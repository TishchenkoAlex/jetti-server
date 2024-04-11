import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.CharityAnalytic',
  description: 'Аналитика благотворительности',
  pruningMethod: 'balance'
})
export class RegisterAccumulationCharityAnalytic extends RegisterAccumulation {

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPerson', dimension: true })
  Creator: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPersonContract', dimension: true })
  CreatorContract: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPerson', dimension: true })
  Recipient: Ref = null;

  @Props({ type: 'Types.CounterpartieOrPersonContract', dimension: true })
  RecipientContract: Ref = null;

  @Props({ type: 'Catalog.Documents', dimension: true })
  Batch: Ref = null;

  @Props({ type: 'Catalog.Catalogs'})
  Source: Ref = null;

  @Props({ type: 'Catalog.Operation.Type'})
  Analytics: Ref = null;

  @Props({ type: 'Catalog.Operation.Type'})
  MovementType: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  @Props({ type: 'string' })
  Info = '';

  constructor(init: Partial<RegisterAccumulationCharityAnalytic>) {
    super(init);
    Object.assign(this, init);
  }
}
