

------------------------------ BEGIN Catalog.Attachment.Type ------------------------------

RAISERROR('Catalog.Attachment.Type start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Attachment.Type.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Attachment.Type.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Attachment.Type.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."AllDocuments"')), 0) [AllDocuments]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."AllCatalogs"')), 0) [AllCatalogs]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxFileSize"')), 0) [MaxFileSize]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FileFilter"')), '') [FileFilter]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."StorageType"')), '') [StorageType]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."IconURL"')), '') [IconURL]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Tags"')), '') [Tags]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."LoadDataOnInit"')), 0) [LoadDataOnInit]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Attachment.Type';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Attachment.Type.v] ON [Catalog.Attachment.Type.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.deleted] ON [Catalog.Attachment.Type.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.code.f] ON [Catalog.Attachment.Type.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.description.f] ON [Catalog.Attachment.Type.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.description] ON [Catalog.Attachment.Type.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.code] ON [Catalog.Attachment.Type.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.user] ON [Catalog.Attachment.Type.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.Type.v.company] ON [Catalog.Attachment.Type.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Attachment.Type.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Attachment.Type.v] TO PUBLIC;
RAISERROR('Catalog.Attachment.Type end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Attachment.Type ------------------------------


------------------------------ BEGIN Catalog.Balance ------------------------------

RAISERROR('Catalog.Balance start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Balance.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Balance.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Balance.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPassive"')), 0) [isPassive]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Balance';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Balance.v] ON [Catalog.Balance.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.deleted] ON [Catalog.Balance.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.code.f] ON [Catalog.Balance.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.description.f] ON [Catalog.Balance.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.description] ON [Catalog.Balance.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.code] ON [Catalog.Balance.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.user] ON [Catalog.Balance.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.v.company] ON [Catalog.Balance.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Balance.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Balance.v] TO PUBLIC;
RAISERROR('Catalog.Balance end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Balance ------------------------------


------------------------------ BEGIN Catalog.Balance.Analytics ------------------------------

RAISERROR('Catalog.Balance.Analytics start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Balance.Analytics.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Balance.Analytics.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Balance.Analytics.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Balance.Analytics';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Balance.Analytics.v] ON [Catalog.Balance.Analytics.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.deleted] ON [Catalog.Balance.Analytics.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.code.f] ON [Catalog.Balance.Analytics.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.description.f] ON [Catalog.Balance.Analytics.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.description] ON [Catalog.Balance.Analytics.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.code] ON [Catalog.Balance.Analytics.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.user] ON [Catalog.Balance.Analytics.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Balance.Analytics.v.company] ON [Catalog.Balance.Analytics.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Balance.Analytics.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Balance.Analytics.v] TO PUBLIC;
RAISERROR('Catalog.Balance.Analytics end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Balance.Analytics ------------------------------


------------------------------ BEGIN Catalog.Bank ------------------------------

RAISERROR('Catalog.Bank start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Bank.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Bank.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Bank.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code2"')), '') [Code2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Address"')), '') [Address]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."KorrAccount"')), '') [KorrAccount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ExportRule"')) [ExportRule]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Bank';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Bank.v] ON [Catalog.Bank.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.deleted] ON [Catalog.Bank.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.code.f] ON [Catalog.Bank.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.description.f] ON [Catalog.Bank.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.description] ON [Catalog.Bank.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.code] ON [Catalog.Bank.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.user] ON [Catalog.Bank.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Bank.v.company] ON [Catalog.Bank.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Bank.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Bank.v] TO PUBLIC;
RAISERROR('Catalog.Bank end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Bank ------------------------------


------------------------------ BEGIN Catalog.BankAccount ------------------------------

RAISERROR('Catalog.BankAccount start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BankAccount.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BankAccount.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BankAccount.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank"')) [Bank]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BankAccount';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BankAccount.v] ON [Catalog.BankAccount.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.deleted] ON [Catalog.BankAccount.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.code.f] ON [Catalog.BankAccount.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.description.f] ON [Catalog.BankAccount.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.description] ON [Catalog.BankAccount.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.code] ON [Catalog.BankAccount.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.user] ON [Catalog.BankAccount.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BankAccount.v.company] ON [Catalog.BankAccount.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BankAccount.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.BankAccount.v] TO PUBLIC;
RAISERROR('Catalog.BankAccount end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BankAccount ------------------------------


------------------------------ BEGIN Catalog.Brand ------------------------------

RAISERROR('Catalog.Brand start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Brand.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Brand.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Brand.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Brand';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Brand.v] ON [Catalog.Brand.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.deleted] ON [Catalog.Brand.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.code.f] ON [Catalog.Brand.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.description.f] ON [Catalog.Brand.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.description] ON [Catalog.Brand.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.code] ON [Catalog.Brand.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.user] ON [Catalog.Brand.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Brand.v.company] ON [Catalog.Brand.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Brand.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Brand.v] TO PUBLIC;
RAISERROR('Catalog.Brand end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Brand ------------------------------


------------------------------ BEGIN Catalog.BudgetItem ------------------------------

RAISERROR('Catalog.BudgetItem start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BudgetItem.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BudgetItem.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BudgetItem.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."parent2"')) [parent2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."UnaryOperator"')), '') [UnaryOperator]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BudgetItem';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BudgetItem.v] ON [Catalog.BudgetItem.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.deleted] ON [Catalog.BudgetItem.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.code.f] ON [Catalog.BudgetItem.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.description.f] ON [Catalog.BudgetItem.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.description] ON [Catalog.BudgetItem.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.code] ON [Catalog.BudgetItem.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.user] ON [Catalog.BudgetItem.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BudgetItem.v.company] ON [Catalog.BudgetItem.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BudgetItem.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.BudgetItem.v] TO PUBLIC;
RAISERROR('Catalog.BudgetItem end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BudgetItem ------------------------------


------------------------------ BEGIN Catalog.BusinessCalendar ------------------------------

RAISERROR('Catalog.BusinessCalendar start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BusinessCalendar.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BusinessCalendar.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BusinessCalendar.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BusinessCalendar';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BusinessCalendar.v] ON [Catalog.BusinessCalendar.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.deleted] ON [Catalog.BusinessCalendar.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.code.f] ON [Catalog.BusinessCalendar.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.description.f] ON [Catalog.BusinessCalendar.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.description] ON [Catalog.BusinessCalendar.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.code] ON [Catalog.BusinessCalendar.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.user] ON [Catalog.BusinessCalendar.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessCalendar.v.company] ON [Catalog.BusinessCalendar.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BusinessCalendar.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.BusinessCalendar.v] TO PUBLIC;
RAISERROR('Catalog.BusinessCalendar end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BusinessCalendar ------------------------------


------------------------------ BEGIN Catalog.BusinessDirection ------------------------------

RAISERROR('Catalog.BusinessDirection start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BusinessDirection.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BusinessDirection.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BusinessDirection.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BusinessDirection';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BusinessDirection.v] ON [Catalog.BusinessDirection.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.deleted] ON [Catalog.BusinessDirection.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.code.f] ON [Catalog.BusinessDirection.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.description.f] ON [Catalog.BusinessDirection.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.description] ON [Catalog.BusinessDirection.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.code] ON [Catalog.BusinessDirection.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.user] ON [Catalog.BusinessDirection.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessDirection.v.company] ON [Catalog.BusinessDirection.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BusinessDirection.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.BusinessDirection.v] TO PUBLIC;
RAISERROR('Catalog.BusinessDirection end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BusinessDirection ------------------------------


------------------------------ BEGIN Catalog.CashRegister ------------------------------

RAISERROR('Catalog.CashRegister start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.CashRegister.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.CashRegister.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.CashRegister.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isAccounting"')), 0) [isAccounting]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.CashRegister';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.CashRegister.v] ON [Catalog.CashRegister.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.deleted] ON [Catalog.CashRegister.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.code.f] ON [Catalog.CashRegister.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.description.f] ON [Catalog.CashRegister.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.description] ON [Catalog.CashRegister.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.code] ON [Catalog.CashRegister.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.user] ON [Catalog.CashRegister.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashRegister.v.company] ON [Catalog.CashRegister.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.CashRegister.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.CashRegister.v] TO PUBLIC;
RAISERROR('Catalog.CashRegister end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.CashRegister ------------------------------


------------------------------ BEGIN Catalog.Catalog ------------------------------

RAISERROR('Catalog.Catalog start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Catalog.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Catalog.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Catalog.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."typeString"')), '') [typeString]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."prefix"')), '') [prefix]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."icon"')), '') [icon]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."menu"')), '') [menu]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."presentation"')), '') [presentation]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."hierarchy"')), '') [hierarchy]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."storedIn"')), '') [storedIn]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."moduleClient"')), '') [moduleClient]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."moduleServer"')), '') [moduleServer]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Catalog';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Catalog.v] ON [Catalog.Catalog.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.deleted] ON [Catalog.Catalog.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.code.f] ON [Catalog.Catalog.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.description.f] ON [Catalog.Catalog.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.description] ON [Catalog.Catalog.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.code] ON [Catalog.Catalog.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.user] ON [Catalog.Catalog.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Catalog.v.company] ON [Catalog.Catalog.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Catalog.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Catalog.v] TO PUBLIC;
RAISERROR('Catalog.Catalog end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Catalog ------------------------------


------------------------------ BEGIN Catalog.Company ------------------------------

RAISERROR('Catalog.Company start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Company.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Company.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Company.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullName"')), '') [FullName]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."prefix"')), '') [prefix]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Intercompany"')) [Intercompany]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessCalendar"')) [BusinessCalendar]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsibilityCenter"')) [ResponsibilityCenter]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressShipping"')), '') [AddressShipping]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressBilling"')), '') [AddressBilling]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Phone"')), '') [Phone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code2"')), '') [Code2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code3"')), '') [Code3]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Email"')), '') [Email]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."timeZone"')), '') [timeZone]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxOffice"')) [TaxOffice]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."GLN"')), '') [GLN]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CEO"')) [CEO]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TrueApiToken"')), '') [TrueApiToken]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Company';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Company.v] ON [Catalog.Company.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.deleted] ON [Catalog.Company.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.code.f] ON [Catalog.Company.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.description.f] ON [Catalog.Company.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.description] ON [Catalog.Company.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.code] ON [Catalog.Company.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.user] ON [Catalog.Company.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.v.company] ON [Catalog.Company.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Company.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Company.v] TO PUBLIC;
RAISERROR('Catalog.Company end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Company ------------------------------


------------------------------ BEGIN Catalog.Company.Group ------------------------------

RAISERROR('Catalog.Company.Group start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Company.Group.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Company.Group.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Company.Group.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullName"')), '') [FullName]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Company.Group';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Company.Group.v] ON [Catalog.Company.Group.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.deleted] ON [Catalog.Company.Group.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.code.f] ON [Catalog.Company.Group.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.description.f] ON [Catalog.Company.Group.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.description] ON [Catalog.Company.Group.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.code] ON [Catalog.Company.Group.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.user] ON [Catalog.Company.Group.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Company.Group.v.company] ON [Catalog.Company.Group.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Company.Group.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Company.Group.v] TO PUBLIC;
RAISERROR('Catalog.Company.Group end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Company.Group ------------------------------


------------------------------ BEGIN Catalog.Contract.Intercompany ------------------------------

RAISERROR('Catalog.Contract.Intercompany start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Contract.Intercompany.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Contract.Intercompany.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Contract.Intercompany.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."KorrCompany"')) [KorrCompany]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashFlow"')) [CashFlow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."notAccounting"')), 0) [notAccounting]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Contract.Intercompany';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Contract.Intercompany.v] ON [Catalog.Contract.Intercompany.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.deleted] ON [Catalog.Contract.Intercompany.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.code.f] ON [Catalog.Contract.Intercompany.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.description.f] ON [Catalog.Contract.Intercompany.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.description] ON [Catalog.Contract.Intercompany.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.code] ON [Catalog.Contract.Intercompany.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.user] ON [Catalog.Contract.Intercompany.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.Intercompany.v.company] ON [Catalog.Contract.Intercompany.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Contract.Intercompany.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Contract.Intercompany.v] TO PUBLIC;
RAISERROR('Catalog.Contract.Intercompany end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Contract.Intercompany ------------------------------


------------------------------ BEGIN Catalog.Counterpartie.BankAccount ------------------------------

RAISERROR('Catalog.Counterpartie.BankAccount start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Counterpartie.BankAccount.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Counterpartie.BankAccount.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Counterpartie.BankAccount.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank"')) [Bank]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Counterpartie.BankAccount';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v] ON [Catalog.Counterpartie.BankAccount.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.deleted] ON [Catalog.Counterpartie.BankAccount.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.code.f] ON [Catalog.Counterpartie.BankAccount.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.description.f] ON [Catalog.Counterpartie.BankAccount.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.description] ON [Catalog.Counterpartie.BankAccount.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.code] ON [Catalog.Counterpartie.BankAccount.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.user] ON [Catalog.Counterpartie.BankAccount.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.BankAccount.v.company] ON [Catalog.Counterpartie.BankAccount.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Counterpartie.BankAccount.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Counterpartie.BankAccount.v] TO PUBLIC;
RAISERROR('Catalog.Counterpartie.BankAccount end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Counterpartie.BankAccount ------------------------------


------------------------------ BEGIN Catalog.Country ------------------------------

RAISERROR('Catalog.Country start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Country.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Country.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Country.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Currency"')) [Currency]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Alpha2Code"')), '') [Alpha2Code]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PhoneCode"')), '') [PhoneCode]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."MobilePhoneMask"')), '') [MobilePhoneMask]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Language"')), '') [Language]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Country';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Country.v] ON [Catalog.Country.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.deleted] ON [Catalog.Country.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.code.f] ON [Catalog.Country.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.description.f] ON [Catalog.Country.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.description] ON [Catalog.Country.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.code] ON [Catalog.Country.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.user] ON [Catalog.Country.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Country.v.company] ON [Catalog.Country.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Country.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Country.v] TO PUBLIC;
RAISERROR('Catalog.Country end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Country ------------------------------


------------------------------ BEGIN Catalog.Currency ------------------------------

RAISERROR('Catalog.Currency start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Currency.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Currency.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Currency.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortName"')), '') [ShortName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."symbol"')), '') [symbol]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Currency';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Currency.v] ON [Catalog.Currency.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.deleted] ON [Catalog.Currency.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.code.f] ON [Catalog.Currency.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.description.f] ON [Catalog.Currency.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.description] ON [Catalog.Currency.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.code] ON [Catalog.Currency.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.user] ON [Catalog.Currency.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Currency.v.company] ON [Catalog.Currency.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Currency.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Currency.v] TO PUBLIC;
RAISERROR('Catalog.Currency end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Currency ------------------------------


------------------------------ BEGIN Catalog.Department ------------------------------

RAISERROR('Catalog.Department start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Department.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Department.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Department.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortName"')), '') [ShortName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessRegion"')) [BusinessRegion]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessCalendar"')) [BusinessCalendar]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsibilityCenter"')) [ResponsibilityCenter]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."OpeningDate"'),127) [OpeningDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."OpeningDatePlanned"'),127) [OpeningDatePlanned]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."OpeningDateBeforePurchase"'),127) [OpeningDateBeforePurchase]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."ClosingDate"'),127) [ClosingDate]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxOffice"')) [TaxOffice]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Brand"')) [Brand]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."kind"')) [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Mail"')), '') [Mail]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Phone"')), '') [Phone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Address"')), '') [Address]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressLegal"')), '') [AddressLegal]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Longitude"')), '') [Longitude]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Latitude"')), '') [Latitude]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AreaTotal"')), 0) [AreaTotal]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AreaTrade"')), 0) [AreaTrade]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Floor"')), 0) [Floor]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."IntegrationType"')), '') [IntegrationType]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."timeZone"')), '') [timeZone]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Department';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Department.v] ON [Catalog.Department.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.deleted] ON [Catalog.Department.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.code.f] ON [Catalog.Department.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.description.f] ON [Catalog.Department.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.description] ON [Catalog.Department.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.code] ON [Catalog.Department.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.user] ON [Catalog.Department.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.v.company] ON [Catalog.Department.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Department.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Department.v] TO PUBLIC;
RAISERROR('Catalog.Department end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Department ------------------------------


------------------------------ BEGIN Catalog.Department.Kind ------------------------------

RAISERROR('Catalog.Department.Kind start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Department.Kind.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Department.Kind.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Department.Kind.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Department.Kind';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Department.Kind.v] ON [Catalog.Department.Kind.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.deleted] ON [Catalog.Department.Kind.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.code.f] ON [Catalog.Department.Kind.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.description.f] ON [Catalog.Department.Kind.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.description] ON [Catalog.Department.Kind.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.code] ON [Catalog.Department.Kind.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.user] ON [Catalog.Department.Kind.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Kind.v.company] ON [Catalog.Department.Kind.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Department.Kind.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Department.Kind.v] TO PUBLIC;
RAISERROR('Catalog.Department.Kind end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Department.Kind ------------------------------


------------------------------ BEGIN Catalog.Department.StatusReason ------------------------------

RAISERROR('Catalog.Department.StatusReason start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Department.StatusReason.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Department.StatusReason.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Department.StatusReason.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Department.StatusReason';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Department.StatusReason.v] ON [Catalog.Department.StatusReason.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.deleted] ON [Catalog.Department.StatusReason.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.code.f] ON [Catalog.Department.StatusReason.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.description.f] ON [Catalog.Department.StatusReason.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.description] ON [Catalog.Department.StatusReason.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.code] ON [Catalog.Department.StatusReason.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.user] ON [Catalog.Department.StatusReason.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.StatusReason.v.company] ON [Catalog.Department.StatusReason.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Department.StatusReason.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Department.StatusReason.v] TO PUBLIC;
RAISERROR('Catalog.Department.StatusReason end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Department.StatusReason ------------------------------


------------------------------ BEGIN Catalog.Dynamic ------------------------------

RAISERROR('Catalog.Dynamic start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Dynamic.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Dynamic.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Dynamic.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Dynamic';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Dynamic.v] ON [Catalog.Dynamic.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.deleted] ON [Catalog.Dynamic.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.code.f] ON [Catalog.Dynamic.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.description.f] ON [Catalog.Dynamic.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.description] ON [Catalog.Dynamic.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.code] ON [Catalog.Dynamic.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.user] ON [Catalog.Dynamic.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Dynamic.v.company] ON [Catalog.Dynamic.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Dynamic.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Dynamic.v] TO PUBLIC;
RAISERROR('Catalog.Dynamic end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Dynamic ------------------------------


------------------------------ BEGIN Catalog.Expense ------------------------------

RAISERROR('Catalog.Expense start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Expense.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Expense.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Expense.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BudgetItem"')) [BudgetItem]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Assign"')), '') [Assign]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Expense';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Expense.v] ON [Catalog.Expense.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.deleted] ON [Catalog.Expense.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.code.f] ON [Catalog.Expense.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.description.f] ON [Catalog.Expense.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.description] ON [Catalog.Expense.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.code] ON [Catalog.Expense.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.user] ON [Catalog.Expense.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.v.company] ON [Catalog.Expense.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Expense.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Expense.v] TO PUBLIC;
RAISERROR('Catalog.Expense end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Expense ------------------------------


------------------------------ BEGIN Catalog.Expense.Analytics ------------------------------

RAISERROR('Catalog.Expense.Analytics start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Expense.Analytics.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Expense.Analytics.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Expense.Analytics.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BudgetItem"')) [BudgetItem]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Expense.Analytics';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Expense.Analytics.v] ON [Catalog.Expense.Analytics.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.deleted] ON [Catalog.Expense.Analytics.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.code.f] ON [Catalog.Expense.Analytics.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.description.f] ON [Catalog.Expense.Analytics.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.description] ON [Catalog.Expense.Analytics.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.code] ON [Catalog.Expense.Analytics.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.user] ON [Catalog.Expense.Analytics.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Expense.Analytics.v.company] ON [Catalog.Expense.Analytics.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Expense.Analytics.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Expense.Analytics.v] TO PUBLIC;
RAISERROR('Catalog.Expense.Analytics end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Expense.Analytics ------------------------------


------------------------------ BEGIN Catalog.GroupObjectsExploitation ------------------------------

RAISERROR('Catalog.GroupObjectsExploitation start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.GroupObjectsExploitation.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.GroupObjectsExploitation.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.GroupObjectsExploitation.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Method"')), '') [Method]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.GroupObjectsExploitation';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.GroupObjectsExploitation.v] ON [Catalog.GroupObjectsExploitation.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.deleted] ON [Catalog.GroupObjectsExploitation.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.code.f] ON [Catalog.GroupObjectsExploitation.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.description.f] ON [Catalog.GroupObjectsExploitation.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.description] ON [Catalog.GroupObjectsExploitation.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.code] ON [Catalog.GroupObjectsExploitation.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.user] ON [Catalog.GroupObjectsExploitation.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.GroupObjectsExploitation.v.company] ON [Catalog.GroupObjectsExploitation.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.GroupObjectsExploitation.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.GroupObjectsExploitation.v] TO PUBLIC;
RAISERROR('Catalog.GroupObjectsExploitation end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.GroupObjectsExploitation ------------------------------


------------------------------ BEGIN Catalog.Income ------------------------------

RAISERROR('Catalog.Income start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Income.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Income.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Income.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BudgetItem"')) [BudgetItem]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Assign"')), '') [Assign]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Income';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Income.v] ON [Catalog.Income.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.deleted] ON [Catalog.Income.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.code.f] ON [Catalog.Income.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.description.f] ON [Catalog.Income.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.description] ON [Catalog.Income.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.code] ON [Catalog.Income.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.user] ON [Catalog.Income.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Income.v.company] ON [Catalog.Income.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Income.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Income.v] TO PUBLIC;
RAISERROR('Catalog.Income end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Income ------------------------------


------------------------------ BEGIN Catalog.JobTitle.Category ------------------------------

RAISERROR('Catalog.JobTitle.Category start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.JobTitle.Category.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.JobTitle.Category.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.JobTitle.Category.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.JobTitle.Category';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.JobTitle.Category.v] ON [Catalog.JobTitle.Category.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.deleted] ON [Catalog.JobTitle.Category.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.code.f] ON [Catalog.JobTitle.Category.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.description.f] ON [Catalog.JobTitle.Category.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.description] ON [Catalog.JobTitle.Category.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.code] ON [Catalog.JobTitle.Category.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.user] ON [Catalog.JobTitle.Category.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Category.v.company] ON [Catalog.JobTitle.Category.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.JobTitle.Category.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.JobTitle.Category.v] TO PUBLIC;
RAISERROR('Catalog.JobTitle.Category end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.JobTitle.Category ------------------------------


------------------------------ BEGIN Catalog.LoanTypes ------------------------------

RAISERROR('Catalog.LoanTypes start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.LoanTypes.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.LoanTypes.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.LoanTypes.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Balance"')) [Balance]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.LoanTypes';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.LoanTypes.v] ON [Catalog.LoanTypes.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.deleted] ON [Catalog.LoanTypes.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.code.f] ON [Catalog.LoanTypes.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.description.f] ON [Catalog.LoanTypes.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.description] ON [Catalog.LoanTypes.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.code] ON [Catalog.LoanTypes.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.user] ON [Catalog.LoanTypes.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.LoanTypes.v.company] ON [Catalog.LoanTypes.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.LoanTypes.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.LoanTypes.v] TO PUBLIC;
RAISERROR('Catalog.LoanTypes end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.LoanTypes ------------------------------


------------------------------ BEGIN Catalog.Manager ------------------------------

RAISERROR('Catalog.Manager start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Manager.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Manager.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Manager.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullName"')), '') [FullName]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Gender"')), 0) [Gender]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."Birthday"'),127) [Birthday]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Manager';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Manager.v] ON [Catalog.Manager.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.deleted] ON [Catalog.Manager.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.code.f] ON [Catalog.Manager.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.description.f] ON [Catalog.Manager.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.description] ON [Catalog.Manager.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.code] ON [Catalog.Manager.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.user] ON [Catalog.Manager.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Manager.v.company] ON [Catalog.Manager.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Manager.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Manager.v] TO PUBLIC;
RAISERROR('Catalog.Manager end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Manager ------------------------------


------------------------------ BEGIN Catalog.ManufactureLocation ------------------------------

RAISERROR('Catalog.ManufactureLocation start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ManufactureLocation.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ManufactureLocation.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ManufactureLocation.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ManufactureLocation';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ManufactureLocation.v] ON [Catalog.ManufactureLocation.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.deleted] ON [Catalog.ManufactureLocation.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.code.f] ON [Catalog.ManufactureLocation.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.description.f] ON [Catalog.ManufactureLocation.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.description] ON [Catalog.ManufactureLocation.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.code] ON [Catalog.ManufactureLocation.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.user] ON [Catalog.ManufactureLocation.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ManufactureLocation.v.company] ON [Catalog.ManufactureLocation.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ManufactureLocation.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.ManufactureLocation.v] TO PUBLIC;
RAISERROR('Catalog.ManufactureLocation end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ManufactureLocation ------------------------------


------------------------------ BEGIN Catalog.Operation ------------------------------

RAISERROR('Catalog.Operation start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Operation.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Operation.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Operation.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."shortName"')), '') [shortName]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Configuration"')) [Configuration]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."script"')), '') [script]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."scriptAccounting"')), '') [scriptAccounting]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."module"')), '') [module]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isManagment"')), 0) [isManagment]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isAccounting"')), 0) [isAccounting]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Operation';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Operation.v] ON [Catalog.Operation.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.deleted] ON [Catalog.Operation.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.code.f] ON [Catalog.Operation.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.description.f] ON [Catalog.Operation.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.description] ON [Catalog.Operation.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.code] ON [Catalog.Operation.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.user] ON [Catalog.Operation.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.v.company] ON [Catalog.Operation.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Operation.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Operation.v] TO PUBLIC;
RAISERROR('Catalog.Operation end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Operation ------------------------------


------------------------------ BEGIN Catalog.Operation.Group ------------------------------

RAISERROR('Catalog.Operation.Group start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Operation.Group.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Operation.Group.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Operation.Group.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Prefix"')), '') [Prefix]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."menu"')), '') [menu]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."icon"')), '') [icon]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Operation.Group';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Operation.Group.v] ON [Catalog.Operation.Group.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.deleted] ON [Catalog.Operation.Group.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.code.f] ON [Catalog.Operation.Group.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.description.f] ON [Catalog.Operation.Group.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.description] ON [Catalog.Operation.Group.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.code] ON [Catalog.Operation.Group.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.user] ON [Catalog.Operation.Group.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Group.v.company] ON [Catalog.Operation.Group.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Operation.Group.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Operation.Group.v] TO PUBLIC;
RAISERROR('Catalog.Operation.Group end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Operation.Group ------------------------------


------------------------------ BEGIN Catalog.Operation.Type ------------------------------

RAISERROR('Catalog.Operation.Type start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Operation.Type.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Operation.Type.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Operation.Type.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PropType"')), '') [PropType]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Model"')) [Model]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."StoredIn"')), '') [StoredIn]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Operation.Type';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Operation.Type.v] ON [Catalog.Operation.Type.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.deleted] ON [Catalog.Operation.Type.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.code.f] ON [Catalog.Operation.Type.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.description.f] ON [Catalog.Operation.Type.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.description] ON [Catalog.Operation.Type.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.code] ON [Catalog.Operation.Type.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.user] ON [Catalog.Operation.Type.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Operation.Type.v.company] ON [Catalog.Operation.Type.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Operation.Type.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Operation.Type.v] TO PUBLIC;
RAISERROR('Catalog.Operation.Type end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Operation.Type ------------------------------


------------------------------ BEGIN Catalog.PlanningScenario ------------------------------

RAISERROR('Catalog.PlanningScenario start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.PlanningScenario.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.PlanningScenario.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.PlanningScenario.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.PlanningScenario';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.PlanningScenario.v] ON [Catalog.PlanningScenario.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.deleted] ON [Catalog.PlanningScenario.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.code.f] ON [Catalog.PlanningScenario.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.description.f] ON [Catalog.PlanningScenario.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.description] ON [Catalog.PlanningScenario.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.code] ON [Catalog.PlanningScenario.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.user] ON [Catalog.PlanningScenario.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PlanningScenario.v.company] ON [Catalog.PlanningScenario.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.PlanningScenario.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.PlanningScenario.v] TO PUBLIC;
RAISERROR('Catalog.PlanningScenario end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.PlanningScenario ------------------------------


------------------------------ BEGIN Catalog.PriceType ------------------------------

RAISERROR('Catalog.PriceType start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.PriceType.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.PriceType.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.PriceType.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."TaxInclude"')), 0) [TaxInclude]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Brand"')) [Brand]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.PriceType';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.PriceType.v] ON [Catalog.PriceType.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.deleted] ON [Catalog.PriceType.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.code.f] ON [Catalog.PriceType.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.description.f] ON [Catalog.PriceType.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.description] ON [Catalog.PriceType.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.code] ON [Catalog.PriceType.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.user] ON [Catalog.PriceType.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PriceType.v.company] ON [Catalog.PriceType.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.PriceType.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.PriceType.v] TO PUBLIC;
RAISERROR('Catalog.PriceType end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.PriceType ------------------------------


------------------------------ BEGIN Catalog.Product.Analytic ------------------------------

RAISERROR('Catalog.Product.Analytic start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Product.Analytic.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Product.Analytic.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Product.Analytic.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Note"')), '') [Note]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."SortOrder"')), 0) [SortOrder]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Product.Analytic';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Product.Analytic.v] ON [Catalog.Product.Analytic.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.deleted] ON [Catalog.Product.Analytic.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.code.f] ON [Catalog.Product.Analytic.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.description.f] ON [Catalog.Product.Analytic.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.description] ON [Catalog.Product.Analytic.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.code] ON [Catalog.Product.Analytic.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.user] ON [Catalog.Product.Analytic.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Analytic.v.company] ON [Catalog.Product.Analytic.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Product.Analytic.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Product.Analytic.v] TO PUBLIC;
RAISERROR('Catalog.Product.Analytic end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Product.Analytic ------------------------------


------------------------------ BEGIN Catalog.Product.Package ------------------------------

RAISERROR('Catalog.Product.Package start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Product.Package.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Product.Package.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Product.Package.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Product"')) [Product]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Qty"')), 0) [Qty]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Label"')), '') [Label]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Product.Package';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Product.Package.v] ON [Catalog.Product.Package.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.deleted] ON [Catalog.Product.Package.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.code.f] ON [Catalog.Product.Package.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.description.f] ON [Catalog.Product.Package.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.description] ON [Catalog.Product.Package.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.code] ON [Catalog.Product.Package.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.user] ON [Catalog.Product.Package.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.Package.v.company] ON [Catalog.Product.Package.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Product.Package.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Product.Package.v] TO PUBLIC;
RAISERROR('Catalog.Product.Package end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Product.Package ------------------------------


------------------------------ BEGIN Catalog.PromotionChannel ------------------------------

RAISERROR('Catalog.PromotionChannel start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.PromotionChannel.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.PromotionChannel.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.PromotionChannel.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.PromotionChannel';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.PromotionChannel.v] ON [Catalog.PromotionChannel.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.deleted] ON [Catalog.PromotionChannel.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.code.f] ON [Catalog.PromotionChannel.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.description.f] ON [Catalog.PromotionChannel.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.description] ON [Catalog.PromotionChannel.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.code] ON [Catalog.PromotionChannel.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.user] ON [Catalog.PromotionChannel.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.PromotionChannel.v.company] ON [Catalog.PromotionChannel.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.PromotionChannel.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.PromotionChannel.v] TO PUBLIC;
RAISERROR('Catalog.PromotionChannel end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.PromotionChannel ------------------------------


------------------------------ BEGIN Catalog.ResponsibilityCenter ------------------------------

RAISERROR('Catalog.ResponsibilityCenter start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ResponsibilityCenter.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ResponsibilityCenter.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ResponsibilityCenter.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsiblePerson"')) [ResponsiblePerson]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsiblePersonFinance"')) [ResponsiblePersonFinance]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Currency"')) [Currency]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ResponsibilityCenter';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ResponsibilityCenter.v] ON [Catalog.ResponsibilityCenter.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.deleted] ON [Catalog.ResponsibilityCenter.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.code.f] ON [Catalog.ResponsibilityCenter.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.description.f] ON [Catalog.ResponsibilityCenter.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.description] ON [Catalog.ResponsibilityCenter.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.code] ON [Catalog.ResponsibilityCenter.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.user] ON [Catalog.ResponsibilityCenter.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ResponsibilityCenter.v.company] ON [Catalog.ResponsibilityCenter.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ResponsibilityCenter.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.ResponsibilityCenter.v] TO PUBLIC;
RAISERROR('Catalog.ResponsibilityCenter end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ResponsibilityCenter ------------------------------


------------------------------ BEGIN Catalog.Role ------------------------------

RAISERROR('Catalog.Role start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Role.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Role.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Role.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Role';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Role.v] ON [Catalog.Role.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.deleted] ON [Catalog.Role.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.code.f] ON [Catalog.Role.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.description.f] ON [Catalog.Role.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.description] ON [Catalog.Role.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.code] ON [Catalog.Role.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.user] ON [Catalog.Role.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Role.v.company] ON [Catalog.Role.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Role.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Role.v] TO PUBLIC;
RAISERROR('Catalog.Role end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Role ------------------------------


------------------------------ BEGIN Catalog.Salary.Analytics ------------------------------

RAISERROR('Catalog.Salary.Analytics start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Salary.Analytics.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Salary.Analytics.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Salary.Analytics.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."SalaryKind"')), '') [SalaryKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Unit"')) [Unit]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Salary.Analytics';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Salary.Analytics.v] ON [Catalog.Salary.Analytics.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.deleted] ON [Catalog.Salary.Analytics.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.code.f] ON [Catalog.Salary.Analytics.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.description.f] ON [Catalog.Salary.Analytics.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.description] ON [Catalog.Salary.Analytics.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.code] ON [Catalog.Salary.Analytics.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.user] ON [Catalog.Salary.Analytics.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Salary.Analytics.v.company] ON [Catalog.Salary.Analytics.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Salary.Analytics.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Salary.Analytics.v] TO PUBLIC;
RAISERROR('Catalog.Salary.Analytics end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Salary.Analytics ------------------------------


------------------------------ BEGIN Catalog.SalaryProject ------------------------------

RAISERROR('Catalog.SalaryProject start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.SalaryProject.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.SalaryProject.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.SalaryProject.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."bank"')) [bank]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."OpenDate"'),127) [OpenDate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."BankBranch"')), '') [BankBranch]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."BankBranchOffice"')), '') [BankBranchOffice]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."BankAccount"')), '') [BankAccount]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.SalaryProject';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.SalaryProject.v] ON [Catalog.SalaryProject.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.deleted] ON [Catalog.SalaryProject.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.code.f] ON [Catalog.SalaryProject.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.description.f] ON [Catalog.SalaryProject.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.description] ON [Catalog.SalaryProject.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.code] ON [Catalog.SalaryProject.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.user] ON [Catalog.SalaryProject.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SalaryProject.v.company] ON [Catalog.SalaryProject.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.SalaryProject.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.SalaryProject.v] TO PUBLIC;
RAISERROR('Catalog.SalaryProject end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.SalaryProject ------------------------------


------------------------------ BEGIN Catalog.Scenario ------------------------------

RAISERROR('Catalog.Scenario start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Scenario.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Scenario.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Scenario.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Scenario';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Scenario.v] ON [Catalog.Scenario.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.deleted] ON [Catalog.Scenario.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.code.f] ON [Catalog.Scenario.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.description.f] ON [Catalog.Scenario.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.description] ON [Catalog.Scenario.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.code] ON [Catalog.Scenario.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.user] ON [Catalog.Scenario.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Scenario.v.company] ON [Catalog.Scenario.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Scenario.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Scenario.v] TO PUBLIC;
RAISERROR('Catalog.Scenario end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Scenario ------------------------------


------------------------------ BEGIN Catalog.StaffingTable ------------------------------

RAISERROR('Catalog.StaffingTable start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.StaffingTable.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.StaffingTable.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.StaffingTable.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."JobTitle"')) [JobTitle]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."DepartmentCompany"')) [DepartmentCompany]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Currency"')) [Currency]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."ActivationDate"'),127) [ActivationDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."CloseDate"'),127) [CloseDate]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Qty"')), 0) [Qty]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Cost"')), 0) [Cost]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.StaffingTable';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.StaffingTable.v] ON [Catalog.StaffingTable.v](id);
CREATE NONCLUSTERED INDEX [Catalog.StaffingTable.v.code.u] ON [Catalog.StaffingTable.v]([code]) INCLUDE([company],[description],[id]);
CREATE NONCLUSTERED INDEX [Catalog.StaffingTable.v.code.c] ON [Catalog.StaffingTable.v]([code]) INCLUDE([company]);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.deleted] ON [Catalog.StaffingTable.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.code.f] ON [Catalog.StaffingTable.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.description.f] ON [Catalog.StaffingTable.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.description] ON [Catalog.StaffingTable.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.code] ON [Catalog.StaffingTable.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.user] ON [Catalog.StaffingTable.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.StaffingTable.v.company] ON [Catalog.StaffingTable.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.StaffingTable.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.StaffingTable.v] TO PUBLIC;
RAISERROR('Catalog.StaffingTable end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.StaffingTable ------------------------------


------------------------------ BEGIN Catalog.Storehouse ------------------------------

RAISERROR('Catalog.Storehouse start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Storehouse.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Storehouse.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Storehouse.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Storehouse';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Storehouse.v] ON [Catalog.Storehouse.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.deleted] ON [Catalog.Storehouse.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.code.f] ON [Catalog.Storehouse.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.description.f] ON [Catalog.Storehouse.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.description] ON [Catalog.Storehouse.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.code] ON [Catalog.Storehouse.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.user] ON [Catalog.Storehouse.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Storehouse.v.company] ON [Catalog.Storehouse.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Storehouse.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Storehouse.v] TO PUBLIC;
RAISERROR('Catalog.Storehouse end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Storehouse ------------------------------


------------------------------ BEGIN Catalog.SubSystem ------------------------------

RAISERROR('Catalog.SubSystem start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.SubSystem.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.SubSystem.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.SubSystem.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."icon"')), '') [icon]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.SubSystem';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.SubSystem.v] ON [Catalog.SubSystem.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.deleted] ON [Catalog.SubSystem.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.code.f] ON [Catalog.SubSystem.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.description.f] ON [Catalog.SubSystem.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.description] ON [Catalog.SubSystem.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.code] ON [Catalog.SubSystem.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.user] ON [Catalog.SubSystem.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.SubSystem.v.company] ON [Catalog.SubSystem.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.SubSystem.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.SubSystem.v] TO PUBLIC;
RAISERROR('Catalog.SubSystem end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.SubSystem ------------------------------


------------------------------ BEGIN Catalog.TaxAssignmentCode ------------------------------

RAISERROR('Catalog.TaxAssignmentCode start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxAssignmentCode.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxAssignmentCode.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxAssignmentCode.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullDescription"')), '') [FullDescription]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxAssignmentCode';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxAssignmentCode.v] ON [Catalog.TaxAssignmentCode.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.deleted] ON [Catalog.TaxAssignmentCode.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.code.f] ON [Catalog.TaxAssignmentCode.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.description.f] ON [Catalog.TaxAssignmentCode.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.description] ON [Catalog.TaxAssignmentCode.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.code] ON [Catalog.TaxAssignmentCode.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.user] ON [Catalog.TaxAssignmentCode.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxAssignmentCode.v.company] ON [Catalog.TaxAssignmentCode.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxAssignmentCode.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxAssignmentCode.v] TO PUBLIC;
RAISERROR('Catalog.TaxAssignmentCode end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxAssignmentCode ------------------------------


------------------------------ BEGIN Catalog.TaxBasisPayment ------------------------------

RAISERROR('Catalog.TaxBasisPayment start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxBasisPayment.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxBasisPayment.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxBasisPayment.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxBasisPayment';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxBasisPayment.v] ON [Catalog.TaxBasisPayment.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.deleted] ON [Catalog.TaxBasisPayment.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.code.f] ON [Catalog.TaxBasisPayment.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.description.f] ON [Catalog.TaxBasisPayment.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.description] ON [Catalog.TaxBasisPayment.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.code] ON [Catalog.TaxBasisPayment.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.user] ON [Catalog.TaxBasisPayment.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxBasisPayment.v.company] ON [Catalog.TaxBasisPayment.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxBasisPayment.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxBasisPayment.v] TO PUBLIC;
RAISERROR('Catalog.TaxBasisPayment end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxBasisPayment ------------------------------


------------------------------ BEGIN Catalog.TaxOffice ------------------------------

RAISERROR('Catalog.TaxOffice start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxOffice.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxOffice.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxOffice.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullName"')), '') [FullName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code2"')), '') [Code2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code3"')), '') [Code3]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxOffice';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxOffice.v] ON [Catalog.TaxOffice.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.deleted] ON [Catalog.TaxOffice.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.code.f] ON [Catalog.TaxOffice.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.description.f] ON [Catalog.TaxOffice.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.description] ON [Catalog.TaxOffice.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.code] ON [Catalog.TaxOffice.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.user] ON [Catalog.TaxOffice.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxOffice.v.company] ON [Catalog.TaxOffice.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxOffice.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxOffice.v] TO PUBLIC;
RAISERROR('Catalog.TaxOffice end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxOffice ------------------------------


------------------------------ BEGIN Catalog.TaxPayerStatus ------------------------------

RAISERROR('Catalog.TaxPayerStatus start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxPayerStatus.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxPayerStatus.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxPayerStatus.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullDescription"')), '') [FullDescription]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxPayerStatus';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxPayerStatus.v] ON [Catalog.TaxPayerStatus.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.deleted] ON [Catalog.TaxPayerStatus.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.code.f] ON [Catalog.TaxPayerStatus.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.description.f] ON [Catalog.TaxPayerStatus.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.description] ON [Catalog.TaxPayerStatus.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.code] ON [Catalog.TaxPayerStatus.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.user] ON [Catalog.TaxPayerStatus.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPayerStatus.v.company] ON [Catalog.TaxPayerStatus.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxPayerStatus.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxPayerStatus.v] TO PUBLIC;
RAISERROR('Catalog.TaxPayerStatus end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxPayerStatus ------------------------------


------------------------------ BEGIN Catalog.TaxPaymentCode ------------------------------

RAISERROR('Catalog.TaxPaymentCode start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxPaymentCode.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxPaymentCode.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxPaymentCode.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullDescription"')), '') [FullDescription]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BalanceAnalytics"')) [BalanceAnalytics]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxPaymentCode';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxPaymentCode.v] ON [Catalog.TaxPaymentCode.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.deleted] ON [Catalog.TaxPaymentCode.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.code.f] ON [Catalog.TaxPaymentCode.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.description.f] ON [Catalog.TaxPaymentCode.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.description] ON [Catalog.TaxPaymentCode.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.code] ON [Catalog.TaxPaymentCode.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.user] ON [Catalog.TaxPaymentCode.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentCode.v.company] ON [Catalog.TaxPaymentCode.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxPaymentCode.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxPaymentCode.v] TO PUBLIC;
RAISERROR('Catalog.TaxPaymentCode end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxPaymentCode ------------------------------


------------------------------ BEGIN Catalog.TaxPaymentPeriod ------------------------------

RAISERROR('Catalog.TaxPaymentPeriod start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxPaymentPeriod.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxPaymentPeriod.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxPaymentPeriod.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxPaymentPeriod';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxPaymentPeriod.v] ON [Catalog.TaxPaymentPeriod.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.deleted] ON [Catalog.TaxPaymentPeriod.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.code.f] ON [Catalog.TaxPaymentPeriod.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.description.f] ON [Catalog.TaxPaymentPeriod.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.description] ON [Catalog.TaxPaymentPeriod.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.code] ON [Catalog.TaxPaymentPeriod.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.user] ON [Catalog.TaxPaymentPeriod.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxPaymentPeriod.v.company] ON [Catalog.TaxPaymentPeriod.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxPaymentPeriod.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxPaymentPeriod.v] TO PUBLIC;
RAISERROR('Catalog.TaxPaymentPeriod end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxPaymentPeriod ------------------------------


------------------------------ BEGIN Catalog.TaxRate ------------------------------

RAISERROR('Catalog.TaxRate start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.TaxRate.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.TaxRate.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.TaxRate.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Rate"')), 0) [Rate]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.TaxRate';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.TaxRate.v] ON [Catalog.TaxRate.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.deleted] ON [Catalog.TaxRate.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.code.f] ON [Catalog.TaxRate.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.description.f] ON [Catalog.TaxRate.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.description] ON [Catalog.TaxRate.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.code] ON [Catalog.TaxRate.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.user] ON [Catalog.TaxRate.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.TaxRate.v.company] ON [Catalog.TaxRate.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.TaxRate.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.TaxRate.v] TO PUBLIC;
RAISERROR('Catalog.TaxRate end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.TaxRate ------------------------------


------------------------------ BEGIN Catalog.Unit ------------------------------

RAISERROR('Catalog.Unit start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Unit.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Unit.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Unit.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BaseUnit"')) [BaseUnit]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Rate"')), 0) [Rate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Unit';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Unit.v] ON [Catalog.Unit.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.deleted] ON [Catalog.Unit.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.code.f] ON [Catalog.Unit.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.description.f] ON [Catalog.Unit.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.description] ON [Catalog.Unit.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.code] ON [Catalog.Unit.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.user] ON [Catalog.Unit.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Unit.v.company] ON [Catalog.Unit.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Unit.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Unit.v] TO PUBLIC;
RAISERROR('Catalog.Unit end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Unit ------------------------------


------------------------------ BEGIN Catalog.User ------------------------------

RAISERROR('Catalog.User start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.User.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.User.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.User.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isAdmin"')), 0) [isAdmin]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDisabled"')), 0) [isDisabled]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.User';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.User.v] ON [Catalog.User.v](id);
CREATE NONCLUSTERED INDEX [Catalog.User.v.code.u] ON [Catalog.User.v]([code]) INCLUDE([company],[description],[id]);
CREATE NONCLUSTERED INDEX [Catalog.User.v.code.c] ON [Catalog.User.v]([code]) INCLUDE([company]);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.deleted] ON [Catalog.User.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.code.f] ON [Catalog.User.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.description.f] ON [Catalog.User.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.description] ON [Catalog.User.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.code] ON [Catalog.User.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.user] ON [Catalog.User.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.User.v.company] ON [Catalog.User.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.User.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.User.v] TO PUBLIC;
RAISERROR('Catalog.User end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.User ------------------------------


------------------------------ BEGIN Document.CashRequest ------------------------------

RAISERROR('Document.CashRequest start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.CashRequest.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.CashRequest.t]
GO

CREATE OR ALTER VIEW dbo.[Document.CashRequest.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Operation"')), '') [Operation]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PaymentKind"')), '') [PaymentKind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."EnforcementProceedings"')), '') [EnforcementProceedings]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CashKind"')), '') [CashKind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PayRollKind"')), '') [PayRollKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashRecipient"')) [CashRecipient]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Contract"')) [Contract]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."PersonContract"')) [PersonContract]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ContractIntercompany"')) [ContractIntercompany]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashFlow"')) [CashFlow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SalaryProject"')) [SalaryProject]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Loan"')) [Loan]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashOrBank"')) [CashOrBank]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashRecipientBankAccount"')) [CashRecipientBankAccount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashOrBankIn"')) [CashOrBankIn]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."PayDay"'),127) [PayDay]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AmountPenalty"')), 0) [AmountPenalty]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."сurrency"')) [сurrency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ExpenseOrBalance"')) [ExpenseOrBalance]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ExpenseAnalytics"')) [ExpenseAnalytics]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SalaryAnalitics"')) [SalaryAnalitics]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SKU"')) [SKU]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxRate"')) [TaxRate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TaxKPP"')), '') [TaxKPP]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxPaymentCode"')) [TaxPaymentCode]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxAssignmentCode"')) [TaxAssignmentCode]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxPayerStatus"')) [TaxPayerStatus]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxBasisPayment"')) [TaxBasisPayment]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."TaxPaymentPeriod"')) [TaxPaymentPeriod]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TaxDocNumber"')), '') [TaxDocNumber]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."TaxDocDate"'),127) [TaxDocDate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TaxOfficeCode2"')), '') [TaxOfficeCode2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BalanceAnalytics"')) [BalanceAnalytics]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."workflowID"')), '') [workflowID]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."ManualInfo"')), 0) [ManualInfo]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."BudgetPayment"')), 0) [BudgetPayment]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."RelatedURL"')), '') [RelatedURL]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."tempCompanyParent"')) [tempCompanyParent]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."tempSalaryKind"')), '') [tempSalaryKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsiblePerson"')) [ResponsiblePerson]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AmountLoan"')), 0) [AmountLoan]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CurrencyLoan"')) [CurrencyLoan]
FROM dbo.[Documents]
WHERE [type] = N'Document.CashRequest';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.CashRequest.v] ON [Document.CashRequest.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.date] ON [Document.CashRequest.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.parent] ON [Document.CashRequest.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.deleted] ON [Document.CashRequest.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.code] ON [Document.CashRequest.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.user] ON [Document.CashRequest.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequest.v.company] ON [Document.CashRequest.v](company,id);
GO

GRANT SELECT ON dbo.[Document.CashRequest.v] TO jetti;
GRANT SELECT ON dbo.[Document.CashRequest.v] TO PUBLIC;
RAISERROR('Document.CashRequest end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.CashRequest ------------------------------


------------------------------ BEGIN Document.CashRequestRegistry ------------------------------

RAISERROR('Document.CashRequestRegistry start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.CashRequestRegistry.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.CashRequestRegistry.t]
GO

CREATE OR ALTER VIEW dbo.[Document.CashRequestRegistry.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Operation"')), '') [Operation]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CashKind"')), '') [CashKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashFlow"')) [CashFlow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessDirection"')) [BusinessDirection]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."сurrency"')) [сurrency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."BankUploadDate"'),127) [BankUploadDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."DocumentsCreationDate"'),127) [DocumentsCreationDate]
FROM dbo.[Documents]
WHERE [type] = N'Document.CashRequestRegistry';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.CashRequestRegistry.v] ON [Document.CashRequestRegistry.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.date] ON [Document.CashRequestRegistry.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.parent] ON [Document.CashRequestRegistry.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.deleted] ON [Document.CashRequestRegistry.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.code] ON [Document.CashRequestRegistry.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.user] ON [Document.CashRequestRegistry.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.CashRequestRegistry.v.company] ON [Document.CashRequestRegistry.v](company,id);
GO

GRANT SELECT ON dbo.[Document.CashRequestRegistry.v] TO jetti;
GRANT SELECT ON dbo.[Document.CashRequestRegistry.v] TO PUBLIC;
RAISERROR('Document.CashRequestRegistry end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.CashRequestRegistry ------------------------------


------------------------------ BEGIN Document.ExchangeRates ------------------------------

RAISERROR('Document.ExchangeRates start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.ExchangeRates.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.ExchangeRates.t]
GO

CREATE OR ALTER VIEW dbo.[Document.ExchangeRates.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
FROM dbo.[Documents]
WHERE [type] = N'Document.ExchangeRates';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.ExchangeRates.v] ON [Document.ExchangeRates.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.date] ON [Document.ExchangeRates.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.parent] ON [Document.ExchangeRates.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.deleted] ON [Document.ExchangeRates.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.code] ON [Document.ExchangeRates.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.user] ON [Document.ExchangeRates.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.ExchangeRates.v.company] ON [Document.ExchangeRates.v](company,id);
GO

GRANT SELECT ON dbo.[Document.ExchangeRates.v] TO jetti;
GRANT SELECT ON dbo.[Document.ExchangeRates.v] TO PUBLIC;
RAISERROR('Document.ExchangeRates end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.ExchangeRates ------------------------------


------------------------------ BEGIN Document.Invoice ------------------------------

RAISERROR('Document.Invoice start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.Invoice.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.Invoice.t]
GO

CREATE OR ALTER VIEW dbo.[Document.Invoice.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Storehouse"')) [Storehouse]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Customer"')) [Customer]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Status"')), '') [Status]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."PayDay"'),127) [PayDay]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Tax"')), 0) [Tax]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
FROM dbo.[Documents]
WHERE [type] = N'Document.Invoice';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.Invoice.v] ON [Document.Invoice.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.date] ON [Document.Invoice.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.parent] ON [Document.Invoice.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.deleted] ON [Document.Invoice.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.code] ON [Document.Invoice.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.user] ON [Document.Invoice.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Invoice.v.company] ON [Document.Invoice.v](company,id);
GO

GRANT SELECT ON dbo.[Document.Invoice.v] TO jetti;
GRANT SELECT ON dbo.[Document.Invoice.v] TO PUBLIC;
RAISERROR('Document.Invoice end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.Invoice ------------------------------


------------------------------ BEGIN Document.Operation ------------------------------

RAISERROR('Document.Operation start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.Operation.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.Operation.t]
GO

CREATE OR ALTER VIEW dbo.[Document.Operation.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."f1"')) [f1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."f2"')) [f2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."f3"')) [f3]
FROM dbo.[Documents]
WHERE [type] = N'Document.Operation';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.Operation.v] ON [Document.Operation.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.date] ON [Document.Operation.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.parent] ON [Document.Operation.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.deleted] ON [Document.Operation.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.code] ON [Document.Operation.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.user] ON [Document.Operation.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.company] ON [Document.Operation.v](company,id);
GO

GRANT SELECT ON dbo.[Document.Operation.v] TO jetti;
GRANT SELECT ON dbo.[Document.Operation.v] TO PUBLIC;
RAISERROR('Document.Operation end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.Operation ------------------------------


------------------------------ BEGIN Document.PriceList ------------------------------

RAISERROR('Document.PriceList start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.PriceList.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.PriceList.t]
GO

CREATE OR ALTER VIEW dbo.[Document.PriceList.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."PriceType"')) [PriceType]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."TaxInclude"')), 0) [TaxInclude]
FROM dbo.[Documents]
WHERE [type] = N'Document.PriceList';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.PriceList.v] ON [Document.PriceList.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.date] ON [Document.PriceList.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.parent] ON [Document.PriceList.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.deleted] ON [Document.PriceList.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.code] ON [Document.PriceList.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.user] ON [Document.PriceList.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.PriceList.v.company] ON [Document.PriceList.v](company,id);
GO

GRANT SELECT ON dbo.[Document.PriceList.v] TO jetti;
GRANT SELECT ON dbo.[Document.PriceList.v] TO PUBLIC;
RAISERROR('Document.PriceList end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.PriceList ------------------------------


------------------------------ BEGIN Document.UserSettings ------------------------------

RAISERROR('Document.UserSettings start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.UserSettings.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.UserSettings.t]
GO

CREATE OR ALTER VIEW dbo.[Document.UserSettings.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."UserOrGroup"')) [UserOrGroup]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."COMP"')), 0) [COMP]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."DEPT"')), 0) [DEPT]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."STOR"')), 0) [STOR]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."CASH"')), 0) [CASH]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."BANK"')), 0) [BANK]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."GROUP"')), 0) [GROUP]
FROM dbo.[Documents]
WHERE [type] = N'Document.UserSettings';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.UserSettings.v] ON [Document.UserSettings.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.date] ON [Document.UserSettings.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.parent] ON [Document.UserSettings.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.deleted] ON [Document.UserSettings.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.code] ON [Document.UserSettings.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.user] ON [Document.UserSettings.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.UserSettings.v.company] ON [Document.UserSettings.v](company,id);
GO

GRANT SELECT ON dbo.[Document.UserSettings.v] TO jetti;
GRANT SELECT ON dbo.[Document.UserSettings.v] TO PUBLIC;
RAISERROR('Document.UserSettings end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.UserSettings ------------------------------


------------------------------ BEGIN Document.WorkFlow ------------------------------

RAISERROR('Document.WorkFlow start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Document.WorkFlow.v]
GO

DROP TRIGGER IF EXISTS dbo.[Document.WorkFlow.t]
GO

CREATE OR ALTER VIEW dbo.[Document.WorkFlow.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Document"')) [Document]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
FROM dbo.[Documents]
WHERE [type] = N'Document.WorkFlow';
GO

CREATE UNIQUE CLUSTERED INDEX [Document.WorkFlow.v] ON [Document.WorkFlow.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.date] ON [Document.WorkFlow.v](date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.parent] ON [Document.WorkFlow.v](parent,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.deleted] ON [Document.WorkFlow.v](deleted,date,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.code] ON [Document.WorkFlow.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.user] ON [Document.WorkFlow.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.WorkFlow.v.company] ON [Document.WorkFlow.v](company,id);
GO

GRANT SELECT ON dbo.[Document.WorkFlow.v] TO jetti;
GRANT SELECT ON dbo.[Document.WorkFlow.v] TO PUBLIC;
RAISERROR('Document.WorkFlow end', 0 ,1) WITH NOWAIT;

------------------------------ END Document.WorkFlow ------------------------------

CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Amount] ON [Document.Operation.v](Amount,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group] ON [dbo].[Document.Operation.v]([Group],[date],[id]);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.user] ON [dbo].[Document.Operation.v]([user],[Group],[date],[id]);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Operation] ON [Document.Operation.v](Operation,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.currency] ON [Document.Operation.v](currency,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f1] ON [Document.Operation.v](f1,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f2] ON [Document.Operation.v](f2,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f3] ON [Document.Operation.v](f3,id);
CREATE NONCLUSTERED INDEX [Document.Operation.v.timestamp] ON [Document.Operation.v]([timestamp],[Operation]);

CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Amount.rls] ON [Document.Operation.v](company,Amount,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.rls] ON [dbo].[Document.Operation.v](company,[Group],[date],[id]);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.user.rls] ON [dbo].[Document.Operation.v](company,[user],[Group],[date],[id]);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Operation.rls] ON [Document.Operation.v](company,Operation,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.currency.rls] ON [Document.Operation.v](company,currency,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f1.rls] ON [Document.Operation.v](company,f1,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f2.rls] ON [Document.Operation.v](company,f2,id);
CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f3.rls] ON [Document.Operation.v](company,f3,id);

CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.CompanyGroup] ON [dbo].[Document.Operation.v]([company],[Group],[date],[id])INCLUDE([deleted])
