import { JETTI_POOL } from './sql.pool.jetti';
import { IDeleteTaskParams, IGetTaskParams, execQueueAPIPostRequest } from './models/Tasks/tasks';
import { CatalogUser } from './models/Catalogs/Catalog.User';
import { EXCHANGE_POOL } from './sql.pool.exchange';
import { getUserPermissions } from './fuctions/UsersPermissions';
import { configSchema, IConfigSchema } from './models/config';
import {
  DocumentBase, Ref, IFlatDocument, INoSqlDocument, RefValue, RegisterAccumulation,
  Type, RegisterInfo, PropOptions, RegisterAccumulationOptions
} from 'jetti-middle';
import { DocumentBaseServer, createDocumentServer } from './models/documents.factory.server';
import { createRegisterAccumulation as createAccumulationRegister, RegisterAccumulationTypes, registeredRegisterAccumulationTypes, } from './models/Registers/Accumulation/factory';
import { adminMode, postDocument, unpostDocument, setPostedSate, IUpdateInsertDocumentOptions as IDocumentUpsertOptions, upsertDocument } from './routes/utils/post';
import { MSSQL } from './mssql';
import { v1 } from 'uuid';
import { BankStatementUnloader } from './fuctions/BankStatementUnloader';
import { IAttachmentsSettings, CatalogAttachment } from './models/Catalogs/Catalog.Attachment';
import { x100 } from './x100.lib';
import { TASKS_POOL } from './sql.pool.tasks';
import { IQueueRow } from './models/Tasks/common';
import axios from 'axios';
import { riseUpdateMetadataEvent } from './models/Dynamic/dynamic.common';
import { SQLGenegatorMetadata } from './fuctions/SQLGenerator.MSSQL.Metadata';
import { getIndexedOperationById } from './models/indexedOperation';
import { createDocument } from './models/documents.factory';
import * as iconv from 'iconv-lite';
import { DocumentOperation } from './models/Documents/Document.Operation';
import { DocumentOperationServer } from './models/Documents/Document.Operation.server';
import { createRegisterInfo, registeredRegisterInfoTypes } from './models/Registers/Info/factory';
import { createFormServer, FormBaseServer } from './models/Forms/form.factory.server';
import { Event } from './fuctions/Event';
import { JETTI_POOL_META } from './sql.pool.meta';
import * as xml2js from 'xml2js';
import * as crypto from 'crypto';
import { Global } from './models/global';
import { DocumentServer } from './models/document.server';

export interface BatchRow { SKU: Ref; Storehouse: Ref; Qty: number; Cost: number; batch: Ref; rate: number; }
export interface FillDocBasedOnParams {
  base: string; // @required base document id
  type: string; // @required fillable document type
  operation: string; // @required fillable document operation id
  id: string; // @optional fillable document id
  saveMode: 'post' | 'save' | 'none'; // @optional fillable save mode (default: 'none')
}

export interface ExecuteCommandParams {
  command: string; // @required command name
  type: string; // @required document type
  operation: string; // @optional catalog.operation id (@required if document type is Document.Operation)
  id: string; // @optional document id
  saveMode: 'post' | 'save' | 'none'; // @optional fillable save mode (default: 'none')
}


export interface JTL {
  account: {
    balance: (account: Ref, date: Date, company: Ref, tx: MSSQL) => Promise<number | null>,
    debit: (account: Ref, date: Date, company: Ref, tx: MSSQL) => Promise<number | null>,
    kredit: (account: Ref, date: Date, company: Ref, tx: MSSQL) => Promise<number | null>,
    byCode: (code: string, tx: MSSQL) => Promise<string | null>
  };
  register: {
    movementsByDoc: <T extends RegisterAccumulation>(type: RegisterAccumulationTypes, doc: Ref, tx: MSSQL) => Promise<T[]>,
    balance: (type: RegisterAccumulationTypes, date: Date, resource: string[],
      analytics: { [key: string]: Ref }, tx: MSSQL) => Promise<{ [x: string]: number } | null>,
  };
  doc: {
    byCode: (type: string, code: string, tx: MSSQL) => Promise<string | null>;
    byId: (id: Ref, tx: MSSQL) => Promise<IFlatDocument | null>;
    byIdT: <T extends DocumentBase>(id: Ref, tx: MSSQL) => Promise<T | null>;
    historyById: (id: Ref, tx: MSSQL) => Promise<IFlatDocument | null>;
    findDocumentByKey: (searchKey: { key: string, value?: any }[], tx: MSSQL) => Promise<IFlatDocument[] | null>
    findDocumentByProps: <T>(
      type: string,
      propsFilter: { [key: string]: any },
      tx: MSSQL,
      options?: {
        matching?: 'OR' | 'AND',
        selectedFields?: string,
        first?: number,
        order?: string,
        excludeDeleted?: boolean
      }
    ) => Promise<T[]>;
    isDocumentUsedInAccumulationWithPropValueById: (docId: string, tx: MSSQL) => Promise<boolean>
    Ancestors: (id: Ref, tx: MSSQL, level?: number) => Promise<{ id: Ref, parent: Ref, level: number }[] | Ref | null>;
    Descendants: (id: Ref, tx: MSSQL) => Promise<{ id: Ref, parent: Ref }[] | null>;
    haveDescendants: (id: Ref, tx: MSSQL) => Promise<boolean>;
    formControlRef: (id: Ref, tx: MSSQL) => Promise<RefValue | null>;
    postById: (id: Ref, tx: MSSQL) => Promise<DocumentBaseServer>;
    unPostById: (id: Ref, tx: MSSQL) => Promise<DocumentBaseServer>;
    createDoc: <T extends DocumentBase>(type: string, document?: IFlatDocument) => Promise<T>;
    createDocServer: <T extends DocumentBaseServer>(type: string, document: IFlatDocument | undefined, tx: MSSQL) => Promise<T>;
    createDocServerById: <T extends DocumentBaseServer>(id: string, tx: MSSQL) => Promise<T | null>;
    saveDoc: (
      servDoc: DocumentBaseServer,
      tx: MSSQL,
      queuePostFlow?: number,
      opts?: IDocumentUpsertOptions
    ) => Promise<DocumentBaseServer>
    updateDoc: (servDoc: DocumentBaseServer, tx: MSSQL) => Promise<DocumentBaseServer>
    fillDocBasedOn: (params: FillDocBasedOnParams, tx: MSSQL) => Promise<IFlatDocument | null>
    executeCommand: (params: ExecuteCommandParams, tx: MSSQL) => Promise<IFlatDocument | null>
    noSqlDocument: (flatDoc: IFlatDocument) => INoSqlDocument | null;
    flatDocument: (noSqldoc: INoSqlDocument) => IFlatDocument | null;
    docPrefix: (type: string, tx: MSSQL) => Promise<string>
  };
  info: {
    sliceLast: <T extends RegisterInfo>(type: string, date: Date, company: Ref,
      analytics: { [key: string]: any }, tx: MSSQL) => Promise<T | null>,
    exchangeRate: (date: Date, company: Ref, currency: Ref, tx: MSSQL) => Promise<number>
  };
  accum: {
    balance: <T>(
      registerName: string,
      date: Date,
      fields: string,
      groupBy: string,
      filter: { [key: string]: any },
      topRows?: number
    ) => Promise<T[] | null>,
    turnover: <T>(
      registerName: string,
      period: { begin: Date, end: Date },
      fields: string,
      groupBy: string,
      filter: { [key: string]: any },
      topRows?: number
    ) => Promise<T[] | null>,

  };
  meta: {
    updateSQLViewsByType: (type: string, tx?: MSSQL, withSecurityPolicy?: boolean) => Promise<void>,
    getSQLMetaByType: (type: string, withSecurityPolicy?: boolean, asArrayOfQueries?: boolean) => Promise<string[] | string>
    updateSQLViewsByOperationId: (id: string, tx?: MSSQL, withSecurityPolicy?: boolean) => Promise<void>,
    riseUpdateMetadataEvent: () => void,
    propsByType: (type: string, operation?: string, tx?: MSSQL) => Promise<{ [x: string]: PropOptions }>,
    propByType: (type: string, operation?: string, tx?: MSSQL) => Promise<PropOptions | RegisterAccumulationOptions>,
    config: () => Map<string, IConfigSchema>
    registersTypes: () => { accumulation: string[], info: string[] },
    getStoredInTablesTypes: () => { [x: string]: boolean }
  };
  util: {
    // tslint:disable-next-line: max-line-length
    createObject: (init: any, tx?: MSSQL | undefined) => Promise<DocumentOperationServer | RegisterAccumulation | RegisterInfo | FormBaseServer>
    groupArray: <T>(array: T[], groupField?: string) => T[],
    formatDate: (date: Date) => string,
    parseDate: (date: string, format: string, delimiter: string) => Date,
    round: (num: number, precision?: number) => number,
    addAttachments: (attachments: CatalogAttachment[], tx: MSSQL) => Promise<any[]>,
    delAttachments: (attachmentsId: Ref[], tx: MSSQL) => Promise<boolean>,
    getAttachmentsByOwner: (ownerId: Ref, withDeleted: boolean, tx: MSSQL) => Promise<CatalogAttachment[]>,
    getAttachmentStorageById: (attachmentId: Ref, tx: MSSQL) => Promise<string>,
    getAttachmentsSettingsByOwner: (ownerId: Ref, tx: MSSQL) => Promise<IAttachmentsSettings[]>,
    salaryCompanyByCompany: (company: Ref, tx: MSSQL) => Promise<string | null>,
    bankStatementUnloadById: (docsID: string[], tx: MSSQL) => Promise<string>,
    adminMode: (mode: boolean, tx: MSSQL) => Promise<void>,
    closeMonth: (company: Ref, date: Date, tx: MSSQL) => Promise<void>,
    // currentUser: () => Promise<void>,
    getUserRoles: (user: CatalogUser) => Promise<string[]>,
    isRoleAvailable: (role: string, tx: MSSQL) => Promise<boolean>,
    closeMonthErrors: (company: Ref, date: Date, tx: MSSQL) => Promise<{ Storehouse: Ref; SKU: Ref; Cost: number }[] | null>,
    GUID: () => Promise<string>,
    getObjectPropertyById: (id: string, propPath: string, tx: MSSQL) => Promise<any>,
    exchangeDB: () => MSSQL,
    taskPoolTx: () => MSSQL,
    jettiPoolTx: () => MSSQL,
    executeGETRequest: (opts: { baseURL: string, query: string }) => Promise<any>,
    executePOSTRequest: (opts: { url: string, data: any, config?: any }) => Promise<any>,
    isEqualObjects: (object1: Object, object2: Object) => boolean,
    decodeBase64StringAsUTF8: (string: string, encodingIn: string) => string,
    converStringEncoding: (string: string, encodingIn: string, encodingOut: string) => string,
    xmlStringToJSON: (xml: string) => Promise<string>,
    timeZoneByCoordinates: (longitude: string, latitude: string) => Promise<{ timeZone?: string, error?: string }>
  };
  queue: {
    insertQueue: (row: IQueueRow, taskPoolTx?: MSSQL) => Promise<IQueueRow>
    updateQueue: (row: IQueueRow, taskPoolTx?: MSSQL) => Promise<IQueueRow>
    deleteQueue: (id: string, taskPoolTx?: MSSQL) => Promise<void>
    getQueueById: (id: string, taskPoolTx?: MSSQL) => Promise<IQueueRow | null>
    addTask: (queueId: string, taskParams, taskOpts) => Promise<any>
    getTasks: (queueId: string, params: IGetTaskParams) => Promise<{ repeatable: any[], jobs: any[] }>
    deleteTasks: (queueId: string, params: IDeleteTaskParams) => Promise<void>
  };
  queuePost: {
    addId: (id: string, flow: number, taskPoolTX?: MSSQL) => Promise<void>
  };
  log: {
    newEvent: (init: Partial<Event>) => Event,
    logIfDev: (...args: any[]) => void
  };
  cache: {
    get: <T>(key: string) => T | undefined,
    update(cacheKey: string)
  }
}

export const lib: JTL = {
  account: {
    balance,
    debit,
    kredit,
    byCode: accountByCode
  },
  register: {
    balance: registerBalance,
    movementsByDoc
  },
  doc: {
    byCode,
    byId,
    byIdT,
    findDocumentByKey,
    findDocumentByProps,
    createDoc,
    createDocServer,
    createDocServerById,
    fillDocBasedOn,
    executeCommand,
    saveDoc,
    updateDoc,
    historyById,
    Ancestors,
    Descendants,
    haveDescendants,
    formControlRef,
    postById,
    unPostById,
    noSqlDocument,
    flatDocument,
    docPrefix,
    isDocumentUsedInAccumulationWithPropValueById
  },
  meta: {
    updateSQLViewsByType,
    getSQLMetaByType,
    updateSQLViewsByOperationId,
    riseUpdateMetadataEvent,
    propsByType,
    propByType,
    config,
    registersTypes,
    getStoredInTablesTypes
  },
  info: {
    sliceLast,
    exchangeRate
  },
  accum: {
    balance: accumBalance,
    turnover
  },
  util: {
    createObject,
    groupArray,
    formatDate,
    parseDate,
    round,
    addAttachments,
    delAttachments,
    getAttachmentsByOwner,
    getAttachmentStorageById,
    getAttachmentsSettingsByOwner,
    salaryCompanyByCompany,
    bankStatementUnloadById,
    adminMode,
    closeMonth,
    getUserRoles,
    isRoleAvailable,
    GUID,
    closeMonthErrors,
    getObjectPropertyById,
    exchangeDB,
    taskPoolTx,
    executeGETRequest,
    executePOSTRequest,
    jettiPoolTx,
    isEqualObjects,
    decodeBase64StringAsUTF8,
    converStringEncoding,
    xmlStringToJSON,
    timeZoneByCoordinates
  },
  queue: {
    insertQueue,
    updateQueue,
    deleteQueue,
    getQueueById,
    addTask,
    getTasks,
    deleteTasks
  },
  queuePost: {
    addId
  },
  log: {
    newEvent,
    logIfDev
  },
  cache: {
    get: cacheGet,
    update: cacheUpdate
  }
};


function cacheUpdate(cacheKey: string) {
  return Global.cacheUpdate(cacheKey);
}

function cacheGet<T>(cacheKey: string): T | undefined {
  return Global.cache().get(cacheKey);
}


function config() {
  return configSchema();
}

async function GUID(): Promise<string> {
  return v1().toLocaleUpperCase();
}

async function accountByCode(code: string, tx: MSSQL): Promise<string | null> {
  const result = await tx.oneOrNone<any>(`
    SELECT id result FROM [Catalog.Account.v]  ${SQLGenegatorMetadata.noExpander('Catalog.Account')} WHERE code = @p1`, [code]);
  return result ? result.result as string : null;
}

async function byCode(type: string, code: string, tx: MSSQL): Promise<string | null> {
  const result = await tx.oneOrNone<{ result: string }>(`SELECT id result FROM [${type}.v]  ${SQLGenegatorMetadata.noExpander(type)} WHERE code = @p1`, [code]);
  return result ? result.result as string : null;
}

async function byId(id: string, tx: MSSQL): Promise<IFlatDocument | null> {
  if (!id) return null;
  const result = await tx.oneOrNone<INoSqlDocument | null>(`
  SELECT * FROM "Documents" WHERE id = @p1`, [id]);
  if (result) return flatDocument(result); else return null;
}

async function historyById(historyId: string, tx: MSSQL): Promise<IFlatDocument | null> {
  if (!historyId) return null;
  const result = await tx.oneOrNone<INoSqlDocument | null>(`
  SELECT
    _id id
    ,type
    ,date
    ,code
    ,description
    ,posted
    ,deleted
    ,doc
    ,parent
    ,isfolder
    ,company
    ,user
    ,info
    ,_timestamp
 FROM "Documents.Hisroty" WHERE id = @p1`, [historyId]);
  if (result) return flatDocument(result); else return null;
}

async function byIdT<T extends DocumentBase>(id: string, tx: MSSQL): Promise<T | null> {
  const result = await byId(id, tx);
  if (result) return createDocument<T>(result.type, result); else return null;
}

async function findDocumentByKey(searchKey: { key: string, value?: any }[], tx: MSSQL): Promise<IFlatDocument[] | null> {

  if (!searchKey || !searchKey.length) return null;

  const result = await tx.manyOrNone<INoSqlDocument | null>(`
  SELECT
  *
  FROM "Documents"
  WHERE 1 = 1 AND
  ${searchKey
      .map((e, index) => `${e.key} = @p${++index}`)
      .join(' AND ')}`
    , searchKey.map(e => e.value)
  );
  if (!result) return null;
  return result.map(doc => flatDocument(doc!));
}

async function findDocumentByProps<T>(
  type: string,
  propsFilter: { [key: string]: any },
  tx: MSSQL,
  options?: {
    matching?: 'OR' | 'AND',
    selectedFields?: string,
    first?: number,
    order?: string,
    excludeDeleted?: boolean
  }): Promise<T[]> {

  if (!Object.keys(propsFilter).length) return [];

  const {
    matching = 'AND',
    selectedFields = 'id, description',
    first = 0,
    order = 'description',
    excludeDeleted = false
  } = options || {};

  const filterQ = Object.keys(propsFilter)
    .map((key, index) => `${key} = @p${++index} `)
    .join(` ${matching} \n`);

  const query = `
  SELECT DISTINCT ${first ? 'TOP ' + first : ''}
  ${selectedFields}
  FROM [dbo].[${type}.v]
  WHERE 1 = 1 AND
  ${excludeDeleted ? 'deleted = 0 AND' : ''}
  (${filterQ})
  ORDER BY ${order} `;

  return await tx.manyOrNone<T>(query, Object.values(propsFilter));

}

async function createDoc<T extends DocumentBase>(type: string, document?: IFlatDocument): Promise<T> {
  return await createDocument<T>(type, document);
}

async function createDocServer<T extends DocumentBaseServer>(type: string, document: IFlatDocument | undefined, tx: MSSQL): Promise<T> {
  return await createDocumentServer<T>(type, document, tx);
}

async function createDocServerById<T extends DocumentBaseServer>(id: string, tx: MSSQL): Promise<T | null> {
  const flatDoc = await byId(id, tx);
  if (!flatDoc) return null;
  return await createDocServer<T>(flatDoc.type, flatDoc, tx);
}

async function fillDocBasedOn(params: FillDocBasedOnParams, tx: MSSQL): Promise<IFlatDocument | null> {
  const { base, type, operation, saveMode, id } = params;
  const baseDoc = await byId(base, tx);
  if (!baseDoc) throw new Error(`Document with id '${base}' is not exist`);
  // serverDoc creation
  const group = operation ? (await getObjectPropertyById(operation, 'Group', tx)).id : undefined;
  let doc: IFlatDocument | DocumentOperation | null = null;
  if (id) doc = await byId(id, tx);
  if (!doc) doc = { ...createDocument(type), Operation: operation, Group: group };
  const ServerDoc = await createDocumentServer(type, doc as IFlatDocument, tx);
  if (!ServerDoc) throw new Error(`wrong type ${type}`);
  if (id) ServerDoc.id = id;
  if (!ServerDoc.baseOn) throw new Error(`Based on method is not defined`);
  // process baseOn
  const resDoc = await ServerDoc.baseOn(base, tx);
  resDoc.user = tx.userId();
  // document saving
  if (saveMode === 'save' || saveMode === 'post') {
    resDoc.posted = saveMode.toLowerCase() === 'post';
    await saveDoc(resDoc, tx);
  }
  return noSqlDocument(resDoc);
}

async function executeCommand(params: ExecuteCommandParams, tx: MSSQL): Promise<IFlatDocument | null> {
  const { command, type, operation, saveMode, id } = params;
  if (Type.isOperation(type) && !operation && !id) throw new Error(`Bad arguments: (Type.isOperation(type) && !operation && !id)`);
  let serverDoc: DocumentBaseServer | null = null;
  // serverDoc creation
  if (id) {
    serverDoc = await createDocServerById(id, tx);
    if (!serverDoc) throw new Error(`Document with id '${id}' is not exist`);
    if (operation && operation !== (serverDoc as any).Operation)
      throw new Error(`Bad arguments: exist document has operation id "${(serverDoc as any).Operation}" (document.operation != operation)`);
  } else {
    const group = operation ? (await getObjectPropertyById(operation, 'Group', tx)).id : undefined;
    const doc = { ...createDocument(type), Operation: operation, Group: group };
    serverDoc = await createDocumentServer(type, doc as IFlatDocument, tx);
  }
  // command execution
  const docModule: () => Promise<void> = serverDoc['serverModule'][command];
  if (typeof docModule !== 'function') throw new Error(`Bad arguments: command "${command}" is not exist`);

  await docModule();
  if (serverDoc.onCommand) await serverDoc.onCommand(command, undefined, tx);

  // document saving
  if (saveMode === 'save' || saveMode === 'post') {
    serverDoc.user = tx.userId();
    serverDoc.posted = saveMode.toLowerCase() === 'post';
    await saveDoc(serverDoc, tx);
  }
  return noSqlDocument(serverDoc);
}

async function saveDoc(
  doc: DocumentBaseServer
  , tx: MSSQL
  , postQueue?: number
  , opts?: IDocumentUpsertOptions): Promise<DocumentBaseServer> {
  const docServer = new DocumentServer(doc, tx);
  if (doc.isDoc && doc.posted)
    return await docServer.post({ postQueue, ...(opts || {}) });
  else
    return await docServer.save();
}

// async function saveDoc(
//   servDoc: DocumentBaseServer
//   , tx: MSSQL
//   , queuePostFlow?: number
//   , opts?: IUpdateInsertDocumentOptions): Promise<DocumentBaseServer> {
//   const savedVersion = await byId(servDoc.id, tx);
//   const isPostedBefore = Type.isDocument(servDoc.type) && savedVersion && savedVersion.posted;
//   const isPostedAfter = Type.isDocument(servDoc.type) && servDoc.posted;
//   if (isPostedBefore) await unpostDocument(servDoc, tx);
//   if (!servDoc.code) servDoc.code = await lib.doc.docPrefix(servDoc.type, tx);
//   const isPostedUsingQueue = isPostedAfter && queuePostFlow !== undefined;
//   if (isPostedUsingQueue) servDoc.posted = false;
//   await upsertDocument(servDoc, tx, opts);
//   if (isPostedAfter) {
//     if (isPostedUsingQueue) await lib.queuePost.addId(servDoc.id, queuePostFlow as number, tx);
//     else await postDocument(servDoc, tx);
//   }
//   return servDoc;
// }


async function updateDoc(servDoc: DocumentBaseServer, tx): Promise<DocumentBaseServer> {
  return await upsertDocument(servDoc, tx);
}

async function isDocumentUsedInAccumulationWithPropValueById(docId: string, tx: MSSQL): Promise<boolean> {
  return (await isDocumentUsedInAccumulationWithPropValueByIdInTable(docId, 'Accumulation', tx) ||
    await isDocumentUsedInAccumulationWithPropValueByIdInTable(docId, '[Register.Info]', tx));
}

// tslint:disable-next-line: max-line-length
async function isDocumentUsedInAccumulationWithPropValueByIdInTable(docId: string, tableName: string, tx: MSSQL): Promise<boolean> {
  const query = `
  select TOP 1 id
  from ${tableName}
  where contains(data, @p1)`;
  return !!(await tx.oneOrNone(query, [docId]));
}

async function Ancestors(id: string, tx: MSSQL, level?: number): Promise<{ id: Ref, parent: Ref, level: number }[] | Ref | null> {
  if (!id) return null;
  const query = `SELECT id, [parent.id] parent, levelUp as N'level' FROM dbo.[Ancestors](@p1) WHERE levelUp = @p2 or @p2 is NULL`;
  let result;
  if (level || level === 0) {
    result = await tx.oneOrNone<{ id: Ref, parent: Ref, level: number } | null>(query, [id, level]);
    if (result) result = result.id;
  } else {
    result = await tx.manyOrNone<{ id: Ref, parent: Ref, level: number } | null>(query, [id, null]);
  }
  return result;
}

async function Descendants(id: string, tx: MSSQL): Promise<{ id: Ref, parent: Ref }[] | null> {
  if (!id) return null;
  return await tx.manyOrNone<{ id: Ref, parent: Ref }>(`SELECT id, parent FROM dbo.[Descendants](@p1,'')`, [id]);

}

async function haveDescendants(id: string, tx: MSSQL): Promise<boolean> {
  if (!id) return false;
  const query = 'select top 1 id from Documents where parent = @p1';
  return !!(await tx.oneOrNone(query, [id]));
}

async function salaryCompanyByCompany(company: Ref, tx: MSSQL): Promise<string | null> {
  return await x100.util.salaryCompanyByCompany(company, tx);
}

function noSqlDocument(flatDoc: INoSqlDocument | DocumentBaseServer): INoSqlDocument | null {
  if (!flatDoc) throw new Error(`lib.noSqlDocument: source is null!`);
  const { id, date, type, code, description, company, user, posted, deleted, isfolder, parent, info, timestamp, ...doc } = flatDoc;
  const getType = () => (type || '').startsWith('Operation.') ? 'Document.Operation' : type;
  return <INoSqlDocument>
    { id, date, type: getType(), code, description, company, user, posted, deleted, isfolder, parent, info, timestamp, ExchangeCode: flatDoc['ExchangeCode'], ExchangeBase: flatDoc['ExchangeBase'], doc };
}

export function flatDocument(noSqldoc: INoSqlDocument): IFlatDocument {
  if (!noSqldoc) throw new Error(`lib.flatDocument: source is null!`);
  const { doc, ...header } = noSqldoc;
  const flatDoc = { ...header, ...doc };
  return flatDoc;
}

async function docPrefix(type: string, tx: MSSQL): Promise<string> {
  const sqType = Type.isOperation(type) ? 'Document.Operation' : type;
  const metadata = configSchema().get(sqType);
  if (metadata && metadata.prefix) {
    const prefix = metadata.prefix;
    const queryText = `SELECT '${prefix}' + FORMAT((NEXT VALUE FOR "Sq.${sqType}"), '0000000000') result `;
    const result = await tx.oneOrNone<{ result: string }>(queryText);
    return result ? result.result : '';
  }
  return '';
}

async function formControlRef(id: Ref, tx: MSSQL): Promise<RefValue | null> {
  const result = await tx.oneOrNone<RefValue>(`
    SELECT "id", "code", "description" as "value", "type" FROM "Documents" WHERE id = @p1`, [id]);
  return result;
}

async function debit(account: Ref, date = new Date(), company: Ref, tx: MSSQL): Promise<number> {
  const result = await tx.oneOrNone<{ result: number }>(`
    SELECT SUM(sum) result FROM "Register.Account"
    WHERE dt = @p1 AND datetime <= @p2 AND company = @p3
  `, [account, date, company]);
  return result ? result.result : 0;
}

async function kredit(account: Ref, date = new Date(), company: Ref, tx: MSSQL): Promise<number> {
  const result = await tx.oneOrNone<{ result: number }>(`
    SELECT SUM(sum) result FROM "Register.Account"
    WHERE kt = @p1 AND datetime <= @p2 AND company = @p3
  `, [account, date, company]);
  return result ? result.result : 0;
}

async function balance(account: Ref, date = new Date(), company: Ref, tx: MSSQL): Promise<number> {
  const result = await tx.oneOrNone<{ result: number }>(`
  SELECT (SUM(u.dt) - SUM(u.kt)) result FROM (
      SELECT SUM(sum) dt, 0 kt
      FROM "Register.Account"
      WHERE dt = @p1 AND datetime <= @p2 AND company = @p3

      UNION ALL

      SELECT 0 dt, SUM(sum) kt
      FROM "Register.Account"
      WHERE kt = @p1 AND datetime <= @p2 AND company = @p3
  ) u`, [account, date, company]);
  return result ? result.result : 0;
}

async function registerBalance(type: RegisterAccumulationTypes, date = new Date(),
  resource: string[], analytics: { [key: string]: Ref }, tx: MSSQL): Promise<{ [x: string]: number }> {

  const addFields = (key) => `SUM("${key}") "${key}",\n`;
  let fields = ''; for (const el of resource) { fields += addFields(el); } fields = fields.slice(0, -2);

  const addWhere = (key) => `AND "${key}" = '${analytics[key]}'\n`;
  let where = ''; for (const el of resource) { where += addWhere(el); } where = where.slice(0, -2);

  const queryText = `
  SELECT ${fields}
  FROM "${type}"
  WHERE (1=1)
    AND date <= @p1
    ${where}
  `;

  const result = await tx.oneOrNone<any>(queryText, [date]);
  return (result ? result : {});
}

async function exchangeRate(date = new Date(), company: Ref, currency: Ref, tx: MSSQL): Promise<number> {

  const queryText = `
    SELECT TOP 1 CAST([Rate] AS FLOAT) / CASE WHEN [Mutiplicity] > 0 THEN [Mutiplicity] ELSE 1 END result
    FROM [Register.Info.ExchangeRates] WITH (NOEXPAND)
    WHERE (1=1)
      AND date <= @p1
      AND company = @p2
      AND [currency] = @p3
    ORDER BY date DESC`;
  const result = await tx.oneOrNone<{ result: number }>(queryText, [date, company, currency]);
  return result ? result.result : 1;
}

async function sliceLast<T extends RegisterInfo>(type: string, date = new Date(), company: Ref,
  analytics: { [key: string]: any }, tx: MSSQL) {

  const addWhere = (key: string) => `AND "${key}" = '${analytics[key]}' \n`;
  let where = ''; for (const el of Object.keys(analytics)) { where += addWhere(el); }

  const queryText = `
    SELECT TOP 1 * FROM [Register.Info.${type}] WITH (NOEXPAND)
    WHERE (1=1)
      AND date <= @p1
      AND company = @p2
      ${where}
    ORDER BY date DESC`;
  const result = await tx.oneOrNone<T>(queryText, [date, company]);
  return result;
}

async function accumBalance<T>(
  registerName: string,
  date: Date,
  fields: string,
  groupBy: string,
  filter: { [key: string]: any },
  topRows?: number
): Promise<T[] | null> {

  const where = Object.keys(filter).map((key, index) => `AND "${key}" = @p${index + 2}`).join('\n');
  const select = fields.split(',').map(key => `SUM(${key}) ${key}`).join(',\n');
  const having = fields.split(',').map(key => `SUM(${key}) <> 0`).join('\n AND ');
  const params = Object.values(filter);

  const queryText = `
    SELECT TOP ${topRows || 1000}
    ${groupBy},
    ${select}
    FROM [Register.Accumulation.${registerName}]
    WHERE
      date <= @p1
      ${where}
      ${groupBy ? `GROUP BY ${groupBy}` : ''}
    HAVING ${having}`;

  const tx = x100.util.x100DataDB();
  const result = await tx.manyOrNone<T>(queryText, [date, ...params]);
  return result;

}

async function turnover<T>(
  registerName: string,
  period: { begin: Date, end: Date },
  fields: string,
  groupBy: string,
  filter: { [key: string]: any },
  topRows?: number
): Promise<T[] | null> {

  const where = Object.keys(filter).map((key, index) => `AND "${key}" = @p${index + 3}`).join('\n');
  const select = fields.split(',').map(key => `SUM(${key}) ${key}`).join(',\n');
  const having = fields.split(',').map(key => `SUM(${key}) <> 0`).join('\n AND ');
  const params = Object.values(filter);

  const queryText = `
    SELECT TOP ${topRows || 1000}
      ${groupBy},
      ${select}
    FROM [Register.Accumulation.${registerName}]
    WHERE
      date BETWEEN @p1 AND @p2
      ${where}
      ${groupBy ? `GROUP BY ${groupBy}` : ''}
      HAVING ${having}`;

  const tx = x100.util.x100DataDB();
  const result = await tx.manyOrNone<T>(queryText, [period.begin, period.end, ...params]);
  return result;

}

export async function postById(id: Ref, tx: MSSQL) {
  return await DocumentServer.postById(id!, tx);
}

export async function _postById(id: Ref, tx: MSSQL) {
  await lib.util.adminMode(true, tx);
  try {
    const serverDoc = await setPostedSate(id, tx);
    await unpostDocument(serverDoc, tx);
    if (serverDoc.deleted === false) await postDocument(serverDoc, tx);
    return serverDoc;
  } catch (ex) { throw new Error(ex); }
  finally { await lib.util.adminMode(false, tx); }
}

export async function unPostById(id: Ref, tx: MSSQL) {

  let docServer: DocumentServer<any> | undefined = undefined;
  let postRes;


  docServer = await DocumentServer.byId(id!, tx);
  if (!docServer) throw DocumentServer.errorNotExistId(id);
  postRes = await docServer.unPost();


  if (!!docServer) {
    try {
      await Promise.all((docServer as DocumentServer<any>).afterTxCommitted.map(f => f()));
    } catch (error) {
      console.error('[lib.unPostById]', error);
    }
  }

  return postRes;
}

export async function _unPostById(id: Ref, tx: MSSQL) {
  await lib.util.adminMode(true, tx);
  try {
    const doc = (await lib.doc.byId(id, tx))!;
    const serverDoc = await createDocumentServer(doc.type as string, doc, tx);
    serverDoc.posted = false;
    await unpostDocument(serverDoc, tx);
    await upsertDocument(serverDoc, tx);
    return serverDoc;
  } catch (ex) { throw new Error(ex); }
  finally { await lib.util.adminMode(false, tx); }
}

function taskPoolTx(): MSSQL {
  return new MSSQL(TASKS_POOL,
    { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
}

async function executeGETRequest(opts: { baseURL: string, query: string }): Promise<any> {
  const instance = axios.create({ baseURL: opts.baseURL });
  return await instance.get(opts.query);
}

async function executePOSTRequest(opts: { url: string, data: any, config?: any }): Promise<any> {
  const instance = axios.create({ baseURL: opts.url });
  return await instance.post(opts.url, opts.data, opts.config);
}

async function updateSQLViewsByType(type: string, tx?: MSSQL, withSecurityPolicy = false): Promise<void> {
  if (!tx) tx = metaPoolTx();
  const queries = await getSQLMetaByType(type, withSecurityPolicy, true);
  const errs: any[] = [];
  for (const querText of queries) {
    try {
      await tx.none(`execute sp_executesql @p1`, [querText]);
    } catch (error) {
      errs.push(error);
    }
  }

  if (errs.length) throw new Error(JSON.stringify(errs));

}

async function getSQLMetaByType(type: string, withSecurityPolicy = false, asArrayOfQueries = false): Promise<string[] | string> {

  const isTablestored = !!Global.storedInTablesTypes()[type];
  const doc = createDocument(type);
  const subQueries = isTablestored ?
    SQLGenegatorMetadata.CatalogTableAndTrigger(doc, type, true) :
    SQLGenegatorMetadata.CreateViewCatalogIndex(type, withSecurityPolicy, true);
  const queries = [
    ...subQueries,
    ...SQLGenegatorMetadata.CreateViewCatalog(type, true)
  ];

  return asArrayOfQueries ? queries : queries.join(`\nGO\n`);

}

async function updateSQLViewsByOperationId(id: string, tx?: MSSQL, withSecurityPolicy = true): Promise<void> {
  const indexedOperation = getIndexedOperationById(id);
  if (!indexedOperation) throw new Error(`Operation ${id} is not indexed`);
  if (!tx) tx = metaPoolTx();
  const queries = [
    ...await SQLGenegatorMetadata.CreateViewOperationIndex(indexedOperation, tx, true, withSecurityPolicy),
    ...await SQLGenegatorMetadata.CreateViewOperation(indexedOperation, true)
  ];
  for (const querText of queries) {
    try {
      if (process.env.NODE_ENV !== 'production') console.log(querText);
      await tx.none(`execute sp_executesql @p1`, [querText]);
    } catch (error) {
      if (queries.indexOf(querText)) throw new Error(error);
    }
  }
}


function registersTypes() {
  return {
    accumulation: registeredRegisterAccumulationTypes(),
    info: registeredRegisterInfoTypes()
  }
}

async function propsByType(type: string, operation?: string, tx?: MSSQL): Promise<{ [x: string]: PropOptions }> {
  return (await createObject({ type, operation }, tx)).Props();
}

async function propByType(type: string, operation?: string, tx?: MSSQL): Promise<PropOptions | RegisterAccumulationOptions> {
  return (await createObject({ type, operation })).Prop();
}

function getStoredInTablesTypes() {
  return { ...Global.storedInTablesTypes() };
}

async function createDocumentOperationServer(init: Partial<DocumentOperation>, tx: MSSQL): Promise<DocumentOperationServer> {
  const fakeDoc = {
    type: 'Document.Operation',
    Operation: init.Operation,
    Group: init.Group || (await lib.util.getObjectPropertyById(init.Operation as string, 'Group', tx)).id
  };
  const doc: IFlatDocument = { ...createDocument(fakeDoc.type), ...fakeDoc };
  return await createDocumentServer<DocumentOperationServer>(fakeDoc.type, doc, tx);
}

async function createObject(init: any, tx?: MSSQL) {

  if (Type.isOperation(init.type) && init.Operation)
    return await createDocumentOperationServer(init, tx!);

  if (init.type.startsWith('Document.') || init.type.startsWith('Catalog.'))
    return await createDocumentServer<DocumentOperationServer>(init.type, init, tx!);

  if (init.type.startsWith('Register.Accumulation.'))
    return createAccumulationRegister(init);

  if (init.type.startsWith('Register.Info.'))
    return createRegisterInfo(init);

  if (init.type.startsWith('Form.'))
    return createFormServer(init);

  throw new Error(`createObject: type ${init!.type} is not registered`);

}

export function isEqualObjects(object1: Object, object2: Object): boolean {
  const keysObject1 = Object.keys(object1);
  const keysObject2 = Object.keys(object2);
  if (keysObject1.length !== keysObject2.length ||
    keysObject1.join().length !== keysObject2.join().length)
    return false;
  keysObject1.forEach(keyObj1 => {
    if (!keysObject2.includes(keyObj1) ||
      object1[keyObj1] !== object2[keyObj1]) return false;
  });
  return true;
}

function decodeBase64StringAsUTF8(string: string, encodingIn: string): string {
  const buff = new Buffer(string, 'base64');
  return iconv.decode(Buffer.from(buff), encodingIn).toString();
}

function converStringEncoding(string: string, encodingIn: string, ecnodingOut: string) {
  const buff = Buffer.from(string, encodingIn as any);
  return iconv.decode(buff, ecnodingOut).toString();
}

async function xmlStringToJSON(xml: string): Promise<string> {
  return await xml2js.parseStringPromise(xml);
}

async function timeZoneByCoordinates(longitude: string, latitude: string): Promise<{ timeZone?: string, error?: string }> {
  const url = `https://jetti-front-fn.azurewebsites.net/api/http-get-timezone?`;
  const data = {
    location: {
      type: 'Point',
      coordinates: [
        `${latitude}`.replace(',', '.'),
        `${longitude}`.replace(',', '.')
      ]
    }
  };

  const opts = { url: url, data };
  const result = await lib.util.executePOSTRequest(opts);

  if (result.status !== 200)
    return { error: result.statusText || 'Server error' };
  return { timeZone: result.data?.WindowsId || '' };

}

export function getAdminTX(): MSSQL {
  return new MSSQL(TASKS_POOL);
}

function jettiPoolTx(): MSSQL {
  return new MSSQL(JETTI_POOL);
}

function metaPoolTx(): MSSQL {
  return new MSSQL(JETTI_POOL_META);
}

async function insertQueue(row: IQueueRow, taskPoolTX?: MSSQL): Promise<IQueueRow> {

  if (!row.date) row.date = new Date();
  if (!taskPoolTX) taskPoolTX = taskPoolTx();

  const query = `INSERT INTO [exc].[Queue]([type],[doc],[status],[ExchangeCode],[ExchangeBase],[Date],[id])
  VALUES (@p1, JSON_QUERY(@p2), @p3, @p4, @p5, @p6, @p7)`;

  if (!row.id) row.id = v1().toLocaleUpperCase();

  await taskPoolTX!.none(query,
    [row.type, row.doc, row.status, row.exchangeCode, row.exchangeBase, row.date, row.id]
  );

  return row;

}

async function addId(id: string, flow: number, taskPoolTX?: MSSQL): Promise<void> {
  if (!id) return;
  if (!taskPoolTX) taskPoolTX = taskPoolTx();
  await taskPoolTX!.none(`INSERT INTO [exc].[QueuePost]([id],[flow])
  VALUES (@p1, @p2)`, [id, flow]);
}

async function updateQueue(row: IQueueRow, taskPoolTX?: MSSQL): Promise<IQueueRow> {

  if (!row.date) row.date = new Date();
  if (!taskPoolTX) taskPoolTX = taskPoolTx();

  const query = `UPDATE [exc].[Queue]
    SET
      [type] = @p1,
      [doc] = JSON_QUERY(@p2),
      [status] = @p3,
      [ExchangeCode] = @p4,
      [ExchangeBase] = @p5,
      [Date] = @p6 WHERE id = @p7`;

  if (!row.id) row.id = v1().toLocaleUpperCase();

  await taskPoolTX!.none(query,
    [row.type, row.doc, row.status, row.exchangeCode, row.exchangeBase, row.date, row.id]
  );

  return row;

}

async function deleteQueue(id: string, taskPoolTX?: MSSQL): Promise<void> {
  if (!taskPoolTX) taskPoolTX = taskPoolTx();
  const query = `DELETE FROM [exc].[Queue] WHERE id = @p1`;
  await taskPoolTX!.none(query, [id]);
}

async function getQueueById(id: string, taskPoolTX?: MSSQL): Promise<IQueueRow | null> {
  if (taskPoolTX) taskPoolTX = taskPoolTx();
  const query = `SELECT * FROM  [exc].[Queue] WHERE id = @p1`;
  return await taskPoolTX!.oneOrNone(query, [id]);
}

async function addTask(queueId: string, taskParams, taskOpts): Promise<any> {
  return await execQueueAPIPostRequest(queueId, `api/v1.0/task/add`, { params: taskParams, opts: taskOpts });
}

async function getTasks(queueId: string, params: IGetTaskParams): Promise<{ repeatable: any[], jobs: any[] }> {
  return await execQueueAPIPostRequest(queueId, `api/v1.0/task/get`, params);
}

async function deleteTasks(queueId: string, params: IDeleteTaskParams): Promise<void> {
  return await execQueueAPIPostRequest(queueId, `api/v1.0/task/delete`, params);
}

function formatDate(date: Date): string {
  const dd = date.getDate();
  const mm = date.getMonth() + 1;
  const yy = date.getFullYear();
  return `${dd < 10 ? '0' + dd : dd}.${mm < 10 ? '0' + mm : mm}.${yy}`;

}

// stringToDate("17/9/2014","dd/MM/yyyy","/");
function parseDate(date: string, format: string, delimiter: string): Date {
  const formatItems = format.toLowerCase().split(delimiter);
  const dateItems = date.split(delimiter);
  const monthIndex = formatItems.indexOf('mm');
  const dayIndex = formatItems.indexOf('dd');
  const yearIndex = formatItems.indexOf('yyyy');
  const month = parseInt(dateItems[monthIndex], undefined) - 1;
  return new Date(dateItems[yearIndex] as any, month, dateItems[dayIndex] as any);
}

function groupArray<T>(array: T[], groupField = ''): T[] {
  return groupField ? [...new Set<T>(array.map(e => e[groupField]))] : [...new Set<T>(array)];
}

function round(num: number, precision = 4): number {
  const factor = +`1${'0'.repeat(precision)}`;
  return Math.round(num * factor) / factor;
}

async function addAttachments(attachments: CatalogAttachment[], tx: MSSQL): Promise<any[]> {
  const keys = Object.keys(new CatalogAttachment);
  const result: any[] = [];
  let userId = '';
  // const getCurrentUserIdByMail = async () => {
  //   return await byCode('Catalog.User', tx.user.email, tx);
  // };
  for (const attachment of attachments) {
    if (!attachment.owner) throw new Error('Attachment owner is empty!');
    let ob;
    if (attachment.id && attachment.timestamp) ob = await createDocServerById(attachment.id, tx);
    else {
      ob = await createDocServer<CatalogAttachment>('Catalog.Attachment', undefined, tx);
      if (!userId) userId = tx.userId();
      ob.user = userId;
      ob.date = new Date;
      ob.company = (await byId(attachment.owner, tx))!.company;
    }
    Object.keys(attachment)
      .filter(e => keys.includes(e) && attachment[e])
      .forEach(e => ob[e] = attachment[e]);

    ob.user = ob.user || '63C8AE00-5985-11EA-B2B2-7DD8BECCDACF'; // EXCHANGE SERVICE

    ob = await saveDoc(ob, tx);

    const resOb = {
      ...attachment,
      timestamp: ob.timestamp,
      date: ob.date,
      user: ob.user,
      id: ob.id,
      Hash: crypto.createHash('sha1').update(attachment.Storage).digest('base64')
    };

    if (!resOb['userDescription'] && resOb.user)
      resOb['userDescription'] = (await byId(resOb.user as string, tx))!.description;

    result.push(resOb);
  }
  return result;
}

async function delAttachments(attachmentsId: Ref[], tx: MSSQL): Promise<boolean> {
  for (const id of attachmentsId) {
    const ob = await createDocServerById<CatalogAttachment>(id as string, tx);
    if (!ob || ob.deleted) continue;
    ob.Storage = '';
    ob.deleted = true;
    await upsertDocument(ob, tx);
  }
  return true;
}

async function getAttachmentsByOwner(ownerId: Ref, withDeleted: boolean, tx: MSSQL): Promise<CatalogAttachment[]> {
  const query = `
  SELECT
    attach.*,
    stor.Storage
FROM
    (
        SELECT
            a.id,
            a.description,
            a.timestamp,
            a.owner,
            a.date,
            a.AttachmentType,
            a.Tags,
            a.MIMEType,
            a.FileSize,
            a.FileName,
            us.description userDescription,
            at.description AttachmentTypeDescription,
            at.IconURL,
            at.StorageType,
            at.LoadDataOnInit
        FROM
            [Catalog.Attachment.v] a WITH (NOEXPAND)
            LEFT JOIN [Catalog.Attachment.Type.v] at WITH (NOEXPAND) ON a.AttachmentType = at.id
            LEFT JOIN [Catalog.User.v] us WITH (NOEXPAND) ON a.[user] = us.id
        WHERE
            a.owner = @p1
            ${withDeleted ? '' : 'and a.deleted = 0'}
    ) attach
    LEFT JOIN dbo.[Documents] doc
    CROSS APPLY OPENJSON (doc.doc, N'$') WITH (Storage NVARCHAR(MAX) N'$.Storage') stor ON attach.id = doc.id
    and attach.LoadDataOnInit = 1
ORDER BY
    attach.timestamp DESC`;
  return await tx.manyOrNone(query, [ownerId]);
}

async function getAttachmentStorageById(attachmentId: Ref, tx: MSSQL): Promise<string> {
  const query = `
  SELECT stor.Storage FROM dbo.[Documents] doc
    CROSS APPLY OPENJSON (doc.doc, N'$') WITH (Storage NVARCHAR(MAX) N'$.Storage') stor WHERE doc.id = @p1`;
  const res = await tx.oneOrNone<{ Storage: string }>(query, [attachmentId]);
  return res ? res.Storage : '';
}

async function getAttachmentsSettingsByOwner(ownerId: Ref, tx: MSSQL): Promise<IAttachmentsSettings[]> {
  const owner = await byId(ownerId as string, tx);
  if (!owner) return [];
  let query = `SELECT d.id AttachmentType,
      d.description AttachmentTypeDescription,
      JSON_VALUE(d.doc, N'$.StorageType')  StorageType,
      JSON_VALUE(d.doc, N'$.FileFilter')  FileFilter,
      JSON_VALUE(d.doc, N'$.MaxFileSize')  MaxFileSize,
      JSON_VALUE(d.doc, N'$.IconURL')  IconURL,
      JSON_VALUE(d.doc, N'$.Tags')  Tags
  FROM [dbo].[Documents] d

  where d.type = 'Catalog.Attachment.Type'
      and d.deleted = 0
      and JSON_VALUE(d.doc, N'$.AllDocuments') = 'true'
  UNION
  SELECT d.id AttachmentType,
      d.description AttachmentTypeDescription,
      JSON_VALUE(d.doc, N'$.StorageType') StorageType,
      JSON_VALUE(d.doc, N'$.FileFilter') FileFilter,
      JSON_VALUE(d.doc, N'$.MaxFileSize') MaxFileSize,
      JSON_VALUE(d.doc, N'$.IconURL')  IconURL,
      JSON_VALUE(d.doc, N'$.Tags')  Tags
  FROM [dbo].[Documents] d
  CROSS APPLY OPENJSON (d.doc, N'$.Owners')
  WITH (
      [OwnerType] VARCHAR(MAX)
  ) AS owners
  where d.type = 'Catalog.Attachment.Type'
      and d.deleted = 0
      and owners.[OwnerType] = @p1
  ORDER by AttachmentTypeDescription`;
  if (Type.isCatalog(owner.type)) query = query.replace('.AllDocuments', '.AllCatalogs');
  const qRes = await tx.manyOrNone(query, [owner.type]) as any[];
  if (!qRes.length) return [];
  return [...new Set(qRes.map(e => {
    return { ...e, Tags: [...new Set(e.Tags.split(';').map(tag => tag.trim()).filter(tag => tag))] };
  }))];

}


export async function movementsByDoc<T extends RegisterAccumulation>(type: RegisterAccumulationTypes, doc: Ref, tx: MSSQL) {
  const queryText = `
  SELECT * FROM [Accumulation] WHERE type = @p1 AND document = @p2`;
  return await tx.manyOrNone<T>(queryText, [type, doc]);
}

async function bankStatementUnloadById(docsID: string[], tx: MSSQL): Promise<string> {
  return await BankStatementUnloader.getBankStatementAsString(docsID, tx);
}

async function getUserRoles(user: CatalogUser): Promise<string[]> {
  return (await getUserPermissions(user)).Roles;
}

async function isRoleAvailable(role: string, tx: MSSQL): Promise<boolean> {
  return tx && tx.user && tx.user.roles && tx.user.roles.length && tx.user.roles.includes(role);
}

async function closeMonth(company: Ref, date: Date, tx: MSSQL): Promise<void> {
  // const sdb = new MSSQL(TASKS_POOL, { email: '', isAdmin: true, env: {}, description: '', roles: []} );
  await tx.none(`
    EXEC [Invetory.Close.Month-MEM] @company = '${company}', @date = '${date.toJSON()}'`);
}

async function closeMonthErrors(company: Ref, date: Date, tx: MSSQL) {
  const result = await tx.manyOrNone<{ Storehouse: Ref, SKU: Ref, Cost: number }>(`
    SELECT q.*, Storehouse.Department Department FROM (
      SELECT Storehouse, SKU, SUM([Cost]) [Cost]
      FROM [dbo].[Register.Accumulation.Inventory] r
      WHERE date < DATEADD(DAY, 1, EOMONTH(@p1)) AND company = @p2
      GROUP BY Storehouse, SKU
      HAVING ISNULL(SUM([Qty]), 0) = 0 AND SUM([Cost]) <> 0) q
    LEFT JOIN [Catalog.Storehouse.v] Storehouse ${SQLGenegatorMetadata.noExpander('Catalog.Storehouse')}
    ON Storehouse.id = q.Storehouse`, [date, company]);
  return result;
}


async function getObjectPropertyById(id: Ref, propPath: string, tx: MSSQL) {

  // https://github.com/tediousjs/tedious/blob/820dd2390dd6d119463822df3d7612c623db21ea/src/data-types/uniqueidentifier.ts
  const isGUID2 = (value: string): boolean => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);

  const isGUID = (val: string): boolean => {
    return val.length === 36 && val.split('-').length === 5 && val.split('-')[0].length === 8;
  };

  let curVal, result: any = null;
  let ob = await lib.doc.byId(id, tx);
  if (!ob) return result;
  const path = propPath.split('.');
  let i = 0;
  for (i = 0; i < path.length; i++) {
    if (!ob) break;
    curVal = ob[path[i]];
    if (curVal && isGUID(curVal.toString())) ob = await byId(curVal, tx);
    else ob = null;
  }
  if (i === path.length) result = curVal;
  if (result && isGUID(result.toString())) result = await byId(result, tx);
  return result;

}

function exchangeDB() {
  return new MSSQL(EXCHANGE_POOL);
}

function newEvent(init: Partial<Event>) {
  return new Event(init);
}

function logIfDev(...args: any[]): void {
  if (!Global.isProd) console.log(args);
}

