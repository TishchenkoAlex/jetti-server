import { CatalogPersonContractServer } from './Catalogs/Catalog.Person.Contract.server';
import { CatalogContractServer } from './Catalogs/Catalog.Contract.server';
import { CatalogEmployeeServer } from './Catalogs/Catalog.Employee.server';
import { CatalogStaffingTableServer } from './Catalogs/Catalog.StaffingTable.server';
import { lib } from '../std.lib';
import { createDocument, RegisteredDocumentType } from './../models/documents.factory';
import { CatalogOperation } from './Catalogs/Catalog.Operation';
import { CatalogOperationServer } from './Catalogs/Catalog.Operation.server';
import { DocumentExchangeRatesServer } from './Documents/Document.ExchangeRates.server';
import { DocumentInvoiceServer } from './Documents/Document.Invoce.server';
import { DocumentOperation } from './Documents/Document.Operation';
import { DocumentOperationServer } from './Documents/Document.Operation.server';
import { DocumentPriceListServer } from './Documents/Document.PriceList.server';
import { DocumentUserSettingsServer } from './Documents/Document.UserSettings.server';
import { MSSQL } from '../mssql';
import { DocumentWorkFlowServer } from './Documents/Document.WorkFlow.server';
import { DocumentCashRequestServer } from './Documents/Document.CashRequest.server';
import { PostResult } from './post.interfaces';
import { DocumentCashRequestRegistryServer } from './Documents/Document.CashRequestRegistry.server';
import { CatalogCatalogServer } from './Catalogs/Catalog.Catalog.server';
import { CatalogProductKindServer } from './Catalogs/Catalog.ProductKind.server';
import { CatalogProductServer } from './Catalogs/Catalog.Product.server';
import { CatalogProductCategoryServer } from './Catalogs/Catalog.ProductCategory.server';
import { CatalogLoanServer } from './Catalogs/Catalog.Loan.server';
import { Ref, DocumentBase, IFlatDocument, DocumentOptions, RefValue, calculateDescription } from 'jetti-middle';
import { CatalogUserServer } from './Catalogs/Catalog.User.server';
import { CatalogOperationTypeServer } from './Catalogs/Catalog.Operation.Type.server';
import { CatalogRoleServer } from './Catalogs/Catalog.Role.server';

export interface IServerDocument {

  selfCreated?(tx: MSSQL, document: IFlatDocument | undefined): Promise<boolean>;
  onCreate?(tx: MSSQL): Promise<DocumentBaseServer>;
  onCopy?(tx: MSSQL): Promise<DocumentBaseServer>;

  beforeSave?(tx: MSSQL): Promise<DocumentBaseServer>;
  afterSave?(tx: MSSQL): Promise<DocumentBaseServer>;

  beforePost?(tx: MSSQL): Promise<DocumentBaseServer>;
  onUnPost?(tx: MSSQL): Promise<DocumentBaseServer>;
  onPost?(tx: MSSQL): Promise<PostResult>;
  afterPost?(tx: MSSQL): Promise<DocumentBaseServer>;

  beforeDelete?(tx: MSSQL): Promise<DocumentBaseServer>;
  afterDelete?(tx: MSSQL): Promise<DocumentBaseServer>;

  onValueChanged?(prop: string, value: any, tx: MSSQL): Promise<DocumentBaseServer>;
  onCommand?(command: string, args: any, tx: MSSQL): Promise<any>;

  baseOn?(id: Ref, tx: MSSQL, params?: any): Promise<DocumentBaseServer>;
}

export type DocumentBaseServer = DocumentBase & IServerDocument;

export const RegisteredServerDocument: RegisteredDocumentType[] = [
  { type: 'Catalog.Contract', Class: CatalogContractServer },
  { type: 'Catalog.Operation', Class: CatalogOperationServer },
  { type: 'Catalog.Operation.Type', Class: CatalogOperationTypeServer },
  { type: 'Catalog.StaffingTable', Class: CatalogStaffingTableServer },
  { type: 'Catalog.Person.Contract', Class: CatalogPersonContractServer },
  { type: 'Catalog.Catalog', Class: CatalogCatalogServer },
  { type: 'Catalog.Employee', Class: CatalogEmployeeServer },
  { type: 'Catalog.Loan', Class: CatalogLoanServer },
  { type: 'Catalog.ProductKind', Class: CatalogProductKindServer },
  { type: 'Catalog.Product', Class: CatalogProductServer },
  { type: 'Catalog.ProductCategory', Class: CatalogProductCategoryServer },
  { type: 'Catalog.Role', Class: CatalogRoleServer },
  { type: 'Catalog.User', Class: CatalogUserServer },
  { type: 'Document.Operation', Class: DocumentOperationServer },
  { type: 'Document.Invoice', Class: DocumentInvoiceServer },
  { type: 'Document.ExchangeRates', Class: DocumentExchangeRatesServer },
  { type: 'Document.PriceList', Class: DocumentPriceListServer },
  { type: 'Document.UserSettings', Class: DocumentUserSettingsServer },
  { type: 'Document.CashRequest', Class: DocumentCashRequestServer },
  { type: 'Document.WorkFlow', Class: DocumentWorkFlowServer },
  { type: 'Document.CashRequestRegistry', Class: DocumentCashRequestRegistryServer }
];

export async function createDocumentServer<T extends DocumentBaseServer>
  (type: string, document: IFlatDocument | undefined, tx: MSSQL) {
  let result: T;
  const doc = RegisteredServerDocument.find(el => el.type === type);
  if (doc) {
    const serverResult = <T>new doc.Class;
    const ArrayProps = Object.keys(serverResult).filter(k => Array.isArray(serverResult[k]));
    ArrayProps.forEach(prop => serverResult[prop].length = 0);
    if (document) serverResult.map(document);
    result = serverResult;
  } else {
    result = createDocument<T>(type, document);
  }

  if (result.selfCreated && await result.selfCreated(tx, document)) return result;

  result['serverModule'] = {};

  const Props = Object.assign({}, result.Props());
  const Prop = { ...result.Prop() as DocumentOptions };

  let Operation: CatalogOperation | null = null;
  let Grop: RefValue | null = null;

  if (result instanceof DocumentOperation && document && document.id) {
    result.f1 = null; result.f2 = null; result.f3 = null;
    Prop.commands = [];
    Prop.copyTo = [];
    if (result.Operation) {
      Operation = await lib.doc.byIdT<CatalogOperation>(result.Operation as string, tx);
      if (!Operation) throw new Error(`Operation with id ${result.Operation} not found!`);
      Grop = await lib.doc.formControlRef(Operation!.Group as string, tx);
      result.Group = Operation!.Group;
      Prop['Group'] = Grop;
      let i = 1;
      (Operation && Operation.Parameters || []).sort((a, b) => (a.order || 0) - (b.order || 0)).forEach(c => {
        if (c.type!.startsWith('Catalog.')) result[`f${i++}`] = result[c.parameter];
        Props[c.parameter] = ({
          label: c.label, type: c.type, required: !!c.required, change: c.change, order: (c.order || 0) + 103,
          [c.parameter]: c.tableDef ? JSON.parse(c.tableDef) : null, ...JSON.parse(c.Props ? c.Props : '{}')
        });
        if (result[c.parameter] === undefined) result[c.parameter] = Props[c.parameter].value;
      });


      Prop.commands = [
        ...Operation.commandsOnServer || [],
        ...(Operation.commandsOnClient || []).map(command => ({ ...command, isClientCommand: true }))
      ];

      for (const o of ((Operation && Operation.CopyTo) || [])) {
        const base = await lib.doc.byIdT<CatalogOperation>(o.Operation, tx);
        if (base) {
          const item = {
            icon: '',
            label: base.description,
            Operation: o.Operation,
            type: result.type,
            order: o.order || 1
          };
          Prop.copyTo.push(item);
        }
      }
      if (Operation && Operation.module) {
        Prop.module = Operation.module;
        const func = new Function('tx', Operation.module);
        result['serverModule'] = func.bind(result, tx)() || {};

        const onCreate: (tx: MSSQL) => Promise<T> = result['serverModule']['onCreate'];
        if (typeof onCreate === 'function') await onCreate(tx);
      }
    }
  }
  if (!Operation && result.onCreate) await result.onCreate(tx);
  // protect against mutate
  result.Props = () => Props;
  result.Prop = () => Prop;

  if (result.isDoc) result.description =
    calculateDescription((result.Prop() as DocumentOptions).description, result.date, result.code, Grop && Grop.value as string || '');
  return result;
}
