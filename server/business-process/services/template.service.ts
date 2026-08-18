import { MSSQL } from '../../mssql';
import {
  BusinessProcessStartMode,
  BusinessProcessStepType,
  BusinessProcessTemplate,
  BusinessProcessTransition,
} from '../types/business-process.types';
import {
  BUSINESS_PROCESS_PROCESS_RULE_PURPOSES,
  BUSINESS_PROCESS_TASK_RULE_PURPOSES,
  BusinessProcessRulePurpose,
} from '../types/business-process-rule.types';
import {
  BusinessProcessTemplateRepository,
  CreateBusinessProcessTemplateDraftInput,
} from '../repositories/bp-template.repository';
import { RuleEngine } from './rule-engine';
import { BusinessProcessRuleExecutor } from './rule-executor';

type TemplateValidationMode = 'DRAFT' | 'EXECUTABLE';

export class TemplateService {
  constructor(
    private readonly templates: BusinessProcessTemplateRepository,
    private readonly ruleEngine: RuleEngine = new RuleEngine(),
  ) {}

  async validateTemplate(template: unknown): Promise<void> {
    this.prepareTemplate(template, 'EXECUTABLE');
  }

  async createDraft(input: unknown, tx?: unknown): Promise<BusinessProcessTemplate> {
    const normalized = this.prepareTemplate(input, 'DRAFT');
    return this.repository(tx).createDraft(normalized);
  }

  async updateDraft(id: string, input: unknown, tx?: unknown): Promise<BusinessProcessTemplate> {
    const normalized = this.prepareTemplate(input, 'DRAFT');
    return this.repository(tx).updateDraft(id, normalized);
  }

  async activate(id: string, tx?: unknown): Promise<BusinessProcessTemplate> {
    const template = await this.repository(tx).getById(id);
    if (!template) throw new Error(`Business process template ${id} not found`);

    await this.validateTemplate(template);
    await this.validateCatalogRules(template, this.database(tx));
    return this.repository(tx).activate(id);
  }

  async archive(id: string, tx?: unknown): Promise<void> {
    await this.repository(tx).archive(id);
  }

  private repository(tx?: unknown): BusinessProcessTemplateRepository {
    return tx instanceof MSSQL ? new BusinessProcessTemplateRepository(tx) : this.templates;
  }

  private database(tx?: unknown): MSSQL {
    return tx instanceof MSSQL ? tx : this.templates.database;
  }

  private prepareTemplate(template: unknown, mode: TemplateValidationMode): CreateBusinessProcessTemplateDraftInput {
    try {
      const normalized = this.normalizeTemplate(template);
      this.validateTemplateShape(normalized, mode);
      return normalized;
    } catch (error) {
      if (error instanceof Error) (error as Error & { status?: number }).status = 400;
      throw error;
    }
  }

  private async validateCatalogRules(template: BusinessProcessTemplate, db: MSSQL): Promise<void> {
    const executor = new BusinessProcessRuleExecutor();
    await executor.validateBindings({
      db,
      bindings: template.rules,
      allowedPurposes: BUSINESS_PROCESS_PROCESS_RULE_PURPOSES,
      path: '$.rules',
    });

    for (const [index, step] of template.steps.entries()) {
      const purposes = await executor.validateBindings({
        db,
        bindings: step.rules,
        allowedPurposes: BUSINESS_PROCESS_TASK_RULE_PURPOSES,
        path: `$.steps[${index}].rules`,
      });
      this.validateRequiredStepRulePurposes(step.type, purposes, `$.steps[${index}].rules`);
    }
  }

  private validateRequiredStepRulePurposes(
    stepType: BusinessProcessStepType,
    purposes: BusinessProcessRulePurpose[],
    path: string,
  ): void {
    if (stepType === 'USER_TASK' && !purposes.includes('TASK_ASSIGNMENT')) {
      throw new Error(`Invalid template at ${path}: USER_TASK requires a TASK_ASSIGNMENT rule`);
    }
    if (stepType !== 'USER_TASK' && purposes.includes('TASK_ASSIGNMENT')) {
      throw new Error(`Invalid template at ${path}: TASK_ASSIGNMENT is allowed only for USER_TASK`);
    }
    const hasPenalty = purposes.includes('TASK_DEADLINE_PENALTY');
    const hasAutoExecute = purposes.includes('TASK_DEADLINE_AUTO_EXECUTE');
    if ((hasPenalty || hasAutoExecute) && !purposes.includes('TASK_DEADLINE_DATE')) {
      throw new Error(
        `Invalid template at ${path}: deadline penalty or auto execution requires a TASK_DEADLINE_DATE rule`,
      );
    }
    if (hasPenalty && hasAutoExecute) {
      throw new Error(
        `Invalid template at ${path}: TASK_DEADLINE_PENALTY and TASK_DEADLINE_AUTO_EXECUTE are mutually exclusive`,
      );
    }
  }

  private validateTemplateShape(
    template: unknown,
    mode: TemplateValidationMode,
  ): asserts template is CreateBusinessProcessTemplateDraftInput {
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

    this.validateRuleBindings(value.rules, '$.rules');

    if (!Array.isArray(value.steps) || value.steps.length === 0) {
      throw new Error('Invalid template at $.steps: steps must be non-empty array');
    }

    const stepKeys = new Set<string>();
    const stepDecisionKeys = new Map<string, Set<string>>();
    value.steps.forEach((step, index) => {
      const decisionKeys = this.validateStep(step, `$.steps[${index}]`, stepKeys, mode);
      stepDecisionKeys.set((step as Record<string, unknown>).key as string, decisionKeys);
    });

    if (!Array.isArray(value.transitions)) {
      throw new Error('Invalid template at $.transitions: transitions must be array');
    }

    const transitionKeys = new Set<string>();
    value.transitions.forEach((transition, index) => {
      this.validateTransition(
        transition,
        `$.transitions[${index}]`,
        stepKeys,
        stepDecisionKeys,
        transitionKeys,
        mode,
      );
    });
    if (mode === 'EXECUTABLE') this.validateDecisionTransitions(value.transitions, stepDecisionKeys);

    this.validateStartStepKey(value.parameters, stepKeys);
    this.ruleEngine.validate(value.startCondition);
    this.validateVisualFields(value);
  }

  private validateVisualFields(value: Record<string, unknown>): void {
    if (value.bpmnXml !== undefined && value.bpmnXml !== null && typeof value.bpmnXml !== 'string') {
      throw new Error('Invalid template at $.bpmnXml: bpmnXml must be string');
    }

    if (value.visualMapping === undefined || value.visualMapping === null) return;
    if (typeof value.visualMapping !== 'object' || Array.isArray(value.visualMapping)) {
      throw new Error('Invalid template at $.visualMapping: visualMapping must be object');
    }

    const mapping = value.visualMapping as Record<string, unknown>;
    if (mapping.schemaVersion !== undefined && ![1, 2].includes(mapping.schemaVersion as number)) {
      throw new Error('Invalid template at $.visualMapping.schemaVersion: unsupported schema version');
    }
    if (mapping.notation !== undefined && !['BPMN', 'CUSTOM_GRAPH'].includes(mapping.notation as string)) {
      throw new Error('Invalid template at $.visualMapping.notation: unsupported notation');
    }
    this.validateOptionalString(mapping.routeHash, '$.visualMapping.routeHash');
    this.validateOptionalString(mapping.startEventId, '$.visualMapping.startEventId');
    this.validateStringMap(mapping.nodeMap, '$.visualMapping.nodeMap');
    this.validateStringMap(mapping.edgeMap, '$.visualMapping.edgeMap');
    this.validateStringMap(mapping.endNodeMap, '$.visualMapping.endNodeMap');
  }

  private validateOptionalString(value: unknown, path: string): void {
    if (value !== undefined && value !== null && (typeof value !== 'string' || !value.trim())) {
      throw new Error(`Invalid template at ${path}: value must be non-empty string`);
    }
  }

  private validateStringMap(value: unknown, path: string): void {
    if (value === undefined || value === null) return;
    if (typeof value !== 'object' || Array.isArray(value)) {
      throw new Error(`Invalid template at ${path}: value must be object`);
    }
    if (Object.keys(value as object).some(key => typeof (value as Record<string, unknown>)[key] !== 'string')) {
      throw new Error(`Invalid template at ${path}: values must be strings`);
    }
  }

  private validateStep(
    step: unknown,
    path: string,
    stepKeys: Set<string>,
    mode: TemplateValidationMode,
  ): Set<string> {
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

    this.validateRuleBindings(value.rules, `${path}.rules`);

    if (!Array.isArray(value.decisions)) {
      throw new Error(`Invalid template at ${path}.decisions: decisions must be array`);
    }
    if (mode === 'EXECUTABLE' && value.type === 'USER_TASK' && value.decisions.length === 0) {
      throw new Error(
        `Invalid template at ${path}.decisions: USER_TASK requires at least one declared decision; `
        + 'TASK_AVAILABLE_DECISIONS rules can only filter declared decisions',
      );
    }

    const decisionKeys = new Set<string>();
    value.decisions.forEach((decision, index) => {
      const decisionPath = `${path}.decisions[${index}]`;
      if (!decision || typeof decision !== 'object' || Array.isArray(decision)) {
        throw new Error(`Invalid template at ${decisionPath}: decision must be object`);
      }
      const item = decision as Record<string, unknown>;
      if (typeof item.key !== 'string' || !item.key.trim()) {
        throw new Error(`Invalid template at ${decisionPath}.key: key must be non-empty string`);
      }
      if (decisionKeys.has(item.key)) {
        throw new Error(`Invalid template at ${decisionPath}.key: decision key must be unique within step`);
      }
      if (typeof item.title !== 'string' || !item.title.trim()) {
        throw new Error(`Invalid template at ${decisionPath}.title: title must be non-empty string`);
      }
      if (item.commentRequired != null && typeof item.commentRequired !== 'boolean') {
        throw new Error(`Invalid template at ${decisionPath}.commentRequired: value must be boolean`);
      }
      decisionKeys.add(item.key);
    });

    if (!['ANY', 'ALL'].includes(value.completionPolicy as string)) {
      throw new Error(`Invalid template at ${path}.completionPolicy: value must be ANY or ALL`);
    }
    return decisionKeys;
  }

  private validateTransition(
    transition: unknown,
    path: string,
    stepKeys: Set<string>,
    stepDecisionKeys: Map<string, Set<string>>,
    transitionKeys: Set<string>,
    mode: TemplateValidationMode,
  ): void {
    if (!transition || typeof transition !== 'object' || Array.isArray(transition)) {
      throw new Error(`Invalid template at ${path}: transition must be object`);
    }

    const value = transition as BusinessProcessTransition;
    if (typeof value.key !== 'string' || !value.key.trim()) {
      throw new Error(`Invalid template at ${path}.key: transition key must be non-empty string`);
    }
    if (transitionKeys.has(value.key)) {
      throw new Error(`Invalid template at ${path}.key: transition key must be unique`);
    }
    transitionKeys.add(value.key);

    if (typeof value.from !== 'string' || !stepKeys.has(value.from)) {
      throw new Error(`Invalid template at ${path}.from: from must reference existing step`);
    }

    const systemEvents = ['TIMEOUT', 'AUTO'];
    const decisionKeys = stepDecisionKeys.get(value.from) || new Set<string>();
    if (typeof value.on !== 'string' || !value.on.trim()) {
      throw new Error(`Invalid template at ${path}.on: event must be non-empty string`);
    }
    if (mode === 'EXECUTABLE' && !systemEvents.includes(value.on) && !decisionKeys.has(value.on)) {
      throw new Error(`Invalid template at ${path}.on: event must reference a decision of step ${value.from} or a system event`);
    }

    const endStates = ['END_APPROVED', 'END_REJECTED', 'END_CANCELLED'];
    if (typeof value.to !== 'string' || (!stepKeys.has(value.to) && !endStates.includes(value.to))) {
      throw new Error(`Invalid template at ${path}.to: to must reference existing step or end state`);
    }

    this.ruleEngine.validate(value.condition);
  }

  private validateDecisionTransitions(
    transitions: unknown[],
    stepDecisionKeys: Map<string, Set<string>>,
  ): void {
    stepDecisionKeys.forEach((decisionKeys, stepKey) => {
      decisionKeys.forEach(decisionKey => {
        const hasTransition = transitions.some(transition => {
          if (!transition || typeof transition !== 'object' || Array.isArray(transition)) return false;
          const value = transition as Record<string, unknown>;
          return value.from === stepKey && value.on === decisionKey;
        });
        if (!hasTransition) {
          throw new Error(
            `Invalid template at $.steps: decision ${decisionKey} of step ${stepKey} has no transition`,
          );
        }
      });
    });
  }

  private normalizeTemplate(template: unknown): unknown {
    if (!template || typeof template !== 'object' || Array.isArray(template)) return template;

    const value = template as Record<string, unknown>;
    const objectTypes = this.normalizeObjectTypes(value.objectTypes);
    const rules = this.normalizeRuleBindings(value.rules, '$.rules');
    const formStepRules = Array.isArray(value.stepRules)
      ? this.normalizeStepRuleBindings(value.stepRules)
      : null;
    const formStepDecisions = Array.isArray(value.stepDecisions)
      ? this.normalizeStepDecisions(value.stepDecisions)
      : null;
    this.validateFormStepReferences(value.steps, formStepRules, '$.stepRules');
    this.validateFormStepReferences(value.steps, formStepDecisions, '$.stepDecisions');
    const steps = Array.isArray(value.steps)
      ? value.steps.map((step, index) => this.normalizeStep(
        step,
        formStepRules,
        formStepDecisions,
        `$.steps[${index}]`,
      ))
      : value.steps;
    const normalized: Record<string, unknown> = {
      ...value,
      objectTypes,
      rules,
      steps,
      startCondition: this.normalizeJsonEditorValue(value.startCondition, '$.startCondition'),
      parameters: this.normalizeJsonEditorValue(value.parameters, '$.parameters'),
      visualMapping: this.normalizeJsonEditorValue(value.visualMapping, '$.visualMapping'),
    };
    delete normalized.stepRules;
    delete normalized.stepDecisions;
    if (!Array.isArray(value.transitions)) return normalized;

    const usedKeys = new Set<string>();
    value.transitions.forEach(transition => {
      if (!transition || typeof transition !== 'object' || Array.isArray(transition)) return;
      const key = (transition as Record<string, unknown>).key;
      if (typeof key === 'string' && key.trim()) usedKeys.add(key.trim());
    });

    let sequence = 1;
    const transitions = value.transitions.map((transition, index) => {
      if (!transition || typeof transition !== 'object' || Array.isArray(transition)) return transition;

      const item = transition as Record<string, unknown>;
      const condition = this.normalizeJsonEditorValue(item.condition, `$.transitions[${index}].condition`);
      if (typeof item.key === 'string' && item.key.trim()) {
        return { ...item, key: item.key.trim(), condition };
      }

      let key = `Transition_${sequence++}`;
      while (usedKeys.has(key)) key = `Transition_${sequence++}`;
      usedKeys.add(key);
      return {
        ...item,
        key,
        condition,
      };
    });

    return { ...normalized, transitions };
  }

  private normalizeStep(
    value: unknown,
    formRules: Array<Record<string, unknown>> | null,
    formDecisions: Array<Record<string, unknown>> | null,
    path: string,
  ): unknown {
    if (!value || typeof value !== 'object' || Array.isArray(value)) return value;
    const step = value as Record<string, unknown>;
    const stepKey = typeof step.key === 'string' ? step.key.trim() : step.key;
    const sourceDecisions = formDecisions == null
      ? step.decisions
      : formDecisions.filter(item => item.stepKey === stepKey);
    const decisions = Array.isArray(sourceDecisions)
      ? sourceDecisions.map(decision => {
        if (!decision || typeof decision !== 'object' || Array.isArray(decision)) return decision;
        const item = decision as Record<string, unknown>;
        const { stepKey: ignoredStepKey, ...decisionValue } = item;
        return {
          ...decisionValue,
          key: typeof item.key === 'string' ? item.key.trim() : item.key,
          title: typeof item.title === 'string' ? item.title.trim() : item.title,
          commentRequired: item.commentRequired === true,
        };
      })
      : [];
    const sourceRules = formRules == null
      ? step.rules
      : formRules.filter(item => item.stepKey === stepKey);
    return {
      ...step,
      key: stepKey,
      rules: this.normalizeRuleBindings(sourceRules, `${path}.rules`).map(binding => {
        if (!binding || typeof binding !== 'object' || Array.isArray(binding)) return binding;
        const { stepKey: ignoredStepKey, ...ruleBinding } = binding as Record<string, unknown>;
        return ruleBinding;
      }),
      decisions,
      completionPolicy: step.completionPolicy || 'ANY',
    };
  }

  private normalizeStepRuleBindings(value: unknown[]): Array<Record<string, unknown>> {
    return this.normalizeRuleBindings(value, '$.stepRules').map(binding => {
      if (!binding || typeof binding !== 'object' || Array.isArray(binding)) return { invalid: binding };
      const item = binding as Record<string, unknown>;
      return {
        ...item,
        stepKey: typeof item.stepKey === 'string' ? item.stepKey.trim() : item.stepKey,
      };
    });
  }

  private normalizeStepDecisions(value: unknown[]): Array<Record<string, unknown>> {
    return value.map(decision => {
      if (!decision || typeof decision !== 'object' || Array.isArray(decision)) return { invalid: decision };
      const item = decision as Record<string, unknown>;
      return {
        ...item,
        stepKey: typeof item.stepKey === 'string' ? item.stepKey.trim() : item.stepKey,
      };
    });
  }

  private validateFormStepReferences(
    steps: unknown,
    rows: Array<Record<string, unknown>> | null,
    path: string,
  ): void {
    if (rows == null) return;
    const stepKeys = new Set(Array.isArray(steps)
      ? steps.map(step => step && typeof step === 'object' && !Array.isArray(step)
        ? (typeof (step as Record<string, unknown>).key === 'string'
          ? ((step as Record<string, unknown>).key as string).trim()
          : null)
        : null).filter(key => typeof key === 'string') as string[]
      : []);
    rows.forEach((row, index) => {
      if (typeof row.stepKey !== 'string' || !row.stepKey || !stepKeys.has(row.stepKey)) {
        throw new Error(`Invalid template at ${path}[${index}].stepKey: stepKey must reference existing step`);
      }
    });
  }

  private normalizeRuleBindings(value: unknown, path: string): unknown[] {
    if (!Array.isArray(value)) return [];
    return value.map((binding, index) => {
      if (!binding || typeof binding !== 'object' || Array.isArray(binding)) return binding;
      const item = binding as Record<string, unknown>;
      return {
        ...item,
        rule: this.normalizeRef(item.rule),
        order: item.order == null ? index : item.order,
        settings: this.normalizeJsonEditorValue(item.settings, `${path}[${index}].settings`),
      };
    });
  }

  private normalizeJsonEditorValue(value: unknown, path: string): unknown {
    if (typeof value !== 'string') return value;
    if (!value.trim()) return null;
    try {
      return JSON.parse(value);
    } catch (error) {
      throw new Error(`Invalid template at ${path}: value must be valid JSON`);
    }
  }

  private normalizeRef(value: unknown): unknown {
    if (typeof value === 'string') return value.trim();
    if (!value || typeof value !== 'object' || Array.isArray(value)) return value;
    const id = (value as Record<string, unknown>).id;
    return typeof id === 'string' ? id.trim() : value;
  }

  private normalizeObjectTypes(value: unknown): unknown {
    if (!Array.isArray(value)) return value;

    return value.map(item => {
      if (typeof item === 'string') return item.trim();
      if (!item || typeof item !== 'object' || Array.isArray(item)) return item;

      const objectType = (item as Record<string, unknown>).objectType;
      if (typeof objectType === 'string') return objectType.trim();
      if (objectType && typeof objectType === 'object' && !Array.isArray(objectType)) {
        const id = (objectType as Record<string, unknown>).id;
        if (typeof id === 'string') return id.trim();
      }

      return item;
    });
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

  private validateRuleBindings(value: unknown, path: string): void {
    if (!Array.isArray(value)) {
      throw new Error(`Invalid template at ${path}: rules must be array`);
    }

    const ruleIds = new Set<string>();
    value.forEach((binding, index) => {
      const bindingPath = `${path}[${index}]`;
      if (!binding || typeof binding !== 'object' || Array.isArray(binding)) {
        throw new Error(`Invalid template at ${bindingPath}: rule binding must be object`);
      }

      const item = binding as Record<string, unknown>;
      if (typeof item.rule !== 'string' || !item.rule.trim()) {
        throw new Error(`Invalid template at ${bindingPath}.rule: Catalog.BusinessProcessRules reference is required`);
      }
      if (ruleIds.has(item.rule)) {
        throw new Error(`Invalid template at ${bindingPath}.rule: rule must be unique within scope`);
      }
      ruleIds.add(item.rule);

      if (item.order != null && (typeof item.order !== 'number' || !Number.isFinite(item.order))) {
        throw new Error(`Invalid template at ${bindingPath}.order: order must be a finite number`);
      }
      if (item.settings != null && (typeof item.settings !== 'object' || Array.isArray(item.settings))) {
        throw new Error(`Invalid template at ${bindingPath}.settings: settings must be an object`);
      }
    });
  }
}
