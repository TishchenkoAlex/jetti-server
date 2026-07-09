import { getUserRoles } from '../../fuctions/UsersPermissions';
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

export async function getBusinessProcessUserRoles(email: string, db: MSSQL): Promise<string[]> {
  const user = await getBusinessProcessUserByEmail(email, db);
  if (!user) throw new Error(`Business process user ${email} not found`);
  return getUserRoles(user);
}

