import { configSchema } from './../../models/config';
import { MSSQL } from '../../mssql';
import { lib } from '../../std.lib';
import { filterBuilder, userContextFilter } from '../../fuctions/filterBuilder';
import {
  buildColumnDef, DocListRequestBody, DocListResponse, DocumentBase, FormListFilter,
  FormListSettings, IViewModel, PropOptions, Type,
} from 'jetti-middle';
import { ARGS } from '../..';
import { ARCH_USER } from '../../env/environment';


export async function _List(params: DocListRequestBody & { used: string }, tx: MSSQL): Promise<DocListResponse> {
  params.filter = (params.filter || [])
    .filter(el => !(el.right === null || el.right === undefined) || el.center === 'is null' || el.center === 'is not null');

  if (params.listOptions && params.listOptions!.withHierarchy) {
    let parent: any = null;
    if (params.id) {
      const ob = await lib.doc.byId(params.id, tx);
      parent = ob!.isfolder && !params.listOptions.hierarchyDirectionUp ? params.id : ob!.parent;
    }
    // folders
    const queryList = configSchema().get(params.type)!.QueryList;
    const parentWhere = parent ? 'd.[parent.id] = @p1' : 'd.[parent.id] is NULL';
    let queryText = `SELECT * FROM (${queryList}) d WHERE ${parentWhere} and isfolder = 1`;
    if (parent) {
      const ancestors = await lib.doc.Ancestors(params.id, tx) as any[];
      const ancestorsId = ancestors.filter(el => el.parent !== parent).map(e => '\'' + e.id + '\'').join();
      queryText = `${queryText} UNION SELECT * FROM (${queryList}) d WHERE id IN (${ancestorsId})`;
    }
    queryText += `${userContextFilter(tx.userContext, `"company.id"`)} ORDER BY description`;
    const folders = await tx.manyOrNone(queryText, [parent]);
    // elements
    const deletedFilter = params.filter.find(e => e.left === 'deleted');
    params.filter = [];
    params.filter.push(new FormListFilter('parent', '=', { id: parent, type: params.type }));
    params.filter.push(new FormListFilter('isfolder', '=', 0));
    if (deletedFilter) params.filter.push(new FormListFilter('deleted', '=', 0));
    params.listOptions.withHierarchy = false;
    const result = await List(params, tx);

    result.data = folders.concat(result.data);

    return result;
  }

  params.command = params.command || 'first';

  const cs = configSchema().get(params.type);
  const { QueryList, Props } = cs!;

  let row: DocumentBase | null = null;
  let query = '';

  if (params.id) row = (await tx.oneOrNone<DocumentBase>(`SELECT * FROM (${QueryList}) d WHERE d.id = '${params.id}'`));
  if (!row && params.command !== 'last') params.command = 'first';
  const isFirstLast = params.command === 'last' || params.command === 'first';
  if (row && isFirstLast) row = null;

  params.order.forEach(el => el.field += (Props[el.field].type as string).includes('.') ? '.value' : '');
  params.filter.forEach(el => el.left += (Props[el.left] && Props[el.left].type && (Props[el.left].type as string).includes('.')) ? '.id' : '');
  let valueOrder: { field: string, order: 'asc' | 'desc', value: any }[] = [];
  params.order.filter(el => el.order).forEach(el => {
    const value = row ? el.field.includes('.value') ? row[el.field.split('.')[0]].value : row[el.field] : '';
    valueOrder.push({ field: el.field, order: el.order || 'asc', value: row ? value : '' });
  });

  const lastORDER = valueOrder.length ? valueOrder[valueOrder.length - 1].order === 'asc' : true;
  valueOrder.push({ field: 'id', order: lastORDER ? 'asc' : 'desc', value: params.id });
  let orderbyBefore = ' ORDER BY '; let orderbyAfter = orderbyBefore;
  valueOrder.forEach(o => orderbyBefore += '"' + o.field + (o.order === 'asc' ? '" DESC, ' : '" ASC, '));
  orderbyBefore = orderbyBefore.slice(0, -2);
  valueOrder.forEach(o => orderbyAfter += '"' + o.field + (o.order === 'asc' ? '" ASC, ' : '" DESC, '));
  orderbyAfter = orderbyAfter.slice(0, -2);

  valueOrder = valueOrder.filter(el => !(el.value === null || el.value === undefined));
  const queryFilter = await filterBuilder(params.filter, tx, params.type);

  const usedInQuery = (dir: '>' | '<') => {
    if (!params.used) {
      return '';
    }
    let q = ` AND id in (SELECT TOP ${params.count + 1}
      id
   FROM
      DOCUMENTS
   WHERE
      CONTAINS(doc, '${params.used}') AND type = N'${params.type}'`;
    if (params.id) q += ` AND id ${dir === '>' ? '>=' : dir} N'${params.id}'`;
    q += ')';
    return q;
  };

  if (!Type.isType(params.type))
    queryFilter.where += userContextFilter(tx.userContext, params.type === 'Catalog.Company' ? 'd.id' : `"company.id"`);

  const queryBuilder = (isAfter: boolean) => {
    if (valueOrder.length === 0) return '';
    const order = valueOrder.slice();
    const dir = lastORDER ? isAfter ? '>' : '<' : isAfter ? '<' : '>';
    const usedQuery = usedInQuery(dir);
    let queryBuilderResult = `
      SELECT TOP ${params.count + 1} id FROM(${QueryList}) d
      WHERE ${queryFilter.where} ${usedQuery}`;

    if (usedQuery) return queryBuilderResult;

    queryBuilderResult += `AND (`;

    valueOrder.forEach(_or => {
      let where = '(';
      order.forEach(_o =>
        where += ` "${_o.field}" ${_o !== order[order.length - 1] ? '=' :
          dir + ((_o.field === 'id') && isAfter ? '=' : '')} N'${_o.value instanceof Date ? _o.value.toJSON() : _o.value}' AND `
      );
      where = where.slice(0, -4);
      order.length--;
      queryBuilderResult += ` ${where} ) OR \n`;
    });
    queryBuilderResult = queryBuilderResult.slice(0, -4) + ')';

    queryBuilderResult += `\n${lastORDER ?
      (dir === '>') ? orderbyAfter : orderbyBefore :
      (dir === '<') ? orderbyAfter : orderbyBefore
      } \n`;
    return queryBuilderResult;
  };

  const queryBefore = queryBuilder(false);
  const queryAfter = queryBuilder(true);
  if (queryBefore && queryAfter && row) {
    query = `${queryFilter.tempTable}
SELECT * FROM(${QueryList}) d WHERE id IN(
  SELECT id FROM(${queryBefore}) q1
      UNION ALL
      SELECT id FROM(${queryAfter}) q2
)
    ${orderbyAfter} `;
  } else {
    // const filter = filterBuilder(params.filter);
    if (params.command === 'last')
      query = `${queryFilter.tempTable} SELECT * FROM(SELECT TOP ${params.count + 1} * FROM(${QueryList}) d WHERE ${(queryFilter.where)} ${usedInQuery('<')} ${orderbyBefore}) d ${orderbyAfter} `;
    else
      query = `${queryFilter.tempTable}SELECT TOP ${params.count + 1} * FROM(${QueryList}) d WHERE ${(queryFilter.where)} ${usedInQuery('>')} ${orderbyAfter} `;
  }

  if (process.env.NODE_ENV !== 'production' && !ARGS.DISABLED_LIST_LOG) console.log(query);
  const data = await tx.manyOrNone<any>(query);

  return listPostProcess(data, params);
}


export async function List(params: DocListRequestBody & { used: string }, tx: MSSQL): Promise<DocListResponse> {
  if (isBusinessProcessListType(params.type)) return BusinessProcessList(params, tx);

  params.filter = (params.filter || [])
    .filter(el => !(el.right === null || el.right === undefined) || el.center === 'is null' || el.center === 'is not null');

  if (params.listOptions && params.listOptions!.withHierarchy) {
    let parent: any = null;
    if (params.id) {
      const ob = await lib.doc.byId(params.id, tx);
      parent = ob!.isfolder && !params.listOptions.hierarchyDirectionUp ? params.id : ob!.parent;
    }
    // folders
    const queryList = configSchema().get(params.type)!.QueryList;
    const parentWhere = parent ? 'd.[parent.id] = @p1' : 'd.[parent.id] is NULL';
    let queryText = `SELECT * FROM (${queryList}) d WHERE ${parentWhere} and isfolder = 1`;
    if (parent) {
      const ancestors = await lib.doc.Ancestors(params.id, tx) as any[];
      const ancestorsId = ancestors.filter(el => el.parent !== parent).map(e => '\'' + e.id + '\'').join();
      queryText = `${queryText} UNION SELECT * FROM (${queryList}) d WHERE id IN (${ancestorsId})`;
    }
    queryText += `${userContextFilter(tx.userContext, `"company.id"`)} ORDER BY description`;
    const folders = await tx.manyOrNone(queryText, [parent]);
    // elements
    const deletedFilter = params.filter.find(e => e.left === 'deleted');
    params.filter = [];
    params.filter.push(new FormListFilter('parent', '=', { id: parent, type: params.type }));
    params.filter.push(new FormListFilter('isfolder', '=', 0));
    if (deletedFilter) params.filter.push(new FormListFilter('deleted', '=', 0));
    params.listOptions.withHierarchy = false;
    const result = await List(params, tx);

    result.data = folders.concat(result.data);

    return result;
  }

  params.command = params.command || 'first';

  const cs = configSchema().get(params.type);
  const { QueryList, Props } = cs!;

  let row: DocumentBase | null = null;
  let query = '';

  if (params.id) row = (await tx.oneOrNone<DocumentBase>(`SELECT * FROM (${QueryList}) d WHERE d.id = @p1`, [params.id]));
  if (!row && params.command !== 'last') params.command = 'first';
  const isFirstLast = params.command === 'last' || params.command === 'first';
  if (row && isFirstLast) row = null;

  params.order.forEach(el => el.field += (Props[el.field].type as string).includes('.') ? '.value' : '');
  params.filter.forEach(el => el.left += (Props[el.left] && Props[el.left].type && (Props[el.left].type as string).includes('.')) ? '.id' : '');
  let valueOrder: { field: string, order: 'asc' | 'desc', value: any }[] = [];
  params.order.filter(el => el.order).forEach(el => {
    const value = row ? el.field.includes('.value') ? row[el.field.split('.')[0]].value : row[el.field] : '';
    valueOrder.push({ field: el.field, order: el.order || 'asc', value: row ? value : '' });
  });

  const lastORDER = valueOrder.length ? valueOrder[valueOrder.length - 1].order === 'asc' : true;
  valueOrder.push({ field: 'id', order: lastORDER ? 'asc' : 'desc', value: params.id });
  let orderbyBefore = ' ORDER BY '; let orderbyAfter = orderbyBefore;
  valueOrder.forEach(o => orderbyBefore += '"' + o.field + (o.order === 'asc' ? '" DESC, ' : '" ASC, '));
  orderbyBefore = orderbyBefore.slice(0, -2);
  valueOrder.forEach(o => orderbyAfter += '"' + o.field + (o.order === 'asc' ? '" ASC, ' : '" DESC, '));
  orderbyAfter = orderbyAfter.slice(0, -2);

  valueOrder = valueOrder.filter(el => !(el.value === null || el.value === undefined));
  const queryFilter = await filterBuilder(params.filter, tx, params.type);

  const usedInQuery = (dir: '>' | '<') => {
    if (!params.used) {
      return '';
    }
    let q = ` AND id in (SELECT TOP ${params.count + 1}
      id
   FROM
      DOCUMENTS
   WHERE
      CONTAINS(doc, '${params.used}') AND type = N'${params.type}'`;
    if (params.id) q += ` AND id ${dir === '>' ? '>=' : dir} N'${params.id}'`;
    q += ')';
    return q;
  };

  const sqlParams = {};
  const getSqlParam = (key: string, value: any) => {
    if (!Object.keys(sqlParams).includes(key)) sqlParams[key] = value;
    return `@p${Object.keys(sqlParams).indexOf(key) + 1}`;
  }

  if (!Type.isType(params.type) && !isTypeListOperation(params.type))
    queryFilter.where += userContextFilter(tx.userContext, params.type === 'Catalog.Company' ? 'd.id' : `"company.id"`);

  const queryBuilder = (isAfter: boolean) => {
    if (valueOrder.length === 0) return '';
    const order = valueOrder.slice();
    const dir = lastORDER ? isAfter ? '>' : '<' : isAfter ? '<' : '>';
    const usedQuery = usedInQuery(dir);
    let queryBuilderResult = `
      SELECT TOP ${params.count + 1} id FROM(${QueryList}) d
      WHERE ${queryFilter.where} ${usedQuery}`;

    if (usedQuery) return queryBuilderResult;

    queryBuilderResult += `AND (`;

    valueOrder.forEach(_or => {
      let where = '(';
      order.forEach(_o =>
        where += ` "${_o.field}" ${_o !== order[order.length - 1] ? '=' :
          dir + ((_o.field === 'id') && isAfter ? '=' : '')} ${getSqlParam(_o.field, _o.value)} AND `
      );
      where = where.slice(0, -4);
      order.length--;
      queryBuilderResult += ` ${where} ) OR \n`;
    });
    queryBuilderResult = queryBuilderResult.slice(0, -4) + ')';

    queryBuilderResult += `\n${lastORDER ?
      (dir === '>') ? orderbyAfter : orderbyBefore :
      (dir === '<') ? orderbyAfter : orderbyBefore
      } \n`;
    return queryBuilderResult;
  };

  const queryBefore = queryBuilder(false);
  const queryAfter = queryBuilder(true);
  if (queryBefore && queryAfter && row) {
    query = `${queryFilter.tempTable}
SELECT * FROM(${QueryList}) d WHERE id IN(
  SELECT id FROM(${queryBefore}) q1
      UNION ALL
      SELECT id FROM(${queryAfter}) q2
)
    ${orderbyAfter} `;
  } else {
    // const filter = filterBuilder(params.filter);
    if (params.command === 'last')
      query = `${queryFilter.tempTable} SELECT * FROM(SELECT TOP ${params.count + 1} * FROM(${QueryList}) d WHERE ${(queryFilter.where)} ${usedInQuery('<')} ${orderbyBefore}) d ${orderbyAfter} `;
    else
      query = `${queryFilter.tempTable}SELECT TOP ${params.count + 1} * FROM(${QueryList}) d WHERE ${(queryFilter.where)} ${usedInQuery('>')} ${orderbyAfter} `;
  }

  if (Type.isCatalog(params.type) && !isTypeListOperation(params.type)) {
    if (query.includes('SELECT *')) {
      query = query.replace('SELECT *', `SELECT *, IIF([user.id] = '${ARCH_USER}', CAST(1 AS bit), CAST(0 AS bit)) archived`);
    } else
      query = query.replace(`SELECT TOP ${params.count + 1} *`, `SELECT TOP ${params.count + 1} *, IIF([user.id] = '${ARCH_USER}', CAST(1 AS bit), CAST(0 AS bit)) archived`);

  }

  if (process.env.NODE_ENV !== 'production' && !ARGS.DISABLED_LIST_LOG) console.log(query);
  const data = await tx.manyOrNone<any>(query, Object.values(sqlParams));

  return listPostProcess(data, params);
}

type BusinessProcessListConfig = {
  queryList: string;
  viewQueryList?: string;
  fields: string[];
  searchFields: string[];
  companyField?: string;
  description: string;
  icon: string;
  schema: { [field: string]: any };
};

const businessProcessListConfigs = new Map<string, BusinessProcessListConfig>();

function registerBusinessProcessListConfig(types: string[], config: BusinessProcessListConfig) {
  types.forEach(type => businessProcessListConfigs.set(type, config));
}

registerBusinessProcessListConfig(
  [
    'Process', 'BusinessProcess', 'BusinessProcess.Process', 'BusinessProcess.Instance',
    'BusinessProcessInstance',
  ],
  {
    queryList: `SELECT * FROM dbo.BusinessProcessInstance`,
    description: 'Processes',
    icon: 'fas fa-project-diagram',
    fields: [
      'id', 'templateId', 'templateCode', 'templateVersion', 'templateHash', 'objectType',
      'objectId', 'status', 'currentStepKey', 'startedAt', 'completedAt', 'author',
      'company', 'context', 'idempotencyKey', 'createdAt', 'updatedAt',
    ],
    searchFields: ['templateCode', 'objectType', 'status', 'currentStepKey'],
    companyField: '"company"',
    schema: {
      id: hiddenBusinessProcessListProp('string'),
      type: hiddenBusinessProcessListProp('string'),
      templateCode: businessProcessListProp('string', 'Template', 1),
      templateVersion: businessProcessListProp('number', 'Version', 2),
      objectType: businessProcessListProp('string', 'Object type', 3),
      objectId: businessProcessListProp('string', 'Object', 4),
      status: {
        ...businessProcessListProp('enum', 'Status', 5,
          ['RUNNING', 'COMPLETED', 'REJECTED', 'CANCELLED', 'FAILED']),
        controlType: 'string',
      },
      currentStepKey: businessProcessListProp('string', 'Current step', 6),
      startedAt: businessProcessListProp('datetime', 'Started at', 7),
      completedAt: businessProcessListProp('datetime', 'Completed at', 8),
      author: businessProcessListProp('string', 'Author', 9),
      company: businessProcessListProp('string', 'Company', 10),
      createdAt: businessProcessListProp('datetime', 'Created at', 11),
      updatedAt: businessProcessListProp('datetime', 'Updated at', 12),
    },
  },
);

registerBusinessProcessListConfig(
  ['Task', 'BusinessProcess.Task', 'BusinessProcessTask'],
  {
    queryList: `SELECT t.*, i.company
      FROM dbo.BusinessProcessTask t
      INNER JOIN dbo.BusinessProcessInstance i ON i.id = t.instanceId`,
    description: 'Tasks',
    icon: 'fas fa-tasks',
    fields: [
      'id', 'instanceId', 'objectType', 'objectId', 'stepKey', 'title', 'status',
      'assigneeUser', 'assigneeRole', 'activeFrom', 'dueAt', 'completedAt',
      'decisionUser', 'decisionComment', 'delegatedFromUser', 'redirectedFromUser',
      'penaltyRuleSnapshot', 'penaltyAmount', 'overdueAt', 'penaltyAppliedAt',
      'createdAt', 'company',
    ],
    searchFields: ['title', 'objectType', 'stepKey', 'status', 'assigneeUser', 'assigneeRole'],
    companyField: '"company"',
    schema: {
      id: hiddenBusinessProcessListProp('string'),
      type: hiddenBusinessProcessListProp('string'),
      title: businessProcessListProp('string', 'Task', 1),
      status: {
        ...businessProcessListProp('enum', 'Status', 2, [
          'CREATED', 'WAITING', 'ACTIVE', 'APPROVED', 'REJECTED', 'REDIRECTED',
          'AUTO_COMPLETED', 'TIMEOUT', 'OVERDUE', 'CANCELLED',
        ]),
        controlType: 'string',
      },
      objectType: businessProcessListProp('string', 'Object type', 3),
      objectId: businessProcessListProp('string', 'Object', 4),
      stepKey: businessProcessListProp('string', 'Step', 5),
      assigneeUser: businessProcessListProp('string', 'Assignee', 6),
      assigneeRole: businessProcessListProp('string', 'Assignee role', 7),
      activeFrom: businessProcessListProp('datetime', 'Active from', 8),
      dueAt: businessProcessListProp('datetime', 'Due at', 9),
      completedAt: businessProcessListProp('datetime', 'Completed at', 10),
      decisionUser: businessProcessListProp('string', 'Decision user', 11),
      decisionComment: businessProcessListProp('string', 'Decision comment', 12),
      penaltyAmount: businessProcessListProp('number', 'Penalty amount', 13),
      overdueAt: businessProcessListProp('datetime', 'Overdue at', 14),
      company: businessProcessListProp('string', 'Company', 15),
      createdAt: businessProcessListProp('datetime', 'Created at', 16),
    },
  },
);

registerBusinessProcessListConfig(
  [
    'ProcessTemplate', 'BusinessProcess.ProcessTemplate', 'BusinessProcess.Template',
    'BusinessProcessTemplate',
  ],
  {
    queryList: `SELECT
      id, code, description, active, version, status, objectTypes, startMode,
      startCondition, steps, transitions, parameters, createdBy, activatedAt,
      archivedAt, createdAt, updatedAt
      FROM dbo.BusinessProcessTemplate`,
    viewQueryList: `SELECT * FROM dbo.BusinessProcessTemplate`,
    description: 'Process templates',
    icon: 'fas fa-file-alt',
    fields: [
      'id', 'code', 'description', 'active', 'version', 'status', 'objectTypes',
      'startMode', 'startCondition', 'steps', 'transitions', 'parameters', 'createdBy',
      'activatedAt', 'archivedAt', 'createdAt', 'updatedAt',
    ],
    searchFields: ['code', 'description', 'status', 'startMode', 'createdBy'],
    schema: {
      id: hiddenBusinessProcessListProp('string'),
      type: hiddenBusinessProcessListProp('string'),
      date: hiddenBusinessProcessListProp('datetime'),
      posted: hiddenBusinessProcessListProp('boolean'),
      deleted: hiddenBusinessProcessListProp('boolean'),
      timestamp: hiddenBusinessProcessListProp('datetime'),
      isfolder: hiddenBusinessProcessListProp('boolean'),
      code: businessProcessListProp('string', 'Code', 1, undefined, false, true),
      description: businessProcessListProp('string', 'Description', 2, undefined, false, true),
      active: businessProcessListProp('boolean', 'Active', 3, undefined, true),
      version: businessProcessListProp('number', 'Version', 4, undefined, true),
      status: {
        ...businessProcessListProp('enum', 'Status', 5,
          ['DRAFT', 'ACTIVE', 'ARCHIVED'], true),
        controlType: 'string',
      },
      objectTypes: businessProcessListProp('json', 'Object types', 6, undefined, false, true),
      startMode: businessProcessListProp('enum', 'Start mode', 7,
        ['MANUAL', 'ON_SAVE', 'ON_POST', 'ON_STATUS_CHANGE'], false, true),
      createdBy: businessProcessListProp('string', 'Created by', 8, undefined, true),
      activatedAt: businessProcessListProp('datetime', 'Activated at', 9, undefined, true),
      archivedAt: businessProcessListProp('datetime', 'Archived at', 10, undefined, true),
      createdAt: businessProcessListProp('datetime', 'Created at', 11, undefined, true),
      updatedAt: businessProcessListProp('datetime', 'Updated at', 12, undefined, true),
      startCondition: businessProcessPanelProp('json', 'Start condition', 1, 'Process map'),
      steps: {
        type: 'table', label: 'Steps', order: 2, panel: 'Process map', required: true, steps: {
          key: businessProcessListProp('string', 'Key', 1, undefined, false, true),
          title: businessProcessListProp('string', 'Title', 2, undefined, false, true),
          type: businessProcessListProp('enum', 'Type', 3,
            ['USER_TASK', 'SYSTEM_TASK', 'TIMER', 'AUTO'], false, true),
          dueRule: businessProcessListProp('json', 'Due rule', 4, undefined, false),
          penaltyRule: businessProcessListProp('json', 'Penalty rule', 5, undefined, false),
          waitUntilRule: businessProcessListProp('json', 'Wait until rule', 6, undefined, false),
          autoCompleteCondition: businessProcessListProp('json', 'Auto-complete condition', 7, undefined, false),
          allowRedirect: businessProcessListProp('boolean', 'Allow redirect', 8, undefined, false),
          allowDelegate: businessProcessListProp('boolean', 'Allow delegate', 9, undefined, false),
          rejectPolicy: businessProcessListProp('enum', 'Reject policy', 10,
            ['REJECT_PROCESS', 'RETURN_TO_PREVIOUS_STEP'], false),
        },
      },
      transitions: {
        type: 'table', label: 'Transitions', order: 3, panel: 'Process map', transitions: {
          key: businessProcessListProp('string', 'Key', 1, undefined, false, true),
          from: businessProcessListProp('string', 'From', 2, undefined, false, true),
          on: businessProcessListProp('enum', 'Event', 3,
            ['APPROVE', 'REJECT', 'TIMEOUT', 'AUTO'], false, true),
          to: businessProcessListProp('string', 'To', 4, undefined, false, true),
          condition: businessProcessListProp('json', 'Condition', 5, undefined, false),
        },
      },
      parameters: businessProcessPanelProp('json', 'Parameters', 4, 'Process map'),
      bpmnXml: hiddenBusinessProcessListProp('string'),
      visualMapping: hiddenBusinessProcessListProp('json'),
      addressing: {
        type: 'table', label: 'Assignments', order: 1, panel: 'Addressing', addressing: {
          stepKey: businessProcessListProp('string', 'Step key', 1, undefined, false, true),
          type: businessProcessListProp('enum', 'Assignment type', 2, [
            'FIXED_USER', 'ROLE', 'DOCUMENT_FIELD', 'RESPONSIBLE_PERSON',
            'AUTHOR', 'MANAGER_OF_AUTHOR',
          ], false, true),
          userId: businessProcessListProp('string', 'User ID', 3, undefined, false),
          role: businessProcessListProp('string', 'Role', 4, undefined, false),
          field: businessProcessListProp('string', 'Document field', 5, undefined, false),
        },
      },
    },
  },
);

function businessProcessListProp(
  type: string,
  label: string,
  order: number,
  value?: string[],
  readOnly: boolean = true,
  required: boolean = false,
): PropOptions {
  return { type, label, order, value, readOnly, required };
}

function businessProcessPanelProp(type: string, label: string, order: number, panel: string): PropOptions {
  return { type, label, order, panel, readOnly: false };
}

function hiddenBusinessProcessListProp(type: string, value?: any): PropOptions {
  return { type, value, hidden: true, hiddenInList: true, readOnly: true };
}

export async function BusinessProcessListViewModel(
  type: string,
  tx: MSSQL,
  id?: string,
): Promise<IViewModel> {
  const config = businessProcessListConfigs.get(type);
  if (!config) throw new Error(`Unsupported business process list type: ${type}`);

  const settings = new FormListSettings();
  const row = id
    ? await tx.oneOrNone<any>(`SELECT * FROM (${config.viewQueryList || config.queryList}) d WHERE d.id = @p1`, [id])
    : null;
  const model = row
    ? businessProcessListFormModel(type, row)
    : businessProcessListFormModel(type, { id });

  return {
    schema: config.schema,
    model: model || {},
    columnsDef: buildColumnDef(config.schema, settings),
    metadata: {
      type,
      description: config.description,
      menu: config.description,
      icon: config.icon,
    },
    settings,
  };
}

function businessProcessListFormModel(type: string, row: any) {
  const model = {
    ...row,
    id: row.id || null,
    type,
    date: row.createdAt || new Date(),
    posted: false,
    deleted: false,
    timestamp: row.updatedAt || null,
    isfolder: false,
  };

  if (type === 'BusinessProcess.Template') {
    model.active = row.active || false;
    model.version = row.version || 1;
    model.status = row.status || 'DRAFT';
    model.objectTypes = row.objectTypes || [];
    model.startMode = row.startMode || 'MANUAL';
    model.steps = businessProcessJsonArray(row.steps);
    model.transitions = businessProcessTransitionRows(row.transitions);
    model.addressing = model.steps
      .filter(step => step.assignmentRule)
      .map(step => ({ stepKey: step.key, ...step.assignmentRule }));
  }

  return model;
}

function businessProcessJsonArray(value: any): any[] {
  if (Array.isArray(value)) return value;
  if (typeof value !== 'string' || !value.trim()) return [];
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

function businessProcessTransitionRows(value: any): any[] {
  const transitions = businessProcessJsonArray(value);
  const usedKeys = new Set<string>();
  transitions.forEach(transition => {
    const key = transition && typeof transition.key === 'string' ? transition.key.trim() : '';
    if (key) usedKeys.add(key);
  });

  let sequence = 1;
  return transitions.map(transition => {
    if (!transition || typeof transition !== 'object') return transition;

    const currentKey = typeof transition.key === 'string' ? transition.key.trim() : '';
    if (currentKey) return { ...transition, key: currentKey };

    let key = `Transition_${sequence++}`;
    while (usedKeys.has(key)) key = `Transition_${sequence++}`;
    usedKeys.add(key);
    return { ...transition, key };
  });
}

/**
 * Returns business-process entities using the same paging contract as List.
 * These entities live outside Documents/configSchema and therefore need their
 * own query sources and field allowlists.
 */
export async function BusinessProcessList(
  params: DocListRequestBody & { used: string },
  tx: MSSQL,
): Promise<DocListResponse> {
  const config = businessProcessListConfigs.get(params.type);
  if (!config) throw new Error(`Unsupported business process list type: ${params.type}`);

  params.filter = (params.filter || [])
    .filter(el => !(el.right === null || el.right === undefined) || el.center === 'is null' || el.center === 'is not null');
  params.order = params.order || [];
  params.command = params.command || 'first';

  const allowedFields = new Set(config.fields);
  params.order.forEach(order => assertBusinessProcessListField(order.field, allowedFields));
  params.filter.forEach(filter => assertBusinessProcessListField(filter.left, allowedFields));

  const count = Math.max(0, Math.floor(Number(params.count) || 0));
  let row: any = null;
  if (params.id) {
    row = await tx.oneOrNone<any>(
      `SELECT * FROM (${config.queryList}) d WHERE d.id = @p1`,
      [params.id],
    );
  }
  if (!row && params.command !== 'last') params.command = 'first';
  if (row && (params.command === 'first' || params.command === 'last')) row = null;

  let valueOrder: { field: string, order: 'asc' | 'desc', value: any }[] = [];
  params.order.filter(el => el.order).forEach(el => {
    valueOrder.push({
      field: el.field,
      order: el.order || 'asc',
      value: row ? row[el.field] : '',
    });
  });

  const lastOrderAscending = valueOrder.length
    ? valueOrder[valueOrder.length - 1].order === 'asc'
    : true;
  valueOrder.push({
    field: 'id',
    order: lastOrderAscending ? 'asc' : 'desc',
    value: params.id,
  });

  const orderByBefore = buildBusinessProcessOrderBy(valueOrder, true);
  const orderByAfter = buildBusinessProcessOrderBy(valueOrder, false);
  valueOrder = valueOrder.filter(el => el.value !== null && el.value !== undefined);

  const queryFilter = await filterBuilder(params.filter, tx, params.type);
  if (config.companyField) {
    queryFilter.where += userContextFilter(tx.userContext, config.companyField);
  }

  const sqlParams: any[] = [];
  const addSqlParam = (value: any) => {
    sqlParams.push(value);
    return `@p${sqlParams.length}`;
  };
  const searchWhere = params.used
    ? ` AND (${config.searchFields
      .map(field => `CONVERT(NVARCHAR(MAX), "${field}") LIKE ${addSqlParam(`%${params.used}%`)}`)
      .join(' OR ')})`
    : '';
  const pagingParams = new Map<string, string>();
  const getPagingParam = (field: string, value: any) => {
    const existing = pagingParams.get(field);
    if (existing) return existing;
    const param = addSqlParam(value instanceof Date ? value.toJSON() : value);
    pagingParams.set(field, param);
    return param;
  };

  const queryBuilder = (isAfter: boolean) => {
    if (!valueOrder.length) return '';
    const order = valueOrder.slice();
    const direction = lastOrderAscending
      ? isAfter ? '>' : '<'
      : isAfter ? '<' : '>';
    let result = `SELECT TOP ${count + 1} id
      FROM (${config.queryList}) d
      WHERE ${queryFilter.where}${searchWhere} AND (`;

    valueOrder.forEach(() => {
      let where = '(';
      order.forEach(item => {
        const operator = item !== order[order.length - 1]
          ? '='
          : direction + (item.field === 'id' && isAfter ? '=' : '');
        where += ` "${item.field}" ${operator} ${getPagingParam(item.field, item.value)} AND`;
      });
      order.length--;
      result += `${where.slice(0, -4)}) OR\n`;
    });

    result = result.slice(0, -3) + `)\n${lastOrderAscending
      ? direction === '>' ? orderByAfter : orderByBefore
      : direction === '<' ? orderByAfter : orderByBefore}`;
    return result;
  };

  const queryBefore = queryBuilder(false);
  const queryAfter = queryBuilder(true);
  let query: string;
  if (queryBefore && queryAfter && row) {
    query = `${queryFilter.tempTable}
      SELECT * FROM (${config.queryList}) d WHERE id IN (
        SELECT id FROM (${queryBefore}) q1
        UNION ALL
        SELECT id FROM (${queryAfter}) q2
      ) ${orderByAfter}`;
  } else if (params.command === 'last') {
    query = `${queryFilter.tempTable}
      SELECT * FROM (
        SELECT TOP ${count + 1} * FROM (${config.queryList}) d
        WHERE ${queryFilter.where}${searchWhere} ${orderByBefore}
      ) d ${orderByAfter}`;
  } else {
    query = `${queryFilter.tempTable}
      SELECT TOP ${count + 1} * FROM (${config.queryList}) d
      WHERE ${queryFilter.where}${searchWhere} ${orderByAfter}`;
  }

  if (process.env.NODE_ENV !== 'production' && !ARGS.DISABLED_LIST_LOG) console.log(query);
  const data = await tx.manyOrNone<any>(query, sqlParams);
  data.forEach(item => item.type = params.type);
  return listPostProcess(data, params);
}

function buildBusinessProcessOrderBy(
  order: { field: string, order: 'asc' | 'desc' }[],
  reverse: boolean,
) {
  return ` ORDER BY ${order.map(item => {
    const ascending = item.order === 'asc';
    const direction = reverse ? !ascending : ascending;
    return `"${item.field}" ${direction ? 'ASC' : 'DESC'}`;
  }).join(', ')}`;
}

function assertBusinessProcessListField(field: string, allowedFields: Set<string>) {
  if (!allowedFields.has(field)) throw new Error(`Unknown business process list field: ${field}`);
}

export function isBusinessProcessListType(type: string) {
  return businessProcessListConfigs.has(type);
}

function isTypeListOperation(type: string) {
  return type === 'Catalog.Subcount';
}

function listPostProcess(data: any[], params: DocListRequestBody) {
  let result: any[] = [];
  const continuation = { first: null, last: null };
  const continuationIndex = data.findIndex(d => d.id === params.id);
  const pageSize = Math.min(data.length, params.count);
  switch (params.command) {
    case 'first':
      continuation.first = null;
      continuation.last = data[pageSize];
      result = data.slice(0, pageSize);
      break;
    case 'last':
      continuation.first = data[data.length - 1 - params.count];
      continuation.last = null;
      result = data.slice(-pageSize);
      break;
    default:
      const direction = params.command !== 'prev';
      if (direction) {
        continuation.first = data[continuationIndex - params.offset - 1];
        continuation.last = data[continuationIndex + pageSize - params.offset];
        result = data.slice(continuation.first ? continuationIndex - params.offset : 0, continuationIndex + pageSize - params.offset);
        if (result.length < pageSize) {
          const first = Math.max(continuationIndex - params.offset - (pageSize - result.length), 0);
          const last = Math.max(continuationIndex - params.offset + result.length, pageSize);
          continuation.first = data[first - 1];
          continuation.last = data[last + 1] || data[last];
          result = data.slice(first, last);
        }
      } else {
        continuation.first = data[continuationIndex - pageSize - params.offset];
        continuation.last = data[continuationIndex + 1 - params.offset];
        result = data.slice(continuation.first ?
          continuationIndex - pageSize + 1 - params.offset : 0, continuationIndex + 1 - params.offset);
        if (result.length < pageSize) {
          continuation.first = null;
          continuation.last = data[pageSize + 1];
          result = data.slice(0, pageSize);
        }
      }
  }
  result.length = Math.min(result.length, params.count);
  return { data: result, continuation: continuation };
}
