IF OBJECT_ID(N'dbo.BusinessProcessTask', N'U') IS NOT NULL
   AND COL_LENGTH('dbo.BusinessProcessTask', 'deadlineAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD deadlineAt DATETIME2(3) NULL;

  IF COL_LENGTH('dbo.BusinessProcessTask', 'dueAt') IS NOT NULL
    EXEC(N'UPDATE dbo.BusinessProcessTask SET deadlineAt = dueAt WHERE deadlineAt IS NULL;');
END;
GO

IF COL_LENGTH('dbo.BusinessProcessTask', 'deadlineReachedAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD deadlineReachedAt DATETIME2(3) NULL;
END;
GO

IF COL_LENGTH('dbo.BusinessProcessTask', 'penaltyStartedAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD penaltyStartedAt DATETIME2(3) NULL;
END;
GO

IF COL_LENGTH('dbo.BusinessProcessTask', 'penaltyLastCalculatedAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD penaltyLastCalculatedAt DATETIME2(3) NULL;
END;
GO

IF COL_LENGTH('dbo.BusinessProcessTask', 'nextPenaltyCalculationAt') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTask
    ADD nextPenaltyCalculationAt DATETIME2(3) NULL;
END;
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Waiting_ActiveFrom'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Waiting_ActiveFrom
    ON dbo.BusinessProcessTask (status, activeFrom)
    INCLUDE (instanceId, stepKey, deadlineAt);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Overdue_NextPenaltyCalculation'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Overdue_NextPenaltyCalculation
    ON dbo.BusinessProcessTask (status, nextPenaltyCalculationAt, penaltyLastCalculatedAt)
    INCLUDE (instanceId, stepKey, deadlineAt, deadlineReachedAt, penaltyAmount);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Active_DeadlineAt'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Active_DeadlineAt
    ON dbo.BusinessProcessTask (status, deadlineAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Overdue_PenaltyCalculation'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Overdue_PenaltyCalculation
    ON dbo.BusinessProcessTask (status, penaltyLastCalculatedAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'IX_BusinessProcessTask_Overdue_PenaltyPending'
    AND object_id = OBJECT_ID(N'dbo.BusinessProcessTask')
)
  CREATE INDEX IX_BusinessProcessTask_Overdue_PenaltyPending
    ON dbo.BusinessProcessTask (status, penaltyLastCalculatedAt, deadlineReachedAt, deadlineAt)
    INCLUDE (instanceId, stepKey, penaltyAmount);
GO
