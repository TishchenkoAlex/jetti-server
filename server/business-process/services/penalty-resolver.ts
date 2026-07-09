export class PenaltyResolver {
  resolveAmount(rule: unknown, context: Record<string, unknown>): number | null {
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) return null;

    const source = rule as Record<string, unknown>;
    let amount: number | null = null;

    if (typeof source.amount === 'number') {
      amount = source.amount;
    } else if (typeof source.percent === 'number' && typeof source.field === 'string') {
      const base = this.resolvePath(context, source.field);
      if (typeof base === 'number') amount = base * source.percent / 100;
    } else if (typeof source.field === 'string') {
      const value = this.resolvePath(context, source.field);
      if (typeof value === 'number') amount = value;
    }

    if (amount == null || !Number.isFinite(amount) || amount <= 0) return null;
    return Math.round(amount * 100) / 100;
  }

  private resolvePath(context: Record<string, unknown>, path: string): unknown {
    return path.split('.').reduce<unknown>((value, key) => {
      if (value == null || typeof value !== 'object') return undefined;
      return (value as Record<string, unknown>)[key];
    }, context);
  }
}

