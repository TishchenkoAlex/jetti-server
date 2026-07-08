export interface CashRequestBusinessProcessObject {
  objectType: 'Document.CashRequest';
  objectId: string;
}

export class CashRequestBusinessProcessAdapter {
  toProcessObject(cashRequestId: string): CashRequestBusinessProcessObject {
    throw new Error('CashRequestBusinessProcessAdapter.toProcessObject is not implemented');
  }
}

