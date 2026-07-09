import { MSSQL } from '../../mssql';
import { getBusinessProcessUserRoles } from './business-process-user-lookup';

export class UserRoleResolver {
  constructor(private readonly db: MSSQL) {}

  async getRolesForUser(email: string): Promise<string[]> {
    return getBusinessProcessUserRoles(email, this.db);
  }
}

