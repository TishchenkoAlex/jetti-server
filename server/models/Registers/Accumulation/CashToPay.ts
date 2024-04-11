import { Props, Ref, JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.CashToPay',
  description: 'Денежные средства к выплате',
  pruningMethod: 'balance'
})
export class RegisterAccumulationCashToPay extends RegisterAccumulation {

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Document.CashRequest', required: true, isIndexed: true, dimension: true })
  CashRequest: Ref = null;

  @Props({ type: 'Catalog.Person.BankAccount', required: true, dimension: true })
  BankAccountPerson: Ref = null;

  @Props({ type: 'string', required: true, dimension: true })
  OperationType = '';

  @Props({ type: 'Types.CashRecipient', dimension: true })
  CashRecipient: Ref = null;

  @Props({ type: 'Catalog.CashFlow', required: true})
  CashFlow: Ref = null;

  @Props({
    type: 'enum', dimension: true, value: [
      'PREPARED',
      'AWAITING',
      'MODIFY',
      'APPROVED',
      'REJECTED',
      'CLOSED',
    ]
  })
  Status = null;

  @Props({ type: 'Types.CounterpartieOrPersonContract', required: true})
  Contract: Ref = null;

  @Props({ type: 'Catalog.Department'})
  Department: Ref = null;

  @Props({ type: 'Catalog.Loan'})
  Loan: Ref = null;

  @Props({ type: 'Types.CashOrBank'})
  CashOrBank: Ref = null;

  @Props({ type: 'Types.ExpenseOrBalanceOrIncome'})
  ExpenseOrBalance: Ref = null;

  @Props({ type: 'Catalog.Expense.Analytics'})
  ExpenseAnalytics: Ref = null;

  @Props({ type: 'Catalog.Balance.Analytics'})
  BalanceAnalytics: Ref = null;

  @Props({ type: 'date' })
  PayDay = new Date();

  @Props({ type: 'number', resource: true })
  Amount = 0;

  constructor(init: Partial<RegisterAccumulationCashToPay>) {
    super(init);
    Object.assign(this, init);
  }
}
