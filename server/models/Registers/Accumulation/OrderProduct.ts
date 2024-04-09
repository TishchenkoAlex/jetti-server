import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.OrderProduct',
  description: 'Заказанная номенклатура'
})

export class RegisterAccumulationOrderProduct extends RegisterAccumulation {
  @Props({ type: 'Catalog.Operation.Type', required: true, dimension: true })
  OrderType: Ref = null;

  @Props({ type: 'Catalog.Operation.Type', required: true, dimension: true })
  MovementType: Ref = null;

  @Props({ type: 'Catalog.RetailNetwork', dimension: true })
  RetailNetwork: Ref = null;

  @Props({ type: 'Catalog.Counterpartie', dimension: true })
  Supplier: Ref = null;

  @Props({ type: 'Catalog.Counterpartie', dimension: true })
  Customer: Ref = null;

  @Props({ type: 'Catalog.Department', dimension: true })
  SenderDepartment: Ref = null;

  @Props({ type: 'Catalog.Storehouse', dimension: true })
  SenderStorehouse: Ref = null;

  @Props({ type: 'Catalog.Department', required: true, dimension: true })
  RecipientDepartment: Ref = null;

  @Props({ type: 'Catalog.Storehouse', required: true, dimension: true })
  RecipientStorehouse: Ref = null;

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.Product', required: true, dimension: true })
  Product: Ref = null;

  @Props({ type: 'Types.Document', dimension: true })
  OrderBatch: Ref = null;

  @Props({ type: 'string', dimension: true })
  OrderRow = '';

  @Props({ type: 'number', resource: true })
  Qty = 0;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  constructor(init: Partial<RegisterAccumulationOrderProduct>) {
    super(init);
    Object.assign(this, init);
  }
}
