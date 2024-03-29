import { RegisterInfoTaxCheck } from './TaxCheck';
import { RegisterInfoDynamic } from './../../Dynamic/dynamic.prototype';
import { RegisterInfoShareEmission } from './ShareEmission';
import { RegisterInfoCompanyPrice } from './CompanyPrice';
import { RegisterInfoRoyaltySales } from './RoyaltySales';
import { RegisterInfoDepartmentStatus } from './DepartmentStatus';
import { RegisterInfoHoliday } from './Holiday';
import { RegisterInfoCompanyResponsiblePersons } from './CompanyResponsiblePersons';
import { RegisterInfoRLSPeriod } from './RLS.Period';
import { RegisterInfoDepreciation } from './Depreciation';
import { RegisterInfoExchangeRates } from './ExchangeRates';
import { RegisterInfoPriceList } from './PriceList';
import { RegisterInfoRLS } from './RLS';
import { RegisterInfoAdditionalProps } from './AdditionalProps';
import { RegisterInfoBudgetItemRule } from './BudgetItemRule';
import { DepartmentCompanyHistory } from './DepartmentCompanyHistory';
import { RegisterInfoCounterpartiePriceList } from './CounterpartiePriceList';
import { RegisterInfoSettlementsReconciliation } from './SettlementsReconciliation';
import { RegisterInfoProductSpecificationByDepartment } from './ProductSpecificationByDepartment';
import { RegisterInfoIntercompanyHistory } from './IntercompanyHistory';
import { RegisterInfoIncomeDocumentRegistry } from './IncomeDocumentRegistry';
import { RegisterInfoLoanOwner } from './LoanOwner';
import { RegisterInfoEmployeeHistory } from './EmployeeHistory';
import { RegisterInfoExchangeRatesNational } from './ExchangeRates.National';
import { RegisterInfoProductModifier } from './ProductModifier';
import { RegisterInfoSelfEmployed } from './SelfEmployed';
import { RegisterInfoStaffingTableHistory } from './StaffingTableHistory';
import { RegisterInfoEmploymentType } from './EmploymentType';
import { RegisterInfoIntl } from './Intl';
import { RegisterInfoBusinessCalendar } from './BusinessCalendar';
import { RegisterInfoBusinessCalendarMonths } from './BusinessCalendar.Months';
import { RegisterInfo } from 'jetti-middle';
import { RegisterInfoDepartmentLimitIndicators } from './Department.LimitIndicators';

export type RegistersInfo =
    RegisterInfoDynamic |
    RegisterInfoHoliday |
    RegisterInfoPriceList |
    RegisterInfoBusinessCalendar |
    RegisterInfoBusinessCalendarMonths |
    RegisterInfoDepartmentStatus |
    RegisterInfoDepartmentLimitIndicators |
    RegisterInfoRoyaltySales |
    RegisterInfoSettlementsReconciliation |
    RegisterInfoCompanyResponsiblePersons |
    RegisterInfoExchangeRates |
    RegisterInfoExchangeRatesNational |
    RegisterInfoDepreciation |
    RegisterInfoAdditionalProps |
    RegisterInfoIntl |
    RegisterInfoSelfEmployed |
    RegisterInfoProductSpecificationByDepartment |
    RegisterInfoIntercompanyHistory |
    RegisterInfoIncomeDocumentRegistry |
    RegisterInfoCompanyPrice |
    RegisterInfoShareEmission |
    RegisterInfoLoanOwner |
    RegisterInfoProductModifier |
    RegisterInfoEmployeeHistory |
    RegisterInfoEmploymentType |
    RegisterInfoStaffingTableHistory |
    RegisterInfoTaxCheck |
    RegisterInfoRLS;

export interface IRegisteredRegisterInfo {
    type: string;
    Class: typeof RegisterInfo;
}

const RegisteredRegisterInfo: IRegisteredRegisterInfo[] = [
    { type: 'Register.Info.Dynamic', Class: RegisterInfoDynamic },
    { type: 'Register.Info.Holiday', Class: RegisterInfoHoliday },
    { type: 'Register.Info.BusinessCalendar', Class: RegisterInfoBusinessCalendar },
    { type: 'Register.Info.BusinessCalendar.Months', Class: RegisterInfoBusinessCalendarMonths },
    { type: 'Register.Info.PriceList', Class: RegisterInfoPriceList },
    { type: 'Register.Info.SelfEmployed', Class: RegisterInfoSelfEmployed },
    { type: 'Register.Info.ProductModifier', Class: RegisterInfoProductModifier },
    { type: 'Register.Info.SettlementsReconciliation', Class: RegisterInfoSettlementsReconciliation },
    { type: 'Register.Info.ExchangeRates', Class: RegisterInfoExchangeRates },
    { type: 'Register.Info.ExchangeRates.National', Class: RegisterInfoExchangeRatesNational },
    { type: 'Register.Info.ProductSpecificationByDepartment', Class: RegisterInfoProductSpecificationByDepartment },
    { type: 'Register.Info.AdditionalProps', Class: RegisterInfoAdditionalProps },
    { type: 'Register.Info.Depreciation', Class: RegisterInfoDepreciation },
    { type: 'Register.Info.RLS.Period', Class: RegisterInfoRLSPeriod },
    { type: 'Register.Info.RLS', Class: RegisterInfoRLS },
    { type: 'Register.Info.BudgetItemRule', Class: RegisterInfoBudgetItemRule },
    { type: 'Register.Info.IntercompanyHistory', Class: RegisterInfoIntercompanyHistory },
    { type: 'Register.Info.DepartmentCompanyHistory', Class: DepartmentCompanyHistory },
    { type: 'Register.Info.Department.LimitIndicators', Class: RegisterInfoDepartmentLimitIndicators },
    { type: 'Register.Info.DepartmentStatus', Class: RegisterInfoDepartmentStatus },
    { type: 'Register.Info.CounterpartiePriceList', Class: RegisterInfoCounterpartiePriceList },
    { type: 'Register.Info.CompanyResponsiblePersons', Class: RegisterInfoCompanyResponsiblePersons },
    { type: 'Register.Info.IncomeDocumentRegistry', Class: RegisterInfoIncomeDocumentRegistry },
    { type: 'Register.Info.CompanyPrice', Class: RegisterInfoCompanyPrice },
    { type: 'Register.Info.ShareEmission', Class: RegisterInfoShareEmission },
    { type: 'Register.Info.LoanOwner', Class: RegisterInfoLoanOwner },
    { type: 'Register.Info.Intl', Class: RegisterInfoIntl },
    { type: 'Register.Info.RoyaltySales', Class: RegisterInfoRoyaltySales },
    { type: 'Register.Info.EmployeeHistory', Class: RegisterInfoEmployeeHistory },
    { type: 'Register.Info.EmploymentType', Class: RegisterInfoEmploymentType },
    { type: 'Register.Info.StaffingTableHistory', Class: RegisterInfoStaffingTableHistory },
    { type: 'Register.Info.TaxCheck', Class: RegisterInfoTaxCheck },
];

export function createRegisterInfo<T extends RegisterInfo>(init: Partial<T>): T {
    const doc = RegisteredRegisterInfo.find(el => el.type === init.type);
    if (doc) return (new doc.Class(init) as T);
    else throw new Error(`createRegisterInfo: can't create type! ${init.type} is not registered`);
}

export function RegisterRegisterInfo(Register: IRegisteredRegisterInfo) {
    RegisteredRegisterInfo.push(Register);
}

export function GetRegisterInfo() {
    return RegisteredRegisterInfo;
}
