import { DocTypes } from './../models/documents.types';
import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from './middleware/db-sessions';
import { filterBuilder, userContextFilter } from '../fuctions/filterBuilder';
import { createTypes, allTypes } from '../models/Types/Types.factory';
import { createDocument } from '../models/documents.factory';
import { FormListFilter, ISuggest, Type, DocumentOptions } from 'jetti-middle';
import { SQLGenegatorMetadata } from '../fuctions/SQLGenerator.MSSQL.Metadata';
import { ARCH_USER } from '../env/environment';

export const router = express.Router();

router.post('/suggest/:type', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdb = SDB(req);
    if (!req.query.filter) return [];
    const type = req.params.type as string;
    const filterLike = (req.query.filter as string || '').replace(/'/g, '');
    const filter = req.body.filters as FormListFilter[];
    const isDoc = Type.isDocument(type);

    const filterQuery = await filterBuilder(filter, sdb, type);
    let query = '';

    const queryWhere = () => isDoc ?
      `code LIKE N'${filterLike}%'`
      :
      `(description LIKE N'%${filterLike}%' OR code LIKE N'%${filterLike}%')`;

    const queryOrder = () => isDoc ? 
      `date desc`
      :
      `LEN([description]), type, description, deleted, code`;

    if (Type.isType(type)) {
      const select = createTypes(type as any).getTypes()
        .map(el => (
          {
            type: el,
            description: (createDocument(el as DocTypes).Prop() as DocumentOptions).description
          }));
      query = suggestQuery(select);
    } else if (type === 'Catalog.Subcount')
      query = suggestQuery(allTypes(), 'Catalog.Subcount');
    else {
      filterQuery.where += userContextFilter(sdb.userContext, type === 'Catalog.Company' ? 'id' : 'company');
      query = `${filterQuery.tempTable}
    SELECT top 10 id as id,
      description as value,
      code,
      description + ' (' + code + ')' as description,
      type,
      isfolder,
      deleted,
      IIF([user] = '${ARCH_USER}', CAST(1 AS bit), CAST(0 AS bit)) archived
    FROM [${type}.v] ${SQLGenegatorMetadata.noExpander(type)}
    WHERE ${filterQuery.where}`;
    }
    query += `AND ${queryWhere()}\nORDER BY ${queryOrder()}`;
    const data = await sdb.manyOrNone<ISuggest>(query, ['%' + filterLike + '%']);
    res.json(data);
  } catch (err) { next(err); }
});


export function suggestQuery(select: { type: string; description: string; }[], type = '') {
  let query = '';
  for (const row of select) {
    query += `SELECT
      N'${type ? row.description : ''}' "value",
      '${row.type}' AS "id",
      '${type || row.type}' "type",
      '${row.type}' "code",
      N'${row.description}' + ' ('+ '${row.type}' + ')' "description",
      CAST(1 AS BIT) posted,
      CAST(0 AS BIT) deleted,
      CAST(0 AS BIT) isfolder,
      NULL parent
      UNION ALL\n`;
  }
  query = `SELECT * FROM (${query.slice(0, -(`UNION ALL\n`).length)}) d WHERE (1=1)\n`;
  return query;
}
