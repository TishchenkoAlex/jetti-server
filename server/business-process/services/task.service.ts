import { MSSQL } from '../../mssql';
import {
  BusinessProcessDecision,
  BusinessProcessInstance,
  BusinessProcessTask,
  BusinessProcessTaskActionInput,
  BusinessProcessTaskActionResult,
  BusinessProcessTaskDecision,
  BusinessProcessTaskDecisionInput,
  BusinessProcessTaskRedirectInput,
  BusinessProcessTemplate,
  BusinessProcessTransition,
} from '../types/business-process.types';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessDelegationRepository } from '../repositories/bp-delegation.repository';
import { BusinessProcessInstanceRepository } from '../repositories/bp-instance.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { BusinessProcessTemplateRepository } from '../repositories/bp-template.repository';
import { BusinessProcessObjectAdapterRegistry } from '../integration/object-adapter.registry';
import { BusinessProcessObjectStatusChange } from '../types/object-integration.types';
import { BusinessProcessTaskFactory } from './task-factory.service';
import { TaskAccessResolver } from './task-access-resolver';
import { TransitionResolver } from './transition-resolver';
import { BusinessProcessRuleLifecycle } from './rule-lifecycle.service';
import { BusinessProcessTaskDecisionResolver } from './task-decision-resolver';
import { BusinessProcessTaskCompletionPolicyResolver } from './task-completion-policy-resolver';

type BusinessProcessTaskDecisionExecutionInput = Omit<BusinessProcessTaskDecisionInput, 'user'> & {
  user: string | null;
};

export class TaskService {
  constructor(
    private readonly db: MSSQL,
    private readonly tasks = new BusinessProcessTaskRepository(db),
    private readonly instances = new BusinessProcessInstanceRepository(db),
    private readonly templates = new BusinessProcessTemplateRepository(db),
    private readonly events = new BusinessProcessEventRepository(db),
    private readonly transitionResolver = new TransitionResolver(),
    private readonly taskFactory = new BusinessProcessTaskFactory(),
    private readonly accessResolver = new TaskAccessResolver(db),
    private readonly ruleLifecycle = new BusinessProcessRuleLifecycle(),
    private readonly decisionResolver = new BusinessProcessTaskDecisionResolver(ruleLifecycle),
    private readonly completionPolicyResolver = new BusinessProcessTaskCompletionPolicyResolver(),
  ) {}

  async getMyTasks(userId: string): Promise<BusinessProcessTask[]> {
    const tasks = await this.tasks.listActiveByAssignee({ userId });
    const delegations = await new BusinessProcessDelegationRepository(this.db).listActiveForUserTo({
      userTo: userId,
      date: new Date(),
    });

    for (const delegation of delegations) {
      const candidates = await this.tasks.listActiveByAssignee({
        userId: delegation.userFrom,
      });
      tasks.push(...await this.filterAllowedDelegatedTasks(candidates, userId));
    }

    return this.uniqueTasks(tasks);
  }

  async approve(taskId: string, input: BusinessProcessTaskActionInput): Promise<BusinessProcessTaskActionResult> {
    return this.decide(taskId, {
      user: input.user,
      decision: { key: 'APPROVE', comment: input.comment || null },
    });
  }

  async reject(taskId: string, input: BusinessProcessTaskActionInput): Promise<BusinessProcessTaskActionResult> {
    return this.decide(taskId, {
      user: input.user,
      decision: { key: 'REJECT', comment: input.comment || null },
    });
  }

  async getAvailableDecisions(
    taskId: string,
    user: string,
    existingTx?: MSSQL,
  ): Promise<BusinessProcessDecision[]> {
    let result: BusinessProcessDecision[] | null = null;
    const execute = async (tx: MSSQL) => {
      const tasks = new BusinessProcessTaskRepository(tx);
      const instances = new BusinessProcessInstanceRepository(tx);
      const templates = new BusinessProcessTemplateRepository(tx);
      const task = await this.requireTask(tasks, taskId);
      const instance = await this.requireRunningInstance(instances, task.instanceId);
      await this.assertCanActOnTask({ task, user, instance, db: tx });
      const template = await templates.getByCodeAndVersion(instance.templateCode, instance.templateVersion);
      if (!template) {
        throw new Error(`Business process template ${instance.templateCode} v${instance.templateVersion} not found`);
      }
      const step = template.steps.find(item => item.key === task.stepKey);
      if (!step) throw new Error(`Business process step ${task.stepKey} not found`);
      result = await this.decisionResolver.resolve({ db: tx, template, instance, step, task, user });
    };
    if (existingTx) await execute(existingTx);
    else await this.db.tx(execute);
    return result!;
  }

  async redirect(taskId: string, input: BusinessProcessTaskRedirectInput): Promise<BusinessProcessTaskActionResult> {
    let result: BusinessProcessTaskActionResult | null = null;
    await this.db.tx(async tx => {
      const tasks = new BusinessProcessTaskRepository(tx);
      const instances = new BusinessProcessInstanceRepository(tx);
      const events = new BusinessProcessEventRepository(tx);
      const templates = new BusinessProcessTemplateRepository(tx);

      const task = await this.requireTask(tasks, taskId);
      const instance = await this.requireRunningInstance(instances, task.instanceId, true);
      const access = await this.assertCanActOnTask({ task, user: input.user, instance, db: tx });
      const template = await templates.getByCodeAndVersion(instance.templateCode, instance.templateVersion);
      if (!template) {
        throw new Error(`Business process template ${instance.templateCode} v${instance.templateVersion} not found`);
      }
      const step = template.steps.find(item => item.key === task.stepKey);
      if (!step) throw new Error(`Business process step ${task.stepKey} not found`);
      if (step.allowRedirect !== true) throw new Error(`Redirect is not allowed for step ${task.stepKey}`);

      const lifecycleData = {
        action: 'REDIRECT',
        targetUser: input.targetUser,
        comment: input.comment || null,
        delegatedFromUser: access.delegatedFromUser || null,
      };
      await this.ruleLifecycle.executeTask({
        db: tx,
        template,
        instance,
        step,
        task,
        purpose: 'TASK_BEFORE_EXECUTE',
        user: input.user,
        data: lifecycleData,
      });

      const redirectedTask = await tasks.setDecisionIfStatusIn({
        taskId,
        allowedStatuses: ['ACTIVE', 'OVERDUE'],
        status: 'REDIRECTED',
        decision: {
          key: 'REDIRECT',
          user: input.user,
          comment: input.comment || null,
          source: 'USER',
        },
      });
      if (!redirectedTask) throw new Error(`Task ${taskId} is not active or was already completed`);
      await this.ruleLifecycle.executeTask({
        db: tx,
        template,
        instance,
        step,
        task: redirectedTask,
        purpose: 'TASK_AFTER_EXECUTE',
        user: input.user,
        data: lifecycleData,
      });
      const createdTasks = await tasks.createMany([{
        instanceId: task.instanceId,
        objectType: task.objectType,
        objectId: task.objectId,
        stepKey: task.stepKey,
        title: task.title,
        status: 'ACTIVE',
        assignee: {
          user: input.targetUser,
          redirectedFrom: input.user,
        },
        activation: { at: new Date() },
        deadline: { ...task.deadline },
        penalty: { ...task.penalty },
      }]);
      for (const createdTask of createdTasks) {
        await this.ruleLifecycle.executeTask({
          db: tx,
          template,
          instance,
          step,
          task: createdTask,
          purpose: 'TASK_CREATED',
          user: input.user,
          data: {
            source: 'REDIRECT',
            redirectedTaskId: task.id,
          },
        });
      }
      await instances.setContext({
        instanceId: instance.id,
        context: instance.context || {},
      });

      await events.appendOnce({
        instanceId: instance.id,
        taskId: redirectedTask.id,
        eventType: 'TASK_REDIRECTED',
        user: input.user,
        payload: {
          stepKey: task.stepKey,
          targetUser: input.targetUser,
          comment: input.comment || null,
          delegatedFromUser: access.delegatedFromUser || null,
        },
        eventKey: `task-redirected:${task.id}`,
      });
      await this.writeTaskCreatedEvents(events, instance.id, createdTasks, input.user);

      result = {
        task: redirectedTask,
        instance,
        createdTasks,
        completed: false,
      };
    });

    return result!;
  }

  async delegate(taskId: string, args: unknown, tx?: unknown): Promise<unknown> {
    throw new Error('TaskService.delegate is not implemented');
  }

  async decide(
    taskId: string,
    input: BusinessProcessTaskDecisionInput,
    tx?: MSSQL,
  ): Promise<BusinessProcessTaskActionResult> {
    return this.decideInternal(taskId, input, 'USER', tx);
  }

  async decideSystem(
    taskId: string,
    input: Omit<BusinessProcessTaskDecisionInput, 'user'>,
    tx?: MSSQL,
  ): Promise<BusinessProcessTaskActionResult> {
    return this.decideInternal(taskId, { ...input, user: null }, 'SYSTEM', tx);
  }

  private async decideInternal(
    taskId: string,
    input: BusinessProcessTaskDecisionExecutionInput,
    source: 'USER' | 'SYSTEM',
    existingTx?: MSSQL,
  ): Promise<BusinessProcessTaskActionResult> {
    const decision = typeof input.decision?.key === 'string' ? input.decision.key.trim() : '';
    const comment = input.decision?.comment || null;
    if (!decision) throw new Error('Business process task decision must be a non-empty string');
    let result: BusinessProcessTaskActionResult | null = null;
    const execute = async (tx: MSSQL) => {
      const tasks = new BusinessProcessTaskRepository(tx);
      const instances = new BusinessProcessInstanceRepository(tx);
      const templates = new BusinessProcessTemplateRepository(tx);
      const events = new BusinessProcessEventRepository(tx);

      const task = await this.requireTask(tasks, taskId);
      const instance = await this.requireRunningInstance(instances, task.instanceId, true);
      const access = source === 'USER'
        ? await this.assertCanActOnTask({ task, user: input.user!, instance, db: tx })
        : { delegatedFromUser: null };
      const template = await templates.getByCodeAndVersion(instance.templateCode, instance.templateVersion);
      if (!template) {
        throw new Error(`Business process template ${instance.templateCode} v${instance.templateVersion} not found`);
      }

      const step = template.steps.find(item => item.key === task.stepKey);
      if (!step) throw new Error(`Business process step ${task.stepKey} not found`);

      const availableDecisions = source === 'USER'
        ? await this.decisionResolver.resolve({
          db: tx,
          template,
          instance,
          step,
          task,
          user: input.user!,
        })
        : step.decisions;
      this.decisionResolver.requireAvailable({
        decisions: availableDecisions,
        key: decision,
        comment,
        taskId: task.id,
        user: input.user || 'SYSTEM',
      });

      const lifecycleData = {
        action: 'DECISION',
        decision,
        comment,
        source,
        delegatedFromUser: access.delegatedFromUser || null,
      };
      await this.ruleLifecycle.executeTask({
        db: tx,
        template,
        instance,
        step,
        task,
        purpose: 'TASK_BEFORE_EXECUTE',
        user: input.user,
        data: lifecycleData,
      });

      const decidedTask = await tasks.setDecisionIfStatusIn({
        taskId,
        allowedStatuses: ['ACTIVE', 'OVERDUE'],
        status: this.taskStatusForDecision(decision, source),
        decision: {
          key: decision,
          user: input.user,
          comment,
          source,
        },
      });
      if (!decidedTask) throw new Error(`Task ${taskId} is not active or was already completed`);
      await this.ruleLifecycle.executeTask({
        db: tx,
        template,
        instance,
        step,
        task: decidedTask,
        purpose: 'TASK_AFTER_EXECUTE',
        user: input.user,
        data: lifecycleData,
      });
      const stepTasks = await tasks.listByInstanceStep({
        instanceId: task.instanceId,
        stepKey: task.stepKey,
      });
      const completion = this.completionPolicyResolver.resolve({ step, tasks: stepTasks });
      const cancelledTasks = completion.cancelSiblings
        ? await tasks.cancelSiblingTasks({
          instanceId: task.instanceId,
          stepKey: task.stepKey,
          exceptTaskId: task.id,
          decisionUser: input.user,
          reason: 'sibling-task-cancelled-after-decision',
        })
        : [];

      const decisionEvent = this.taskEventForDecision(decision, source);
      await events.appendOnce({
        instanceId: instance.id,
        taskId: task.id,
        eventType: decisionEvent.eventType,
        user: input.user,
        payload: {
          stepKey: task.stepKey,
          decision,
          comment,
          source,
          completionPolicy: step.completionPolicy,
          delegatedFromUser: access.delegatedFromUser || null,
        },
        eventKey: `${decisionEvent.eventKeyPrefix}:${task.id}`,
      });
      for (const cancelledTask of cancelledTasks) {
        await events.appendOnce({
          instanceId: instance.id,
          taskId: cancelledTask.id,
          eventType: 'TASK_CANCELLED',
          user: input.user,
          payload: {
            stepKey: cancelledTask.stepKey,
            reason: 'sibling-task-cancelled-after-decision',
            winnerTaskId: task.id,
          },
          eventKey: `task-cancelled:${cancelledTask.id}`,
        });
      }

      if (!completion.shouldAdvance) {
        await instances.setContext({
          instanceId: instance.id,
          context: instance.context || {},
        });
        result = {
          task: decidedTask,
          instance,
          createdTasks: [],
          completed: false,
          objectStatusChanges: [],
        };
        return;
      }

      const context = {
        ...(instance.context || {}),
        context: instance.context || {},
        objectType: instance.objectType,
        objectId: instance.objectId,
        taskId: task.id,
        user: input.user,
        decision,
        decisionSource: source,
        completionPolicy: step.completionPolicy,
        taskDecisions: completion.taskDecisions,
      };
      const transition = this.transitionResolver.resolve({
        transitions: template.transitions,
        fromStepKey: task.stepKey,
        decision,
        context,
      });

      result = await this.applyTransition({
        tx,
        instances,
        events,
        instance,
        task: decidedTask,
        transition,
        user: input.user,
        context,
        template,
      });
    };

    if (existingTx) await execute(existingTx);
    else await this.db.tx(execute);

    return result!;
  }

  private async applyTransition(args: {
    tx: MSSQL;
    instances: BusinessProcessInstanceRepository;
    events: BusinessProcessEventRepository;
    instance: BusinessProcessInstance;
    task: BusinessProcessTask;
    transition: BusinessProcessTransition;
    user: string | null;
    context: Record<string, unknown>;
    template: BusinessProcessTemplate;
  }): Promise<BusinessProcessTaskActionResult> {
    const currentStep = args.template.steps.find(step => step.key === args.task.stepKey);
    if (args.transition.to === 'END_APPROVED') {
      return this.completeInstance({
        ...args,
        rejectPolicy: currentStep?.rejectPolicy || 'REJECT_PROCESS',
      }, 'COMPLETED', 'PROCESS_COMPLETED', 'APPROVED');
    }
    if (args.transition.to === 'END_REJECTED') {
      return this.completeInstance({
        ...args,
        rejectPolicy: currentStep?.rejectPolicy || 'REJECT_PROCESS',
      }, 'REJECTED', 'PROCESS_REJECTED', 'REJECTED');
    }
    if (args.transition.to === 'END_CANCELLED') {
      return this.completeInstance({
        ...args,
        rejectPolicy: currentStep?.rejectPolicy || 'REJECT_PROCESS',
      }, 'CANCELLED', 'PROCESS_CANCELLED', 'CANCELLED');
    }

    const nextStep = args.template.steps.find(step => step.key === args.transition.to);
    if (!nextStep) throw new Error(`Business process step ${args.transition.to} not found`);

    await this.ruleLifecycle.executeProcess({
      db: args.tx,
      template: args.template,
      instance: args.instance,
      step: currentStep || null,
      task: args.task,
      purpose: 'PROCESS_BEFORE_SAVE',
      user: args.user,
      data: {
        operation: 'SET_CURRENT_STEP',
        fromStepKey: args.task.stepKey,
        toStepKey: nextStep.key,
        decision: args.task.decision,
      },
    });
    await args.instances.setCurrentStep({
      instanceId: args.instance.id,
      stepKey: nextStep.key,
      context: args.instance.context || {},
    });
    const updatedInstance = await args.instances.getById(args.instance.id);
    if (!updatedInstance) throw new Error(`Business process instance ${args.instance.id} not found after transition`);
    const createdTasks = await this.taskFactory.createTasksForStep({
      db: args.tx,
      step: nextStep,
      instance: updatedInstance,
      template: args.template,
      user: args.user,
      context: args.context,
    });
    await args.instances.setContext({
      instanceId: updatedInstance.id,
      context: updatedInstance.context || {},
    });
    await this.writeTaskCreatedEvents(args.events, args.instance.id, createdTasks, args.user);

    return {
      task: args.task,
      instance: updatedInstance,
      createdTasks,
      completed: false,
      objectStatusChanges: [],
    };
  }

  private async completeInstance(
    args: {
      tx: MSSQL;
      instances: BusinessProcessInstanceRepository;
      events: BusinessProcessEventRepository;
      instance: BusinessProcessInstance;
      task: BusinessProcessTask;
      template: BusinessProcessTemplate;
      user: string | null;
      rejectPolicy?: string | null;
    },
    status: 'COMPLETED' | 'REJECTED' | 'CANCELLED',
    eventType: 'PROCESS_COMPLETED' | 'PROCESS_REJECTED' | 'PROCESS_CANCELLED',
    result: 'APPROVED' | 'REJECTED' | 'CANCELLED',
  ): Promise<BusinessProcessTaskActionResult> {
    const step = args.template.steps.find(item => item.key === args.task.stepKey) || null;
    await this.ruleLifecycle.executeProcess({
      db: args.tx,
      template: args.template,
      instance: args.instance,
      step,
      task: args.task,
      purpose: 'PROCESS_BEFORE_SAVE',
      user: args.user,
      data: {
        operation: 'COMPLETE',
        status,
        result,
      },
    });
    await args.instances.complete({
      instanceId: args.instance.id,
      status,
      context: args.instance.context || {},
    });

    const updatedInstance = await args.instances.getById(args.instance.id);
    if (!updatedInstance) throw new Error(`Business process instance ${args.instance.id} not found after completion`);

    await this.ruleLifecycle.executeProcess({
      db: args.tx,
      template: args.template,
      instance: updatedInstance,
      step,
      task: args.task,
      purpose: 'PROCESS_COMPLETED',
      user: args.user,
      data: {
        status,
        result,
      },
    });
    await args.instances.setContext({
      instanceId: updatedInstance.id,
      context: updatedInstance.context || {},
    });

    const adapter = new BusinessProcessObjectAdapterRegistry().get(args.instance.objectType);
    let statusChange: BusinessProcessObjectStatusChange | null = null;
    if (adapter) {
      statusChange = status === 'COMPLETED'
        ? await adapter.onProcessCompleted({
          instance: updatedInstance,
          task: args.task,
          user: args.user,
          tx: args.tx,
        })
        : status === 'REJECTED'
          ? await adapter.onProcessRejected({
            instance: updatedInstance,
            task: args.task,
            rejectPolicy: args.rejectPolicy || 'REJECT_PROCESS',
            user: args.user,
            tx: args.tx,
          })
          : await adapter.onProcessCancelled({
            instance: updatedInstance,
            task: args.task,
            user: args.user,
            tx: args.tx,
          });
      await this.appendObjectStatusChanged(args.events, updatedInstance.id, args.user, statusChange, eventType);
    }

    await args.events.appendOnce({
      instanceId: args.instance.id,
      eventType,
      user: args.user,
      payload: {
        result,
        taskId: args.task.id,
        stepKey: args.task.stepKey,
      },
      eventKey: eventType === 'PROCESS_COMPLETED'
        ? `process-completed:${args.instance.id}`
        : eventType === 'PROCESS_REJECTED'
          ? `process-rejected:${args.instance.id}`
          : `process-cancelled:${args.instance.id}`,
    });

    return {
      task: args.task,
      instance: updatedInstance,
      createdTasks: [],
      completed: true,
      objectStatusChanges: statusChange ? [statusChange] : [],
    };
  }

  private async writeTaskCreatedEvents(
    events: BusinessProcessEventRepository,
    instanceId: string,
    tasks: BusinessProcessTask[],
    user: string | null,
  ): Promise<void> {
    for (const task of tasks) {
      await events.appendOnce({
        instanceId,
        taskId: task.id,
        eventType: 'TASK_CREATED',
        user,
        payload: {
          stepKey: task.stepKey,
          title: task.title,
          assigneeUser: task.assignee.user,
        },
        eventKey: `task-created:${task.id}`,
      });

      if (task.status === 'ACTIVE') {
        await events.appendOnce({
          instanceId,
          taskId: task.id,
          eventType: 'TASK_ACTIVATED',
          user,
          payload: {
            stepKey: task.stepKey,
            title: task.title,
          },
          eventKey: `task-activated:${task.id}`,
        });
      }

      if (task.assignee.delegatedFrom) {
        await events.appendOnce({
          instanceId,
          taskId: task.id,
          eventType: 'TASK_DELEGATED',
          user,
          payload: {
            stepKey: task.stepKey,
            delegatedFromUser: task.assignee.delegatedFrom,
            assigneeUser: task.assignee.user,
          },
          eventKey: `task-delegated:${task.id}`,
        });
      }
    }
  }

  private async appendObjectStatusChanged(
    events: BusinessProcessEventRepository,
    instanceId: string,
    user: string | null,
    statusChange: BusinessProcessObjectStatusChange | null,
    reason: 'PROCESS_COMPLETED' | 'PROCESS_REJECTED' | 'PROCESS_CANCELLED',
  ): Promise<void> {
    if (!statusChange) return;
    await events.appendOnce({
      instanceId,
      eventType: 'OBJECT_STATUS_CHANGED',
      user,
      payload: {
        objectType: statusChange.objectType,
        objectId: statusChange.objectId,
        fromStatus: statusChange.fromStatus || null,
        toStatus: statusChange.toStatus || null,
        reason,
      },
      eventKey: `object-status-changed:${instanceId}:${reason}`,
    });
  }

  private async assertCanActOnTask(args: {
    task: BusinessProcessTask;
    user: string;
    instance?: BusinessProcessInstance;
    db?: MSSQL;
  }): Promise<{
    delegatedFromUser?: string | null;
  }> {
    const task = args.task;
    if (!['ACTIVE', 'OVERDUE'].includes(task.status)) {
      throw new Error(`Task ${task.id} is not active`);
    }

    const accessResolver = args.db ? new TaskAccessResolver(args.db) : this.accessResolver;
    const access = await accessResolver.canActOnTask({
      task,
      user: args.user,
      templateCode: args.instance?.templateCode || null,
      company: args.instance?.company || null,
    });
    if (!access.allowed) throw new Error(`User ${args.user} cannot act on task ${task.id}`);

    return {
      delegatedFromUser: access.delegatedFromUser || null,
    };
  }

  private async requireTask(tasks: BusinessProcessTaskRepository, taskId: string): Promise<BusinessProcessTask> {
    const task = await tasks.getById(taskId);
    if (!task) throw new Error(`Business process task ${taskId} not found`);
    return task;
  }

  private async requireRunningInstance(
    instances: BusinessProcessInstanceRepository,
    instanceId: string,
    lockForUpdate: boolean = false,
  ): Promise<BusinessProcessInstance> {
    const instance = lockForUpdate
      ? await instances.getByIdForUpdate(instanceId)
      : await instances.getById(instanceId);
    if (!instance) throw new Error(`Business process instance ${instanceId} not found`);
    if (instance.status !== 'RUNNING') throw new Error(`Business process instance ${instanceId} is not running`);
    return instance;
  }

  private taskStatusForDecision(
    decision: BusinessProcessTaskDecision,
    source: 'USER' | 'SYSTEM',
  ): 'COMPLETED' | 'APPROVED' | 'REJECTED' | 'AUTO_COMPLETED' | 'TIMEOUT' {
    if (source === 'SYSTEM') return decision === 'TIMEOUT' ? 'TIMEOUT' : 'AUTO_COMPLETED';
    if (decision === 'APPROVE') return 'APPROVED';
    if (decision === 'REJECT') return 'REJECTED';
    return 'COMPLETED';
  }

  private taskEventForDecision(decision: BusinessProcessTaskDecision, source: 'USER' | 'SYSTEM'): {
    eventType: 'TASK_COMPLETED' | 'TASK_APPROVED' | 'TASK_REJECTED' | 'TASK_AUTO_COMPLETED' | 'TASK_TIMEOUT';
    eventKeyPrefix: 'task-completed' | 'task-approved' | 'task-rejected' | 'task-auto-completed' | 'task-timeout';
  } {
    if (source === 'SYSTEM') {
      if (decision === 'TIMEOUT') return { eventType: 'TASK_TIMEOUT', eventKeyPrefix: 'task-timeout' };
      return { eventType: 'TASK_AUTO_COMPLETED', eventKeyPrefix: 'task-auto-completed' };
    }
    if (decision === 'APPROVE') return { eventType: 'TASK_APPROVED', eventKeyPrefix: 'task-approved' };
    if (decision === 'REJECT') return { eventType: 'TASK_REJECTED', eventKeyPrefix: 'task-rejected' };
    return { eventType: 'TASK_COMPLETED', eventKeyPrefix: 'task-completed' };
  }

  private uniqueTasks(tasks: BusinessProcessTask[]): BusinessProcessTask[] {
    const map = new Map<string, BusinessProcessTask>();
    tasks.forEach(task => map.set(task.id, task));
    return Array.from(map.values());
  }

  private async filterAllowedDelegatedTasks(tasks: BusinessProcessTask[], user: string): Promise<BusinessProcessTask[]> {
    const result: BusinessProcessTask[] = [];
    for (const task of tasks) {
      const instance = await this.instances.getById(task.instanceId);
      if (!instance) continue;

      const access = await this.accessResolver.canActOnTask({
        task,
        user,
        templateCode: instance.templateCode,
        company: instance.company || null,
      });
      if (access.allowed) result.push(task);
    }
    return result;
  }
}
