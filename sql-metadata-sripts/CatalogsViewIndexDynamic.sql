

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
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."VersionNumber"')), 0) [VersionNumber]
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
GRANT SELECT ON dbo.[Catalog.Attachment.v] TO PUBLIC;
RAISERROR('Catalog.Attachment end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Attachment ------------------------------


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
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."GLN"')), '') [GLN]
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
GRANT SELECT ON dbo.[Catalog.Counterpartie.v] TO PUBLIC;
RAISERROR('Catalog.Counterpartie end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Counterpartie ------------------------------


------------------------------ BEGIN Catalog.Newdynocat ------------------------------

RAISERROR('Catalog.Newdynocat start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."simpleString"')), '') [simpleString]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat.v] ON [Catalog.Newdynocat.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.deleted] ON [Catalog.Newdynocat.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.code.f] ON [Catalog.Newdynocat.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.description.f] ON [Catalog.Newdynocat.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.description] ON [Catalog.Newdynocat.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.code] ON [Catalog.Newdynocat.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.user] ON [Catalog.Newdynocat.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat.v.company] ON [Catalog.Newdynocat.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat ------------------------------


------------------------------ BEGIN Catalog.Newdynocat2 ------------------------------

RAISERROR('Catalog.Newdynocat2 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat2.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat2.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat2.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat2';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat2.v] ON [Catalog.Newdynocat2.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.deleted] ON [Catalog.Newdynocat2.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.code.f] ON [Catalog.Newdynocat2.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.description.f] ON [Catalog.Newdynocat2.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.description] ON [Catalog.Newdynocat2.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.code] ON [Catalog.Newdynocat2.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.user] ON [Catalog.Newdynocat2.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat2.v.company] ON [Catalog.Newdynocat2.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat2.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat2.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat2 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat2 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat3 ------------------------------

RAISERROR('Catalog.Newdynocat3 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat3.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat3.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat3.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Str"')), '') [Str]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."numb"')), 0) [numb]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank"')) [Bank]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank2"')) [Bank2]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat3';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat3.v] ON [Catalog.Newdynocat3.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.deleted] ON [Catalog.Newdynocat3.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.code.f] ON [Catalog.Newdynocat3.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.description.f] ON [Catalog.Newdynocat3.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.description] ON [Catalog.Newdynocat3.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.code] ON [Catalog.Newdynocat3.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.user] ON [Catalog.Newdynocat3.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat3.v.company] ON [Catalog.Newdynocat3.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat3.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat3.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat3 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat3 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat4 ------------------------------

RAISERROR('Catalog.Newdynocat4 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat4.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat4.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat4.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat4';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat4.v] ON [Catalog.Newdynocat4.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.deleted] ON [Catalog.Newdynocat4.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.code.f] ON [Catalog.Newdynocat4.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.description.f] ON [Catalog.Newdynocat4.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.description] ON [Catalog.Newdynocat4.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.code] ON [Catalog.Newdynocat4.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.user] ON [Catalog.Newdynocat4.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat4.v.company] ON [Catalog.Newdynocat4.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat4.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat4.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat4 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat4 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat5 ------------------------------

RAISERROR('Catalog.Newdynocat5 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat5.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat5.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat5.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Str"')), '') [Str]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."numb"')), 0) [numb]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank"')) [Bank]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank2"')) [Bank2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dyno6"')) [dyno6]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat5';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat5.v] ON [Catalog.Newdynocat5.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.deleted] ON [Catalog.Newdynocat5.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.code.f] ON [Catalog.Newdynocat5.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.description.f] ON [Catalog.Newdynocat5.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.description] ON [Catalog.Newdynocat5.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.code] ON [Catalog.Newdynocat5.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.user] ON [Catalog.Newdynocat5.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat5.v.company] ON [Catalog.Newdynocat5.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat5.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat5.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat5 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat5 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat6 ------------------------------

RAISERROR('Catalog.Newdynocat6 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat6.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat6.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat6.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Str"')), '') [Str]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."numb"')), 0) [numb]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Job"')) [Job]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank2"')) [Bank2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank3"')) [Bank3]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."store"')) [store]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat6';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat6.v] ON [Catalog.Newdynocat6.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.deleted] ON [Catalog.Newdynocat6.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.code.f] ON [Catalog.Newdynocat6.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.description.f] ON [Catalog.Newdynocat6.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.description] ON [Catalog.Newdynocat6.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.code] ON [Catalog.Newdynocat6.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.user] ON [Catalog.Newdynocat6.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat6.v.company] ON [Catalog.Newdynocat6.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat6.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat6.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat6 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat6 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat7 ------------------------------

RAISERROR('Catalog.Newdynocat7 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat7.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat7.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat7.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Str"')), '') [Str]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."numb"')), 0) [numb]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Job"')) [Job]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank2"')) [Bank2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank3"')) [Bank3]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."store"')) [store]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat7';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat7.v] ON [Catalog.Newdynocat7.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.deleted] ON [Catalog.Newdynocat7.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.code.f] ON [Catalog.Newdynocat7.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.description.f] ON [Catalog.Newdynocat7.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.description] ON [Catalog.Newdynocat7.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.code] ON [Catalog.Newdynocat7.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.user] ON [Catalog.Newdynocat7.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat7.v.company] ON [Catalog.Newdynocat7.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat7.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat7.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat7 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat7 ------------------------------


------------------------------ BEGIN Catalog.Newdynocat8 ------------------------------

RAISERROR('Catalog.Newdynocat8 start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Newdynocat8.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Newdynocat8.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat8.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."FieldString"')), '') [FieldString]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."FieldNumber"')), 0) [FieldNumber]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Person"')) [Person]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."dynocat1"')) [dynocat1]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Str"')), '') [Str]
, ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."numb"')), 0) [numb]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Job"')) [Job]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank2"')) [Bank2]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Bank3"')) [Bank3]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."store"')) [store]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."complex"')) [complex]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."complex2"')) [complex2]
FROM dbo.[Documents]
WHERE [type] = N'Catalog.Newdynocat8';
GO

CREATE UNIQUE CLUSTERED INDEX [Catalog.Newdynocat8.v] ON [Catalog.Newdynocat8.v](id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.deleted] ON [Catalog.Newdynocat8.v](deleted,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.code.f] ON [Catalog.Newdynocat8.v](parent,isfolder,code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.description.f] ON [Catalog.Newdynocat8.v](parent,isfolder,description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.description] ON [Catalog.Newdynocat8.v](description,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.code] ON [Catalog.Newdynocat8.v](code,id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.user] ON [Catalog.Newdynocat8.v]([user],id);
CREATE UNIQUE NONCLUSTERED INDEX [Catalog.Newdynocat8.v.company] ON [Catalog.Newdynocat8.v](company,id);
GO

GRANT SELECT ON dbo.[Catalog.Newdynocat8.v] TO jetti;
GRANT SELECT ON dbo.[Catalog.Newdynocat8.v] TO PUBLIC;
RAISERROR('Catalog.Newdynocat8 end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Newdynocat8 ------------------------------


------------------------------ BEGIN Catalog.Operation.Type ------------------------------

RAISERROR('Catalog.Operation.Type start', 0 ,1) WITH NOWAIT;
DROP TABLE IF EXISTS dbo.[Catalog.Operation.Type.v]
GO

DROP TRIGGER IF EXISTS dbo.[Catalog.Operation.Type.t]
GO

CREATE OR ALTER VIEW dbo.[Catalog.Operation.Type.v] WITH SCHEMABINDING AS
SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."OwnerType"')), '') [OwnerType]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Model"')) [Model]
, ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."StoredIn"')), '') [StoredIn]
, TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Owner"')) [Owner]
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
GRANT SELECT ON dbo.[Catalog.Specification.v] TO PUBLIC;
RAISERROR('Catalog.Specification end', 0 ,1) WITH NOWAIT;

------------------------------ END Catalog.Specification ------------------------------

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
