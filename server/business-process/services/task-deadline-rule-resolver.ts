import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import {
  BusinessProcessTaskDeadlineAutoExecuteRuleResult,
  BusinessProcessTaskDeadlinePenaltyRuleResult,
} from '../types/business-process-rule.types';
import { BusinessProcessRuleLifecycle } from './rule-lifecycle.service';

export interface BusinessProcessPenaltyResolution {
  configured: boolean;
  amount: number;
  nextCalculationAt: Date | null;
}

export interface BusinessProcessAutoDecisionResolution {
  key: string;
  comment: string | null;
}

export class BusinessProcessTaskDeadlineRuleResolver {
  constructor(private readonly ruleLifecycle = new BusinessProcessRuleLifecycle()) {}

  async resolvePenalty(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    step: BusinessProcessStep;
    task: BusinessProcessTask;
    now: Date;
  }): Promise<BusinessProcessPenaltyResolution> {
    const executions = await this.ruleLifecycle.executeTask<BusinessProcessTaskDeadlinePenaltyRuleResult>({
      ...args,
      purpose: 'TASK_DEADLINE_PENALTY',
      user: null,
      data: this.deadlineData(args.task, args.now),
    });
    let amount = 0;
    let nextCalculationAt: Date | null = null;

    for (const execution of executions) {
      const result = execution.result;
      if (!result || typeof result !== 'object' || Array.isArray(result) || !('penalty' in result)) {
        throw new Error(
          `TASK_DEADLINE_PENALTY rule ${execution.rule.code || execution.rule.id} `
          + 'must return { penalty: { amount, nextCalculationAt? } | null }',
        );
      }
      if (result.penalty == null) continue;
      if (typeof result.penalty !== 'object' || Array.isArray(result.penalty)
        || typeof result.penalty.amount !== 'number' || !Number.isFinite(result.penalty.amount)
        || result.penalty.amount < 0) {
        throw new Error(
          `TASK_DEADLINE_PENALTY rule ${execution.rule.code || execution.rule.id} returned invalid amount`,
        );
      }
      amount += result.penalty.amount;
      if (result.penalty.nextCalculationAt != null) {
        const next = this.date(result.penalty.nextCalculationAt, execution.rule.code || execution.rule.id);
        if (next.getTime() <= args.now.getTime()) {
          throw new Error(
            `TASK_DEADLINE_PENALTY rule ${execution.rule.code || execution.rule.id} `
            + 'returned nextCalculationAt that is not later than now',
          );
        }
        if (!nextCalculationAt || next.getTime() < nextCalculationAt.getTime()) nextCalculationAt = next;
      }
    }

    return {
      configured: executions.length > 0,
      amount,
      nextCalculationAt,
    };
  }

  async resolveAutoDecision(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    step: BusinessProcessStep;
    task: BusinessProcessTask;
    now: Date;
  }): Promise<BusinessProcessAutoDecisionResolution | null> {
    const executions = await this.ruleLifecycle.executeTask<BusinessProcessTaskDeadlineAutoExecuteRuleResult>({
      ...args,
      purpose: 'TASK_DEADLINE_AUTO_EXECUTE',
      user: null,
      data: this.deadlineData(args.task, args.now),
    });
    let decision: BusinessProcessAutoDecisionResolution | null = null;

    for (const execution of executions) {
      const result = execution.result;
      if (!result || typeof result !== 'object' || Array.isArray(result) || !('decision' in result)) {
        throw new Error(
          `TASK_DEADLINE_AUTO_EXECUTE rule ${execution.rule.code || execution.rule.id} `
          + 'must return { decision: { key, comment? } | null }',
        );
      }
      if (result.decision == null) {
        decision = null;
        continue;
      }
      if (typeof result.decision !== 'object' || Array.isArray(result.decision)
        || typeof result.decision.key !== 'string' || !result.decision.key.trim()) {
        throw new Error(
          `TASK_DEADLINE_AUTO_EXECUTE rule ${execution.rule.code || execution.rule.id} returned invalid decision`,
        );
      }
      const key = result.decision.key.trim();
      if (!args.step.decisions.some(item => item.key === key)) {
        throw new Error(
          `TASK_DEADLINE_AUTO_EXECUTE rule ${execution.rule.code || execution.rule.id} `
          + `returned decision ${key}, which is not declared in step ${args.step.key}`,
        );
      }
      decision = {
        key,
        comment: result.decision.comment || null,
      };
    }
    return decision;
  }

  private deadlineData(task: BusinessProcessTask, now: Date): Record<string, unknown> {
    const deadlineAt = task.deadline.at || null;
    return {
      now,
      deadline: {
        at: deadlineAt,
        reachedAt: task.deadline.reachedAt || null,
        overdueMilliseconds: deadlineAt ? Math.max(0, now.getTime() - deadlineAt.getTime()) : 0,
      },
      penalty: task.penalty,
    };
  }

  private date(value: Date | string, rule: string): Date {
    const date = value instanceof Date ? new Date(value.getTime()) : new Date(value);
    if (Number.isNaN(date.getTime())) {
      throw new Error(`TASK_DEADLINE_PENALTY rule ${rule} returned invalid nextCalculationAt`);
    }
    return date;
  }
}
