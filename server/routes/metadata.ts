import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { MetaTree } from '../fuctions/metaTree';
import { SDB } from './middleware/db-sessions';

export const router = express.Router();

router.post('/treeMeta/descendants', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const childs = await MetaTree.getByNode(req.body, SDB(req));
    console.log(childs);
    res.json(childs);
  } catch (err) { next(err); }
});
