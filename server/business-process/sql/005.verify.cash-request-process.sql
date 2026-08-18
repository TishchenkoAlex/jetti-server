-- Structural smoke check for 004.seed.cash-request-process.sql.
-- JavaScript compilation is intentionally checked later by TemplateService.activate().

SET NOCOUNT ON;

DECLARE @TemplateId UNIQUEIDENTIFIER;
DECLARE @Steps NVARCHAR(MAX);
DECLARE @Transitions NVARCHAR(MAX);

SELECT TOP (1)
  @TemplateId = id,
  @Steps = steps,
  @Transitions = transitions
FROM dbo.BusinessProcessTemplate
WHERE code = N'CashRequestApproval'
  AND version = 1;

IF @TemplateId IS NULL
  THROW 51000, 'CashRequestApproval template v1 is not installed', 1;

IF ISJSON(@Steps) <> 1
  THROW 51000, 'CashRequestApproval steps are not valid JSON', 1;

IF ISJSON(@Transitions) <> 1
  THROW 51000, 'CashRequestApproval transitions are not valid JSON', 1;

IF NOT EXISTS (
  SELECT 1
  FROM OPENJSON(@Steps)
  WITH (
    stepKey NVARCHAR(128) '$.key',
    stepType NVARCHAR(32) '$.type',
    rules NVARCHAR(MAX) '$.rules' AS JSON
  ) step
  WHERE step.stepKey = N'finance_approval'
    AND step.stepType = N'USER_TASK'
    AND ISJSON(step.rules) = 1
)
  THROW 51000, 'finance_approval USER_TASK is not configured', 1;

DECLARE @RequiredPurposes TABLE (purpose NVARCHAR(100) NOT NULL PRIMARY KEY);
INSERT INTO @RequiredPurposes (purpose)
VALUES
  (N'TASK_ASSIGNMENT'),
  (N'TASK_AVAILABLE_DECISIONS'),
  (N'TASK_DEADLINE_DATE'),
  (N'TASK_DEADLINE_AUTO_EXECUTE');

IF EXISTS (
  SELECT required.purpose
  FROM @RequiredPurposes required
  WHERE NOT EXISTS (
    SELECT 1
    FROM OPENJSON(@Steps)
    WITH (
      stepKey NVARCHAR(128) '$.key',
      rules NVARCHAR(MAX) '$.rules' AS JSON
    ) step
    CROSS APPLY OPENJSON(step.rules)
    WITH (ruleId UNIQUEIDENTIFIER '$.rule') binding
    INNER JOIN dbo.Documents ruleDocument
      ON ruleDocument.id = binding.ruleId
     AND ruleDocument.[type] = N'Catalog.BusinessProcessRules'
     AND ruleDocument.deleted = 0
     AND ruleDocument.isfolder = 0
    CROSS APPLY OPENJSON(ruleDocument.doc)
    WITH (
      purpose NVARCHAR(100) '$.purpose',
      [module] NVARCHAR(MAX) '$.module'
    ) ruleData
    WHERE step.stepKey = N'finance_approval'
      AND ruleData.purpose = required.purpose
      AND NULLIF(LTRIM(RTRIM(ruleData.[module])), N'') IS NOT NULL
  )
)
  THROW 51000, 'CashRequestApproval has a missing or empty required rule', 1;

DECLARE @RequiredTransitions TABLE (
  decisionKey NVARCHAR(128) NOT NULL PRIMARY KEY,
  targetKey NVARCHAR(128) NOT NULL
);
INSERT INTO @RequiredTransitions (decisionKey, targetKey)
VALUES
  (N'APPROVE', N'END_APPROVED'),
  (N'REJECT', N'END_REJECTED'),
  (N'TIMEOUT', N'END_REJECTED');

IF EXISTS (
  SELECT required.decisionKey
  FROM @RequiredTransitions required
  WHERE NOT EXISTS (
    SELECT 1
    FROM OPENJSON(@Transitions)
    WITH (
      fromStepKey NVARCHAR(128) '$.from',
      decisionKey NVARCHAR(128) '$.on',
      targetKey NVARCHAR(128) '$.to'
    ) transitionData
    WHERE transitionData.fromStepKey = N'finance_approval'
      AND transitionData.decisionKey = required.decisionKey
      AND transitionData.targetKey = required.targetKey
  )
)
  THROW 51000, 'CashRequestApproval has an invalid decision transition', 1;

SELECT
  @TemplateId AS templateId,
  template.status AS templateStatus,
  COUNT(DISTINCT ruleDocument.id) AS resolvedRules,
  N'VALID' AS validationResult
FROM dbo.BusinessProcessTemplate template
CROSS APPLY OPENJSON(template.steps)
WITH (rules NVARCHAR(MAX) '$.rules' AS JSON) step
CROSS APPLY OPENJSON(step.rules)
WITH (ruleId UNIQUEIDENTIFIER '$.rule') binding
INNER JOIN dbo.Documents ruleDocument
  ON ruleDocument.id = binding.ruleId
WHERE template.id = @TemplateId
GROUP BY template.status;
GO
