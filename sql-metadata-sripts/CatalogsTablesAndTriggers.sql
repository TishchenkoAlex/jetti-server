
------------------------------ BEGIN Catalog.BRMRules ------------------------------

      RAISERROR('Catalog.BRMRules start', 0 ,1) WITH NOWAIT;
      GO
      
    CREATE OR ALTER TRIGGER [Catalog.BRMRules.t] ON [Documents] AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
      SET NOCOUNT ON;
      DECLARE @COUNT_D BIGINT = (SELECT COUNT(*) FROM deleted WHERE type = N'Catalog.BRMRules');
      IF (@COUNT_D) > 1 DELETE FROM [Catalog.BRMRules.v] WHERE id IN (SELECT id FROM deleted WHERE type = N'Catalog.BRMRules');
      IF (@COUNT_D) = 1 DELETE FROM [Catalog.BRMRules.v] WHERE id = (SELECT id FROM deleted WHERE type = N'Catalog.BRMRules');
      IF (SELECT COUNT(*) FROM inserted WHERE type = N'Catalog.BRMRules') = 0 RETURN;

      INSERT INTO [Catalog.BRMRules.v] ([id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user],[workflow],[functionName],[weight])
    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."functionName"')), '') [functionName]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."weight"')), 0) [weight]

    FROM inserted r
    WHERE [type] = N'Catalog.BRMRules'
    END	
GO

    DROP TABLE IF EXISTS [Catalog.BRMRules.v];
    DROP VIEW IF EXISTS [Catalog.BRMRules.v];	
GO

    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."functionName"')), '') [functionName]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."weight"')), 0) [weight]

    INTO [Catalog.BRMRules.v]
    FROM [Documents] r
    WHERE r.type = N'Catalog.BRMRules';	
GO

    GRANT SELECT,INSERT,DELETE ON [Catalog.BRMRules.v] TO JETTI;	
GO

    ALTER TABLE [Catalog.BRMRules.v] ADD CONSTRAINT [PK_Catalog.BRMRules.v] PRIMARY KEY NONCLUSTERED ([id]);
    CREATE UNIQUE CLUSTERED INDEX [Catalog.BRMRules.v] ON [Catalog.BRMRules.v](id);
      
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.deleted] ON [Catalog.BRMRules.v](deleted,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.code.f] ON [Catalog.BRMRules.v](parent,isfolder,code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.description.f] ON [Catalog.BRMRules.v](parent,isfolder,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.description] ON [Catalog.BRMRules.v](description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.code] ON [Catalog.BRMRules.v](code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.user] ON [Catalog.BRMRules.v]([user],id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.company] ON [Catalog.BRMRules.v](company,id);
      RAISERROR('Catalog.BRMRules end', 0 ,1) WITH NOWAIT;
      
------------------------------ END Catalog.BRMRules ------------------------------

------------------------------ BEGIN Catalog.ModifiersGroup ------------------------------

      RAISERROR('Catalog.ModifiersGroup start', 0 ,1) WITH NOWAIT;
      GO
      
    CREATE OR ALTER TRIGGER [Catalog.ModifiersGroup.t] ON [Documents] AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
      SET NOCOUNT ON;
      DECLARE @COUNT_D BIGINT = (SELECT COUNT(*) FROM deleted WHERE type = N'Catalog.ModifiersGroup');
      IF (@COUNT_D) > 1 DELETE FROM [Catalog.ModifiersGroup.v] WHERE id IN (SELECT id FROM deleted WHERE type = N'Catalog.ModifiersGroup');
      IF (@COUNT_D) = 1 DELETE FROM [Catalog.ModifiersGroup.v] WHERE id = (SELECT id FROM deleted WHERE type = N'Catalog.ModifiersGroup');
      IF (SELECT COUNT(*) FROM inserted WHERE type = N'Catalog.ModifiersGroup') = 0 RETURN;

      INSERT INTO [Catalog.ModifiersGroup.v] ([id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user],[workflow],[MinPosition],[MaxPosition],[Multiselection])
    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MinPosition"')), 0) [MinPosition]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxPosition"')), 0) [MaxPosition]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Multiselection"')), 0) [Multiselection]

    FROM inserted r
    WHERE [type] = N'Catalog.ModifiersGroup'
    END	
GO

    DROP TABLE IF EXISTS [Catalog.ModifiersGroup.v];
    DROP VIEW IF EXISTS [Catalog.ModifiersGroup.v];	
GO

    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MinPosition"')), 0) [MinPosition]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxPosition"')), 0) [MaxPosition]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Multiselection"')), 0) [Multiselection]

    INTO [Catalog.ModifiersGroup.v]
    FROM [Documents] r
    WHERE r.type = N'Catalog.ModifiersGroup';	
GO

    GRANT SELECT,INSERT,DELETE ON [Catalog.ModifiersGroup.v] TO JETTI;	
GO

    ALTER TABLE [Catalog.ModifiersGroup.v] ADD CONSTRAINT [PK_Catalog.ModifiersGroup.v] PRIMARY KEY NONCLUSTERED ([id]);
    CREATE UNIQUE CLUSTERED INDEX [Catalog.ModifiersGroup.v] ON [Catalog.ModifiersGroup.v](id);
      
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.deleted] ON [Catalog.ModifiersGroup.v](deleted,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.code.f] ON [Catalog.ModifiersGroup.v](parent,isfolder,code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.description.f] ON [Catalog.ModifiersGroup.v](parent,isfolder,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.description] ON [Catalog.ModifiersGroup.v](description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.code] ON [Catalog.ModifiersGroup.v](code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.user] ON [Catalog.ModifiersGroup.v]([user],id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.company] ON [Catalog.ModifiersGroup.v](company,id);
      RAISERROR('Catalog.ModifiersGroup end', 0 ,1) WITH NOWAIT;
      
------------------------------ END Catalog.ModifiersGroup ------------------------------

------------------------------ BEGIN Catalog.MoneyDocument ------------------------------

      RAISERROR('Catalog.MoneyDocument start', 0 ,1) WITH NOWAIT;
      GO
      
    CREATE OR ALTER TRIGGER [Catalog.MoneyDocument.t] ON [Documents] AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
      SET NOCOUNT ON;
      DECLARE @COUNT_D BIGINT = (SELECT COUNT(*) FROM deleted WHERE type = N'Catalog.MoneyDocument');
      IF (@COUNT_D) > 1 DELETE FROM [Catalog.MoneyDocument.v] WHERE id IN (SELECT id FROM deleted WHERE type = N'Catalog.MoneyDocument');
      IF (@COUNT_D) = 1 DELETE FROM [Catalog.MoneyDocument.v] WHERE id = (SELECT id FROM deleted WHERE type = N'Catalog.MoneyDocument');
      IF (SELECT COUNT(*) FROM inserted WHERE type = N'Catalog.MoneyDocument') = 0 RETURN;

      INSERT INTO [Catalog.MoneyDocument.v] ([id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user],[workflow],[kind],[currency],[Owner],[Qty],[Price],[CreateDate],[ExpiredAt],[currency_Pay],[Amount_Pay])
    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."kind"')) [kind]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Owner"')) [Owner]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Qty"')), 0) [Qty]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Price"')), 0) [Price]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."CreateDate"'),127) [CreateDate]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."ExpiredAt"'),127) [ExpiredAt]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency_Pay"')) [currency_Pay]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount_Pay"')), 0) [Amount_Pay]

    FROM inserted r
    WHERE [type] = N'Catalog.MoneyDocument'
    END	
GO

    DROP TABLE IF EXISTS [Catalog.MoneyDocument.v];
    DROP VIEW IF EXISTS [Catalog.MoneyDocument.v];	
GO

    
      SELECT [id],[type],[date],[code],[description],[posted],[deleted],[isfolder],[timestamp],[parent],[company],[user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."kind"')) [kind]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Owner"')) [Owner]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Qty"')), 0) [Qty]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Price"')), 0) [Price]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."CreateDate"'),127) [CreateDate]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."ExpiredAt"'),127) [ExpiredAt]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency_Pay"')) [currency_Pay]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount_Pay"')), 0) [Amount_Pay]

    INTO [Catalog.MoneyDocument.v]
    FROM [Documents] r
    WHERE r.type = N'Catalog.MoneyDocument';	
GO

    GRANT SELECT,INSERT,DELETE ON [Catalog.MoneyDocument.v] TO JETTI;	
GO

    ALTER TABLE [Catalog.MoneyDocument.v] ADD CONSTRAINT [PK_Catalog.MoneyDocument.v] PRIMARY KEY NONCLUSTERED ([id]);
    CREATE UNIQUE CLUSTERED INDEX [Catalog.MoneyDocument.v] ON [Catalog.MoneyDocument.v](id);
      
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.deleted] ON [Catalog.MoneyDocument.v](deleted,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.code.f] ON [Catalog.MoneyDocument.v](parent,isfolder,code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.description.f] ON [Catalog.MoneyDocument.v](parent,isfolder,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.description] ON [Catalog.MoneyDocument.v](description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.code] ON [Catalog.MoneyDocument.v](code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.user] ON [Catalog.MoneyDocument.v]([user],id);
    CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.company] ON [Catalog.MoneyDocument.v](company,id);
      RAISERROR('Catalog.MoneyDocument end', 0 ,1) WITH NOWAIT;
      
------------------------------ END Catalog.MoneyDocument ------------------------------
