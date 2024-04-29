import { InfoMovement } from "./post.interfaces";
import { lib } from "../std.lib";

export enum RLS_PARTITION {
    ALL = 'ALL',
    INVENTORY = 'INVENTORY'
};

const CONST = {
    CACHE_KEY: {
        ALL: 'RLS.Period.All',
        INVENTORY: 'RLS.Period.Inventory'
    },
    REGISTER_TYPE: 'Register.Info.RLS.Period',
    QUERY_RLS_SLICE_LAST: `
    SELECT MAX(date) date, company 
    FROM [Register.Info.RLS.Period] r WITH(NOEXPAND) 
    WHERE partition = @p1 
    GROUP BY company`
}

export class RegisterRlsPeriod {

    static readonly activePartitions: RLS_PARTITION[] = [RLS_PARTITION.ALL, RLS_PARTITION.INVENTORY];

    static getCacheUpdaters() {
        return this.activePartitions.map(e => ({ event: CONST.CACHE_KEY[e], handler: () => this.getLastRlsPeriodByPartition(e) }))
    }

    static async getLastRlsPeriodByPartition(partition: RLS_PARTITION) {
        const value = await lib.util.jettiPoolTx().manyOrNone<{ date: Date, company: string }>(CONST.QUERY_RLS_SLICE_LAST, [partition]);
        return new Map<string, number>(value.map(e => [e.company, e.date.getTime()]))
    }

    static async updatePartitionInCache(rlsPartition: RLS_PARTITION) {
        lib.cache.update(CONST.CACHE_KEY[rlsPartition]);
    }

    static get(company: string, partition: RLS_PARTITION): number {
        return lib.cache.get<Map<string, number>>(CONST.CACHE_KEY[partition])?.get(company) || 0;
    }

    static getRlsPartitionFromMovements({ info }: { info: InfoMovement[] }): RLS_PARTITION | undefined {
        const rlsPartitionData = info.find(e => e.type === CONST.REGISTER_TYPE)?.data;
        if (!rlsPartitionData) return;
        try {
            const partition = (JSON.parse(rlsPartitionData).partition || '').toUpperCase();
            if (RegisterRlsPeriod.activePartitions.some(e => e === partition)) return partition;
        } catch (error) {
            console.error('Register.Info.RLS.Period.update.parsePartition', error);
        }
    }

    static isDateInClosedPeriod(date: number, company: string, partition: RLS_PARTITION) {
        return this.get(company, partition) >= date;
    }
}
