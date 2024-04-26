import { AllTypes } from './../../models/documents.types';
import { lib } from '../../std.lib';
import { MSSQL } from '../../mssql';
import { DocumentBaseServer, createDocumentServer } from '../../models/documents.factory.server';
import { INoSqlDocument, Ref, Type } from 'jetti-middle';

export interface IUpdateInsertDocumentOptions { withExchangeInfo: boolean; }

export async function postDocument(serverDoc: DocumentBaseServer, tx: MSSQL) {

  throw `Deprecated method "postDocument"`

  // const beforePost: (tx: MSSQL) => Promise<DocumentBaseServer> = serverDoc['serverModule']['beforePost'];
  // if (typeof beforePost === 'function') await beforePost(tx);
  // if (serverDoc.beforePost) await serverDoc.beforePost(tx);

  // if (serverDoc.isDoc && serverDoc.onPost) {
  //   const Registers = await serverDoc.onPost(tx);
  //   await InsertRegistersIntoDB(serverDoc, Registers, tx);
  // }

  // const afterPost: (tx: MSSQL) => Promise<DocumentBaseServer> = serverDoc['serverModule']['afterPost'];
  // if (typeof afterPost === 'function') await afterPost(tx);
  // if (serverDoc.afterPost) await serverDoc.afterPost(tx);

}

export async function unpostDocument(serverDoc: DocumentBaseServer, tx: MSSQL) {
  if (!serverDoc.isDoc) return;
  throw `Deprecated method "unpostDocument"`
  // const onUnPost: (tx: MSSQL) => Promise<DocumentBaseServer> = serverDoc['serverModule']['onUnPost'];
  // if (typeof onUnPost === 'function') await onUnPost(tx);
  // if (serverDoc.onUnPost) await serverDoc.onUnPost(tx);

  // await DocumentsMovements.beforeDelete(serverDoc.id, tx);

  // await tx.none(`
  //   DELETE FROM "Register.Info" WHERE document = @p1;
  //   DELETE FROM "Register.Account" WHERE document = @p1;
  //   DELETE FROM "Accumulation" WHERE document = @p1;
  // `, [serverDoc.id, serverDoc.date]);
}

export async function insertDocument(serverDoc: DocumentBaseServer, tx: MSSQL, opts?: IUpdateInsertDocumentOptions) {

  await beforeSaveDocument(serverDoc, tx);

  const noSqlDocument = lib.doc.noSqlDocument(serverDoc);
  const jsonDoc = JSON.stringify(noSqlDocument);
  const withExchangeInfo = (opts && opts.withExchangeInfo) || serverDoc['ExchangeBase'];

  const response = <INoSqlDocument>await tx.oneOrNone<INoSqlDocument>(`
    INSERT INTO Documents(
      [id], [type], [date], [code], [description], [posted], [deleted],
      [parent], [isfolder], [company], [user], [info], [doc] ${withExchangeInfo ? ', [ExchangeCode], [ExchangeBase]' : ''})
    SELECT
      [id], [type], [date], [code], [description], [posted], [deleted],
      [parent], [isfolder], [company], [user], [info], [doc]
      ${withExchangeInfo ? ', [ExchangeCode], [ExchangeBase]' : ''}
    FROM OPENJSON(@p1) WITH (
      [id] UNIQUEIDENTIFIER,
      [date] DATETIME,
      [type] NVARCHAR(100),
      [code] NVARCHAR(36),
      [description] NVARCHAR(150),
      [posted] BIT,
      [deleted] BIT,
      [parent] UNIQUEIDENTIFIER,
      [isfolder] BIT,
      [company] UNIQUEIDENTIFIER,
      [user] UNIQUEIDENTIFIER,
      [info] NVARCHAR(max),
      [doc] NVARCHAR(max) N'$.doc' AS JSON
      ${withExchangeInfo ? `
      ,[ExchangeCode] NVARCHAR(50),
      [ExchangeBase] NVARCHAR(50)` : ''}
    );
    SELECT * FROM Documents WHERE id = @p2`, [jsonDoc, serverDoc.id]);

  await afterSaveDocument(serverDoc, tx);
  serverDoc.map(response);
  return serverDoc;

}

export async function updateDocument(serverDoc: DocumentBaseServer, tx: MSSQL, opts?: IUpdateInsertDocumentOptions) {

  await beforeSaveDocument(serverDoc, tx);

  const noSqlDocument = lib.doc.noSqlDocument(serverDoc);
  const jsonDoc = JSON.stringify(noSqlDocument);
  const withExchangeInfo = (opts && opts.withExchangeInfo) || serverDoc['ExchangeBase'];

  const response = <INoSqlDocument>await tx.oneOrNone<INoSqlDocument>(`
    UPDATE Documents
      SET
        type = i.type, parent = i.parent,
        date = i.date, code = i.code, description = i.description,
        posted = i.posted, deleted = i.deleted, isfolder = i.isfolder,
        "user" = i."user", company = i.company, info = i.info, timestamp = GETDATE(),
        ${withExchangeInfo ? 'ExchangeCode = i.ExchangeCode,  ExchangeBase = i.ExchangeBase,' : ''} doc = i.doc
      FROM (
        SELECT *
        FROM OPENJSON(@p1) WITH (
          [id] UNIQUEIDENTIFIER,
          [date] DATETIME,
          [type] NVARCHAR(100),
          [code] NVARCHAR(36),
          [description] NVARCHAR(150),
          [posted] BIT,
          [deleted] BIT,
          [isfolder] BIT,
          [company] UNIQUEIDENTIFIER,
          [user] UNIQUEIDENTIFIER,
          [info] NVARCHAR(max),
          [parent] UNIQUEIDENTIFIER,
          ${withExchangeInfo ? `
          [ExchangeCode] NVARCHAR(50),
          [ExchangeBase] NVARCHAR(50),` : ''}
          [doc] NVARCHAR(max) N'$.doc' AS JSON
        )
      ) i
    WHERE Documents.id = i.id;
    SELECT * FROM Documents WHERE id = @p2`, [jsonDoc, serverDoc.id]);

  await afterSaveDocument(serverDoc, tx);

  serverDoc.map(response);
  return serverDoc;
}

export async function upsertDocument(serverDoc: DocumentBaseServer, tx: MSSQL, opts?: IUpdateInsertDocumentOptions) {

  await beforeSaveDocument(serverDoc, tx);

  const noSqlDocument = lib.doc.noSqlDocument(serverDoc);
  const jsonDoc = JSON.stringify(noSqlDocument);
  const withExchangeInfo = (opts && opts.withExchangeInfo) || serverDoc['ExchangeBase'];

  const response = <INoSqlDocument>await tx.oneOrNone<INoSqlDocument>(`
  DECLARE @DocId UNIQUEIDENTIFIER;

  SELECT @DocId = id FROM Documents WHERE id = @p2;

  IF @DocId IS NULL
  BEGIN
  INSERT INTO Documents(
        [id], [type], [date], [code], [description], [posted], [deleted],
        [parent], [isfolder], [company], [user], [info], [doc] ${withExchangeInfo ? ', [ExchangeCode], [ExchangeBase]' : ''})
      SELECT
        [id], [type], [date], [code], [description], [posted], [deleted],
        [parent], [isfolder], [company], [user], [info], [doc]
        ${withExchangeInfo ? ', [ExchangeCode], [ExchangeBase]' : ''}
      FROM OPENJSON(@p1) WITH (
        [id] UNIQUEIDENTIFIER,
        [date] DATETIME,
        [type] NVARCHAR(100),
        [code] NVARCHAR(36),
        [description] NVARCHAR(150),
        [posted] BIT,
        [deleted] BIT,
        [parent] UNIQUEIDENTIFIER,
        [isfolder] BIT,
        [company] UNIQUEIDENTIFIER,
        [user] UNIQUEIDENTIFIER,
        [info] NVARCHAR(max),
        [doc] NVARCHAR(max) N'$.doc' AS JSON
        ${withExchangeInfo ? `
        ,[ExchangeCode] NVARCHAR(50)
        ,[ExchangeBase] NVARCHAR(50)` : ''}
      );
  END

  IF NOT @DocId IS NULL
  BEGIN
    UPDATE Documents
        SET
          type = i.type, parent = i.parent,
          date = i.date, code = i.code, description = i.description,
          posted = i.posted, deleted = i.deleted, isfolder = i.isfolder,
          "user" = i."user", company = i.company, info = i.info, timestamp = GETDATE(), doc = i.doc
          ${withExchangeInfo ? ',ExchangeCode = i.ExchangeCode,  ExchangeBase = i.ExchangeBase' : ''}
        FROM (
          SELECT *
          FROM OPENJSON(@p1) WITH (
            [id] UNIQUEIDENTIFIER,
            [date] DATETIME,
            [type] NVARCHAR(100),
            [code] NVARCHAR(36),
            [description] NVARCHAR(150),
            [posted] BIT,
            [deleted] BIT,
            [isfolder] BIT,
            [company] UNIQUEIDENTIFIER,
            [user] UNIQUEIDENTIFIER,
            [info] NVARCHAR(max),
            [parent] UNIQUEIDENTIFIER,
            [doc] NVARCHAR(max) N'$.doc' AS JSON
            ${withExchangeInfo ? `
            ,[ExchangeCode] NVARCHAR(50)
            ,[ExchangeBase] NVARCHAR(50)` : ''}
          )
        ) i
      WHERE Documents.id = i.id;
  END

  SELECT * FROM Documents WHERE id = @p2`, [jsonDoc, serverDoc.id]);

  await afterSaveDocument(serverDoc, tx);

  serverDoc.map(response);
  return serverDoc;
}

export async function setPostedSate(id: Ref, tx: MSSQL) {
  const doc = await tx.oneOrNone<INoSqlDocument>(`
    UPDATE Documents SET posted = 1 WHERE id = @p1 and deleted = @p2 and posted = @p3;
    SELECT * FROM Documents WHERE id = @p1`, [id, 0, 0]);
  const flatDoc = lib.doc.flatDocument(doc!);
  const serverDoc = createDocumentServer(flatDoc!.type, flatDoc!, tx);
  return serverDoc;
}

export async function adminMode(mode: boolean, tx: MSSQL) {
  await tx.adminMode(mode);
}

async function beforeSaveDocument(serverDoc: DocumentBaseServer, tx: MSSQL) {

  if (!tx.user.disableChecks) {
    await checkCommonDataValidity(serverDoc);
    await checkDocumentUnique(serverDoc, tx);
    await checkProtectedPropsModify(serverDoc, tx);
  }
  const beforeSave: (tx: MSSQL) => Promise<DocumentBaseServer> = serverDoc['serverModule']['beforeSave'];
  if (typeof beforeSave === 'function') await beforeSave(tx);
  if (serverDoc.beforeSave) await serverDoc.beforeSave(tx);
  serverDoc.timestamp = new Date();
}

async function afterSaveDocument(serverDoc: DocumentBaseServer, tx: MSSQL) {
  const afterSave: (tx: MSSQL) => Promise<DocumentBaseServer> = serverDoc['serverModule']['afterSave'];
  if (typeof afterSave === 'function') await afterSave(tx);
  if (serverDoc.afterSave) await serverDoc.afterSave(tx);
}

async function checkCommonDataValidity(serverDoc: DocumentBaseServer) {
  if (Type.isCatalog(serverDoc.type) && serverDoc.parent && serverDoc.parent === serverDoc.id)
    throw new Error(`beforeSave: "${serverDoc.description || serverDoc.id}" cannot be a parent of itself`);
}

async function checkDocumentUnique(serverDoc: DocumentBaseServer, tx: MSSQL) {

  if (!serverDoc.isCatalog) return;
  const uniqueProps = serverDoc.getPropsWithOption('isUnique', true);
  const propsKeys = Object.keys(uniqueProps).filter(key => !!serverDoc[key]);

  if (!propsKeys.length) return;

  const getExisting = async (propName: string, propValue: any): Promise<{ id: string, description: string } | null> =>
    await tx.oneOrNone(`
    SELECT TOP 1 description, id
    FROM [dbo].[${serverDoc.type}.v]
    WHERE ${propName} = @p1
    and id <> @p2`,
      [propValue, serverDoc.id]
    );

  const getValueDescription = async (type: AllTypes, value: any) => {
    if (!value) return `<empty>`;
    if (!Type.isRefType(type)) return value;
    return (await lib.doc.byId(value, tx))!.description;
  };

  for (const propKey of propsKeys) {
    const existing = await getExisting(propKey, serverDoc[propKey]);
    if (!existing) continue;
    const propLabel = uniqueProps[propKey].label || propKey;
    const propDesctiption = await getValueDescription(uniqueProps[propKey].type as any, serverDoc[propKey]);
    const msg = `
    Объект "${serverDoc.description}" должен быть уникален по реквизиту "${propLabel}".
    Уже существует объект "${existing.description}" (id: ${existing.id}) с значением "${propLabel}"="${propDesctiption}".`;
    throw new Error(msg);
  }
}

async function checkProtectedPropsModify(serverDoc: DocumentBaseServer, tx: MSSQL) {

  if (!serverDoc.isCatalog || !serverDoc.timestamp || tx.isRoleAvailableModifyProtected()) return;
  const protectedProps = serverDoc.getPropsWithOption('isProtected', true);

  if (!Object.keys(protectedProps).length) return;

  const savedDoc = await lib.doc.byId(serverDoc.id, tx);
  if (!savedDoc) return;

  const modProps = Object.keys(protectedProps)
    .filter(key => serverDoc[key] !== savedDoc[key])
    .map(key => key);

  for (const modProp of modProps) {
    if (savedDoc[modProp] && await lib.doc.isDocumentUsedInAccumulationWithPropValueById(serverDoc.id, tx))
      throw new Error(`"${serverDoc.description}" can't be changed by protected field "${protectedProps[modProp].label || modProp}":\n used in accumulation/info movements"`);
  }

}
