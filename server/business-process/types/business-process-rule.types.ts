import type { MSSQL } from '../../mssql';
import type {
  BusinessProcessInstance,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
  CatalogUserId,
} from './business-process.types';

export const BUSINESS_PROCESS_RULE_PURPOSES = [
  'TASK_ASSIGNMENT',
  'TASK_AVAILABLE_DECISIONS',
  'TASK_CREATED',
  'TASK_ACTIVATION_DATE',
  'TASK_DEADLINE_DATE',
  'TASK_DEADLINE_PENALTY',
  'TASK_DEADLINE_AUTO_EXECUTE',
  'TASK_BEFORE_EXECUTE',
  'TASK_AFTER_EXECUTE',
  'PROCESS_BEFORE_SAVE',
  'PROCESS_STARTED',
  'PROCESS_COMPLETED',
] as const;

export type BusinessProcessRulePurpose = typeof BUSINESS_PROCESS_RULE_PURPOSES[number];

export const BUSINESS_PROCESS_PROCESS_RULE_PURPOSES: BusinessProcessRulePurpose[] = [
  'PROCESS_BEFORE_SAVE',
  'PROCESS_STARTED',
  'PROCESS_COMPLETED',
];

export const BUSINESS_PROCESS_TASK_RULE_PURPOSES: BusinessProcessRulePurpose[] = [
  'TASK_ASSIGNMENT',
  'TASK_AVAILABLE_DECISIONS',
  'TASK_CREATED',
  'TASK_ACTIVATION_DATE',
  'TASK_DEADLINE_DATE',
  'TASK_DEADLINE_PENALTY',
  'TASK_DEADLINE_AUTO_EXECUTE',
  'TASK_BEFORE_EXECUTE',
  'TASK_AFTER_EXECUTE',
];

export interface BusinessProcessRuleBinding {
  rule: string;
  order?: number;
  settings?: Record<string, unknown>;
}

export interface BusinessProcessRuleBaseContext {
  process: {
    instance: BusinessProcessInstance;
    template: BusinessProcessTemplate;
    object: {
      type: string;
      id: string;
    };
    context: Record<string, unknown>;
  };
  step?: BusinessProcessStep | null;
  task?: BusinessProcessTask | null;
  event: {
    purpose: BusinessProcessRulePurpose;
    user?: CatalogUserId | null;
    data?: Record<string, unknown>;
  };
}

export interface BusinessProcessRuleContext extends BusinessProcessRuleBaseContext {
  transaction: MSSQL;
  rule: {
    id: string;
    code: string;
    description: string;
    purpose: BusinessProcessRulePurpose;
    settings: Record<string, unknown>;
  };
}

export interface BusinessProcessTaskAssignmentRuleResult {
  assignees: Array<{
    user: CatalogUserId;
  }>;
}

export interface BusinessProcessTaskAvailableDecisionsRuleResult {
  decisions: string[];
}

export type BusinessProcessRuleDateValue = Date | string | null;

export interface BusinessProcessTaskActivationDateRuleResult {
  activation: {
    at: BusinessProcessRuleDateValue;
  };
}

export interface BusinessProcessTaskDeadlineDateRuleResult {
  deadline: {
    at: BusinessProcessRuleDateValue;
  };
}

export interface BusinessProcessTaskDeadlinePenaltyRuleResult {
  penalty: {
    amount: number;
    nextCalculationAt?: BusinessProcessRuleDateValue;
  } | null;
}

export interface BusinessProcessTaskDeadlineAutoExecuteRuleResult {
  decision: {
    key: string;
    comment?: string | null;
  } | null;
}

export interface BusinessProcessRuleExecution<TResult = unknown> {
  rule: BusinessProcessRuleContext['rule'];
  result: TResult;
}

export function isBusinessProcessRulePurpose(value: unknown): value is BusinessProcessRulePurpose {
  return typeof value === 'string'
    && (BUSINESS_PROCESS_RULE_PURPOSES as readonly string[]).includes(value);
}
