import { MSSQL } from '../../mssql';
import { lib } from '../../std.lib';
import { upsertDocument } from '../../routes/utils/post';
import { DocumentBaseServer } from '../../models/documents.factory.server';
import { DocumentCashRequest } from '../../models/Documents/Document.CashRequest';
import {
  BusinessProcessObjectAdapter,
  BusinessProcessObjectStatusChange,
} from '../types/object-integration.types';
import {
  BusinessProcessInstance,
  BusinessProcessTask,
} from '../types/business-process.types';

type CashRequestStatus =
  | 'PREPARED'
  | 'AWAITING'
  | 'MODIFY'
  | 'APPROVED'
  | 'REJECTED'
  | 'CLOSED';

/**
 * TODO Stage 7:
 * Enforce that process-controlled statuses are changed only by BusinessProcessTask actions.
 */
export class CashRequestProcessAdapter implements BusinessProcessObjectAdapter {
  objectType = 'Document.CashRequest';

  async buildStartContext(args: {
    objectId: string;
    user?: string | null;
    tx: MSSQL;
  }): Promise<{
    objectType: string;
    objectId: string;
    company?: string | null;
    context: Record<string, unknown>;
  }> {
    const doc = await this.requireCashRequest(args.objectId, args.tx);
    return {
      objectType: this.objectType,
      objectId: args.objectId,
      company: doc.company || null,
      context: {
        id: doc.id,
        type: doc.type,
        code: doc.code,
        date: doc.date,
        company: doc.company || null,
        author: doc.user || null,
        Amount: doc.Amount,
        Status: doc.Status,
        Operation: doc.Operation,
        CashKind: doc.CashKind,
        Department: doc.Department || null,
        CashRecipient: doc.CashRecipient || null,
        CashFlow: doc.CashFlow || null,
        PayDay: doc.PayDay || null,
        info: doc.info || '',
      },
    };
  }

  async onProcessStarted(args: {
    instance: BusinessProcessInstance;
    tasks: BusinessProcessTask[];
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null> {
    const doc = await this.requireCashRequest(args.instance.objectId, args.tx);
    const fromStatus = this.status(doc);

    if (fromStatus === 'AWAITING') return null;
    if (fromStatus === 'APPROVED' || fromStatus === 'CLOSED') {
      throw new Error(`CashRequest ${doc.id} cannot be moved to AWAITING from status ${fromStatus}`);
    }
    if (!['PREPARED', 'MODIFY', 'REJECTED'].includes(fromStatus)) {
      throw new Error(`CashRequest ${doc.id} cannot be moved to AWAITING from status ${fromStatus}`);
    }

    return this.setStatus(doc, 'AWAITING', args.tx, fromStatus);
  }

  async onProcessCompleted(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null> {
    const doc = await this.requireCashRequest(args.instance.objectId, args.tx);
    const fromStatus = this.status(doc);

    if (fromStatus === 'APPROVED') return null;
    if (!['AWAITING', 'MODIFY'].includes(fromStatus)) {
      throw new Error(`CashRequest ${doc.id} cannot be moved to APPROVED from status ${fromStatus}`);
    }

    return this.setStatus(doc, 'APPROVED', args.tx, fromStatus);
  }

  async onProcessRejected(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    rejectPolicy?: string | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null> {
    const doc = await this.requireCashRequest(args.instance.objectId, args.tx);
    const fromStatus = this.status(doc);
    const toStatus: CashRequestStatus = args.rejectPolicy === 'RETURN_TO_AUTHOR' ? 'MODIFY' : 'REJECTED';

    if (fromStatus === toStatus) return null;
    if (!['AWAITING', 'MODIFY', 'REJECTED'].includes(fromStatus)) {
      throw new Error(`CashRequest ${doc.id} cannot be moved to ${toStatus} from status ${fromStatus}`);
    }

    return this.setStatus(doc, toStatus, args.tx, fromStatus);
  }

  async onProcessCancelled(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null> {
    const doc = await this.requireCashRequest(args.instance.objectId, args.tx);
    const fromStatus = this.status(doc);

    if (fromStatus === 'PREPARED') return null;
    if (!['AWAITING', 'MODIFY', 'REJECTED'].includes(fromStatus)) {
      throw new Error(`CashRequest ${doc.id} cannot be moved to PREPARED from status ${fromStatus}`);
    }

    return this.setStatus(doc, 'PREPARED', args.tx, fromStatus);
  }

  private async requireCashRequest(objectId: string, tx: MSSQL): Promise<DocumentCashRequest> {
    const doc = await lib.doc.byIdT<DocumentCashRequest>(objectId, tx);
    if (!doc) throw new Error(`CashRequest ${objectId} not found`);
    return doc;
  }

  private status(doc: DocumentCashRequest): CashRequestStatus {
    return doc.Status as CashRequestStatus;
  }

  private async setStatus(
    doc: DocumentCashRequest,
    toStatus: CashRequestStatus,
    tx: MSSQL,
    fromStatus: CashRequestStatus,
  ): Promise<BusinessProcessObjectStatusChange> {
    doc.Status = toStatus;
    await upsertDocument(doc as unknown as DocumentBaseServer, tx);
    return {
      objectType: this.objectType,
      objectId: doc.id,
      fromStatus,
      toStatus,
    };
  }
}
