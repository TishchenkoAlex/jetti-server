import { Rule, RuleCompareOperator } from '../types/rule.types';

export class RuleEngine {
  validate(rule: unknown): void {
    if (this.isEmptyRule(rule)) return;
    this.validateRule(rule, '$');
  }

  evaluate(rule: unknown, context: Record<string, unknown>): boolean {
    if (this.isEmptyRule(rule)) return true;
    this.validate(rule);
    return this.evaluateRule(rule as Rule, context || {});
  }

  private isEmptyRule(rule: unknown): boolean {
    return rule == null || (typeof rule === 'object' && Object.keys(rule as object).length === 0);
  }

  private validateRule(rule: unknown, path: string): void {
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
      throw new Error(`Invalid rule at ${path}: rule must be object`);
    }

    const keys = Object.keys(rule as object);
    const compareKeys = ['field', 'op', 'value'];
    const hasCompare = keys.some(key => compareKeys.includes(key));
    const logicalKeys = keys.filter(key => ['and', 'or', 'not'].includes(key));

    if (hasCompare) {
      const unexpectedKey = keys.find(key => !compareKeys.includes(key));
      if (unexpectedKey) {
        throw new Error(`Invalid rule at ${path}: unexpected key "${unexpectedKey}" for compare rule`);
      }
      this.validateCompareRule(rule as { field?: unknown; op?: unknown; value?: unknown }, path);
      return;
    }

    if (logicalKeys.length === 1 && keys.length !== 1) {
      const unexpectedKey = keys.find(key => key !== logicalKeys[0]);
      throw new Error(`Invalid rule at ${path}: unexpected key "${unexpectedKey}" for logical rule`);
    }

    if (logicalKeys.length !== 1) {
      throw new Error(`Invalid rule at ${path}: expected compare, and, or or not rule`);
    }

    const key = logicalKeys[0];
    const value = (rule as Record<string, unknown>)[key];

    if (key === 'and' || key === 'or') {
      if (!Array.isArray(value) || value.length === 0) {
        throw new Error(`Invalid rule at ${path}.${key}: ${key} must be non-empty array`);
      }
      value.forEach((item, index) => this.validateRule(item, `${path}.${key}[${index}]`));
      return;
    }

    this.validateRule(value, `${path}.not`);
  }

  private validateCompareRule(rule: { field?: unknown; op?: unknown; value?: unknown }, path: string): void {
    if (typeof rule.field !== 'string' || !rule.field.trim()) {
      throw new Error(`Invalid rule at ${path}.field: field must be non-empty string`);
    }

    if (!this.isCompareOperator(rule.op)) {
      throw new Error(`Invalid rule at ${path}.op: unsupported operator`);
    }

    if ((rule.op === 'in' || rule.op === 'notIn') && !Array.isArray(rule.value)) {
      throw new Error(`Invalid rule at ${path}.value: value must be array for ${rule.op}`);
    }
  }

  private isCompareOperator(value: unknown): value is RuleCompareOperator {
    return typeof value === 'string' && [
      '=',
      '!=',
      '>',
      '>=',
      '<',
      '<=',
      'in',
      'notIn',
      'exists',
      'notExists',
    ].includes(value);
  }

  private evaluateRule(rule: Rule, context: Record<string, unknown>): boolean {
    if ('and' in rule) return rule.and.every(item => this.evaluateRule(item, context));
    if ('or' in rule) return rule.or.some(item => this.evaluateRule(item, context));
    if ('not' in rule) return !this.evaluateRule(rule.not, context);

    const fieldValue = this.resolvePath(context, rule.field);

    switch (rule.op) {
      case '=':
        return fieldValue === rule.value;
      case '!=':
        return fieldValue !== rule.value;
      case '>':
        return this.compare(fieldValue, rule.value) > 0;
      case '>=':
        return this.compare(fieldValue, rule.value) >= 0;
      case '<':
        return this.compare(fieldValue, rule.value) < 0;
      case '<=':
        return this.compare(fieldValue, rule.value) <= 0;
      case 'in':
        return (rule.value as unknown[]).includes(fieldValue);
      case 'notIn':
        return !(rule.value as unknown[]).includes(fieldValue);
      case 'exists':
        return fieldValue !== undefined && fieldValue !== null;
      case 'notExists':
        return fieldValue === undefined || fieldValue === null;
      default:
        return false;
    }
  }

  private resolvePath(context: Record<string, unknown>, path: string): unknown {
    return path.split('.').reduce<unknown>((value, key) => {
      if (value == null || typeof value !== 'object') return undefined;
      return (value as Record<string, unknown>)[key];
    }, context);
  }

  private compare(left: unknown, right: unknown): number {
    if (typeof left === 'number' && typeof right === 'number') return left - right;
    if (left instanceof Date && right instanceof Date) return left.getTime() - right.getTime();
    if (typeof left === 'string' && typeof right === 'string') return left.localeCompare(right);
    return NaN;
  }
}
