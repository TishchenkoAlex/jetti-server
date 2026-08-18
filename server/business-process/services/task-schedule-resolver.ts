import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTaskStatus,
  BusinessProcessTemplate,
  ResolvedAssignee,
} from '../types/business-process.types';
import {
  BusinessProcessRuleExecution,
  BusinessProcessTaskActivationDateRuleResult,
  BusinessProcessTaskDeadlineDateRuleResult,
} from '../types/business-process-rule.types';
import { BusinessProcessRuleLifecycle } from './rule-lifecycle.service';

export interface BusinessProcessTaskSchedule {
  status: Extract<BusinessProcessTaskStatus, 'WAITING' | 'ACTIVE'>;
  activation: { at: Date | null };
  deadline: { at: Date | null; reachedAt: null };
}

export class BusinessProcessTaskScheduleResolver {
  constructor(private readonly ruleLifecycle = new BusinessProcessRuleLifecycle()) {}

  async resolve(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    step: BusinessProcessStep;
    assignee: ResolvedAssignee;
    user?: string | null;
    now: Date;
  }): Promise<BusinessProcessTaskSchedule> {
    const common = {
      db: args.db,
      template: args.template,
      instance: args.instance,
      step: args.step,
      task: null,
      user: args.user || null,
      data: {
        assignee: {
          user: args.assignee.userId,
          delegatedFrom: args.assignee.delegatedFromUser || null,
        },
        now: args.now,
      },
    };
    const activationRules = await this.ruleLifecycle.executeTask<BusinessProcessTaskActivationDateRuleResult>({
      ...common,
      purpose: 'TASK_ACTIVATION_DATE',
    });
    const deadlineRules = await this.ruleLifecycle.executeTask<BusinessProcessTaskDeadlineDateRuleResult>({
      ...common,
      purpose: 'TASK_DEADLINE_DATE',
    });
    const activationAt = this.lastDate(activationRules, 'activation', 'at');
    const deadlineAt = this.lastDate(deadlineRules, 'deadline', 'at');

    if (activationAt && deadlineAt && deadlineAt.getTime() <= activationAt.getTime()) {
      throw new Error(
        `Task deadline ${deadlineAt.toISOString()} must be later than activation ${activationAt.toISOString()} `
        + `for business process step ${args.step.key}`,
      );
    }

    return {
      status: activationAt && activationAt.getTime() > args.now.getTime() ? 'WAITING' : 'ACTIVE',
      activation: { at: activationAt },
      deadline: { at: deadlineAt, reachedAt: null },
    };
  }

  private lastDate(
    executions: Array<BusinessProcessRuleExecution<unknown>>,
    objectKey: 'activation' | 'deadline',
    dateKey: 'at',
  ): Date | null {
    let result: Date | null = null;
    for (const execution of executions) {
      const value = execution.result;
      if (!value || typeof value !== 'object' || Array.isArray(value)) {
        throw new Error(`${execution.rule.purpose} rule ${execution.rule.code || execution.rule.id} returned invalid result`);
      }
      const objectValue = value[objectKey];
      if (!objectValue || typeof objectValue !== 'object' || Array.isArray(objectValue) || !(dateKey in objectValue)) {
        throw new Error(
          `${execution.rule.purpose} rule ${execution.rule.code || execution.rule.id} `
          + `must return { ${objectKey}: { ${dateKey} } }`,
        );
      }
      result = this.dateOrNull(objectValue[dateKey], execution.rule.code || execution.rule.id, execution.rule.purpose);
    }
    return result;
  }

  private dateOrNull(value: unknown, rule: string, purpose: string): Date | null {
    if (value == null) return null;
    const date = value instanceof Date ? new Date(value.getTime()) : new Date(String(value));
    if (Number.isNaN(date.getTime())) {
      throw new Error(`${purpose} rule ${rule} returned invalid date`);
    }
    return date;
  }
}
