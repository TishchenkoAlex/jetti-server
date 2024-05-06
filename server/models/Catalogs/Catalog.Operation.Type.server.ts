import { createDocumentServer, IServerDocument } from './../documents.factory.server';
import { MSSQL } from '../../mssql';
import { lib } from '../../std.lib';
import { CatalogOperationType } from './Catalog.Operation.Type';
import { createDocument } from '../documents.factory';
import { DocumentOptions, IFlatDocument, Ref } from 'jetti-middle';
import { DocumentOperationServer } from './../Documents/Document.Operation.server';

export class CatalogOperationTypeServer extends CatalogOperationType implements IServerDocument {

  async selfCreated(tx: MSSQL, document: IFlatDocument | undefined) {

    if (document) this.map(document);
    if (this['isExtended']) return true;
    
    this['isExtended'] = true;
    
    if (document?.isfolder) return false;
    const model = await this.getModel(tx, this.parent);
    if (!model) return false;

    const fakeDoc = {
      type: 'Document.Operation',
      Operation: model,
      Group: (await lib.util.getObjectPropertyById(model, 'Group', tx)).id
    };

    const doc: IFlatDocument = { ...createDocument(fakeDoc.type), ...fakeDoc };
    const ServerDoc = await createDocumentServer<DocumentOperationServer>(fakeDoc.type, doc, tx);
    const thisProps = { ...ServerDoc.Props(), ...this.Props() };

    ['Group', 'Operation', 'Amount', 'currency', 'f1', 'f2', 'f3'].forEach(key => delete thisProps[key]);
    if (!(await this.isEditorMode(tx)))
      Object.keys(this.getPropsWithOption('panel', 'Config')).forEach(key => thisProps[key].hidden = true);

    this.Props = () => thisProps;
    this['serverModule'] = ServerDoc['serverModule'];
    const modelProp = (ServerDoc.Prop() || {}) as DocumentOptions;
    if (modelProp.module || (modelProp.commands || []).length) {
      const thisProp = this.Prop() || {};
      this.Prop = () => ({ ...thisProp, module: modelProp.module, commands: modelProp.commands || [] });
      if (modelProp.module) {
        const func = new Function('tx', modelProp.module);
        this['serverModule'] = func.bind(this, tx)() || {};
        const onCreate: (tx: MSSQL) => Promise<any> = this['serverModule']['onCreate'];
        if (typeof onCreate === 'function') await onCreate(tx);
      }
    }
    return true;
  }

  async getModel(tx: MSSQL, parent: Ref) {
    if (this.Model || !parent) return this.Model;
    const parentOb = await lib.doc.byIdT<CatalogOperationType>(parent, tx);
    if (parentOb && parentOb.Model) return parentOb.Model;
    if (!parentOb || !parentOb.parent) return null;
    return this.getModel(tx, parentOb.parent);
  }

  async isEditorMode(tx: MSSQL) {
    return await lib.util.isRoleAvailable('Operation types editor', tx);
  }

  async beforeSave(tx: MSSQL) {
    delete this['isExtended'];
    const beforeSave: (tx: MSSQL) => Promise<any> = this['serverModule']['beforeSave'];
    if (typeof beforeSave === 'function') await beforeSave(tx);
    return this;
  }

  async onCommand(command: string, tx: MSSQL) {
    if (this[command]) await this[command](tx);
    return this;
  }

}
