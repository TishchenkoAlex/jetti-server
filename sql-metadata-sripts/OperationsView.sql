
------------------------------ BEGIN Operation.balance ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.balance] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "balance",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[RegisterName] [RegisterName]
        , d.[BalanceDate] [BalanceDate]
        , d.[Fields] [Fields]
        , d.[GroupBy] [GroupBy]
        , d.[TopRows] [TopRows]
      FROM [Operation.balance.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
    ; 
GO
GRANT SELECT ON dbo.[Operation.balance] TO jetti;
GO
GRANT SELECT ON dbo.[Operation.balance] TO PUBLIC;
GO

      
------------------------------ END Operation.balance ------------------------------

------------------------------ BEGIN Operation.load ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.load] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "load",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[CSV] [CSV]
        , ISNULL([UsersParent.v].description, '') [UsersParent.value], d.[UsersParent] [UsersParent.id], [UsersParent.v].type [UsersParent.type]
      FROM [Operation.load.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.User.v] [UsersParent.v] WITH (NOEXPAND) ON [UsersParent.v].id = d.[UsersParent]
    ; 
GO
GRANT SELECT ON dbo.[Operation.load] TO jetti;
GO
GRANT SELECT ON dbo.[Operation.load] TO PUBLIC;
GO

      
------------------------------ END Operation.load ------------------------------

------------------------------ BEGIN Operation.OperName1 ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.OperName1] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "OperName1",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[BankConfirm] [BankConfirm]
        , d.[BankDocNumber] [BankDocNumber]
        , d.[BankConfirmDate] [BankConfirmDate]
        , ISNULL([BankAccount.v].description, '') [BankAccount.value], d.[BankAccount] [BankAccount.id], [BankAccount.v].type [BankAccount.type]
        , ISNULL([Counterpartie.v].description, '') [Counterpartie.value], d.[Counterpartie] [Counterpartie.id], [Counterpartie.v].type [Counterpartie.type]
        , ISNULL([Loan.v].description, '') [Loan.value], d.[Loan] [Loan.id], [Loan.v].type [Loan.type]
        , d.[PaymentKind] [PaymentKind]
        , ISNULL([BankAccountSupplier.v].description, '') [BankAccountSupplier.value], d.[BankAccountSupplier] [BankAccountSupplier.id], [BankAccountSupplier.v].type [BankAccountSupplier.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([CashFlow.v].description, '') [CashFlow.value], d.[CashFlow] [CashFlow.id], [CashFlow.v].type [CashFlow.type]
      FROM [Operation.OperName1.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.BankAccount.v] [BankAccount.v] WITH (NOEXPAND) ON [BankAccount.v].id = d.[BankAccount]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Counterpartie.v] WITH (NOEXPAND) ON [Counterpartie.v].id = d.[Counterpartie]
        LEFT JOIN dbo.[Catalog.Loan.v] [Loan.v] WITH (NOEXPAND) ON [Loan.v].id = d.[Loan]
        LEFT JOIN dbo.[Catalog.Counterpartie.BankAccount.v] [BankAccountSupplier.v] WITH (NOEXPAND) ON [BankAccountSupplier.v].id = d.[BankAccountSupplier]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.CashFlow.v] [CashFlow.v] WITH (NOEXPAND) ON [CashFlow.v].id = d.[CashFlow]
    ; 
GO
GRANT SELECT ON dbo.[Operation.OperName1] TO jetti;
GO
GRANT SELECT ON dbo.[Operation.OperName1] TO PUBLIC;
GO

      
------------------------------ END Operation.OperName1 ------------------------------

------------------------------ BEGIN Operation.OperName2 ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.OperName2] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "OperName2",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
        , d.[BankConfirm] [BankConfirm]
        , d.[BankDocNumber] [BankDocNumber]
        , d.[BankConfirmDate] [BankConfirmDate]
        , ISNULL([BankAccount.v].description, '') [BankAccount.value], d.[BankAccount] [BankAccount.id], [BankAccount.v].type [BankAccount.type]
        , ISNULL([Supplier.v].description, '') [Supplier.value], d.[Supplier] [Supplier.id], [Supplier.v].type [Supplier.type]
        , ISNULL([CashFlow.v].description, '') [CashFlow.value], d.[CashFlow] [CashFlow.id], [CashFlow.v].type [CashFlow.type]
        , ISNULL([Department.v].description, '') [Department.value], d.[Department] [Department.id], [Department.v].type [Department.type]
        , ISNULL([BankAccountSupplier.v].description, '') [BankAccountSupplier.value], d.[BankAccountSupplier] [BankAccountSupplier.id], [BankAccountSupplier.v].type [BankAccountSupplier.type]
        , ISNULL([CashFlowAPersons.v].description, '') [CashFlowAPersons.value], d.[CashFlowAPersons] [CashFlowAPersons.id], [CashFlowAPersons.v].type [CashFlowAPersons.type]
        , ISNULL([TaxPaymentCode.v].description, '') [TaxPaymentCode.value], d.[TaxPaymentCode] [TaxPaymentCode.id], [TaxPaymentCode.v].type [TaxPaymentCode.type]
        , d.[TaxOfficeCode2] [TaxOfficeCode2]
        , d.[TaxKPP] [TaxKPP]
        , ISNULL([TaxPayerStatus.v].description, '') [TaxPayerStatus.value], d.[TaxPayerStatus] [TaxPayerStatus.id], [TaxPayerStatus.v].type [TaxPayerStatus.type]
        , ISNULL([TaxBasisPayment.v].description, '') [TaxBasisPayment.value], d.[TaxBasisPayment] [TaxBasisPayment.id], [TaxBasisPayment.v].type [TaxBasisPayment.type]
        , ISNULL([TaxPaymentPeriod.v].description, '') [TaxPaymentPeriod.value], d.[TaxPaymentPeriod] [TaxPaymentPeriod.id], [TaxPaymentPeriod.v].type [TaxPaymentPeriod.type]
        , d.[TaxDocNumber] [TaxDocNumber]
        , d.[TaxDocDate] [TaxDocDate]
        , ISNULL([CompanyParent.v].description, '') [CompanyParent.value], d.[CompanyParent] [CompanyParent.id], [CompanyParent.v].type [CompanyParent.type]
      FROM [Operation.OperName2.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
        LEFT JOIN dbo.[Catalog.BankAccount.v] [BankAccount.v] WITH (NOEXPAND) ON [BankAccount.v].id = d.[BankAccount]
        LEFT JOIN dbo.[Catalog.Counterpartie.v] [Supplier.v] WITH (NOEXPAND) ON [Supplier.v].id = d.[Supplier]
        LEFT JOIN dbo.[Catalog.CashFlow.v] [CashFlow.v] WITH (NOEXPAND) ON [CashFlow.v].id = d.[CashFlow]
        LEFT JOIN dbo.[Catalog.Department.v] [Department.v] WITH (NOEXPAND) ON [Department.v].id = d.[Department]
        LEFT JOIN dbo.[Catalog.Counterpartie.BankAccount.v] [BankAccountSupplier.v] WITH (NOEXPAND) ON [BankAccountSupplier.v].id = d.[BankAccountSupplier]
        LEFT JOIN dbo.[Catalog.CashFlow.v] [CashFlowAPersons.v] WITH (NOEXPAND) ON [CashFlowAPersons.v].id = d.[CashFlowAPersons]
        LEFT JOIN dbo.[Catalog.TaxPaymentCode.v] [TaxPaymentCode.v] WITH (NOEXPAND) ON [TaxPaymentCode.v].id = d.[TaxPaymentCode]
        LEFT JOIN dbo.[Catalog.TaxPayerStatus.v] [TaxPayerStatus.v] WITH (NOEXPAND) ON [TaxPayerStatus.v].id = d.[TaxPayerStatus]
        LEFT JOIN dbo.[Catalog.TaxBasisPayment.v] [TaxBasisPayment.v] WITH (NOEXPAND) ON [TaxBasisPayment.v].id = d.[TaxBasisPayment]
        LEFT JOIN dbo.[Catalog.TaxPaymentPeriod.v] [TaxPaymentPeriod.v] WITH (NOEXPAND) ON [TaxPaymentPeriod.v].id = d.[TaxPaymentPeriod]
        LEFT JOIN dbo.[Catalog.Company.v] [CompanyParent.v] WITH (NOEXPAND) ON [CompanyParent.v].id = d.[CompanyParent]
    ; 
GO
GRANT SELECT ON dbo.[Operation.OperName2] TO jetti;
GO
GRANT SELECT ON dbo.[Operation.OperName2] TO PUBLIC;
GO

      
------------------------------ END Operation.OperName2 ------------------------------

------------------------------ BEGIN Operation.respPerson ------------------------------

      CREATE OR ALTER VIEW dbo.[Operation.respPerson] AS
      
      SELECT
        d.id, d.type, d.date, d.code, d.description "respPerson",  d.posted, d.deleted, d.isfolder, d.timestamp, d.version
        , ISNULL("parent".description, '') "parent.value", d."parent" "parent.id", "parent".type "parent.type"
        , ISNULL("company".description, '') "company.value", d."company" "company.id", "company".type "company.type"
        , ISNULL("user".description, '') "user.value", d."user" "user.id", "user".type "user.type"
        , ISNULL([workflow.v].description, '') [workflow.value], d.[workflow] [workflow.id], [workflow.v].type [workflow.type]
        , ISNULL([Group.v].description, '') [Group.value], d.[Group] [Group.id], [Group.v].type [Group.type]
        , ISNULL([Operation.v].description, '') [Operation.value], d.[Operation] [Operation.id], [Operation.v].type [Operation.type]
        , d.[Amount] [Amount]
        , ISNULL([currency.v].description, '') [currency.value], d.[currency] [currency.id], [currency.v].type [currency.type]
      FROM [Operation.respPerson.v] d WITH (NOEXPAND)
        LEFT JOIN dbo.[Documents] [parent] ON [parent].id = d.[parent]
        LEFT JOIN dbo.[Catalog.User.v] [user] WITH (NOEXPAND) ON [user].id = d.[user]
        LEFT JOIN dbo.[Catalog.Company.v] [company] WITH (NOEXPAND) ON [company].id = d.company
        LEFT JOIN dbo.[Document.WorkFlow.v] [workflow.v] WITH (NOEXPAND) ON [workflow.v].id = d.[workflow]
        LEFT JOIN dbo.[Catalog.Operation.Group.v] [Group.v] WITH (NOEXPAND) ON [Group.v].id = d.[Group]
        LEFT JOIN dbo.[Catalog.Operation.v] [Operation.v] WITH (NOEXPAND) ON [Operation.v].id = d.[Operation]
        LEFT JOIN dbo.[Catalog.Currency.v] [currency.v] WITH (NOEXPAND) ON [currency.v].id = d.[currency]
    ; 
GO
GRANT SELECT ON dbo.[Operation.respPerson] TO jetti;
GO
GRANT SELECT ON dbo.[Operation.respPerson] TO PUBLIC;
GO

      
------------------------------ END Operation.respPerson ------------------------------
