import { DocumentOptions, Type } from "jetti-middle";
import { MSSQL } from "../../mssql";
import { DocumentBaseServer } from "../documents.factory.server";
import { compareWithMirrorContourHandler } from "./common.compareWithMirror";
import { copyToMirrorContourHandler } from "./common.copyToMirror";
import { Contour } from "../contour";

export interface CommandResult {
  status: "warn" | "success" | "error";
  message: string;
  data?: any;
}

interface CommonCommand {
  method: string;
  label: string;
  icon: string;
  order: number;
  handler: (doc: DocumentBaseServer, tx: MSSQL, args?: any) => Promise<CommandResult>;
  predicate: (doc: DocumentBaseServer, tx: MSSQL) => Promise<boolean>;
  isCommon?: boolean;
}

const CommonCommands: CommonCommand[] = [
  {
    method: "CompareWithMirrorContour",
    label: `Compare with mirror contour`,
    isCommon: true,
    icon: "diff",
    order: 101,
    handler: compareWithMirrorContourHandler,
    predicate: async (doc, tx) => Type.isRefType(doc.type) && (tx.isAdmin || await Contour.isCommonDataContourCompany(doc.company as string | undefined, tx) || await Contour.isMirrorContourCompany(doc.company as string | undefined, tx)),
  },
  {
    method: "CopyToMirrorContour",
    label: `[ADMIN] COPY to mirror contour`,
    isCommon: true,
    icon: "copy",
    order: 100,
    handler: copyToMirrorContourHandler,
    predicate: async (doc, tx) => Type.isRefType(doc.type) &&
      Contour.isCommonDataEditor(tx)
      || (Contour.isMirrorContourEditor(tx) && await Contour.isMirrorContourCompany(doc.company as string | undefined, tx)),
  }
];

export async function putCommonCommands(doc: DocumentBaseServer, tx: MSSQL) {
  const prop = doc.Prop() as DocumentOptions;
  prop.commands = prop.commands || [];

  for (const command of CommonCommands) {
    const alreadyExists = prop.commands.some((e) => e.method === command.method);

    if (alreadyExists) continue;

    const available = await command.predicate(doc, tx);

    if (available) {
      prop.commands.push(command);
    }
  }
}

export async function handleCommonCommand(
  doc: DocumentBaseServer,
  method: string,
  args: any,
  tx: MSSQL,
): Promise<CommandResult | undefined> {
  const command = CommonCommands.find((c) => c.method === method);

  if (!command) return;

  try {
    return await command.handler(doc, tx, args);
  } catch (error) {
    throw new Error(`Error on executing command "${command.label}": ${error instanceof Error ? error.message : error}`);
  }
}


