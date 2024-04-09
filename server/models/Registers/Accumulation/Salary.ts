import { Props, Ref } from 'jetti-middle';
import { JRegisterAccumulation, RegisterAccumulation } from 'jetti-middle';

/* Check for pruning */
@JRegisterAccumulation({
  type: 'Register.Accumulation.Salary',
  description: 'Расчеты с сотрудниками',
  pruningMethod: 'balance'
})
export class RegisterAccumulationSalary extends RegisterAccumulation {

  @Props({ type: 'Catalog.Currency', required: true, dimension: true })
  currency: Ref = null;

  @Props({ type: 'Catalog.Company', required: true, dimension: true })
  KorrCompany: Ref = null;

  @Props({ type: 'Catalog.Department', dimension: true })
  Department: Ref = null;

  @Props({ type: 'Catalog.Person', required: true, dimension: true })
  Person: Ref = null;

  @Props({ type: 'Catalog.Person', required: true, dimension: true })
  Employee: Ref = null;

  @Props({ type: 'Catalog.Salary.Analytics', required: true, dimension: true })
  Analytics: Ref = null;

  @Props({ type: 'enum', value: ['INCOME', 'EXPENSE', 'PAID']})
  SalaryKind = 'INCOME';

  @Props({ type: 'Types.Catalog', required: false})
  PL: Ref = null;

  @Props({ type: 'Types.Catalog', required: false})
  PLAnalytics: Ref = null;

  @Props({ type: 'enum', value: ['APPROVED', 'PREPARED']})
  Status = 'APPROVED';

  @Props({ type: 'boolean' })
  IsPortal = false;

  @Props({ type: 'number', resource: true })
  Amount = 0;

  @Props({ type: 'number', resource: true })
  AmountInBalance = 0;

  @Props({ type: 'number', resource: true })
  AmountInAccounting = 0;

  constructor(init: Partial<RegisterAccumulationSalary>) {
    super(init);
    Object.assign(this, init);
  }
}
