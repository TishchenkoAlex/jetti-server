import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.Depreciation',
  description: 'Амортизация',
  pruningMethod: 'balance'
})
export class RegisterAccumulationDepreciation extends RegisterAccumulation {

  @Props({ type: 'Catalog.Operation.Type', dimension: true })
  OperationType: Ref = null;

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.Department', required: true, dimension: true })
  Department: Ref = null;

  @Props({ type: 'Catalog.Person', required: true, dimension: true })
  ResponsiblePerson: Ref = null;

  @Props({ type: 'Catalog.ObjectsExploitation', required: true, dimension: true })
  OE: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  constructor (init: Partial<RegisterAccumulationDepreciation>) {
    super(init);
    Object.assign(this, init);
  }
}
