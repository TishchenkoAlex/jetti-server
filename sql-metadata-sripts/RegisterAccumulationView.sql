
    
------------------------------ BEGIN Register.Accumulation.AccountablePersons ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.AccountablePersons]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, Employee, CashFlow
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
      , d.[AmountToPay] * IIF(r.kind = 1, 1, -1) [AmountToPay], d.[AmountToPay] * IIF(r.kind = 1, 1, null) [AmountToPay.In], d.[AmountToPay] * IIF(r.kind = 1, null, 1) [AmountToPay.Out]
      , d.[AmountIsPaid] * IIF(r.kind = 1, 1, -1) [AmountIsPaid], d.[AmountIsPaid] * IIF(r.kind = 1, 1, null) [AmountIsPaid.In], d.[AmountIsPaid] * IIF(r.kind = 1, null, 1) [AmountIsPaid.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Employee] UNIQUEIDENTIFIER N'$.Employee'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [AmountToPay] MONEY N'$.AmountToPay'
        , [AmountIsPaid] MONEY N'$.AmountIsPaid'
        ) AS d
        WHERE r.type = N'Register.Accumulation.AccountablePersons';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.AccountablePersons] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.AccountablePersons] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.AccountablePersons ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.PaymentBatch ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.PaymentBatch]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, PaymentsKind, Counterpartie, ProductPackage, Product, Currency, batch, PayDay
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
      , d.[Price] * IIF(r.kind = 1, 1, -1) [Price], d.[Price] * IIF(r.kind = 1, 1, null) [Price.In], d.[Price] * IIF(r.kind = 1, null, 1) [Price.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [PaymentsKind] NVARCHAR(250) N'$.PaymentsKind'
        , [Counterpartie] UNIQUEIDENTIFIER N'$.Counterpartie'
        , [ProductPackage] UNIQUEIDENTIFIER N'$.ProductPackage'
        , [Product] UNIQUEIDENTIFIER N'$.Product'
        , [Currency] UNIQUEIDENTIFIER N'$.Currency'
        , [batch] UNIQUEIDENTIFIER N'$.batch'
        , [PayDay] DATE N'$.PayDay'
        , [Qty] MONEY N'$.Qty'
        , [Price] MONEY N'$.Price'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        ) AS d
        WHERE r.type = N'Register.Accumulation.PaymentBatch';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.PaymentBatch] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.PaymentBatch] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.PaymentBatch ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Investment.Analytics ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Investment.Analytics]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Department, SourceTransaction, CreditTransaction, OperationType, Analytics, Analytics2, Investor, CompanyProduct, Product
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out], CurrencyProduct
      , d.[AmountProduct] * IIF(r.kind = 1, 1, -1) [AmountProduct], d.[AmountProduct] * IIF(r.kind = 1, 1, null) [AmountProduct.In], d.[AmountProduct] * IIF(r.kind = 1, null, 1) [AmountProduct.Out], PaymentSource, CurrencySource
      , d.[AmountSource] * IIF(r.kind = 1, 1, -1) [AmountSource], d.[AmountSource] * IIF(r.kind = 1, 1, null) [AmountSource.In], d.[AmountSource] * IIF(r.kind = 1, null, 1) [AmountSource.Out], CompanyLoan, Loan, CurrencyLoan
      , d.[AmountLoan] * IIF(r.kind = 1, 1, -1) [AmountLoan], d.[AmountLoan] * IIF(r.kind = 1, 1, null) [AmountLoan.In], d.[AmountLoan] * IIF(r.kind = 1, null, 1) [AmountLoan.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [SourceTransaction] NVARCHAR(250) N'$.SourceTransaction'
        , [CreditTransaction] UNIQUEIDENTIFIER N'$.CreditTransaction'
        , [OperationType] UNIQUEIDENTIFIER N'$.OperationType'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Analytics2] UNIQUEIDENTIFIER N'$.Analytics2'
        , [Investor] UNIQUEIDENTIFIER N'$.Investor'
        , [CompanyProduct] UNIQUEIDENTIFIER N'$.CompanyProduct'
        , [Product] UNIQUEIDENTIFIER N'$.Product'
        , [Qty] MONEY N'$.Qty'
        , [CurrencyProduct] UNIQUEIDENTIFIER N'$.CurrencyProduct'
        , [AmountProduct] MONEY N'$.AmountProduct'
        , [PaymentSource] UNIQUEIDENTIFIER N'$.PaymentSource'
        , [CurrencySource] UNIQUEIDENTIFIER N'$.CurrencySource'
        , [AmountSource] MONEY N'$.AmountSource'
        , [CompanyLoan] UNIQUEIDENTIFIER N'$.CompanyLoan'
        , [Loan] UNIQUEIDENTIFIER N'$.Loan'
        , [CurrencyLoan] UNIQUEIDENTIFIER N'$.CurrencyLoan'
        , [AmountLoan] MONEY N'$.AmountLoan'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Investment.Analytics';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Investment.Analytics] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Investment.Analytics] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Investment.Analytics ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.OrderPayment ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.OrderPayment]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, PaymantKind, Customer, BankAccount, CashRegister, AcquiringTerminal, currency, Department
      , d.[CashShift] * IIF(r.kind = 1, 1, -1) [CashShift], d.[CashShift] * IIF(r.kind = 1, 1, null) [CashShift.In], d.[CashShift] * IIF(r.kind = 1, null, 1) [CashShift.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [PaymantKind] NVARCHAR(250) N'$.PaymantKind'
        , [Customer] UNIQUEIDENTIFIER N'$.Customer'
        , [BankAccount] UNIQUEIDENTIFIER N'$.BankAccount'
        , [CashRegister] UNIQUEIDENTIFIER N'$.CashRegister'
        , [AcquiringTerminal] UNIQUEIDENTIFIER N'$.AcquiringTerminal'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [CashShift] MONEY N'$.CashShift'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.OrderPayment';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.OrderPayment] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.OrderPayment] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.OrderPayment ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.OrderProduct ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.OrderProduct]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, OrderType, MovementType, RetailNetwork, Supplier, Customer, SenderDepartment, SenderStorehouse, RecipientDepartment, RecipientStorehouse, currency, Product, OrderBatch, OrderRow
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [OrderType] UNIQUEIDENTIFIER N'$.OrderType'
        , [MovementType] UNIQUEIDENTIFIER N'$.MovementType'
        , [RetailNetwork] UNIQUEIDENTIFIER N'$.RetailNetwork'
        , [Supplier] UNIQUEIDENTIFIER N'$.Supplier'
        , [Customer] UNIQUEIDENTIFIER N'$.Customer'
        , [SenderDepartment] UNIQUEIDENTIFIER N'$.SenderDepartment'
        , [SenderStorehouse] UNIQUEIDENTIFIER N'$.SenderStorehouse'
        , [RecipientDepartment] UNIQUEIDENTIFIER N'$.RecipientDepartment'
        , [RecipientStorehouse] UNIQUEIDENTIFIER N'$.RecipientStorehouse'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Product] UNIQUEIDENTIFIER N'$.Product'
        , [OrderBatch] UNIQUEIDENTIFIER N'$.OrderBatch'
        , [OrderRow] NVARCHAR(250) N'$.OrderRow'
        , [Qty] MONEY N'$.Qty'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.OrderProduct';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.OrderProduct] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.OrderProduct] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.OrderProduct ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.AP ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.AP]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, AO, Supplier, Department, SupplierDocDate, PayDay
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
      , d.[AmountToPay] * IIF(r.kind = 1, 1, -1) [AmountToPay], d.[AmountToPay] * IIF(r.kind = 1, 1, null) [AmountToPay.In], d.[AmountToPay] * IIF(r.kind = 1, null, 1) [AmountToPay.Out]
      , d.[AmountIsPaid] * IIF(r.kind = 1, 1, -1) [AmountIsPaid], d.[AmountIsPaid] * IIF(r.kind = 1, 1, null) [AmountIsPaid.In], d.[AmountIsPaid] * IIF(r.kind = 1, null, 1) [AmountIsPaid.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [AO] UNIQUEIDENTIFIER N'$.AO'
        , [Supplier] UNIQUEIDENTIFIER N'$.Supplier'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [SupplierDocDate] DATE N'$.SupplierDocDate'
        , [PayDay] DATE N'$.PayDay'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [AmountToPay] MONEY N'$.AmountToPay'
        , [AmountIsPaid] MONEY N'$.AmountIsPaid'
        ) AS d
        WHERE r.type = N'Register.Accumulation.AP';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.AP] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.AP] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.AP ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.AR ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.AR]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, AO, Customer, Department, PayDay
      , d.[AR] * IIF(r.kind = 1, 1, -1) [AR], d.[AR] * IIF(r.kind = 1, 1, null) [AR.In], d.[AR] * IIF(r.kind = 1, null, 1) [AR.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
      , d.[AmountToPay] * IIF(r.kind = 1, 1, -1) [AmountToPay], d.[AmountToPay] * IIF(r.kind = 1, 1, null) [AmountToPay.In], d.[AmountToPay] * IIF(r.kind = 1, null, 1) [AmountToPay.Out]
      , d.[AmountIsPaid] * IIF(r.kind = 1, 1, -1) [AmountIsPaid], d.[AmountIsPaid] * IIF(r.kind = 1, 1, null) [AmountIsPaid.In], d.[AmountIsPaid] * IIF(r.kind = 1, null, 1) [AmountIsPaid.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [AO] UNIQUEIDENTIFIER N'$.AO'
        , [Customer] UNIQUEIDENTIFIER N'$.Customer'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [PayDay] DATE N'$.PayDay'
        , [AR] MONEY N'$.AR'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [AmountToPay] MONEY N'$.AmountToPay'
        , [AmountIsPaid] MONEY N'$.AmountIsPaid'
        ) AS d
        WHERE r.type = N'Register.Accumulation.AR';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.AR] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.AR] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.AR ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Bank ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Bank]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, BankAccount, CashFlow, Analytics
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [BankAccount] UNIQUEIDENTIFIER N'$.BankAccount'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Bank';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Bank] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Bank] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Bank ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Balance ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Balance]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Balance, Analytics, Department
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Balance] UNIQUEIDENTIFIER N'$.Balance'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Amount] MONEY N'$.Amount'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Balance';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Balance] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Balance] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Balance ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Balance.RC ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Balance.RC]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, ResponsibilityCenter, Department, Balance, Analytics, Analytics2, Currency
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountRC] * IIF(r.kind = 1, 1, -1) [AmountRC], d.[AmountRC] * IIF(r.kind = 1, 1, null) [AmountRC.In], d.[AmountRC] * IIF(r.kind = 1, null, 1) [AmountRC.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [ResponsibilityCenter] UNIQUEIDENTIFIER N'$.ResponsibilityCenter'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Balance] UNIQUEIDENTIFIER N'$.Balance'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Analytics2] UNIQUEIDENTIFIER N'$.Analytics2'
        , [Currency] UNIQUEIDENTIFIER N'$.Currency'
        , [Amount] MONEY N'$.Amount'
        , [AmountRC] MONEY N'$.AmountRC'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Balance.RC';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Balance.RC] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Balance.RC] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Balance.RC ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Balance.Report ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Balance.Report]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, Balance, Analytics, Analytics2, Analytics3, Analytics4, Analytics5, Department
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Balance] UNIQUEIDENTIFIER N'$.Balance'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Analytics2] UNIQUEIDENTIFIER N'$.Analytics2'
        , [Analytics3] UNIQUEIDENTIFIER N'$.Analytics3'
        , [Analytics4] UNIQUEIDENTIFIER N'$.Analytics4'
        , [Analytics5] UNIQUEIDENTIFIER N'$.Analytics5'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Balance.Report';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Balance.Report] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Balance.Report] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Balance.Report ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Cash ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Cash]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, CashRegister, CashFlow, Analytics
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [CashRegister] UNIQUEIDENTIFIER N'$.CashRegister'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Cash';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Cash] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Cash] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Cash ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Cash.Transit ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Cash.Transit]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, CompanyRecipient, currency, Sender, Recipient, CashFlow
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [CompanyRecipient] UNIQUEIDENTIFIER N'$.CompanyRecipient'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Sender] UNIQUEIDENTIFIER N'$.Sender'
        , [Recipient] UNIQUEIDENTIFIER N'$.Recipient'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Cash.Transit';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Cash.Transit] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Cash.Transit] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Cash.Transit ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.EmployeeTimekeeping ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.EmployeeTimekeeping]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, isActive, PeriodMonth, KindTimekeeping, Employee, Person, StaffingTable
      , d.[Days] * IIF(r.kind = 1, 1, -1) [Days], d.[Days] * IIF(r.kind = 1, 1, null) [Days.In], d.[Days] * IIF(r.kind = 1, null, 1) [Days.Out]
      , d.[Hours] * IIF(r.kind = 1, 1, -1) [Hours], d.[Hours] * IIF(r.kind = 1, 1, null) [Hours.In], d.[Hours] * IIF(r.kind = 1, null, 1) [Hours.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [isActive] BIT N'$.isActive'
        , [PeriodMonth] DATE N'$.PeriodMonth'
        , [KindTimekeeping] NVARCHAR(250) N'$.KindTimekeeping'
        , [Employee] UNIQUEIDENTIFIER N'$.Employee'
        , [Person] UNIQUEIDENTIFIER N'$.Person'
        , [StaffingTable] UNIQUEIDENTIFIER N'$.StaffingTable'
        , [Days] MONEY N'$.Days'
        , [Hours] MONEY N'$.Hours'
        ) AS d
        WHERE r.type = N'Register.Accumulation.EmployeeTimekeeping';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.EmployeeTimekeeping] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.EmployeeTimekeeping] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.EmployeeTimekeeping ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Inventory ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Inventory]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Storehouse, SKU, OperationType, Expense, ExpenseAnalytics, ExpenseAnalytics2, Income, IncomeAnalytics, IncomeAnalytics2, BalanceIn, BalanceInAnalytics, BalanceOut, BalanceOutAnalytics, batch, Department
      , d.[Cost] * IIF(r.kind = 1, 1, -1) [Cost], d.[Cost] * IIF(r.kind = 1, 1, null) [Cost.In], d.[Cost] * IIF(r.kind = 1, null, 1) [Cost.Out]
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Storehouse] UNIQUEIDENTIFIER N'$.Storehouse'
        , [SKU] UNIQUEIDENTIFIER N'$.SKU'
        , [OperationType] UNIQUEIDENTIFIER N'$.OperationType'
        , [Expense] UNIQUEIDENTIFIER N'$.Expense'
        , [ExpenseAnalytics] UNIQUEIDENTIFIER N'$.ExpenseAnalytics'
        , [ExpenseAnalytics2] UNIQUEIDENTIFIER N'$.ExpenseAnalytics2'
        , [Income] UNIQUEIDENTIFIER N'$.Income'
        , [IncomeAnalytics] UNIQUEIDENTIFIER N'$.IncomeAnalytics'
        , [IncomeAnalytics2] UNIQUEIDENTIFIER N'$.IncomeAnalytics2'
        , [BalanceIn] UNIQUEIDENTIFIER N'$.BalanceIn'
        , [BalanceInAnalytics] UNIQUEIDENTIFIER N'$.BalanceInAnalytics'
        , [BalanceOut] UNIQUEIDENTIFIER N'$.BalanceOut'
        , [BalanceOutAnalytics] UNIQUEIDENTIFIER N'$.BalanceOutAnalytics'
        , [batch] UNIQUEIDENTIFIER N'$.batch'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Cost] MONEY N'$.Cost'
        , [Qty] MONEY N'$.Qty'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Inventory';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Inventory] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Inventory] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Inventory ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Loan ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Loan]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Loan, Counterpartie, CashFlow, currency, PaymentKind
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
      , d.[AmountToPay] * IIF(r.kind = 1, 1, -1) [AmountToPay], d.[AmountToPay] * IIF(r.kind = 1, 1, null) [AmountToPay.In], d.[AmountToPay] * IIF(r.kind = 1, null, 1) [AmountToPay.Out]
      , d.[AmountIsPaid] * IIF(r.kind = 1, 1, -1) [AmountIsPaid], d.[AmountIsPaid] * IIF(r.kind = 1, 1, null) [AmountIsPaid.In], d.[AmountIsPaid] * IIF(r.kind = 1, null, 1) [AmountIsPaid.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Loan] UNIQUEIDENTIFIER N'$.Loan'
        , [Counterpartie] UNIQUEIDENTIFIER N'$.Counterpartie'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [PaymentKind] NVARCHAR(250) N'$.PaymentKind'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [AmountToPay] MONEY N'$.AmountToPay'
        , [AmountIsPaid] MONEY N'$.AmountIsPaid'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Loan';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Loan] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Loan] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Loan ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.PL ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.PL]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, RetailNetwork, Department, PL, Analytics, Analytics2
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [RetailNetwork] UNIQUEIDENTIFIER N'$.RetailNetwork'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [PL] UNIQUEIDENTIFIER N'$.PL'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Analytics2] UNIQUEIDENTIFIER N'$.Analytics2'
        , [Amount] MONEY N'$.Amount'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.PL';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.PL] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.PL] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.PL ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.PL.RC ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.PL.RC]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, ResponsibilityCenter, Department, PL, Analytics, Analytics2, Currency
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountRC] * IIF(r.kind = 1, 1, -1) [AmountRC], d.[AmountRC] * IIF(r.kind = 1, 1, null) [AmountRC.In], d.[AmountRC] * IIF(r.kind = 1, null, 1) [AmountRC.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [ResponsibilityCenter] UNIQUEIDENTIFIER N'$.ResponsibilityCenter'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [PL] UNIQUEIDENTIFIER N'$.PL'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Analytics2] UNIQUEIDENTIFIER N'$.Analytics2'
        , [Currency] UNIQUEIDENTIFIER N'$.Currency'
        , [Amount] MONEY N'$.Amount'
        , [AmountRC] MONEY N'$.AmountRC'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.PL.RC';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.PL.RC] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.PL.RC] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.PL.RC ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Sales ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Sales]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, RetailNetwork, Department, Customer, Aggregator, Product, Analytic, Manager, DeliveryType, OrderSource, ParentOrderSource, RetailClient, Storehouse, Courier, AO
      , d.[DeliverArea] * IIF(r.kind = 1, 1, -1) [DeliverArea], d.[DeliverArea] * IIF(r.kind = 1, 1, null) [DeliverArea.In], d.[DeliverArea] * IIF(r.kind = 1, null, 1) [DeliverArea.Out], OpenTime, PrintTime, DeliverTime, BillTime, CloseTime
      , d.[CashShift] * IIF(r.kind = 1, 1, -1) [CashShift], d.[CashShift] * IIF(r.kind = 1, 1, null) [CashShift.In], d.[CashShift] * IIF(r.kind = 1, null, 1) [CashShift.Out]
      , d.[Cost] * IIF(r.kind = 1, 1, -1) [Cost], d.[Cost] * IIF(r.kind = 1, 1, null) [Cost.In], d.[Cost] * IIF(r.kind = 1, null, 1) [Cost.Out]
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[Discount] * IIF(r.kind = 1, 1, -1) [Discount], d.[Discount] * IIF(r.kind = 1, 1, null) [Discount.In], d.[Discount] * IIF(r.kind = 1, null, 1) [Discount.Out]
      , d.[Tax] * IIF(r.kind = 1, 1, -1) [Tax], d.[Tax] * IIF(r.kind = 1, 1, null) [Tax.In], d.[Tax] * IIF(r.kind = 1, null, 1) [Tax.Out]
      , d.[AmountInDoc] * IIF(r.kind = 1, 1, -1) [AmountInDoc], d.[AmountInDoc] * IIF(r.kind = 1, 1, null) [AmountInDoc.In], d.[AmountInDoc] * IIF(r.kind = 1, null, 1) [AmountInDoc.Out]
      , d.[AmountInAR] * IIF(r.kind = 1, 1, -1) [AmountInAR], d.[AmountInAR] * IIF(r.kind = 1, 1, null) [AmountInAR.In], d.[AmountInAR] * IIF(r.kind = 1, null, 1) [AmountInAR.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [RetailNetwork] UNIQUEIDENTIFIER N'$.RetailNetwork'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Customer] UNIQUEIDENTIFIER N'$.Customer'
        , [Aggregator] UNIQUEIDENTIFIER N'$.Aggregator'
        , [Product] UNIQUEIDENTIFIER N'$.Product'
        , [Analytic] UNIQUEIDENTIFIER N'$.Analytic'
        , [Manager] UNIQUEIDENTIFIER N'$.Manager'
        , [DeliveryType] NVARCHAR(250) N'$.DeliveryType'
        , [OrderSource] NVARCHAR(250) N'$.OrderSource'
        , [ParentOrderSource] UNIQUEIDENTIFIER N'$.ParentOrderSource'
        , [RetailClient] UNIQUEIDENTIFIER N'$.RetailClient'
        , [Storehouse] UNIQUEIDENTIFIER N'$.Storehouse'
        , [Courier] UNIQUEIDENTIFIER N'$.Courier'
        , [AO] UNIQUEIDENTIFIER N'$.AO'
        , [DeliverArea] MONEY N'$.DeliverArea'
        , [OpenTime] DATETIME N'$.OpenTime'
        , [PrintTime] DATETIME N'$.PrintTime'
        , [DeliverTime] DATETIME N'$.DeliverTime'
        , [BillTime] DATETIME N'$.BillTime'
        , [CloseTime] DATETIME N'$.CloseTime'
        , [CashShift] MONEY N'$.CashShift'
        , [Cost] MONEY N'$.Cost'
        , [Qty] MONEY N'$.Qty'
        , [Amount] MONEY N'$.Amount'
        , [Discount] MONEY N'$.Discount'
        , [Tax] MONEY N'$.Tax'
        , [AmountInDoc] MONEY N'$.AmountInDoc'
        , [AmountInAR] MONEY N'$.AmountInAR'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Sales';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Sales] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Sales] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Sales ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Salary ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Salary]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, KorrCompany, Department, Person, Employee, Analytics, SalaryKind, PL, PLAnalytics, Status, IsPortal
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [KorrCompany] UNIQUEIDENTIFIER N'$.KorrCompany'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Person] UNIQUEIDENTIFIER N'$.Person'
        , [Employee] UNIQUEIDENTIFIER N'$.Employee'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [SalaryKind] NVARCHAR(250) N'$.SalaryKind'
        , [PL] UNIQUEIDENTIFIER N'$.PL'
        , [PLAnalytics] UNIQUEIDENTIFIER N'$.PLAnalytics'
        , [Status] NVARCHAR(250) N'$.Status'
        , [IsPortal] BIT N'$.IsPortal'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Salary';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Salary] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Salary] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Salary ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Depreciation ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Depreciation]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, OperationType, currency, Department, ResponsiblePerson, OE
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [OperationType] UNIQUEIDENTIFIER N'$.OperationType'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [ResponsiblePerson] UNIQUEIDENTIFIER N'$.ResponsiblePerson'
        , [OE] UNIQUEIDENTIFIER N'$.OE'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Depreciation';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Depreciation] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Depreciation] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Depreciation ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.CashToPay ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.CashToPay]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, CashRequest, BankAccountPerson, OperationType, CashRecipient, CashFlow, Status, Contract, Department, Loan, CashOrBank, ExpenseOrBalance, ExpenseAnalytics, BalanceAnalytics, PayDay
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [CashRequest] UNIQUEIDENTIFIER N'$.CashRequest'
        , [BankAccountPerson] UNIQUEIDENTIFIER N'$.BankAccountPerson'
        , [OperationType] NVARCHAR(250) N'$.OperationType'
        , [CashRecipient] UNIQUEIDENTIFIER N'$.CashRecipient'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [Status] NVARCHAR(250) N'$.Status'
        , [Contract] UNIQUEIDENTIFIER N'$.Contract'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Loan] UNIQUEIDENTIFIER N'$.Loan'
        , [CashOrBank] UNIQUEIDENTIFIER N'$.CashOrBank'
        , [ExpenseOrBalance] UNIQUEIDENTIFIER N'$.ExpenseOrBalance'
        , [ExpenseAnalytics] UNIQUEIDENTIFIER N'$.ExpenseAnalytics'
        , [BalanceAnalytics] UNIQUEIDENTIFIER N'$.BalanceAnalytics'
        , [PayDay] DATE N'$.PayDay'
        , [Amount] MONEY N'$.Amount'
        ) AS d
        WHERE r.type = N'Register.Accumulation.CashToPay';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.CashToPay] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.CashToPay] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.CashToPay ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.CharityAnalytic ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.CharityAnalytic]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, Creator, CreatorContract, Recipient, RecipientContract, Batch, Source, Analytics, MovementType
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out], Info
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Creator] UNIQUEIDENTIFIER N'$.Creator'
        , [CreatorContract] UNIQUEIDENTIFIER N'$.CreatorContract'
        , [Recipient] UNIQUEIDENTIFIER N'$.Recipient'
        , [RecipientContract] UNIQUEIDENTIFIER N'$.RecipientContract'
        , [Batch] UNIQUEIDENTIFIER N'$.Batch'
        , [Source] UNIQUEIDENTIFIER N'$.Source'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [MovementType] UNIQUEIDENTIFIER N'$.MovementType'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [Info] NVARCHAR(250) N'$.Info'
        ) AS d
        WHERE r.type = N'Register.Accumulation.CharityAnalytic';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.CharityAnalytic] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.CharityAnalytic] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.CharityAnalytic ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.BudgetItemTurnover ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.BudgetItemTurnover]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Department, Scenario, BudgetItem, Anatitic1, Anatitic2, Anatitic3, Anatitic4, Anatitic5, currency
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInScenatio] * IIF(r.kind = 1, 1, -1) [AmountInScenatio], d.[AmountInScenatio] * IIF(r.kind = 1, 1, null) [AmountInScenatio.In], d.[AmountInScenatio] * IIF(r.kind = 1, null, 1) [AmountInScenatio.Out]
      , d.[AmountInCurrency] * IIF(r.kind = 1, 1, -1) [AmountInCurrency], d.[AmountInCurrency] * IIF(r.kind = 1, 1, null) [AmountInCurrency.In], d.[AmountInCurrency] * IIF(r.kind = 1, null, 1) [AmountInCurrency.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [Scenario] UNIQUEIDENTIFIER N'$.Scenario'
        , [BudgetItem] UNIQUEIDENTIFIER N'$.BudgetItem'
        , [Anatitic1] UNIQUEIDENTIFIER N'$.Anatitic1'
        , [Anatitic2] UNIQUEIDENTIFIER N'$.Anatitic2'
        , [Anatitic3] UNIQUEIDENTIFIER N'$.Anatitic3'
        , [Anatitic4] UNIQUEIDENTIFIER N'$.Anatitic4'
        , [Anatitic5] UNIQUEIDENTIFIER N'$.Anatitic5'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Amount] MONEY N'$.Amount'
        , [AmountInScenatio] MONEY N'$.AmountInScenatio'
        , [AmountInCurrency] MONEY N'$.AmountInCurrency'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        , [Qty] MONEY N'$.Qty'
        ) AS d
        WHERE r.type = N'Register.Accumulation.BudgetItemTurnover';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.BudgetItemTurnover] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.BudgetItemTurnover] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.BudgetItemTurnover ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Intercompany ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Intercompany]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, Intercompany, LegalCompanySender, LegalCompanyRecipient, Contract, OperationType, Analytics
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [Intercompany] UNIQUEIDENTIFIER N'$.Intercompany'
        , [LegalCompanySender] UNIQUEIDENTIFIER N'$.LegalCompanySender'
        , [LegalCompanyRecipient] UNIQUEIDENTIFIER N'$.LegalCompanyRecipient'
        , [Contract] UNIQUEIDENTIFIER N'$.Contract'
        , [OperationType] UNIQUEIDENTIFIER N'$.OperationType'
        , [Analytics] UNIQUEIDENTIFIER N'$.Analytics'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Intercompany';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Intercompany] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Intercompany] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Intercompany ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.Acquiring ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.Acquiring]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, AcquiringTerminal, AcquiringTerminalCode1, Department, OperationType, CashFlow, PaymantCard, PayDay, DateOperation, DatePaid, AuthorizationCode
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountOperation] * IIF(r.kind = 1, 1, -1) [AmountOperation], d.[AmountOperation] * IIF(r.kind = 1, 1, null) [AmountOperation.In], d.[AmountOperation] * IIF(r.kind = 1, null, 1) [AmountOperation.Out]
      , d.[AmountPaid] * IIF(r.kind = 1, 1, -1) [AmountPaid], d.[AmountPaid] * IIF(r.kind = 1, 1, null) [AmountPaid.In], d.[AmountPaid] * IIF(r.kind = 1, null, 1) [AmountPaid.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [AcquiringTerminal] UNIQUEIDENTIFIER N'$.AcquiringTerminal'
        , [AcquiringTerminalCode1] NVARCHAR(250) N'$.AcquiringTerminalCode1'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [OperationType] UNIQUEIDENTIFIER N'$.OperationType'
        , [CashFlow] UNIQUEIDENTIFIER N'$.CashFlow'
        , [PaymantCard] NVARCHAR(250) N'$.PaymantCard'
        , [PayDay] DATE N'$.PayDay'
        , [DateOperation] DATE N'$.DateOperation'
        , [DatePaid] DATE N'$.DatePaid'
        , [AuthorizationCode] NVARCHAR(250) N'$.AuthorizationCode'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountOperation] MONEY N'$.AmountOperation'
        , [AmountPaid] MONEY N'$.AmountPaid'
        ) AS d
        WHERE r.type = N'Register.Accumulation.Acquiring';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.Acquiring] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.Acquiring] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.Acquiring ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.PromotionPoints ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.PromotionPoints]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, RetailNetwork, Department, OwnerInner, OwnerExternal, PromotionChannel, currency, batch, OrderId, ExpiredAt
      , d.[Qty] * IIF(r.kind = 1, 1, -1) [Qty], d.[Qty] * IIF(r.kind = 1, 1, null) [Qty.In], d.[Qty] * IIF(r.kind = 1, null, 1) [Qty.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [RetailNetwork] UNIQUEIDENTIFIER N'$.RetailNetwork'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [OwnerInner] UNIQUEIDENTIFIER N'$.OwnerInner'
        , [OwnerExternal] NVARCHAR(250) N'$.OwnerExternal'
        , [PromotionChannel] UNIQUEIDENTIFIER N'$.PromotionChannel'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [batch] UNIQUEIDENTIFIER N'$.batch'
        , [OrderId] NVARCHAR(250) N'$.OrderId'
        , [ExpiredAt] DATE N'$.ExpiredAt'
        , [Qty] MONEY N'$.Qty'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.PromotionPoints';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.PromotionPoints] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.PromotionPoints] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.PromotionPoints ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.StaffingTable ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.StaffingTable]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, Department, DepartmentCompany, StaffingType, StaffingTablePosition, Employee, Person, SalaryAnalytic, currency
      , d.[SalaryRate] * IIF(r.kind = 1, 1, -1) [SalaryRate], d.[SalaryRate] * IIF(r.kind = 1, 1, null) [SalaryRate.In], d.[SalaryRate] * IIF(r.kind = 1, null, 1) [SalaryRate.Out]
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountPrepay] * IIF(r.kind = 1, 1, -1) [AmountPrepay], d.[AmountPrepay] * IIF(r.kind = 1, 1, null) [AmountPrepay.In], d.[AmountPrepay] * IIF(r.kind = 1, null, 1) [AmountPrepay.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [DepartmentCompany] UNIQUEIDENTIFIER N'$.DepartmentCompany'
        , [StaffingType] NVARCHAR(250) N'$.StaffingType'
        , [StaffingTablePosition] UNIQUEIDENTIFIER N'$.StaffingTablePosition'
        , [Employee] UNIQUEIDENTIFIER N'$.Employee'
        , [Person] UNIQUEIDENTIFIER N'$.Person'
        , [SalaryAnalytic] UNIQUEIDENTIFIER N'$.SalaryAnalytic'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [SalaryRate] MONEY N'$.SalaryRate'
        , [Amount] MONEY N'$.Amount'
        , [AmountPrepay] MONEY N'$.AmountPrepay'
        ) AS d
        WHERE r.type = N'Register.Accumulation.StaffingTable';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.StaffingTable] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.StaffingTable] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.StaffingTable ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
------------------------------ BEGIN Register.Accumulation.MoneyDocuments ------------------------------

    CREATE OR ALTER VIEW [Register.Accumulation.MoneyDocuments]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate, currency, MoneyDocument, Department, OwnedBy, Sourse, ExpiredAt
      , d.[Amount] * IIF(r.kind = 1, 1, -1) [Amount], d.[Amount] * IIF(r.kind = 1, 1, null) [Amount.In], d.[Amount] * IIF(r.kind = 1, null, 1) [Amount.Out]
      , d.[AmountInBalance] * IIF(r.kind = 1, 1, -1) [AmountInBalance], d.[AmountInBalance] * IIF(r.kind = 1, 1, null) [AmountInBalance.In], d.[AmountInBalance] * IIF(r.kind = 1, null, 1) [AmountInBalance.Out]
      , d.[AmountInAccounting] * IIF(r.kind = 1, 1, -1) [AmountInAccounting], d.[AmountInAccounting] * IIF(r.kind = 1, 1, null) [AmountInAccounting.In], d.[AmountInAccounting] * IIF(r.kind = 1, null, 1) [AmountInAccounting.Out]
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'
        , [currency] UNIQUEIDENTIFIER N'$.currency'
        , [MoneyDocument] UNIQUEIDENTIFIER N'$.MoneyDocument'
        , [Department] UNIQUEIDENTIFIER N'$.Department'
        , [OwnedBy] UNIQUEIDENTIFIER N'$.OwnedBy'
        , [Sourse] UNIQUEIDENTIFIER N'$.Sourse'
        , [ExpiredAt] DATE N'$.ExpiredAt'
        , [Amount] MONEY N'$.Amount'
        , [AmountInBalance] MONEY N'$.AmountInBalance'
        , [AmountInAccounting] MONEY N'$.AmountInAccounting'
        ) AS d
        WHERE r.type = N'Register.Accumulation.MoneyDocuments';
    GO
    GRANT SELECT,DELETE ON [Register.Accumulation.MoneyDocuments] TO JETTI;
    GO
    GRANT SELECT ON [Register.Accumulation.MoneyDocuments] TO PUBLIC;
    GO
    
------------------------------ END Register.Accumulation.MoneyDocuments ------------------------------

      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      
    