
------------------------------ BEGIN Operation.AdditionalParametersDepartment ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.AdditionalParametersDepartment] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "AdditionalParametersDepartment",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , d.[FrontType] [FrontType]
        , ISNULL([MainStoreHouse.v].description, '') [MainStoreHouse.value], d.[MainStoreHouse] [MainStoreHouse.id], [MainStoreHouse.v].type [MainStoreHouse.type]
        , d.[TimeOpen] [TimeOpen]
        , d.[TimeClose] [TimeClose]
        , d.[MaxTotalOrder] [MaxTotalOrder]
        , d.[DeliveryTimeClose] [DeliveryTimeClose]
        , d.[isDeliveringService] [isDeliveringService]
        , d.[isPickupService] [isPickupService]
        , d.[isComentRequired] [isComentRequired]
        , d.[isOnlinePayAccepted] [isOnlinePayAccepted]
        , d.[isCoordinatesCheck] [isCoordinatesCheck]
        , d.[isSailPlayPromocodeCheck] [isSailPlayPromocodeCheck]
        , d.[isSailPlayBonusCheck] [isSailPlayBonusCheck]
        , d.[wifiSSID] [wifiSSID]
        , d.[timeZoneOffset] [timeZoneOffset]
        , d.[addressCheck] [addressCheck]
        , d.[addressSMS] [addressSMS]
        , d.[organisationCheck] [organisationCheck]
        , d.[defaultCoockingTime] [defaultCoockingTime]
        , d.[currentCoockingTime] [currentCoockingTime]
        , d.[currentCookingTimeExpiredAt] [currentCookingTimeExpiredAt]
        , d.[CookingTimeshift] [CookingTimeshift]
        , d.[CookingTimeshiftExpiredAt] [CookingTimeshiftExpiredAt]
        , d.[defaultDeliveryTime] [defaultDeliveryTime]
        , d.[DeliveryTimeShift] [DeliveryTimeShift]
        , d.[DeliveryTimeShiftExpiredAt] [DeliveryTimeShiftExpiredAt]
        , d.[iikoTerminalId] [iikoTerminalId]
        , d.[paymentGateway] [paymentGateway]
        , d.[keyVaultURL] [keyVaultURL]
        , ISNULL([WayStoreHouse.v].description, '') [WayStoreHouse.value], d.[WayStoreHouse] [WayStoreHouse.id], [WayStoreHouse.v].type [WayStoreHouse.type]
        , d.[generatorExist] [generatorExist]
        , d.[hostName] [hostName]
        , d.[isTaxPayer] [isTaxPayer]
        , d.[StickerSettings] [StickerSettings]
        , d.[ThermalName] [ThermalName]
        , d.[AreaTotal] [AreaTotal]
        , d.[AreaTrade] [AreaTrade]
        , d.[AreaKitchen] [AreaKitchen]
        , d.[MaxOrdersPerHour] [MaxOrdersPerHour]
        , d.[provider] [provider]
        , d.[outletId] [outletId]
        , d.[isPlanningSemifinished] [isPlanningSemifinished]
        , d.[PickupTimeOpen] [PickupTimeOpen]
        , d.[PickupTimeClose] [PickupTimeClose]
        , d.[DeliveryTimeOpen] [DeliveryTimeOpen]
        , d.[DeliveryTimeCloseKaDS] [DeliveryTimeCloseKaDS]
      FROM [Operation.AdditionalParametersDepartment.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [MainStoreHouse.v] WITH (NOEXPAND) ON [MainStoreHouse.v].id = d.[MainStoreHouse]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [WayStoreHouse.v] WITH (NOEXPAND) ON [WayStoreHouse.v].id = d.[WayStoreHouse]
    ; 
GO
GRANT SELECT ON dbo.[Operation.AdditionalParametersDepartment] TO jetti;
GO

      
------------------------------ END Operation.AdditionalParametersDepartment ------------------------------

------------------------------ BEGIN Operation.AutoAdditionSettings ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.AutoAdditionSettings] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "AutoAdditionSettings",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , d.[AdditionalType] [AdditionalType]
        , ISNULL([MainSKU.v].description, '') [MainSKU.value], d.[MainSKU] [MainSKU.id], [MainSKU.v].type [MainSKU.type]
        , d.[Qty] [Qty]
        , d.[defaultQty] [defaultQty]
        , d.[DateBegin] [DateBegin]
        , d.[DateEnd] [DateEnd]
        , d.[DeliveryType] [DeliveryType]
      FROM [Operation.AutoAdditionSettings.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.Product.v] [MainSKU.v] WITH (NOEXPAND) ON [MainSKU.v].id = d.[MainSKU]
    ; 
GO
GRANT SELECT ON dbo.[Operation.AutoAdditionSettings] TO jetti;
GO

      
------------------------------ END Operation.AutoAdditionSettings ------------------------------

------------------------------ BEGIN Operation.CashShifts ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.CashShifts] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "CashShifts",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([UserId.v].description, '') [UserId.value], d.[UserId] [UserId.id], [UserId.v].type [UserId.type]
        , d.[CashShiftNumber] [CashShiftNumber]
        , d.[AccountingDate] [AccountingDate]
        , d.[StartDate] [StartDate]
        , d.[EndDate] [EndDate]
        , d.[ChecksLoaded] [ChecksLoaded]
        , d.[ProductionCalculated] [ProductionCalculated]
        , d.[startBalance] [startBalance]
        , d.[endBalance] [endBalance]
        , d.[ErrorCount] [ErrorCount]
        , d.[ProductionId] [ProductionId]
      FROM [Operation.CashShifts.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Person.v] [UserId.v] WITH (NOEXPAND) ON [UserId.v].id = d.[UserId]
    ; 
GO
GRANT SELECT ON dbo.[Operation.CashShifts] TO jetti;
GO

      
------------------------------ END Operation.CashShifts ------------------------------

------------------------------ BEGIN Operation.CHECK_JETTI_FRONT ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.CHECK_JETTI_FRONT] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "CHECK_JETTI_FRONT",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , ISNULL([Manager.v].description, '') [Manager.value], d.[Manager] [Manager.id], [Manager.v].type [Manager.type]
        , ISNULL([Customer.v].description, '') [Customer.value], d.[Customer] [Customer.id], [Customer.v].type [Customer.type]
        , ISNULL([Storehouse.v].description, '') [Storehouse.value], d.[Storehouse] [Storehouse.id], [Storehouse.v].type [Storehouse.type]
        , d.[DiscountDoc] [DiscountDoc]
        , d.[NumCashShift] [NumCashShift]
        , d.[TypeDocument] [TypeDocument]
        , d.[PrintTime] [PrintTime]
        , d.[TypeOfFranchise] [TypeOfFranchise]
        , d.[DeliveryType] [DeliveryType]
        , d.[OrderSource] [OrderSource]
        , ISNULL([ParentOrderSource.v].description, '') [ParentOrderSource.value], d.[ParentOrderSource] [ParentOrderSource.id], [ParentOrderSource.v].type [ParentOrderSource.type]
        , ISNULL([Aggregator.v].description, '') [Aggregator.value], d.[Aggregator] [Aggregator.id], [Aggregator.v].type [Aggregator.type]
        , d.[DeliveryArea] [DeliveryArea]
        , ISNULL([Courier.v].description, '') [Courier.value], d.[Courier] [Courier.id], [Courier.v].type [Courier.type]
        , d.[counterpartyId] [counterpartyId]
        , ISNULL([RetailClient.v].description, '') [RetailClient.value], d.[RetailClient] [RetailClient.id], [RetailClient.v].type [RetailClient.type]
        , d.[orderId] [orderId]
      FROM [Operation.CHECK_JETTI_FRONT.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.Person.v] [Manager.v] WITH (NOEXPAND) ON [Manager.v].id = d.[Manager]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Customer.v] WITH (NOEXPAND) ON [Customer.v].id = d.[Customer]
        LEFT JOIN dbo.[Catalog.Storehouse.v] [Storehouse.v] WITH (NOEXPAND) ON [Storehouse.v].id = d.[Storehouse]
        LEFT JOIN dbo.[Catalog.OrderSource.v] [ParentOrderSource.v] WITH (NOEXPAND) ON [ParentOrderSource.v].id = d.[ParentOrderSource]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Aggregator.v] WITH (NOEXPAND) ON [Aggregator.v].id = d.[Aggregator]
        LEFT JOIN dbo.[Catalog.Person.v] [Courier.v] WITH (NOEXPAND) ON [Courier.v].id = d.[Courier]
        LEFT JOIN dbo.[Catalog.RetailClient.v] [RetailClient.v] WITH (NOEXPAND) ON [RetailClient.v].id = d.[RetailClient]
    ; 
GO
GRANT SELECT ON dbo.[Operation.CHECK_JETTI_FRONT] TO jetti;
GO

      
------------------------------ END Operation.CHECK_JETTI_FRONT ------------------------------

------------------------------ BEGIN Operation.DeliveryAreas ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.DeliveryAreas] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "DeliveryAreas",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , d.[MapUrl] [MapUrl]
        , d.[LoadFolder] [LoadFolder]
      FROM [Operation.DeliveryAreas.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
    ; 
GO
GRANT SELECT ON dbo.[Operation.DeliveryAreas] TO jetti;
GO

      
------------------------------ END Operation.DeliveryAreas ------------------------------

------------------------------ BEGIN Operation.Group_Create_CashRequests ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.Group_Create_CashRequests] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "Group_Create_CashRequests",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([ResponsibilityCenter.v].description, '') [ResponsibilityCenter.value], d.[ResponsibilityCenter] [ResponsibilityCenter.id], [ResponsibilityCenter.v].type [ResponsibilityCenter.type]
        , ISNULL([GroupSettings.v].description, '') [GroupSettings.value], d.[GroupSettings] [GroupSettings.id], [GroupSettings.v].type [GroupSettings.type]
        , d.[BDate] [BDate]
        , d.[EDate] [EDate]
        , ISNULL([SalaryAnalytics.v].description, '') [SalaryAnalytics.value], d.[SalaryAnalytics] [SalaryAnalytics.id], [SalaryAnalytics.v].type [SalaryAnalytics.type]
        , d.[Status_Log] [Status_Log]
        , ISNULL([CashFlow.v].description, '') [CashFlow.value], d.[CashFlow] [CashFlow.id], [CashFlow.v].type [CashFlow.type]
        , ISNULL([CashRegisterByDefault.v].description, '') [CashRegisterByDefault.value], d.[CashRegisterByDefault] [CashRegisterByDefault.id], [CashRegisterByDefault.v].type [CashRegisterByDefault.type]
        , d.[isPayByDepartmentOfPerson] [isPayByDepartmentOfPerson]
      FROM [Operation.Group_Create_CashRequests.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.ResponsibilityCenter.v] [ResponsibilityCenter.v] WITH (NOEXPAND) ON [ResponsibilityCenter.v].id = d.[ResponsibilityCenter]
        LEFT JOIN dbo.[Catalog.Operation.Type.v] [GroupSettings.v] WITH (NOEXPAND) ON [GroupSettings.v].id = d.[GroupSettings]
        LEFT JOIN dbo.[Catalog.Salary.Analytics.v] [SalaryAnalytics.v] WITH (NOEXPAND) ON [SalaryAnalytics.v].id = d.[SalaryAnalytics]
        LEFT JOIN dbo.[Catalog.CashFlow.v] [CashFlow.v] WITH (NOEXPAND) ON [CashFlow.v].id = d.[CashFlow]
        LEFT JOIN dbo.[Catalog.CashRegister.v] [CashRegisterByDefault.v] WITH (NOEXPAND) ON [CashRegisterByDefault.v].id = d.[CashRegisterByDefault]
    ; 
GO
GRANT SELECT ON dbo.[Operation.Group_Create_CashRequests] TO jetti;
GO

      
------------------------------ END Operation.Group_Create_CashRequests ------------------------------

------------------------------ BEGIN Operation.OnlineSalesManagementSettings ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.OnlineSalesManagementSettings] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "OnlineSalesManagementSettings",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([BusinessRegion.v].description, '') [BusinessRegion.value], d.[BusinessRegion] [BusinessRegion.id], [BusinessRegion.v].type [BusinessRegion.type]
        , ISNULL([RetailNetwork.v].description, '') [RetailNetwork.value], d.[RetailNetwork] [RetailNetwork.id], [RetailNetwork.v].type [RetailNetwork.type]
        , d.[TypeShowcase] [TypeShowcase]
        , d.[Status] [Status]
        , d.[DateBegin] [DateBegin]
        , d.[DateEnd] [DateEnd]
        , ISNULL([SourceAggr.v].description, '') [SourceAggr.value], d.[SourceAggr] [SourceAggr.id], [SourceAggr.v].type [SourceAggr.type]
      FROM [Operation.OnlineSalesManagementSettings.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.BusinessRegion.v] [BusinessRegion.v] WITH (NOEXPAND) ON [BusinessRegion.v].id = d.[BusinessRegion]
        LEFT JOIN dbo.[Catalog.RetailNetwork.v] [RetailNetwork.v] WITH (NOEXPAND) ON [RetailNetwork.v].id = d.[RetailNetwork]
        LEFT JOIN dbo.[Catalog.OrderSource.v] [SourceAggr.v] WITH (NOEXPAND) ON [SourceAggr.v].id = d.[SourceAggr]
    ; 
GO
GRANT SELECT ON dbo.[Operation.OnlineSalesManagementSettings] TO jetti;
GO

      
------------------------------ END Operation.OnlineSalesManagementSettings ------------------------------

------------------------------ BEGIN Operation.Registry_Share_Sert ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.Registry_Share_Sert] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "Registry_Share_Sert",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , ISNULL([CounterpartieOrPerson.v].description, '') [CounterpartieOrPerson.value], d.[CounterpartieOrPerson] [CounterpartieOrPerson.id], [CounterpartieOrPerson.v].type [CounterpartieOrPerson.type]
        , ISNULL([PersonOwnerStocks.v].description, '') [PersonOwnerStocks.value], d.[PersonOwnerStocks] [PersonOwnerStocks.id], [PersonOwnerStocks.v].type [PersonOwnerStocks.type]
        , ISNULL([OwnerStocksVia.v].description, '') [OwnerStocksVia.value], d.[OwnerStocksVia] [OwnerStocksVia.id], [OwnerStocksVia.v].type [OwnerStocksVia.type]
        , d.[separator_1] [separator_1]
        , d.[PersonOwnerStocks_isEmployee] [PersonOwnerStocks_isEmployee]
      FROM [Operation.Registry_Share_Sert.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Documents] [CounterpartieOrPerson.v] ON [CounterpartieOrPerson.v].id = d.[CounterpartieOrPerson]
        LEFT JOIN dbo.[Catalog.Person.v] [PersonOwnerStocks.v] WITH (NOEXPAND) ON [PersonOwnerStocks.v].id = d.[PersonOwnerStocks]
        LEFT JOIN dbo.[Catalog.Person.v] [OwnerStocksVia.v] WITH (NOEXPAND) ON [OwnerStocksVia.v].id = d.[OwnerStocksVia]
    ; 
GO
GRANT SELECT ON dbo.[Operation.Registry_Share_Sert] TO jetti;
GO

      
------------------------------ END Operation.Registry_Share_Sert ------------------------------

------------------------------ BEGIN Operation.SyncManual ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.SyncManual] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "SyncManual",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[About] [About]
        , d.[logLevel] [logLevel]
        , d.[Source] [Source]
        , d.[forsedUpdate] [forsedUpdate]
        , d.[periodBegin] [periodBegin]
        , d.[periodEnd] [periodEnd]
        , d.[flow] [flow]
        , d.[exchangeID] [exchangeID]
      FROM [Operation.SyncManual.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
    ; 
GO
GRANT SELECT ON dbo.[Operation.SyncManual] TO jetti;
GO

      
------------------------------ END Operation.SyncManual ------------------------------
