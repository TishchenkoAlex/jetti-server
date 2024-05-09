import { IFlatDocument, Ref, dateReviverUTC } from "jetti-middle";
import { MSSQL } from "../mssql";
import { DocumentBaseServer, createDocumentServer } from "./documents.factory.server";
import { DocTypes } from "./documents.types";
import { lib } from "../std.lib";
import { setPostedSate, upsertDocument } from "../routes/utils/post";
import { buildViewModel } from "../routes/documents";
import { PostResult } from "./post.interfaces";
import { RegistersMovements } from "./registers.movements";

enum DocLiveCycleEvent {
    onUnPost = 'onUnPost',
    beforeDelete = 'beforeDelete',
    afterDelete = 'afterDelete',
    beforePost = 'beforePost',
    afterPost = 'afterPost'
}

const SQL_QUERY = {
    DELETE_DOCUMENT: `UPDATE "Documents" SET deleted = @p3, posted = @p4, timestamp = GETDATE() WHERE id = @p1;`
}

type asyncF = () => Promise<any>;

export class DocumentServer<T extends DocumentBaseServer> {

    static errorNotExistId(id: Ref) {
        return `Document with id "${id}" is not exist`;
    }

    static async byId(id: string, tx: MSSQL) {
        if (!id) return;
        const doc = await lib.doc.byId(id, tx);
        if (!doc) return;
        return await this.instance(doc, tx);
    }

    static async instance(data: IFlatDocument, tx: MSSQL) {
        const doc = await createDocumentServer(data.type, data, tx);
        return new DocumentServer(doc, tx);
    }

    static async new(type: DocTypes, tx: MSSQL) {
        const doc = await createDocumentServer(type, undefined, tx);
        return new DocumentServer(doc, tx);
    }

    static async parse(data: string, tx: MSSQL) {
        const docFlat: IFlatDocument = JSON.parse(JSON.stringify(data), dateReviverUTC);
        const doc = await createDocumentServer(docFlat.type, docFlat, tx);
        if (docFlat.ExchangeBase) {
            doc['ExchangeBase'] = docFlat.ExchangeBase;
            doc['ExchangeCode'] = docFlat.ExchangeCode;
        }
        return new DocumentServer(doc, tx);
    }

    constructor(private readonly doc: T, private tx: MSSQL) { }

    get id() {
        return this.doc?.id;
    }

    get type() {
        return this.doc?.type;
    }

    get deleted() {
        return this.doc?.deleted;
    }

    get posted() {
        return this.doc?.posted;
    }

    get docBase() {
        return this.doc;
    }

    get afterTxCommitted(): asyncF[] {
        return this._afterTxCommitted;
    }

    set afterTxCommitted(f: asyncF[]) {
        this._afterTxCommitted.push(...f);
    }

    private _afterTxCommitted: asyncF[] = [];

    async toViewModel() {
        return await buildViewModel(this.doc, this.tx);
    }

    private async newCode() {
        return await lib.doc.docPrefix(this.doc.type, this.tx);
    }

    static async unPostById(id: Ref, tx: MSSQL) {
        try {
            if (!id) throw this.errorNotExistId(id);
            await lib.util.adminMode(true, tx);
            const docServer = await this.byId(id, tx);
            if (!docServer) throw this.errorNotExistId(id);
            docServer.doc.posted = false;
            await docServer.upsert();
            await docServer.deleteMovements();
            return docServer;
        } catch (ex) {
            throw new Error(ex);
        }
        finally {
            await lib.util.adminMode(false, tx);
        }
    }

    static async postById(id: string, tx: MSSQL) {
        try {
            if (!id) throw this.errorNotExistId(id);
            await lib.util.adminMode(true, tx);
            const serverDoc = await setPostedSate(id, tx);
            if (!serverDoc) throw this.errorNotExistId(id);
            const docServer = new DocumentServer(serverDoc, tx);
            await docServer.deleteMovements();
            if (serverDoc.deleted === false)
                await docServer.insertMovements();
            return docServer;
        } catch (ex) {
            throw new Error(ex);
        }
        finally {
            await lib.util.adminMode(false, tx);
        }
    }

    async setDeleted(deleted: boolean) {
        if (deleted === this.deleted) return this.doc;
        if (deleted) await this.handleLifeCycleEvent(DocLiveCycleEvent.beforeDelete);

        if (this.doc.isDoc && deleted) {
            await RegistersMovements.delete(this, this.tx)
        }

        this.doc.deleted = deleted;
        this.doc.posted = false;

        await this.tx.none(SQL_QUERY.DELETE_DOCUMENT, [this.doc.id, this.doc.date, this.doc.deleted, this.doc.posted]);

        if (deleted) await this.handleLifeCycleEvent(DocLiveCycleEvent.afterDelete);

        return this.doc;
    }

    async unPost(options?: { postQueue?: number, withExchangeInfo?: boolean }) {
        try {
            await this.tx.adminMode(true);
            this.doc.posted = false;
            await this.upsert(options);
            await this.deleteMovements();
            return this.doc;
        } catch (error) {
            throw new Error(error);
        } finally {
            await this.tx.adminMode(false);
        }
    }

    async post(options?: { postQueue?: number, withExchangeInfo?: boolean }) {
        try {
            if (this.doc.deleted) throw `Can\'t POST deleted document ${this.doc.id}`
            await this.tx.adminMode(true);
            this.doc.code = this.doc.code || await this.newCode();
            this.doc.posted = options?.postQueue === undefined;
            await this.upsert(options);
            await this.deleteMovements();
            if (this.doc.posted)
                await this.insertMovements();
            else
                await lib.queuePost.addId(this.doc.id, options!.postQueue!)

            return this.doc;
        } catch (error) {
            throw new Error(error);
        } finally {
            await this.tx.adminMode(false);
        }
    }

    async save() {
        try {
            await this.tx.adminMode(true);
            this.doc.code = this.doc.code || await this.newCode();
            await this.upsert();
            if (this.doc.posted && this.doc.isDoc) {
                await this.deleteMovements();
                await this.insertMovements();
            }
            return this.doc;
        } catch (error) {
            throw new Error(error);
        } finally {
            await this.tx.adminMode(false);
        }
    }

    private async deleteMovements() {
        if (!this.doc.isDoc) return;
        await this.handleLifeCycleEvent(DocLiveCycleEvent.onUnPost);
        await RegistersMovements.delete(this, this.tx)
    }

    private async insertMovements() {
        await this.handleLifeCycleEvent(DocLiveCycleEvent.beforePost);

        if (this.doc.isDoc && this.doc.onPost) {
            await RegistersMovements.insert(this, this.tx)
        }

        await this.handleLifeCycleEvent(DocLiveCycleEvent.afterPost);
    }

    private async upsert(options?: { postQueue?: number, withExchangeInfo?: boolean }) {
        return await upsertDocument(this.doc, this.tx, { withExchangeInfo: !!options?.withExchangeInfo });
    }

    private async handleLifeCycleEvent(event: DocLiveCycleEvent) {
        const eventFunc: (tx: MSSQL) => Promise<void> = this.doc['serverModule'][event];
        if (typeof eventFunc === 'function') await eventFunc(this.tx);
        if (!!this.doc[event]) await this.doc[event]!(this.tx);
        return this.doc;
    }

    async getPostResult(): Promise<PostResult> {
        return await this.doc.onPost!(this.tx);
    }
}