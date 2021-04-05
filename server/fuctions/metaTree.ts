import { MSSQL } from '../mssql';
import { lib } from '../std.lib';
import { DocumentOptions } from 'jetti-middle/dist';
import { DocumentOperationServer } from './../models/Documents/Document.Operation.server';
import { configSchema } from '../models/config';

export type MetaKind = 'Catalog' | 'Document' | 'Form' | 'RegisterInfo' | 'RegisterAccumulation';

export class MetaTreeNode {
    key: string;
    kind: MetaKind;
    parentKey?: string;
    id?: string;
    type?: string;
    label?: string;
    isLeaf: boolean;
    propKey?: string;
    propLabel?: string;
    propType?: string;
    propOptions?: string;
    propValue?: any;
    children?: MetaTreeNode[];
}

export const metaTreeRoot: MetaTreeNode[] = [
    { isLeaf: true, key: 'Catalogs', kind: 'Catalog', parentKey: 'root' },
    { isLeaf: true, key: 'Documents', kind: 'Document', parentKey: 'root' },
    { isLeaf: true, key: 'Forms', kind: 'Form', parentKey: 'root' },
    { isLeaf: true, key: 'RegistersInfo', kind: 'RegisterInfo', parentKey: 'root' },
    { isLeaf: true, key: 'RegistersAccumulation', kind: 'RegisterAccumulation', parentKey: 'root' }
];


export class MetaTree {

    static init() {
        MetaTree.set(new Map);
        MetaTree.add('root', metaTreeRoot);
    }

    static async getByNode(node: Partial<MetaTreeNode>, tx?: MSSQL) {
        const key = MetaTree.keyByNode(node);
        const res = MetaTree.getByKey(key);
        if (res) return res;
        MetaTree.add(key, await MetaTree.getChildrenByNode(node, tx));
        return MetaTree.getByKey(key);
    }

    static async getChildrenByNode(node: Partial<MetaTreeNode>, tx?: MSSQL): Promise<MetaTreeNode[]> {

        if (node.parentKey === 'root' && node.kind === 'Document') {
            const groups = await MetaTree._getOperationsGroups(tx);
            return groups.map(g => ({
                isLeaf: true,
                parentKey: node.key,
                id: g.id,
                label: g.label,
                key: g.id,
                kind: node.kind!,
                type: 'Catalog.Operation.Group'
            }));
        }

        if (node.parentKey === 'Documents' && node.id) {
            const operations = await MetaTree._getOperationsByGroup(node.id, tx);
            return operations.map(g => ({
                isLeaf: true,
                parentKey: node.key,
                id: g.id,
                label: g.label,
                key: g.id,
                kind: node.kind!,
                type: 'Catalog.Operation'
            }));
        }

        if (node.kind === 'Document' && node.id && node.type === 'Catalog.Operation') {
            const doc = await lib.util.createObject(
                {
                    type: 'Document.Operation',
                    Operation: node.id,
                    id: lib.util.GUID()
                },
                tx || lib.util.jettiPoolTx()) as DocumentOperationServer;


            const props = doc.Props();

            return Object.keys(props).map(key => ({
                isLeaf: true,
                key: `${node.id}.${key}`,
                parentKey: node.id,
                kind: 'Document',
                type: 'Document.Operation',
                label: props[key].label || key,
                propKey: key,
                propType: props[key].type
            }));
        }

        if (node.parentKey === 'root') {
            return [...configSchema().keys()]
                .filter(key => key.startsWith(node.kind!))
                .map(key => {
                    const cs = configSchema().get(key);
                    return {
                        kind: node.kind!,
                        type: cs!.type,
                        isLeaf: true,
                        key: cs!.type,
                        parentKey: node.key,
                        label: cs?.menu || cs?.description || cs?.type,
                        children: Object.keys(cs!.Props).map(k => ({
                            isLeaf: true,
                            key: `${node.id}.${k}`,
                            parentKey: node.id,
                            kind: node.kind!,
                            type: cs!.type,
                            label: cs!.Props[k].label || k
                        }))
                    };
                });
        }
        return [];
    }

    static getByKey(key: string) {
        return (global['JET_metaTree'] as Map<string, MetaTreeNode[]>).get(key)
    }

    static set(tree: Map<string, MetaTreeNode[]>) {
        return global['JET_metaTree'] = tree;
    }

    static add(key: string, nodes: MetaTreeNode[]) { return global['JET_metaTree'].set(key, nodes); }

    static keyByNode(key: Partial<MetaTreeNode>) {
        return key.key!;
    }

    private static async _getOperationsGroups(tx?: MSSQL) {
        return (tx || lib.util.jettiPoolTx()).manyOrNone<{ id: string, type: string, label: string }>(`
        SELECT
            [id],
            [type],
            [menu] [label]
        FROM [sm].[dbo].[Catalog.Operation.Group]
        WHERE posted = 1
        ORDER BY [menu]`);
    }

    private static async _getOperationsByGroup(group: string, tx?: MSSQL) {
        return (tx || lib.util.jettiPoolTx()).manyOrNone<{ id: string, type: string, label: string }>(`
        SELECT
            [id],
            [description] [label],
            [shortName]
        FROM [sm].[dbo].[Catalog.Operation.v]
        WHERE
            [posted] = 1
            and [isfolder] = 0
            and [Group] = '42512520-BE7A-11E7-A145-CF5C65BC8F97'
        ORDER BY [description]`, [group]
        );
    }
}