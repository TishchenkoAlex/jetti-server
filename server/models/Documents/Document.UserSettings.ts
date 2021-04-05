import { Ref, matchOperator } from 'jetti-middle';
import { DocumentBase, JDocument, Props } from 'jetti-middle/dist/common/models/document';

@JDocument({
  type: 'Document.UserSettings',
  description: 'User settings',
  icon: 'far fa-file-alt',
  menu: 'User settings',
  prefix: 'USET-',
  dimensions: [{ UserOrGroup: 'Types.UserOrGroup' }],
  commands: [
    { method: 'AddDescendantsCompany', icon: 'pi pi-plus', label: 'Добавить починенные компании', order: 1 },
    { method: 'ClearCompanyList', icon: 'pi pi-plus', label: 'Очистить ТЧ "Companys"', order: 2 }
  ],
})
export class DocumentUserSettings extends DocumentBase {
  @Props({ type: 'Types.Document', hiddenInList: true, order: -1 })
  parent: Ref = null;

  @Props({ type: 'Types.UserOrGroup', required: true })
  UserOrGroup: Ref = null;

  @Props({ type: 'boolean', label: 'Exclude Companys' })
  ExcludeCompanys = false;

  @Props({ type: 'boolean', label: 'Exclude Departments' })
  ExcludeDepartments = false;

  @Props({ type: 'boolean', label: 'Exclude Storehouse' })
  ExcludeStorehouse = false;

  @Props({ type: 'boolean', label: 'Exclude CashRegisters' })
  ExcludeCashRegisters = false;

  @Props({ type: 'boolean', label: 'Exclude BankAccounts' })
  ExcludeBankAccounts = false;

  @Props({ type: 'boolean', label: 'Exclude Operations ' })
  ExcludeOperationGroups = false;

  @Props({ type: 'table', order: 8, label: 'Filters' })
  Filters: Filters[] = [new Filters()];

  @Props({ type: 'table', order: 1, label: 'Roles' })
  RoleList: RoleItems[] = [new RoleItems()];

  @Props({ type: 'table', order: 2, label: 'Сompanys' })
  CompanyList: CompanyItems[] = [new CompanyItems()];

  @Props({ type: 'table', order: 3, label: 'Departments' })
  Departments: Departments[] = [new Departments()];

  @Props({ type: 'table', order: 4, label: 'Storehouses' })
  Storehouses: Storehouses[] = [new Storehouses()];

  @Props({ type: 'table', order: 5, label: 'CashRegisters' })
  CashRegisters: CashRegisters[] = [new CashRegisters()];

  @Props({ type: 'table', order: 6, label: 'BankAccounts' })
  BankAccounts: BankAccounts[] = [new BankAccounts()];

  @Props({ type: 'table', order: 7, label: 'Operation Groups' })
  OperationGroups: OperationGroups[] = [new OperationGroups()];

}

class Filters {

  @Props({ type: 'Catalog.Subcount', required: true })
  Type: Ref = null;

  @Props({ type: 'enum', value: ['IN', 'NOT IN', 'IN GROUP', 'NOT IN GROUP', 'IS NULL', 'IS NOT NULL'], required: true })
  MatchOperator: String = 'IN';

  @Props({ type: 'Types.Catalog' })
  Value: Ref = null;

}
class RoleItems {
  @Props({ type: 'Catalog.Role', required: true, style: { width: '100%' } })
  Role: Ref = null;
}

export class CompanyItems {
  @Props({ type: 'Catalog.Company', style: { width: '100%' } })
  company: Ref = null;
}

class OperationGroups {
  @Props({ type: 'Catalog.Operation.Group', style: { width: '100%' } })
  Group: Ref = null;
}

class Storehouses {
  @Props({ type: 'Catalog.Storehouse', style: { width: '100%' } })
  Storehouse: Ref = null;
}

class CashRegisters {
  @Props({ type: 'Catalog.CashRegister', style: { width: '100%' } })
  CashRegister: Ref = null;
}

class BankAccounts {
  @Props({ type: 'Catalog.BankAccount', style: { width: '100%' } })
  BankAccount: Ref = null;
}

class Departments {
  @Props({ type: 'Catalog.Department', style: { width: '100%' } })
  Department: Ref = null;
}




