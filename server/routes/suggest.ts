import { AllDocTypes, DocTypes } from './../models/documents.types';
import * as express from 'express';
import { NextFunction, Request, Response } from 'express';
import { SDB } from './middleware/db-sessions';
import { filterBuilder, filterBuilderConcat, filterBuilderGroup } from '../fuctions/filterBuilder';
import { createTypes, allTypes } from '../models/Types/Types.factory';
import { createDocument } from '../models/documents.factory';
import { FormListFilter, ISuggest, Type, DocumentOptions } from 'jetti-middle';
import { getPermissionQueryFilter } from '../fuctions/UsersPermissions';

export const router = express.Router();

router.post('/suggest/:type', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdb = SDB(req);
    const type = req.params.type as string;
    const filterLike = req.query.filter as string;
    const filter = req.body.filters as FormListFilter[];
    const queryOrder = 'type, description, deleted, code'.split(', ');
    let query = '';

    if (Type.isType(type)) {
      const select = createTypes(type as any).getTypes()
        .map(el => (
          {
            type: el,
            description: (createDocument(el as DocTypes).Prop() as DocumentOptions).description
          }));
      query = `
      ${suggestQuery(select)}
      AND (description LIKE @p1 OR code LIKE @p1)
      ORDER BY ${queryOrder.join(', ')}`;

    } else if (type === 'Catalog.Subcount')
      query = `
      ${suggestQuery(allTypes(), 'Catalog.Subcount')}
      AND (description LIKE @p1 OR code LIKE @p1)
      ORDER BY ${queryOrder.join(', ')}`;
    else {
      const filterQuery = filterBuilderConcat(
        [filterBuilderGroup([{ group: 'AND', filters: filter }]),
        await getPermissionQueryFilter({ type: type as AllDocTypes, tx: sdb, kind: 'list', user: sdb.userId() })]
      );
      //   query = `${filterQuery.tempTable}
      // SELECT top 10 id,
      //   description value,
      //   code,
      //   description + ' (' + code + ')' description,
      //   type,
      //   isfolder,
      //   deleted
      // FROM [${type}.v] WITH (NOEXPAND)
      // WHERE ${filterQuery.where}`;
      //   queryOrder.unshift('LEN([description])');
      // }
      // query += `
      // AND (description LIKE @p1 OR code LIKE @p1)
      // ORDER BY ${queryOrder.join(', ')}`;
      const shortType = type.replace('Catalog.', '').replace('Document.', '');
      queryOrder.unshift(`LEN([${shortType}])`);
      query = `${filterQuery.tempTable}
      SELECT TOP 10
        id,
        [${shortType}] value,
        code,
        [${shortType}]  + ' (' + code + ')' description,
        type,
        isfolder,
        deleted
      FROM [${type}]
      WHERE ${filterQuery.where}
      AND ([${shortType}] LIKE @p1 OR code LIKE @p1)
      ORDER BY ${queryOrder.join(', ')}`;
    }
    res.json(await sdb.manyOrNone<ISuggest>(query, [`%${filterLike}%`]));
  } catch (err) { next(err); }
});

function suggestQuery(select: { type: string; description: string; }[], type = '') {
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
