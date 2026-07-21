IF OBJECT_ID(N'dbo.BusinessProcessTemplate', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BusinessProcessTemplate (
    id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BusinessProcessTemplate PRIMARY KEY,
    code NVARCHAR(128) NOT NULL,
    description NVARCHAR(512) NULL,
    active BIT NOT NULL CONSTRAINT DF_BusinessProcessTemplate_active DEFAULT (0),
    version INT NOT NULL,
    status NVARCHAR(32) NOT NULL,
    objectTypes NVARCHAR(MAX) NOT NULL,
    startMode NVARCHAR(32) NOT NULL,
    startCondition NVARCHAR(MAX) NULL,
    steps NVARCHAR(MAX) NOT NULL,
    transitions NVARCHAR(MAX) NOT NULL,
    parameters NVARCHAR(MAX) NULL,
    bpmnXml NVARCHAR(MAX) NULL,
    visualMapping NVARCHAR(MAX) NULL,
    createdBy NVARCHAR(256) NULL,
    activatedAt DATETIME2(3) NULL,
    archivedAt DATETIME2(3) NULL,
    createdAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessTemplate_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessTemplate_updatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_BusinessProcessTemplate_Status CHECK (status IN (N'DRAFT', N'ACTIVE', N'ARCHIVED')),
    CONSTRAINT CK_BusinessProcessTemplate_StartMode CHECK (startMode IN (N'MANUAL', N'ON_SAVE', N'ON_POST', N'ON_STATUS_CHANGE')),
    CONSTRAINT CK_BusinessProcessTemplate_ObjectTypesJson CHECK (ISJSON(objectTypes) = 1),
    CONSTRAINT CK_BusinessProcessTemplate_StepsJson CHECK (ISJSON(steps) = 1),
    CONSTRAINT CK_BusinessProcessTemplate_TransitionsJson CHECK (ISJSON(transitions) = 1),
    CONSTRAINT CK_BusinessProcessTemplate_StartConditionJson CHECK (startCondition IS NULL OR ISJSON(startCondition) = 1),
    CONSTRAINT CK_BusinessProcessTemplate_ParametersJson CHECK (parameters IS NULL OR ISJSON(parameters) = 1),
    CONSTRAINT CK_BusinessProcessTemplate_VisualMappingJson CHECK (visualMapping IS NULL OR ISJSON(visualMapping) = 1)
  );
END;
GO

IF OBJECT_ID(N'dbo.BusinessProcessInstance', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BusinessProcessInstance (
    id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BusinessProcessInstance PRIMARY KEY,
    templateId UNIQUEIDENTIFIER NOT NULL,
    templateCode NVARCHAR(128) NOT NULL,
    templateVersion INT NOT NULL,
    templateHash NVARCHAR(128) NOT NULL,
    objectType NVARCHAR(128) NOT NULL,
    objectId UNIQUEIDENTIFIER NOT NULL,
    status NVARCHAR(32) NOT NULL,
    currentStepKey NVARCHAR(128) NULL,
    startedAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessInstance_startedAt DEFAULT (SYSUTCDATETIME()),
    completedAt DATETIME2(3) NULL,
    author NVARCHAR(256) NULL,
    company UNIQUEIDENTIFIER NULL,
    context NVARCHAR(MAX) NULL,
    idempotencyKey NVARCHAR(256) NULL,
    createdAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessInstance_createdAt DEFAULT (SYSUTCDATETIME()),
    updatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessInstance_updatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_BusinessProcessInstance_Status CHECK (status IN (N'RUNNING', N'COMPLETED', N'REJECTED', N'CANCELLED', N'FAILED')),
    CONSTRAINT CK_BusinessProcessInstance_ContextJson CHECK (context IS NULL OR ISJSON(context) = 1),
    CONSTRAINT FK_BusinessProcessInstance_Template FOREIGN KEY (templateId)
      REFERENCES dbo.BusinessProcessTemplate(id)
  );
END;
GO

IF OBJECT_ID(N'dbo.BusinessProcessTask', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BusinessProcessTask (
    id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BusinessProcessTask PRIMARY KEY,
    instanceId UNIQUEIDENTIFIER NOT NULL,
    objectType NVARCHAR(128) NOT NULL,
    objectId UNIQUEIDENTIFIER NOT NULL,
    stepKey NVARCHAR(128) NOT NULL,
    title NVARCHAR(256) NOT NULL,
    status NVARCHAR(32) NOT NULL,
    assigneeUser NVARCHAR(256) NULL,
    assigneeRole NVARCHAR(128) NULL,
    activeFrom DATETIME2(3) NULL,
    dueAt DATETIME2(3) NULL,
    completedAt DATETIME2(3) NULL,
    decisionUser NVARCHAR(256) NULL,
    decisionComment NVARCHAR(MAX) NULL,
    delegatedFromUser NVARCHAR(256) NULL,
    redirectedFromUser NVARCHAR(256) NULL,
    penaltyRuleSnapshot NVARCHAR(MAX) NULL,
    penaltyAmount DECIMAL(19, 4) NULL,
    overdueAt DATETIME2(3) NULL,
    penaltyAppliedAt DATETIME2(3) NULL,
    createdAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessTask_createdAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_BusinessProcessTask_Status CHECK (status IN (
      N'CREATED',
      N'WAITING',
      N'ACTIVE',
      N'APPROVED',
      N'REJECTED',
      N'REDIRECTED',
      N'AUTO_COMPLETED',
      N'TIMEOUT',
      N'OVERDUE',
      N'CANCELLED'
    )),
    CONSTRAINT CK_BusinessProcessTask_PenaltyRuleSnapshotJson CHECK (penaltyRuleSnapshot IS NULL OR ISJSON(penaltyRuleSnapshot) = 1),
    CONSTRAINT FK_BusinessProcessTask_Instance FOREIGN KEY (instanceId)
      REFERENCES dbo.BusinessProcessInstance(id)
  );
END;
GO

IF OBJECT_ID(N'dbo.BusinessProcessEvent', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BusinessProcessEvent (
    id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BusinessProcessEvent PRIMARY KEY,
    instanceId UNIQUEIDENTIFIER NOT NULL,
    taskId UNIQUEIDENTIFIER NULL,
    eventType NVARCHAR(64) NOT NULL,
    eventUser NVARCHAR(256) NULL,
    eventAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessEvent_eventAt DEFAULT (SYSUTCDATETIME()),
    payload NVARCHAR(MAX) NULL,
    eventKey NVARCHAR(256) NULL,
    CONSTRAINT CK_BusinessProcessEvent_PayloadJson CHECK (payload IS NULL OR ISJSON(payload) = 1),
    CONSTRAINT FK_BusinessProcessEvent_Instance FOREIGN KEY (instanceId)
      REFERENCES dbo.BusinessProcessInstance(id),
    CONSTRAINT FK_BusinessProcessEvent_Task FOREIGN KEY (taskId)
      REFERENCES dbo.BusinessProcessTask(id)
  );
END;
GO

IF OBJECT_ID(N'dbo.BusinessProcessDelegation', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.BusinessProcessDelegation (
    id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BusinessProcessDelegation PRIMARY KEY,
    userFrom NVARCHAR(256) NOT NULL,
    userTo NVARCHAR(256) NOT NULL,
    role NVARCHAR(128) NULL,
    processTemplate NVARCHAR(128) NULL,
    company UNIQUEIDENTIFIER NULL,
    dateFrom DATETIME2(3) NOT NULL,
    dateTo DATETIME2(3) NULL,
    active BIT NOT NULL CONSTRAINT DF_BusinessProcessDelegation_active DEFAULT (1),
    comment NVARCHAR(512) NULL,
    createdAt DATETIME2(3) NOT NULL CONSTRAINT DF_BusinessProcessDelegation_createdAt DEFAULT (SYSUTCDATETIME())
  );
END;
GO
