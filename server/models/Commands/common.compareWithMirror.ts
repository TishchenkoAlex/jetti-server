import { MSSQL } from "../../mssql";
import { lib } from "../../std.lib";
import { DocumentBaseServer } from "../documents.factory.server";
import type { CommandResult } from "./common";

type JsonObject = { [key: string]: any };
type CompareDocumentRow = JsonObject & { doc: JsonObject | string | null };

export async function compareWithMirrorContourHandler(
  doc: DocumentBaseServer,
  tx: MSSQL,
): Promise<CommandResult> {
  if (!doc.id) return {
    status: "error",
    message: "Document must be saved before comparing",
  };

  const result = await compareWithMirrorContour(doc.id, tx);

  if (result.targetMissing) {
    return {
      status: "warn",
      message: "The object is missing in the mirror contour"
    };
  }

  return {
    status: result.differentProperties.length ? "warn" : "success",
    message: result.differentProperties.length
      ? `Different properties: ${result.differentProperties.join('\n')}`
      : "The objects are equal",
    data: result.differentProperties,
  };
}

async function compareWithMirrorContour(
  id: string,
  sourceDb: MSSQL,
): Promise<{ differentProperties: string[]; targetMissing: boolean }> {
  const sourceDoc = await readDocumentForCompare(id, sourceDb);

  if (!sourceDoc) {
    throw new Error(`Source document "${id}" is not found`);
  }

  const targetDb = lib.util.mirrorContourPoolTx();
  const targetDoc = await readDocumentForCompare(id, targetDb);

  const differentProperties = Array.from(new Set([
    ...compareDocObjects(
      normalizeDocObject(sourceDoc.doc),
      normalizeDocObject(targetDoc ? targetDoc.doc : null),
    ),
    ...compareDocObjects(
      rowWithoutDoc(sourceDoc),
      targetDoc ? rowWithoutDoc(targetDoc) : {},
    ),
  ])).sort();

  return {
    differentProperties: differentProperties.filter((property) => !['module', 'readonly', 'version'].includes(property)),
    targetMissing: !targetDoc,
  };
}

async function readDocumentForCompare(id: string, tx: MSSQL): Promise<CompareDocumentRow | null> {
  return await tx.oneOrNone<CompareDocumentRow>(
    `
      SELECT
        [type],
        [date],
        [code],
        [description],
        [posted],
        [deleted],
        [doc],
        [parent],
        [isfolder],
        [company],
        [info],
        [operation]
      FROM Documents
      WHERE id = @p1
    `,
    [id],
  );
}

function rowWithoutDoc(row: CompareDocumentRow): JsonObject {
  const { doc, ...fields } = row;
  return fields;
}

function compareDocObjects(sourceDoc: JsonObject, targetDoc: JsonObject): string[] {
  const propertyNames = new Set([
    ...Object.keys(sourceDoc),
    ...Object.keys(targetDoc),
  ]);

  return Array.from(propertyNames)
    .filter((propertyName) => !hasEqualPropertyValue(sourceDoc, targetDoc, propertyName))
    .sort();
}

function hasEqualPropertyValue(sourceDoc: JsonObject, targetDoc: JsonObject, propertyName: string): boolean {
  const sourceHasProperty = hasOwnProperty(sourceDoc, propertyName);
  const targetHasProperty = hasOwnProperty(targetDoc, propertyName);

  if (!sourceHasProperty || !targetHasProperty) {
    const existingValue = sourceHasProperty ? sourceDoc[propertyName] : targetDoc[propertyName];
    return existingValue === null;
  }

  return isEqualValue(sourceDoc[propertyName], targetDoc[propertyName]);
}

function isEqualValue(source: any, target: any): boolean {
  if (source === target) return true;
  if (source === null || target === null) return source === target;
  if (source === undefined || target === undefined) return source === target;

  if (source instanceof Date || target instanceof Date) {
    const sourceDate = toDate(source);
    const targetDate = toDate(target);
    return !!sourceDate && !!targetDate && sourceDate.getTime() === targetDate.getTime();
  }

  if (Array.isArray(source) || Array.isArray(target)) {
    if (!Array.isArray(source) || !Array.isArray(target)) return false;
    if (source.length !== target.length) return false;
    return source.every((value, index) => isEqualValue(value, target[index]));
  }

  if (typeof source === "object" || typeof target === "object") {
    if (!isPlainObject(source) || !isPlainObject(target)) return false;

    const propertyNames = new Set([
      ...Object.keys(source),
      ...Object.keys(target),
    ]);

    return Array.from(propertyNames)
      .every((propertyName) => hasEqualPropertyValue(source, target, propertyName));
  }

  return false;
}

function normalizeDocObject(doc: JsonObject | string | null | undefined): JsonObject {
  if (!doc) return {};

  if (typeof doc === "string") {
    const parsed = JSON.parse(doc);
    return isPlainObject(parsed) ? parsed : {};
  }

  return isPlainObject(doc) ? doc : {};
}

function isPlainObject(value: any): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value) && !(value instanceof Date);
}

function hasOwnProperty(value: JsonObject, propertyName: string): boolean {
  return Object.prototype.hasOwnProperty.call(value, propertyName);
}

function toDate(value: any): Date | null {
  if (value instanceof Date) return value;
  if (typeof value !== "string") return null;

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}
