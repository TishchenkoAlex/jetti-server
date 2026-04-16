import { DocumentOptions, Type } from "jetti-middle";
import { MSSQL } from "../../mssql";
import { DocumentBaseServer } from "../documents.factory.server";
import { copyToMirrorContourHandler } from "./common.copyToMirror";

const CommonCommands = [
  {
    method: "CopyToMirrorContour",
    label: `[ADMIN] Copy to mirror contour`,
    icon: "copy",
    order: 100,
    handler: copyToMirrorContourHandler,
  },
];

export function putCommonCommands(doc: DocumentBaseServer, tx: MSSQL) {
  if (!Type.isCatalog(doc.type)) return;
  if (!tx.isRoleAvailable('Common data editor')) return;
  const prop = doc.Prop() as DocumentOptions;
  prop.commands = prop.commands || [];
  CommonCommands
    .filter(c => !prop.commands!.some((e) => e.method === c.method))
    .forEach((c) => prop.commands!.push(c));
}

export async function handleCommonCommand(
  doc: DocumentBaseServer,
  method: string,
  args: any,
  tx: MSSQL,
) {
  const command = CommonCommands.find((c) => c.method === method);

  if (!command) return;

  try {
    return await command.handler(doc, args, tx);
  } catch (error) {
    throw new Error(`Error on executing command "${command.label}": ${error instanceof Error ? error.message : error}`);
  }
}


