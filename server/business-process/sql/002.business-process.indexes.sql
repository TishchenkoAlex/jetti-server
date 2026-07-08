IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_BusinessProcessTemplate_Code_Version' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTemplate'))
  CREATE UNIQUE INDEX UX_BusinessProcessTemplate_Code_Version
    ON dbo.BusinessProcessTemplate (code, version);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_BusinessProcessTemplate_Code_Active' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTemplate'))
  CREATE UNIQUE INDEX UX_BusinessProcessTemplate_Code_Active
    ON dbo.BusinessProcessTemplate (code)
    WHERE status = N'ACTIVE';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTemplate_Status_Active_Code' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTemplate'))
  CREATE INDEX IX_BusinessProcessTemplate_Status_Active_Code
    ON dbo.BusinessProcessTemplate (status, active, code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessInstance_Object_Status' AND object_id = OBJECT_ID(N'dbo.BusinessProcessInstance'))
  CREATE INDEX IX_BusinessProcessInstance_Object_Status
    ON dbo.BusinessProcessInstance (objectType, objectId, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_BusinessProcessInstance_Object_Template_Running' AND object_id = OBJECT_ID(N'dbo.BusinessProcessInstance'))
  CREATE UNIQUE INDEX UX_BusinessProcessInstance_Object_Template_Running
    ON dbo.BusinessProcessInstance (objectType, objectId, templateCode)
    WHERE status = N'RUNNING';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_BusinessProcessInstance_IdempotencyKey' AND object_id = OBJECT_ID(N'dbo.BusinessProcessInstance'))
  CREATE UNIQUE INDEX UX_BusinessProcessInstance_IdempotencyKey
    ON dbo.BusinessProcessInstance (idempotencyKey)
    WHERE idempotencyKey IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTask_AssigneeUser_Status' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask'))
  CREATE INDEX IX_BusinessProcessTask_AssigneeUser_Status
    ON dbo.BusinessProcessTask (assigneeUser, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTask_AssigneeRole_Status' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask'))
  CREATE INDEX IX_BusinessProcessTask_AssigneeRole_Status
    ON dbo.BusinessProcessTask (assigneeRole, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTask_Status_ActiveFrom' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask'))
  CREATE INDEX IX_BusinessProcessTask_Status_ActiveFrom
    ON dbo.BusinessProcessTask (status, activeFrom);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTask_Status_DueAt' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask'))
  CREATE INDEX IX_BusinessProcessTask_Status_DueAt
    ON dbo.BusinessProcessTask (status, dueAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessTask_Instance_Step_Status' AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask'))
  CREATE INDEX IX_BusinessProcessTask_Instance_Step_Status
    ON dbo.BusinessProcessTask (instanceId, stepKey, status);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessEvent_InstanceId_EventAt' AND object_id = OBJECT_ID(N'dbo.BusinessProcessEvent'))
  CREATE INDEX IX_BusinessProcessEvent_InstanceId_EventAt
    ON dbo.BusinessProcessEvent (instanceId, eventAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_BusinessProcessEvent_EventKey' AND object_id = OBJECT_ID(N'dbo.BusinessProcessEvent'))
  CREATE UNIQUE INDEX UX_BusinessProcessEvent_EventKey
    ON dbo.BusinessProcessEvent (eventKey)
    WHERE eventKey IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessDelegation_UserFrom_Active_Dates' AND object_id = OBJECT_ID(N'dbo.BusinessProcessDelegation'))
  CREATE INDEX IX_BusinessProcessDelegation_UserFrom_Active_Dates
    ON dbo.BusinessProcessDelegation (userFrom, active, dateFrom, dateTo);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_BusinessProcessDelegation_UserTo_Active_Dates' AND object_id = OBJECT_ID(N'dbo.BusinessProcessDelegation'))
  CREATE INDEX IX_BusinessProcessDelegation_UserTo_Active_Dates
    ON dbo.BusinessProcessDelegation (userTo, active, dateFrom, dateTo);
GO
