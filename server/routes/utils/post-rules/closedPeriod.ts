import { IRuleContext } from "../../../models/registers.movements";
import { RLS_PARTITION, RegisterRlsPeriod } from "../../../models/register.info.rls.period";

const CONST = {
    INVENTORY: {
        REGISTER_TYPE: 'Register.Accumulation.Inventory',
        ROLE: 'Cost calculation',
        QUERY: `SELECT TOP 1 r.id FROM [Accumulation] r 
        INNER JOIN [dbo].[Register.Info.RLS.Period]  rls WITH(NOEXPAND)
        ON r.document = @p1 
        AND r.type = @p2
        AND r.company = rls.company
        AND rls.partition = N'INVENTORY'
        AND r.date <= rls.date`,
        ERROR: {
            DELETE: 'DELETE forbidden for closed data period in register "Inventory"',
            INSERT: 'INSERT forbidden for closed data period in register "Inventory"',
        }
    },
    ALL: {
        ROLE: 'ignore closed period',
        QUERY: `SELECT TOP 1 r.id FROM [Accumulation] r 
        INNER JOIN [dbo].[Register.Info.RLS.Period]  rls WITH(NOEXPAND)
        ON r.document = @p1 
        AND r.company = rls.company
        AND rls.partition = N'ALL'
        AND r.date <= rls.date`,
        ERROR: {
            DELETE: 'DELETE forbidden for closed data period',
            INSERT: 'INSERT forbidden for closed data period',
        }
    }
}


export function checkClosedPeriodPartitionInventory({ minDate, operation, roles }: IRuleContext) {
    if (roles.includes(CONST.INVENTORY.ROLE)) return;
    const companies = minDate.byType.find(e => e.type === 'inventory')?.companies || [];
    const outdated = companies.find(e => RegisterRlsPeriod.isDateInClosedPeriod(e.date, e.company as string, RLS_PARTITION.INVENTORY));
    if (outdated) throw CONST.INVENTORY.ERROR[operation];
}

export function checkClosedPeriodPartitionAll({ minDate, operation, roles }: IRuleContext) {
    if (roles.includes(CONST.ALL.ROLE)) return;
    const companies = minDate.byType.find(e => e.type === 'accumulation')?.companies || [];
    const outdated = companies.find(e => RegisterRlsPeriod.isDateInClosedPeriod(e.date, e.company as string, RLS_PARTITION.ALL));
    if (outdated) throw CONST.ALL.ERROR[operation];
}

// async function checkClosedPeriodBeforeUnPostInventoryFromDb(docId: string, tx: MSSQL) {
//     const movements = await tx.oneOrNone(CONST.INVENTORY.QUERY, [docId, CONST.INVENTORY.REGISTER_TYPE]);
//     if (!!movements) throw CONST.INVENTORY.ERROR.DELETE;
// }

// async function checkClosedPeriodBeforeUnPostAllFromDb(docId: string, tx: MSSQL) {
//     if (tx.isRoleAvailable(CONST.ALL.ROLE, true)) return;
//     const movements = await tx.oneOrNone(CONST.ALL.QUERY, [docId]);
//     if (!!movements) throw CONST.ALL.ERROR.DELETE;
// }


// export async function checkClosedPeriodBeforePost({ minDate }: IRuleContext, tx: MSSQL) {
//     const outdeted = minDate?.companiesAccumulation.find(e => RlsPeriodRegister.get(e.company as string, RLS_PARTITION.INVENTORY) <= e.date);
//     if (outdeted) throw CONST.INVENTORY.ERROR.DELETE;
//     const outdetedAll = minDate?.companiesAccumulation.find(e => RlsPeriodRegister.get(e.company as string, RLS_PARTITION.ALL) <= e.date);
//     if (outdetedAll) throw CONST.ALL.ERROR.DELETE;
// }

// async function checkClosedPeriodBeforePostInventory(movements: AccumulationMovement[], tx: MSSQL) {
//     const inventoryMovements = movements.filter(e => e.type === CONST.INVENTORY.REGISTER_TYPE);
//     const ignoreChecking = !inventoryMovements.length;

//     if (ignoreChecking) return;

//     const dates = RegistersMovements.movementsMinDates(inventoryMovements);
//     const toQuery = ({ company, date }: { date: number; company: Ref }) =>
//         `SELECT TOP 1 id from [dbo].[Register.Info.RLS.Period] r WITH(NOEXPAND)
//     WHERE r.company = N'${company}' and '${new Date(date).toJSON()}' <= r.date and r.partition = N'INVENTORY';`

//     const query = dates.companies.map(toQuery).join('\n');

//     const existed = await tx.oneOrNone(query);

//     if (existed) throw CONST.INVENTORY.ERROR.INSERT;

// }

// async function checkClosedPeriodBeforePostAll(movements: AccumulationMovement[], tx: MSSQL) {
//     const ignoreChecking = ((tx.user?.roles || []) as string[]).some(e => e.includes(CONST.ALL.ROLE));

//     if (ignoreChecking) return;

//     const dates = RegistersMovements.movementsMinDates(movements);
//     const toQuery = ({ company, date }: { date: number; company: Ref }) =>
//         `SELECT TOP 1 id from [dbo].[Register.Info.RLS.Period] r WITH(NOEXPAND)
//       WHERE r.company = N'${company}' and '${new Date(date).toJSON()}' <= r.date and r.partition = N'ALL';`

//     const query = dates.companies.map(toQuery).join('\n');

//     const existed = await tx.oneOrNone(query);

//     if (existed) throw CONST.ALL.ERROR.INSERT;
// }
