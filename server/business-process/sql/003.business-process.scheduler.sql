IF COL_LENGTH('dbo.BusinessProcessTask', 'overdueAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD overdueAt DATETIME2(3) NULL;
END;
GO

IF COL_LENGTH('dbo.BusinessProcessTask', 'penaltyAppliedAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD penaltyAppliedAt DATETIME2(3) NULL;
END;
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Waiting_ActiveFrom'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Waiting_ActiveFrom
    ON dbo.BusinessProcessTask (status, activeFrom)
    INCLUDE (instanceId, stepKey, dueAt);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Active_DueAt'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Active_DueAt
    ON dbo.BusinessProcessTask (status, dueAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Overdue_Penalty'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Overdue_Penalty
    ON dbo.BusinessProcessTask (status, penaltyAppliedAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Overdue_PenaltyPending'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Overdue_PenaltyPending
    ON dbo.BusinessProcessTask (status, penaltyAppliedAt, overdueAt, dueAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO
