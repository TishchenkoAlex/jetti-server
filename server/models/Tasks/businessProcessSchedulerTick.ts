import { MSSQL } from '../../mssql';
import { SchedulerService } from '../../business-process/services/scheduler.service';
import { JETTI_POOL } from '../../sql.pool.jetti';
import * as Bull from 'bull';

export default async function businessProcessSchedulerTick(job: Bull.Job) {
  const db = new MSSQL(JETTI_POOL, {
    email: 'business-process@scheduler',
    isAdmin: true,
    description: 'business process scheduler',
    env: {},
    roles: [],
  });

  const result = await new SchedulerService(db).tick({
    limit: resolveLimit(job.data?.limit),
  });

  await job.progress(100);
  return result;
}

function resolveLimit(value: unknown): number {
  const limit = Number(value || 500);
  if (!Number.isInteger(limit) || limit <= 0) return 500;
  return Math.min(limit, 5000);
}
