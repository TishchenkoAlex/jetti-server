export class TaskDateResolver {
  resolveActiveFrom(waitUntilRule: unknown, context: Record<string, unknown>): Date | null {
    if (!waitUntilRule || typeof waitUntilRule !== 'object' || Array.isArray(waitUntilRule)) return null;

    const rule = waitUntilRule as Record<string, unknown>;
    if (typeof rule.date === 'string') return this.toDate(rule.date);
    if (typeof rule.field === 'string') return this.toDate(this.resolvePath(context, rule.field));

    return null;
  }

  resolveDueAt(dueRule: unknown, activeFrom: Date, context: Record<string, unknown>): Date | null {
    if (!dueRule || typeof dueRule !== 'object' || Array.isArray(dueRule)) return null;

    const rule = dueRule as Record<string, unknown>;
    if (typeof rule.field === 'string') return this.toDate(this.resolvePath(context, rule.field));

    if (typeof rule.hours === 'number' && Number.isFinite(rule.hours)) {
      return new Date(activeFrom.getTime() + rule.hours * 60 * 60 * 1000);
    }

    if (typeof rule.days === 'number' && Number.isFinite(rule.days)) {
      return new Date(activeFrom.getTime() + rule.days * 24 * 60 * 60 * 1000);
    }

    return null;
  }

  private resolvePath(context: Record<string, unknown>, path: string): unknown {
    return path.split('.').reduce<unknown>((value, key) => {
      if (value == null || typeof value !== 'object') return undefined;
      return (value as Record<string, unknown>)[key];
    }, context);
  }

  private toDate(value: unknown): Date | null {
    if (value instanceof Date && !Number.isNaN(value.getTime())) return value;
    if (typeof value !== 'string') return null;

    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
}
