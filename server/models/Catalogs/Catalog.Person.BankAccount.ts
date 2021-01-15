import { JDocument, Props, Ref, DocumentBase } from 'jetti-middle';

@JDocument({
  type: 'Catalog.Person.BankAccount',
  description: 'Лицевой счет',
  icon: 'fa fa-list',
  menu: 'Лицевые счета',
  prefix: 'BANK.P-',
  dimensions: [
    { SalaryProject: 'Catalog.SalaryProject' }
  ]
})
export class CatalogPersonBankAccount extends DocumentBase {

  @Props({ type: 'Catalog.Person.BankAccount', hiddenInList: true, order: -1 })
  parent: Ref = null;

  @Props({ type: 'Catalog.Company', hiddenInForm: false })
  company: Ref = null;

  @Props({ type: 'Catalog.Person', required: true, order: 1 })
  owner: Ref = null;

  @Props({ type: 'Catalog.Bank', required: false })
  Bank: Ref = null;

  @Props({ type: 'Catalog.SalaryProject', required: false })
  SalaryProject: Ref = null;

  @Props({ type: 'date', required: false })
  OpenDate = new Date;

}
