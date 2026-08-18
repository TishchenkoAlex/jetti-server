import { MSSQL } from '../../mssql';
import { BusinessProcessDelegationRepository } from '../repositories/bp-delegation.repository';
import { BusinessProcessTask } from '../types/business-process.types';

export class TaskAccessResolver {
  constructor(
    private readonly db: MSSQL,
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
    if (args.task.assignee.user === args.user) return { allowed: true };

    const activeDelegations = await this.delegations.listActiveForUserTo({
      userTo: args.user,
      date,
      processTemplate: args.templateCode || null,
      company: args.company || null,
    });

    for (const delegation of activeDelegations) {
      if (delegation.userFrom === args.task.assignee.user) {
        return { allowed: true, delegatedFromUser: delegation.userFrom };
      }
    }

    return { allowed: false, reason: 'No direct assignment or delegation matched' };
  }
}

