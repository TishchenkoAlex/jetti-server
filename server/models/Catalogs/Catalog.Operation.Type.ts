import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';
@JDocument({
  type: 'Catalog.Operation.Type',
  description: 'Тип операции/свойства',
  icon: 'fa fa-list',
  menu: 'Типы операций/свойств',
  prefix: 'OPERT-',
  hierarchy: 'folders'
})

export class CatalogOperationType extends DocumentBase {

  @Props({ type: 'Catalog.Operation.Type', hiddenInList: true, order: -1, panel: 'Config' })
  parent: Ref = null;

  @Props({ type: 'string', label: 'Type', panel: 'Config', useIn: "folders" })
  OwnerType = '';

  @Props({ type: 'Catalog.Operation', useIn: 'all', panel: 'Config' })
  Model: Ref = null;

  @Props({ type: 'enum', value: ['SELF', 'OBJECT', 'REGISTER'], label: 'Stored in', panel: 'Config' })
  StoredIn = '';

  @Props({ type: 'Types.Catalog', useIn: 'elements', panel: 'Config', isIndexed: true })
  Owner: Ref = null;
}
