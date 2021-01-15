import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

@JDocument({
  type: 'Catalog.BankAccount',
  description: 'Банковский счет',
  icon: 'fa fa-list',
  menu: 'Банковкие счета',
  prefix: 'BANK-',
  dimensions: [
    { company: 'Catalog.Company' }
  ]
})
export class CatalogBankAccount extends DocumentBase {

  @Props({ type: 'Catalog.BankAccount', hiddenInList: true, order: -1 })
  parent: Ref = null;

  @Props({ type: 'Catalog.Currency', required: true, style: { width: '100px' }, isProtected: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'Catalog.Company', required: true, hiddenInList: false, isProtected: true })
  company: Ref = null;

  @Props({ type: 'Catalog.Bank', required: true })
  Bank: Ref = null;

  @Props({ type: 'boolean', required: false })
  isDefault = false;

}
