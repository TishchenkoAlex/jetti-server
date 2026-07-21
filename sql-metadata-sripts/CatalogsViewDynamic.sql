CREATE OR ALTER VIEW[dbo].[Catalog.Documents] AS
    SELECT
    'https://x100-jetti.web.app/' + d.type + '/' + TRY_CONVERT(varchar(36), d.id) as link,
      d.id, d.date[date],
      d.description Presentation,
        d.info,
        d.type, CAST(JSON_VALUE(doc, N'$.DocReceived') as bit) DocReceived
    FROM dbo.[Documents] d
    GO
    GRANT SELECT ON[dbo].[Catalog.Documents] TO jetti;
    GO
      
------------------------------ BEGIN Catalog.Attachment ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Attachment] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Attachment", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([owner.v].description, '') [owner.value], d.[owner] [owner.id], [owner.v].type [owner.type]
        , ISNULL([AttachmentType.v].description, '') [AttachmentType.value], d.[AttachmentType] [AttachmentType.id], [AttachmentType.v].type [AttachmentType.type]
        , d.[Storage] [Storage]
        , d.[Tags] [Tags]
        , d.[FileSize] [FileSize]
        , d.[FileName] [FileName]
        , d.[MIMEType] [MIMEType]
        , d.[Hash] [Hash]
        , d.[VersionNumber] [VersionNumber]
      
        , ISNULL(l5.id, d.id) [Attachment.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Attachment.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Attachment.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Attachment.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Attachment.Level1.id]
        , ISNULL(l5.description, d.description) [Attachment.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Attachment.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Attachment.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Attachment.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Attachment.Level1]
      FROM [Catalog.Attachment.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Attachment.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Attachment.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Attachment.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Attachment.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Attachment.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Documents] [owner.v] ON [owner.v].id = d.[owner]
        LEFT JOIN dbo.[Catalog.Attachment.Type.v] [AttachmentType.v] WITH (NOEXPAND) ON [AttachmentType.v].id = d.[AttachmentType]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Attachment] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Attachment] TO PUBLIC;
GO

      
------------------------------ END Catalog.Attachment ------------------------------

      
      
------------------------------ BEGIN Catalog.BankAccount ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.BankAccount] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "BankAccount", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([Bank.v].description, '') [Bank.value], d.[Bank] [Bank.id], [Bank.v].type [Bank.type]
        , d.[isDefault] [isDefault]
      
        , ISNULL(l5.id, d.id) [BankAccount.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [BankAccount.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [BankAccount.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [BankAccount.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [BankAccount.Level1.id]
        , ISNULL(l5.description, d.description) [BankAccount.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [BankAccount.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [BankAccount.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [BankAccount.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [BankAccount.Level1]
      FROM [Catalog.BankAccount.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.BankAccount.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.BankAccount.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.BankAccount.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.BankAccount.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.BankAccount.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank.v] WITH (NOEXPAND) ON [Bank.v].id = d.[Bank]
    ;
GO
GRANT SELECT ON dbo.[Catalog.BankAccount] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.BankAccount] TO PUBLIC;
GO

      
------------------------------ END Catalog.BankAccount ------------------------------

      
      
------------------------------ BEGIN Catalog.Counterpartie ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Counterpartie] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Counterpartie", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[kind] [kind]
        , d.[FullName] [FullName]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Client] [Client]
        , d.[Supplier] [Supplier]
        , d.[isInternal] [isInternal]
        , d.[AddressShipping] [AddressShipping]
        , d.[AddressBilling] [AddressBilling]
        , d.[Phone] [Phone]
        , d.[Code1] [Code1]
        , d.[Code2] [Code2]
        , d.[Code3] [Code3]
        , d.[GLN] [GLN]
      
        , ISNULL(l5.id, d.id) [Counterpartie.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Counterpartie.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Counterpartie.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Counterpartie.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Counterpartie.Level1.id]
        , ISNULL(l5.description, d.description) [Counterpartie.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Counterpartie.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Counterpartie.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Counterpartie.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Counterpartie.Level1]
      FROM [Catalog.Counterpartie.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Counterpartie.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Counterpartie.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Counterpartie.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Counterpartie.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Counterpartie.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Counterpartie] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Counterpartie] TO PUBLIC;
GO

      
------------------------------ END Catalog.Counterpartie ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , d.[simpleString] [simpleString]
      
        , ISNULL(l5.id, d.id) [Newdynocat.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat.Level1]
      FROM [Catalog.Newdynocat.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat2 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat2] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat2", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat2.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat2.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat2.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat2.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat2.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat2.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat2.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat2.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat2.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat2.Level1]
      FROM [Catalog.Newdynocat2.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat2.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat2.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat2.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat2.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat2.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat2] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat2] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat2 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat3 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat3] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat3", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Str] [Str]
        , d.[numb] [numb]
        , ISNULL([Bank.v].description, '') [Bank.value], d.[Bank] [Bank.id], [Bank.v].type [Bank.type]
        , ISNULL([Bank2.v].description, '') [Bank2.value], d.[Bank2] [Bank2.id], [Bank2.v].type [Bank2.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat3.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat3.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat3.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat3.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat3.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat3.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat3.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat3.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat3.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat3.Level1]
      FROM [Catalog.Newdynocat3.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat3.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat3.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat3.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat3.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat3.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Expense.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank.v] WITH (NOEXPAND) ON [Bank.v].id = d.[Bank]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank2.v] WITH (NOEXPAND) ON [Bank2.v].id = d.[Bank2]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat3] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat3] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat3 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat4 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat4] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat4", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat4.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat4.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat4.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat4.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat4.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat4.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat4.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat4.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat4.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat4.Level1]
      FROM [Catalog.Newdynocat4.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat4.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat4.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat4.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat4.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat4.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat4] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat4] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat4 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat5 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat5] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat5", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Str] [Str]
        , d.[numb] [numb]
        , ISNULL([Bank.v].description, '') [Bank.value], d.[Bank] [Bank.id], [Bank.v].type [Bank.type]
        , ISNULL([Bank2.v].description, '') [Bank2.value], d.[Bank2] [Bank2.id], [Bank2.v].type [Bank2.type]
        , ISNULL([dyno6.v].description, '') [dyno6.value], d.[dyno6] [dyno6.id], [dyno6.v].type [dyno6.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat5.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat5.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat5.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat5.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat5.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat5.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat5.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat5.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat5.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat5.Level1]
      FROM [Catalog.Newdynocat5.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat5.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat5.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat5.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat5.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat5.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Expense.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank.v] WITH (NOEXPAND) ON [Bank.v].id = d.[Bank]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank2.v] WITH (NOEXPAND) ON [Bank2.v].id = d.[Bank2]
        LEFT JOIN dbo.[Catalog.Newdynocat6.v] [dyno6.v] WITH (NOEXPAND) ON [dyno6.v].id = d.[dyno6]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat5] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat5] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat5 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat6 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat6] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat6", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Str] [Str]
        , d.[numb] [numb]
        , ISNULL([Job.v].description, '') [Job.value], d.[Job] [Job.id], [Job.v].type [Job.type]
        , ISNULL([Bank2.v].description, '') [Bank2.value], d.[Bank2] [Bank2.id], [Bank2.v].type [Bank2.type]
        , ISNULL([Bank3.v].description, '') [Bank3.value], d.[Bank3] [Bank3.id], [Bank3.v].type [Bank3.type]
        , ISNULL([store.v].description, '') [store.value], d.[store] [store.id], [store.v].type [store.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat6.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat6.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat6.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat6.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat6.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat6.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat6.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat6.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat6.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat6.Level1]
      FROM [Catalog.Newdynocat6.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat6.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat6.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat6.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat6.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat6.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Expense.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.JobTitle.v] [Job.v] WITH (NOEXPAND) ON [Job.v].id = d.[Job]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank2.v] WITH (NOEXPAND) ON [Bank2.v].id = d.[Bank2]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank3.v] WITH (NOEXPAND) ON [Bank3.v].id = d.[Bank3]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [store.v] WITH (NOEXPAND) ON [store.v].id = d.[store]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat6] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat6] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat6 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat7 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat7] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat7", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Str] [Str]
        , d.[numb] [numb]
        , ISNULL([Job.v].description, '') [Job.value], d.[Job] [Job.id], [Job.v].type [Job.type]
        , ISNULL([Bank2.v].description, '') [Bank2.value], d.[Bank2] [Bank2.id], [Bank2.v].type [Bank2.type]
        , ISNULL([Bank3.v].description, '') [Bank3.value], d.[Bank3] [Bank3.id], [Bank3.v].type [Bank3.type]
        , ISNULL([store.v].description, '') [store.value], d.[store] [store.id], [store.v].type [store.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat7.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat7.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat7.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat7.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat7.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat7.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat7.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat7.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat7.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat7.Level1]
      FROM [Catalog.Newdynocat7.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat7.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat7.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat7.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat7.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat7.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Expense.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.JobTitle.v] [Job.v] WITH (NOEXPAND) ON [Job.v].id = d.[Job]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank2.v] WITH (NOEXPAND) ON [Bank2.v].id = d.[Bank2]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank3.v] WITH (NOEXPAND) ON [Bank3.v].id = d.[Bank3]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [store.v] WITH (NOEXPAND) ON [store.v].id = d.[store]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat7] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat7] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat7 ------------------------------

      
      
------------------------------ BEGIN Catalog.Newdynocat8 ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Newdynocat8] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Newdynocat8", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[FieldString] [FieldString]
        , d.[FieldNumber] [FieldNumber]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , ISNULL([dynocat1.v].description, '') [dynocat1.value], d.[dynocat1] [dynocat1.id], [dynocat1.v].type [dynocat1.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[Str] [Str]
        , d.[numb] [numb]
        , ISNULL([Job.v].description, '') [Job.value], d.[Job] [Job.id], [Job.v].type [Job.type]
        , ISNULL([Bank2.v].description, '') [Bank2.value], d.[Bank2] [Bank2.id], [Bank2.v].type [Bank2.type]
        , ISNULL([Bank3.v].description, '') [Bank3.value], d.[Bank3] [Bank3.id], [Bank3.v].type [Bank3.type]
        , ISNULL([store.v].description, '') [store.value], d.[store] [store.id], [store.v].type [store.type]
        , ISNULL([complex.v].description, '') [complex.value], d.[complex] [complex.id], [complex.v].type [complex.type]
        , ISNULL([complex2.v].description, '') [complex2.value], d.[complex2] [complex2.id], [complex2.v].type [complex2.type]
      
        , ISNULL(l5.id, d.id) [Newdynocat8.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Newdynocat8.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Newdynocat8.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Newdynocat8.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Newdynocat8.Level1.id]
        , ISNULL(l5.description, d.description) [Newdynocat8.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Newdynocat8.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Newdynocat8.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Newdynocat8.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Newdynocat8.Level1]
      FROM [Catalog.Newdynocat8.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Newdynocat8.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Newdynocat8.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Newdynocat8.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Newdynocat8.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Newdynocat8.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Expense.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
        LEFT JOIN dbo.[Catalog.Newdynocat.v] [dynocat1.v] WITH (NOEXPAND) ON [dynocat1.v].id = d.[dynocat1]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.JobTitle.v] [Job.v] WITH (NOEXPAND) ON [Job.v].id = d.[Job]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank2.v] WITH (NOEXPAND) ON [Bank2.v].id = d.[Bank2]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank3.v] WITH (NOEXPAND) ON [Bank3.v].id = d.[Bank3]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [store.v] WITH (NOEXPAND) ON [store.v].id = d.[store]
        LEFT JOIN dbo.[Documents] [complex.v] ON [complex.v].id = d.[complex]
        LEFT JOIN dbo.[Documents] [complex2.v] ON [complex2.v].id = d.[complex2]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat8] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Newdynocat8] TO PUBLIC;
GO

      
------------------------------ END Catalog.Newdynocat8 ------------------------------

      
      
------------------------------ BEGIN Catalog.Operation.Type ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Operation.Type] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "OperationType", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[OwnerType] [OwnerType]
        , ISNULL([Model.v].description, '') [Model.value], d.[Model] [Model.id], [Model.v].type [Model.type]
        , d.[StoredIn] [StoredIn]
        , ISNULL([Owner.v].description, '') [Owner.value], d.[Owner] [Owner.id], [Owner.v].type [Owner.type]
      
        , ISNULL(l5.id, d.id) [OperationType.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [OperationType.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [OperationType.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [OperationType.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [OperationType.Level1.id]
        , ISNULL(l5.description, d.description) [OperationType.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [OperationType.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [OperationType.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [OperationType.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [OperationType.Level1]
      FROM [Catalog.Operation.Type.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Operation.Type.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Operation.Type.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Operation.Type.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Operation.Type.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Operation.Type.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.v] [Model.v] WITH (NOEXPAND) ON [Model.v].id = d.[Model]
        LEFT JOIN dbo.[Documents] [Owner.v] ON [Owner.v].id = d.[Owner]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Operation.Type] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Operation.Type] TO PUBLIC;
GO

      
------------------------------ END Catalog.Operation.Type ------------------------------

      
      
------------------------------ BEGIN Catalog.Specification ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Specification] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Specification", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Brand.v].description, '') [Brand.value], d.[Brand] [Brand.id], [Brand.v].type [Brand.type]
        , ISNULL([MainProduct.v].description, '') [MainProduct.value], d.[MainProduct] [MainProduct.id], [MainProduct.v].type [MainProduct.type]
        , d.[Status] [Status]
        , d.[FullDescription] [FullDescription]
        , d.[StartDate] [StartDate]
        , d.[EndDate] [EndDate]
        , ISNULL([ResponsiblePerson.v].description, '') [ResponsiblePerson.value], d.[ResponsiblePerson] [ResponsiblePerson.id], [ResponsiblePerson.v].type [ResponsiblePerson.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , d.[K2Tree] [K2Tree]
      
        , ISNULL(l5.id, d.id) [Specification.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Specification.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Specification.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Specification.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Specification.Level1.id]
        , ISNULL(l5.description, d.description) [Specification.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Specification.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Specification.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Specification.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Specification.Level1]
      FROM [Catalog.Specification.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Specification.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Specification.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Specification.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Specification.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Specification.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Brand.v] [Brand.v] WITH (NOEXPAND) ON [Brand.v].id = d.[Brand]
        LEFT JOIN dbo.[Catalog.Product.v] [MainProduct.v] WITH (NOEXPAND) ON [MainProduct.v].id = d.[MainProduct]
        LEFT JOIN dbo.[Catalog.Person.v] [ResponsiblePerson.v] WITH (NOEXPAND) ON [ResponsiblePerson.v].id = d.[ResponsiblePerson]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Specification] TO jetti;
GO
GRANT SELECT ON dbo.[Catalog.Specification] TO PUBLIC;
GO

      
------------------------------ END Catalog.Specification ------------------------------

      