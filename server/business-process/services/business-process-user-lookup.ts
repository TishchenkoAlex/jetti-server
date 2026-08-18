import { MSSQL } from '../../mssql';
import { CatalogUser } from '../../models/Catalogs/Catalog.User';
import { lib } from '../../std.lib';

export async function getBusinessProcessUserByEmail(email: string, db: MSSQL): Promise<CatalogUser | null> {
  const userId = await lib.doc.byCode('Catalog.User', email, db);
  if (!userId) return null;

  const user = await lib.doc.byIdT<CatalogUser>(userId, db);
  if (!user || user.isDisabled) return null;
  return user;
}

export async function getBusinessProcessUserByIdentity(identity: string, db: MSSQL): Promise<CatalogUser | null> {
  if (!identity) return null;
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(identity)) {
    return getBusinessProcessUserByEmail(identity, db);
  }

  const user = await lib.doc.byIdT<CatalogUser>(identity, db);
  if (!user || user.type !== 'Catalog.User' || user.isDisabled) return null;
  return user;
}

export async function requireBusinessProcessUserId(identity: string, db: MSSQL): Promise<string> {
  const user = await getBusinessProcessUserByIdentity(identity, db);
  if (!user) throw new Error(`Business process user ${identity || '<empty>'} not found`);
  return user.id;
}

