import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

@JDocument({
  type: 'Catalog.AcquiringTerminal',
  description: 'Банковский терминал',
  icon: 'fa fa-list',
  menu: 'Банковские терминалы',
  prefix: 'AQTERM-'
})
export class CatalogAcquiringTerminal extends DocumentBase {

  @Props({ type: 'Catalog.AcquiringTerminal', hiddenInList: true, order: -1 })
  parent: Ref = null;

  @Props({ type: 'Catalog.Company', required: true, hiddenInList: false })
  company: Ref = null;

  @Props({ type: 'Catalog.BankAccount', required: true })
  BankAccount: Ref = null;

  @Props({ type: 'Catalog.Counterpartie', required: true })
  Counterpartie: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'boolean' })
  isDefault = false;

  @Props({ type: 'string', label: 'Мерчант' })
  Code1 = '';

}
