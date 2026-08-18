export type BusinessProcessTemplateStatus = 'DRAFT' | 'ACTIVE' | 'ARCHIVED';

export type BusinessProcessStartMode =
  | 'MANUAL'
  | 'ON_SAVE'
  | 'ON_POST'
  | 'ON_STATUS_CHANGE';

export type BusinessProcessInstanceStatus =
  | 'RUNNING'
  | 'COMPLETED'
  | 'REJECTED'
  | 'CANCELLED'
  | 'FAILED';

export type BusinessProcessTaskStatus =
  | 'CREATED'
  | 'WAITING'
  | 'ACTIVE'
  | 'COMPLETED'
  | 'APPROVED'
  | 'REJECTED'
  | 'REDIRECTED'
  | 'AUTO_COMPLETED'
  | 'TIMEOUT'
  | 'OVERDUE'
  | 'CANCELLED';

export type BusinessProcessStepType =
  | 'USER_TASK'
  | 'SYSTEM_TASK'
  | 'TIMER'
  | 'AUTO';

export type BusinessProcessEventType =
  | 'PROCESS_STARTED'
  | 'PROCESS_COMPLETED'
  | 'PROCESS_REJECTED'
  | 'PROCESS_CANCELLED'
  | 'PROCESS_FAILED'
  | 'TASK_CREATED'
  | 'TASK_ACTIVATED'
  | 'TASK_COMPLETED'
  | 'TASK_APPROVED'
  | 'TASK_REJECTED'
  | 'TASK_REDIRECTED'
  | 'TASK_DELEGATED'
  | 'TASK_CANCELLED'
  | 'TASK_AUTO_COMPLETED'
  | 'TASK_OVERDUE'
  | 'TASK_TIMEOUT'
  | 'PENALTY_APPLIED'
  | 'OBJECT_STATUS_CHANGED';

export type BusinessProcessTaskDecision = string;

export type CatalogUserId = string;

export interface BusinessProcessTaskAssignee {
  user: CatalogUserId;
  delegatedFrom?: CatalogUserId | null;
  redirectedFrom?: CatalogUserId | null;
}

export interface BusinessProcessTaskActivation {
  at?: Date | null;
}

export interface BusinessProcessTaskDeadline {
  at?: Date | null;
  reachedAt?: Date | null;
}

export interface BusinessProcessTaskDecisionInfo {
  key?: string | null;
  user?: CatalogUserId | null;
  comment?: string | null;
  source?: 'USER' | 'SYSTEM' | null;
  at?: Date | null;
}

export interface BusinessProcessTaskPenalty {
  amount?: number | null;
  startedAt?: Date | null;
  lastCalculatedAt?: Date | null;
  nextCalculationAt?: Date | null;
}

export interface BusinessProcessTemplate {
  id: string;
  code: string;
  description?: string;
  active: boolean;
  version: number;
  status: BusinessProcessTemplateStatus;
  objectTypes: string[];
  startMode: BusinessProcessStartMode;
  rules: import('./business-process-rule.types').BusinessProcessRuleBinding[];
  startCondition?: unknown;
  steps: BusinessProcessStep[];
  transitions: BusinessProcessTransition[];
  parameters?: Record<string, unknown>;
  /** Optional visual representation. It is not the execution source of truth. */
  bpmnXml?: string;
  /** Optional mapping between backend route elements and diagram elements. */
  visualMapping?: BusinessProcessVisualMapping;
  createdAt?: Date;
  updatedAt?: Date;
  createdBy?: CatalogUserId | null;
  activatedAt?: Date | null;
  archivedAt?: Date | null;
}

export interface BusinessProcessVisualMapping {
  schemaVersion?: 1 | 2;
  notation?: 'BPMN' | 'CUSTOM_GRAPH';
  routeHash?: string;
  startEventId?: string;
  nodeMap?: Record<string, string>;
  edgeMap?: Record<string, string>;
  endNodeMap?: Record<string, string>;
}

export interface BusinessProcessStep {
  key: string;
  title: string;
  type: BusinessProcessStepType;
  rules: import('./business-process-rule.types').BusinessProcessRuleBinding[];
  decisions: BusinessProcessDecision[];
  completionPolicy: 'ANY' | 'ALL';
  allowRedirect?: boolean;
  allowDelegate?: boolean;
  rejectPolicy?: string;
}

export interface BusinessProcessTransition {
  key: string;
  from: string;
  on: string;
  to: string;
  condition?: unknown;
}

export interface BusinessProcessInstance {
  id: string;
  templateId: string;
  templateCode: string;
  templateVersion: number;
  templateHash: string;
  objectType: string;
  objectId: string;
  status: BusinessProcessInstanceStatus;
  currentStepKey?: string;
  startedAt: Date;
  completedAt?: Date | null;
  authorUser?: CatalogUserId | null;
  company?: string | null;
  context?: Record<string, unknown>;
  idempotencyKey?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface BusinessProcessTask {
  id: string;
  instanceId: string;
  objectType: string;
  objectId: string;
  stepKey: string;
  title: string;
  status: BusinessProcessTaskStatus;
  assignee: BusinessProcessTaskAssignee;
  activation: BusinessProcessTaskActivation;
  deadline: BusinessProcessTaskDeadline;
  decision: BusinessProcessTaskDecisionInfo;
  penalty: BusinessProcessTaskPenalty;
  createdAt?: Date;
}

export interface BusinessProcessEvent {
  id: string;
  instanceId: string;
  taskId?: string | null;
  eventType: BusinessProcessEventType;
  user?: CatalogUserId | null;
  date: Date;
  payload?: Record<string, unknown> | null;
  eventKey?: string | null;
}

export interface BusinessProcessDelegation {
  id: string;
  userFrom: CatalogUserId;
  userTo: CatalogUserId;
  processTemplate?: string | null;
  company?: string | null;
  dateFrom: Date;
  dateTo?: Date | null;
  active: boolean;
}

export interface BusinessProcessStartInput {
  templateCode: string;
  objectType: string;
  objectId: string;
  user?: CatalogUserId | null;
  company?: string | null;
  context?: Record<string, unknown>;
  idempotencyKey?: string | null;
}

export interface BusinessProcessStartResult {
  instance: BusinessProcessInstance;
  tasks: BusinessProcessTask[];
  alreadyRunning?: boolean;
  objectStatusChanges?: Array<{
    objectType: string;
    objectId: string;
    fromStatus?: string | null;
    toStatus?: string | null;
  }>;
}

export interface ResolvedAssignee {
  userId: CatalogUserId;
  delegatedFromUser?: CatalogUserId | null;
}

export interface BusinessProcessTaskActionInput {
  user: CatalogUserId;
  comment?: string | null;
}

export interface BusinessProcessTaskDecisionInput {
  user: CatalogUserId;
  decision: {
    key: BusinessProcessTaskDecision;
    comment?: string | null;
  };
}

export interface BusinessProcessTaskRedirectInput {
  user: CatalogUserId;
  targetUser: CatalogUserId;
  comment?: string | null;
}

export interface BusinessProcessDecision {
  key: string;
  title: string;
  commentRequired?: boolean;
}

export interface BusinessProcessTaskActionResult {
  task: BusinessProcessTask;
  instance: BusinessProcessInstance;
  createdTasks: BusinessProcessTask[];
  completed: boolean;
  objectStatusChanges?: Array<{
    objectType: string;
    objectId: string;
    fromStatus?: string | null;
    toStatus?: string | null;
  }>;
}

export interface BusinessProcessSchedulerTickResult {
  run: {
    id: string;
    status: 'COMPLETED' | 'COMPLETED_WITH_ERRORS' | 'SKIPPED_LOCKED';
    startedAt: Date;
    completedAt: Date;
  };
  activatedTasks: number;
  overdueTasks: number;
  autoCompletedTasks: number;
  penaltyCandidates: number;
  penaltiesApplied: number;
  skipped: number;
  errors: Array<{
    taskId?: string;
    message: string;
  }>;
}

export interface BusinessProcessSchedulerStatus {
  lock: {
    resource: string;
    available: boolean;
  };
  databaseTime: Date;
}
