import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

@JRegisterAccumulation({
  type: 'Register.Accumulation.Acquiring',
  description: 'Расчеты по эквайрингу'
})
export class RegisterAccumulationAcquiring extends RegisterAccumulation {

  @Props({ type: 'Catalog.AcquiringTerminal', dimension: true })
  AcquiringTerminal: Ref = null;

  @Props({ type: 'string', label: 'Merchant' })
  AcquiringTerminalCode1 = '';

  @Props({ type: 'Catalog.Operation.Type', dimension: true })
  OperationType: Ref = null;

  @Props({ type: 'Catalog.Department', dimension: true })
  Department: Ref = null;

  @Props({ type: 'Catalog.CashFlow', dimension: true })
  CashFlow: Ref = null;

  @Props({ type: 'string' })
  PaymantCard = '';

  @Props({ type: 'date' })
  PayDay = new Date();

  @Props({ type: 'Catalog.Currency', dimension: true })
  currency: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountOperation = 0;

  @Props({ type: 'number', resource: true })
  AmountPaid = 0;

  @Props({ type: 'date' })
  DateOperation = null;

  @Props({ type: 'date' })
  DatePaid = null;

  @Props({ type: 'string' })
  AuthorizationCode = '';

  constructor(init: Partial<RegisterAccumulationAcquiring>) {
    super(init);
    Object.assign(this, init);
  }
}
