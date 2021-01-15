import { Props, Ref } from 'jetti-middle';
import { JRegisterInfo, RegisterInfo } from 'jetti-middle';

@JRegisterInfo({
  type: 'Register.Info.EmployeeHistory',
  description: 'Кадровая история'
})
export class RegisterInfoEmployeeHistory extends RegisterInfo {

  @Props({ type: 'Catalog.Employee' })
  Employee: Ref = null;

  @Props({ type: 'Catalog.Person' })
  Person: Ref = null;

  @Props({ type: 'Catalog.Department' })
  Department: Ref = null;

  @Props({ type: 'Catalog.Department.Company' })
  DepartmentCompany: Ref = null;

  @Props({ type: 'Catalog.JobTitle' })
  JobTitle: Ref = null;

  @Props({ type: 'Catalog.StaffingTable' })
  StaffingPosition: Ref = null;

  @Props({ type: 'Catalog.Operation.Type' })
  OperationType: Ref = null;

  @Props({ type: 'number' })
  SalaryRate = 0;

  constructor(init: Partial<RegisterInfoEmployeeHistory>) {
    super(init);
    Object.assign(this, init);
  }
}
