import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.Balance.Report',
  description: 'Активы/Пассивы (аналитика)',
  pruningMethod: 'balance'
})
export class RegisterAccumulationBalanceReport extends RegisterAccumulation {
  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.Balance', dimension: true })
  Balance: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics2: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics3: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics4: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics5: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  @Props({ type: 'string' })
  Info = '';

  constructor (init: Partial<RegisterAccumulationBalanceReport>) {
    super(init);
    Object.assign(this, init);
  }
}
