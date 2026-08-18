import { MSSQL } from '../../mssql';
import {
  BusinessProcessDecision,
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import { BusinessProcessTaskAvailableDecisionsRuleResult } from '../types/business-process-rule.types';
import { BusinessProcessRuleLifecycle } from './rule-lifecycle.service';

export class BusinessProcessTaskDecisionResolver {
  constructor(private readonly ruleLifecycle = new BusinessProcessRuleLifecycle()) {}

  async resolve(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    step: BusinessProcessStep;
    task: BusinessProcessTask;
    user: string;
  }): Promise<BusinessProcessDecision[]> {
    const decisionsByKey = new Map(args.step.decisions.map(decision => [decision.key, decision]));
    let available = [...args.step.decisions];
    const executions = await this.ruleLifecycle.executeTask<BusinessProcessTaskAvailableDecisionsRuleResult>({
      db: args.db,
      template: args.template,
      instance: args.instance,
      step: args.step,
      task: args.task,
      purpose: 'TASK_AVAILABLE_DECISIONS',
      user: args.user,
      data: { mode: 'RESOLVE_AVAILABLE_DECISIONS' },
    });

    for (const execution of executions) {
      const result = execution.result;
      if (!result || typeof result !== 'object' || Array.isArray(result) || !Array.isArray(result.decisions)) {
        throw new Error(
          `TASK_AVAILABLE_DECISIONS rule ${execution.rule.code || execution.rule.id} `
          + 'must return { decisions: string[] }',
        );
      }
      const allowedKeys = new Set<string>();
      result.decisions.forEach((key, index) => {
        if (typeof key !== 'string' || !key.trim()) {
          throw new Error(
            `TASK_AVAILABLE_DECISIONS rule ${execution.rule.code || execution.rule.id} `
            + `returned invalid decision key at index ${index}`,
          );
        }
        const normalizedKey = key.trim();
        if (!decisionsByKey.has(normalizedKey)) {
          throw new Error(
            `TASK_AVAILABLE_DECISIONS rule ${execution.rule.code || execution.rule.id} `
            + `returned decision ${normalizedKey}, which is not declared in step ${args.step.key}`,
          );
        }
        allowedKeys.add(normalizedKey);
      });
      available = available.filter(decision => allowedKeys.has(decision.key));
    }

    return available;
  }

  requireAvailable(args: {
    decisions: BusinessProcessDecision[];
    key: string;
    comment?: string | null;
    taskId: string;
    user: string;
  }): BusinessProcessDecision {
    const decision = args.decisions.find(item => item.key === args.key);
    if (!decision) {
      throw new Error(`Decision ${args.key} is not available for task ${args.taskId} and user ${args.user}`);
    }
    if (decision.commentRequired && !String(args.comment || '').trim()) {
      throw new Error(`Decision ${args.key} requires a comment`);
    }
    return decision;
  }
}
