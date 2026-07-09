import { MSSQL } from '../../mssql';
import { BusinessProcessDelegationRepository } from '../repositories/bp-delegation.repository';
import { ResolvedAssignee } from '../types/business-process.types';

export class DelegationResolver {
  constructor(
    private readonly db: MSSQL,
    private readonly delegations = new BusinessProcessDelegationRepository(db),
  ) {}

  async applyToAssignees(args: {
    assignees: ResolvedAssignee[];
    date: Date;
    processTemplate?: string | null;
    company?: string | null;
  }): Promise<ResolvedAssignee[]> {
    const result: ResolvedAssignee[] = [];

    for (const assignee of args.assignees) {
      if (!assignee.userId) {
        result.push(assignee);
        continue;
      }

      const [delegation] = await this.delegations.listActiveForUserFrom({
        userFrom: assignee.userId,
        date: args.date,
        processTemplate: args.processTemplate || null,
        company: args.company || null,
      });

      if (!delegation) {
        result.push(assignee);
        continue;
      }

      result.push({
        ...assignee,
        userId: delegation.userTo,
        delegatedFromUser: delegation.userFrom,
      });
    }

    return result;
  }
}

