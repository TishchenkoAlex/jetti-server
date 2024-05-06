import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from "./middleware/db-sessions";
import { AdditionalProps } from "../models/additional.props";
import { FormListSettings, buildColumnDef } from 'jetti-middle';

export const router = express.Router();

type handlerFunc = (req: Request) => Promise<any>;
type handlersMap = Record<string, handlerFunc>;

const handlers: handlersMap = {
  list: listByType,
  view: view
}

async function handle(routerPoint: string, req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await handlers[routerPoint](req));
  } catch (error) {
    next(error)
  }
}

Object.keys(handlers).forEach(point => router.post(`/${point}`, async (req: Request, res: Response, next: NextFunction) => { handle(point, req, res, next); }))

async function listByType(req: Request) {
  return await AdditionalProps.availableModelsByType(req.body!.type, SDB(req));
}

async function view(req: Request) {
  const { ownerId, propsId } = req.body;
  const tx = SDB(req);
  const docServer = await AdditionalProps.byOwner(ownerId, propsId, tx);
  const settings = new FormListSettings();
  const columnsDef = buildColumnDef(docServer.props, settings);
  const result = { schema: docServer.props, model: await docServer.toViewModel(), columnsDef, metadata: docServer.prop, settings };
  return result;
}

