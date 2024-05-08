import { ADD_PROPS_GROUP_ID } from "../env/environment";
import { MSSQL } from "../mssql";
import { lib } from "../std.lib";
import { CatalogOperationType } from "./Catalogs/Catalog.Operation.Type";
import { DocumentServer } from "./document.server";
import { createDocument } from "./documents.factory";
import { createDocumentServer } from "./documents.factory.server";

const availableModelsByType = `
SELECT id,
description 
from [Catalog.Operation.Type.v] with (noexpand) 
where deleted = 0 and parent in (
	select top 1 id 
	from [Catalog.Operation.Type.v] with (noexpand) 
	where [OwnerType] = @p1 and deleted = 0)
ORDER BY description`

const addPropsDocType = 'Catalog.Operation.Type';

const byOwner = `SELECT top 1 id FROM [Catalog.Operation.Type.v] with (noexpand)  WHERE deleted = 0 and [Owner] = @p1  and [parent] = @p2;`

export class AdditionalProps {

    static type = addPropsDocType;
    static readonly groupId = ADD_PROPS_GROUP_ID;

    static availableModelsByType(type: string, tx: MSSQL) {
        return tx.manyOrNone<{ id: string, description: string }>(availableModelsByType, [type]);
    }

    static async new(ownerId: string, parentId: string, tx: MSSQL) {
        const docBase = createDocument(AdditionalProps.type, { parent: parentId });
        const serverDocBase = await createDocumentServer<CatalogOperationType>(AdditionalProps.type, docBase, tx);
        const schema = serverDocBase.Props();
        Object.keys(schema).filter(p => schema[p].value !== undefined).forEach(p => serverDocBase[p] = schema[p].value);
        serverDocBase.code = await lib.doc.docPrefix(this.type, tx);
        serverDocBase.description = 'AP';
        serverDocBase.Owner = ownerId;
        serverDocBase.parent = parentId;
        serverDocBase.user = tx.userId();
        if (serverDocBase['onCreate']) await serverDocBase['onCreate'](tx);
        return new DocumentServer(serverDocBase, tx);
    }

    static instance(id: string, tx: MSSQL) {
        return DocumentServer.byId<CatalogOperationType>(id, tx) as Promise<DocumentServer<CatalogOperationType>>;
    }

    static async byOwner(ownerId: string, parentId: string, tx: MSSQL) {
        const r = await tx.oneOrNone<{ id: string }>(byOwner, [ownerId, parentId]);
        if (r?.id) return await this.instance(r.id, tx);
        return this.new(ownerId, parentId, tx);
    }
}