import { Props, Ref } from 'jetti-middle';
import { JRegisterInfo, RegisterInfo } from 'jetti-middle';

@JRegisterInfo({
  type: 'Register.Info.AdditionalProps',
  description: 'Additional props',
  pruningMethod : 'nonBalanceProp'
})
export class RegisterInfoAdditionalProps extends RegisterInfo {

  @Props({ type: 'Catalog.Operation.Type', isIndexed: true })
  AddProp: Ref = null;

  @Props({ type: 'Types.Object', isIndexed: true })
  Object: Ref = null;

  @Props({ type: 'Types.Object', isIndexed: true })
  Analytic1: Ref = null;

  @Props({ type: 'Types.Object', isIndexed: true })
  Analytic2: Ref = null;

  @Props({ type: 'Types.Object' })
  ValueRef: Ref = null;

  @Props({ type: 'number' })
  ValueNumber = '';

  @Props({ type: 'string' })
  ValueString = '';

  @Props({ type: 'datetime' })
  ValueDate = '';

  @Props({ type: 'boolean' })
  ValueBoolean = '';

  constructor(init: Partial<RegisterInfoAdditionalProps>) {
    super(init);
    Object.assign(this, init);
  }
}

