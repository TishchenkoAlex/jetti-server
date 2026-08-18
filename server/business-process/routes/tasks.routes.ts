import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { TaskService } from '../services/task.service';
import { requireBusinessProcessUserId } from '../services/business-process-user-lookup';

export const router = express.Router();

router.get('/my', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    res.json(await new TaskService(db).getMyTasks(user));
  } catch (err) { next(err); }
});

router.get('/:id/decisions', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    res.json(await new TaskService(db).getAvailableDecisions(req.params.id, user));
  } catch (err) { next(err); }
});

router.post('/:id/decide', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    const decision = req.body?.decision;
    res.json(await new TaskService(db).decide(req.params.id, {
      user,
      decision: {
        key: decision && typeof decision === 'object' ? decision.key : decision,
        comment: decision && typeof decision === 'object'
          ? decision.comment || null
          : req.body?.comment || null,
      },
    }));
  } catch (err) { next(err); }
});

router.post('/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    res.json(await new TaskService(db).approve(req.params.id, {
      user,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.post('/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    res.json(await new TaskService(db).reject(req.params.id, {
      user,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.post('/:id/redirect', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    const targetUser = await requireBusinessProcessUserId(req.body?.targetUser || '', db);
    res.json(await new TaskService(db).redirect(req.params.id, {
      user,
      targetUser,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const repository = new BusinessProcessTaskRepository(SDB(req));
    const task = await repository.getById(req.params.id);
    if (!task) return res.status(404).json({ error: `Business process task ${req.params.id} not found` });
    res.json(task);
  } catch (err) { next(err); }
});
