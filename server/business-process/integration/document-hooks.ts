import { MSSQL } from '../../mssql';
import { DocumentBaseServer } from '../../models/documents.factory.server';
import { lib } from '../../std.lib';
import { BusinessProcessService, BusinessProcessStartEvent } from '../services/business-process.service';
import { BusinessProcessStartResult } from '../types/business-process.types';

export async function tryStartBusinessProcessForDocument(args: {
  doc: DocumentBaseServer;
  event: Exclude<BusinessProcessStartEvent, 'MANUAL'>;
  tx: MSSQL;
  user?: string | null;
}): Promise<BusinessProcessStartResult[]> {
  if (!args.doc) return [];
  if (!args.doc.id) return [];
  if (args.doc.deleted === true) return [];
  if (typeof args.tx.isMirrorContourOperation === 'function' && args.tx.isMirrorContourOperation()) return [];

  return new BusinessProcessService(args.tx).tryStartForObjectMany({
    objectType: args.doc.type,
    objectId: args.doc.id,
    event: args.event,
    user: args.user || args.tx.email || null,
  });
}

export async function syncDocumentAfterBusinessProcess(args: {
  doc: DocumentBaseServer;
  results: BusinessProcessStartResult[];
  tx: MSSQL;
}): Promise<void> {
  if (!args.doc || !args.doc.id) return;

  const hasChange = args.results.some(result => (result.objectStatusChanges || [])
    .some(change => change.objectType === args.doc.type && change.objectId === args.doc.id));
  if (!hasChange) return;

  const actual = await lib.doc.byId(args.doc.id, args.tx);
  if (!actual) return;

  const mapper = (args.doc as unknown as { map?: (source: unknown) => void }).map;
  if (typeof mapper === 'function') {
    mapper.call(args.doc, actual);
    return;
  }

  Object.assign(args.doc, actual);
}
