
------------------------------ BEGIN Register.Info.Dynamic ------------------------------

    CREATE OR ALTER VIEW [Register.Info.Dynamic]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.Dynamic';
    GO
    GRANT SELECT, DELETE ON [Register.Info.Dynamic] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.Dynamic] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.Dynamic] ON [dbo].[Register.Info.Dynamic]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.Dynamic ------------------------------

------------------------------ BEGIN Register.Info.Holiday ------------------------------

    CREATE OR ALTER VIEW [Register.Info.Holiday]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Country"')) [Country]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Info"')) [Info]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.Holiday';
    GO
    GRANT SELECT, DELETE ON [Register.Info.Holiday] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.Holiday] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.Holiday] ON [dbo].[Register.Info.Holiday]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.Holiday ------------------------------

------------------------------ BEGIN Register.Info.BusinessCalendar ------------------------------

    CREATE OR ALTER VIEW [Register.Info.BusinessCalendar]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."BusinessCalendar"')) [BusinessCalendar]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."DayType"')) [DayType]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."DayTransfer"'),127) [DayTransfer]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Year"')) [Year]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.BusinessCalendar';
    GO
    GRANT SELECT, DELETE ON [Register.Info.BusinessCalendar] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.BusinessCalendar] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.BusinessCalendar] ON [dbo].[Register.Info.BusinessCalendar]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.BusinessCalendar ------------------------------

------------------------------ BEGIN Register.Info.BusinessCalendar.Months ------------------------------

    CREATE OR ALTER VIEW [Register.Info.BusinessCalendar.Months]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."BusinessCalendar"')) [BusinessCalendar]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."TotalDay"')) [TotalDay]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."WorkDay"')) [WorkDay]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."WorkHours40"')) [WorkHours40]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."WorkHours36"')) [WorkHours36]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."WorkHours24"')) [WorkHours24]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.BusinessCalendar.Months';
    GO
    GRANT SELECT, DELETE ON [Register.Info.BusinessCalendar.Months] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.BusinessCalendar.Months] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.BusinessCalendar.Months] ON [dbo].[Register.Info.BusinessCalendar.Months]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.BusinessCalendar.Months ------------------------------

------------------------------ BEGIN Register.Info.PriceList ------------------------------

    CREATE OR ALTER VIEW [Register.Info.PriceList]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Storehouse"')) [Storehouse]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Product"')) [Product]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Role"')) [Role]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Unit"')) [Unit]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."PriceType"')) [PriceType]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Price"')) [Price]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."forSales"')) [forSales]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."forPurchases"')) [forPurchases]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."isActive"')) [isActive]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.PriceList';
    GO
    GRANT SELECT, DELETE ON [Register.Info.PriceList] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.PriceList] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.PriceList] ON [dbo].[Register.Info.PriceList]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.PriceList ------------------------------

------------------------------ BEGIN Register.Info.SelfEmployed ------------------------------

    CREATE OR ALTER VIEW [Register.Info.SelfEmployed]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Person"')) [Person]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Contract"')) [Contract]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."BankAccount"')) [BankAccount]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."isActive"')) [isActive]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.SelfEmployed';
    GO
    GRANT SELECT, DELETE ON [Register.Info.SelfEmployed] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.SelfEmployed] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.SelfEmployed] ON [dbo].[Register.Info.SelfEmployed]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.SelfEmployed ------------------------------

------------------------------ BEGIN Register.Info.ProductModifier ------------------------------

    CREATE OR ALTER VIEW [Register.Info.ProductModifier]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Product"')) [Product]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Modifier"')) [Modifier]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Qty"')) [Qty]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.ProductModifier';
    GO
    GRANT SELECT, DELETE ON [Register.Info.ProductModifier] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.ProductModifier] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.ProductModifier] ON [dbo].[Register.Info.ProductModifier]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.ProductModifier ------------------------------

------------------------------ BEGIN Register.Info.SettlementsReconciliation ------------------------------

    CREATE OR ALTER VIEW [Register.Info.SettlementsReconciliation]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Customer"')) [Customer]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Contract"')) [Contract]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Status"')) [Status]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."Period"'),127) [Period]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Operation"')) [Operation]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."OperationDescription"')) [OperationDescription]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."OperationInDocNumber"')) [OperationInDocNumber]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."OperationInDocDate"'),127) [OperationInDocDate]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Comment"')) [Comment]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Amount"')) [Amount]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountPaid"')) [AmountPaid]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountBalance"')) [AmountBalance]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.SettlementsReconciliation';
    GO
    GRANT SELECT, DELETE ON [Register.Info.SettlementsReconciliation] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.SettlementsReconciliation] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.SettlementsReconciliation] ON [dbo].[Register.Info.SettlementsReconciliation]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.SettlementsReconciliation ------------------------------

------------------------------ BEGIN Register.Info.ExchangeRates ------------------------------

    CREATE OR ALTER VIEW [Register.Info.ExchangeRates]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Rate"')) [Rate]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Mutiplicity"')) [Mutiplicity]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.ExchangeRates';
    GO
    GRANT SELECT, DELETE ON [Register.Info.ExchangeRates] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.ExchangeRates] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.ExchangeRates] ON [dbo].[Register.Info.ExchangeRates]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.ExchangeRates.currency] ON [Register.Info.ExchangeRates]([currency]);
    GO
------------------------------ END Register.Info.ExchangeRates ------------------------------

------------------------------ BEGIN Register.Info.ExchangeRates.National ------------------------------

    CREATE OR ALTER VIEW [Register.Info.ExchangeRates.National]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Country"')) [Country]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Currency1"')) [Currency1]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Currency2"')) [Currency2]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Rate"')) [Rate]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Mutiplicity"')) [Mutiplicity]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.ExchangeRates.National';
    GO
    GRANT SELECT, DELETE ON [Register.Info.ExchangeRates.National] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.ExchangeRates.National] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.ExchangeRates.National] ON [dbo].[Register.Info.ExchangeRates.National]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.ExchangeRates.National ------------------------------

------------------------------ BEGIN Register.Info.ProductSpecificationByDepartment ------------------------------

    CREATE OR ALTER VIEW [Register.Info.ProductSpecificationByDepartment]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Storehouse"')) [Storehouse]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Product"')) [Product]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Specification"')) [Specification]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."isActive"')) [isActive]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.ProductSpecificationByDepartment';
    GO
    GRANT SELECT, DELETE ON [Register.Info.ProductSpecificationByDepartment] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.ProductSpecificationByDepartment] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.ProductSpecificationByDepartment] ON [dbo].[Register.Info.ProductSpecificationByDepartment]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.ProductSpecificationByDepartment ------------------------------

------------------------------ BEGIN Register.Info.AdditionalProps ------------------------------

    CREATE OR ALTER VIEW [Register.Info.AdditionalProps]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."AddProp"')) [AddProp]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Object"')) [Object]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Analytic1"')) [Analytic1]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Analytic2"')) [Analytic2]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."ValueRef"')) [ValueRef]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."ValueNumber"')) [ValueNumber]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."ValueString"')) [ValueString]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."ValueDate"'),127) [ValueDate]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."ValueBoolean"')) [ValueBoolean]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.AdditionalProps';
    GO
    GRANT SELECT, DELETE ON [Register.Info.AdditionalProps] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.AdditionalProps] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.AdditionalProps] ON [dbo].[Register.Info.AdditionalProps]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.AdditionalProps.AddProp] ON [Register.Info.AdditionalProps]([AddProp]);
    CREATE NONCLUSTERED INDEX[Register.Info.AdditionalProps.Object] ON [Register.Info.AdditionalProps]([Object]);
    CREATE NONCLUSTERED INDEX[Register.Info.AdditionalProps.Analytic1] ON [Register.Info.AdditionalProps]([Analytic1]);
    CREATE NONCLUSTERED INDEX[Register.Info.AdditionalProps.Analytic2] ON [Register.Info.AdditionalProps]([Analytic2]);
    GO
------------------------------ END Register.Info.AdditionalProps ------------------------------

------------------------------ BEGIN Register.Info.Depreciation ------------------------------

    CREATE OR ALTER VIEW [Register.Info.Depreciation]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."OE"')) [OE]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."StartDate"'),127) [StartDate]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Period"')) [Period]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."StartCost"')) [StartCost]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."EndCost"')) [EndCost]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Method"')) [Method]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.Depreciation';
    GO
    GRANT SELECT, DELETE ON [Register.Info.Depreciation] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.Depreciation] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.Depreciation] ON [dbo].[Register.Info.Depreciation]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.Depreciation ------------------------------

------------------------------ BEGIN Register.Info.RLS.Period ------------------------------

    CREATE OR ALTER VIEW [Register.Info.RLS.Period]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."user"')) [user]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."partition"')) [partition]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.RLS.Period';
    GO
    GRANT SELECT, DELETE ON [Register.Info.RLS.Period] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.RLS.Period] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.RLS.Period] ON [dbo].[Register.Info.RLS.Period]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.RLS.Period ------------------------------

------------------------------ BEGIN Register.Info.RLS ------------------------------

    CREATE OR ALTER VIEW [Register.Info.RLS]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."user"')) [user]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.RLS';
    GO
    GRANT SELECT, DELETE ON [Register.Info.RLS] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.RLS] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.RLS] ON [dbo].[Register.Info.RLS]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.RLS ------------------------------

------------------------------ BEGIN Register.Info.BudgetItemRule ------------------------------

    CREATE OR ALTER VIEW [Register.Info.BudgetItemRule]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."BudgetItem"')) [BudgetItem]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Scenario"')) [Scenario]
        , JSON_VALUE(data, N'$."Rule"') [Rule]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.BudgetItemRule';
    GO
    GRANT SELECT, DELETE ON [Register.Info.BudgetItemRule] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.BudgetItemRule] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.BudgetItemRule] ON [dbo].[Register.Info.BudgetItemRule]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.BudgetItemRule ------------------------------

------------------------------ BEGIN Register.Info.IntercompanyHistory ------------------------------

    CREATE OR ALTER VIEW [Register.Info.IntercompanyHistory]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Intercompany"')) [Intercompany]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.IntercompanyHistory';
    GO
    GRANT SELECT, DELETE ON [Register.Info.IntercompanyHistory] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.IntercompanyHistory] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.IntercompanyHistory] ON [dbo].[Register.Info.IntercompanyHistory]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.IntercompanyHistory ------------------------------

------------------------------ BEGIN Register.Info.DepartmentCompanyHistory ------------------------------

    CREATE OR ALTER VIEW [Register.Info.DepartmentCompanyHistory]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department2"')) [Department2]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."company2"')) [company2]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."InvestorGroup"')) [InvestorGroup]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."TypeFranchise"')) [TypeFranchise]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.DepartmentCompanyHistory';
    GO
    GRANT SELECT, DELETE ON [Register.Info.DepartmentCompanyHistory] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.DepartmentCompanyHistory] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.DepartmentCompanyHistory] ON [dbo].[Register.Info.DepartmentCompanyHistory]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.DepartmentCompanyHistory ------------------------------

------------------------------ BEGIN Register.Info.Department.LimitIndicators ------------------------------

    CREATE OR ALTER VIEW [Register.Info.Department.LimitIndicators]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."RetailNetwork"')) [RetailNetwork]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."TermStarts"'),127) [TermStarts]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."TermEnds"'),127) [TermEnds]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."TimeStart"'),127) [TimeStart]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."TimeFinish"'),127) [TimeFinish]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."MaxOrderCount"')) [MaxOrderCount]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."MaxOrderTotalAmount"')) [MaxOrderTotalAmount]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.Department.LimitIndicators';
    GO
    GRANT SELECT, DELETE ON [Register.Info.Department.LimitIndicators] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.Department.LimitIndicators] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.Department.LimitIndicators] ON [dbo].[Register.Info.Department.LimitIndicators]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.Department.LimitIndicators.RetailNetwork] ON [Register.Info.Department.LimitIndicators]([RetailNetwork]);
    CREATE NONCLUSTERED INDEX[Register.Info.Department.LimitIndicators.Department] ON [Register.Info.Department.LimitIndicators]([Department]);
    GO
------------------------------ END Register.Info.Department.LimitIndicators ------------------------------

------------------------------ BEGIN Register.Info.DepartmentStatus ------------------------------

    CREATE OR ALTER VIEW [Register.Info.DepartmentStatus]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."RetailNetwork"')) [RetailNetwork]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."BeginDate"'),127) [BeginDate]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."EndDate"'),127) [EndDate]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Info"')) [Info]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."StatusReason"')) [StatusReason]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.DepartmentStatus';
    GO
    GRANT SELECT, DELETE ON [Register.Info.DepartmentStatus] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.DepartmentStatus] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.DepartmentStatus] ON [dbo].[Register.Info.DepartmentStatus]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.DepartmentStatus ------------------------------

------------------------------ BEGIN Register.Info.CounterpartiePriceList ------------------------------

    CREATE OR ALTER VIEW [Register.Info.CounterpartiePriceList]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Scenario"')) [Scenario]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Counterpartie"')) [Counterpartie]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Contract"')) [Contract]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."DocNumber"')) [DocNumber]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."DocDate"'),127) [DocDate]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Storehouse"')) [Storehouse]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Product"')) [Product]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Qty"')) [Qty]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Price"')) [Price]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Cost"')) [Cost]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.CounterpartiePriceList';
    GO
    GRANT SELECT, DELETE ON [Register.Info.CounterpartiePriceList] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.CounterpartiePriceList] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.CounterpartiePriceList] ON [dbo].[Register.Info.CounterpartiePriceList]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.CounterpartiePriceList ------------------------------

------------------------------ BEGIN Register.Info.CompanyResponsiblePersons ------------------------------

    CREATE OR ALTER VIEW [Register.Info.CompanyResponsiblePersons]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Role"')) [Role]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."OperationType"')) [OperationType]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."companyOrGroup"')) [companyOrGroup]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."InvestorGroup"')) [InvestorGroup]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Loan"')) [Loan]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."User"')) [User]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Person"')) [Person]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Employee"')) [Employee]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."isActive"')) [isActive]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."GrantSales"')) [GrantSales]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."GrantPL"')) [GrantPL]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.CompanyResponsiblePersons';
    GO
    GRANT SELECT, DELETE ON [Register.Info.CompanyResponsiblePersons] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.CompanyResponsiblePersons] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.CompanyResponsiblePersons] ON [dbo].[Register.Info.CompanyResponsiblePersons]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.CompanyResponsiblePersons ------------------------------

------------------------------ BEGIN Register.Info.IncomeDocumentRegistry ------------------------------

    CREATE OR ALTER VIEW [Register.Info.IncomeDocumentRegistry]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."StatusRegistry"')) [StatusRegistry]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."OperationType"')) [OperationType]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Counterpartie"')) [Counterpartie]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Currency"')) [Currency]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."DocNumber"')) [DocNumber]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."DocJETTI"')) [DocJETTI]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountIncome"')) [AmountIncome]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountJETTI"')) [AmountJETTI]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."ReasonType"')) [ReasonType]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.IncomeDocumentRegistry';
    GO
    GRANT SELECT, DELETE ON [Register.Info.IncomeDocumentRegistry] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.IncomeDocumentRegistry] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.IncomeDocumentRegistry] ON [dbo].[Register.Info.IncomeDocumentRegistry]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.IncomeDocumentRegistry.DocJETTI] ON [Register.Info.IncomeDocumentRegistry]([DocJETTI]);
    GO
------------------------------ END Register.Info.IncomeDocumentRegistry ------------------------------

------------------------------ BEGIN Register.Info.CompanyPrice ------------------------------

    CREATE OR ALTER VIEW [Register.Info.CompanyPrice]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."CompanyPrice"')) [CompanyPrice]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.CompanyPrice';
    GO
    GRANT SELECT, DELETE ON [Register.Info.CompanyPrice] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.CompanyPrice] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.CompanyPrice] ON [dbo].[Register.Info.CompanyPrice]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.CompanyPrice ------------------------------

------------------------------ BEGIN Register.Info.ShareEmission ------------------------------

    CREATE OR ALTER VIEW [Register.Info.ShareEmission]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."OperationType"')) [OperationType]
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."isActive"')) [isActive]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."InvestorGroup"')) [InvestorGroup]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."CompanyGroup"')) [CompanyGroup]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Loan"')) [Loan]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Person"')) [Person]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."currency"')) [currency]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Qty"')) [Qty]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Price"')) [Price]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Amount"')) [Amount]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Share"')) [Share]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."ShareAmount"')) [ShareAmount]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.ShareEmission';
    GO
    GRANT SELECT, DELETE ON [Register.Info.ShareEmission] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.ShareEmission] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.ShareEmission] ON [dbo].[Register.Info.ShareEmission]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.ShareEmission ------------------------------

------------------------------ BEGIN Register.Info.LoanOwner ------------------------------

    CREATE OR ALTER VIEW [Register.Info.LoanOwner]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."InvestorGroup"')) [InvestorGroup]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."User"')) [User]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."LoanOwner"')) [LoanOwner]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.LoanOwner';
    GO
    GRANT SELECT, DELETE ON [Register.Info.LoanOwner] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.LoanOwner] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.LoanOwner] ON [dbo].[Register.Info.LoanOwner]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.LoanOwner ------------------------------

------------------------------ BEGIN Register.Info.Intl ------------------------------

    CREATE OR ALTER VIEW [Register.Info.Intl]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Catalog"')) [Catalog]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Property"')) [Property]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Language"')) [Language]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."Value"')) [Value]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."DativeCase"')) [DativeCase]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."NominativeCase"')) [NominativeCase]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."PrepositionalCase"')) [PrepositionalCase]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.Intl';
    GO
    GRANT SELECT, DELETE ON [Register.Info.Intl] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.Intl] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.Intl] ON [dbo].[Register.Info.Intl]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.Intl.Catalog] ON [Register.Info.Intl]([Catalog]);
    CREATE NONCLUSTERED INDEX[Register.Info.Intl.Property] ON [Register.Info.Intl]([Property]);
    GO
------------------------------ END Register.Info.Intl ------------------------------

------------------------------ BEGIN Register.Info.RoyaltySales ------------------------------

    CREATE OR ALTER VIEW [Register.Info.RoyaltySales]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountMin"')) [AmountMin]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."AmountMax"')) [AmountMax]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Royalty"')) [Royalty]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.RoyaltySales';
    GO
    GRANT SELECT, DELETE ON [Register.Info.RoyaltySales] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.RoyaltySales] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.RoyaltySales] ON [dbo].[Register.Info.RoyaltySales]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.RoyaltySales ------------------------------

------------------------------ BEGIN Register.Info.EmployeeHistory ------------------------------

    CREATE OR ALTER VIEW [Register.Info.EmployeeHistory]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Employee"')) [Employee]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Person"')) [Person]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."DepartmentCompany"')) [DepartmentCompany]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."JobTitle"')) [JobTitle]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."StaffingPosition"')) [StaffingPosition]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."OperationType"')) [OperationType]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."SalaryRate"')) [SalaryRate]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.EmployeeHistory';
    GO
    GRANT SELECT, DELETE ON [Register.Info.EmployeeHistory] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.EmployeeHistory] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.EmployeeHistory] ON [dbo].[Register.Info.EmployeeHistory]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.EmployeeHistory ------------------------------

------------------------------ BEGIN Register.Info.EmploymentType ------------------------------

    CREATE OR ALTER VIEW [Register.Info.EmploymentType]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."EmploymentType"')) [EmploymentType]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Employee"')) [Employee]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Person"')) [Person]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."DepartmentCompany"')) [DepartmentCompany]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."JobTitle"')) [JobTitle]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."StaffingPosition"')) [StaffingPosition]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."SalaryRate"')) [SalaryRate]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.EmploymentType';
    GO
    GRANT SELECT, DELETE ON [Register.Info.EmploymentType] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.EmploymentType] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.EmploymentType] ON [dbo].[Register.Info.EmploymentType]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.EmploymentType ------------------------------

------------------------------ BEGIN Register.Info.StaffingTableHistory ------------------------------

    CREATE OR ALTER VIEW [Register.Info.StaffingTableHistory]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Department"')) [Department]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."DepartmentCompany"')) [DepartmentCompany]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."StaffingPosition"')) [StaffingPosition]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."SalaryAnalytic"')) [SalaryAnalytic]
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."Currency"')) [Currency]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."AccrualType"')) [AccrualType]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."ActivationDate"'),127) [ActivationDate]
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."CloseDate"'),127) [CloseDate]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Qty"')) [Qty]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."Cost"')) [Cost]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.StaffingTableHistory';
    GO
    GRANT SELECT, DELETE ON [Register.Info.StaffingTableHistory] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.StaffingTableHistory] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.StaffingTableHistory] ON [dbo].[Register.Info.StaffingTableHistory]([company], [date], [id])
    
    GO
------------------------------ END Register.Info.StaffingTableHistory ------------------------------

------------------------------ BEGIN Register.Info.TaxCheck ------------------------------

    CREATE OR ALTER VIEW [Register.Info.TaxCheck]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."clientInn"')) [clientInn]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."inn"')) [inn]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."totalAmount"')) [totalAmount]
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."receiptId"')) [receiptId]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."operationTime"'),127) [operationTime]
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."modifyDate"'),127) [modifyDate]
      FROM dbo.[Register.Info] WHERE type = N'Register.Info.TaxCheck';
    GO
    GRANT SELECT, DELETE ON [Register.Info.TaxCheck] TO JETTI;
    GO
    GRANT SELECT ON [Register.Info.TaxCheck] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [Register.Info.TaxCheck] ON [dbo].[Register.Info.TaxCheck]([company], [date], [id])
    CREATE NONCLUSTERED INDEX[Register.Info.TaxCheck.clientInn] ON [Register.Info.TaxCheck]([clientInn]);
    CREATE NONCLUSTERED INDEX[Register.Info.TaxCheck.inn] ON [Register.Info.TaxCheck]([inn]);
    CREATE NONCLUSTERED INDEX[Register.Info.TaxCheck.receiptId] ON [Register.Info.TaxCheck]([receiptId]);
    GO
------------------------------ END Register.Info.TaxCheck ------------------------------
