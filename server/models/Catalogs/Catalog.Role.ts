import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

@JDocument({
  type: 'Catalog.Role',
  description: 'Роль пользователя',
  icon: 'fa fa-list',
  menu: 'Роли пользователя',
})
export class CatalogRole extends DocumentBase {

  @Props({ type: 'Catalog.Role', hiddenInList: true, order: -1 })
  parent: Ref = null;

  @Props({ type: 'string', order: 1, required: true, style: { width: '250px' } })
  code = '';

  @Props({ type: 'table', order: 1, label: 'Catalogs' })
  Catalogs: Catalogs[] = [new Catalogs()];

  @Props({ type: 'table', order: 2, label: 'Documents' })
  Documents: Documents[] = [new Documents()];

  @Props({ type: 'table', order: 3, label: 'Operation groups' })
  Groups: OperationGroups[] = [new OperationGroups()];

  @Props({ type: 'table', order: 4, label: 'Subsystems' })
  Subsystems: Subsystems[] = [new Subsystems()];
}

class Catalogs {
  @Props({ type: 'Catalog.Catalogs', required: true, style: { width: '100%' } })
  Catalog: Ref = null;

  @Props({ type: 'boolean' })
  read = true;
}

class Documents {
  @Props({ type: 'Catalog.Documents', required: true, style: { width: '100%' } })
  Document: Ref = null;

  @Props({ type: 'boolean' })
  read = true;
}

class OperationGroups {
  @Props({ type: 'Catalog.Operation.Group', required: true, style: { width: '100%' } })
  Group: Ref = null;

  @Props({ type: 'boolean' })
  read = true;
}

class Subsystems {
  @Props({ type: 'Catalog.SubSystem', required: true, style: { width: '100%' } })
  SubSystem: Ref = null;

  @Props({ type: 'boolean' })
  read = true;
}
