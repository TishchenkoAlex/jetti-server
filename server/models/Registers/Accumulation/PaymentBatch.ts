import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

@JRegisterAccumulation({
  type: 'Register.Accumulation.PaymentBatch',
  description: 'Партии предоплат',
  pruningMethod: 'balance'
})
export class RegisterAccumulationPaymentBatch extends RegisterAccumulation {

  @Props({ type: 'enum', value: ['AP', 'AR', 'LOAN', 'PREPAY'], dimension: true })
  PaymentsKind = 'AR';

  @Props({ type: 'Types.CompanyOrCounterpartieOrPersonOrRetailClient', dimension: true })
  Counterpartie: Ref = null;

  @Props({ type: 'Catalog.Product.Package', dimension: true })
  ProductPackage: Ref = null;

  @Props({ type: 'Catalog.Product', dimension: true })
  Product: Ref = null;

  @Props({ type: 'Catalog.Currency', dimension: true })
  Currency: Ref = null;

  @Props({ type: 'date' })
  PayDay = null;

  @Props({ type: 'number', resource: true })
  Qty = 0;

  @Props({ type: 'number', resource: true, balanceCalculationFormula: `[Amount]/[Qty]` })
  Price = 0;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'Types.Document', required: true, dimension: true })
  batch: Ref = null;

  constructor(init: Partial<RegisterAccumulationPaymentBatch>) {
    super(init);
    Object.assign(this, init);
  }
}
