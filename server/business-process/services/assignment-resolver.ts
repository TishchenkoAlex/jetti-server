import { AssignmentRule } from '../types/assignment.types';
import { ResolvedAssignee } from '../types/business-process.types';

export interface AssignmentResolverContext {
  user?: string | null;
  author?: string | null;
  objectType: string;
  objectId: string;
  object?: Record<string, unknown>;
  processContext?: Record<string, unknown>;
}

export class AssignmentResolver {
  async resolve(rule: unknown, context: AssignmentResolverContext): Promise<ResolvedAssignee[]> {
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
      throw new Error('USER_TASK step requires assignmentRule');
    }

    const assignmentRule = rule as AssignmentRule;
    switch (assignmentRule.type) {
      case 'FIXED_USER':
        if (!assignmentRule.userId) throw new Error('Assignment rule FIXED_USER requires userId');
        return [{ userId: assignmentRule.userId }];
      case 'AUTHOR':
        return [{ userId: context.author || context.user || null }];
      case 'DOCUMENT_FIELD':
        return [{ userId: this.resolveUserFromField(assignmentRule.field, context) }];
      case 'RESPONSIBLE_PERSON':
        return [{ userId: this.resolveUserFromField('ResponsiblePerson', context) }];
      case 'ROLE':
        if (!assignmentRule.role) throw new Error('Assignment rule ROLE requires role');
        return [{ role: assignmentRule.role }];
      case 'MANAGER_OF_AUTHOR':
        throw new Error('Assignment rule MANAGER_OF_AUTHOR is not implemented yet');
      default:
        throw new Error(`Assignment rule ${(assignmentRule as any).type || '<empty>'} is not supported`);
    }
  }

  private resolveUserFromField(field: string | undefined, context: AssignmentResolverContext): string | null {
    if (!field) throw new Error('Assignment rule DOCUMENT_FIELD requires field');

    const value = this.resolvePath(context.object || {}, field)
      ?? this.resolvePath(context.processContext || {}, field);

    if (typeof value === 'string') return value;
    if (value && typeof value === 'object') {
      const source = value as Record<string, unknown>;
      if (typeof source.email === 'string') return source.email;
      if (typeof source.id === 'string') return source.id;
    }

    return null;
  }

  private resolvePath(context: Record<string, unknown>, path: string): unknown {
    return path.split('.').reduce<unknown>((value, key) => {
      if (value == null || typeof value !== 'object') return undefined;
      return (value as Record<string, unknown>)[key];
    }, context);
  }
}
