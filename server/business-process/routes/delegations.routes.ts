import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { BusinessProcessDelegationRepository } from '../repositories/bp-delegation.repository';

export const router = express.Router();

router.get('/my', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const repository = new BusinessProcessDelegationRepository(db);
    res.json(await repository.listMine(db.email));
  } catch (err) { next(err); }
});

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const userFrom = db.email;
    const userTo = req.body?.userTo;
    if (typeof userTo !== 'string' || !userTo.trim()) throw new Error('Delegation userTo is required');
    if (userTo === userFrom) throw new Error('Delegation userTo must be different from userFrom');

    const dateFrom = new Date(req.body?.dateFrom);
    if (Number.isNaN(dateFrom.getTime())) throw new Error('Delegation dateFrom must be a valid date');

    const dateTo = req.body?.dateTo ? new Date(req.body.dateTo) : null;
    if (dateTo && Number.isNaN(dateTo.getTime())) throw new Error('Delegation dateTo must be a valid date');
    if (dateTo && dateTo.getTime() < dateFrom.getTime()) throw new Error('Delegation dateTo must be greater than or equal to dateFrom');

    const repository = new BusinessProcessDelegationRepository(db);
    res.json(await repository.create({
      userFrom,
      userTo,
      role: req.body?.role || null,
      processTemplate: req.body?.processTemplate || null,
      company: req.body?.company || null,
      dateFrom,
      dateTo,
      comment: req.body?.comment || null,
    }));
  } catch (err) { next(err); }
});

router.post('/:id/cancel', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const repository = new BusinessProcessDelegationRepository(db);
    const delegation = await repository.getById(req.params.id);
    if (!delegation) return res.status(404).json({ error: `Business process delegation ${req.params.id} not found` });
    if (delegation.userFrom !== db.email) throw new Error(`User ${db.email} cannot cancel delegation ${req.params.id}`);

    await repository.cancel(req.params.id);
    res.json({});
  } catch (err) { next(err); }
});

