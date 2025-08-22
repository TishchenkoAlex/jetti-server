import { IDynamicMetadata, getDynamicMeta } from './Dynamic/dynamic.common';
import { AllDocTypes, DocTypes } from './documents.types';
import { x100 } from '../x100.lib';
import { lib } from '../std.lib';
import { getConfigSchema, getRegisteredDocuments, IConfigSchema, storedInTablesTypes } from './config';
import { getIndexedOperationsMap } from './indexedOperation';
import { DocumentBase } from 'jetti-middle';
import { RegisteredDocumentType } from './documents.factory';
import { JCache } from './cache';
import { publisher, subscriber } from '..';
import { RegisterRlsPeriod } from './register.info.rls.period';


export class Global {

    private static _dynamicFields = ['RegisteredDocuments', 'dynamicMeta', 'indexedOperations', 'configSchema', 'storedInTablesTypes'];
    static x100 = x100;
    static lib = lib;
    static isProd: boolean = global['isProd'];
    // static byCode = lib.doc.byCode;
    static DocBase = DocumentBase;

    static indexedOperations = () => global['indexedOperations'] as Map<string, string>;
    static dynamicMeta = () => global['dynamicMeta'] as IDynamicMetadata;
    static configSchema = () => global['configSchema'] as Map<AllDocTypes, IConfigSchema> || new Map;
    static RegisteredDocuments = () => global['RegisteredDocuments'] as Map<DocTypes, RegisteredDocumentType> || new Map;
    static RegisteredDocumentDynamic = () =>
        (global['dynamicMeta'] ? global['dynamicMeta']['RegisteredDocument'] : []) as RegisteredDocumentType[]
    static storedInTablesTypes = () => (global['storedInTablesTypes'] || {}) as { [x: string]: boolean };
    static cache = () => global['cache'] as JCache;

    static async init() {
        global['x100'] = x100;
        global['lib'] = lib;
        global['DOC'] = lib.doc;
        global['byCode'] = lib.doc.byCode;
        global['isProd'] = process.env.NODE_ENV === 'production';
        await this.updateDynamicMeta();
        await this.initCache();
    }

    static cacheUpdate(event: string) {
        publisher.publish('updateCached', event);
    }

    private static async initCache() {
        const updaters = RegisterRlsPeriod.getCacheUpdaters();
        const cache = new JCache(new Map, updaters);
        global['cache'] = await cache.init();
        subscriber.subscribe(['updateCached']);
    }

    static async updateDynamicMeta() {
        Global._dynamicFields.forEach(field => delete global[field]);
        global['RegisteredDocuments'] = await getRegisteredDocuments(); // only static
        global['dynamicMeta'] = await getDynamicMeta();
        global['indexedOperations'] = await getIndexedOperationsMap();
        global['RegisteredDocuments'] = await getRegisteredDocuments(); // static + dynamic
        global['storedInTablesTypes'] = await storedInTablesTypes();
        global['configSchema'] = getConfigSchema();
    }

    static cacheSet(key: string, value: any) {
        return this.cache().set(key, value);
    }

    static cacheGet(key: string) {
        return this.cache().get(key);
    }
}
