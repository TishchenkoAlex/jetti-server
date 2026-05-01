import { DocumentOptions, Type } from "jetti-middle";
import { MSSQL } from "../../mssql";
import { DocumentBaseServer } from "../documents.factory.server";
import { compareWithMirrorContourHandler } from "./common.compareWithMirror";
import { copyToMirrorContourHandler } from "./common.copyToMirror";

export interface CommonCommandResult {
  status: "warn" | "success" | "error";
  message: string;
  data?: any;
}

interface CommonCommand {
  method: string;
  label: string;
  icon: string;
  order: number;
  handler: (doc: DocumentBaseServer, args: any, tx: MSSQL) => Promise<CommonCommandResult>;
  predicate: (doc: DocumentBaseServer, tx: MSSQL) => boolean;
}

const CommonCommands: CommonCommand[] = [
  {
    method: "CompareWithMirrorContour",
    label: `Compare with mirror contour`,
    icon: "diff",
    order: 101,
    handler: compareWithMirrorContourHandler,
    predicate: (doc, tx) => Type.isCatalog(doc.type) || Type.isDocument(doc.type) && tx.isAdmin,
  },
  {
    method: "CopyToMirrorContour",
    label: `[ADMIN] COPY to mirror contour`,
    icon: "copy",
    order: 100,
    handler: copyToMirrorContourHandler,
    predicate: (doc, tx) => Type.isCatalog(doc.type) && tx.isRoleAvailable('Common data editor'),
  }
];

export function putCommonCommands(doc: DocumentBaseServer, tx: MSSQL) {
  const prop = doc.Prop() as DocumentOptions;
  prop.commands = prop.commands || [];
  CommonCommands
    .filter(c => c.predicate(doc, tx) && !prop.commands!.some((e) => e.method === c.method))
    .forEach((c) => prop.commands!.push(c));
}

export async function handleCommonCommand(
  doc: DocumentBaseServer,
  method: string,
  args: any,
  tx: MSSQL,
): Promise<CommonCommandResult | undefined> {
  const command = CommonCommands.find((c) => c.method === method);

  if (!command) return;

  try {
    return await command.handler(doc, args, tx);
  } catch (error) {
    throw new Error(`Error on executing command "${command.label}": ${error instanceof Error ? error.message : error}`);
  }
}


