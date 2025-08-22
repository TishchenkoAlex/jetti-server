import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';

@JDocument({
  type: 'Catalog.Unit',
  description: 'Unit',
  icon: 'fa fa-list',
  menu: 'Units',
  prefix: 'UNIT-',
  module: `{ const onOpen = async () => { this.readonly = this.readonly || !this.auth.isRoleAvailable('UNIT editor') }; return { onOpen }; }`,
})
export class CatalogUnit extends DocumentBase {

  @Props({ type: 'Catalog.Unit' })
  parent: Ref = null;

  @Props({ type: 'Catalog.Unit', useIn: 'elements' })
  BaseUnit: Ref = null;

  @Props({ type: 'number', useIn: 'elements' })
  Rate = 0;

  @Props({ type: 'enum', value: ['NONE', 'WEIGHT', 'AREA', 'LENGTH', 'VOLUME'], required: true })
  kind = 'NONE';

}
