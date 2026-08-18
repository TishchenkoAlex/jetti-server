import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessInstanceRepository } from '../repositories/bp-instance.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { BusinessProcessService } from '../services/business-process.service';
import { BusinessProcessStartInput } from '../types/business-process.types';
import { requireBusinessProcessUserId } from '../services/business-process-user-lookup';

export const router = express.Router();

router.post('/start', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const user = await requireBusinessProcessUserId(db.email, db);
    const input: BusinessProcessStartInput = {
      ...req.body,
      user,
    };
    res.json(await new BusinessProcessService(db).start(input));
  } catch (err) { next(err); }
});

router.get('/by-object/:objectType/:objectId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const repository = new BusinessProcessInstanceRepository(SDB(req));
    res.json(await repository.getByObject({
      objectType: req.params.objectType,
      objectId: req.params.objectId,
    }));
  } catch (err) { next(err); }
});

router.get('/:id/events', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const repository = new BusinessProcessEventRepository(SDB(req));
    res.json(await repository.listByInstance(req.params.id));
  } catch (err) { next(err); }
});

router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const instances = new BusinessProcessInstanceRepository(db);
    const tasks = new BusinessProcessTaskRepository(db);
    const instance = await instances.getById(req.params.id);
    if (!instance) return res.status(404).json({ error: `Business process instance ${req.params.id} not found` });

    res.json({
      instance,
      tasks: await tasks.listByInstance(instance.id),
    });
  } catch (err) { next(err); }
});
