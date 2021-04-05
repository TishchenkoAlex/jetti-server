import { IDynamicMetadata, getDynamicMeta } from './Dynamic/dynamic.common';
import { AllDocTypes, DocTypes } from './documents.types';
import { x100 } from '../x100.lib';
import { lib } from '../std.lib';
import * as moment from 'moment';
import { getConfigSchema, IConfigSchema, getRegisteredDocuments } from './config';
import { getIndexedOperationsMap } from './indexedOperation';
import { DocumentBase } from 'jetti-middle';
import { RegisteredDocumentType } from './documents.factory';
import { IQueryFilter } from '../fuctions/filterBuilder';
import { MetaTree } from '../fuctions/metaTree';
import { IPermissionQueryFilterParams } from '../fuctions/UsersPermissions';

export interface IProcessVariables {
    permissionsDisabled: boolean;
    isAdminDisabled: boolean;
}
export class Global {

    static readonly _dynamicFields = ['JET_RegisteredDocuments', 'JET_dynamicMeta', 'JET_indexedOperations', 'JET_configSchema', 'JET_metaTree'];

    static x100 = x100;
    static lib = lib;
    static isProd: boolean = global['isProd'];
    // static byCode = lib.doc.byCode;
    static DocBase = DocumentBase;
    static moment = () => global['JET_moment'];

    static indexedOperations = () => global['JET_indexedOperations'] as Map<string, string>;
    static dynamicMeta = () => global['JET_dynamicMeta'] as IDynamicMetadata;

    static configSchema = () => global['JET_configSchema'] as Map<AllDocTypes, IConfigSchema> || new Map;
    static configSchemaAdd = (key: string, schema: IConfigSchema) => global['JET_configSchema'].set(key, schema);

    static RegisteredDocuments = () => global['JET_RegisteredDocuments'] as Map<DocTypes, RegisteredDocumentType> || new Map;
    static RegisteredDocumentDynamic = () =>
        (global['JET_dynamicMeta'] ? global['JET_dynamicMeta']['RegisteredDocument'] : []) as RegisteredDocumentType[]

    static processVariables = () => global['JET_processVariables'] as IProcessVariables;
    static permissionsDisabled = () => Global.processVariables().permissionsDisabled;
    static isAdminDisabled = () => Global.processVariables().isAdminDisabled;

    static usersPermissionsFilters = () => global['JET_usersPermissionsFilters'] as Map<string, IQueryFilter>;
    static usersPermissionsFiltersSet = (p: IPermissionQueryFilterParams, filter: IQueryFilter) =>
        Global.usersPermissionsFilters().set(Global.usersPermissionsFiltersKey(p), filter)
    static usersPermissionsFiltersGet = (p: IPermissionQueryFilterParams) =>
        Global.usersPermissionsFilters().get(Global.usersPermissionsFiltersKey(p))

    static usersPermissionsTypes = () => global['JET_usersPermissionsTypes'] as Map<string, Map<string, boolean>>;
    static usersPermissionsTypesSet = (user: string, types: Map<string, boolean>) => Global.usersPermissionsTypes().set(user, types);
    static usersPermissionsTypesGet = (user: string) => Global.usersPermissionsTypes().get(user);

    static usersPermissionsDelegates = () => global['JET_usersPermissionsDelegates'] as Map<string, string>;
    static usersPermissionsDelegatesSet = (user: string, delegate: string) => Global.usersPermissionsDelegates().set(user, delegate);
    static usersPermissionsDelegatesGet = (user: string) => Global.usersPermissionsTypes().get(user);

    static meta = () => global['JET_META'];

    private static delKeys(keys: string[]) {
        keys.forEach(key => delete global[key]);
    }

    static async init() {
        global['x100'] = x100;
        global['lib'] = lib;
        global['DOC'] = lib.doc;
        global['byCode'] = lib.doc.byCode;
        global['moment'] = moment;
        global['isProd'] = process.env.NODE_ENV === 'production';
        global['JET_usersPermissionsFilters'] = new Map;
        global['JET_usersPermissionsTypes'] = new Map;
        global['JET_usersPermissionsDelegates'] = new Map;
        global['JET_processVariables'] = { permissionsDisabled: false, isAdminDisabled: false };
        await Global.updateDynamicMeta();
        await Global.readProcessVariables();
    }

    static async readProcessVariables(opId: string = '016231F0-872E-11EB-B1F8-5DC0D0964B47') {
        const doc = await lib.doc.createDocServerById(opId, lib.util.jettiPoolTx());
        if (doc && doc!['serverModule'] && doc!['serverModule']['getVariables']) {
            const vars = await doc!['serverModule']['getVariables']();
            if (vars) Global.updateProcessVariables(vars);
        }
    }

    static async updateProcessVariables(variables: Partial<IProcessVariables>) {
        global['JET_processVariables'] = { ...Global.processVariables(), ...variables };
    }

    static async clearUsersPermissons(users?: string[]) {
        if (users && users.length) {
            const upf = Global.usersPermissionsFilters();
            const upt = Global.usersPermissionsTypes();
            const keys = [...upf.keys()];
            for (const user of users) {
                keys.filter(e => e.startsWith(user)).forEach(e => upf.delete(e));
                upt.delete(user);
            }
            global['JET_usersPermissionsFilters'] = upf;
            global['JET_usersPermissionsTypes'] = upt;
        } else {
            global['JET_usersPermissionsFilters'] = new Map;
            global['JET_usersPermissionsTypes'] = new Map;
        }
    }

    static async updateDynamicMeta() {
        this.delKeys(this._dynamicFields);
        Global._dynamicFields.forEach(field => delete global[field]);
        global['JET_RegisteredDocuments'] = await getRegisteredDocuments(); // only static
        global['JET_dynamicMeta'] = await getDynamicMeta();
        global['JET_indexedOperations'] = await getIndexedOperationsMap();
        global['JET_RegisteredDocuments'] = await getRegisteredDocuments(); // static + dynamic
        global['JET_configSchema'] = getConfigSchema();
        // MetaTree.init();
    }

    private static usersPermissionsFiltersKey(p: IPermissionQueryFilterParams) {
        return `${p.user}.${p.type}.${p.kind}.${p.operation}`;
    }
}
