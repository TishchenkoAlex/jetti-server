import { Props, Ref } from 'jetti-middle';
import { JRegisterInfo, RegisterInfo } from 'jetti-middle';

@JRegisterInfo({
  type: 'Register.Info.ExchangeRates',
  description: 'Exchange rates',
})
export class RegisterInfoExchangeRates extends RegisterInfo {

  @Props({ type: 'Catalog.Currency', required: true, isIndexed: true })
  currency: Ref = null;

  @Props({ type: 'number', required: true })
  Rate = 1;

  @Props({ type: 'number' })
  Mutiplicity = 1;

  constructor(init: Partial<RegisterInfoExchangeRates>) {
    super(init);
    Object.assign(this, init);
  }
}
