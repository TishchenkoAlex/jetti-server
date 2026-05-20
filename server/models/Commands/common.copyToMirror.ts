import { Type } from "jetti-middle";
import { MSSQL } from "../../mssql";
import { lib } from "../../std.lib";
import { DocumentBaseServer } from "../documents.factory.server";
import type { CommonCommandResult } from "./common";

type CopyResult =
  | { status: "error"; id: string; reason: string }
  | { status: "inserted"; id: string }
  | { status: "updated"; id: string }
  | { status: "skipped"; id: string; reason: "target_is_newer_or_equal" | "source_not_found" };

export async function copyToMirrorContourHandler(
  doc: DocumentBaseServer,
  args: any,
  tx: MSSQL,
): Promise<CommonCommandResult> {
  if (!doc.id) throw new Error("Document must be saved before copying");
  const result = await copyToMirrorContour(doc.id, tx);
  return mapCopyResult(result);
}

function mapCopyResult(result: CopyResult): CommonCommandResult {
  let status: CommonCommandResult["status"] = result.status === "skipped" ? "warn" : "success";
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
  const sourceDoc = await lib.doc.byId(id, sourceDb);

  if (!sourceDoc) {
    return { status: "skipped", id, reason: "source_not_found" };
  }

  const noSqlDocument = lib.doc.noSqlDocument(sourceDoc);

  if (!noSqlDocument) {
    return { status: "skipped", id, reason: "source_not_found" };
  }

  const { ExchangeBase, ExchangeCode, operation, version, ...doc } = noSqlDocument.doc as any;

  noSqlDocument.doc = doc; // убираем из JSON полей, которые не нужны в целевой БД и могут вызвать проблемы при сериализации/десериализации
  const jsonDoc = JSON.stringify(noSqlDocument);
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
    IF @DocId IS NOT NULL
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
    noSqlDocument.id,
    noSqlDocument.timestamp,
    noSqlDocument.type
  ]);

  if (!resp) {
    return { status: "skipped", id, reason: "source_not_found" };
  }

  const needToPost = (resp.status === "inserted" || resp.status === "updated") && sourceDoc.posted && Type.isDocument(sourceDoc.type);

  if (needToPost) {
    // после копирования в контур-отражение, если документ был проведен, нужно попытаться провести его там
    const errorMsg = await postInMirrorContour(id, targetDb);
    if (errorMsg) {
      return { status: "error", id, reason: `post failed in mirror contour ${errorMsg}, but document was ${resp.status}!` };
    }
  }

  if (resp.status === "inserted") {
    return { status: "inserted", id };
  }

  if (resp.status === "updated") {
    return { status: "updated", id };
  }

  return { status: "skipped", id, reason: "target_is_newer_or_equal"};
}

async function postInMirrorContour(id: string, targetDb: MSSQL): Promise<string | undefined> {
  try {
    await lib.doc.postById(id, targetDb);
  } catch (error: any) {
    return error.message || 'unknown error';
  }
}
