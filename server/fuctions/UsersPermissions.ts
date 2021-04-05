import { CatalogUser } from './../models/Catalogs/Catalog.User';
import { DocumentTypes, CatalogTypes, AllDocTypes } from './../models/documents.types';
import { MSSQL } from '../mssql';
import { JETTI_POOL } from '../sql.pool.jetti';
import { Ref, PropOptions, FormListFilter, matchOperator, IUserPermission, Type, DocumentBase } from 'jetti-middle';
import { lib } from '../std.lib';
import { Global } from './../models/global';
import { filterBuilderGroup, IGroupFilter, IQueryFilter } from './filterBuilder';
import { createDocumentServer, DocumentBaseServer } from '../models/documents.factory.server';
import { buildViewModel } from '../routes/documents';

const sdba = new MSSQL(JETTI_POOL,
    { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });

export class UserPermissions {
    User: CatalogUser;
    Subsystems: { id: Ref, description: string }[];
    Roles: string[];
    UserGroups: Ref[];
    Documents: { DocType: DocumentTypes, read: boolean }[];
    Catalogs: { DocType: CatalogTypes, read: boolean }[];
}

class UserPermissionsRow {
    id: Ref;
    kind: string;
    description: string;
    DocType: DocumentTypes | CatalogTypes | null;
    read: boolean | null;
}

export interface IPermissionQueryFilterParams {
    user: string;
    kind: 'list' | 'view';
    type: AllDocTypes;
    operation?: string;
    tx?: MSSQL;
    props?: { [x: string]: PropOptions };
    forced?: boolean;
    permissions?: IUserPermission[];
}

export async function getUsersPermissionQueryFilters(users: string[], type: AllDocTypes): Promise<any> {
    const tx = lib.util.jettiPoolTx();
    const permissionsAll = (await usersPermissions(users, tx)).values;

    const getParams = (user: string): IPermissionQueryFilterParams => ({
        user,
        kind: 'list',
        tx,
        forced: true,
        permissions: permissionsAll.filter(e => e.user === user),
        type
    });

    const result = await Promise.all(
        users.map(e => getPermissionQueryFilter(getParams(e)))
    );

    return result.map((e, index) => ({
        user: users[index],
        tempTables: e.tempTable,
        where: e.where,
        docType: type
    }));
}



export async function getPermissionQueryFilter(params: IPermissionQueryFilterParams): Promise<IQueryFilter> {
    if (!Type.isRefType(params.type) ||
        (!params.forced && !(await isPermissionControlEnabledByUser(params.user, params.tx))))
        return { tempTable: '', where: '' };

    let result;
    if (params.forced)
        result = filterBuilderGroup(await getUserPermissionFilters(params), params.kind === 'view');
    else {
        result = Global.usersPermissionsFiltersGet(params);
        if (!result) {
            result = filterBuilderGroup(await getUserPermissionFilters(params), params.kind === 'view');
            Global.usersPermissionsFiltersSet(params, result);
        }
    }

    return result;
}

export async function isPermissionControlEnabledByUser(user: string, tx?: MSSQL) {
    if (Global.permissionsDisabled()) return false;
    if (tx && tx.user) return !tx.user.isAdmin || Global.isAdminDisabled();
    const userOb = await lib.doc.byIdT<CatalogUser>(user, lib.util.jettiPoolTx());
    if (!user || !userOb) throw new Error(`isPermissionControlEnabledByUser: user '${user}' dos\'t exist`);
    return !userOb.isAdmin || Global.isAdminDisabled();
}

async function getUserPermissionFilters(p: IPermissionQueryFilterParams): Promise<IGroupFilter[]> {

    const result: IGroupFilter[] = [];
    const permissions = p.permissions || (await usersPermissions([p.user], p.tx || lib.util.jettiPoolTx())).values;
    const types = lib.util.groupArray<string>(permissions, 'type');
    const operators = lib.util.groupArray<matchOperator>(permissions, 'operator');
    const props = p.props || p.operation ? await lib.meta.propsByType(p.type, p.operation, p.tx) : Global.configSchema().get(p.type)!.Props;
    const fLeft = (key: string) => p.kind === 'list' ? `${key}.id` : `"${key}".id`;
    const permissonsByTypes = Object.keys(props)
        .filter(key => types.includes(props![key].type) && key !== 'parent' && !key.startsWith('temp'))
        .map(key => ({
            type: props![key].type,
            key,
            permissions: permissions.filter(e => e.type === props![key].type)
        }));

    for (const permission of permissonsByTypes) {
        const filters: FormListFilter[] = [];
        for (const operator of operators) {
            const byOperator = permission.permissions.filter(e => e.operator === operator);
            if (!byOperator.length) continue;
            switch (operator) {
                case 'in group': case 'not in group':
                    byOperator.forEach(e => filters.push({
                        left: fLeft(permission.key),
                        center: operator,
                        right: { id: e.value, type: e.type },
                        isOR: operator === 'in group'
                    }));
                    break;
                case 'is null': case 'is not null':
                    byOperator.forEach(e => filters.push({
                        left: fLeft(permission.key),
                        center: operator,
                        right: null,
                        isOR: operator === 'is null'
                    }));
                    break;
                case 'in': case 'not in':
                    filters.push({
                        left: fLeft(permission.key),
                        center: operator,
                        right: byOperator.map(e => `'${e.value}'`),
                        isOR: operator === 'in'
                    });
            }
        }
        result.push({ group: 'AND', filters });
    }
    return result;
}


export async function usersPermissions(users: string[], tx: MSSQL) {

    try {
        const res = await tx.manyOrNone<IUserPermission>(`SELECT * FROM [UserPermission] WHERE [user] IN (${users.map(e => '\'' + e + '\'')})`);
        return {
            values: res.filter(e => e.kind === 'value'),
            types: res.filter(e => e.kind === 'type')
        };
    } catch (error) {
        return { values: [], types: [] };
    }
}

export async function userPermissionsTypes(user: string, tx: MSSQL) {
    if (!(await isPermissionControlEnabledByUser(user, tx))) return [];
    return (await usersPermissions([user], tx)).types.map(e => ({
        type: e.type === 'Catalog.Operation.Group' ? 'Document.Operation' : e.type,
        read: e.read,
        value: e.value
    }));
}

export async function isAvalibleObject(id: string, userID: string, tx: MSSQL) {
    if (!(await isPermissionControlEnabledByUser(userID, tx))) return true;
    const serverDoc = await lib.doc.createDocServerById(id, tx);
    return serverDoc && (await buildViewModel(serverDoc, tx)) !== null;
}

export async function controlPermission(serverDoc: DocumentBaseServer, tx: MSSQL) {
    if (!(await isPermissionControlEnabledByUser(tx.userId(), tx))) return;
    if (await isReadOnlyType(serverDoc.type as AllDocTypes, tx, serverDoc['Group']) || !(await buildViewModel(serverDoc, tx)))
        throw new Error('Access denied');
}

export async function isReadOnlyType(type: AllDocTypes, tx: MSSQL, value?: string) {
    if (!(await isPermissionControlEnabledByUser(tx.userId(), tx))) return false;
    if (tx.isRoleAvailable('Readonly')) return true;

    const perm = Global.usersPermissionsTypesGet(tx.userId());
    if (perm) return perm.get(`${type}${value || ''}`) || false;
    const map = new Map;
    const permissions = (await userPermissionsTypes(tx.userId(), tx));
    for (const permission of permissions) {
        map.set(`${type}${permission.value || ''}`, permission.read);
    }
    Global.usersPermissionsTypesSet(tx.userId(), map);
    return map.get(`${type}${value || ''}`);
}

export const getUserPermissions = async (user: CatalogUser): Promise<UserPermissions> => {

    const result = new UserPermissions;
    // const userId = await lib.doc.byCode('Catalog.User', (tx.user.email as string).substring(0, 36), tx);
    // if (!userId) throw new Error('Unknow user: ' + tx.user.email);
    // const user = await lib.doc.byIdT<CatalogUser>(userId as any, tx);
    // if (!user) throw new Error('Unknow user: ' + tx.user.email);
    result.User = user;
    const PermissionsData = await sdba.manyOrNone<UserPermissionsRow>(PermissionsQuery, [result.User.id, result.User.isAdmin]);
    result.Subsystems = PermissionsData.filter(e => e.kind === 'Subsystem').map(k => ({ id: k.id, description: k.description }));
    result.UserGroups = PermissionsData.filter(e => e.kind === 'UserOrGroup' && e.id !== user.id).map(k => k.id);
    result.Roles = PermissionsData.filter(e => e.kind === 'Role').map(k => k.description);
    result.Documents = PermissionsData.filter(e => e.kind === 'Document').map(k => (
        { DocType: k.DocType as DocumentTypes, read: !!k.read }
    ));
    result.Catalogs = PermissionsData.filter(e => e.kind === 'Catalog').map(k => (
        { DocType: k.DocType as CatalogTypes, read: !!k.read }
    ));
    return result;
};

export const getUserRoles = async (user: CatalogUser): Promise<string[]> => {
    return (await getUserPermissions(user)).Roles;
};

const PermissionsQuery = `
DROP TABLE IF EXISTS #userorgroup;
SELECT @p1 id
INTO   #userorgroup
UNION ALL
SELECT      id
FROM        documents
CROSS apply Openjson (doc, N'$.Users')
WITH ([UsersGroup.User] uniqueidentifier N'$.User') AS users
WHERE       (1=1)
AND         type = 'Catalog.UsersGroup'
AND         [UsersGroup.User] = @p1;

DROP TABLE IF EXISTS #roles1;
SELECT      [Role]
INTO        #roles1
FROM        documents
CROSS apply Openjson (doc, N'$.RoleList')
WITH ([Role] uniqueidentifier N'$.Role') AS roles
INNER JOIN  #userorgroup
ON          #userorgroup.id = cast(json_value(doc, N'$.UserOrGroup') AS uniqueidentifier)
WHERE       (1=1)
AND         posted = 1
AND         type = 'Document.UserSettings';

DROP TABLE IF EXISTS #subsystems1;
SELECT      subsystem,
            [read] N'read'
INTO        #subsystems1
FROM        documents r
CROSS apply Openjson (doc, N'$.Subsystems')
WITH (
    subsystem uniqueidentifier N'$.SubSystem',
    [read] bit N'$.read') AS subsystems
WHERE       (1=1)
AND         type = 'Catalog.Role'
AND         id IN (SELECT [Role] FROM   #roles1);

DROP TABLE IF EXISTS #subsystems;
SELECT   r.id,
         r.description
INTO     #subsystems
FROM     documents r
WHERE    (1=1)
AND      type = 'Catalog.SubSystem'
AND      posted = 1
AND      (id IN (SELECT subsystem FROM   #subsystems1)
         OR @p2 = 1)
ORDER BY code;

DROP TABLE IF EXISTS #roles;
SELECT r.id [Role],
       r.description
INTO   #roles
FROM   documents r
WHERE  (1=1)
AND    type = 'Catalog.Role'
AND    posted = 1
AND    id IN (SELECT [role] FROM   #roles1);

DROP TABLE IF EXISTS #documents;
SELECT document doctype,
            [read] N'read'
INTO        #documents
FROM        documents r
CROSS apply Openjson (doc, N'$.Documents')
WITH (
    document varchar(max) N'$.Document',
    [read] bit N'$.read') AS document
WHERE (1=1)
AND         type = 'Catalog.Role'
AND         id IN
            (SELECT [Role] FROM   #roles);
DROP TABLE IF EXISTS #catalogs;

SELECT document.[Catalog] doctype,
            [read] N'read'
INTO        #catalogs
FROM        documents r
CROSS apply Openjson (doc, N'$.Catalogs')
WITH (
    [Catalog] varchar(max) N'$.Catalog',
    [read] bit N'$.read') AS document
WHERE       (1=1)
AND         type = 'Catalog.Role'
AND         id IN (SELECT [Role] FROM #roles);

SELECT 'UserOrGroup' kind,
       *
FROM   #userorgroup;
SELECT 'Subsystem' kind,
       *
FROM   #subsystems;
SELECT  'Catalog' kind,
         doctype,
         Cast(Max(Cast([read] AS  INT)) AS BIT) N'read'
FROM     #catalogs
GROUP BY doctype;

SELECT   'Document' kind,
         doctype,
         Cast(Max(Cast([read] AS  INT)) AS BIT) N'read'
FROM  #documents
GROUP BY doctype;SELECT 'Role' kind,
       [role] id,
       description
FROM   #roles;`;
