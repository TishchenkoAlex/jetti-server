import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  ResolvedAssignee,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import {
  BusinessProcessTaskAssignmentRuleResult,
} from '../types/business-process-rule.types';
import {
  BusinessProcessTaskRepository,
  CreateBusinessProcessTaskInput,
} from '../repositories/bp-task.repository';
import { requireBusinessProcessUserId } from './business-process-user-lookup';
import { DelegationResolver } from './delegation-resolver';
import { BusinessProcessRuleLifecycle } from './rule-lifecycle.service';
import { BusinessProcessTaskScheduleResolver } from './task-schedule-resolver';

export class BusinessProcessTaskFactory {
  constructor(
    private readonly ruleLifecycle = new BusinessProcessRuleLifecycle(),
    private readonly scheduleResolver = new BusinessProcessTaskScheduleResolver(ruleLifecycle),
  ) {}

  async createTasksForStep(args: {
    db: MSSQL;
    step: BusinessProcessStep;
    instance: BusinessProcessInstance;
    template: BusinessProcessTemplate;
    user?: string | null;
    context: Record<string, unknown>;
  }): Promise<BusinessProcessTask[]> {
    if (args.step.type !== 'USER_TASK') {
      throw new Error(`Step type ${args.step.type} is not implemented in runtime start yet`);
    }

    const executions = await this.ruleLifecycle.executeTask<BusinessProcessTaskAssignmentRuleResult>({
      db: args.db,
      template: args.template,
      instance: args.instance,
      step: args.step,
      purpose: 'TASK_ASSIGNMENT',
      user: args.user || null,
      data: args.context || {},
    });
    if (!executions.length) {
      throw new Error(`Business process step ${args.step.key} has no TASK_ASSIGNMENT rule`);
    }

    const assignees = await this.resolveAssignees(args.db, executions.map(item => ({
      ruleCode: item.rule.code || item.rule.id,
      result: item.result,
    })));
    const now = new Date();
    const delegated = await new DelegationResolver(args.db).applyToAssignees({
      assignees,
      date: now,
      processTemplate: args.template.code,
      company: args.instance.company || null,
    });
    const uniqueAssignees = this.uniqueAssignees(delegated);
    if (!uniqueAssignees.length) {
      throw new Error(`TASK_ASSIGNMENT rules returned no assignees for business process step ${args.step.key}`);
    }

    const repository = new BusinessProcessTaskRepository(args.db);
    const taskInputs: CreateBusinessProcessTaskInput[] = [];
    for (const assignee of uniqueAssignees) {
      const schedule = await this.scheduleResolver.resolve({
        db: args.db,
        template: args.template,
        instance: args.instance,
        step: args.step,
        assignee,
        user: args.user || null,
        now,
      });
      taskInputs.push({
        instanceId: args.instance.id,
        objectType: args.instance.objectType,
        objectId: args.instance.objectId,
        stepKey: args.step.key,
        title: args.step.title,
        status: schedule.status,
        assignee: {
          user: assignee.userId,
          delegatedFrom: assignee.delegatedFromUser || null,
          redirectedFrom: null,
        },
        activation: schedule.activation,
        deadline: schedule.deadline,
        penalty: {
          amount: null,
          startedAt: null,
          lastCalculatedAt: null,
          nextCalculationAt: null,
        },
      });
    }
    const tasks = await repository.createMany(taskInputs);
    for (const task of tasks) {
      await this.ruleLifecycle.executeTask({
        db: args.db,
        template: args.template,
        instance: args.instance,
        step: args.step,
        task,
        purpose: 'TASK_CREATED',
        user: args.user || null,
        data: { source: 'STEP_ENTRY' },
      });
    }
    return tasks;
  }

  private async resolveAssignees(
    db: MSSQL,
    executions: Array<{
      ruleCode: string;
      result: BusinessProcessTaskAssignmentRuleResult;
    }>,
  ): Promise<ResolvedAssignee[]> {
    const result: ResolvedAssignee[] = [];

    for (const execution of executions) {
      if (!execution.result || typeof execution.result !== 'object' || Array.isArray(execution.result)
        || !Array.isArray(execution.result.assignees)) {
        throw new Error(
          `TASK_ASSIGNMENT rule ${execution.ruleCode} must return { assignees: [{ user }] }`,
        );
      }
      for (const [index, assignee] of execution.result.assignees.entries()) {
        if (!assignee || typeof assignee !== 'object' || typeof assignee.user !== 'string' || !assignee.user.trim()) {
          throw new Error(
            `TASK_ASSIGNMENT rule ${execution.ruleCode} returned invalid assignee at index ${index}`,
          );
        }
        result.push({ userId: await requireBusinessProcessUserId(assignee.user.trim(), db) });
      }
    }

    return this.uniqueAssignees(result);
  }

  private uniqueAssignees(assignees: ResolvedAssignee[]): ResolvedAssignee[] {
    const result = new Map<string, ResolvedAssignee>();
    assignees.forEach(assignee => {
      if (!result.has(assignee.userId)) result.set(assignee.userId, assignee);
    });
    return Array.from(result.values());
  }
}
