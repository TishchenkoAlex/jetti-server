import { Props, Ref } from 'jetti-middle';
import { JRegisterInfo, RegisterInfo } from 'jetti-middle';

@JRegisterInfo({
  type: 'Register.Info.Department.LimitIndicators',
  description: 'Department Limit Indicators',
})
export class RegisterInfoDepartmentLimitIndicators extends RegisterInfo {

  @Props({ type: 'Catalog.Currency' })
  currency: Ref = null;

  @Props({ type: 'Catalog.RetailNetwork', isIndexed: true})
  RetailNetwork: Ref = null;

  @Props({ type: 'Catalog.Department', isIndexed: true})
  Department: Ref = null;

  @Props({ type: 'date' })
  TermStarts = null;

  @Props({ type: 'date' })
  TermEnds = null;

  @Props({ type: 'datetime' })
  TimeStart = null;

  @Props({ type: 'datetime' })
  TimeFinish = null;

  @Props({ type: 'number' })
  MaxOrderCount = 0;

  @Props({ type: 'number' })
  MaxOrderTotalAmount = 0;

  @Props({ type: 'number' })
  KitchenVolume = null;

  constructor(init: Partial<RegisterInfoDepartmentLimitIndicators>) {
    super(init);
    Object.assign(this, init);
  }
}
