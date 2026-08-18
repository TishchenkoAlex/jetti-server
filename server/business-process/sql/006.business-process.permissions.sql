-- Runtime permissions for the Jetti API database user.
-- Catalog.BusinessProcessRules are stored in dbo.Documents; permissions for that
-- table are managed by server/sql/user.jetti.sql.

IF DATABASE_PRINCIPAL_ID(N'jetti') IS NULL
  THROW 51000, 'Database user jetti does not exist', 1;
GO

GRANT SELECT, INSERT, UPDATE
  ON OBJECT::dbo.BusinessProcessTemplate TO [jetti];
GO

GRANT SELECT, INSERT, UPDATE
  ON OBJECT::dbo.BusinessProcessInstance TO [jetti];
GO

GRANT SELECT, INSERT, UPDATE
  ON OBJECT::dbo.BusinessProcessTask TO [jetti];
GO

GRANT SELECT, INSERT
  ON OBJECT::dbo.BusinessProcessEvent TO [jetti];
GO

GRANT SELECT, INSERT, UPDATE
  ON OBJECT::dbo.BusinessProcessDelegation TO [jetti];
GO

EXECUTE AS USER = N'jetti';

SELECT
  permissionState.permissionName,
  permissionState.objectName,
  permissionState.hasPermission
FROM (
  VALUES
    (N'SELECT', N'dbo.BusinessProcessTemplate', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTemplate', N'OBJECT', N'SELECT')),
    (N'INSERT', N'dbo.BusinessProcessTemplate', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTemplate', N'OBJECT', N'INSERT')),
    (N'UPDATE', N'dbo.BusinessProcessTemplate', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTemplate', N'OBJECT', N'UPDATE')),
    (N'SELECT', N'dbo.BusinessProcessInstance', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessInstance', N'OBJECT', N'SELECT')),
    (N'INSERT', N'dbo.BusinessProcessInstance', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessInstance', N'OBJECT', N'INSERT')),
    (N'UPDATE', N'dbo.BusinessProcessInstance', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessInstance', N'OBJECT', N'UPDATE')),
    (N'SELECT', N'dbo.BusinessProcessTask', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTask', N'OBJECT', N'SELECT')),
    (N'INSERT', N'dbo.BusinessProcessTask', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTask', N'OBJECT', N'INSERT')),
    (N'UPDATE', N'dbo.BusinessProcessTask', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessTask', N'OBJECT', N'UPDATE')),
    (N'SELECT', N'dbo.BusinessProcessEvent', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessEvent', N'OBJECT', N'SELECT')),
    (N'INSERT', N'dbo.BusinessProcessEvent', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessEvent', N'OBJECT', N'INSERT')),
    (N'SELECT', N'dbo.BusinessProcessDelegation', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessDelegation', N'OBJECT', N'SELECT')),
    (N'INSERT', N'dbo.BusinessProcessDelegation', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessDelegation', N'OBJECT', N'INSERT')),
    (N'UPDATE', N'dbo.BusinessProcessDelegation', HAS_PERMS_BY_NAME(N'dbo.BusinessProcessDelegation', N'OBJECT', N'UPDATE'))
) permissionState(permissionName, objectName, hasPermission)
ORDER BY permissionState.objectName, permissionState.permissionName;

REVERT;
GO
