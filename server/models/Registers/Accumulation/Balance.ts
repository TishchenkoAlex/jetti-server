import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.Balance',
  description: 'Активы/Пассивы',
  pruningMethod: 'balance'
})
export class RegisterAccumulationBalance extends RegisterAccumulation {
  @Props({ type: 'Catalog.Balance', dimension: true })
  Balance: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytics: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'string' })
  Info = '';

  constructor (init: Partial<RegisterAccumulationBalance>) {
    super(init);
    Object.assign(this, init);
  }
}
