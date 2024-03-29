import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

@JRegisterAccumulation({
  type: 'Register.Accumulation.StaffingTable',
  description: 'Занятые позиции штатного расписания'
})
export class RegisterAccumulationStaffingTable extends RegisterAccumulation {

  @Props({ type: 'Catalog.Department', dimension: true })
  Department: Ref = null;

  @Props({ type: 'Catalog.Department.Company', dimension: true })
  DepartmentCompany: Ref = null;

  @Props({ type: 'enum', value: ['TEMP'], dimension: true })
  StaffingType = '';

  @Props({ type: 'Catalog.StaffingTable', dimension: true })
  StaffingTablePosition: Ref = null;

  @Props({ type: 'Catalog.Employee', dimension: true })
  Employee: Ref = null;

  @Props({ type: 'Catalog.Person', dimension: true })
  Person: Ref = null;

  @Props({ type: 'number', resource: true })
  SalaryRate = 0;

  @Props({ type: 'Catalog.Salary.Analytics', dimension: true })
  SalaryAnalytic: Ref = null;

  @Props({ type: 'Catalog.Currency', dimension: true })
  currency: Ref = null;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountPrepay = 0;

  constructor(init: Partial<RegisterAccumulationStaffingTable>) {
    super(init);
    Object.assign(this, init);
  }
}
