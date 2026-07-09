import { MSSQL } from '../../mssql';
import {
  BusinessProcessStartMode,
  BusinessProcessStepType,
  BusinessProcessTemplate,
  BusinessProcessTransition,
} from '../types/business-process.types';
import {
  BusinessProcessTemplateRepository,
  CreateBusinessProcessTemplateDraftInput,
} from '../repositories/bp-template.repository';
import { RuleEngine } from './rule-engine';

export class TemplateService {
  constructor(
    private readonly templates: BusinessProcessTemplateRepository,
    private readonly ruleEngine: RuleEngine = new RuleEngine(),
  ) {}

  async validateTemplate(template: unknown): Promise<void> {
    this.validateTemplateShape(template);
  }

  async createDraft(input: unknown, tx?: unknown): Promise<BusinessProcessTemplate> {
    this.validateTemplateShape(input);
    return this.repository(tx).createDraft(input as CreateBusinessProcessTemplateDraftInput);
  }

  async activate(id: string, tx?: unknown): Promise<BusinessProcessTemplate> {
    const template = await this.repository(tx).getById(id);
    if (!template) throw new Error(`Business process template ${id} not found`);

    await this.validateTemplate(template);
    return this.repository(tx).activate(id, this.userFromTx(tx));
  }

  async archive(id: string, tx?: unknown): Promise<void> {
    await this.repository(tx).archive(id, this.userFromTx(tx));
  }

  private repository(tx?: unknown): BusinessProcessTemplateRepository {
    return tx instanceof MSSQL ? new BusinessProcessTemplateRepository(tx) : this.templates;
  }

  private userFromTx(tx?: unknown): string | null {
    return tx instanceof MSSQL ? tx.email || null : null;
  }

  private validateTemplateShape(template: unknown): asserts template is CreateBusinessProcessTemplateDraftInput {
    if (!template || typeof template !== 'object' || Array.isArray(template)) {
      throw new Error('Invalid template at $: template must be object');
    }

    const value = template as Record<string, unknown>;
    if (typeof value.code !== 'string' || !value.code.trim()) {
      throw new Error('Invalid template at $.code: code must be non-empty string');
    }

    if (!Array.isArray(value.objectTypes) || value.objectTypes.length === 0 || value.objectTypes.some(item => typeof item !== 'string' || !item.trim())) {
      throw new Error('Invalid template at $.objectTypes: objectTypes must be non-empty string array');
    }

    if (!this.isStartMode(value.startMode)) {
      throw new Error('Invalid template at $.startMode: unsupported startMode');
    }

    if (!Array.isArray(value.steps) || value.steps.length === 0) {
      throw new Error('Invalid template at $.steps: steps must be non-empty array');
    }

    const stepKeys = new Set<string>();
    value.steps.forEach((step, index) => {
      this.validateStep(step, `$.steps[${index}]`, stepKeys);
    });

    if (!Array.isArray(value.transitions)) {
      throw new Error('Invalid template at $.transitions: transitions must be array');
    }

    value.transitions.forEach((transition, index) => {
      this.validateTransition(transition, `$.transitions[${index}]`, stepKeys);
    });

    this.validateStartStepKey(value.parameters, stepKeys);
    this.ruleEngine.validate(value.startCondition);
  }

  private validateStep(step: unknown, path: string, stepKeys: Set<string>): void {
    if (!step || typeof step !== 'object' || Array.isArray(step)) {
      throw new Error(`Invalid template at ${path}: step must be object`);
    }

    const value = step as Record<string, unknown>;
    if (typeof value.key !== 'string' || !value.key.trim()) {
      throw new Error(`Invalid template at ${path}.key: key must be non-empty string`);
    }

    if (stepKeys.has(value.key)) {
      throw new Error(`Invalid template at ${path}.key: step key must be unique`);
    }
    stepKeys.add(value.key);

    if (typeof value.title !== 'string' || !value.title.trim()) {
      throw new Error(`Invalid template at ${path}.title: title must be non-empty string`);
    }

    if (!this.isStepType(value.type)) {
      throw new Error(`Invalid template at ${path}.type: unsupported step type`);
    }

    this.ruleEngine.validate(value.autoCompleteCondition);
    this.validateDueRule(value.dueRule, `${path}.dueRule`);
    this.validateWaitUntilRule(value.waitUntilRule, `${path}.waitUntilRule`);
    this.validatePenaltyRule(value.penaltyRule, `${path}.penaltyRule`);
    this.validateAssignmentRule(value.type, value.assignmentRule, `${path}.assignmentRule`);
  }

  private validateTransition(transition: unknown, path: string, stepKeys: Set<string>): void {
    if (!transition || typeof transition !== 'object' || Array.isArray(transition)) {
      throw new Error(`Invalid template at ${path}: transition must be object`);
    }

    const value = transition as BusinessProcessTransition;
    if (typeof value.from !== 'string' || !stepKeys.has(value.from)) {
      throw new Error(`Invalid template at ${path}.from: from must reference existing step`);
    }

    const endStates = ['END_APPROVED', 'END_REJECTED', 'END_CANCELLED'];
    if (typeof value.to !== 'string' || (!stepKeys.has(value.to) && !endStates.includes(value.to))) {
      throw new Error(`Invalid template at ${path}.to: to must reference existing step or end state`);
    }

    this.ruleEngine.validate(value.condition);
  }

  private isStartMode(value: unknown): value is BusinessProcessStartMode {
    return typeof value === 'string' && ['MANUAL', 'ON_SAVE', 'ON_POST', 'ON_STATUS_CHANGE'].includes(value);
  }

  private isStepType(value: unknown): value is BusinessProcessStepType {
    return typeof value === 'string' && ['USER_TASK', 'SYSTEM_TASK', 'TIMER', 'AUTO'].includes(value);
  }

  private validateStartStepKey(parameters: unknown, stepKeys: Set<string>): void {
    if (!parameters || typeof parameters !== 'object' || Array.isArray(parameters)) return;

    const startStepKey = (parameters as Record<string, unknown>).startStepKey;
    if (startStepKey == null) return;
    if (typeof startStepKey !== 'string' || !stepKeys.has(startStepKey)) {
      throw new Error('Invalid template at $.parameters.startStepKey: startStepKey must reference existing step');
    }
  }

  private validateAssignmentRule(stepType: unknown, assignmentRule: unknown, path: string): void {
    if (stepType !== 'USER_TASK') return;
    if (!assignmentRule || typeof assignmentRule !== 'object' || Array.isArray(assignmentRule)) {
      throw new Error(`Invalid template at ${path}: USER_TASK step requires assignmentRule`);
    }

    const rule = assignmentRule as Record<string, unknown>;
    if (typeof rule.type !== 'string' || !rule.type.trim()) {
      throw new Error(`Invalid template at ${path}.type: assignmentRule.type is required`);
    }

    switch (rule.type) {
      case 'ROLE':
        if (typeof rule.role !== 'string' || !rule.role.trim()) {
          throw new Error(`Invalid template at ${path}.role: role is required for ROLE assignment`);
        }
        return;
      case 'FIXED_USER':
        if (typeof rule.userId !== 'string' || !rule.userId.trim()) {
          throw new Error(`Invalid template at ${path}.userId: userId is required for FIXED_USER assignment`);
        }
        return;
      case 'DOCUMENT_FIELD':
        if (typeof rule.field !== 'string' || !rule.field.trim()) {
          throw new Error(`Invalid template at ${path}.field: field is required for DOCUMENT_FIELD assignment`);
        }
        return;
      case 'AUTHOR':
      case 'RESPONSIBLE_PERSON':
      case 'MANAGER_OF_AUTHOR':
        return;
      default:
        throw new Error(`Invalid template at ${path}.type: unsupported assignmentRule.type`);
    }
  }

  private validateDueRule(rule: unknown, path: string): void {
    if (rule == null) return;
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
      throw new Error(`Invalid template at ${path}: dueRule must be object`);
    }

    const value = rule as Record<string, unknown>;
    const keys = ['hours', 'days', 'field'].filter(key => value[key] != null);
    if (keys.length !== 1) throw new Error(`Invalid template at ${path}: dueRule must contain exactly one of hours, days or field`);

    if (value.hours != null && (typeof value.hours !== 'number' || value.hours <= 0)) {
      throw new Error(`Invalid template at ${path}.hours: hours must be positive number`);
    }
    if (value.days != null && (typeof value.days !== 'number' || value.days <= 0)) {
      throw new Error(`Invalid template at ${path}.days: days must be positive number`);
    }
    if (value.field != null && (typeof value.field !== 'string' || !value.field.trim())) {
      throw new Error(`Invalid template at ${path}.field: field must be non-empty string`);
    }
  }

  private validateWaitUntilRule(rule: unknown, path: string): void {
    if (rule == null) return;
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
      throw new Error(`Invalid template at ${path}: waitUntilRule must be object`);
    }

    const value = rule as Record<string, unknown>;
    const keys = ['date', 'field'].filter(key => value[key] != null);
    if (keys.length !== 1) throw new Error(`Invalid template at ${path}: waitUntilRule must contain exactly one of date or field`);

    if (value.date != null) {
      if (typeof value.date !== 'string' || Number.isNaN(new Date(value.date).getTime())) {
        throw new Error(`Invalid template at ${path}.date: date must be valid date string`);
      }
    }
    if (value.field != null && (typeof value.field !== 'string' || !value.field.trim())) {
      throw new Error(`Invalid template at ${path}.field: field must be non-empty string`);
    }
  }

  private validatePenaltyRule(rule: unknown, path: string): void {
    if (rule == null) return;
    if (!rule || typeof rule !== 'object' || Array.isArray(rule)) {
      throw new Error(`Invalid template at ${path}: penaltyRule must be object`);
    }

    const value = rule as Record<string, unknown>;
    if (value.amount != null) {
      if (typeof value.amount !== 'number' || value.amount <= 0) {
        throw new Error(`Invalid template at ${path}.amount: amount must be positive number`);
      }
      if (value.percent != null || value.field != null) {
        throw new Error(`Invalid template at ${path}: amount penalty cannot be combined with percent or field`);
      }
      return;
    }

    if (value.percent != null) {
      if (typeof value.percent !== 'number' || value.percent <= 0) {
        throw new Error(`Invalid template at ${path}.percent: percent must be positive number`);
      }
      if (typeof value.field !== 'string' || !value.field.trim()) {
        throw new Error(`Invalid template at ${path}.field: field is required for percent penalty`);
      }
      return;
    }

    if (value.field != null) {
      if (typeof value.field !== 'string' || !value.field.trim()) {
        throw new Error(`Invalid template at ${path}.field: field must be non-empty string`);
      }
      return;
    }

    throw new Error(`Invalid template at ${path}: penaltyRule must contain amount, field or percent with field`);
  }
}
