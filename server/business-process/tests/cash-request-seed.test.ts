import * as assert from 'assert';
import * as fs from 'fs';
import * as path from 'path';

interface SeedRule {
  code: string;
  source: string;
}

const seedPath = path.resolve(__dirname, '../sql/004.seed.cash-request-process.sql');
const seed = fs.readFileSync(seedPath, 'utf8');
const rulePattern = /\(\s*@\w+RuleId,\s*N'([^']+)',\s*N'[^']+',\s*N'([^']+)',\s*N'(module\.exports[\s\S]*?)'\s*\)(?:,|;)/g;
const rules = new Map<string, SeedRule>();
let match: RegExpExecArray | null;

while ((match = rulePattern.exec(seed)) !== null) {
  rules.set(match[2], { code: match[1], source: match[3].replace(/''/g, "'") });
}

assert.strictEqual(rules.size, 4, 'seed must contain four executable rules');

async function execute(
  purpose: string,
  context: Record<string, unknown>,
  settings: Record<string, unknown>,
): Promise<unknown> {
  const rule = rules.get(purpose);
  assert.ok(rule, `rule ${purpose} is not present in seed`);
  const AsyncFunction = Object.getPrototypeOf(async function () { return; }).constructor;
  const initialExports: Record<string, unknown> = {};
  const moduleContainer: { exports: unknown } = { exports: initialExports };
  const compiled = new AsyncFunction(
    'context',
    'tx',
    'settings',
    'module',
    'exports',
    rule.source,
  );
  const tx = {};
  const directResult = await compiled(context, tx, settings, moduleContainer, initialExports);
  const exported = moduleContainer.exports;

  if (typeof exported === 'function') return exported(context, tx, settings);
  if (exported && typeof exported === 'object' && typeof exported['execute'] === 'function') {
    return exported['execute'](context, tx, settings);
  }
  return directResult;
}

async function run(): Promise<void> {
  const author = '0a553dae-96d2-4b7e-90ec-046d7a570299';
  const now = new Date('2026-07-22T10:00:00.000Z');
  const context = {
    process: {
      instance: { authorUser: null },
      context: { author },
    },
    event: {
      user: null,
      data: { now },
    },
  };

  assert.deepStrictEqual(
    await execute('TASK_ASSIGNMENT', context, {}),
    { assignees: [{ user: author }] },
  );
  assert.deepStrictEqual(
    await execute('TASK_AVAILABLE_DECISIONS', context, { decisions: ['APPROVE', 'REJECT'] }),
    { decisions: ['APPROVE', 'REJECT'] },
  );

  const deadline = await execute('TASK_DEADLINE_DATE', context, { minutes: 60 }) as {
    deadline: { at: Date };
  };
  assert.ok(deadline.deadline.at instanceof Date);
  assert.strictEqual(deadline.deadline.at.toISOString(), '2026-07-22T11:00:00.000Z');

  assert.deepStrictEqual(
    await execute('TASK_DEADLINE_AUTO_EXECUTE', context, {
      decisionKey: 'TIMEOUT',
      comment: 'timeout',
    }),
    { decision: { key: 'TIMEOUT', comment: 'timeout' } },
  );

  assert.ok(seed.includes('{"key":"timeout","from":"finance_approval","on":"TIMEOUT","to":"END_REJECTED"}'));
  assert.ok(seed.includes('{"key":"TIMEOUT","title":"Срок истёк"'));
  process.stdout.write('CASH_REQUEST_BP_SEED_OK\n');
}

run().catch(error => {
  process.stderr.write(`${error instanceof Error ? error.stack || error.message : String(error)}\n`);
  process.exitCode = 1;
});
