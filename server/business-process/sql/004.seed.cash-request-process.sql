-- First executable Business Process scenario for Document.CashRequest.
-- Apply manually in a development/test database after 001-003 scripts.
-- The template remains DRAFT: activate it through POST /api/business-process/templates/:id/activate
-- so that rule references and JavaScript modules are validated by TemplateService.

SET NOCOUNT ON;

-- The seed can be rerun against a template table created before rule bindings
-- were introduced. Upgrade that table before compiling the MERGE below.
IF OBJECT_ID(N'dbo.BusinessProcessTemplate', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.BusinessProcessTemplate', N'rules') IS NULL
BEGIN
  EXEC(N'ALTER TABLE dbo.BusinessProcessTemplate ADD rules NVARCHAR(MAX) NULL;');
  EXEC(N'UPDATE dbo.BusinessProcessTemplate SET rules = N''[]'' WHERE rules IS NULL;');
  EXEC(N'ALTER TABLE dbo.BusinessProcessTemplate ALTER COLUMN rules NVARCHAR(MAX) NOT NULL;');
END;
GO

IF COL_LENGTH(N'dbo.BusinessProcessTemplate', N'rules') IS NOT NULL
   AND NOT EXISTS (
     SELECT 1
     FROM sys.check_constraints
     WHERE name = N'CK_BusinessProcessTemplate_RulesJson'
       AND parent_object_id = OBJECT_ID(N'dbo.BusinessProcessTemplate')
   )
BEGIN
  ALTER TABLE dbo.BusinessProcessTemplate
    ADD CONSTRAINT CK_BusinessProcessTemplate_RulesJson
    CHECK (ISJSON(rules) = 1);
END;
GO

DECLARE @RuleFolderId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.Documents
  WHERE [type] = N'Catalog.BusinessProcessRules'
    AND code = N'BP.CashRequest'
    AND isfolder = 1
);
IF @RuleFolderId IS NULL SET @RuleFolderId = N'34EBD902-5026-45EB-904C-F1D5F285DF01';

DECLARE @AssignmentRuleId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.Documents
  WHERE [type] = N'Catalog.BusinessProcessRules'
    AND code = N'BP.CashRequest.AssignAuthor'
    AND isfolder = 0
);
IF @AssignmentRuleId IS NULL SET @AssignmentRuleId = N'34EBD902-5026-45EB-904C-F1D5F285DF02';

DECLARE @DecisionsRuleId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.Documents
  WHERE [type] = N'Catalog.BusinessProcessRules'
    AND code = N'BP.CashRequest.Decisions'
    AND isfolder = 0
);
IF @DecisionsRuleId IS NULL SET @DecisionsRuleId = N'34EBD902-5026-45EB-904C-F1D5F285DF03';

DECLARE @DeadlineRuleId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.Documents
  WHERE [type] = N'Catalog.BusinessProcessRules'
    AND code = N'BP.CashRequest.Deadline'
    AND isfolder = 0
);
IF @DeadlineRuleId IS NULL SET @DeadlineRuleId = N'34EBD902-5026-45EB-904C-F1D5F285DF04';

DECLARE @TimeoutRuleId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.Documents
  WHERE [type] = N'Catalog.BusinessProcessRules'
    AND code = N'BP.CashRequest.Timeout'
    AND isfolder = 0
);
IF @TimeoutRuleId IS NULL SET @TimeoutRuleId = N'34EBD902-5026-45EB-904C-F1D5F285DF05';

DECLARE @FolderDescription NVARCHAR(150) = N'Согласование заявок на расход денежных средств';
DECLARE @FolderDocument NVARCHAR(MAX) = (
  SELECT
    N'BP.CashRequest' AS code,
    @FolderDescription AS description
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

MERGE dbo.Documents AS target
USING (SELECT @RuleFolderId AS id) AS source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    [type] = N'Catalog.BusinessProcessRules',
    code = N'BP.CashRequest',
    description = @FolderDescription,
    deleted = 0,
    parent = NULL,
    isfolder = 1,
    doc = @FolderDocument,
    [timestamp] = GETDATE()
WHEN NOT MATCHED THEN
  INSERT (
    id, [type], [date], code, description, posted, deleted,
    doc, parent, isfolder, company, [user], info
  )
  VALUES (
    @RuleFolderId, N'Catalog.BusinessProcessRules', SYSUTCDATETIME(), N'BP.CashRequest',
    @FolderDescription, 0, 0, @FolderDocument, NULL, 1, NULL, NULL, N''
  );

DECLARE @Rules TABLE (
  id UNIQUEIDENTIFIER NOT NULL,
  code NVARCHAR(36) NOT NULL,
  description NVARCHAR(150) NOT NULL,
  purpose NVARCHAR(100) NOT NULL,
  module NVARCHAR(MAX) NOT NULL
);

INSERT INTO @Rules (id, code, description, purpose, module)
VALUES
(
  @AssignmentRuleId,
  N'BP.CashRequest.AssignAuthor',
  N'Назначить задачу автору заявки ДС',
  N'TASK_ASSIGNMENT',
  N'module.exports = async function (context) {
  const user = context.process.context.author || context.process.instance.authorUser || context.event.user;
  if (!user) throw new Error("CashRequest author is required for task assignment");
  return { assignees: [{ user: user }] };
};'
),
(
  @DecisionsRuleId,
  N'BP.CashRequest.Decisions',
  N'Доступные решения по заявке ДС',
  N'TASK_AVAILABLE_DECISIONS',
  N'module.exports = async function (context, tx, settings) {
  const decisions = Array.isArray(settings.decisions) ? settings.decisions : ["APPROVE", "REJECT"];
  return { decisions: decisions };
};'
),
(
  @DeadlineRuleId,
  N'BP.CashRequest.Deadline',
  N'Срок согласования заявки ДС',
  N'TASK_DEADLINE_DATE',
  N'module.exports = async function (context, tx, settings) {
  const minutes = Number(settings.minutes);
  if (!Number.isFinite(minutes) || minutes <= 0) throw new Error("settings.minutes must be a positive number");
  const eventNow = context.event.data && context.event.data.now;
  const now = eventNow instanceof Date ? eventNow : new Date(eventNow || Date.now());
  return { deadline: { at: new Date(now.getTime() + minutes * 60000) } };
};'
),
(
  @TimeoutRuleId,
  N'BP.CashRequest.Timeout',
  N'Отклонить просроченную заявку ДС',
  N'TASK_DEADLINE_AUTO_EXECUTE',
  N'module.exports = async function (context, tx, settings) {
  return {
    decision: {
      key: settings.decisionKey || "TIMEOUT",
      comment: settings.comment || "Срок согласования истёк"
    }
  };
};'
);

MERGE dbo.Documents AS target
USING (
  SELECT
    source.id,
    source.code,
    source.description,
    source.purpose,
    source.module,
    (
      SELECT
        source.code AS code,
        source.description AS description,
        source.purpose AS purpose,
        source.module AS [module]
      FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS doc
  FROM @Rules source
) AS source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    [type] = N'Catalog.BusinessProcessRules',
    code = source.code,
    description = source.description,
    deleted = 0,
    parent = @RuleFolderId,
    isfolder = 0,
    doc = source.doc,
    [timestamp] = GETDATE()
WHEN NOT MATCHED THEN
  INSERT (
    id, [type], [date], code, description, posted, deleted,
    doc, parent, isfolder, company, [user], info
  )
  VALUES (
    source.id, N'Catalog.BusinessProcessRules', SYSUTCDATETIME(), source.code,
    source.description, 0, 0, source.doc, @RuleFolderId, 0, NULL, NULL, N''
  );

DECLARE @TemplateId UNIQUEIDENTIFIER = (
  SELECT TOP (1) id
  FROM dbo.BusinessProcessTemplate
  WHERE code = N'CashRequestApproval'
    AND version = 1
);
IF @TemplateId IS NULL SET @TemplateId = N'34EBD902-5026-45EB-904C-F1D5F285DF10';

DECLARE @StepRules NVARCHAR(MAX) = CONCAT(
  N'[',
  N'{"rule":"', CONVERT(NVARCHAR(36), @AssignmentRuleId), N'","order":10,"settings":{}},',
  N'{"rule":"', CONVERT(NVARCHAR(36), @DecisionsRuleId), N'","order":20,"settings":{"decisions":["APPROVE","REJECT"]}},',
  N'{"rule":"', CONVERT(NVARCHAR(36), @DeadlineRuleId), N'","order":30,"settings":{"minutes":1440}},',
  N'{"rule":"', CONVERT(NVARCHAR(36), @TimeoutRuleId), N'","order":40,"settings":{"decisionKey":"TIMEOUT","comment":"Срок согласования истёк"}}',
  N']'
);

DECLARE @Steps NVARCHAR(MAX) = CONCAT(
  N'[{
    "key":"finance_approval",
    "title":"Согласование заявки ДС",
    "type":"USER_TASK",
    "rules":', @StepRules, N',
    "decisions":[
      {"key":"APPROVE","title":"Согласовать","commentRequired":false},
      {"key":"REJECT","title":"Отклонить","commentRequired":true},
      {"key":"TIMEOUT","title":"Срок истёк","commentRequired":false}
    ],
    "completionPolicy":"ANY",
    "allowRedirect":true,
    "allowDelegate":true,
    "rejectPolicy":"REJECT_PROCESS"
  }]'
);

DECLARE @Transitions NVARCHAR(MAX) = N'[
  {"key":"approve","from":"finance_approval","on":"APPROVE","to":"END_APPROVED"},
  {"key":"reject","from":"finance_approval","on":"REJECT","to":"END_REJECTED"},
  {"key":"timeout","from":"finance_approval","on":"TIMEOUT","to":"END_REJECTED"}
]';

-- A repeated seed intentionally returns version 1 to DRAFT. There are no live BP data yet;
-- activation is an explicit operation and validates current Catalog.BusinessProcessRules modules.
UPDATE dbo.BusinessProcessTemplate
SET status = N'ARCHIVED',
    active = 0,
    archivedAt = COALESCE(archivedAt, SYSUTCDATETIME()),
    updatedAt = SYSUTCDATETIME()
WHERE code = N'CashRequestApproval'
  AND status = N'ACTIVE';

MERGE dbo.BusinessProcessTemplate AS target
USING (SELECT @TemplateId AS id) AS source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    code = N'CashRequestApproval',
    description = N'Согласование заявки на расход денежных средств',
    active = 0,
    status = N'DRAFT',
    objectTypes = N'["Document.CashRequest"]',
    startMode = N'ON_POST',
    rules = N'[]',
    startCondition = NULL,
    steps = @Steps,
    transitions = @Transitions,
    parameters = N'{"startStepKey":"finance_approval"}',
    activatedAt = NULL,
    archivedAt = NULL,
    updatedAt = SYSUTCDATETIME()
WHEN NOT MATCHED THEN
  INSERT (
    id, code, description, active, version, status, objectTypes, startMode,
    rules, startCondition, steps, transitions, parameters, createdBy
  )
  VALUES (
    @TemplateId,
    N'CashRequestApproval',
    N'Согласование заявки на расход денежных средств',
    0,
    1,
    N'DRAFT',
    N'["Document.CashRequest"]',
    N'ON_POST',
    N'[]',
    NULL,
    @Steps,
    @Transitions,
    N'{"startStepKey":"finance_approval"}',
    NULL
  );

SELECT
  @TemplateId AS templateId,
  N'CashRequestApproval' AS templateCode,
  N'DRAFT' AS templateStatus,
  N'Activate through POST /api/business-process/templates/'
    + CONVERT(NVARCHAR(36), @TemplateId)
    + N'/activate' AS nextAction;
GO
