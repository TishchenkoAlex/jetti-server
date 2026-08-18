import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

abstract class BusinessProcessEntity extends DocumentBase {
  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  id = '';

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  type = '';

  @Props({ type: 'datetime', hidden: true, hiddenInList: true, readOnly: true })
  date = new Date();

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  code = '';

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  description = '';

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  company = null;

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  user = null;

  @Props({ type: 'boolean', hidden: true, hiddenInList: true, readOnly: true })
  posted = false;

  @Props({ type: 'boolean', hidden: true, hiddenInList: true, readOnly: true })
  deleted = false;

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  parent = null;

  @Props({ type: 'boolean', hidden: true, hiddenInList: true, readOnly: true })
  isfolder = false;

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  info = '';

  @Props({ type: 'datetime', hidden: true, hiddenInList: true, readOnly: true })
  timestamp: Date | null = null;

  @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
  workflow = null;
}

class BusinessProcessRuleBindingMetadata {
  @Props({
    type: 'Catalog.BusinessProcessRules',
    label: 'Rule',
    order: 1,
    required: true,
    storageType: 'elements',
    style: { width: '400px' },
  })
  rule: Ref = null;

  @Props({ type: 'number', label: 'Order', order: 2, required: true })
  order = 0;

  @Props({ type: 'json', label: 'Settings', order: 3 })
  settings: unknown = null;
}

class BusinessProcessDecisionMetadata {
  @Props({ type: 'string', label: 'Key', order: 1, required: true })
  key = '';

  @Props({ type: 'string', label: 'Title', order: 2, required: true })
  title = '';

  @Props({ type: 'boolean', label: 'Comment required', order: 3 })
  commentRequired = false;
}

class BusinessProcessStepRuleBindingMetadata extends BusinessProcessRuleBindingMetadata {
  @Props({ type: 'string', label: 'Step key', order: 0, required: true })
  stepKey = '';
}

class BusinessProcessStepDecisionMetadata extends BusinessProcessDecisionMetadata {
  @Props({ type: 'string', label: 'Step key', order: 0, required: true })
  stepKey = '';
}

class BusinessProcessStepMetadata {
  @Props({ type: 'string', label: 'Key', order: 1, readOnly: false, required: true })
  key = '';

  @Props({ type: 'string', label: 'Title', order: 2, readOnly: false, required: true })
  title = '';

  @Props({
    type: 'enum',
    label: 'Type',
    order: 3,
    value: ['USER_TASK', 'SYSTEM_TASK', 'TIMER', 'AUTO'],
    readOnly: false,
    required: true,
  })
  type = 'USER_TASK';

  @Props({
    type: 'enum',
    label: 'Completion policy',
    order: 4,
    value: ['ANY', 'ALL'],
    readOnly: false,
    required: true,
  })
  completionPolicy = 'ANY';

  @Props({ type: 'boolean', label: 'Allow redirect', order: 5, readOnly: false })
  allowRedirect = false;

  @Props({ type: 'boolean', label: 'Allow delegate', order: 6, readOnly: false })
  allowDelegate = false;

  @Props({
    type: 'enum',
    label: 'Reject policy',
    order: 7,
    value: ['REJECT_PROCESS', 'RETURN_TO_PREVIOUS_STEP'],
    readOnly: false,
  })
  rejectPolicy = 'REJECT_PROCESS';
}

class BusinessProcessTransitionMetadata {
  @Props({ type: 'string', label: 'Key', order: 1, readOnly: false, required: true })
  key = '';

  @Props({ type: 'string', label: 'From', order: 2, readOnly: false, required: true })
  from = '';

  @Props({ type: 'string', label: 'Event / decision', order: 3, readOnly: false, required: true })
  on = 'APPROVE';

  @Props({ type: 'string', label: 'To', order: 4, readOnly: false, required: true })
  to = '';

  @Props({ type: 'json', label: 'Condition', order: 5, readOnly: false })
  condition: unknown = null;
}

class BusinessProcessObjectTypeMetadata {
  @Props({
    type: 'Types.Object',
    label: 'Object type',
    required: true,
    style: { width: '100%' },
  })
  objectType = '';
}

export namespace BusinessProcess {
  @JDocument({
    type: 'BusinessProcess.Instance',
    description: 'Processes',
    icon: 'fas fa-project-diagram',
    menu: 'Processes',
  })
  export class Instance extends BusinessProcessEntity {
    @Props({
      type: 'BusinessProcess.Template',
      label: 'Template',
      order: 1,
      required: true,
      readOnly: false,
      storageType: 'elements',
      owner: [
        { dependsOn: 'templateActive', filterBy: 'active', isOwnerFixed: true },
        { dependsOn: 'templateStatus', filterBy: 'status', isOwnerFixed: true },
        { dependsOn: 'templateStartMode', filterBy: 'startMode', isOwnerFixed: true },
      ],
    })
    templateId: Ref = null;

    @Props({ type: 'boolean', value: true, hidden: true, hiddenInList: true, readOnly: true })
    templateActive = true;

    @Props({ type: 'string', value: 'ACTIVE', hidden: true, hiddenInList: true, readOnly: true })
    templateStatus = 'ACTIVE';

    @Props({ type: 'string', value: 'MANUAL', hidden: true, hiddenInList: true, readOnly: true })
    templateStartMode = 'MANUAL';

    @Props({ type: 'string', hidden: true, hiddenInList: false, readOnly: true })
    templateCode = '';

    @Props({ type: 'number', label: 'Version', order: 2, readOnly: true })
    templateVersion = 0;

    @Props({ type: 'string', label: 'Object type', order: 3, required: true, readOnly: false })
    objectType = '';

    @Props({ type: 'string', label: 'Object', order: 4, required: true, readOnly: false })
    objectId = '';

    @Props({
      type: 'enum',
      label: 'Status',
      order: 5,
      value: ['RUNNING', 'COMPLETED', 'REJECTED', 'CANCELLED', 'FAILED'],
      readOnly: true,
    })
    status = 'RUNNING';

    @Props({ type: 'string', label: 'Current step', order: 6, readOnly: true })
    currentStepKey = '';

    @Props({ type: 'datetime', label: 'Started at', order: 7, readOnly: true })
    startedAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Completed at', order: 8, readOnly: true })
    completedAt: Date | null = null;

    @Props({ type: 'Catalog.User', label: 'Author', order: 9, readOnly: true })
    authorUser = null;

    @Props({ type: 'string', label: 'Company', order: 10, readOnly: true })
    company = null;

    @Props({ type: 'datetime', label: 'Created at', order: 11, readOnly: true })
    createdAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Updated at', order: 12, readOnly: true })
    updatedAt: Date | null = null;

    @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
    templateHash = '';

    @Props({ type: 'json', hidden: true, hiddenInList: true, readOnly: true })
    context: unknown = null;

    @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
    idempotencyKey = '';
  }

  @JDocument({
    type: 'BusinessProcess.Task',
    description: 'Tasks',
    icon: 'fas fa-tasks',
    menu: 'Tasks',
  })
  export class Task extends BusinessProcessEntity {
    @Props({ type: 'string', label: 'Task', order: 1, readOnly: true })
    title = '';

    @Props({
      type: 'enum',
      controlType: 'string',
      label: 'Status',
      order: 2,
      value: [
        'CREATED',
        'WAITING',
        'ACTIVE',
        'COMPLETED',
        'APPROVED',
        'REJECTED',
        'REDIRECTED',
        'AUTO_COMPLETED',
        'TIMEOUT',
        'OVERDUE',
        'CANCELLED',
      ],
      readOnly: true,
    })
    status = 'CREATED';

    @Props({ type: 'string', label: 'Object type', order: 3, readOnly: true })
    objectType = '';

    @Props({ type: 'string', label: 'Object', order: 4, readOnly: true })
    objectId = '';

    @Props({ type: 'string', label: 'Step', order: 5, readOnly: true })
    stepKey = '';

    @Props({ type: 'Catalog.User', label: 'Assignee', order: 6, readOnly: true, panel: 'Assignment' })
    assigneeUser = null;

    @Props({ type: 'datetime', label: 'Active from', order: 7, readOnly: true, panel: 'Activation' })
    activeFrom: Date | null = null;

    @Props({ type: 'datetime', label: 'Deadline', order: 8, readOnly: true, panel: 'Deadline' })
    deadlineAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Deadline reached at', order: 9, readOnly: true, panel: 'Deadline' })
    deadlineReachedAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Completed at', order: 10, readOnly: true, panel: 'Decision' })
    completedAt: Date | null = null;

    @Props({ type: 'string', label: 'Decision', order: 11, readOnly: true, panel: 'Decision' })
    decisionKey = '';

    @Props({ type: 'Catalog.User', label: 'Decision user', order: 12, readOnly: true, panel: 'Decision' })
    decisionUser = null;

    @Props({ type: 'string', label: 'Decision comment', order: 13, readOnly: true, panel: 'Decision' })
    decisionComment = '';

    @Props({
      type: 'enum',
      controlType: 'string',
      label: 'Decision source',
      order: 14,
      value: ['USER', 'SYSTEM'],
      readOnly: true,
      panel: 'Decision',
    })
    decisionSource = '';

    @Props({ type: 'datetime', label: 'Penalty started at', order: 15, readOnly: true, panel: 'Penalty' })
    penaltyStartedAt: Date | null = null;

    @Props({ type: 'number', label: 'Penalty amount', order: 16, readOnly: true, panel: 'Penalty' })
    penaltyAmount: number | null = null;

    @Props({ type: 'datetime', label: 'Penalty calculated at', order: 17, readOnly: true, panel: 'Penalty' })
    penaltyLastCalculatedAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Next penalty calculation', order: 18, readOnly: true, panel: 'Penalty' })
    nextPenaltyCalculationAt: Date | null = null;

    @Props({ type: 'string', label: 'Company', order: 19, readOnly: true })
    company = null;

    @Props({ type: 'datetime', label: 'Created at', order: 20, readOnly: true })
    createdAt: Date | null = null;

    @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
    instanceId = '';

    @Props({ type: 'Catalog.User', hidden: true, hiddenInList: true, readOnly: true })
    delegatedFromUser = null;

    @Props({ type: 'Catalog.User', hidden: true, hiddenInList: true, readOnly: true })
    redirectedFromUser = null;

  }

  @JDocument({
    type: 'BusinessProcess.Template',
    description: 'Process templates',
    icon: 'fas fa-file-alt',
    menu: 'Process templates',
  })
  export class Template extends BusinessProcessEntity {
    @Props({ type: 'string', label: 'Code', order: 1, readOnly: false, required: true })
    code = '';

    @Props({ type: 'string', label: 'Description', order: 2, readOnly: false, required: true })
    description = '';

    @Props({ type: 'boolean', label: 'Active', order: 3, readOnly: true })
    active = false;

    @Props({ type: 'number', label: 'Version', order: 4, readOnly: true })
    version = 1;

    @Props({
      type: 'enum',
      controlType: 'string',
      label: 'Status',
      order: 5,
      value: ['DRAFT', 'ACTIVE', 'ARCHIVED'],
      readOnly: true,
    })
    status = 'DRAFT';

    @Props({
      type: 'table',
      label: 'Object types',
      order: 6,
      panel: 'Applicability',
      required: true,
    })
    objectTypes: BusinessProcessObjectTypeMetadata[] = [new BusinessProcessObjectTypeMetadata()];

    @Props({
      type: 'enum',
      label: 'Start mode',
      order: 7,
      value: ['MANUAL', 'ON_SAVE', 'ON_POST', 'ON_STATUS_CHANGE'],
      readOnly: false,
      required: true,
    })
    startMode = 'MANUAL';

    @Props({ type: 'Catalog.User', label: 'Created by', order: 8, readOnly: true })
    createdBy = null;

    @Props({ type: 'datetime', label: 'Activated at', order: 9, readOnly: true })
    activatedAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Archived at', order: 10, readOnly: true })
    archivedAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Created at', order: 11, readOnly: true })
    createdAt: Date | null = null;

    @Props({ type: 'datetime', label: 'Updated at', order: 12, readOnly: true })
    updatedAt: Date | null = null;

    @Props({ type: 'json', label: 'Start condition', order: 1, panel: 'Process map', readOnly: false })
    startCondition: unknown = null;

    @Props({ type: 'table', label: 'Process rules', order: 2, panel: 'Process map' })
    rules: BusinessProcessRuleBindingMetadata[] = [new BusinessProcessRuleBindingMetadata()];

    @Props({ type: 'table', label: 'Steps', order: 3, panel: 'Process map', required: true })
    steps: BusinessProcessStepMetadata[] = [new BusinessProcessStepMetadata()];

    @Props({ type: 'table', label: 'Step rules', order: 4, panel: 'Process map' })
    stepRules: BusinessProcessStepRuleBindingMetadata[] = [new BusinessProcessStepRuleBindingMetadata()];

    @Props({ type: 'table', label: 'Step decisions', order: 5, panel: 'Process map' })
    stepDecisions: BusinessProcessStepDecisionMetadata[] = [new BusinessProcessStepDecisionMetadata()];

    @Props({ type: 'table', label: 'Transitions', order: 6, panel: 'Process map' })
    transitions: BusinessProcessTransitionMetadata[] = [new BusinessProcessTransitionMetadata()];

    @Props({ type: 'json', label: 'Parameters', order: 7, panel: 'Process map', readOnly: false })
    parameters: unknown = null;

    @Props({ type: 'string', hidden: true, hiddenInList: true, readOnly: true })
    bpmnXml = '';

    @Props({ type: 'json', hidden: true, hiddenInList: true, readOnly: true })
    visualMapping: unknown = null;

  }
}
