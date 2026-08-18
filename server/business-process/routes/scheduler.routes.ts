import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { SchedulerService } from '../services/scheduler.service';
import { businessProcessSchedulerRegistrationState } from '../services/scheduler-registration';

export const router = express.Router();

router.get('/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = requireSchedulerAdmin(req);
    res.json({
      automatic: businessProcessSchedulerRegistrationState(),
      runtime: await new SchedulerService(db).status(),
    });
  } catch (err) { next(err); }
});

router.post('/tick', async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json(await new SchedulerService(requireSchedulerAdmin(req)).tick({
      now: parseSchedulerNow(req.body?.now),
      limit: parseSchedulerLimit(req.body?.limit),
    }));
  } catch (err) { next(err); }
});

router.post('/rebuild', async (req: Request, res: Response, next: NextFunction) => {
  try {
    res.json(await new SchedulerService(requireSchedulerAdmin(req)).rebuild());
  } catch (err) { next(err); }
});

function parseSchedulerLimit(value: unknown): number {
  if (value == null) return 500;
  const limit = Number(value);
  if (!Number.isInteger(limit) || limit <= 0) {
    throw new Error('Scheduler tick limit must be positive integer');
  }
  if (limit > 5000) {
    throw new Error('Scheduler tick limit must not exceed 5000');
  }
  return limit;
}

function parseSchedulerNow(value: unknown): Date | undefined {
  if (value == null) return undefined;
  const date = new Date(String(value));
  if (Number.isNaN(date.getTime())) {
    throw new Error('Scheduler tick now must be a valid date');
  }
  return date;
}

function requireSchedulerAdmin(req: Request) {
  const db = SDB(req);
  if (db.isAdmin) return db;
  const error = new Error('Business process scheduler operation requires administrator access') as Error & {
    status?: number;
  };
  error['status'] = 403;
  throw error;
}
