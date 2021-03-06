import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

@JDocument({
  type: 'Catalog.InvestorGroup',
  description: 'Группа инвесторов',
  icon: 'fa fa-list',
  menu: 'Группы инвесторов',
  hierarchy: 'folders',
})
export class CatalogInvestorGroup extends DocumentBase {

  @Props({ type: 'Catalog.InvestorGroup', hiddenInList: true, order: -1, storageType: 'folders' })
  parent: Ref = null;

}
