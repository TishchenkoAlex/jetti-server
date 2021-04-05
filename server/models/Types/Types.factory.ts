import { TypesCompanyOrCounterpartieOrPersonOrRetailClient } from './Types.CompanyOrCounterpartieOrPersonOrRetailClient';
import { AllTypes } from './../documents.types';
import { TypesCompanyOrCompanyGroup } from './Types.CompanyOrCompanyGroup';
import { ComplexTypes } from '../documents.types';
import { TypesCatalog } from './Types.Catalog';
import { TypesDocument } from './Types.Document';
import { TypesExpenseOrBalanceOrIncome } from './Types.ExpenseOrBalanceOrIncome';
import { TypesObject } from './Types.Object';
import { TypesSubcount } from './Types.Subcount';
import { TypesBase } from './TypesBase';
import { TypesUserOrGroup } from './Types.UserOrGroup';
import { TypesCashOrBank } from './Types.CashOrBank';
import { TypesCashRecipient } from './Types.CashRecipient';
import { TypesCounterpartieOrPerson } from './Types.CounterpartieOrPerson';
import { TypesCounterpartieOrPersonContract } from './Types.CounterpartieOrPersonContract';
import { TypesPersonOrCounterpartieBankAccount } from './Types.PersonOrCounterpartieBankAccount';
import { TypesCompanyOrCounterpartieOrPerson } from './Types.CompanyOrCounterpartieOrPerson';
import { createDocument, RegisteredDocumentsTypes } from '../documents.factory';
import { DocumentOptions, Type } from 'jetti-middle';
import { TypesExpenseOrIncome } from './Types.ExpenseOrIncome';

export interface IRegisteredTypes {
  type: ComplexTypes;
  Class: typeof TypesBase;
}

export function allTypes(): { type: AllTypes, description: string }[] {
  return [
    ...documentsTypes(),
    ...simpleTypes(),
    ...RegisteredTypes.map(e => ({ type: e.type as any, description: e.type as string }))
  ];
}

export function documentsTypes(): { type: AllTypes, description: string }[] {
  return RegisteredDocumentsTypes()
    .map(type => ({
      type: type as AllTypes,
      description: (<DocumentOptions>(createDocument(type).Prop())).description
    }));
}

export function simpleTypes(): { type: AllTypes, description: string, defaultValue?: any }[] {

  return [
    { type: 'number', description: 'number', defaultValue: 0 },
    { type: 'date', description: 'date', defaultValue: null },
    { type: 'datetime', description: 'datetime', defaultValue: null },
    { type: 'string', description: 'string', defaultValue: '' },
    { type: 'boolean', description: 'boolean', defaultValue: false },
    { type: 'table', description: 'table', defaultValue: [] },
    { type: 'javascript', description: 'javascript', defaultValue: '' },
    { type: 'enum', description: 'emum', defaultValue: '' },
    { type: 'link', description: 'link', defaultValue: '' },
    { type: 'URL', description: 'URL', defaultValue: '' },
  ];

}

export function defaultTypeValue(type: any) {
  if (Type.isRefType(type)) return null;
  const simple = simpleTypes().find(e => e.type === type);
  return simple ? simple.defaultValue : null;
}

export function createTypes(type: ComplexTypes): TypesBase {
  const doc = RegisteredTypes.find(el => el.type === type);
  if (doc) return new doc.Class;
  else throw new Error(`type: ${type} is not defined.`);
}

export const RegisteredTypes: IRegisteredTypes[] = [
  { type: 'Types.Document', Class: TypesDocument },
  { type: 'Types.Catalog', Class: TypesCatalog },
  { type: 'Types.Subcount', Class: TypesSubcount },
  { type: 'Types.Object', Class: TypesObject },
  { type: 'Types.ExpenseOrBalanceOrIncome', Class: TypesExpenseOrBalanceOrIncome },
  { type: 'Types.TypesExpenseOrIncome', Class: TypesExpenseOrIncome },
  { type: 'Types.CashOrBank', Class: TypesCashOrBank },
  { type: 'Types.CashRecipient', Class: TypesCashRecipient },
  { type: 'Types.UserOrGroup', Class: TypesUserOrGroup },
  { type: 'Types.CounterpartieOrPerson', Class: TypesCounterpartieOrPerson },
  { type: 'Types.CounterpartieOrPersonContract', Class: TypesCounterpartieOrPersonContract },
  { type: 'Types.PersonOrCounterpartieBankAccount', Class: TypesPersonOrCounterpartieBankAccount },
  { type: 'Types.CompanyOrCounterpartieOrPerson', Class: TypesCompanyOrCounterpartieOrPerson },
  { type: 'Types.CompanyOrCounterpartieOrPersonOrRetailClient', Class: TypesCompanyOrCounterpartieOrPersonOrRetailClient },
  { type: 'Types.CompanyOrCompanyGroup', Class: TypesCompanyOrCompanyGroup },
];
