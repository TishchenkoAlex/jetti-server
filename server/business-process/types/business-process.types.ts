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

export type BusinessProcessTaskDecision =
  | 'APPROVE'
  | 'REJECT';

export interface BusinessProcessTemplate {
  id: string;
  code: string;
  description?: string;
  active: boolean;
  version: number;
  status: BusinessProcessTemplateStatus;
  objectTypes: string[];
  startMode: BusinessProcessStartMode;
  startCondition?: unknown;
  steps: BusinessProcessStep[];
  transitions: BusinessProcessTransition[];
  parameters?: Record<string, unknown>;
  createdAt?: Date;
  updatedAt?: Date;
  createdBy?: string | null;
  activatedAt?: Date | null;
  archivedAt?: Date | null;
}

export interface BusinessProcessStep {
  key: string;
  title: string;
  type: BusinessProcessStepType;
  assignmentRule?: unknown;
  dueRule?: unknown;
  penaltyRule?: unknown;
  waitUntilRule?: unknown;
  autoCompleteCondition?: unknown;
  allowRedirect?: boolean;
  allowDelegate?: boolean;
  rejectPolicy?: string;
}

export interface BusinessProcessTransition {
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
  author?: string | null;
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
  assigneeUser?: string | null;
  assigneeRole?: string | null;
  activeFrom?: Date | null;
  dueAt?: Date | null;
  completedAt?: Date | null;
  decisionUser?: string | null;
  decisionComment?: string | null;
  delegatedFromUser?: string | null;
  redirectedFromUser?: string | null;
  penaltyRuleSnapshot?: unknown;
  penaltyAmount?: number | null;
  overdueAt?: Date | null;
  penaltyAppliedAt?: Date | null;
  createdAt?: Date;
}

export interface BusinessProcessEvent {
  id: string;
  instanceId: string;
  taskId?: string | null;
  eventType: BusinessProcessEventType;
  user?: string | null;
  date: Date;
  payload?: Record<string, unknown> | null;
  eventKey?: string | null;
}

export interface BusinessProcessDelegation {
  id: string;
  userFrom: string;
  userTo: string;
  role?: string | null;
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
  user?: string | null;
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
  userId?: string | null;
  role?: string | null;
  delegatedFromUser?: string | null;
}

export interface BusinessProcessTaskActionInput {
  user: string;
  comment?: string | null;
}

export interface BusinessProcessTaskRedirectInput {
  user: string;
  targetUser?: string | null;
  targetRole?: string | null;
  comment?: string | null;
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
  activatedTasks: number;
  overdueTasks: number;
  penaltyCandidates: number;
  penaltiesApplied: number;
  skipped: number;
  errors: Array<{
    taskId?: string;
    message: string;
  }>;
}
