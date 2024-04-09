import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.MoneyDocuments',
  description: 'Денежные документы',
  pruningMethod: 'balance'
})
export class RegisterAccumulationMoneyDocuments extends RegisterAccumulation {

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.MoneyDocument', required: true, dimension: true })
  MoneyDocument: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPerson', required: true })
  OwnedBy: Ref = null;

  @Props({ type: 'Types.Catalog', required: true})
  Sourse: Ref = null;

  @Props({ type: 'date' })
  ExpiredAt = new Date();

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  constructor(init: Partial<RegisterAccumulationMoneyDocuments>) {
    super(init);
    Object.assign(this, init);
  }
}
