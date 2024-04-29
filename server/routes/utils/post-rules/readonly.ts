import { IRuleContext } from "../../../models/registers.movements";

const READONLY_ROLE = 'ignore readonly period';
const READONLY_ERROR = 'INSERT forbidden for readonly data period';
const READONLY_DATE = (new Date(2022, 0, 1)).getTime();

export function checkReadonlyPeriod({ minDate, roles }: IRuleContext) {
    if (!roles.includes(READONLY_ROLE)) {
        checkMovementDateInReadonlyPeriod(minDate?.date);
    }
}

function checkMovementDateInReadonlyPeriod(movementDate: number | undefined) {
    const isReadonly = (movementDate ?? 0) < READONLY_DATE;
    if (isReadonly) throw READONLY_ERROR;
}
