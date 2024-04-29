import { AccumulationMovement, InfoMovement, PostResult } from "./post.interfaces";
import { MSSQL } from "../mssql";
import { DocumentServer } from "./document.server";
import { DocumentBaseServer } from "./documents.factory.server";
import { Ref, RegisterAccumulation, RegisterInfo } from "jetti-middle";
import { v1 } from "uuid";
import { RLS_PARTITION, RegisterRlsPeriod } from "./register.info.rls.period";
import { lib } from "../std.lib";
import { checkClosedPeriodPartitionAll, checkClosedPeriodPartitionInventory } from "../routes/utils/post-rules/closedPeriod";
import { checkRlsUpdate } from "../routes/utils/post-rules/rlsUpdate";
import { checkReadonlyPeriod } from "../routes/utils/post-rules/readonly";

const CONST = {
    REGISTER_TYPE: {
        RLS: 'Register.Info.RLS.Period',
        INVENTORY: 'Register.Accumulation.Inventory'
    },
    HOLDING_COMPANY: '9F00DDE0-F043-11E9-9115-B72821305A00',
    HOLDING_REGISTERS: ['Register.Accumulation.PL', 'Register.Accumulation.Balance'],
    DELETE_QUERY: `
    DELETE FROM "Register.Account" WHERE document = @p1;
    DELETE FROM "Register.Info" WHERE document = @p1;
    DELETE FROM "Accumulation" WHERE document = @p1;`,
    DELETE_CONTEXT_QUERY: `
    SELECT 
	sub.type,
	MIN(sub.date) date,
	company company,
	MAX(rlsPartition) rlsPartition
    FROM 
        (
        SELECT
            'accumulation' [type],
            CAST(MIN(date) AS DATE) date,
            company,
            null rlsPartition
        FROM [Accumulation] 
        WHERE document = @p1 
        GROUP BY company
        UNION
        SELECT
            'inventory' [type],
            CAST(MIN(date) AS DATE) date,
            company,
            null
        FROM [Accumulation] 
        WHERE document = @p1 AND [type] = N'Register.Accumulation.Inventory'
        GROUP BY company
        UNION
        SELECT
            'info',
            CAST(MIN(date) AS DATE),
            null,
            MIN(IIF([type] = N'Register.Info.RLS.Period', JSON_VALUE(data, '$.partition'), null))
        FROM [Register.Info]
        WHERE document = @p1
        ) sub
    GROUP BY sub.type, sub.company
    HAVING MIN(sub.date) IS NOT NULL`,
    ACTIVE_MIN_DATE_TYPES: ['accumulation', 'inventory', 'info']
}

export interface IRuleContext { docId: string, operation: 'INSERT' | 'DELETE', minDate: IMovementsMinDates, rlsPartition?: RLS_PARTITION, roles: string[] }

interface MovementsOnDelete { type: MovementPartitionType, date: Date, company: Ref, rlsPartition: RLS_PARTITION | null };
interface MovementsOnInsert { info: InfoMovement[], accumulation: AccumulationMovement[] };

type MovementPartitionType = 'accumulation' | 'info' | 'inventory';
type RuleHandler = (i: IRuleContext) => void;

interface rules {
    before: RuleHandler[],
    after: RuleHandler[],
}

interface IMovements {
    delete?: MovementsOnDelete[],
    insert?: MovementsOnInsert
}

interface MinDateByType {
    type: MovementPartitionType;
    date: number;
    companies?: MinDateByCompany[];
}

interface MinDateByCompany {
    date: number;
    company: Ref;
}
export interface IMovementsMinDates {
    date: number;
    byType: MinDateByType[]
}

export abstract class RegistersMovements {

    static async insert(document: DocumentServer<DocumentBaseServer>, tx: MSSQL) {
        await (new RegistersMovementsInsertOperation(document, tx)).execute();
    }

    static async delete(document: DocumentServer<DocumentBaseServer>, tx: MSSQL) {
        await (new RegistersMovementsDeleteOperation(document, tx)).execute();
    }

    protected static readonly checksRules: rules = {
        before: [checkReadonlyPeriod, checkClosedPeriodPartitionInventory, checkClosedPeriodPartitionAll],
        after: [checkRlsUpdate],
    }

    static get ActiveMovementPartitionTypes() {
        return CONST.ACTIVE_MIN_DATE_TYPES as MovementPartitionType[];
    }
    constructor(protected readonly document: DocumentServer<DocumentBaseServer>, protected readonly tx: MSSQL) { }

    get docBase() {
        return this.document.docBase;
    }

    protected context?: IRuleContext;
    protected movements: IMovements;

    protected async execute() {
        await this.prepareMovements();
        if (this.isEmpty()) return;
        this.prepareContext();
        this.doChecksRules('before');
        await this.commit();
        this.doChecksRules('after');
    }

    protected doChecksRules(key: keyof rules) {
        for (const rule of RegistersMovements.checksRules[key]) {
            // lib.log.logIfDev('[RegistersMovements.execRules]', key, JSON.stringify(this.context));
            rule(this.context!);
        }
    }

    protected minDateFromMovementsCommon(arr: { company: Ref, date: Date }[] = []) {
        const getCompanies = () => {
            const companies = [...new Set(arr.map(e => e.company))];
            return companies.map(company => ({ company, date: this.getMinDate(arr.filter(a => a.company === company)) }));
        }

        return { date: this.getMinDate(arr), companies: getCompanies() };
    }

    protected getMinDate(arr: { date: Date }[] = []): number {
        if (!arr.length) return 0;
        const res = arr.filter(e => !!e.date).map(e => e.date.getTime()).sort()[0];
        // lib.log.logIfDev('getMinDate', 'in', arr, 'out', res);
        return res;
    }

    protected abstract prepareMovements(): Promise<void>
    protected abstract isEmpty(): boolean;
    protected abstract prepareContext(): void;
    protected abstract commit(): Promise<void>;
}

export class RegistersMovementsInsertOperation extends RegistersMovements {

    async prepareMovements() {
        this.movements = { insert: this.postResultToMovements(await this.document.getPostResult()) }
    }


    isEmpty() {
        return !(this.movements.insert?.accumulation || []).length && !(this.movements.insert?.info || []).length
    }

    prepareContext() {
        this.context = {
            docId: this.docBase.id,
            roles: this.tx.user?.roles ?? [],
            operation: 'INSERT',
            minDate: this.minDateFromMovements(),
            rlsPartition: RegisterRlsPeriod.getRlsPartitionFromMovements(this.movements.insert!)
        };
    }


    async commit() {

        const movementToQueryAccumulation = ({ id, parent, calculated, kind, date, type, company, document, data }: AccumulationMovement) => {
            return `INSERT INTO "Accumulation" (id, parent, calculated, kind, date, type, company, document, data)
           VALUES ('${id}', '${parent}', ${calculated}, ${kind}, '${new Date(date).toJSON()}', N'${type}' , N'${company}','${document}', JSON_QUERY(N'${data}'));`;
        }

        const movementToQueryInfo = ({ date, type, company, document, data }: InfoMovement) => {
            return `INSERT INTO "Register.Info" (date, type, company, document, data)
          VALUES ('${new Date(date).toJSON()}', N'${type}', N'${company}','${document}', JSON_QUERY(N'${data}'));`;
        }

        const query = [
            ...this.movements.insert!.accumulation.map(movementToQueryAccumulation),
            ...this.movements.insert!.info!.map(movementToQueryInfo)]
            .join('\n')
            .replace(/\'undefined\'|\'null\'/g, 'NULL')

        const db = !!this.context?.rlsPartition ? lib.util.jettiPoolTx() : this.tx;

        if (query) { await db.none(query); }
    }

    private minDateFromMovements(): IMovementsMinDates {
        const movements = { ...this.movements.insert!, inventory: this.movements.insert!.accumulation.filter(e => e.type === CONST.REGISTER_TYPE.INVENTORY) };
        const mapByType = (type: MovementsOnDelete['type']) => ({ type, ...this.minDateFromMovementsCommon(movements[type]) })
        const byType = RegistersMovements.ActiveMovementPartitionTypes.map(mapByType);
        const date = this.getMinDate(byType.filter(e => !!e.date).map(e => ({ date: new Date(e.date) })));
        return { date, byType };
    }

    private postResultToMovements(Registers: PostResult): { info: InfoMovement[], accumulation: AccumulationMovement[] } {

        const isForbiddenAccumulationMovement = ({ company, type }: RegisterAccumulation) => company === CONST.HOLDING_COMPANY && CONST.HOLDING_REGISTERS.includes(type || '');

        const accumulationPostResultToMovement = (r: RegisterAccumulation): AccumulationMovement => {

            const deleteUnnecessaryJsonProps = ({ type, company, kind, calculated, document, date, parent, ...doc }: RegisterAccumulation) => doc;

            const data = deleteUnnecessaryJsonProps({ ...r, ...r['data'], company: r.company || this.docBase.company, document: this.docBase.id });

            const movement = {
                id: r.id || v1().toUpperCase(),
                parent: r.parent,
                calculated: r.calculated ? 1 : 0,
                kind: r.kind ? 1 : 0,
                date: r.date || this.docBase.date,
                type: r.type!,
                company: r.company || this.docBase.company,
                document: this.docBase.id,
                data: JSON.stringify(data).replace(/\'/g, '\'\'')
            };

            return movement;

        }

        const infoPostResultToMovement = (r: RegisterInfo) => {

            const deleteUnnecessaryJsonProps = ({ type, company, document, date, ...doc }: RegisterInfo) => doc;

            const data = deleteUnnecessaryJsonProps({ ...r, ...r['data'], company: r.company || this.docBase.company, document: this.docBase.id });

            const movement = {
                date: r.date || this.docBase.date,
                type: r.type!,
                company: r.company || this.docBase.company,
                document: this.docBase.id,
                data: JSON.stringify(data).replace(/\'/g, '\'\'')
            };

            return movement;

        }

        const accumulation = () => Registers.Accumulation.filter(e => !isForbiddenAccumulationMovement(e)).map(accumulationPostResultToMovement)

        const info = () => Registers.Info.map(infoPostResultToMovement);

        return { accumulation: accumulation(), info: info() };
    }
}


export class RegistersMovementsDeleteOperation extends RegistersMovements {

    async prepareMovements() {
        this.movements = { delete: await this.tx.manyOrNone<MovementsOnDelete>(CONST.DELETE_CONTEXT_QUERY, [this.docBase.id, this.docBase.date]) }
    }

    isEmpty() {
        return !this.movements.delete?.length
    }

    prepareContext() {
        this.context = {
            docId: this.docBase.id,
            operation: 'DELETE',
            roles: this.tx.user?.roles ?? [],
            minDate: this.minDateFromMovements(),
            rlsPartition: this.movements.delete?.find(e => !!e.rlsPartition)?.rlsPartition ?? undefined
        };
    }

    async commit() {
        const db = !!this.context?.rlsPartition ? lib.util.jettiPoolTx() : this.tx;
        await db.none(CONST.DELETE_QUERY, [this.docBase.id, this.docBase.date]);
    }

    private minDateFromMovements(): IMovementsMinDates {
        const filterByType = (type: MovementsOnDelete['type']) => this.movements.delete!.filter(e => e.type === type);
        const mapByType = (type: MovementsOnDelete['type']) => ({ type, ...this.minDateFromMovementsCommon(filterByType(type)) })
        const byType = RegistersMovements.ActiveMovementPartitionTypes.map(mapByType);
        const date = this.getMinDate(byType.filter(e => !!e.date).map(e => ({ date: new Date(e.date) })));
        return { date, byType };
    }

}