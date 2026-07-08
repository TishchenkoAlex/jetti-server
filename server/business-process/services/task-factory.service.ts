import { MSSQL } from '../../mssql';
import {
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTaskStatus,
} from '../types/business-process.types';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { AssignmentResolver } from './assignment-resolver';
import { TaskDateResolver } from './task-date-resolver';

export class BusinessProcessTaskFactory {
  constructor(
    private readonly assignmentResolver = new AssignmentResolver(),
    private readonly dateResolver = new TaskDateResolver(),
  ) {}

  async createTasksForStep(args: {
    db: MSSQL;
    step: BusinessProcessStep;
    instanceId: string;
    objectType: string;
    objectId: string;
    user?: string | null;
    author?: string | null;
    context: Record<string, unknown>;
  }): Promise<BusinessProcessTask[]> {
    if (args.step.type !== 'USER_TASK') {
      throw new Error(`Step type ${args.step.type} is not implemented in runtime start yet`);
    }
    if (!args.step.assignmentRule) throw new Error('USER_TASK step requires assignmentRule');

    const assignees = await this.assignmentResolver.resolve(args.step.assignmentRule, {
      user: args.user || null,
      author: args.author || args.user || null,
      objectType: args.objectType,
      objectId: args.objectId,
      object: args.context,
      processContext: args.context,
    });
    if (!assignees.length) throw new Error(`No assignee resolved for step ${args.step.key}`);
    if (assignees.some(assignee => !assignee.userId && !assignee.role)) {
      throw new Error(`No assignee user or role resolved for step ${args.step.key}`);
    }

    const now = new Date();
    const activeFrom = this.dateResolver.resolveActiveFrom(args.step.waitUntilRule, args.context);
    const dueBase = activeFrom || now;
    const dueAt = this.dateResolver.resolveDueAt(args.step.dueRule, dueBase, args.context);
    const status: BusinessProcessTaskStatus = activeFrom && activeFrom.getTime() > now.getTime() ? 'WAITING' : 'ACTIVE';
    const taskRepository = new BusinessProcessTaskRepository(args.db);

    return taskRepository.createMany(assignees.map(assignee => ({
      instanceId: args.instanceId,
      objectType: args.objectType,
      objectId: args.objectId,
      stepKey: args.step.key,
      title: args.step.title,
      status,
      assigneeUser: assignee.userId || null,
      assigneeRole: assignee.role || null,
      activeFrom,
      dueAt,
      delegatedFromUser: assignee.delegatedFromUser || null,
      penaltyRuleSnapshot: args.step.penaltyRule,
    })));
  }
}

