import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.Sales',
  description: 'Выручка и себестоимость продаж'
})
export class RegisterAccumulationSales extends RegisterAccumulation {

  @Props({ type: 'Catalog.Currency', dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.RetailNetwork', dimension: true })
  RetailNetwork: Ref = null;

  @Props({ type: 'Catalog.Department', dimension: true })
  Department: Ref = null;

  @Props({ type: 'Catalog.Counterpartie', dimension: true })
  Customer: Ref = null;

  @Props({ type: 'Catalog.Counterpartie', dimension: true })
  Aggregator: Ref = null;

  @Props({ type: 'Catalog.Product', dimension: true })
  Product: Ref = null;

  @Props({ type: 'Types.Catalog', dimension: true })
  Analytic: Ref = null;

  @Props({ type: 'Catalog.Manager', dimension: true })
  Manager: Ref = null;

  @Props({ type: 'enum', value: ['COURIER', 'CLIENT', 'EXTERNAL'], dimension: true })
  DeliveryType = '';

  @Props({ type: 'string', dimension: true })
  OrderSource = '';

  @Props({ type: 'Catalog.OrderSource', dimension: true })
  ParentOrderSource: Ref = null;

  @Props({ type: 'Catalog.RetailClient', dimension: true })
  RetailClient: Ref = null;

  @Props({ type: 'Catalog.Storehouse', dimension: true })
  Storehouse: Ref = null;

  @Props({ type: 'Catalog.Person', dimension: true })
  Courier: Ref = null;

  @Props({ type: 'Types.Document' })
  AO: Ref = null;

  @Props({ type: 'number' })
  DeliverArea = 0;

  @Props({ type: 'datetime' })
  OpenTime = null;

  @Props({ type: 'datetime' })
  PrintTime = null;

  @Props({ type: 'datetime' })
  DeliverTime = null;

  @Props({ type: 'datetime' })
  BillTime = null;

  @Props({ type: 'datetime' })
  CloseTime = null;

  @Props({ type: 'number' })
  CashShift = 0;

  @Props({ type: 'number', resource: true })
  Cost = 0;

  @Props({ type: 'number', resource: true })
  Qty = 0;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  Discount = 0;

  @Props({ type: 'number', resource: true })
  Tax = 0;

  @Props({ type: 'number', resource: true })
  AmountInDoc = 0;

  @Props({ type: 'number', resource: true })
  AmountInAR = 0;

  constructor(init: Partial<RegisterAccumulationSales>) {
    super(init);
    Object.assign(this, init);
  }
}
