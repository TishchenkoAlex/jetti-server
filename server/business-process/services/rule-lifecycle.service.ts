import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import {
  BUSINESS_PROCESS_PROCESS_RULE_PURPOSES,
  BUSINESS_PROCESS_TASK_RULE_PURPOSES,
  BusinessProcessRuleBaseContext,
  BusinessProcessRuleExecution,
  BusinessProcessRulePurpose,
} from '../types/business-process-rule.types';
import { BusinessProcessRuleExecutor } from './rule-executor';

export class BusinessProcessRuleLifecycle {
  constructor(private readonly executor = new BusinessProcessRuleExecutor()) {}

  executeProcess<TResult = unknown>(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    purpose: BusinessProcessRulePurpose;
    step?: BusinessProcessStep | null;
    task?: BusinessProcessTask | null;
    user?: string | null;
    data?: Record<string, unknown>;
  }): Promise<Array<BusinessProcessRuleExecution<TResult>>> {
    if (!BUSINESS_PROCESS_PROCESS_RULE_PURPOSES.includes(args.purpose)) {
      throw new Error(`Rule purpose ${args.purpose} is not a process lifecycle purpose`);
    }
    return this.executor.execute<TResult>({
      db: args.db,
      bindings: args.template.rules,
      purpose: args.purpose,
      allowedPurposes: BUSINESS_PROCESS_PROCESS_RULE_PURPOSES,
      context: this.context(args),
    });
  }

  executeTask<TResult = unknown>(args: {
    db: MSSQL;
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    step: BusinessProcessStep;
    purpose: BusinessProcessRulePurpose;
    task?: BusinessProcessTask | null;
    user?: string | null;
    data?: Record<string, unknown>;
  }): Promise<Array<BusinessProcessRuleExecution<TResult>>> {
    if (!BUSINESS_PROCESS_TASK_RULE_PURPOSES.includes(args.purpose)) {
      throw new Error(`Rule purpose ${args.purpose} is not a task lifecycle purpose`);
    }
    return this.executor.execute<TResult>({
      db: args.db,
      bindings: args.step.rules,
      purpose: args.purpose,
      allowedPurposes: BUSINESS_PROCESS_TASK_RULE_PURPOSES,
      context: this.context(args),
    });
  }

  private context(args: {
    template: BusinessProcessTemplate;
    instance: BusinessProcessInstance;
    purpose: BusinessProcessRulePurpose;
    step?: BusinessProcessStep | null;
    task?: BusinessProcessTask | null;
    user?: string | null;
    data?: Record<string, unknown>;
  }): BusinessProcessRuleBaseContext {
    const processContext = args.instance.context || {};
    args.instance.context = processContext;
    return {
      process: {
        instance: args.instance,
        template: args.template,
        object: {
          type: args.instance.objectType,
          id: args.instance.objectId,
        },
        context: processContext,
      },
      step: args.step || null,
      task: args.task || null,
      event: {
        purpose: args.purpose,
        user: args.user || null,
        data: args.data || {},
      },
    };
  }
}
