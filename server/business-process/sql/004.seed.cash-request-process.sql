-- Draft/active seed for Document.CashRequest internal BP.
-- Apply manually in dev/test only.

IF NOT EXISTS (
  SELECT 1
  FROM dbo.BusinessProcessTemplate
  WHERE code = N'CashRequestApproval'
)
BEGIN
  INSERT INTO dbo.BusinessProcessTemplate (
    id, code, description, active, version, status, objectTypes, startMode,
    startCondition, steps, transitions, parameters, createdBy, activatedAt
  )
  VALUES (
    NEWID(),
    N'CashRequestApproval',
    N'Internal cash request approval process',
    1,
    1,
    N'ACTIVE',
    JSON_QUERY(N'["Document.CashRequest"]'),
    N'ON_POST',
    NULL,
    JSON_QUERY(N'[
      {
        "key": "finance_approval",
        "title": "Согласование заявки ДС",
        "type": "USER_TASK",
        "assignmentRule": {
          "type": "ROLE",
          "role": "Cash request approver"
        },
        "dueRule": {
          "hours": 24
        },
        "penaltyRule": {
          "amount": 500
        },
        "allowRedirect": true,
        "allowDelegate": true,
        "rejectPolicy": "REJECT_PROCESS"
      }
    ]'),
    JSON_QUERY(N'[
      {
        "from": "finance_approval",
        "on": "APPROVE",
        "to": "END_APPROVED"
      },
      {
        "from": "finance_approval",
        "on": "REJECT",
        "to": "END_REJECTED"
      }
    ]'),
    JSON_QUERY(N'{
      "startStepKey": "finance_approval"
    }'),
    N'seed',
    SYSUTCDATETIME()
  );
END;
GO
