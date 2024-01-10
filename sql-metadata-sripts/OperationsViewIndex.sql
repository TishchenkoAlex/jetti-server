
------------------------------ BEGIN Operation.AdditionalParametersDepartment ------------------------------

      RAISERROR('Operation.AdditionalParametersDepartment start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.AdditionalParametersDepartment.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."FrontType"')), '') [FrontType]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."MainStoreHouse"')) [MainStoreHouse]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TimeOpen"')), '') [TimeOpen]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."TimeClose"')), '') [TimeClose]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxTotalOrder"')), 0) [MaxTotalOrder]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DeliveryTimeClose"')), '') [DeliveryTimeClose]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isDeliveringService"')), 0) [isDeliveringService]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPickupService"')), 0) [isPickupService]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isComentRequired"')), 0) [isComentRequired]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isOnlinePayAccepted"')), 0) [isOnlinePayAccepted]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isCoordinatesCheck"')), 0) [isCoordinatesCheck]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isSailPlayPromocodeCheck"')), 0) [isSailPlayPromocodeCheck]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isSailPlayBonusCheck"')), 0) [isSailPlayBonusCheck]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."wifiSSID"')), '') [wifiSSID]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."timeZoneOffset"')), '') [timeZoneOffset]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."addressCheck"')), '') [addressCheck]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."addressSMS"')), '') [addressSMS]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."organisationCheck"')), '') [organisationCheck]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."defaultCoockingTime"')), 0) [defaultCoockingTime]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."currentCoockingTime"')), 0) [currentCoockingTime]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."currentCookingTimeExpiredAt"'),127) [currentCookingTimeExpiredAt]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."CookingTimeshift"')), 0) [CookingTimeshift]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."CookingTimeshiftExpiredAt"'),127) [CookingTimeshiftExpiredAt]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."defaultDeliveryTime"')), 0) [defaultDeliveryTime]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."DeliveryTimeShift"')), 0) [DeliveryTimeShift]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."DeliveryTimeShiftExpiredAt"'),127) [DeliveryTimeShiftExpiredAt]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."iikoTerminalId"')), '') [iikoTerminalId]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."paymentGateway"')), '') [paymentGateway]
      , ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."keyVaultURL"')), '') [keyVaultURL]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."WayStoreHouse"')) [WayStoreHouse]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."generatorExist"')), 0) [generatorExist]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."hostName"')), '') [hostName]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isTaxPayer"')), 0) [isTaxPayer]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."StickerSettings"')), '') [StickerSettings]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."ThermalName"')), '') [ThermalName]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AreaTotal"')), 0) [AreaTotal]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AreaTrade"')), 0) [AreaTrade]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."AreaKitchen"')), 0) [AreaKitchen]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."MaxOrdersPerHour"')), 0) [MaxOrdersPerHour]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."provider"')), '') [provider]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."outletId"')), '') [outletId]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPlanningSemifinished"')), 0) [isPlanningSemifinished]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PickupTimeOpen"')), '') [PickupTimeOpen]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."PickupTimeClose"')), '') [PickupTimeClose]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DeliveryTimeOpen"')), '') [DeliveryTimeOpen]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."DeliveryTimeCloseKaDS"')), '') [DeliveryTimeCloseKaDS]
      FROM dbo.[Documents]
      WHERE [operation] = 'CE62E430-3004-11E8-A0FF-732D589B1ACA'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.AdditionalParametersDepartment.v] ON [Operation.AdditionalParametersDepartment.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.AdditionalParametersDepartment.v.date] ON[Operation.AdditionalParametersDepartment.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AdditionalParametersDepartment.v.parent] ON [Operation.AdditionalParametersDepartment.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AdditionalParametersDepartment.v.deleted] ON [Operation.AdditionalParametersDepartment.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AdditionalParametersDepartment.v.code] ON [Operation.AdditionalParametersDepartment.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AdditionalParametersDepartment.v.user] ON [Operation.AdditionalParametersDepartment.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AdditionalParametersDepartment.v.company] ON [Operation.AdditionalParametersDepartment.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.AdditionalParametersDepartment.v]TO jetti; 
      RAISERROR('Operation.AdditionalParametersDepartment finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.AdditionalParametersDepartment ------------------------------

      
------------------------------ BEGIN Operation.AutoAdditionSettings ------------------------------

      RAISERROR('Operation.AutoAdditionSettings start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.AutoAdditionSettings.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."AdditionalType"')), '') [AdditionalType]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."MainSKU"')) [MainSKU]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Qty"')), 0) [Qty]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."defaultQty"')), 0) [defaultQty]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."DateBegin"'),127) [DateBegin]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."DateEnd"'),127) [DateEnd]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."DeliveryType"')), '') [DeliveryType]
      FROM dbo.[Documents]
      WHERE [operation] = '73F98550-33E2-11EB-A7C3-274B4A063111'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.AutoAdditionSettings.v] ON [Operation.AutoAdditionSettings.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.AutoAdditionSettings.v.date] ON[Operation.AutoAdditionSettings.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AutoAdditionSettings.v.parent] ON [Operation.AutoAdditionSettings.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AutoAdditionSettings.v.deleted] ON [Operation.AutoAdditionSettings.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AutoAdditionSettings.v.code] ON [Operation.AutoAdditionSettings.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AutoAdditionSettings.v.user] ON [Operation.AutoAdditionSettings.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.AutoAdditionSettings.v.company] ON [Operation.AutoAdditionSettings.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.AutoAdditionSettings.v]TO jetti; 
      RAISERROR('Operation.AutoAdditionSettings finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.AutoAdditionSettings ------------------------------

      
------------------------------ BEGIN Operation.CashShifts ------------------------------

      RAISERROR('Operation.CashShifts start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.CashShifts.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."UserId"')) [UserId]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."CashShiftNumber"')), '') [CashShiftNumber]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."AccountingDate"'),127) [AccountingDate]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."StartDate"'),127) [StartDate]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."EndDate"'),127) [EndDate]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."ChecksLoaded"')), 0) [ChecksLoaded]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."ProductionCalculated"')), 0) [ProductionCalculated]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."startBalance"')), 0) [startBalance]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."endBalance"')), 0) [endBalance]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."ErrorCount"')), 0) [ErrorCount]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."ProductionId"')), '') [ProductionId]
      FROM dbo.[Documents]
      WHERE [operation] = '72D21520-144D-11EB-B23D-A9B204614E62'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.CashShifts.v] ON [Operation.CashShifts.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.CashShifts.v.date] ON[Operation.CashShifts.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CashShifts.v.parent] ON [Operation.CashShifts.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CashShifts.v.deleted] ON [Operation.CashShifts.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CashShifts.v.code] ON [Operation.CashShifts.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CashShifts.v.user] ON [Operation.CashShifts.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CashShifts.v.company] ON [Operation.CashShifts.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.CashShifts.v]TO jetti; 
      RAISERROR('Operation.CashShifts finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.CashShifts ------------------------------

      
------------------------------ BEGIN Operation.CHECK_JETTI_FRONT ------------------------------

      RAISERROR('Operation.CHECK_JETTI_FRONT start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.CHECK_JETTI_FRONT.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Department"')) [Department]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Manager"')) [Manager]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Customer"')) [Customer]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Storehouse"')) [Storehouse]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."DiscountDoc"')), 0) [DiscountDoc]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."NumCashShift"')), '') [NumCashShift]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."TypeDocument"')), '') [TypeDocument]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."PrintTime"'),127) [PrintTime]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."TypeOfFranchise"')), '') [TypeOfFranchise]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."DeliveryType"')), '') [DeliveryType]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."OrderSource"')), '') [OrderSource]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ParentOrderSource"')) [ParentOrderSource]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Aggregator"')) [Aggregator]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."DeliveryArea"')), 0) [DeliveryArea]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Courier"')) [Courier]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."counterpartyId"')), '') [counterpartyId]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailClient"')) [RetailClient]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."orderId"')), '') [orderId]
      FROM dbo.[Documents]
      WHERE [operation] = '1D5BE740-298A-11EB-87AE-6D4972EE7833'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v] ON [Operation.CHECK_JETTI_FRONT.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.CHECK_JETTI_FRONT.v.date] ON[Operation.CHECK_JETTI_FRONT.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v.parent] ON [Operation.CHECK_JETTI_FRONT.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v.deleted] ON [Operation.CHECK_JETTI_FRONT.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v.code] ON [Operation.CHECK_JETTI_FRONT.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v.user] ON [Operation.CHECK_JETTI_FRONT.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.CHECK_JETTI_FRONT.v.company] ON [Operation.CHECK_JETTI_FRONT.v](company,id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.CHECK_JETTI_FRONT.v.Department] ON[Operation.CHECK_JETTI_FRONT.v](Department, id) INCLUDE([company]);
CREATE UNIQUE NONCLUSTERED INDEX[Operation.CHECK_JETTI_FRONT.v.Customer] ON[Operation.CHECK_JETTI_FRONT.v](Customer, id) INCLUDE([company]);
CREATE UNIQUE NONCLUSTERED INDEX[Operation.CHECK_JETTI_FRONT.v.Storehouse] ON[Operation.CHECK_JETTI_FRONT.v](Storehouse, id) INCLUDE([company]);
GO
GRANT SELECT ON dbo.[Operation.CHECK_JETTI_FRONT.v]TO jetti; 
      RAISERROR('Operation.CHECK_JETTI_FRONT finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.CHECK_JETTI_FRONT ------------------------------

      
------------------------------ BEGIN Operation.DeliveryAreas ------------------------------

      RAISERROR('Operation.DeliveryAreas start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.DeliveryAreas.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
      , ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."MapUrl"')), '') [MapUrl]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."LoadFolder"')), '') [LoadFolder]
      FROM dbo.[Documents]
      WHERE [operation] = '3C593A00-32FC-11EB-9D67-5B583D0A1D7D'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.DeliveryAreas.v] ON [Operation.DeliveryAreas.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.DeliveryAreas.v.date] ON[Operation.DeliveryAreas.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.DeliveryAreas.v.parent] ON [Operation.DeliveryAreas.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.DeliveryAreas.v.deleted] ON [Operation.DeliveryAreas.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.DeliveryAreas.v.code] ON [Operation.DeliveryAreas.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.DeliveryAreas.v.user] ON [Operation.DeliveryAreas.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.DeliveryAreas.v.company] ON [Operation.DeliveryAreas.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.DeliveryAreas.v]TO jetti; 
      RAISERROR('Operation.DeliveryAreas finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.DeliveryAreas ------------------------------

      
------------------------------ BEGIN Operation.Group_Create_CashRequests ------------------------------

      RAISERROR('Operation.Group_Create_CashRequests start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.Group_Create_CashRequests.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."ResponsibilityCenter"')) [ResponsibilityCenter]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."GroupSettings"')) [GroupSettings]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."BDate"'),127) [BDate]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."EDate"'),127) [EDate]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SalaryAnalytics"')) [SalaryAnalytics]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."Status_Log"')), '') [Status_Log]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashFlow"')) [CashFlow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CashRegisterByDefault"')) [CashRegisterByDefault]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."isPayByDepartmentOfPerson"')), 0) [isPayByDepartmentOfPerson]
      FROM dbo.[Documents]
      WHERE [operation] = '22F78600-F4AD-11ED-BDD8-81F4104CEA7C'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.Group_Create_CashRequests.v] ON [Operation.Group_Create_CashRequests.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.Group_Create_CashRequests.v.date] ON[Operation.Group_Create_CashRequests.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Group_Create_CashRequests.v.parent] ON [Operation.Group_Create_CashRequests.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Group_Create_CashRequests.v.deleted] ON [Operation.Group_Create_CashRequests.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Group_Create_CashRequests.v.code] ON [Operation.Group_Create_CashRequests.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Group_Create_CashRequests.v.user] ON [Operation.Group_Create_CashRequests.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Group_Create_CashRequests.v.company] ON [Operation.Group_Create_CashRequests.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.Group_Create_CashRequests.v]TO jetti; 
      RAISERROR('Operation.Group_Create_CashRequests finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.Group_Create_CashRequests ------------------------------

      
------------------------------ BEGIN Operation.OnlineSalesManagementSettings ------------------------------

      RAISERROR('Operation.OnlineSalesManagementSettings start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.OnlineSalesManagementSettings.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."BusinessRegion"')) [BusinessRegion]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."RetailNetwork"')) [RetailNetwork]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."TypeShowcase"')), '') [TypeShowcase]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."Status"')), '') [Status]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."DateBegin"'),127) [DateBegin]
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."DateEnd"'),127) [DateEnd]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."SourceAggr"')) [SourceAggr]
      FROM dbo.[Documents]
      WHERE [operation] = '12917090-5CCB-11EB-AAD1-616C53FDF9AB'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v] ON [Operation.OnlineSalesManagementSettings.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.OnlineSalesManagementSettings.v.date] ON[Operation.OnlineSalesManagementSettings.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v.parent] ON [Operation.OnlineSalesManagementSettings.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v.deleted] ON [Operation.OnlineSalesManagementSettings.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v.code] ON [Operation.OnlineSalesManagementSettings.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v.user] ON [Operation.OnlineSalesManagementSettings.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.OnlineSalesManagementSettings.v.company] ON [Operation.OnlineSalesManagementSettings.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.OnlineSalesManagementSettings.v]TO jetti; 
      RAISERROR('Operation.OnlineSalesManagementSettings finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.OnlineSalesManagementSettings ------------------------------

      
------------------------------ BEGIN Operation.Registry_Share_Sert ------------------------------

      RAISERROR('Operation.Registry_Share_Sert start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.Registry_Share_Sert.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."CounterpartieOrPerson"')) [CounterpartieOrPerson]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."PersonOwnerStocks"')) [PersonOwnerStocks]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."OwnerStocksVia"')) [OwnerStocksVia]
      , ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."separator_1"')), '') [separator_1]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."PersonOwnerStocks_isEmployee"')), 0) [PersonOwnerStocks_isEmployee]
      FROM dbo.[Documents]
      WHERE [operation] = '3883A530-5511-11ED-BDA4-E52E2CDB3CB6'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.Registry_Share_Sert.v] ON [Operation.Registry_Share_Sert.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.Registry_Share_Sert.v.date] ON[Operation.Registry_Share_Sert.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Registry_Share_Sert.v.parent] ON [Operation.Registry_Share_Sert.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Registry_Share_Sert.v.deleted] ON [Operation.Registry_Share_Sert.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Registry_Share_Sert.v.code] ON [Operation.Registry_Share_Sert.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Registry_Share_Sert.v.user] ON [Operation.Registry_Share_Sert.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.Registry_Share_Sert.v.company] ON [Operation.Registry_Share_Sert.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.Registry_Share_Sert.v]TO jetti; 
      RAISERROR('Operation.Registry_Share_Sert finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.Registry_Share_Sert ------------------------------

      
------------------------------ BEGIN Operation.SyncManual ------------------------------

      RAISERROR('Operation.SyncManual start', 0 ,1) WITH NOWAIT;
      CREATE OR ALTER VIEW dbo.[Operation.SyncManual.v] WITH SCHEMABINDING AS 
      SELECT id, type, date, code, description, posted, deleted, isfolder, timestamp, parent, company, [user], [version]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."workflow"')) [workflow]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Group"')) [Group]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."Operation"')) [Operation]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."Amount"')), 0) [Amount]
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."currency"')) [currency]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."About"')), '') [About]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."logLevel"')), 0) [logLevel]
      , ISNULL(TRY_CONVERT(NVARCHAR(36), JSON_VALUE(doc,N'$."Source"')), '') [Source]
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."forsedUpdate"')), 0) [forsedUpdate]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."periodBegin"'),127) [periodBegin]
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."periodEnd"'),127) [periodEnd]
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."flow"')), 0) [flow]
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc, N'$."exchangeID"')), '') [exchangeID]
      FROM dbo.[Documents]
      WHERE [operation] = '9CA5E6D0-F803-11EA-ADBF-956D134E29F5'
; 
GO
CREATE UNIQUE CLUSTERED INDEX [Operation.SyncManual.v] ON [Operation.SyncManual.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[Operation.SyncManual.v.date] ON[Operation.SyncManual.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.SyncManual.v.parent] ON [Operation.SyncManual.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.SyncManual.v.deleted] ON [Operation.SyncManual.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.SyncManual.v.code] ON [Operation.SyncManual.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.SyncManual.v.user] ON [Operation.SyncManual.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [Operation.SyncManual.v.company] ON [Operation.SyncManual.v](company,id);
      
GO
GRANT SELECT ON dbo.[Operation.SyncManual.v]TO jetti; 
      RAISERROR('Operation.SyncManual finish', 0 ,1) WITH NOWAIT;
      
------------------------------ BEGIN Operation.SyncManual ------------------------------

      