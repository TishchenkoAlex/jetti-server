IF COL_LENGTH(N'dbo.BusinessProcessTemplate', N'bpmnXml') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTemplate ADD bpmnXml NVARCHAR(MAX) NULL;
END;
GO

IF COL_LENGTH(N'dbo.BusinessProcessTemplate', N'visualMapping') IS NULL
BEGIN
  ALTER TABLE dbo.BusinessProcessTemplate ADD visualMapping NVARCHAR(MAX) NULL;
END;
GO

IF NOT EXISTS (
  SELECT 1
  FROM sys.check_constraints
  WHERE name = N'CK_BusinessProcessTemplate_VisualMappingJson'
)
BEGIN
  ALTER TABLE dbo.BusinessProcessTemplate
    ADD CONSTRAINT CK_BusinessProcessTemplate_VisualMappingJson
    CHECK (visualMapping IS NULL OR ISJSON(visualMapping) = 1);
END;
GO
