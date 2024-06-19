

------------------------------ BEGIN Catalog.Account ------------------------------

RAISERROR('Catalog.Account start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Account.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Account.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Account.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."descriptionEng"')), '') [descriptionEng]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPassive"')), 0) [isPassive]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isForex"')), 0) [isForex]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Account';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Account.v] ON [Catalog.Account.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.deleted] ON [Catalog.Account.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.code.f] ON [Catalog.Account.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.description.f] ON [Catalog.Account.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.description] ON [Catalog.Account.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.code] ON [Catalog.Account.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.user] ON [Catalog.Account.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Account.v.company] ON [Catalog.Account.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Account.v] TO jetti;
RAISERROR('Catalog.Account end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Account ------------------------------


------------------------------ BEGIN Catalog.AcquiringTerminal ------------------------------

RAISERROR('Catalog.AcquiringTerminal start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.AcquiringTerminal.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.AcquiringTerminal.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.AcquiringTerminal.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BankAccount"')) [BankAccount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Counterpartie"')) [Counterpartie]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isLocal"')), 0) [isLocal]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isSoftTerminal"')), 0) [isSoftTerminal]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."OwnerTerminal"')) [OwnerTerminal]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDisabled"')), 0) [isDisabled]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.AcquiringTerminal';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.AcquiringTerminal.v] ON [Catalog.AcquiringTerminal.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.deleted] ON [Catalog.AcquiringTerminal.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.code.f] ON [Catalog.AcquiringTerminal.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.description.f] ON [Catalog.AcquiringTerminal.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.description] ON [Catalog.AcquiringTerminal.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.code] ON [Catalog.AcquiringTerminal.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.user] ON [Catalog.AcquiringTerminal.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.AcquiringTerminal.v.company] ON [Catalog.AcquiringTerminal.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.AcquiringTerminal.v] TO jetti;
RAISERROR('Catalog.AcquiringTerminal end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.AcquiringTerminal ------------------------------


------------------------------ BEGIN Catalog.Advertising ------------------------------

RAISERROR('Catalog.Advertising start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Advertising.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Advertising.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Advertising.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."shortDescription"')), '') [shortDescription]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."fullDescription"')), '') [fullDescription]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."dateFrom"'),127) [dateFrom]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."dateTill"'),127) [dateTill]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."availableCron"')), '') [availableCron]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."slug"')), '') [slug]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."typeAction"')), '') [typeAction]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."valueAction"')), '') [valueAction]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."slugIndex"')), 0) [slugIndex]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."retailNetwork"')) [retailNetwork]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."hideWebBanner"')), 0) [hideWebBanner]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."hideMobileBanner"')), 0) [hideMobileBanner]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Advertising';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Advertising.v] ON [Catalog.Advertising.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.deleted] ON [Catalog.Advertising.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.code.f] ON [Catalog.Advertising.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.description.f] ON [Catalog.Advertising.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.description] ON [Catalog.Advertising.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.code] ON [Catalog.Advertising.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.user] ON [Catalog.Advertising.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Advertising.v.company] ON [Catalog.Advertising.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Advertising.v] TO jetti;
RAISERROR('Catalog.Advertising end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Advertising ------------------------------


------------------------------ BEGIN Catalog.Attachment ------------------------------

RAISERROR('Catalog.Attachment start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Attachment.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Attachment.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Attachment.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."AttachmentType"')) [AttachmentType]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Storage"')), '') [Storage]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Tags"')), '') [Tags]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FileSize"')), 0) [FileSize]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FileName"')), '') [FileName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."MIMEType"')), '') [MIMEType]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Hash"')), '') [Hash]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Attachment';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Attachment.v] ON [Catalog.Attachment.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.deleted] ON [Catalog.Attachment.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.code.f] ON [Catalog.Attachment.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.description.f] ON [Catalog.Attachment.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.description] ON [Catalog.Attachment.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.code] ON [Catalog.Attachment.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.user] ON [Catalog.Attachment.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Attachment.v.company] ON [Catalog.Attachment.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Attachment.v] TO jetti;
RAISERROR('Catalog.Attachment end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Attachment ------------------------------


------------------------------ BEGIN Catalog.BRMRules ------------------------------

RAISERROR('Catalog.BRMRules start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BRMRules.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BRMRules.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BRMRules.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."functionName"')), '') [functionName]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."weight"')), 0) [weight]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BRMRules';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BRMRules.v] ON [Catalog.BRMRules.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.deleted] ON [Catalog.BRMRules.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.code.f] ON [Catalog.BRMRules.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.description.f] ON [Catalog.BRMRules.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.description] ON [Catalog.BRMRules.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.code] ON [Catalog.BRMRules.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.user] ON [Catalog.BRMRules.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BRMRules.v.company] ON [Catalog.BRMRules.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BRMRules.v] TO jetti;
RAISERROR('Catalog.BRMRules end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BRMRules ------------------------------


------------------------------ BEGIN Catalog.BusinessRegion ------------------------------

RAISERROR('Catalog.BusinessRegion start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.BusinessRegion.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.BusinessRegion.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.BusinessRegion.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Population"')), 0) [Population]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDevelopmentRegion"')), 0) [isDevelopmentRegion]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isActive"')), 0) [isActive]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Longitude"')), '') [Longitude]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Latitude"')), '') [Latitude]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Slug"')), '') [Slug]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."GeoCodeName"')), '') [GeoCodeName]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."DstOffset"')), 0) [DstOffset]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."TimeOffset"')), 0) [TimeOffset]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TimeZoneId"')), '') [TimeZoneId]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."PriceType"')) [PriceType]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."GeocodeRadius"')), 0) [GeocodeRadius]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CallCenterPhone"')), '') [CallCenterPhone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."SalaryRateRegion"')), '') [SalaryRateRegion]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.BusinessRegion';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.BusinessRegion.v] ON [Catalog.BusinessRegion.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.deleted] ON [Catalog.BusinessRegion.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.code.f] ON [Catalog.BusinessRegion.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.description.f] ON [Catalog.BusinessRegion.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.description] ON [Catalog.BusinessRegion.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.code] ON [Catalog.BusinessRegion.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.user] ON [Catalog.BusinessRegion.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.BusinessRegion.v.company] ON [Catalog.BusinessRegion.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.BusinessRegion.v] TO jetti;
RAISERROR('Catalog.BusinessRegion end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.BusinessRegion ------------------------------


------------------------------ BEGIN Catalog.CashFlow ------------------------------

RAISERROR('Catalog.CashFlow start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.CashFlow.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.CashFlow.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.CashFlow.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionENG"')), '') [DescriptionENG]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessDirection"')) [BusinessDirection]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.CashFlow';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.CashFlow.v] ON [Catalog.CashFlow.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.deleted] ON [Catalog.CashFlow.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.code.f] ON [Catalog.CashFlow.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.description.f] ON [Catalog.CashFlow.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.description] ON [Catalog.CashFlow.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.code] ON [Catalog.CashFlow.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.user] ON [Catalog.CashFlow.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.CashFlow.v.company] ON [Catalog.CashFlow.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.CashFlow.v] TO jetti;
RAISERROR('Catalog.CashFlow end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.CashFlow ------------------------------


------------------------------ BEGIN Catalog.Contract ------------------------------

RAISERROR('Catalog.Contract start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Contract.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Contract.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Contract.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Indulgence"')), 0) [Indulgence]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessDirection"')) [BusinessDirection]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashFlow"')) [CashFlow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BankAccount"')) [BankAccount]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsiblePerson"')) [ResponsiblePerson]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."notAccounting"')), 0) [notAccounting]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."RoyaltyArrangements"')), '') [RoyaltyArrangements]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."RoyaltyDelayTo"'),127) [RoyaltyDelayTo]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PaymentKC"')), '') [PaymentKC]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."RoyaltyPercent"')), 0) [RoyaltyPercent]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PaymentOVM"')), '') [PaymentOVM]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PaymentOKK"')), '') [PaymentOKK]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PaymentKRO"')), '') [PaymentKRO]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."OtherServices"')), '') [OtherServices]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Contract';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Contract.v] ON [Catalog.Contract.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.deleted] ON [Catalog.Contract.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.code.f] ON [Catalog.Contract.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.description.f] ON [Catalog.Contract.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.description] ON [Catalog.Contract.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.code] ON [Catalog.Contract.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.user] ON [Catalog.Contract.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Contract.v.company] ON [Catalog.Contract.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Contract.v] TO jetti;
RAISERROR('Catalog.Contract end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Contract ------------------------------


------------------------------ BEGIN Catalog.Counterpartie ------------------------------

RAISERROR('Catalog.Counterpartie start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Counterpartie.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Counterpartie.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Counterpartie.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullName"')), '') [FullName]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Client"')), 0) [Client]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Supplier"')), 0) [Supplier]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isInternal"')), 0) [isInternal]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressShipping"')), '') [AddressShipping]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressBilling"')), '') [AddressBilling]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Phone"')), '') [Phone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code2"')), '') [Code2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code3"')), '') [Code3]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."BC"')), '') [BC]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."GLN"')), '') [GLN]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Mail"')), '') [Mail]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ParentCounterpartie"')) [ParentCounterpartie]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Counterpartie';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Counterpartie.v] ON [Catalog.Counterpartie.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.deleted] ON [Catalog.Counterpartie.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.code.f] ON [Catalog.Counterpartie.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.description.f] ON [Catalog.Counterpartie.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.description] ON [Catalog.Counterpartie.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.code] ON [Catalog.Counterpartie.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.user] ON [Catalog.Counterpartie.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Counterpartie.v.company] ON [Catalog.Counterpartie.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Counterpartie.v] TO jetti;
RAISERROR('Catalog.Counterpartie end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Counterpartie ------------------------------


------------------------------ BEGIN Catalog.Department.Company ------------------------------

RAISERROR('Catalog.Department.Company start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Department.Company.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Department.Company.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Department.Company.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortName"')), '') [ShortName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."SecurityGroup"')), '') [SecurityGroup]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."StaffingPositionManager"')) [StaffingPositionManager]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."StaffingPositionAssistant"')) [StaffingPositionAssistant]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Department.Company';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Department.Company.v] ON [Catalog.Department.Company.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.deleted] ON [Catalog.Department.Company.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.code.f] ON [Catalog.Department.Company.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.description.f] ON [Catalog.Department.Company.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.description] ON [Catalog.Department.Company.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.code] ON [Catalog.Department.Company.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.user] ON [Catalog.Department.Company.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Department.Company.v.company] ON [Catalog.Department.Company.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Department.Company.v] TO jetti;
RAISERROR('Catalog.Department.Company end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Department.Company ------------------------------


------------------------------ BEGIN Catalog.Employee ------------------------------

RAISERROR('Catalog.Employee start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Employee.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Employee.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Employee.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."InnerPhone"')), '') [InnerPhone]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Employee';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Employee.v] ON [Catalog.Employee.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.deleted] ON [Catalog.Employee.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.code.f] ON [Catalog.Employee.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.description.f] ON [Catalog.Employee.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.description] ON [Catalog.Employee.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.code] ON [Catalog.Employee.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.user] ON [Catalog.Employee.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Employee.v.company] ON [Catalog.Employee.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Employee.v] TO jetti;
RAISERROR('Catalog.Employee end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Employee ------------------------------


------------------------------ BEGIN Catalog.InvestorGroup ------------------------------

RAISERROR('Catalog.InvestorGroup start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.InvestorGroup.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.InvestorGroup.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.InvestorGroup.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."KindInvestorGroup"')) [KindInvestorGroup]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."NameAD"')), '') [NameAD]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Product"')) [Product]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsibilityCenter"')) [ResponsibilityCenter]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.InvestorGroup';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.InvestorGroup.v] ON [Catalog.InvestorGroup.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.deleted] ON [Catalog.InvestorGroup.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.code.f] ON [Catalog.InvestorGroup.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.description.f] ON [Catalog.InvestorGroup.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.description] ON [Catalog.InvestorGroup.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.code] ON [Catalog.InvestorGroup.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.user] ON [Catalog.InvestorGroup.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.InvestorGroup.v.company] ON [Catalog.InvestorGroup.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.InvestorGroup.v] TO jetti;
RAISERROR('Catalog.InvestorGroup end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.InvestorGroup ------------------------------


------------------------------ BEGIN Catalog.JobTitle ------------------------------

RAISERROR('Catalog.JobTitle start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.JobTitle.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.JobTitle.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.JobTitle.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Category"')) [Category]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."TO"')), 0) [TO]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."CO"')), 0) [CO]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."FunctionalStructure"')) [FunctionalStructure]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortName"')), '') [ShortName]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.JobTitle';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.JobTitle.v] ON [Catalog.JobTitle.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.deleted] ON [Catalog.JobTitle.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.code.f] ON [Catalog.JobTitle.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.description.f] ON [Catalog.JobTitle.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.description] ON [Catalog.JobTitle.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.code] ON [Catalog.JobTitle.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.user] ON [Catalog.JobTitle.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.v.company] ON [Catalog.JobTitle.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.JobTitle.v] TO jetti;
RAISERROR('Catalog.JobTitle end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.JobTitle ------------------------------


------------------------------ BEGIN Catalog.JobTitle.Functional ------------------------------

RAISERROR('Catalog.JobTitle.Functional start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.JobTitle.Functional.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.JobTitle.Functional.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.JobTitle.Functional.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."StaffingTableResponsible"')) [StaffingTableResponsible]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.JobTitle.Functional';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.JobTitle.Functional.v] ON [Catalog.JobTitle.Functional.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.deleted] ON [Catalog.JobTitle.Functional.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.code.f] ON [Catalog.JobTitle.Functional.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.description.f] ON [Catalog.JobTitle.Functional.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.description] ON [Catalog.JobTitle.Functional.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.code] ON [Catalog.JobTitle.Functional.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.user] ON [Catalog.JobTitle.Functional.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.JobTitle.Functional.v.company] ON [Catalog.JobTitle.Functional.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.JobTitle.Functional.v] TO jetti;
RAISERROR('Catalog.JobTitle.Functional end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.JobTitle.Functional ------------------------------


------------------------------ BEGIN Catalog.Loan ------------------------------

RAISERROR('Catalog.Loan start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Loan.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Loan.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Loan.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."InvestorGroup"')) [InvestorGroup]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."loanType"')) [loanType]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."PayDay"'),127) [PayDay]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."CloseDay"'),127) [CloseDay]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CashKind"')), '') [CashKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."OwnerBankAccount"')) [OwnerBankAccount]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."InterestRate"')), 0) [InterestRate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."InterestDeadline"'),127) [InterestDeadline]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AmountLoan"')), 0) [AmountLoan]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Lot"')) [Lot]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."LotQty"')), 0) [LotQty]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."LoanRepaymentProcedure"')) [LoanRepaymentProcedure]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."PayDeadline"'),127) [PayDeadline]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Loan';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Loan.v] ON [Catalog.Loan.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.deleted] ON [Catalog.Loan.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.code.f] ON [Catalog.Loan.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.description.f] ON [Catalog.Loan.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.description] ON [Catalog.Loan.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.code] ON [Catalog.Loan.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.user] ON [Catalog.Loan.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Loan.v.company] ON [Catalog.Loan.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Loan.v] TO jetti;
RAISERROR('Catalog.Loan end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Loan ------------------------------


------------------------------ BEGIN Catalog.ModifiersGroup ------------------------------

RAISERROR('Catalog.ModifiersGroup start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ModifiersGroup.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ModifiersGroup.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ModifiersGroup.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MinPosition"')), 0) [MinPosition]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxPosition"')), 0) [MaxPosition]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Multiselection"')), 0) [Multiselection]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ModifiersGroup';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ModifiersGroup.v] ON [Catalog.ModifiersGroup.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.deleted] ON [Catalog.ModifiersGroup.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.code.f] ON [Catalog.ModifiersGroup.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.description.f] ON [Catalog.ModifiersGroup.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.description] ON [Catalog.ModifiersGroup.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.code] ON [Catalog.ModifiersGroup.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.user] ON [Catalog.ModifiersGroup.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ModifiersGroup.v.company] ON [Catalog.ModifiersGroup.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ModifiersGroup.v] TO jetti;
RAISERROR('Catalog.ModifiersGroup end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ModifiersGroup ------------------------------


------------------------------ BEGIN Catalog.MoneyDocument ------------------------------

RAISERROR('Catalog.MoneyDocument start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.MoneyDocument.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.MoneyDocument.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.MoneyDocument.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
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
FROM dbo.[Documents]
WHERE [type] = N'Catalog.MoneyDocument';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.MoneyDocument.v] ON [Catalog.MoneyDocument.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.deleted] ON [Catalog.MoneyDocument.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.code.f] ON [Catalog.MoneyDocument.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.description.f] ON [Catalog.MoneyDocument.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.description] ON [Catalog.MoneyDocument.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.code] ON [Catalog.MoneyDocument.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.user] ON [Catalog.MoneyDocument.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.MoneyDocument.v.company] ON [Catalog.MoneyDocument.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.MoneyDocument.v] TO jetti;
RAISERROR('Catalog.MoneyDocument end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.MoneyDocument ------------------------------


------------------------------ BEGIN Catalog.ObjectsExploitation ------------------------------

RAISERROR('Catalog.ObjectsExploitation start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ObjectsExploitation.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ObjectsExploitation.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ObjectsExploitation.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."InventoryNumber"')), '') [InventoryNumber]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ObjectsExploitation';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ObjectsExploitation.v] ON [Catalog.ObjectsExploitation.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.deleted] ON [Catalog.ObjectsExploitation.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.code.f] ON [Catalog.ObjectsExploitation.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.description.f] ON [Catalog.ObjectsExploitation.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.description] ON [Catalog.ObjectsExploitation.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.code] ON [Catalog.ObjectsExploitation.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.user] ON [Catalog.ObjectsExploitation.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ObjectsExploitation.v.company] ON [Catalog.ObjectsExploitation.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ObjectsExploitation.v] TO jetti;
RAISERROR('Catalog.ObjectsExploitation end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ObjectsExploitation ------------------------------


------------------------------ BEGIN Catalog.OrderSource ------------------------------

RAISERROR('Catalog.OrderSource start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.OrderSource.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.OrderSource.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.OrderSource.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Kind"')), '') [Kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."SourceType"')), '') [SourceType]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Counterpartie"')) [Counterpartie]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."venusHubSource"')), '') [venusHubSource]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."ExportSaturation"')), 0) [ExportSaturation]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."ExportDeliveryZones"')), 0) [ExportDeliveryZones]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.OrderSource';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.OrderSource.v] ON [Catalog.OrderSource.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.deleted] ON [Catalog.OrderSource.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.code.f] ON [Catalog.OrderSource.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.description.f] ON [Catalog.OrderSource.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.description] ON [Catalog.OrderSource.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.code] ON [Catalog.OrderSource.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.user] ON [Catalog.OrderSource.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.OrderSource.v.company] ON [Catalog.OrderSource.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.OrderSource.v] TO jetti;
RAISERROR('Catalog.OrderSource end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.OrderSource ------------------------------


------------------------------ BEGIN Catalog.Person ------------------------------

RAISERROR('Catalog.Person start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Person.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Person.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Person.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ParentPerson"')) [ParentPerson]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Gender"')), '') [Gender]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FirstName"')), '') [FirstName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."LastName"')), '') [LastName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."MiddleName"')), '') [MiddleName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code1"')), '') [Code1]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Code2"')), '') [Code2]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Address"')), '') [Address]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AddressResidence"')), '') [AddressResidence]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."City"')), '') [City]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Phone"')), '') [Phone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PersonalPhone"')), '') [PersonalPhone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Email"')), '') [Email]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PersonalEmail"')), '') [PersonalEmail]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."Birthday"'),127) [Birthday]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EmploymentDate"'),127) [EmploymentDate]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."JobTitle"')) [JobTitle]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Profile"')), '') [Profile]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."DocumentType"')) [DocumentType]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DocumentCode"')), '') [DocumentCode]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DocumentNumber"')), '') [DocumentNumber]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."DocumentDate"'),127) [DocumentDate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DocumentAuthority"')), '') [DocumentAuthority]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AccountAD"')), '') [AccountAD]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."SMAccount"')), '') [SMAccount]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Pincode"')), '') [Pincode]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Fired"')), 0) [Fired]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."PayoutBlocked"')), 0) [PayoutBlocked]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."AccountEntraID"')), '') [AccountEntraID]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Person';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Person.v] ON [Catalog.Person.v](id);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.AccountAD.u] ON [Catalog.Person.v]([AccountAD]) INCLUDE([company],[description],[id]);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.SMAccount.u] ON [Catalog.Person.v]([SMAccount]) INCLUDE([company],[description],[id]);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.AccountEntraID.u] ON [Catalog.Person.v]([AccountEntraID]) INCLUDE([company],[description],[id]);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.AccountAD.c] ON [Catalog.Person.v]([AccountAD]) INCLUDE([company]);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.SMAccount.c] ON [Catalog.Person.v]([SMAccount]) INCLUDE([company]);
CREATE NONCLUSTERED INDEX [Catalog.Person.v.AccountEntraID.c] ON [Catalog.Person.v]([AccountEntraID]) INCLUDE([company]);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.deleted] ON [Catalog.Person.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.code.f] ON [Catalog.Person.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.description.f] ON [Catalog.Person.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.description] ON [Catalog.Person.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.code] ON [Catalog.Person.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.user] ON [Catalog.Person.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.v.company] ON [Catalog.Person.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Person.v] TO jetti;
RAISERROR('Catalog.Person end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Person ------------------------------


------------------------------ BEGIN Catalog.Person.BankAccount ------------------------------

RAISERROR('Catalog.Person.BankAccount start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Person.BankAccount.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Person.BankAccount.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Person.BankAccount.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank"')) [Bank]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SalaryProject"')) [SalaryProject]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."OpenDate"'),127) [OpenDate]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CardId"')), '') [CardId]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CardBank"')), '') [CardBank]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CryptoWalletId"')), '') [CryptoWalletId]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CryptoNetwork"')), '') [CryptoNetwork]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PersonExchangeId"')), '') [PersonExchangeId]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."PersonExchangeValue"')), '') [PersonExchangeValue]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CorporateBankAccount"')), '') [CorporateBankAccount]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CorporateBankCode"')), '') [CorporateBankCode]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Person.BankAccount';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Person.BankAccount.v] ON [Catalog.Person.BankAccount.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.deleted] ON [Catalog.Person.BankAccount.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.code.f] ON [Catalog.Person.BankAccount.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.description.f] ON [Catalog.Person.BankAccount.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.description] ON [Catalog.Person.BankAccount.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.code] ON [Catalog.Person.BankAccount.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.user] ON [Catalog.Person.BankAccount.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.BankAccount.v.company] ON [Catalog.Person.BankAccount.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Person.BankAccount.v] TO jetti;
RAISERROR('Catalog.Person.BankAccount end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Person.BankAccount ------------------------------


------------------------------ BEGIN Catalog.Person.Contract ------------------------------

RAISERROR('Catalog.Person.Contract start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Person.Contract.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Person.Contract.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Person.Contract.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."owner"')) [owner]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BankAccount"')) [BankAccount]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Kind"')), '') [Kind]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Person.Contract';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Person.Contract.v] ON [Catalog.Person.Contract.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.deleted] ON [Catalog.Person.Contract.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.code.f] ON [Catalog.Person.Contract.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.description.f] ON [Catalog.Person.Contract.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.description] ON [Catalog.Person.Contract.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.code] ON [Catalog.Person.Contract.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.user] ON [Catalog.Person.Contract.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Person.Contract.v.company] ON [Catalog.Person.Contract.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Person.Contract.v] TO jetti;
RAISERROR('Catalog.Person.Contract end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Person.Contract ------------------------------


------------------------------ BEGIN Catalog.Product ------------------------------

RAISERROR('Catalog.Product start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Product.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Product.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Product.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ProductKind"')) [ProductKind]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ProductCategory"')) [ProductCategory]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Specification"')) [Specification]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Brand"')) [Brand]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Unit"')) [Unit]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Expense"')) [Expense]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Analytics"')) [Analytics]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ProductReport"')) [ProductReport]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Settings"')) [Settings]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Purchased"')), 0) [Purchased]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortCode"')), '') [ShortCode]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DescriptionCustomer"')), '') [DescriptionCustomer]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ShortName"')), '') [ShortName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Tags"')), '') [Tags]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Weight"')), 0) [Weight]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Volume"')), 0) [Volume]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Calorie"')), 0) [Calorie]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Carbohydrates"')), 0) [Carbohydrates]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Fat"')), 0) [Fat]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Proteins"')), 0) [Proteins]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."CookingTime"')), 0) [CookingTime]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Composition"')), '') [Composition]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."CookingPlace"')), '') [CookingPlace]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Order"')), 0) [Order]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Barcode"')), '') [Barcode]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Eancode"')), '') [Eancode]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isVegan"')), 0) [isVegan]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isHot"')), 0) [isHot]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPromo"')), 0) [isPromo]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isAggregator"')), 0) [isAggregator]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isThermallabelPrinting"')), 0) [isThermallabelPrinting]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Slug"')), '') [Slug]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."InvoiceComposition"')), '') [InvoiceComposition]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isAdditions"')), 0) [isAdditions]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."SlugIndex"')), 0) [SlugIndex]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Product';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Product.v] ON [Catalog.Product.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.deleted] ON [Catalog.Product.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.code.f] ON [Catalog.Product.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.description.f] ON [Catalog.Product.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.description] ON [Catalog.Product.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.code] ON [Catalog.Product.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.user] ON [Catalog.Product.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Product.v.company] ON [Catalog.Product.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Product.v] TO jetti;
RAISERROR('Catalog.Product end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Product ------------------------------


------------------------------ BEGIN Catalog.ProductCategory ------------------------------

RAISERROR('Catalog.ProductCategory start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ProductCategory.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ProductCategory.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ProductCategory.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Order"')), 0) [Order]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Presentation"')), '') [Presentation]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDefault"')), 0) [isDefault]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDesktop"')), 0) [isDesktop]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isWeb"')), 0) [isWeb]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isMobile"')), 0) [isMobile]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Slug"')), '') [Slug]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."GroupProductCategory"')) [GroupProductCategory]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ProductCategory';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ProductCategory.v] ON [Catalog.ProductCategory.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.deleted] ON [Catalog.ProductCategory.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.code.f] ON [Catalog.ProductCategory.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.description.f] ON [Catalog.ProductCategory.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.description] ON [Catalog.ProductCategory.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.code] ON [Catalog.ProductCategory.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.user] ON [Catalog.ProductCategory.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductCategory.v.company] ON [Catalog.ProductCategory.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ProductCategory.v] TO jetti;
RAISERROR('Catalog.ProductCategory end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ProductCategory ------------------------------


------------------------------ BEGIN Catalog.ProductKind ------------------------------

RAISERROR('Catalog.ProductKind start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ProductKind.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ProductKind.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ProductKind.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."ProductType"')), '') [ProductType]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ShareType"')) [ShareType]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ProductKind';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ProductKind.v] ON [Catalog.ProductKind.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.deleted] ON [Catalog.ProductKind.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.code.f] ON [Catalog.ProductKind.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.description.f] ON [Catalog.ProductKind.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.description] ON [Catalog.ProductKind.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.code] ON [Catalog.ProductKind.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.user] ON [Catalog.ProductKind.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ProductKind.v.company] ON [Catalog.ProductKind.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ProductKind.v] TO jetti;
RAISERROR('Catalog.ProductKind end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ProductKind ------------------------------


------------------------------ BEGIN Catalog.ReasonTypes ------------------------------

RAISERROR('Catalog.ReasonTypes start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.ReasonTypes.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.ReasonTypes.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.ReasonTypes.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."WriteOff"')), 0) [WriteOff]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Expense"')) [Expense]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ExpenseAnalynic"')) [ExpenseAnalynic]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Kind"')), '') [Kind]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Destination"')), '') [Destination]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.ReasonTypes';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.ReasonTypes.v] ON [Catalog.ReasonTypes.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.deleted] ON [Catalog.ReasonTypes.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.code.f] ON [Catalog.ReasonTypes.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.description.f] ON [Catalog.ReasonTypes.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.description] ON [Catalog.ReasonTypes.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.code] ON [Catalog.ReasonTypes.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.user] ON [Catalog.ReasonTypes.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.ReasonTypes.v.company] ON [Catalog.ReasonTypes.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.ReasonTypes.v] TO jetti;
RAISERROR('Catalog.ReasonTypes end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.ReasonTypes ------------------------------


------------------------------ BEGIN Catalog.RetailClient ------------------------------

RAISERROR('Catalog.RetailClient start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.RetailClient.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.RetailClient.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.RetailClient.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Gender"')), '') [Gender]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isBlocked"')), 0) [isBlocked]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."CreateDate"'),127) [CreateDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."Birthday"'),127) [Birthday]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FirstName"')), '') [FirstName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."LastName"')), '') [LastName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."MiddleName"')), '') [MiddleName]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Phone"')), '') [Phone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Email"')), '') [Email]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessRegion"')) [BusinessRegion]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."SailplayId"')), '') [SailplayId]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Source"')), '') [Source]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Address"')), '') [Address]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.RetailClient';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.RetailClient.v] ON [Catalog.RetailClient.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.deleted] ON [Catalog.RetailClient.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.code.f] ON [Catalog.RetailClient.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.description.f] ON [Catalog.RetailClient.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.description] ON [Catalog.RetailClient.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.code] ON [Catalog.RetailClient.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.user] ON [Catalog.RetailClient.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailClient.v.company] ON [Catalog.RetailClient.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.RetailClient.v] TO jetti;
RAISERROR('Catalog.RetailClient end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.RetailClient ------------------------------


------------------------------ BEGIN Catalog.RetailNetwork ------------------------------

RAISERROR('Catalog.RetailNetwork start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.RetailNetwork.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.RetailNetwork.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.RetailNetwork.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."aboutCompanyUrl"')), '') [aboutCompanyUrl]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."appAvailable"')), 0) [appAvailable]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."BonusPercent"')), 0) [BonusPercent]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Brand"')) [Brand]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessRegion"')) [BusinessRegion]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Country"')) [Country]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Currency"')) [Currency]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."customerSupportPhone"')), '') [customerSupportPhone]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."DefaultMapService"')), '') [DefaultMapService]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDeleted"')), 0) [isDeleted]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."keyVaultURL"')), '') [keyVaultURL]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."maxTotalOrder"')), 0) [maxTotalOrder]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."PlaceHolder"')), '') [PlaceHolder]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."publicOfferUrl"')), '') [publicOfferUrl]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ServiceProduct"')) [ServiceProduct]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."smsGateway"')), '') [smsGateway]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."usePriceByAggregator"')), 0) [usePriceByAggregator]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."sailplayCredentials"')), '') [sailplayCredentials]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Slug"')), '') [Slug]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isCashRequestRecipientApprovingUsed"')), 0) [isCashRequestRecipientApprovingUsed]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isCashRequestCFRecipientApprovingUsed"')), 0) [isCashRequestCFRecipientApprovingUsed]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.RetailNetwork';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.RetailNetwork.v] ON [Catalog.RetailNetwork.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.deleted] ON [Catalog.RetailNetwork.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.code.f] ON [Catalog.RetailNetwork.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.description.f] ON [Catalog.RetailNetwork.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.description] ON [Catalog.RetailNetwork.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.code] ON [Catalog.RetailNetwork.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.user] ON [Catalog.RetailNetwork.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.RetailNetwork.v.company] ON [Catalog.RetailNetwork.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.RetailNetwork.v] TO jetti;
RAISERROR('Catalog.RetailNetwork end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.RetailNetwork ------------------------------


------------------------------ BEGIN Catalog.Specification ------------------------------

RAISERROR('Catalog.Specification start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Specification.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Specification.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Specification.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Brand"')) [Brand]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."MainProduct"')) [MainProduct]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."Status"')), '') [Status]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FullDescription"')), '') [FullDescription]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
, TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsiblePerson"')) [ResponsiblePerson]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
, ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."K2Tree"')), '') [K2Tree]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Specification';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Specification.v] ON [Catalog.Specification.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.deleted] ON [Catalog.Specification.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.code.f] ON [Catalog.Specification.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.description.f] ON [Catalog.Specification.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.description] ON [Catalog.Specification.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.code] ON [Catalog.Specification.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.user] ON [Catalog.Specification.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Specification.v.company] ON [Catalog.Specification.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Specification.v] TO jetti;
RAISERROR('Catalog.Specification end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Specification ------------------------------


------------------------------ BEGIN Catalog.UsersGroup ------------------------------

RAISERROR('Catalog.UsersGroup start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.UsersGroup.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.UsersGroup.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.UsersGroup.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."Checked"')), 0) [Checked]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."DepartmentCompany"')) [DepartmentCompany]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.UsersGroup';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.UsersGroup.v] ON [Catalog.UsersGroup.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.deleted] ON [Catalog.UsersGroup.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.code.f] ON [Catalog.UsersGroup.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.description.f] ON [Catalog.UsersGroup.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.description] ON [Catalog.UsersGroup.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.code] ON [Catalog.UsersGroup.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.user] ON [Catalog.UsersGroup.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.UsersGroup.v.company] ON [Catalog.UsersGroup.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.UsersGroup.v] TO jetti;
RAISERROR('Catalog.UsersGroup end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.UsersGroup ------------------------------


------------------------------ BEGIN Catalog.Vehicle ------------------------------

RAISERROR('Catalog.Vehicle start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Vehicle.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Vehicle.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Vehicle.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Carrier"')) [Carrier]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Model"')), '') [Model]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."RegNumber"')), '') [RegNumber]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."kind"')), '') [kind]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Carrying"')), 0) [Carrying]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Capacity"')), 0) [Capacity]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ModelTrailer"')), '') [ModelTrailer]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."RegNumberTrailer"')), '') [RegNumberTrailer]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Vehicle';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Vehicle.v] ON [Catalog.Vehicle.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.deleted] ON [Catalog.Vehicle.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.code.f] ON [Catalog.Vehicle.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.description.f] ON [Catalog.Vehicle.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.description] ON [Catalog.Vehicle.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.code] ON [Catalog.Vehicle.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.user] ON [Catalog.Vehicle.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Vehicle.v.company] ON [Catalog.Vehicle.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Vehicle.v] TO jetti;
RAISERROR('Catalog.Vehicle end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Vehicle ------------------------------

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
