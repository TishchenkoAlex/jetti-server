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
      
------------------------------ BEGIN Catalog.Account ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Account] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Account", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[descriptionEng] [descriptionEng]
        , d.[isActive] [isActive]
        , d.[isPassive] [isPassive]
        , d.[isForex] [isForex]
      
        , ISNULL(l5.id, d.id) [Account.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Account.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Account.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Account.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Account.Level1.id]
        , ISNULL(l5.description, d.description) [Account.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Account.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Account.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Account.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Account.Level1]
      FROM [Catalog.Account.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Account.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Account.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Account.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Account.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Account.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Account] TO jetti;
GO

      
------------------------------ END Catalog.Account ------------------------------

      
      
------------------------------ BEGIN Catalog.AcquiringTerminal ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.AcquiringTerminal] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "AcquiringTerminal", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([BankAccount.v].description, '') [BankAccount.value], d.[BankAccount] [BankAccount.id], [BankAccount.v].type [BankAccount.type]
        , ISNULL([Counterpartie.v].description, '') [Counterpartie.value], d.[Counterpartie] [Counterpartie.id], [Counterpartie.v].type [Counterpartie.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[isActive] [isActive]
        , d.[isDefault] [isDefault]
        , d.[Code1] [Code1]
        , d.[isLocal] [isLocal]
      
        , ISNULL(l5.id, d.id) [AcquiringTerminal.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [AcquiringTerminal.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [AcquiringTerminal.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [AcquiringTerminal.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [AcquiringTerminal.Level1.id]
        , ISNULL(l5.description, d.description) [AcquiringTerminal.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [AcquiringTerminal.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [AcquiringTerminal.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [AcquiringTerminal.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [AcquiringTerminal.Level1]
      FROM [Catalog.AcquiringTerminal.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.AcquiringTerminal.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.AcquiringTerminal.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.AcquiringTerminal.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.AcquiringTerminal.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.AcquiringTerminal.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.BankAccount.v] [BankAccount.v] WITH (NOEXPAND) ON [BankAccount.v].id = d.[BankAccount]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Counterpartie.v] WITH (NOEXPAND) ON [Counterpartie.v].id = d.[Counterpartie]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
    ;
GO
GRANT SELECT ON dbo.[Catalog.AcquiringTerminal] TO jetti;
GO

      
------------------------------ END Catalog.AcquiringTerminal ------------------------------

      
      
------------------------------ BEGIN Catalog.Advertising ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Advertising] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Advertising", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[kind] [kind]
        , d.[shortDescription] [shortDescription]
        , d.[fullDescription] [fullDescription]
        , d.[isActive] [isActive]
        , d.[dateFrom] [dateFrom]
        , d.[dateTill] [dateTill]
        , d.[availableCron] [availableCron]
        , d.[slug] [slug]
        , d.[typeAction] [typeAction]
        , d.[valueAction] [valueAction]
        , d.[slugIndex] [slugIndex]
        , ISNULL([retailNetwork.v].description, '') [retailNetwork.value], d.[retailNetwork] [retailNetwork.id], [retailNetwork.v].type [retailNetwork.type]
        , d.[hideWebBanner] [hideWebBanner]
        , d.[hideMobileBanner] [hideMobileBanner]
      
        , ISNULL(l5.id, d.id) [Advertising.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Advertising.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Advertising.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Advertising.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Advertising.Level1.id]
        , ISNULL(l5.description, d.description) [Advertising.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Advertising.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Advertising.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Advertising.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Advertising.Level1]
      FROM [Catalog.Advertising.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Advertising.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Advertising.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Advertising.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Advertising.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Advertising.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [retailNetwork.v] WITH (NOEXPAND) ON [retailNetwork.v].id = d.[retailNetwork]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Advertising] TO jetti;
GO

      
------------------------------ END Catalog.Advertising ------------------------------

      
      
------------------------------ BEGIN Catalog.BRMRules ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.BRMRules] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "BRMRules", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[functionName] [functionName]
        , d.[weight] [weight]
      
        , ISNULL(l5.id, d.id) [BRMRules.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [BRMRules.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [BRMRules.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [BRMRules.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [BRMRules.Level1.id]
        , ISNULL(l5.description, d.description) [BRMRules.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [BRMRules.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [BRMRules.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [BRMRules.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [BRMRules.Level1]
      FROM [Catalog.BRMRules.v] d 
        LEFT JOIN [Catalog.BRMRules.v] l5  ON (l5.id = d.parent)
        LEFT JOIN [Catalog.BRMRules.v] l4  ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.BRMRules.v] l3  ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.BRMRules.v] l2  ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.BRMRules.v] l1  ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
    ;
GO
GRANT SELECT ON dbo.[Catalog.BRMRules] TO jetti;
GO

      
------------------------------ END Catalog.BRMRules ------------------------------

      
      
------------------------------ BEGIN Catalog.BusinessRegion ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.BusinessRegion] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "BusinessRegion", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[Population] [Population]
        , d.[isDevelopmentRegion] [isDevelopmentRegion]
        , d.[isActive] [isActive]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
        , d.[Longitude] [Longitude]
        , d.[Latitude] [Latitude]
        , d.[Slug] [Slug]
        , d.[GeoCodeName] [GeoCodeName]
        , d.[DstOffset] [DstOffset]
        , d.[TimeOffset] [TimeOffset]
        , d.[TimeZoneId] [TimeZoneId]
        , ISNULL([PriceType.v].description, '') [PriceType.value], d.[PriceType] [PriceType.id], [PriceType.v].type [PriceType.type]
        , d.[GeocodeRadius] [GeocodeRadius]
        , d.[CallCenterPhone] [CallCenterPhone]
        , d.[SalaryRateRegion] [SalaryRateRegion]
      
        , ISNULL(l5.id, d.id) [BusinessRegion.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [BusinessRegion.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [BusinessRegion.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [BusinessRegion.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [BusinessRegion.Level1.id]
        , ISNULL(l5.description, d.description) [BusinessRegion.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [BusinessRegion.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [BusinessRegion.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [BusinessRegion.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [BusinessRegion.Level1]
      FROM [Catalog.BusinessRegion.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.BusinessRegion.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.BusinessRegion.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.BusinessRegion.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.BusinessRegion.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.BusinessRegion.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
        LEFT JOIN dbo.[Catalog.PriceType.v] [PriceType.v] WITH (NOEXPAND) ON [PriceType.v].id = d.[PriceType]
    ;
GO
GRANT SELECT ON dbo.[Catalog.BusinessRegion] TO jetti;
GO

      
------------------------------ END Catalog.BusinessRegion ------------------------------

      
      
------------------------------ BEGIN Catalog.CashFlow ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.CashFlow] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "CashFlow", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[DescriptionENG] [DescriptionENG]
        , ISNULL([BusinessDirection.v].description, '') [BusinessDirection.value], d.[BusinessDirection] [BusinessDirection.id], [BusinessDirection.v].type [BusinessDirection.type]
      
        , ISNULL(l5.id, d.id) [CashFlow.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [CashFlow.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [CashFlow.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [CashFlow.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [CashFlow.Level1.id]
        , ISNULL(l5.description, d.description) [CashFlow.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [CashFlow.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [CashFlow.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [CashFlow.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [CashFlow.Level1]
      FROM [Catalog.CashFlow.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.CashFlow.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.CashFlow.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.CashFlow.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.CashFlow.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.CashFlow.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.BusinessDirection.v] [BusinessDirection.v] WITH (NOEXPAND) ON [BusinessDirection.v].id = d.[BusinessDirection]
    ;
GO
GRANT SELECT ON dbo.[Catalog.CashFlow] TO jetti;
GO

      
------------------------------ END Catalog.CashFlow ------------------------------

      
      
------------------------------ BEGIN Catalog.Contract ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Contract] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Contract", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([owner.v].description, '') [owner.value], d.[owner] [owner.id], [owner.v].type [owner.type]
        , d.[Status] [Status]
        , d.[kind] [kind]
        , d.[StartDate] [StartDate]
        , d.[EndDate] [EndDate]
        , d.[Indulgence] [Indulgence]
        , d.[Amount] [Amount]
        , ISNULL([BusinessDirection.v].description, '') [BusinessDirection.value], d.[BusinessDirection] [BusinessDirection.id], [BusinessDirection.v].type [BusinessDirection.type]
        , ISNULL([CashFlow.v].description, '') [CashFlow.value], d.[CashFlow] [CashFlow.id], [CashFlow.v].type [CashFlow.type]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([BankAccount.v].description, '') [BankAccount.value], d.[BankAccount] [BankAccount.id], [BankAccount.v].type [BankAccount.type]
        , ISNULL([Manager.v].description, '') [Manager.value], d.[Manager] [Manager.id], [Manager.v].type [Manager.type]
        , ISNULL([ResponsiblePerson.v].description, '') [ResponsiblePerson.value], d.[ResponsiblePerson] [ResponsiblePerson.id], [ResponsiblePerson.v].type [ResponsiblePerson.type]
        , d.[isDefault] [isDefault]
        , d.[notAccounting] [notAccounting]
        , d.[RoyaltyArrangements] [RoyaltyArrangements]
        , d.[RoyaltyDelayTo] [RoyaltyDelayTo]
        , d.[PaymentKC] [PaymentKC]
        , d.[RoyaltyPercent] [RoyaltyPercent]
        , d.[PaymentOVM] [PaymentOVM]
        , d.[PaymentOKK] [PaymentOKK]
        , d.[PaymentKRO] [PaymentKRO]
        , d.[OtherServices] [OtherServices]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
      
        , ISNULL(l5.id, d.id) [Contract.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Contract.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Contract.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Contract.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Contract.Level1.id]
        , ISNULL(l5.description, d.description) [Contract.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Contract.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Contract.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Contract.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Contract.Level1]
      FROM [Catalog.Contract.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Contract.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Contract.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Contract.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Contract.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Contract.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [owner.v] WITH (NOEXPAND) ON [owner.v].id = d.[owner]
        LEFT JOIN dbo.[Catalog.BusinessDirection.v] [BusinessDirection.v] WITH (NOEXPAND) ON [BusinessDirection.v].id = d.[BusinessDirection]
        LEFT JOIN dbo.[Catalog.CashFlow.v] [CashFlow.v] WITH (NOEXPAND) ON [CashFlow.v].id = d.[CashFlow]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Counterpartie.BankAccount.v] [BankAccount.v] WITH (NOEXPAND) ON [BankAccount.v].id = d.[BankAccount]
        LEFT JOIN dbo.[Catalog.Manager.v] [Manager.v] WITH (NOEXPAND) ON [Manager.v].id = d.[Manager]
        LEFT JOIN dbo.[Catalog.Person.v] [ResponsiblePerson.v] WITH (NOEXPAND) ON [ResponsiblePerson.v].id = d.[ResponsiblePerson]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Contract] TO jetti;
GO

      
------------------------------ END Catalog.Contract ------------------------------

      
      
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
        , d.[BC] [BC]
        , d.[GLN] [GLN]
        , ISNULL([Manager.v].description, '') [Manager.value], d.[Manager] [Manager.id], [Manager.v].type [Manager.type]
        , d.[Mail] [Mail]
        , ISNULL([ParentCounterpartie.v].description, '') [ParentCounterpartie.value], d.[ParentCounterpartie] [ParentCounterpartie.id], [ParentCounterpartie.v].type [ParentCounterpartie.type]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
      
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
        LEFT JOIN dbo.[Catalog.User.v] [Manager.v] WITH (NOEXPAND) ON [Manager.v].id = d.[Manager]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [ParentCounterpartie.v] WITH (NOEXPAND) ON [ParentCounterpartie.v].id = d.[ParentCounterpartie]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Counterpartie] TO jetti;
GO

      
------------------------------ END Catalog.Counterpartie ------------------------------

      
      
------------------------------ BEGIN Catalog.Department.Company ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Department.Company] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "DepartmentCompany", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[kind] [kind]
        , d.[ShortName] [ShortName]
        , d.[SecurityGroup] [SecurityGroup]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([StaffingPositionManager.v].description, '') [StaffingPositionManager.value], d.[StaffingPositionManager] [StaffingPositionManager.id], [StaffingPositionManager.v].type [StaffingPositionManager.type]
        , ISNULL([StaffingPositionAssistant.v].description, '') [StaffingPositionAssistant.value], d.[StaffingPositionAssistant] [StaffingPositionAssistant.id], [StaffingPositionAssistant.v].type [StaffingPositionAssistant.type]
      
        , ISNULL(l5.id, d.id) [DepartmentCompany.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [DepartmentCompany.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [DepartmentCompany.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [DepartmentCompany.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [DepartmentCompany.Level1.id]
        , ISNULL(l5.description, d.description) [DepartmentCompany.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [DepartmentCompany.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [DepartmentCompany.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [DepartmentCompany.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [DepartmentCompany.Level1]
      FROM [Catalog.Department.Company.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Department.Company.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Department.Company.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Department.Company.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Department.Company.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Department.Company.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.StaffingTable.v] [StaffingPositionManager.v] WITH (NOEXPAND) ON [StaffingPositionManager.v].id = d.[StaffingPositionManager]
        LEFT JOIN dbo.[Catalog.StaffingTable.v] [StaffingPositionAssistant.v] WITH (NOEXPAND) ON [StaffingPositionAssistant.v].id = d.[StaffingPositionAssistant]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Department.Company] TO jetti;
GO

      
------------------------------ END Catalog.Department.Company ------------------------------

      
      
------------------------------ BEGIN Catalog.Employee ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Employee] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Employee", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Person.v].description, '') [Person.value], d.[Person] [Person.id], [Person.v].type [Person.type]
        , d.[InnerPhone] [InnerPhone]
      
        , ISNULL(l5.id, d.id) [Employee.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Employee.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Employee.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Employee.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Employee.Level1.id]
        , ISNULL(l5.description, d.description) [Employee.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Employee.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Employee.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Employee.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Employee.Level1]
      FROM [Catalog.Employee.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Employee.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Employee.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Employee.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Employee.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Employee.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [Person.v] WITH (NOEXPAND) ON [Person.v].id = d.[Person]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Employee] TO jetti;
GO

      
------------------------------ END Catalog.Employee ------------------------------

      
      
------------------------------ BEGIN Catalog.InvestorGroup ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.InvestorGroup] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "InvestorGroup", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([KindInvestorGroup.v].description, '') [KindInvestorGroup.value], d.[KindInvestorGroup] [KindInvestorGroup.id], [KindInvestorGroup.v].type [KindInvestorGroup.type]
        , d.[NameAD] [NameAD]
        , ISNULL([Product.v].description, '') [Product.value], d.[Product] [Product.id], [Product.v].type [Product.type]
      
        , ISNULL(l5.id, d.id) [InvestorGroup.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [InvestorGroup.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [InvestorGroup.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [InvestorGroup.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [InvestorGroup.Level1.id]
        , ISNULL(l5.description, d.description) [InvestorGroup.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [InvestorGroup.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [InvestorGroup.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [InvestorGroup.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [InvestorGroup.Level1]
      FROM [Catalog.InvestorGroup.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.InvestorGroup.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.InvestorGroup.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.InvestorGroup.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.InvestorGroup.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.InvestorGroup.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Type.v] [KindInvestorGroup.v] WITH (NOEXPAND) ON [KindInvestorGroup.v].id = d.[KindInvestorGroup]
        LEFT JOIN dbo.[Catalog.Product.v] [Product.v] WITH (NOEXPAND) ON [Product.v].id = d.[Product]
    ;
GO
GRANT SELECT ON dbo.[Catalog.InvestorGroup] TO jetti;
GO

      
------------------------------ END Catalog.InvestorGroup ------------------------------

      
      
------------------------------ BEGIN Catalog.JobTitle ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.JobTitle] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "JobTitle", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Category.v].description, '') [Category.value], d.[Category] [Category.id], [Category.v].type [Category.type]
        , d.[TO] [TO]
        , d.[CO] [CO]
        , ISNULL([FunctionalStructure.v].description, '') [FunctionalStructure.value], d.[FunctionalStructure] [FunctionalStructure.id], [FunctionalStructure.v].type [FunctionalStructure.type]
        , d.[ShortName] [ShortName]
      
        , ISNULL(l5.id, d.id) [JobTitle.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [JobTitle.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [JobTitle.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [JobTitle.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [JobTitle.Level1.id]
        , ISNULL(l5.description, d.description) [JobTitle.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [JobTitle.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [JobTitle.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [JobTitle.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [JobTitle.Level1]
      FROM [Catalog.JobTitle.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.JobTitle.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.JobTitle.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.JobTitle.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.JobTitle.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.JobTitle.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.JobTitle.Category.v] [Category.v] WITH (NOEXPAND) ON [Category.v].id = d.[Category]
        LEFT JOIN dbo.[Catalog.JobTitle.Functional.v] [FunctionalStructure.v] WITH (NOEXPAND) ON [FunctionalStructure.v].id = d.[FunctionalStructure]
    ;
GO
GRANT SELECT ON dbo.[Catalog.JobTitle] TO jetti;
GO

      
------------------------------ END Catalog.JobTitle ------------------------------

      
      
------------------------------ BEGIN Catalog.JobTitle.Functional ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.JobTitle.Functional] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "JobTitleFunctional", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([StaffingTableResponsible.v].description, '') [StaffingTableResponsible.value], d.[StaffingTableResponsible] [StaffingTableResponsible.id], [StaffingTableResponsible.v].type [StaffingTableResponsible.type]
      
        , ISNULL(l5.id, d.id) [JobTitleFunctional.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [JobTitleFunctional.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [JobTitleFunctional.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [JobTitleFunctional.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [JobTitleFunctional.Level1.id]
        , ISNULL(l5.description, d.description) [JobTitleFunctional.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [JobTitleFunctional.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [JobTitleFunctional.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [JobTitleFunctional.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [JobTitleFunctional.Level1]
      FROM [Catalog.JobTitle.Functional.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.JobTitle.Functional.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.JobTitle.Functional.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.JobTitle.Functional.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.JobTitle.Functional.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.JobTitle.Functional.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.StaffingTable.v] [StaffingTableResponsible.v] WITH (NOEXPAND) ON [StaffingTableResponsible.v].id = d.[StaffingTableResponsible]
    ;
GO
GRANT SELECT ON dbo.[Catalog.JobTitle.Functional] TO jetti;
GO

      
------------------------------ END Catalog.JobTitle.Functional ------------------------------

      
      
------------------------------ BEGIN Catalog.Loan ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Loan] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Loan", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[PayDay] [PayDay]
        , d.[CloseDay] [CloseDay]
        , ISNULL([owner.v].description, '') [owner.value], d.[owner] [owner.id], [owner.v].type [owner.type]
        , ISNULL([OwnerBankAccount.v].description, '') [OwnerBankAccount.value], d.[OwnerBankAccount] [OwnerBankAccount.id], [OwnerBankAccount.v].type [OwnerBankAccount.type]
        , d.[CashKind] [CashKind]
        , d.[kind] [kind]
        , d.[Status] [Status]
        , ISNULL([InvestorGroup.v].description, '') [InvestorGroup.value], d.[InvestorGroup] [InvestorGroup.id], [InvestorGroup.v].type [InvestorGroup.type]
        , d.[InterestRate] [InterestRate]
        , d.[InterestDeadline] [InterestDeadline]
        , ISNULL([loanType.v].description, '') [loanType.value], d.[loanType] [loanType.id], [loanType.v].type [loanType.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[AmountLoan] [AmountLoan]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
        , ISNULL([Lot.v].description, '') [Lot.value], d.[Lot] [Lot.id], [Lot.v].type [Lot.type]
        , d.[LotQty] [LotQty]
        , ISNULL([LoanRepaymentProcedure.v].description, '') [LoanRepaymentProcedure.value], d.[LoanRepaymentProcedure] [LoanRepaymentProcedure.id], [LoanRepaymentProcedure.v].type [LoanRepaymentProcedure.type]
        , d.[PayDeadline] [PayDeadline]
      
        , ISNULL(l5.id, d.id) [Loan.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Loan.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Loan.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Loan.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Loan.Level1.id]
        , ISNULL(l5.description, d.description) [Loan.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Loan.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Loan.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Loan.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Loan.Level1]
      FROM [Catalog.Loan.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Loan.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Loan.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Loan.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Loan.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Loan.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Documents] [owner.v] ON [owner.v].id = d.[owner]
        LEFT JOIN dbo.[Catalog.Counterpartie.BankAccount.v] [OwnerBankAccount.v] WITH (NOEXPAND) ON [OwnerBankAccount.v].id = d.[OwnerBankAccount]
        LEFT JOIN dbo.[Catalog.InvestorGroup.v] [InvestorGroup.v] WITH (NOEXPAND) ON [InvestorGroup.v].id = d.[InvestorGroup]
        LEFT JOIN dbo.[Catalog.LoanTypes.v] [loanType.v] WITH (NOEXPAND) ON [loanType.v].id = d.[loanType]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
        LEFT JOIN dbo.[Catalog.Product.v] [Lot.v] WITH (NOEXPAND) ON [Lot.v].id = d.[Lot]
        LEFT JOIN dbo.[Catalog.LoanRepaymentProcedure.v] [LoanRepaymentProcedure.v] WITH (NOEXPAND) ON [LoanRepaymentProcedure.v].id = d.[LoanRepaymentProcedure]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Loan] TO jetti;
GO

      
------------------------------ END Catalog.Loan ------------------------------

      
      
------------------------------ BEGIN Catalog.ModifiersGroup ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.ModifiersGroup] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "ModifiersGroup", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[MinPosition] [MinPosition]
        , d.[MaxPosition] [MaxPosition]
        , d.[Multiselection] [Multiselection]
      
        , ISNULL(l5.id, d.id) [ModifiersGroup.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [ModifiersGroup.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [ModifiersGroup.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [ModifiersGroup.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [ModifiersGroup.Level1.id]
        , ISNULL(l5.description, d.description) [ModifiersGroup.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [ModifiersGroup.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [ModifiersGroup.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [ModifiersGroup.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [ModifiersGroup.Level1]
      FROM [Catalog.ModifiersGroup.v] d 
        LEFT JOIN [Catalog.ModifiersGroup.v] l5  ON (l5.id = d.parent)
        LEFT JOIN [Catalog.ModifiersGroup.v] l4  ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.ModifiersGroup.v] l3  ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.ModifiersGroup.v] l2  ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.ModifiersGroup.v] l1  ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
    ;
GO
GRANT SELECT ON dbo.[Catalog.ModifiersGroup] TO jetti;
GO

      
------------------------------ END Catalog.ModifiersGroup ------------------------------

      
      
------------------------------ BEGIN Catalog.MoneyDocument ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.MoneyDocument] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "MoneyDocument", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([kind.v].description, '') [kind.value], d.[kind] [kind.id], [kind.v].type [kind.type]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Owner.v].description, '') [Owner.value], d.[Owner] [Owner.id], [Owner.v].type [Owner.type]
        , d.[Qty] [Qty]
        , d.[Price] [Price]
        , d.[CreateDate] [CreateDate]
        , d.[ExpiredAt] [ExpiredAt]
        , ISNULL([currency_Pay.v].description, '') [currency_Pay.value], d.[currency_Pay] [currency_Pay.id], [currency_Pay.v].type [currency_Pay.type]
        , d.[Amount_Pay] [Amount_Pay]
      
        , ISNULL(l5.id, d.id) [MoneyDocument.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [MoneyDocument.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [MoneyDocument.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [MoneyDocument.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [MoneyDocument.Level1.id]
        , ISNULL(l5.description, d.description) [MoneyDocument.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [MoneyDocument.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [MoneyDocument.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [MoneyDocument.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [MoneyDocument.Level1]
      FROM [Catalog.MoneyDocument.v] d 
        LEFT JOIN [Catalog.MoneyDocument.v] l5  ON (l5.id = d.parent)
        LEFT JOIN [Catalog.MoneyDocument.v] l4  ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.MoneyDocument.v] l3  ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.MoneyDocument.v] l2  ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.MoneyDocument.v] l1  ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Type.v] [kind.v] WITH (NOEXPAND) ON [kind.v].id = d.[kind]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Documents] [Owner.v] ON [Owner.v].id = d.[Owner]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency_Pay.v] WITH (NOEXPAND) ON [currency_Pay.v].id = d.[currency_Pay]
    ;
GO
GRANT SELECT ON dbo.[Catalog.MoneyDocument] TO jetti;
GO

      
------------------------------ END Catalog.MoneyDocument ------------------------------

      
      
------------------------------ BEGIN Catalog.ObjectsExploitation ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.ObjectsExploitation] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "ObjectsExploitation", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , d.[InventoryNumber] [InventoryNumber]
      
        , ISNULL(l5.id, d.id) [ObjectsExploitation.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [ObjectsExploitation.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [ObjectsExploitation.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [ObjectsExploitation.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [ObjectsExploitation.Level1.id]
        , ISNULL(l5.description, d.description) [ObjectsExploitation.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [ObjectsExploitation.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [ObjectsExploitation.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [ObjectsExploitation.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [ObjectsExploitation.Level1]
      FROM [Catalog.ObjectsExploitation.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.ObjectsExploitation.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.ObjectsExploitation.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.ObjectsExploitation.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.ObjectsExploitation.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.ObjectsExploitation.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.ObjectsExploitation.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
    ;
GO
GRANT SELECT ON dbo.[Catalog.ObjectsExploitation] TO jetti;
GO

      
------------------------------ END Catalog.ObjectsExploitation ------------------------------

      
      
------------------------------ BEGIN Catalog.OrderSource ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.OrderSource] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "OrderSource", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[Kind] [Kind]
        , d.[SourceType] [SourceType]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
        , ISNULL([Counterpartie.v].description, '') [Counterpartie.value], d.[Counterpartie] [Counterpartie.id], [Counterpartie.v].type [Counterpartie.type]
        , d.[venusHubSource] [venusHubSource]
      
        , ISNULL(l5.id, d.id) [OrderSource.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [OrderSource.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [OrderSource.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [OrderSource.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [OrderSource.Level1.id]
        , ISNULL(l5.description, d.description) [OrderSource.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [OrderSource.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [OrderSource.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [OrderSource.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [OrderSource.Level1]
      FROM [Catalog.OrderSource.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.OrderSource.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.OrderSource.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.OrderSource.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.OrderSource.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.OrderSource.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Counterpartie.v] WITH (NOEXPAND) ON [Counterpartie.v].id = d.[Counterpartie]
    ;
GO
GRANT SELECT ON dbo.[Catalog.OrderSource] TO jetti;
GO

      
------------------------------ END Catalog.OrderSource ------------------------------

      
      
------------------------------ BEGIN Catalog.Person ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Person] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Person", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([ParentPerson.v].description, '') [ParentPerson.value], d.[ParentPerson] [ParentPerson.id], [ParentPerson.v].type [ParentPerson.type]
        , d.[Gender] [Gender]
        , d.[FirstName] [FirstName]
        , d.[LastName] [LastName]
        , d.[MiddleName] [MiddleName]
        , d.[Code1] [Code1]
        , d.[Code2] [Code2]
        , d.[Address] [Address]
        , d.[AddressResidence] [AddressResidence]
        , d.[City] [City]
        , d.[Phone] [Phone]
        , d.[PersonalPhone] [PersonalPhone]
        , d.[Email] [Email]
        , d.[PersonalEmail] [PersonalEmail]
        , d.[Birthday] [Birthday]
        , d.[EmploymentDate] [EmploymentDate]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([JobTitle.v].description, '') [JobTitle.value], d.[JobTitle] [JobTitle.id], [JobTitle.v].type [JobTitle.type]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
        , d.[Profile] [Profile]
        , ISNULL([DocumentType.v].description, '') [DocumentType.value], d.[DocumentType] [DocumentType.id], [DocumentType.v].type [DocumentType.type]
        , d.[DocumentCode] [DocumentCode]
        , d.[DocumentNumber] [DocumentNumber]
        , d.[DocumentDate] [DocumentDate]
        , d.[DocumentAuthority] [DocumentAuthority]
        , d.[AccountAD] [AccountAD]
        , d.[SMAccount] [SMAccount]
        , d.[Pincode] [Pincode]
        , d.[Fired] [Fired]
        , d.[PayoutBlocked] [PayoutBlocked]
      
        , ISNULL(l5.id, d.id) [Person.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Person.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Person.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Person.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Person.Level1.id]
        , ISNULL(l5.description, d.description) [Person.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Person.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Person.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Person.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Person.Level1]
      FROM [Catalog.Person.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Person.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Person.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Person.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Person.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Person.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [ParentPerson.v] WITH (NOEXPAND) ON [ParentPerson.v].id = d.[ParentPerson]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.JobTitle.v] [JobTitle.v] WITH (NOEXPAND) ON [JobTitle.v].id = d.[JobTitle]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
        LEFT JOIN dbo.[Catalog.PersonIdentity.v] [DocumentType.v] WITH (NOEXPAND) ON [DocumentType.v].id = d.[DocumentType]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Person] TO jetti;
GO

      
------------------------------ END Catalog.Person ------------------------------

      
      
------------------------------ BEGIN Catalog.Person.BankAccount ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Person.BankAccount] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "PersonBankAccount", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([owner.v].description, '') [owner.value], d.[owner] [owner.id], [owner.v].type [owner.type]
        , ISNULL([Bank.v].description, '') [Bank.value], d.[Bank] [Bank.id], [Bank.v].type [Bank.type]
        , ISNULL([SalaryProject.v].description, '') [SalaryProject.value], d.[SalaryProject] [SalaryProject.id], [SalaryProject.v].type [SalaryProject.type]
        , d.[OpenDate] [OpenDate]
        , d.[CardId] [CardId]
        , d.[CardBank] [CardBank]
        , d.[CryptoWalletId] [CryptoWalletId]
        , d.[CryptoNetwork] [CryptoNetwork]
        , d.[PersonExchangeId] [PersonExchangeId]
        , d.[PersonExchangeValue] [PersonExchangeValue]
        , d.[CorporateBankAccount] [CorporateBankAccount]
        , d.[CorporateBankCode] [CorporateBankCode]
      
        , ISNULL(l5.id, d.id) [PersonBankAccount.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [PersonBankAccount.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [PersonBankAccount.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [PersonBankAccount.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [PersonBankAccount.Level1.id]
        , ISNULL(l5.description, d.description) [PersonBankAccount.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [PersonBankAccount.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [PersonBankAccount.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [PersonBankAccount.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [PersonBankAccount.Level1]
      FROM [Catalog.Person.BankAccount.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Person.BankAccount.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Person.BankAccount.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Person.BankAccount.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Person.BankAccount.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Person.BankAccount.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [owner.v] WITH (NOEXPAND) ON [owner.v].id = d.[owner]
        LEFT JOIN dbo.[Catalog.Bank.v] [Bank.v] WITH (NOEXPAND) ON [Bank.v].id = d.[Bank]
        LEFT JOIN dbo.[Catalog.SalaryProject.v] [SalaryProject.v] WITH (NOEXPAND) ON [SalaryProject.v].id = d.[SalaryProject]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Person.BankAccount] TO jetti;
GO

      
------------------------------ END Catalog.Person.BankAccount ------------------------------

      
      
------------------------------ BEGIN Catalog.Person.Contract ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Person.Contract] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "PersonContract", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([owner.v].description, '') [owner.value], d.[owner] [owner.id], [owner.v].type [owner.type]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[Status] [Status]
        , d.[StartDate] [StartDate]
        , d.[EndDate] [EndDate]
        , ISNULL([BankAccount.v].description, '') [BankAccount.value], d.[BankAccount] [BankAccount.id], [BankAccount.v].type [BankAccount.type]
        , d.[Kind] [Kind]
      
        , ISNULL(l5.id, d.id) [PersonContract.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [PersonContract.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [PersonContract.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [PersonContract.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [PersonContract.Level1.id]
        , ISNULL(l5.description, d.description) [PersonContract.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [PersonContract.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [PersonContract.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [PersonContract.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [PersonContract.Level1]
      FROM [Catalog.Person.Contract.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Person.Contract.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Person.Contract.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Person.Contract.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Person.Contract.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Person.Contract.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Person.v] [owner.v] WITH (NOEXPAND) ON [owner.v].id = d.[owner]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Person.BankAccount.v] [BankAccount.v] WITH (NOEXPAND) ON [BankAccount.v].id = d.[BankAccount]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Person.Contract] TO jetti;
GO

      
------------------------------ END Catalog.Person.Contract ------------------------------

      
      
------------------------------ BEGIN Catalog.Product ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Product] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Product", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([ProductKind.v].description, '') [ProductKind.value], d.[ProductKind] [ProductKind.id], [ProductKind.v].type [ProductKind.type]
        , ISNULL([ProductCategory.v].description, '') [ProductCategory.value], d.[ProductCategory] [ProductCategory.id], [ProductCategory.v].type [ProductCategory.type]
        , ISNULL([Specification.v].description, '') [Specification.value], d.[Specification] [Specification.id], [Specification.v].type [Specification.type]
        , ISNULL([Brand.v].description, '') [Brand.value], d.[Brand] [Brand.id], [Brand.v].type [Brand.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , ISNULL([Unit.v].description, '') [Unit.value], d.[Unit] [Unit.id], [Unit.v].type [Unit.type]
        , ISNULL([Expense.v].description, '') [Expense.value], d.[Expense] [Expense.id], [Expense.v].type [Expense.type]
        , ISNULL([Analytics.v].description, '') [Analytics.value], d.[Analytics] [Analytics.id], [Analytics.v].type [Analytics.type]
        , ISNULL([ProductReport.v].description, '') [ProductReport.value], d.[ProductReport] [ProductReport.id], [ProductReport.v].type [ProductReport.type]
        , ISNULL([Settings.v].description, '') [Settings.value], d.[Settings] [Settings.id], [Settings.v].type [Settings.type]
        , d.[Purchased] [Purchased]
        , d.[ShortCode] [ShortCode]
        , d.[DescriptionCustomer] [DescriptionCustomer]
        , d.[ShortName] [ShortName]
        , d.[Tags] [Tags]
        , d.[Weight] [Weight]
        , d.[Volume] [Volume]
        , d.[Calorie] [Calorie]
        , d.[Carbohydrates] [Carbohydrates]
        , d.[Fat] [Fat]
        , d.[Proteins] [Proteins]
        , d.[CookingTime] [CookingTime]
        , d.[Composition] [Composition]
        , d.[CookingPlace] [CookingPlace]
        , d.[Order] [Order]
        , d.[Barcode] [Barcode]
        , d.[Eancode] [Eancode]
        , d.[isVegan] [isVegan]
        , d.[isHot] [isHot]
        , d.[isPromo] [isPromo]
        , d.[isAggregator] [isAggregator]
        , d.[isThermallabelPrinting] [isThermallabelPrinting]
        , d.[Slug] [Slug]
        , d.[InvoiceComposition] [InvoiceComposition]
        , d.[isAdditions] [isAdditions]
        , d.[SlugIndex] [SlugIndex]
      
        , ISNULL(l5.id, d.id) [Product.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Product.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Product.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Product.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Product.Level1.id]
        , ISNULL(l5.description, d.description) [Product.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Product.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Product.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Product.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Product.Level1]
      FROM [Catalog.Product.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Product.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Product.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Product.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Product.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Product.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.ProductKind.v] [ProductKind.v] WITH (NOEXPAND) ON [ProductKind.v].id = d.[ProductKind]
        LEFT JOIN dbo.[Catalog.ProductCategory.v] [ProductCategory.v] WITH (NOEXPAND) ON [ProductCategory.v].id = d.[ProductCategory]
        LEFT JOIN dbo.[Catalog.Specification.v] [Specification.v] WITH (NOEXPAND) ON [Specification.v].id = d.[Specification]
        LEFT JOIN dbo.[Catalog.Brand.v] [Brand.v] WITH (NOEXPAND) ON [Brand.v].id = d.[Brand]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.Unit.v] [Unit.v] WITH (NOEXPAND) ON [Unit.v].id = d.[Unit]
        LEFT JOIN dbo.[Catalog.Expense.v] [Expense.v] WITH (NOEXPAND) ON [Expense.v].id = d.[Expense]
        LEFT JOIN dbo.[Catalog.Expense.Analytics.v] [Analytics.v] WITH (NOEXPAND) ON [Analytics.v].id = d.[Analytics]
        LEFT JOIN dbo.[Catalog.Product.Report.v] [ProductReport.v] WITH (NOEXPAND) ON [ProductReport.v].id = d.[ProductReport]
        LEFT JOIN dbo.[Document.Operation.v] [Settings.v] WITH (NOEXPAND) ON [Settings.v].id = d.[Settings]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Product] TO jetti;
GO

      
------------------------------ END Catalog.Product ------------------------------

      
      
------------------------------ BEGIN Catalog.ProductCategory ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.ProductCategory] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "ProductCategory", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[Order] [Order]
        , d.[Presentation] [Presentation]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , d.[isDefault] [isDefault]
        , d.[isDesktop] [isDesktop]
        , d.[isWeb] [isWeb]
        , d.[isMobile] [isMobile]
        , d.[Slug] [Slug]
        , ISNULL([GroupProductCategory.v].description, '') [GroupProductCategory.value], d.[GroupProductCategory] [GroupProductCategory.id], [GroupProductCategory.v].type [GroupProductCategory.type]
      
        , ISNULL(l5.id, d.id) [ProductCategory.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [ProductCategory.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [ProductCategory.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [ProductCategory.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [ProductCategory.Level1.id]
        , ISNULL(l5.description, d.description) [ProductCategory.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [ProductCategory.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [ProductCategory.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [ProductCategory.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [ProductCategory.Level1]
      FROM [Catalog.ProductCategory.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.ProductCategory.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.ProductCategory.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.ProductCategory.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.ProductCategory.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.ProductCategory.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.Operation.Type.v] [GroupProductCategory.v] WITH (NOEXPAND) ON [GroupProductCategory.v].id = d.[GroupProductCategory]
    ;
GO
GRANT SELECT ON dbo.[Catalog.ProductCategory] TO jetti;
GO

      
------------------------------ END Catalog.ProductCategory ------------------------------

      
      
------------------------------ BEGIN Catalog.ReasonTypes ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.ReasonTypes] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "ReasonTypes", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[WriteOff] [WriteOff]
        , ISNULL([Expense.v].description, '') [Expense.value], d.[Expense] [Expense.id], [Expense.v].type [Expense.type]
        , ISNULL([ExpenseAnalynic.v].description, '') [ExpenseAnalynic.value], d.[ExpenseAnalynic] [ExpenseAnalynic.id], [ExpenseAnalynic.v].type [ExpenseAnalynic.type]
        , d.[Kind] [Kind]
      
        , ISNULL(l5.id, d.id) [ReasonTypes.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [ReasonTypes.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [ReasonTypes.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [ReasonTypes.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [ReasonTypes.Level1.id]
        , ISNULL(l5.description, d.description) [ReasonTypes.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [ReasonTypes.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [ReasonTypes.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [ReasonTypes.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [ReasonTypes.Level1]
      FROM [Catalog.ReasonTypes.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.ReasonTypes.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.ReasonTypes.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.ReasonTypes.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.ReasonTypes.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.ReasonTypes.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Documents] [Expense.v] ON [Expense.v].id = d.[Expense]
        LEFT JOIN dbo.[Catalog.Expense.Analytics.v] [ExpenseAnalynic.v] WITH (NOEXPAND) ON [ExpenseAnalynic.v].id = d.[ExpenseAnalynic]
    ;
GO
GRANT SELECT ON dbo.[Catalog.ReasonTypes] TO jetti;
GO

      
------------------------------ END Catalog.ReasonTypes ------------------------------

      
      
------------------------------ BEGIN Catalog.RetailClient ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.RetailClient] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "RetailClient", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[Gender] [Gender]
        , d.[isBlocked] [isBlocked]
        , d.[CreateDate] [CreateDate]
        , d.[Birthday] [Birthday]
        , d.[FirstName] [FirstName]
        , d.[LastName] [LastName]
        , d.[MiddleName] [MiddleName]
        , d.[Phone] [Phone]
        , d.[Email] [Email]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , ISNULL([BusinessRegion.v].description, '') [BusinessRegion.value], d.[BusinessRegion] [BusinessRegion.id], [BusinessRegion.v].type [BusinessRegion.type]
        , d.[SailplayId] [SailplayId]
        , d.[Source] [Source]
        , d.[Address] [Address]
      
        , ISNULL(l5.id, d.id) [RetailClient.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [RetailClient.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [RetailClient.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [RetailClient.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [RetailClient.Level1.id]
        , ISNULL(l5.description, d.description) [RetailClient.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [RetailClient.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [RetailClient.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [RetailClient.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [RetailClient.Level1]
      FROM [Catalog.RetailClient.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.RetailClient.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.RetailClient.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.RetailClient.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.RetailClient.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.RetailClient.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.BusinessRegion.v] [BusinessRegion.v] WITH (NOEXPAND) ON [BusinessRegion.v].id = d.[BusinessRegion]
    ;
GO
GRANT SELECT ON dbo.[Catalog.RetailClient] TO jetti;
GO

      
------------------------------ END Catalog.RetailClient ------------------------------

      
      
------------------------------ BEGIN Catalog.RetailNetwork ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.RetailNetwork] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "RetailNetwork", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[aboutCompanyUrl] [aboutCompanyUrl]
        , d.[appAvailable] [appAvailable]
        , d.[BonusPercent] [BonusPercent]
        , ISNULL([Brand.v].description, '') [Brand.value], d.[Brand] [Brand.id], [Brand.v].type [Brand.type]
        , ISNULL([BusinessRegion.v].description, '') [BusinessRegion.value], d.[BusinessRegion] [BusinessRegion.id], [BusinessRegion.v].type [BusinessRegion.type]
        , ISNULL([Country.v].description, '') [Country.value], d.[Country] [Country.id], [Country.v].type [Country.type]
        , ISNULL([Currency.v].description, '') [Currency.value], d.[Currency] [Currency.id], [Currency.v].type [Currency.type]
        , d.[customerSupportPhone] [customerSupportPhone]
        , d.[DefaultMapService] [DefaultMapService]
        , d.[isDeleted] [isDeleted]
        , d.[keyVaultURL] [keyVaultURL]
        , d.[maxTotalOrder] [maxTotalOrder]
        , d.[PlaceHolder] [PlaceHolder]
        , d.[publicOfferUrl] [publicOfferUrl]
        , ISNULL([ServiceProduct.v].description, '') [ServiceProduct.value], d.[ServiceProduct] [ServiceProduct.id], [ServiceProduct.v].type [ServiceProduct.type]
        , d.[smsGateway] [smsGateway]
        , d.[usePriceByAggregator] [usePriceByAggregator]
        , d.[sailplayCredentials] [sailplayCredentials]
        , d.[Slug] [Slug]
      
        , ISNULL(l5.id, d.id) [RetailNetwork.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [RetailNetwork.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [RetailNetwork.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [RetailNetwork.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [RetailNetwork.Level1.id]
        , ISNULL(l5.description, d.description) [RetailNetwork.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [RetailNetwork.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [RetailNetwork.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [RetailNetwork.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [RetailNetwork.Level1]
      FROM [Catalog.RetailNetwork.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.RetailNetwork.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.RetailNetwork.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.RetailNetwork.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.RetailNetwork.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.RetailNetwork.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Brand.v] [Brand.v] WITH (NOEXPAND) ON [Brand.v].id = d.[Brand]
        LEFT JOIN dbo.[Catalog.BusinessRegion.v] [BusinessRegion.v] WITH (NOEXPAND) ON [BusinessRegion.v].id = d.[BusinessRegion]
        LEFT JOIN dbo.[Catalog.Country.v] [Country.v] WITH (NOEXPAND) ON [Country.v].id = d.[Country]
        LEFT JOIN dbo.[Catalog.Currency.v] [Currency.v] WITH (NOEXPAND) ON [Currency.v].id = d.[Currency]
        LEFT JOIN dbo.[Catalog.Product.v] [ServiceProduct.v] WITH (NOEXPAND) ON [ServiceProduct.v].id = d.[ServiceProduct]
    ;
GO
GRANT SELECT ON dbo.[Catalog.RetailNetwork] TO jetti;
GO

      
------------------------------ END Catalog.RetailNetwork ------------------------------

      
      
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

      
------------------------------ END Catalog.Specification ------------------------------

      
      
------------------------------ BEGIN Catalog.UsersGroup ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.UsersGroup] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "UsersGroup", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , d.[Checked] [Checked]
        , ISNULL([DepartmentCompany.v].description, '') [DepartmentCompany.value], d.[DepartmentCompany] [DepartmentCompany.id], [DepartmentCompany.v].type [DepartmentCompany.type]
      
        , ISNULL(l5.id, d.id) [UsersGroup.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [UsersGroup.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [UsersGroup.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [UsersGroup.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [UsersGroup.Level1.id]
        , ISNULL(l5.description, d.description) [UsersGroup.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [UsersGroup.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [UsersGroup.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [UsersGroup.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [UsersGroup.Level1]
      FROM [Catalog.UsersGroup.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.UsersGroup.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.UsersGroup.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.UsersGroup.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.UsersGroup.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.UsersGroup.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Department.Company.v] [DepartmentCompany.v] WITH (NOEXPAND) ON [DepartmentCompany.v].id = d.[DepartmentCompany]
    ;
GO
GRANT SELECT ON dbo.[Catalog.UsersGroup] TO jetti;
GO

      
------------------------------ END Catalog.UsersGroup ------------------------------

      
      
------------------------------ BEGIN Catalog.Vehicle ------------------------------

      
      CREATE OR ALTER VIEW dbo.[Catalog.Vehicle] AS
        
      SELECT
        d.id, d.type, d.date, d.code, d.description "Vehicle", d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Carrier.v].description, '') [Carrier.value], d.[Carrier] [Carrier.id], [Carrier.v].type [Carrier.type]
        , d.[Model] [Model]
        , d.[RegNumber] [RegNumber]
        , d.[kind] [kind]
        , d.[Carrying] [Carrying]
        , d.[Capacity] [Capacity]
        , d.[ModelTrailer] [ModelTrailer]
        , d.[RegNumberTrailer] [RegNumberTrailer]
      
        , ISNULL(l5.id, d.id) [Vehicle.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [Vehicle.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [Vehicle.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [Vehicle.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [Vehicle.Level1.id]
        , ISNULL(l5.description, d.description) [Vehicle.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [Vehicle.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [Vehicle.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [Vehicle.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [Vehicle.Level1]
      FROM [Catalog.Vehicle.v] d WITH (NOEXPAND)
        LEFT JOIN [Catalog.Vehicle.v] l5 WITH (NOEXPAND) ON (l5.id = d.parent)
        LEFT JOIN [Catalog.Vehicle.v] l4 WITH (NOEXPAND) ON (l4.id = l5.parent)
        LEFT JOIN [Catalog.Vehicle.v] l3 WITH (NOEXPAND) ON (l3.id = l4.parent)
        LEFT JOIN [Catalog.Vehicle.v] l2 WITH (NOEXPAND) ON (l2.id = l3.parent)
        LEFT JOIN [Catalog.Vehicle.v] l1 WITH (NOEXPAND) ON (l1.id = l2.parent)
      
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Carrier.v] WITH (NOEXPAND) ON [Carrier.v].id = d.[Carrier]
    ;
GO
GRANT SELECT ON dbo.[Catalog.Vehicle] TO jetti;
GO

      
------------------------------ END Catalog.Vehicle ------------------------------

      