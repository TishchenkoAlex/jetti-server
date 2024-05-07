import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { DocumentBaseServer } from '../models/documents.factory.server';
import { lib } from './../std.lib';
import { MSSQL } from '../mssql';
import { SDB } from './middleware/db-sessions';
import { JETTI_POOL } from '../sql.pool.jetti';
import { INoSqlDocument, dateReviverUTC } from 'jetti-middle';
import { DocumentServer } from '../models/document.server';

export const router = express.Router();

export interface IUpdateDocumentRequest {
  document: INoSqlDocument;
  options: IUpdateOptions;
}

export interface IUpdateOptions {
  updateType: 'Insert' | 'Update' | 'InsertOrUpdate';
  commands: string[]; // document server methods name
  searchKey: { key: string, value?: any }[];
  queueFlow: number;
}

// Get raw document by id
router.get('/document/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tx = new MSSQL(JETTI_POOL);
    let noSqlDoc: INoSqlDocument | null = null;
    const flatDoc = await lib.doc.byId(req.params.id, tx);
    if (flatDoc) {
      noSqlDoc = await lib.doc.noSqlDocument(flatDoc);
      delete noSqlDoc!.doc['serverModule'];
      if (noSqlDoc!['operation'] && noSqlDoc!['Operation']) delete noSqlDoc!['operation'];
      noSqlDoc!.docByKeys = Object.keys(noSqlDoc!.doc)
        .map(key => ({ key: key, value: noSqlDoc!.doc[key] }));
      if (req.query.asArray === 'true') res.json(Object.entries(flatDoc));
    }
    res.json(noSqlDoc);

  } catch (err) { next(err); }
});

router.get('/document/meta/:type/:operationId', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const tx = new MSSQL(JETTI_POOL);
    const flatDocument = { id: (await lib.util.GUID()), Operation: req.params.operationId || null };
    const docServer = await lib.doc.createDocServer(req.params.type as any, flatDocument as any, tx);
    const props = docServer.Props();
    res.json({ prop: docServer.Prop(), props: props });

  } catch (err) { next(err); }
});

router.post('/document', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdb = SDB(req);
    await sdb.tx(async tx => {
      await lib.util.adminMode(true, tx);
      try {
        const { document, options } = JSON.parse(JSON.stringify(req.body), dateReviverUTC) as IUpdateDocumentRequest;
        res.statusCode = 405;

        if (!document.type) { res.json(`Document type not specified`); return; }
        if (!options.searchKey && options.updateType !== 'Insert') { res.json(`Search key is not specified`); return; }

        let docServer: DocumentBaseServer | null = null;
        let flatDocument: any = null;
        const existDoc = await lib.doc.findDocumentByKey(options.searchKey, tx);

        if ((!existDoc || existDoc.length === 0) && options.updateType === 'Update')
          res.json(`Document not found by: ${JSON.stringify(options.searchKey)}`);
        else if (existDoc && existDoc.length > 1)
          res.json(`Found ${existDoc.length} documents by ${JSON.stringify(options.searchKey)}`);
        else if (existDoc && existDoc.length === 1) {
          if (options.updateType === 'Insert') {
            res.json(`Document already exists with ${JSON.stringify(options.searchKey)}`);
          } else {
            flatDocument = existDoc[0];
            res.statusCode = 200;
          }
        } else if ((!existDoc || existDoc.length === 0) && options.updateType.includes('Insert')) res.statusCode = 200;
        else res.json(`Bad arguments`);

        if (res.statusCode !== 200) return;

        if (!flatDocument) {
          flatDocument = { id: document.id || (await lib.util.GUID()) };
          if (document.type === 'Document.Operation') {
            flatDocument.Operation = document.doc.Operation;
            if (!flatDocument.Operation) { res.json(`Value of required field 'Operation' are not filled`); return; }
          }
        }

        docServer = await lib.doc.createDocServer(document.type, flatDocument as any, tx);

        res.statusCode = 405;

        const props = docServer.Props();
        const propsKeys = Object.keys(props);

        const excludedProps = ['doc', 'docByKey', 'serverModule'];
        const commonProps = ['ExchangeCode', 'ExchangeBase', 'version', 'operation'];

        if (document.docByKeys) {
          const unknowKeys = document.docByKeys
            .filter(keyVal => !propsKeys.includes(keyVal.key) && !commonProps.includes(keyVal.key))
            .map(keyVal => `${keyVal.key}`)
            .join(',');

          if (unknowKeys.length) {
            res.json(`Incorrect document meta: fields ${unknowKeys} do not exist in document type.`);
            return;
          }

          document.docByKeys
            .forEach(keyVal => docServer![keyVal.key] = keyVal.value);

        } else if (document.doc) {
          const unknowKeys = Object.keys(document.doc)
            .filter(key => !propsKeys.includes(key) && !commonProps.includes(key))
            .map(key => `${key}`)
            .join(',');

          if (unknowKeys.length) {
            res.json(`Incorrect document meta: fields ${unknowKeys} do not exist in document type.`);
            return;
          }

          Object.keys(document.doc)
            .forEach(key => docServer![key] = document.doc[key]);
        }

        Object.keys(document)
          .filter(key => !excludedProps.includes(key))
          .forEach(key => docServer![key] = document[key]);

        const emptyProps = propsKeys
          .filter(key => props[key].required && !docServer![key])
          .map(key => `${key}`)
          .join(',');

        if (emptyProps.length) { res.json(`Values of required fields are not filled: ${emptyProps}`); return; }

        if (docServer.type === 'Document.Operation' && !docServer['Operation']) { res.json(`Value of required field 'Operation' are not filled`); return; }

        if (options.commands) {
          for (const command of options.commands) {
            // command execution
            const docModule: () => Promise<void> = docServer['serverModule'][command];
            if (typeof docModule !== 'function') throw new Error(`Bad arguments: command "${command}" is not exist`);
            await docModule();
            if (docServer.onCommand) await docServer.onCommand(command, undefined, tx);
          }
        }

        if (docServer.deleted && docServer.posted) {
          docServer.posted = false;
        }

        await saveDoc(docServer,
          tx,
          options.queueFlow,
          { withExchangeInfo: !!(docServer['ExchangeBase'] || docServer['ExchangeCode']) }
        );

        let docByKeys: any[] = [];

        if (docServer['doc']) {
          delete docServer['doc']['workflow'];
          delete docServer['doc']['serverModule'];
          docByKeys = Object.keys(docServer['doc']).map(key => ({ key: key, value: docServer!['doc'][key] }));
          delete docServer['doc'];
        }

        if (docServer['operation'] && docServer['Operation']) delete docServer['operation'];

        res.statusCode = 200;
        const noSqlDoc = await lib.doc.noSqlDocument(docServer);
        noSqlDoc!.docByKeys = docByKeys;
        res.json(noSqlDoc);

      } catch (ex) { res.statusCode = 405; res.json(`Unknow error: ${JSON.stringify(ex.message)}`); }
      finally { await lib.util.adminMode(false, tx); }
    });
  } catch (err) { next(err); }
});

async function saveDoc(
  doc: DocumentBaseServer
  , tx: MSSQL
  , postQueue?: number
  , opts?: any): Promise<DocumentBaseServer> {
  const docServer = new DocumentServer(doc, tx);
  if (doc.isDoc && doc.posted)
    return await docServer.post({ postQueue, ...(opts || {}) });
  if (doc.isDoc)
    return await docServer.unPost();
  return await docServer.save();
}


router.delete('/document/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdb = SDB(req);
    await sdb.tx(async tx => {
      try {
        const doc = await DocumentServer.byId(req.params.id, tx);
        if (!doc) throw new Error(`API - Delete: document with id '${req.params.id}' not found.`);
        await doc.setDeleted(!!!doc.deleted);
        res.json({ Status: 'OK' });
      } catch (ex) { res.status(500).json({ ...ex, Error: ex.message }); }
      finally { await lib.util.adminMode(false, tx); }
    });
  } catch (err) { next(err); }
});

router.post('/executeOperation', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdb = SDB(req);
    await sdb.tx(async tx => {
      await lib.util.adminMode(true, tx);
      try {
        let err = '';
        const { operationId, method, args } = JSON.parse(req.body);
        let oper: DocumentBaseServer | null = null;
        if (!operationId) err = 'Empty arg "operationId"';
        else oper = await lib.doc.createDocServerById(operationId as any, tx);
        if (!oper) err = `Operation with id ${operationId} does not exist`;
        else {
          let result = {};
          const docModule: (args: { [key: string]: any }) => Promise<any> = oper['serverModule'][args.method || 'RESTMethod'];
          if (typeof docModule === 'function') result = await docModule(args);
          res.json(result);
        }
      } catch (ex) { throw new Error(ex); }
      finally { await lib.util.adminMode(false, tx); }
    });
  } catch (err) { next(err); }
});
