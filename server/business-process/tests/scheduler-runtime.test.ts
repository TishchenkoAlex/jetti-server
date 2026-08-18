import * as assert from 'assert';
import {
  BUSINESS_PROCESS_SCHEDULER_JOB_ID,
  ensureBusinessProcessSchedulerJob,
} from '../services/scheduler-registration';
import { BusinessProcessSchedulerLock } from '../services/scheduler-lock.service';

interface RepeatableJobFixture {
  key: string;
  name: string;
  id?: string;
  every?: string;
}

async function registrationTest(): Promise<void> {
  const repeatable: RepeatableJobFixture[] = [{
    key: 'stale-key',
    name: '__default__',
    id: BUSINESS_PROCESS_SCHEDULER_JOB_ID,
    every: '120000',
  }];
  const removed: string[] = [];
  const added: Array<{ data: any; options: any }> = [];
  const queue = {
    async getRepeatableJobs() {
      return repeatable;
    },
    async removeRepeatableByKey(key: string) {
      removed.push(key);
      const index = repeatable.findIndex(item => item.key === key);
      if (index >= 0) repeatable.splice(index, 1);
    },
    async add(data: any, options: any) {
      added.push({ data, options });
      repeatable.push({
        key: 'current-key',
        name: '__default__',
        id: options.jobId,
        every: String(options.repeat.every),
      });
      return { opts: options };
    },
  };

  const result = await ensureBusinessProcessSchedulerJob(queue as any, {
    enabled: true,
    intervalMs: 60000,
    limit: 250,
  });
  assert.deepStrictEqual(removed, ['stale-key']);
  assert.strictEqual(added.length, 1);
  assert.strictEqual(added[0].data.limit, 250);
  assert.strictEqual(added[0].options.repeat.every, 60000);
  assert.strictEqual(result.repeatKey, 'current-key');
  assert.strictEqual(result.registered, true);
  assert.ok(result.registeredAt instanceof Date);
  assert.deepStrictEqual(result.removedRepeatKeys, ['stale-key']);

  const disabledQueue = {
    getRepeatableJobs() { throw new Error('queue must not be used when scheduler is disabled'); },
  };
  const disabled = await ensureBusinessProcessSchedulerJob(disabledQueue as any, {
    enabled: false,
    intervalMs: 60000,
    limit: 500,
  });
  assert.strictEqual(disabled.enabled, false);
  assert.strictEqual(disabled.registered, false);
}

async function lockContentionTest(): Promise<void> {
  let released = false;
  const sessionDb = {
    async oneOrNone(sql: string) {
      if (sql.includes('sp_getapplock')) return { lockResult: -1 };
      throw new Error(`Unexpected SQL: ${sql}`);
    },
    async none() {
      released = true;
    },
  };
  const db = {
    async session(action: (session: unknown) => Promise<unknown>) {
      return action(sessionDb);
    },
  };

  const result = await new BusinessProcessSchedulerLock().runExclusive(
    db as any,
    async () => 'must not run',
  );
  assert.strictEqual(result.acquired, false);
  assert.strictEqual(result.result, undefined);
  assert.strictEqual(released, false, 'a lock that was not acquired must not be released');
}

async function acquiredLockTest(): Promise<void> {
  let released = false;
  const sessionDb = {
    async oneOrNone(sql: string) {
      if (sql.includes('sp_getapplock')) return { lockResult: 0 };
      throw new Error(`Unexpected SQL: ${sql}`);
    },
    async none(sql: string) {
      assert.ok(sql.includes('sp_releaseapplock'));
      released = true;
    },
  };
  const db = {
    async session(action: (session: unknown) => Promise<unknown>) {
      return action(sessionDb);
    },
  };

  const result = await new BusinessProcessSchedulerLock().runExclusive(
    db as any,
    async session => {
      assert.strictEqual(session, sessionDb);
      return 'completed';
    },
  );
  assert.strictEqual(result.acquired, true);
  assert.strictEqual(result.result, 'completed');
  assert.strictEqual(released, true);
}

async function statusTest(): Promise<void> {
  const databaseTime = new Date('2026-07-22T12:00:00.000Z');
  const db = {
    async oneOrNone() {
      return { lockAvailable: 1, databaseTime };
    },
  };
  const status = await new BusinessProcessSchedulerLock().status(db as any);
  assert.strictEqual(status.lock.available, true);
  assert.strictEqual(status.lock.resource, 'BusinessProcess.Scheduler.Tick');
  assert.strictEqual(status.databaseTime, databaseTime);
}

Promise.all([registrationTest(), lockContentionTest(), acquiredLockTest(), statusTest()])
  .then(() => process.stdout.write('BUSINESS_PROCESS_SCHEDULER_RUNTIME_OK\n'))
  .catch(error => {
    process.stderr.write(`${error instanceof Error ? error.stack || error.message : String(error)}\n`);
    process.exitCode = 1;
  });
