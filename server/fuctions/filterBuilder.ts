import { FormListFilter, FilterInterval } from 'jetti-middle';
import { v4 } from 'uuid';
import { AllDocTypes } from '../models/documents.types';
import { Global } from '../models/global';

export interface IQueryFilter {
  tempTable: string;
  where: string;
}

export interface IGroupFilter {
  group: 'OR' | 'AND';
  filters: FormListFilter[];
}

export const filterBuilder = (filter: FormListFilter[], nonQuotes = false): IQueryFilter => {

  let where = '';
  let tempTable = '';
  const tempTables: Map<string, string> = new Map;

  const filterList = filter
    .filter(el => !(el.right === null || el.right === undefined) || el.center === 'is null' || el.center === 'is not null')
    .map(f => ({ ...f, leftQ: nonQuotes ? `${f.left}` : `\"${f.left}\"` }));

  const OROrAND = (f: FormListFilter, index: number) => index ? f.isOR ? 'OR' : 'AND' : '';
  const tempTableName = (field: string) => `#${field}.${v4().toLocaleUpperCase().split('-')[0]}`;

  for (let i = 0; i < filterList.length; i++) {
    const f = filterList[i];
    switch (f.center) {
      case '=': case '>=': case '<=': case '>': case '<': case '<>':
        if (Array.isArray(f.right)) { // time interval
          if (f.right[0]) where += ` AND ${f.leftQ} >= '${f.right[0]}'`;
          if (f.right[1]) where += ` AND ${f.leftQ} <= '${f.right[1]}'`;
          break;
        }
        if (typeof f.right === 'string') f.right = f.right.toString().replace('\'', '\'\'');
        if (typeof f.right === 'number') { where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center} '${f.right}'`; break; }
        if (typeof f.right === 'boolean') { where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center} '${f.right}'`; break; }
        if (f.right instanceof Date) { where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center} N'${f.right.toJSON()}'`; break; }
        if (typeof f.right === 'object') {
          if (!f.right.id) where += ` ${OROrAND(f, i)} ${f.leftQ} IS NULL `;
          else where += ` ${OROrAND(f, i)} ${f.leftQ} = '${f.right.id}'`;
          // else if (!tempTable.includes(`[#${f.left}]`)) {
          //   tempTable += `SELECT id INTO [#${f.left}] FROM dbo.[Descendants]('${f.right.id}', '${f.right.type}');\n`;
          //   where += ` AND ${f.leftQ} IN (SELECT id FROM [#${f.left}])`;
          // }
          break;
        }
        if (!f.right) where += ` ${OROrAND(f, i)} ${f.leftQ} IS NULL `;
        else where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center} N'${f.right}'`;
        break;
      case 'like': case 'not like':
        where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center === 'like' ? '' : 'NOT'} LIKE N'%${(f.right['value'] || f.right).toString().replace('\'', '\'\'')}%' `;
        break;
      case 'start with':
        where += ` ${OROrAND(f, i)} ${f.leftQ} LIKE N'${(f.right['value'] || f.right).toString().replace('\'', '\'\'')}%' `;
        break;
      case 'end with':
        where += ` ${OROrAND(f, i)} ${f.leftQ} LIKE N'%${(f.right['value'] || f.right).toString().replace('\'', '\'\'')}' `;
        break;
      case 'matching':
        where += ` ${OROrAND(f, i)} ${f.leftQ} LIKE N'${(f.right['value'] || f.right).toString().replace('\'', '\'\'')}' `;
        break;
      case 'don\'t matching':
        where += ` ${OROrAND(f, i)} ${f.leftQ} NOT LIKE N'${(f.right['value'] || f.right).toString().replace('\'', '\'\'')}' `;
        break;
      case 'beetwen':
        if (Array.isArray(f.right)) {
          if (f.right[0] instanceof Date)
            where += ` AND ${f.leftQ} >= N'${f.right[0].toJSON()}' AND ${f.leftQ} <= N'${f.right[1].toJSON()}'`;
          else if (typeof f.right[0] === 'number') {
            if (f.right[0]) where += ` AND ${f.leftQ} >= '${f.right[0]}'`;
            if (f.right[1]) where += ` AND ${f.leftQ} <= '${f.right[1]}'`;
          }
        } else {
          const interval = f.right as FilterInterval;
          if (typeof interval.start === 'number') {
            where += ` ${OROrAND(f, i)} ${f.leftQ} >= '${interval.start}'`;
            where += ` ${OROrAND(f, i)} ${f.leftQ} <= '${interval.end}'`;
          } else if (interval.start)
            where += ` ${OROrAND(f, i)} ${f.leftQ} BEETWEN '${interval.start}' AND '${interval.end}' `;
        }
        break;
      case 'in group': case 'not in group':
        if (tempTables.get(f.left) !== f.right.id) {
          const ttName = tempTableName(f.left);
          tempTable += `SELECT id INTO [${ttName}] FROM dbo.[Descendants]('${f.right.id}', '${f.right.type}');\n`;
          where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center === 'in group' ? '' : 'NOT'} IN (SELECT id FROM [${ttName}])`;
        }
        break;
      case 'in': case 'not in':
        if (f.right['value'] || f.right)
          where += ` ${OROrAND(f, i)} ${f.leftQ} ${f.center === 'in' ? '' : 'NOT'} IN (${(f.right['value'] || f.right)}) `;
        break;
      case 'is null': case 'is not null':
        where += ` ${OROrAND(f, i)} ${f.leftQ} IS ${f.center === 'is null' ? '' : 'NOT'} NULL `;
        break;
    }
  }
  return { where: where || ' (1 = 1) ', tempTable: tempTable };
};

export const filterBuilderGroup = (groupFilter: IGroupFilter[], nonQuotes = false): IQueryFilter => {

  let where = '';
  let tempTable = '';

  for (const group of groupFilter) {
    const queryFilter = filterBuilder(group.filters, nonQuotes);
    where += ` ${group.group} (${queryFilter.where})`;
    tempTable += `\n${queryFilter.tempTable}`;
  }

  return { where: where, tempTable: tempTable };
};

export const filterBuilderConcat = (filters: IQueryFilter[]): IQueryFilter => {

  const result: IQueryFilter = {
    where: ' (1 = 1) ',
    tempTable: ''
  };

  for (const filter of filters) {
    result.where += `\n${filter.where}`;
    result.tempTable += `\n${filter.tempTable}`;
  }

  return result;
};
