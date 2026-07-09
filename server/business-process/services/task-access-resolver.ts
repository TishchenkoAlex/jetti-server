import { MSSQL } from '../../mssql';
import { BusinessProcessDelegationRepository } from '../repositories/bp-delegation.repository';
import { BusinessProcessTask } from '../types/business-process.types';
import { UserRoleResolver } from './user-role-resolver';

export class TaskAccessResolver {
  constructor(
    private readonly db: MSSQL,
    private readonly userRoles = new UserRoleResolver(db),
    private readonly delegations = new BusinessProcessDelegationRepository(db),
  ) {}

  async canActOnTask(args: {
    task: BusinessProcessTask;
    user: string;
    date?: Date;
    templateCode?: string | null;
    company?: string | null;
  }): Promise<{
    allowed: boolean;
    reason?: string;
    delegatedFromUser?: string | null;
  }> {
    const date = args.date || new Date();
    if (args.task.assigneeUser === args.user) return { allowed: true };

    const roles = await this.getEffectiveRoles(args.user);
    if (args.task.assigneeRole && roles.includes(args.task.assigneeRole)) return { allowed: true };

    const activeDelegations = await this.delegations.listActiveForUserTo({
      userTo: args.user,
      date,
      processTemplate: args.templateCode || null,
      company: args.company || null,
    });

    for (const delegation of activeDelegations) {
      if (args.task.assigneeUser && delegation.userFrom === args.task.assigneeUser) {
        return { allowed: true, delegatedFromUser: delegation.userFrom };
      }

      if (args.task.assigneeRole && delegation.role === args.task.assigneeRole) {
        const delegatedUserRoles = await this.getEffectiveRoles(delegation.userFrom);
        if (delegatedUserRoles.includes(args.task.assigneeRole)) {
          return { allowed: true, delegatedFromUser: delegation.userFrom };
        }
      }
    }

    return { allowed: false, reason: 'No direct assignment, role or delegation matched' };
  }

  async getEffectiveRoles(user: string): Promise<string[]> {
    return this.userRoles.getRolesForUser(user);
  }
}

