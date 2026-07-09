import * as express from 'express';
import { router as delegations } from './delegations.routes';
import { router as instances } from './instances.routes';
import { router as scheduler } from './scheduler.routes';
import { router as tasks } from './tasks.routes';
import { router as templates } from './templates.routes';

export const router = express.Router();

router.get('/status', (req, res) => {
  res.json({
    module: 'business-process',
    status: 'initialized',
  });
});

router.use('/templates', templates);
router.use('/instances', instances);
router.use('/tasks', tasks);
router.use('/delegations', delegations);
router.use('/scheduler', scheduler);
