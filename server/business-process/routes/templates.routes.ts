import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from '../../routes/middleware/db-sessions';
import { BusinessProcessTemplateRepository } from '../repositories/bp-template.repository';
import { BusinessProcessTemplateStatus } from '../types/business-process.types';
import { TemplateService } from '../services/template.service';

export const router = express.Router();

router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const repository = new BusinessProcessTemplateRepository(SDB(req));
    res.json(await repository.list({
      code: typeof req.query.code === 'string' ? req.query.code : undefined,
      status: isTemplateStatus(req.query.status) ? req.query.status : undefined,
      objectType: typeof req.query.objectType === 'string' ? req.query.objectType : undefined,
    }));
  } catch (err) { next(err); }
});

router.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const repository = new BusinessProcessTemplateRepository(SDB(req));
    const template = await repository.getById(req.params.id);
    if (!template) return res.status(404).json({ error: `Business process template ${req.params.id} not found` });
    res.json(template);
  } catch (err) { next(err); }
});

router.post('/validate', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const service = templateService(req);
    await service.validateTemplate(req.body);
    res.json({ valid: true });
  } catch (err) { next(err); }
});

router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const db = SDB(req);
    const service = templateService(req);
    const input = { ...req.body, createdBy: req.body?.createdBy || db.email || undefined };
    res.json(await service.createDraft(input));
  } catch (err) { next(err); }
});

router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const service = templateService(req);
    res.json(await service.updateDraft(req.params.id, req.body, SDB(req)));
  } catch (err) { next(err); }
});

router.post('/:id/activate', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const service = templateService(req);
    res.json(await service.activate(req.params.id, SDB(req)));
  } catch (err) { next(err); }
});

router.post('/:id/archive', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const service = templateService(req);
    await service.archive(req.params.id, SDB(req));
    res.json({});
  } catch (err) { next(err); }
});

function templateService(req: Request): TemplateService {
  return new TemplateService(new BusinessProcessTemplateRepository(SDB(req)));
}

function isTemplateStatus(value: unknown): value is BusinessProcessTemplateStatus {
  return typeof value === 'string' && ['DRAFT', 'ACTIVE', 'ARCHIVED'].includes(value);
}
