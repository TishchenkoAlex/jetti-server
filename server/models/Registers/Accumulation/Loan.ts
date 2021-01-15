import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

@JRegisterAccumulation({
  type: 'Register.Accumulation.Loan',
  description: 'Расчеты по кредитам и депозитам'
})
export class RegisterAccumulationLoan extends RegisterAccumulation {

  @Props({ type: 'Catalog.Loan', required: true, dimension: true })
  Loan: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPerson', required: true, dimension: true })
  Counterpartie: Ref = null;

  @Props({ type: 'Catalog.CashFlow', required: true, dimension: true })
  CashFlow: Ref = null;

  @Props({ type: 'Catalog.Currency', required: true, dimension: true, isProtected: true })
  currency: Ref = null;

  @Props({
    type: 'enum', required: true, value: [
      'BODY',
      'PERCENT',
      'SHARE',
      'CUSTOM1'
    ]
  })
  PaymentKind = 'BODY';

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  @Props({ type: 'number', resource: true })
  AmountToPay = 0;

  @Props({ type: 'number', resource: true })
  AmountIsPaid = 0;

  constructor (init: Partial<RegisterAccumulationLoan>) {
    super(init);
    Object.assign(this, init);
  }
}
