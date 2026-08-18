import { DocumentBase, JDocument, Props, Ref } from 'jetti-middle';
import {
  BUSINESS_PROCESS_RULE_PURPOSES,
  BusinessProcessRulePurpose,
} from '../../business-process/types/business-process-rule.types';

@JDocument({
  type: 'Catalog.BusinessProcessRules',
  description: 'Правило бизнес-процесса',
  icon: 'fas fa-code-branch',
  menu: 'Правила бизнес-процессов',
  prefix: 'BPR-',
  hierarchy: 'folders',
})
export class CatalogBusinessProcessRules extends DocumentBase {

  @Props({
    type: 'Catalog.BusinessProcessRules',
    hiddenInList: true,
    order: -1,
    storageType: 'folders',
  })
  parent: Ref = null;

  @Props({
    type: 'string',
    label: 'Код',
    order: 1,
    required: true,
    isUnique: true,
    style: { width: '250px' },
  })
  code = '';

  @Props({
    type: 'string',
    label: 'Наименование',
    order: 2,
    required: true,
    style: { width: '500px' },
  })
  description = '';

  @Props({
    type: 'enum',
    label: 'Назначение',
    order: 3,
    required: true,
    storageType: 'elements',
    value: [...BUSINESS_PROCESS_RULE_PURPOSES],
    style: { width: '400px' },
  })
  purpose: BusinessProcessRulePurpose | '' = '';

  @Props({
    type: 'javascript',
    label: 'Модуль',
    order: 4,
    required: true,
    hiddenInList: true,
    storageType: 'elements',
    panel: 'Серверный модуль',
    style: { height: '50vh' },
  })
  module = '';
}
