import { Type } from "jetti-middle";
import { MSSQL } from "../../mssql";
import { lib } from "../../std.lib";
import { DocumentBaseServer } from "../documents.factory.server";
import type { CommandResult } from "./common";

type CopyResult =
  | { status: "error"; id: string; reason: string }
  | { status: "inserted"; id: string }
  | { status: "updated"; id: string }
  | { status: "skipped"; id: string; reason: "target_is_newer_or_equal" | "source_not_found" };

type JsonObject = { [key: string]: any };
type CopyDocumentRow = JsonObject & {
  id: string;
  type: string;
  posted: boolean;
  timestamp: Date | null;
  doc: JsonObject | string | null;
};
const EXCHANGE_PROPERTIES = ["ExchangeBase", "ExchangeCode"] as const;
type ExchangeProperty = typeof EXCHANGE_PROPERTIES[number];

export async function copyToMirrorContourHandler(
  doc: DocumentBaseServer,
  tx: MSSQL,
): Promise<CommandResult> {
  if (!doc.id) throw new Error("Document must be saved before copying");
  const result = await copyToMirrorContour(doc.id, tx);
  return mapCopyResult(result);
}

function mapCopyResult(result: CopyResult): CommandResult {
  let status: CommandResult["status"] = result.status === "skipped" ? "warn" : "success";
  let message = "";

  if (result.status === "skipped") {
    if (result.reason === "source_not_found") {
      message = "Source document not found.";
      status = "error";
    }
    if (result.reason === "target_is_newer_or_equal")
      message = "Target document is newer or has the same timestamp.";
  } else if (result.status === "inserted") {
    message = "Document inserted into mirror contour.";
  } else if (result.status === "updated") {
    message = "Document updated in mirror contour.";
  }

  return { status, message };
}

async function copyToMirrorContour(id: string, sourceDb: MSSQL): Promise<CopyResult> {
  const sourceDoc = await readDocumentForCopy(id, sourceDb);

  if (!sourceDoc) {
    return { status: "skipped", id, reason: "source_not_found" };
  }

  const docForCopy = docWithoutExcludedProperties(sourceDoc.doc);
  const documentForCopy = {
    ...sourceDoc,
    doc: docForCopy,
  };
  const needRestoreAfterMovements = needsRestoreExchangeLayout(sourceDoc, docForCopy);
  const jsonDoc = JSON.stringify(documentForCopy);
  const targetDb = lib.util.mirrorContourPoolTx();

  const query = `
    DECLARE @DocId UNIQUEIDENTIFIER;
    DECLARE @TimestampInSource DATETIME;
    DECLARE @TimestampInTarget DATETIME;

    SET @TimestampInSource = @p3;

    SELECT
      @DocId = id,
      @TimestampInTarget = [timestamp]
    FROM Documents
    WHERE id = @p2;

    -- target уже новее или равен source -> пропускаем
    IF @p5 = 0
       AND @DocId IS NOT NULL
       AND @TimestampInTarget IS NOT NULL
       AND @TimestampInSource IS NOT NULL
       AND @TimestampInTarget >= @TimestampInSource
    BEGIN
      SELECT
        CAST('skipped' AS NVARCHAR(32)) AS [status],
        CAST('target_is_newer_or_equal' AS NVARCHAR(64)) AS [reason],
        @p2 AS [id];

      RETURN;
    END

    IF @DocId IS NULL
    BEGIN
      INSERT INTO Documents (
        [id], [type], [date], [code], [description], [posted], [deleted],
        [parent], [isfolder], [company], [user], [info], [doc], [ExchangeCode], [ExchangeBase]
      )
      SELECT
        [id], [type], [date], [code], [description], [posted], [deleted],
        [parent], [isfolder], [company], [user], [info], [doc], [ExchangeCode], [ExchangeBase]
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
        [info] NVARCHAR(MAX),
        [doc] NVARCHAR(MAX) N'$.doc' AS JSON,
        [ExchangeCode] NVARCHAR(50),
        [ExchangeBase] NVARCHAR(50)
      )
      WHERE [type] = @p4;

      SELECT
        CAST('inserted' AS NVARCHAR(32)) AS [status],
        CAST(NULL AS NVARCHAR(64)) AS [reason],
        @p2 AS [id];

      RETURN;
    END

    UPDATE Documents
    SET
      parent = i.parent,
      [date] = i.[date],
      code = i.code,
      description = i.description,
      posted = i.posted,
      deleted = i.deleted,
      isfolder = i.isfolder,
      [user] = i.[user],
      company = i.company,
      info = i.info,
      [timestamp] = GETDATE(),
      doc = i.doc,
      ExchangeCode = i.ExchangeCode,
      ExchangeBase = i.ExchangeBase
    FROM Documents
    INNER JOIN (
      SELECT *
      FROM OPENJSON(@p1) WITH (
        [date] DATETIME,
        [code] NVARCHAR(36),
        [description] NVARCHAR(150),
        [posted] BIT,
        [deleted] BIT,
        [isfolder] BIT,
        [company] UNIQUEIDENTIFIER,
        [user] UNIQUEIDENTIFIER,
        [info] NVARCHAR(MAX),
        [parent] UNIQUEIDENTIFIER,
        [doc] NVARCHAR(MAX) N'$.doc' AS JSON,
        [ExchangeCode] NVARCHAR(50),
        [ExchangeBase] NVARCHAR(50)
      )
    ) i ON 1 = 1
    WHERE Documents.[type] = @p4
      AND Documents.id = @DocId;

    SELECT
      CAST('updated' AS NVARCHAR(32)) AS [status],
      CAST(NULL AS NVARCHAR(64)) AS [reason],
      @p2 AS [id];
  `;

  const resp = await targetDb.oneOrNone<{
    status: "inserted" | "updated" | "skipped";
    reason: "target_is_newer_or_equal" | null;
    id: string;
  }>(query, [
    jsonDoc,
    sourceDoc.id,
    sourceDoc.timestamp,
    sourceDoc.type,
    false,
  ]);

  if (!resp) {
    return { status: "skipped", id, reason: "source_not_found" };
  }

  const needToPost = (resp.status === "inserted" || resp.status === "updated") && Type.isDocument(sourceDoc.type);

  if (needToPost) {
    const errorMsg = await postInMirrorContour(id, targetDb, sourceDoc.posted);
    if (errorMsg) {
      return { status: "error", id, reason: `post failed in mirror contour ${errorMsg}, but document was ${resp.status}!` };
    }

    if (needRestoreAfterMovements) {
      // Unposting saves the target document through the regular serialization
      // pipeline. Force the same copy if exchange fields changed location.
      await targetDb.oneOrNone(query, [
        jsonDoc,
        sourceDoc.id,
        sourceDoc.timestamp,
        sourceDoc.type,
        true,
      ]);
    }
  }

  if (resp.status === "inserted") {
    return { status: "inserted", id };
  }

  if (resp.status === "updated") {
    return { status: "updated", id };
  }

  return { status: "skipped", id, reason: "target_is_newer_or_equal" };
}

async function readDocumentForCopy(id: string, tx: MSSQL): Promise<CopyDocumentRow | null> {
  return await tx.oneOrNone<CopyDocumentRow>(
    `
      SELECT
        [id],
        [type],
        [date],
        [code],
        [description],
        [posted],
        [deleted],
        [parent],
        [isfolder],
        [company],
        [user],
        [info],
        [doc],
        [timestamp],
        [ExchangeCode],
        [ExchangeBase]
      FROM Documents
      WHERE id = @p1
    `,
    [id],
  );
}

function docWithoutExcludedProperties(doc: JsonObject | string | null): any {
  const parsedDoc = typeof doc === "string" ? JSON.parse(doc) : doc;

  if (!isPlainObject(parsedDoc)) return parsedDoc;

  const { operation, version, ...result } = parsedDoc;
  return result;
}

function isPlainObject(value: any): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value) && !(value instanceof Date);
}

function needsRestoreExchangeLayout(source: CopyDocumentRow, doc: any): boolean {
  // postById does not save Documents; only unPostById passes through upsertDocument.
  if (source.posted || !isPlainObject(doc)) return false;

  const effectiveValues = {
    ExchangeBase: effectiveExchangeValue(source, doc, "ExchangeBase"),
    ExchangeCode: effectiveExchangeValue(source, doc, "ExchangeCode"),
  };

  // Mirrors the withExchangeInfo condition used by upsertDocument during unposting.
  const headersWillBeUpdated = !!effectiveValues.ExchangeBase;

  return EXCHANGE_PROPERTIES.some((property) => {
    const effectiveValue = effectiveValues[property];

    // Movement handlers cannot populate a truthy exchange value.
    if (!effectiveValue) return false;

    const headerValueAfterSave = headersWillBeUpdated
      ? effectiveValue
      : source[property];

    const headerWillChange = headerValueAfterSave !== source[property];
    const docWillChange = !hasOwnProperty(doc, property) || doc[property] !== effectiveValue;

    return headerWillChange || docWillChange;
  });
}

function effectiveExchangeValue(source: CopyDocumentRow, doc: JsonObject, property: ExchangeProperty): any {
  return hasOwnProperty(doc, property) ? doc[property] : source[property];
}

function hasOwnProperty(value: JsonObject, property: string): boolean {
  return Object.prototype.hasOwnProperty.call(value, property);
}

async function postInMirrorContour(id: string, targetDb: MSSQL, posted: boolean): Promise<string | undefined> {
  try {
    targetDb.setMirrorContourOperation(true);
    if (posted) {
      await lib.doc.postById(id, targetDb);
    } else {
      await lib.doc.unPostById(id, targetDb);
    }
  } catch (error: any) {
    return error.message || 'unknown error';
  } finally {
    targetDb.setMirrorContourOperation(false);
  }
}
