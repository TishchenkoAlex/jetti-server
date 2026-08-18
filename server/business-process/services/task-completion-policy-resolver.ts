import { BusinessProcessStep, BusinessProcessTask } from '../types/business-process.types';

export interface BusinessProcessTaskDecisionSummary {
  taskId: string;
  assigneeUser: string;
  key: string | null;
  user: string | null;
  comment: string | null;
  source: 'USER' | 'SYSTEM' | null;
  at: Date | null;
}

export interface BusinessProcessTaskCompletionResolution {
  shouldAdvance: boolean;
  cancelSiblings: boolean;
  pendingTaskIds: string[];
  taskDecisions: BusinessProcessTaskDecisionSummary[];
}

export class BusinessProcessTaskCompletionPolicyResolver {
  resolve(args: {
    step: BusinessProcessStep;
    tasks: BusinessProcessTask[];
  }): BusinessProcessTaskCompletionResolution {
    const pendingTaskIds = args.tasks
      .filter(task => ['CREATED', 'WAITING', 'ACTIVE', 'OVERDUE'].includes(task.status))
      .map(task => task.id);
    const taskDecisions = args.tasks
      .filter(task => !!task.decision.key)
      .map(task => ({
        taskId: task.id,
        assigneeUser: task.assignee.user,
        key: task.decision.key || null,
        user: task.decision.user || null,
        comment: task.decision.comment || null,
        source: task.decision.source || null,
        at: task.decision.at || null,
      }));

    return {
      shouldAdvance: args.step.completionPolicy === 'ANY' || pendingTaskIds.length === 0,
      cancelSiblings: args.step.completionPolicy === 'ANY',
      pendingTaskIds,
      taskDecisions,
    };
  }
}
