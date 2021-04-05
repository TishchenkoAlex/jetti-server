import { IServerDocument } from './../documents.factory.server';
import { MSSQL } from '../../mssql';
import { CatalogRole } from './Catalog.Role';
import { lib } from '../../std.lib';

export class CatalogRoleServer extends CatalogRole implements IServerDocument {

  async afterSave(tx: MSSQL) {
    lib.sys.clearUsersPermissons([]);
    return this;
  }

}
