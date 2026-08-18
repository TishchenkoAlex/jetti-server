import { MSSQL } from '../../mssql';
import {
  BusinessProcessRuleBaseContext,
  BusinessProcessRuleBinding,
  BusinessProcessRuleContext,
  BusinessProcessRuleExecution,
  BusinessProcessRulePurpose,
  isBusinessProcessRulePurpose,
} from '../types/business-process-rule.types';

type CompiledBusinessProcessRule = (
  context: BusinessProcessRuleContext,
  tx: MSSQL,
  settings: Record<string, unknown>,
  module: { exports: unknown },
  exports: Record<string, unknown>,
) => Promise<unknown>;

interface ResolvedBusinessProcessRule {
  binding: BusinessProcessRuleBinding;
  document: BusinessProcessRuleDocument;
  purpose: BusinessProcessRulePurpose;
}

interface BusinessProcessRuleDocument {
  id: string;
  type: string;
  deleted?: boolean | null;
  code?: string | null;
  description?: string | null;
  purpose?: string | null;
  module?: string | null;
}

export class BusinessProcessRuleExecutor {
  async execute<TResult = unknown>(args: {
    db: MSSQL;
    bindings: BusinessProcessRuleBinding[];
    purpose: BusinessProcessRulePurpose;
    context: BusinessProcessRuleBaseContext;
    allowedPurposes?: readonly BusinessProcessRulePurpose[];
  }): Promise<Array<BusinessProcessRuleExecution<TResult>>> {
    const resolved = await this.resolveBindings(args.db, args.bindings);
    if (args.allowedPurposes) {
      const invalid = resolved.find(item => !args.allowedPurposes!.includes(item.purpose));
      if (invalid) {
        throw new Error(
          `Business process rule ${invalid.document.code || invalid.document.id} has purpose ${invalid.purpose}, `
          + `which is not allowed in the current scope`,
        );
      }
    }
    const selected = resolved.filter(item => item.purpose === args.purpose);
    const executions: Array<BusinessProcessRuleExecution<TResult>> = [];

    for (const item of selected) {
      const rule = this.ruleInfo(item);
      const context: BusinessProcessRuleContext = {
        ...args.context,
        event: {
          ...args.context.event,
          purpose: args.purpose,
        },
        transaction: args.db,
        rule,
      };

      try {
        const compiled = this.compile(item.document);
        const result = await this.run(compiled, context, args.db, rule.settings);
        executions.push({ rule, result: result as TResult });
      } catch (error) {
        throw new Error(
          `Business process rule ${rule.code || rule.id} (${rule.purpose}) failed: ${this.errorMessage(error)}`,
        );
      }
    }

    return executions;
  }

  async validateBindings(args: {
    db: MSSQL;
    bindings: BusinessProcessRuleBinding[];
    allowedPurposes: readonly BusinessProcessRulePurpose[];
    path: string;
  }): Promise<BusinessProcessRulePurpose[]> {
    const resolved = await this.resolveBindings(args.db, args.bindings);

    resolved.forEach(item => {
      if (!args.allowedPurposes.includes(item.purpose)) {
        throw new Error(
          `Invalid template at ${args.path}: rule ${item.document.code || item.document.id} `
          + `has purpose ${item.purpose}, which is not allowed in this scope`,
        );
      }
      try {
        this.compile(item.document);
      } catch (error) {
        throw new Error(
          `Invalid template at ${args.path}: rule ${item.document.code || item.document.id} `
          + `cannot be compiled: ${this.errorMessage(error)}`,
        );
      }
    });

    return resolved.map(item => item.purpose);
  }

  private async resolveBindings(
    db: MSSQL,
    bindings: BusinessProcessRuleBinding[],
  ): Promise<ResolvedBusinessProcessRule[]> {
    const sorted = [...bindings].sort((left, right) => (left.order || 0) - (right.order || 0));
    const result: ResolvedBusinessProcessRule[] = [];

    for (const binding of sorted) {
      const document = await db.oneOrNone<BusinessProcessRuleDocument>(
        `SELECT
           source.id,
           source.type,
           source.deleted,
           ruleData.code,
           ruleData.description,
           ruleData.purpose,
           ruleData.[module]
         FROM dbo.Documents source
         CROSS APPLY OPENJSON(source.doc)
         WITH (
           code NVARCHAR(255) '$.code',
           description NVARCHAR(1024) '$.description',
           purpose NVARCHAR(100) '$.purpose',
           [module] NVARCHAR(MAX) '$.module'
         ) ruleData
         WHERE source.id = @p1`,
        [binding.rule],
      );
      if (!document) {
        throw new Error(`Catalog.BusinessProcessRules ${binding.rule} not found`);
      }
      if (document.type !== 'Catalog.BusinessProcessRules') {
        throw new Error(`Document ${binding.rule} is ${document.type}, expected Catalog.BusinessProcessRules`);
      }
      if (document.deleted) {
        throw new Error(`Catalog.BusinessProcessRules ${document.code || document.id} is deleted`);
      }
      if (!isBusinessProcessRulePurpose(document.purpose)) {
        throw new Error(`Catalog.BusinessProcessRules ${document.code || document.id} has invalid purpose`);
      }
      if (typeof document.module !== 'string' || !document.module.trim()) {
        throw new Error(`Catalog.BusinessProcessRules ${document.code || document.id} has empty module`);
      }
      result.push({ binding, document, purpose: document.purpose });
    }

    return result;
  }

  private compile(document: BusinessProcessRuleDocument): CompiledBusinessProcessRule {
    const AsyncFunction = Object.getPrototypeOf(async function () { return; }).constructor;
    return new AsyncFunction(
      'context',
      'tx',
      'settings',
      'module',
      'exports',
      document.module!,
    ) as CompiledBusinessProcessRule;
  }

  private async run(
    compiled: CompiledBusinessProcessRule,
    context: BusinessProcessRuleContext,
    db: MSSQL,
    settings: Record<string, unknown>,
  ): Promise<unknown> {
    const initialExports: Record<string, unknown> = {};
    const moduleContainer: { exports: unknown } = { exports: initialExports };
    const directResult = await compiled(context, db, settings, moduleContainer, initialExports);
    const exported = moduleContainer.exports;

    if (typeof exported === 'function') {
      return exported(context, db, settings);
    }
    if (exported && typeof exported === 'object' && typeof exported['execute'] === 'function') {
      return exported['execute'](context, db, settings);
    }
    if (exported !== initialExports || Object.keys(initialExports).length > 0) {
      throw new Error('module must export a function or an object with execute(context)');
    }
    if (typeof directResult === 'function') {
      return directResult(context, db, settings);
    }
    return directResult;
  }

  private ruleInfo(item: ResolvedBusinessProcessRule): BusinessProcessRuleContext['rule'] {
    return {
      id: item.document.id,
      code: item.document.code || '',
      description: item.document.description || '',
      purpose: item.purpose,
      settings: { ...(item.binding.settings || {}) },
    };
  }

  private errorMessage(error: unknown): string {
    return error instanceof Error ? error.message : String(error);
  }
}
