import * as assert from 'assert';
import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import { JETTI_POOL } from '../../sql.pool.jetti';
import { BusinessProcessEventType } from '../types/business-process.types';

interface SmokeCandidate {
  id: string;
  userId: string;
  status: string;
}

interface SmokeScenarioReport {
  scenario: 'APPROVE' | 'REJECT' | 'TIMEOUT';
  taskStatus: string;
  processStatus: string;
  documentStatus: string;
  decisionSource: string | null;
  eventTypes: BusinessProcessEventType[];
}

interface SmokePreflightReport {
  schemaReady: boolean;
  template: {
    installed: boolean;
    active: boolean;
    resolvedRules: number;
  };
  rules: {
    installed: number;
    required: number;
  };
  candidates: number;
}

class SmokeRollback extends Error {
  constructor() {
    super('BUSINESS_PROCESS_SMOKE_ROLLBACK');
  }
}

const adminContext = {
  email: 'business-process-smoke',
  isAdmin: true,
  description: 'business process integration smoke',
  env: {},
  roles: [],
};

async function preflight(db: MSSQL): Promise<SmokePreflightReport> {
  const schema = await db.oneOrNone<{
    templates: number;
    instances: number;
    tasks: number;
    events: number;
  }>(`SELECT
      CASE WHEN OBJECT_ID(N'dbo.BusinessProcessTemplate', N'U') IS NULL THEN 0 ELSE 1 END templates,
      CASE WHEN OBJECT_ID(N'dbo.BusinessProcessInstance', N'U') IS NULL THEN 0 ELSE 1 END instances,
      CASE WHEN OBJECT_ID(N'dbo.BusinessProcessTask', N'U') IS NULL THEN 0 ELSE 1 END tasks,
      CASE WHEN OBJECT_ID(N'dbo.BusinessProcessEvent', N'U') IS NULL THEN 0 ELSE 1 END events`);
  const schemaReady = !!schema
    && [schema.templates, schema.instances, schema.tasks, schema.events].every(value => Number(value) === 1);
  if (!schemaReady) {
    return {
      schemaReady: false,
      template: { installed: false, active: false, resolvedRules: 0 },
      rules: { installed: 0, required: 4 },
      candidates: 0,
    };
  }

  const state = await db.oneOrNone<{
    templateCount: number;
    activeTemplateCount: number;
    resolvedTemplateRuleCount: number;
    ruleCount: number;
    candidateCount: number;
  }>(`SELECT
      (SELECT COUNT(*)
       FROM dbo.BusinessProcessTemplate
       WHERE code = N'CashRequestApproval') templateCount,
      (SELECT COUNT(*)
       FROM dbo.BusinessProcessTemplate
       WHERE code = N'CashRequestApproval'
         AND status = N'ACTIVE'
         AND active = 1) activeTemplateCount,
      (SELECT COUNT(DISTINCT ruleDocument.id)
       FROM dbo.BusinessProcessTemplate template
       CROSS APPLY OPENJSON(template.steps)
       WITH (rules NVARCHAR(MAX) '$.rules' AS JSON) step
       CROSS APPLY OPENJSON(step.rules)
       WITH (ruleId UNIQUEIDENTIFIER '$.rule') binding
       INNER JOIN dbo.Documents ruleDocument
         ON ruleDocument.id = binding.ruleId
        AND ruleDocument.[type] = N'Catalog.BusinessProcessRules'
        AND ruleDocument.deleted = 0
        AND ruleDocument.isfolder = 0
        AND ruleDocument.code IN (
          N'BP.CashRequest.AssignAuthor',
          N'BP.CashRequest.Decisions',
          N'BP.CashRequest.Deadline',
          N'BP.CashRequest.Timeout'
        )
       WHERE template.code = N'CashRequestApproval'
         AND template.status = N'ACTIVE'
         AND template.active = 1) resolvedTemplateRuleCount,
      (SELECT COUNT(*)
       FROM dbo.Documents
       WHERE [type] = N'Catalog.BusinessProcessRules'
         AND code IN (
           N'BP.CashRequest.AssignAuthor',
           N'BP.CashRequest.Decisions',
           N'BP.CashRequest.Deadline',
           N'BP.CashRequest.Timeout'
         )
         AND deleted = 0
         AND isfolder = 0) ruleCount,
      (SELECT COUNT(*)
       FROM dbo.Documents request
       INNER JOIN dbo.Documents requestUser
         ON requestUser.id = request.[user]
        AND requestUser.[type] = N'Catalog.User'
        AND requestUser.deleted = 0
        AND requestUser.isfolder = 0
       WHERE request.[type] = N'Document.CashRequest'
         AND request.deleted = 0
         AND request.isfolder = 0
         AND JSON_VALUE(request.doc, '$.Status') IN (N'PREPARED', N'MODIFY', N'REJECTED')
         AND ISNULL(TRY_CONVERT(BIT, JSON_VALUE(requestUser.doc, '$.isDisabled')), 0) = 0
         AND NOT EXISTS (
           SELECT 1
           FROM dbo.BusinessProcessInstance instance
           WHERE instance.objectType = N'Document.CashRequest'
             AND instance.objectId = request.id
         )) candidateCount`);
  if (!state) throw new Error('Cannot read business process integration preflight state');

  return {
    schemaReady: true,
    template: {
      installed: Number(state.templateCount) > 0,
      active: Number(state.activeTemplateCount) === 1,
      resolvedRules: Number(state.resolvedTemplateRuleCount),
    },
    rules: {
      installed: Number(state.ruleCount),
      required: 4,
    },
    candidates: Number(state.candidateCount),
  };
}

async function requireCandidate(db: MSSQL, id: string): Promise<SmokeCandidate> {
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(id)) {
    throw new Error('BUSINESS_PROCESS_SMOKE_CASH_REQUEST_ID must be a valid UUID');
  }
  const candidate = await db.oneOrNone<SmokeCandidate>(
    `SELECT
       request.id,
       CONVERT(NVARCHAR(36), request.[user]) userId,
       JSON_VALUE(request.doc, '$.Status') status
     FROM dbo.Documents request
     INNER JOIN dbo.Documents requestUser
       ON requestUser.id = request.[user]
      AND requestUser.[type] = N'Catalog.User'
      AND requestUser.deleted = 0
      AND requestUser.isfolder = 0
     WHERE request.id = @p1
       AND request.[type] = N'Document.CashRequest'
       AND request.deleted = 0
       AND request.isfolder = 0
       AND JSON_VALUE(request.doc, '$.Status') IN (N'PREPARED', N'MODIFY', N'REJECTED')
       AND ISNULL(TRY_CONVERT(BIT, JSON_VALUE(requestUser.doc, '$.isDisabled')), 0) = 0
       AND NOT EXISTS (
         SELECT 1
         FROM dbo.BusinessProcessInstance instance
         WHERE instance.objectType = N'Document.CashRequest'
           AND instance.objectId = request.id
       )`,
    [id],
  );
  if (!candidate) {
    throw new Error('CashRequest is not eligible for an isolated business process smoke run');
  }
  return candidate;
}

async function runScenario(
  db: MSSQL,
  candidate: SmokeCandidate,
  scenario: SmokeScenarioReport['scenario'],
  runId: string,
): Promise<SmokeScenarioReport> {
  let report: SmokeScenarioReport | null = null;
  try {
    await db.tx(async tx => {
      const [
        { BusinessProcessService },
        { TaskService },
        { BusinessProcessTaskRepository },
        { BusinessProcessTemplateRepository },
        { BusinessProcessEventRepository },
        { BusinessProcessTaskDeadlineRuleResolver },
      ] = await Promise.all([
        import('../services/business-process.service'),
        import('../services/task.service'),
        import('../repositories/bp-task.repository'),
        import('../repositories/bp-template.repository'),
        import('../repositories/bp-event.repository'),
        import('../services/task-deadline-rule-resolver'),
      ]);
      const startResults = await new BusinessProcessService(tx).tryStartForObjectMany({
        objectType: 'Document.CashRequest',
        objectId: candidate.id,
        event: 'ON_POST',
        user: candidate.userId,
        tx,
        idempotencyKey: `BP_SMOKE:${runId}:${scenario}`,
      });
      assert.strictEqual(startResults.length, 1, 'exactly one CashRequest process must start');
      const started = startResults[0];
      assert.strictEqual(started.tasks.length, 1, 'finance_approval must create exactly one task');
      const task = started.tasks[0];
      assert.strictEqual(task.status, 'ACTIVE');
      assert.ok(task.deadline.at instanceof Date, 'task deadline must be calculated');

      const actor = task.assignee.user;
      const taskService = new TaskService(tx);
      const available = await taskService.getAvailableDecisions(task.id, actor, tx);
      assert.deepStrictEqual(available.map(item => item.key), ['APPROVE', 'REJECT']);

      let action;
      if (scenario === 'TIMEOUT') {
        const deadlineAt = task.deadline.at!;
        const now = new Date(deadlineAt.getTime() + 60000);
        const tasks = new BusinessProcessTaskRepository(tx);
        const overdue = await tasks.markOverdueIfActive({ taskId: task.id, now });
        assert.ok(overdue, 'task must become overdue');
        await new BusinessProcessEventRepository(tx).appendOnce({
          instanceId: started.instance.id,
          taskId: task.id,
          eventType: 'TASK_OVERDUE',
          user: null,
          payload: { smoke: true, deadlineAt, deadlineReachedAt: now },
          eventKey: `task-overdue:${task.id}`,
        });
        const template = await new BusinessProcessTemplateRepository(tx).getByCodeAndVersion(
          started.instance.templateCode,
          started.instance.templateVersion,
        );
        assert.ok(template, 'active template version must exist');
        const step = template!.steps.find(item => item.key === task.stepKey);
        assert.ok(step, 'task step must exist in template');
        const autoDecision = await new BusinessProcessTaskDeadlineRuleResolver().resolveAutoDecision({
          db: tx,
          template: template!,
          instance: started.instance,
          step: step!,
          task: overdue!,
          now,
        });
        assert.deepStrictEqual(autoDecision && autoDecision.key, 'TIMEOUT');
        action = await taskService.decideSystem(task.id, { decision: autoDecision! }, tx);
      } else {
        action = await taskService.decide(task.id, {
          user: actor,
          decision: {
            key: scenario,
            comment: scenario === 'REJECT' ? 'Business process rollback smoke test' : null,
          },
        }, tx);
      }

      const expected = scenario === 'APPROVE'
        ? { task: 'APPROVED', process: 'COMPLETED', document: 'APPROVED', source: 'USER' }
        : scenario === 'REJECT'
          ? { task: 'REJECTED', process: 'REJECTED', document: 'REJECTED', source: 'USER' }
          : { task: 'TIMEOUT', process: 'REJECTED', document: 'REJECTED', source: 'SYSTEM' };
      assert.strictEqual(action.task.status, expected.task);
      assert.strictEqual(action.instance.status, expected.process);
      assert.strictEqual(action.task.decision.source, expected.source);
      const document = await tx.oneOrNone<{ status: string }>(
        `SELECT JSON_VALUE(doc, '$.Status') status FROM dbo.Documents WHERE id = @p1`,
        [candidate.id],
      );
      assert.strictEqual(document && document.status, expected.document);
      const events = await new BusinessProcessEventRepository(tx).listByInstance(started.instance.id);
      const eventTypes = events.map(item => item.eventType);
      assert.ok(eventTypes.includes('PROCESS_STARTED'));
      assert.ok(eventTypes.includes(scenario === 'APPROVE' ? 'PROCESS_COMPLETED' : 'PROCESS_REJECTED'));
      assert.ok(eventTypes.includes(
        scenario === 'APPROVE' ? 'TASK_APPROVED' : scenario === 'REJECT' ? 'TASK_REJECTED' : 'TASK_TIMEOUT',
      ));
      report = {
        scenario,
        taskStatus: action.task.status,
        processStatus: action.instance.status,
        documentStatus: document!.status,
        decisionSource: action.task.decision.source || null,
        eventTypes,
      };
      throw new SmokeRollback();
    });
  } catch (error) {
    if (!(error instanceof SmokeRollback)) throw error;
  }
  if (!report) throw new Error(`Smoke scenario ${scenario} did not produce a report`);
  return report;
}

async function main(): Promise<void> {
  const db = new MSSQL(JETTI_POOL, adminContext);
  const shouldRun = process.argv.includes('--run');
  try {
    const state = await preflight(db);
    process.stdout.write(`BUSINESS_PROCESS_INTEGRATION_PREFLIGHT ${JSON.stringify(state)}\n`);
    if (!shouldRun) return;

    assert.strictEqual(state.schemaReady, true, 'business process SQL schema is not ready');
    assert.strictEqual(state.template.active, true, 'CashRequestApproval template is not active');
    assert.strictEqual(state.rules.installed, state.rules.required, 'CashRequest rules are not installed');
    assert.strictEqual(
      state.template.resolvedRules,
      state.rules.required,
      'CashRequestApproval active template does not resolve all required rules',
    );
    const candidateId = process.env.BUSINESS_PROCESS_SMOKE_CASH_REQUEST_ID || '';
    const candidate = await requireCandidate(db, candidateId);
    const runId = uuid();
    const reports: SmokeScenarioReport[] = [];
    for (const scenario of ['APPROVE', 'REJECT', 'TIMEOUT'] as const) {
      reports.push(await runScenario(db, candidate, scenario, runId));
    }

    const after = await db.oneOrNone<{ status: string; smokeInstances: number }>(
      `SELECT
         JSON_VALUE(request.doc, '$.Status') status,
         (SELECT COUNT(*)
          FROM dbo.BusinessProcessInstance
          WHERE idempotencyKey LIKE @p2) smokeInstances
       FROM dbo.Documents request
       WHERE request.id = @p1`,
      [candidate.id, `BP_SMOKE:${runId}:%`],
    );
    assert.strictEqual(after && after.status, candidate.status, 'CashRequest status was not rolled back');
    assert.strictEqual(after && Number(after.smokeInstances), 0, 'smoke process data was not rolled back');
    process.stdout.write(`BUSINESS_PROCESS_INTEGRATION_ROLLBACK_OK ${JSON.stringify(reports)}\n`);
  } finally {
    await JETTI_POOL.pool.destroy();
    const queueModulePath = require.resolve('../../models/Tasks/tasks');
    if (require.cache[queueModulePath]) {
      const { JQueue } = require(queueModulePath) as typeof import('../../models/Tasks/tasks');
      await JQueue.close();
    }
  }
}

main().catch(error => {
  process.stderr.write(`${error instanceof Error ? error.stack || error.message : String(error)}\n`);
  process.exitCode = 1;
});
