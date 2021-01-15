import { Props, Ref } from 'jetti-middle';
import { JRegisterInfo, RegisterInfo } from 'jetti-middle';

@JRegisterInfo({
  type: 'Register.Info.RLS.Period',
  description: 'Row level security (period)',
})
export class RegisterInfoRLSPeriod extends RegisterInfo {

  @Props({ type: 'string', required: true, unique: true, order: 1 })
  user = '';

  @Props({ type: 'Catalog.Company', required: true, unique: true, order: 2 })
  company: Ref = null;

  @Props({ type: 'enum', value: ['ALL', 'INVENTORY'] })
  partition = '';

  constructor(init: Partial<RegisterInfoRLSPeriod>) {
    super(init);
    Object.assign(this, init);
  }
}
