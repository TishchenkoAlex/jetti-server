import { Type } from "jetti-middle";
import { IRuleContext } from "../../../models/registers.movements";

const READONLY_DATE = new Date(2024, 0, 1);

export const READONLY = {
    ROLE: 'ignore readonly period',
    ERROR: 'INSERT forbidden for readonly data period',
    DATE: READONLY_DATE,
    TIME: READONLY_DATE.getTime()
} as const;

export function checkReadonlyPeriod(type: string, date: Date, roles: string[] = []) {
    if (Type.isDocument(type) && !roles.includes(READONLY.ROLE) && date && date < READONLY.DATE) {
        throw READONLY.ERROR;
    }
}

export function checkReadonlyPeriodRegisters({ minDate, roles }: IRuleContext) {
    if (!roles.includes(READONLY.ROLE)) {
        checkMovementDateInReadonlyPeriod(minDate?.date);
    }
}

function checkMovementDateInReadonlyPeriod(movementDate: number | undefined) {
    const isReadonly = (movementDate ?? 0) < READONLY.TIME;
    if (isReadonly) throw READONLY.ERROR;
}
