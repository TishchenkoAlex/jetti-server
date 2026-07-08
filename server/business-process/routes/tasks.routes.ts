import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { TaskService } from '../services/task.service';

export const router = express.Router();

router.get('/my', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const roles = db.user && Array.isArray(db.user.roles) ? db.user.roles : [];
    res.json(await new TaskService(db).getMyTasks(db.email, roles));
  } catch (err) { next(err); }
});

router.post('/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    res.json(await new TaskService(db).approve(req.params.id, {
      user: db.email,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.post('/:id/reject', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    res.json(await new TaskService(db).reject(req.params.id, {
      user: db.email,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.post('/:id/redirect', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    res.json(await new TaskService(db).redirect(req.params.id, {
      user: db.email,
      targetUser: req.body?.targetUser || null,
      targetRole: req.body?.targetRole || null,
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
