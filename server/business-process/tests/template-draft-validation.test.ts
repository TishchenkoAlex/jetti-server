import * as assert from 'assert';
import { TemplateService } from '../services/template.service';

const draft = {
  code: 'DraftWithoutDecisions',
  objectTypes: ['Document.CashRequest'],
  startMode: 'MANUAL',
  rules: [],
  steps: [{
    key: 'approval',
    title: 'Approval',
    type: 'USER_TASK',
    rules: [],
    decisions: [],
    completionPolicy: 'ANY',
  }],
  transitions: [{
    key: 'approve',
    from: 'approval',
    on: 'APPROVE',
    to: 'END_APPROVED',
  }],
};

const repository = {
  createDraft: async (input: unknown) => input,
};

async function run(): Promise<void> {
  const service = new TemplateService(repository as any);

  await service.createDraft(draft);

  const normalized = await service.createDraft({
    ...draft,
    rules: [{ rule: 'process-rule', settings: '{"enabled":true}' }],
    stepRules: [{ stepKey: 'approval', rule: 'task-rule', settings: '{"limit":10}' }],
    parameters: '{"startStepKey":"approval"}',
    visualMapping: '{"schemaVersion":1}',
  }) as any;
  assert.deepStrictEqual(normalized.rules[0].settings, { enabled: true });
  assert.deepStrictEqual(normalized.steps[0].rules[0].settings, { limit: 10 });
  assert.deepStrictEqual(normalized.parameters, { startStepKey: 'approval' });
  assert.deepStrictEqual(normalized.visualMapping, { schemaVersion: 1 });

  let validationError: Error | null = null;
  try {
    await service.validateTemplate(draft);
  } catch (error) {
    validationError = error as Error;
  }

  assert.ok(validationError, 'executable template validation must reject a USER_TASK without decisions');
  assert.strictEqual(
    (validationError as Error & { status?: number }).status,
    400,
    'template validation errors must be returned as bad requests',
  );
  assert.ok(
    validationError!.message.includes('TASK_AVAILABLE_DECISIONS rules can only filter declared decisions'),
    'validation error must explain the role of TASK_AVAILABLE_DECISIONS',
  );
}

run()
  .then(() => console.log('BUSINESS_PROCESS_TEMPLATE_DRAFT_VALIDATION_OK'))
  .catch(error => {
    console.error(error);
    process.exitCode = 1;
  });
