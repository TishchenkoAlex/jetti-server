import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTaskActionInput,
  BusinessProcessTaskActionResult,
  BusinessProcessTaskDecision,
  BusinessProcessTaskRedirectInput,
  BusinessProcessTransition,
} from '../types/business-process.types';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessInstanceRepository } from '../repositories/bp-instance.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { BusinessProcessTemplateRepository } from '../repositories/bp-template.repository';
import { BusinessProcessTaskFactory } from './task-factory.service';
import { TransitionResolver } from './transition-resolver';

export class TaskService {
  constructor(
    private readonly db: MSSQL,
    private readonly tasks = new BusinessProcessTaskRepository(db),
    private readonly instances = new BusinessProcessInstanceRepository(db),
    private readonly templates = new BusinessProcessTemplateRepository(db),
    private readonly events = new BusinessProcessEventRepository(db),
    private readonly transitionResolver = new TransitionResolver(),
    private readonly taskFactory = new BusinessProcessTaskFactory(),
  ) {}

  async getMyTasks(userId: string, roles: string[] = []): Promise<BusinessProcessTask[]> {
    return this.tasks.listActiveByAssignee({ userId, roles });
  }

  async approve(taskId: string, input: BusinessProcessTaskActionInput): Promise<BusinessProcessTaskActionResult> {
    return this.decide(taskId, 'APPROVE', input);
  }

  async reject(taskId: string, input: BusinessProcessTaskActionInput): Promise<BusinessProcessTaskActionResult> {
    return this.decide(taskId, 'REJECT', input);
  }

  async redirect(taskId: string, input: BusinessProcessTaskRedirectInput): Promise<BusinessProcessTaskActionResult> {
    let result: BusinessProcessTaskActionResult | null = null;
    await this.db.tx(async tx => {
      const tasks = new BusinessProcessTaskRepository(tx);
      const instances = new BusinessProcessInstanceRepository(tx);
      const events = new BusinessProcessEventRepository(tx);

      const task = await this.requireTask(tasks, taskId);
      this.assertCanActOnTask(task, input.user, this.userRoles());
      if (!input.targetUser && !input.targetRole) {
        throw new Error('Redirect requires targetUser or targetRole');
      }

      const instance = await this.requireRunningInstance(instances, task.instanceId);
      const redirectedTask = await tasks.setDecision({
        taskId,
        status: 'REDIRECTED',
        decisionUser: input.user,
        decisionComment: input.comment || null,
      });
      const createdTasks = await tasks.createMany([{
        instanceId: task.instanceId,
        objectType: task.objectType,
        objectId: task.objectId,
        stepKey: task.stepKey,
        title: task.title,
        status: 'ACTIVE',
        assigneeUser: input.targetUser || null,
        assigneeRole: input.targetRole || null,
        activeFrom: new Date(),
        dueAt: task.dueAt || null,
        redirectedFromUser: input.user,
        penaltyRuleSnapshot: task.penaltyRuleSnapshot,
        penaltyAmount: task.penaltyAmount || null,
      }]);

      await events.appendOnce({
        instanceId: instance.id,
        taskId: redirectedTask.id,
        eventType: 'TASK_REDIRECTED',
        user: input.user,
        payload: {
          stepKey: task.stepKey,
          targetUser: input.targetUser || null,
          targetRole: input.targetRole || null,
          comment: input.comment || null,
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

  private async decide(
    taskId: string,
    decision: BusinessProcessTaskDecision,
    input: BusinessProcessTaskActionInput,
  ): Promise<BusinessProcessTaskActionResult> {
    let result: BusinessProcessTaskActionResult | null = null;
    await this.db.tx(async tx => {
      const tasks = new BusinessProcessTaskRepository(tx);
      const instances = new BusinessProcessInstanceRepository(tx);
      const templates = new BusinessProcessTemplateRepository(tx);
      const events = new BusinessProcessEventRepository(tx);

      const task = await this.requireTask(tasks, taskId);
      this.assertCanActOnTask(task, input.user, this.userRoles());

      const instance = await this.requireRunningInstance(instances, task.instanceId);
      const template = await templates.getByCodeAndVersion(instance.templateCode, instance.templateVersion);
      if (!template) {
        throw new Error(`Business process template ${instance.templateCode} v${instance.templateVersion} not found`);
      }

      const step = template.steps.find(item => item.key === task.stepKey);
      if (!step) throw new Error(`Business process step ${task.stepKey} not found`);

      const context = {
        ...(instance.context || {}),
        context: instance.context || {},
        objectType: instance.objectType,
        objectId: instance.objectId,
        taskId: task.id,
        user: input.user,
        decision,
      };
      const transition = this.transitionResolver.resolve({
        transitions: template.transitions,
        fromStepKey: task.stepKey,
        decision,
        context,
      });

      const decidedTask = await tasks.setDecision({
        taskId,
        status: decision === 'APPROVE' ? 'APPROVED' : 'REJECTED',
        decisionUser: input.user,
        decisionComment: input.comment || null,
      });
      const cancelledTasks = await tasks.cancelSiblingTasks({
        instanceId: task.instanceId,
        stepKey: task.stepKey,
        exceptTaskId: task.id,
        decisionUser: input.user,
        reason: 'sibling-task-cancelled-after-decision',
      });

      await events.appendOnce({
        instanceId: instance.id,
        taskId: task.id,
        eventType: decision === 'APPROVE' ? 'TASK_APPROVED' : 'TASK_REJECTED',
        user: input.user,
        payload: {
          stepKey: task.stepKey,
          decision,
          comment: input.comment || null,
        },
        eventKey: decision === 'APPROVE' ? `task-approved:${task.id}` : `task-rejected:${task.id}`,
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

      result = await this.applyTransition({
        tx,
        instances,
        events,
        instance,
        task: decidedTask,
        transition,
        user: input.user,
        context,
        templateSteps: template.steps,
      });
    });

    return result!;
  }

  private async applyTransition(args: {
    tx: MSSQL;
    instances: BusinessProcessInstanceRepository;
    events: BusinessProcessEventRepository;
    instance: BusinessProcessInstance;
    task: BusinessProcessTask;
    transition: BusinessProcessTransition;
    user: string;
    context: Record<string, unknown>;
    templateSteps: BusinessProcessStep[];
  }): Promise<BusinessProcessTaskActionResult> {
    if (args.transition.to === 'END_APPROVED') {
      return this.completeInstance(args, 'COMPLETED', 'PROCESS_COMPLETED', 'APPROVED');
    }
    if (args.transition.to === 'END_REJECTED') {
      return this.completeInstance(args, 'REJECTED', 'PROCESS_REJECTED', 'REJECTED');
    }
    if (args.transition.to === 'END_CANCELLED') {
      return this.completeInstance(args, 'CANCELLED', 'PROCESS_CANCELLED', 'CANCELLED');
    }

    const nextStep = args.templateSteps.find(step => step.key === args.transition.to);
    if (!nextStep) throw new Error(`Business process step ${args.transition.to} not found`);

    const createdTasks = await this.taskFactory.createTasksForStep({
      db: args.tx,
      step: nextStep,
      instanceId: args.instance.id,
      objectType: args.instance.objectType,
      objectId: args.instance.objectId,
      user: args.user,
      author: args.instance.author || null,
      context: args.context,
    });
    await args.instances.setCurrentStep({
      instanceId: args.instance.id,
      stepKey: nextStep.key,
    });
    await this.writeTaskCreatedEvents(args.events, args.instance.id, createdTasks, args.user);

    const updatedInstance = await args.instances.getById(args.instance.id);
    if (!updatedInstance) throw new Error(`Business process instance ${args.instance.id} not found after transition`);

    return {
      task: args.task,
      instance: updatedInstance,
      createdTasks,
      completed: false,
    };
  }

  private async completeInstance(
    args: {
      instances: BusinessProcessInstanceRepository;
      events: BusinessProcessEventRepository;
      instance: BusinessProcessInstance;
      task: BusinessProcessTask;
      user: string;
    },
    status: 'COMPLETED' | 'REJECTED' | 'CANCELLED',
    eventType: 'PROCESS_COMPLETED' | 'PROCESS_REJECTED' | 'PROCESS_CANCELLED',
    result: 'APPROVED' | 'REJECTED' | 'CANCELLED',
  ): Promise<BusinessProcessTaskActionResult> {
    await args.instances.complete({
      instanceId: args.instance.id,
      status,
    });
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

    const updatedInstance = await args.instances.getById(args.instance.id);
    if (!updatedInstance) throw new Error(`Business process instance ${args.instance.id} not found after completion`);

    return {
      task: args.task,
      instance: updatedInstance,
      createdTasks: [],
      completed: true,
    };
  }

  private async writeTaskCreatedEvents(
    events: BusinessProcessEventRepository,
    instanceId: string,
    tasks: BusinessProcessTask[],
    user: string,
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
          assigneeUser: task.assigneeUser || null,
          assigneeRole: task.assigneeRole || null,
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
    }
  }

  private assertCanActOnTask(task: BusinessProcessTask, user: string, roles: string[] = []): void {
    if (!['ACTIVE', 'OVERDUE'].includes(task.status)) {
      throw new Error(`Task ${task.id} is not active`);
    }

    if (task.assigneeUser === user) return;
    if (task.assigneeRole && roles.includes(task.assigneeRole)) return;

    throw new Error(`User ${user} cannot act on task ${task.id}`);
  }

  private async requireTask(tasks: BusinessProcessTaskRepository, taskId: string): Promise<BusinessProcessTask> {
    const task = await tasks.getById(taskId);
    if (!task) throw new Error(`Business process task ${taskId} not found`);
    return task;
  }

  private async requireRunningInstance(
    instances: BusinessProcessInstanceRepository,
    instanceId: string,
  ): Promise<BusinessProcessInstance> {
    const instance = await instances.getById(instanceId);
    if (!instance) throw new Error(`Business process instance ${instanceId} not found`);
    if (instance.status !== 'RUNNING') throw new Error(`Business process instance ${instanceId} is not running`);
    return instance;
  }

  private userRoles(): string[] {
    return this.db.user && Array.isArray(this.db.user.roles) ? this.db.user.roles : [];
  }
}
