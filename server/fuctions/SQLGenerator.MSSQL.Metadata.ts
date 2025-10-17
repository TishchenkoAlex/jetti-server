// tslint:disable:max-line-length
// tslint:disable:no-shadowed-variable
// tslint:disable:forin

import { Global } from './../models/global';
import { CatalogOperationServer } from './../models/Catalogs/Catalog.Operation.server';
import { PrimitiveTypes, DocumentOptions, PropOptions, excludeRegisterAccumulatioProps, SQLGenegator, Type, excludeProps, DocumentBase } from 'jetti-middle';
import { createDocument, RegisteredDocuments } from '../models/documents.factory';
import { createRegisterAccumulation, RegisteredRegisterAccumulation } from '../models/Registers/Accumulation/factory';
import { createRegisterInfo, GetRegisterInfo } from '../models/Registers/Info/factory';
import { lib } from '../std.lib';
import { getIndexedOperationById, IIndexedOperation } from '../models/indexedOperation';
import { MSSQL } from '../mssql';


export class SQLGenegatorMetadata {

  static storedInTablesTypes = {};

  static typeSpliter(type: string, begin: boolean, length = 30) {
    return `\n${'-'.repeat(length)} ${begin ? 'BEGIN' : 'END'} ${type} ${'-'.repeat(length)}\n`;
  }

  static QueryRegisterAccumulationView(doc: { [x: string]: any }, type: string) {

    let select = ''; let fields = '';
    const simleProperty = (prop: string, type: string) => {
      switch (type) {
        case 'boolean': {
          return `
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;
        }
        case 'number': {
          fields += `, [${prop}.In], [${prop}.Out]`;
          return `
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, 1, -1) [${prop}]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, 1,  null) [${prop}.In]
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, null,  1) [${prop}.Out]`;
        }
        case 'date': {
          return `
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."${prop}"'),127) [${prop}]`;
        }
        case 'datetime': {
          return `
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."${prop}"'),127) [${prop}]`;
        }
        case 'enum': {
          return `
        , TRY_CONVERT(VARCHAR(150), JSON_VALUE(data, '$."${prop}"')) [${prop}]`;
        }
        default: {
          return `
        , TRY_CONVERT(NVARCHAR(36), JSON_VALUE(data, '$."${prop}"')) [${prop}]`;
        }
      }
    };

    const complexProperty = (prop: string, type: string) => `
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;

    for (const prop in excludeRegisterAccumulatioProps(doc)) {
      fields += `, [${prop}]`;
      const propType: string = doc[prop].type || 'string';
      if (propType.includes('.')) {
        select += complexProperty(prop, propType);
      } else {
        select += simleProperty(prop, propType);
      }
    }

    const query = `
    RAISERROR('${type} start', 0 ,1) WITH NOWAIT;
    GO
    CREATE OR ALTER VIEW [${type}.v] WITH SCHEMABINDING AS
    SELECT [id], [kind], [parent], CAST(date AS DATE) [date], [document], [company], [calculated]${select}
      FROM dbo.[Accumulation] WHERE [type] = N'${type}';
    GO
    CREATE UNIQUE CLUSTERED INDEX [${type}.id] ON [${type}.v]([id]);
    CREATE NONCLUSTERED COLUMNSTORE INDEX [${type}] ON [${type}.v]([date], [document], [company], [calculated], [parent]${fields});
    GO
    CREATE OR ALTER VIEW [${type}] AS SELECT * FROM [${type}.v] ${this.noExpander(type)};
    GO
    GRANT SELECT, DELETE ON [${type}] TO JETTI;
    GO
    GRANT SELECT ON [${type}] TO PUBLIC;
    GO
    RAISERROR('${type} finish', 0 ,1) WITH NOWAIT;
    GO
    `;
    return query;
  }

  static CreateRegisterAccumulationViewIndex() {
    let query = '';
    for (const type of RegisteredRegisterAccumulation) {
      const register = createRegisterAccumulation({ type: type.type });
      query += SQLGenegatorMetadata.QueryRegisterAccumulationView(register.Props(), register.Prop().type.toString());
    }
    query = `
    ${query}
    `;
    return query;
  }

  static QueryRegisterIntoView(doc: { [x: string]: PropOptions }, type: string) {

    const simleProperty = (prop: string, type: PrimitiveTypes) => {
      switch (type) {
        case 'boolean':
          return `
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;
        case 'number':
          return `
        , TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;
        case 'date':
          return `
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."${prop}"'),127) [${prop}]`;
        case 'time':
          return `
        , TRY_CONVERT(TIME, JSON_VALUE(data, N'$."${prop}"'),127) [${prop}]`;
        case 'datetime':
          return `
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."${prop}"'),127) [${prop}]`;
        case 'string': case 'enum':
          return `
        , TRY_CONVERT(NVARCHAR(128), JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;
        default:
          return `
        , JSON_VALUE(data, N'$."${prop}"') [${prop}]`;
      }
    };

    const complexProperty = (prop: string) => `
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."${prop}"')) [${prop}]`;

    let insert = ''; let select = ''; let fields = '';
    const Props = excludeRegisterAccumulatioProps(doc);
    for (const prop in Props) {
      fields += `[${prop}],`;
      const type = doc[prop].type || 'string';
      insert += `
        , "${prop}"`;
      if (type === 'number') {
        insert += `
        , "${prop}.In"
        , "${prop}.Out"`;
      }

      if (type.toLocaleString().includes('.')) {
        select += complexProperty(prop);
      } else {
        select += simleProperty(prop, type as PrimitiveTypes);
      }
    }

    const query = `
    CREATE OR ALTER VIEW [${type}]
    WITH SCHEMABINDING
    AS
    SELECT
      id, date, document, company${select}
      FROM dbo.[Register.Info] WHERE type = N'${type}';
    GO
    GRANT SELECT, DELETE ON [${type}] TO JETTI;
    GO
    GRANT SELECT ON [${type}] TO PUBLIC;
    GO
    CREATE UNIQUE CLUSTERED INDEX [${type}] ON [dbo].[${type}]([company], [date], [id])
    ${Object.keys(Props)
        .filter(key => Props[key].isIndexed)
        .map(key => `CREATE NONCLUSTERED INDEX[${type}.${key}] ON [${type}]([${key}]);`)
        .join('\n    ')}
    GO`;
    return query;
  }

  static CreateRegisterInfoViewIndex() {
    let query = '';
    for (const type of GetRegisterInfo()) {
      const register = createRegisterInfo({ type: type.type });
      query += this.typeSpliter(type.type, true);
      query += SQLGenegatorMetadata.QueryRegisterIntoView(register.Props(), register.Prop().type.toString());
      query += this.typeSpliter(type.type, false);
    }
    return query;
  }

  static async CreateViewOperations() {

    const operations = Global.indexedOperations();
    let query = '';

    for (const operation of operations) {
      const indexedOperation = getIndexedOperationById(operation[0]);
      if (!indexedOperation) continue;
      query += `${this.typeSpliter(indexedOperation.type, true)}
      ${this.CreateViewOperation(indexedOperation)}
      ${this.typeSpliter(indexedOperation.type, false)}`;
    }
    return query;
  }

  static noExpander = (type: string) => SQLGenegator.storedInTablesTypes[type] ? '' : 'WITH (NOEXPAND)';

  static CreateViewOperation(operation: IIndexedOperation, asArrayOfQueries = false) {

    const subQueries: string[] = [];
    const type = operation.type as string;
    let select = Global.configSchema().get(operation.type)!.QueryList;
    select = select
      .replace('d.description,', `d.description "${operation.shortName.trim()}", `);

    subQueries.push(`CREATE OR ALTER VIEW dbo.[${type}] AS
      ${select}; `);

    subQueries.push(`GRANT SELECT ON dbo.[${type}] TO jetti;`);
    subQueries.push(`GRANT SELECT ON dbo.[${type}] TO PUBLIC;`);
    subQueries.push('');

    return asArrayOfQueries ? subQueries : subQueries.join('\nGO\n');
  }

  static async CreateViewOperationsIndex(withSecurityPolicy = false) {

    const tx = lib.util.jettiPoolTx();
    const operations = Global.indexedOperations();
    let query = '';

    for (const operation of operations) {
      const indexedOperation = getIndexedOperationById(operation[0]);
      if (!indexedOperation) continue;
      query += `${this.typeSpliter(indexedOperation.type, true)}
      RAISERROR('${indexedOperation.type} start', 0 ,1) WITH NOWAIT;
      ${await this.CreateViewOperationIndex(indexedOperation, tx, false, withSecurityPolicy)}
      RAISERROR('${indexedOperation.type} finish', 0 ,1) WITH NOWAIT;
      ${this.typeSpliter(indexedOperation.type, true)}
      `;
    }

    return query;
  }

  static async CreateViewOperationIndex(operation: IIndexedOperation, tx: MSSQL, asArrayOfQueries = false, withSecurityPolicy = true) {

    const subQueries: string[] = [];
    const type = operation.type as string;
    const doc = await lib.doc.createDocServer<CatalogOperationServer>('Catalog.Operation', { id: operation.id, Operation: operation.id } as any, tx);
    const Props = (await doc.getPropsFunc(tx))();
    const select = SQLGenegator.QueryListRaw(Props, type)
      .replace(`WHERE [type] = N'${type}'`, `WHERE [operation] = '${operation.id}'`);

    if (withSecurityPolicy)
      subQueries.push(`
      BEGIN TRY
        ALTER SECURITY POLICY[rls].[companyAccessPolicy] DROP FILTER PREDICATE ON[dbo].[${type}.v];
      END TRY
      BEGIN CATCH
      END CATCH`);

    subQueries.push(`CREATE OR ALTER VIEW dbo.[${type}.v] WITH SCHEMABINDING AS ${select}; `);

    subQueries.push(`CREATE UNIQUE CLUSTERED INDEX [${type}.v] ON [${type}.v](id);
      CREATE UNIQUE NONCLUSTERED INDEX[${type}.v.date] ON[${type}.v](date, id) INCLUDE([company]);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.parent] ON [${type}.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code] ON [${type}.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.user] ON [${type}.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.company] ON [${type}.v](company,id);
      ${Object.keys(Props)
        .filter(key => Props[key].isIndexed)
        .map(key => `CREATE UNIQUE NONCLUSTERED INDEX[${type}.v.${key}] ON[${type}.v](${key}, id) INCLUDE([company]);`)
        .join('\n')}`);

    subQueries.push(`GRANT SELECT ON dbo.[${type}.v]TO jetti; `);
    subQueries.push(`GRANT SELECT ON dbo.[${type}.v]TO PUBLIC; `);

    if (withSecurityPolicy)
      subQueries.push(`ALTER SECURITY POLICY[rls].[companyAccessPolicy]
      ADD FILTER PREDICATE[rls].[fn_companyAccessPredicate]([company]) ON[dbo].[${type}.v];`);

    return asArrayOfQueries ? subQueries : subQueries.join('\nGO\n');
  }


  static CreateViewCatalogs(dynamic = false) {
    let query = `CREATE OR ALTER VIEW[dbo].[Catalog.Documents] AS
    SELECT
    'https://x100-jetti.web.app/' + d.type + '/' + TRY_CONVERT(varchar(36), d.id) as link,
      d.id, d.date[date],
      d.description Presentation,
        d.info,
        d.type, CAST(JSON_VALUE(doc, N'$.DocReceived') as bit) DocReceived
    FROM dbo.[Documents] d
    GO
    GRANT SELECT ON[dbo].[Catalog.Documents] TO jetti;
    GO`;
    const registeredCatalogs = [...RegisteredDocuments().values()].filter(e => !Type.isOperation(e.type) && e.dynamic === dynamic);
    for (const registeredCatalog of registeredCatalogs) {
      query += `
      ${this.typeSpliter(registeredCatalog.type, true)}
      ${this.CreateViewCatalog(registeredCatalog.type)}
      ${this.typeSpliter(registeredCatalog.type, false)}
      `;
    }

    return query;
  }

  static CreateViewCatalog(type: string, asArrayOfQueries = false) {

    const subQueries: string[] = [];
    const doc = createDocument(type);
    if (!doc['QueryList']) {
      const Props = doc.Props();
      const type = (doc.Prop() as DocumentOptions).type;
      let select = SQLGenegator.QueryList(Props, doc.type);
      const typeSplit = type.split('.');
      let name = '';
      for (let i = 1; i < typeSplit.length; i++) name += typeSplit[i];
      select = select.replace(`FROM [${type}.v] d ${this.noExpander(type)}`, `
        , ISNULL(l5.id, d.id) [${name}.Level5.id]
        , ISNULL(l4.id, ISNULL(l5.id, d.id)) [${name}.Level4.id]
        , ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))) [${name}.Level3.id]
        , ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id)))) [${name}.Level2.id]
        , ISNULL(l1.id, ISNULL(l2.id, ISNULL(l3.id, ISNULL(l4.id, ISNULL(l5.id, d.id))))) [${name}.Level1.id]
        , ISNULL(l5.description, d.description) [${name}.Level5]
        , ISNULL(l4.description, ISNULL(l5.description, d.description)) [${name}.Level4]
        , ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))) [${name}.Level3]
        , ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description)))) [${name}.Level2]
        , ISNULL(l1.description, ISNULL(l2.description, ISNULL(l3.description, ISNULL(l4.description, ISNULL(l5.description, d.description))))) [${name}.Level1]
      FROM [${type}.v] d ${this.noExpander(type)}
        LEFT JOIN [${type}.v] l5 ${this.noExpander(type)} ON (l5.id = d.parent)
        LEFT JOIN [${type}.v] l4 ${this.noExpander(type)} ON (l4.id = l5.parent)
        LEFT JOIN [${type}.v] l3 ${this.noExpander(type)} ON (l3.id = l4.parent)
        LEFT JOIN [${type}.v] l2 ${this.noExpander(type)} ON (l2.id = l3.parent)
        LEFT JOIN [${type}.v] l1 ${this.noExpander(type)} ON (l1.id = l2.parent)
      `).replace('d.description,', `d.description "${name}",`);

      subQueries.push(`
      CREATE OR ALTER VIEW dbo.[${type}] AS
        ${select};`);
      subQueries.push(`GRANT SELECT ON dbo.[${type}] TO jetti;`);
      subQueries.push(`GRANT SELECT ON dbo.[${type}] TO PUBLIC;`);
      subQueries.push('');
    }

    return asArrayOfQueries ? subQueries : subQueries.join('\nGO\n');
  }

  static CreateViewCatalogsIndex(withSecurityPolicy = false, dynamic = false) {

    const delSpaces = (s: string) => s.split('\n').map(e => e.trim()).join('\n');

    const registeredCatalogs = [...RegisteredDocuments().values()]
      .filter(e => !Type.isOperation(e.type) && e.dynamic === dynamic);

    let query = '';

    for (const cat of registeredCatalogs) {
      const doc = createDocument(cat.type);
      if (doc['QueryList']) continue;
      query += `
    ${this.typeSpliter(cat.type, true)}
    RAISERROR('${cat.type} start', 0 ,1) WITH NOWAIT;
    ${this.CreateViewCatalogIndex(cat.type, withSecurityPolicy)}
    RAISERROR('${cat.type} end', 0 ,1) WITH NOWAIT;
    ${this.typeSpliter(cat.type, false)}`;
    }

    query += `
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Amount] ON [Document.Operation.v](Amount,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group] ON [dbo].[Document.Operation.v]([Group],[date],[id]);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.user] ON [dbo].[Document.Operation.v]([user],[Group],[date],[id]);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Operation] ON [Document.Operation.v](Operation,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.currency] ON [Document.Operation.v](currency,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f1] ON [Document.Operation.v](f1,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f2] ON [Document.Operation.v](f2,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f3] ON [Document.Operation.v](f3,id);
    CREATE NONCLUSTERED INDEX [Document.Operation.v.timestamp] ON [Document.Operation.v]([timestamp],[Operation]);

    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Amount.rls] ON [Document.Operation.v](company,Amount,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.rls] ON [dbo].[Document.Operation.v](company,[Group],[date],[id]);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Group.user.rls] ON [dbo].[Document.Operation.v](company,[user],[Group],[date],[id]);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.Operation.rls] ON [Document.Operation.v](company,Operation,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.currency.rls] ON [Document.Operation.v](company,currency,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f1.rls] ON [Document.Operation.v](company,f1,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f2.rls] ON [Document.Operation.v](company,f2,id);
    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.f3.rls] ON [Document.Operation.v](company,f3,id);

    CREATE UNIQUE NONCLUSTERED INDEX [Document.Operation.v.CompanyGroup] ON [dbo].[Document.Operation.v]([company],[Group],[date],[id])INCLUDE([deleted])
    `;

    return delSpaces(query);
  }


  static CreateViewCatalogIndex(type: string, withSecurityPolicy = true, asArrayOfQueries = false) {

    const querySpliter = '\nGO\n';
    let query = '';
    const result = () => asArrayOfQueries ? query.split(querySpliter) : query;

    const queryAdd = (subQuery: string, before = '\n', after = querySpliter) => query += subQuery && `${before}${subQuery.trim()}${after}`;

    const doc = createDocument(type);
    if (doc['QueryList']) return result();

    queryAdd(`DROP TABLE IF EXISTS dbo.[${type}.v]`, '');
    queryAdd(`DROP TRIGGER IF EXISTS dbo.[${type}.t]`);

    if (withSecurityPolicy)
      queryAdd(`
      BEGIN TRY
        ALTER SECURITY POLICY[rls].[companyAccessPolicy] DROP FILTER PREDICATE ON[dbo].[${type}.v];
      END TRY
      BEGIN CATCH
      END CATCH;`);

    const Props = doc.Props();
    const select = SQLGenegator.QueryListRaw(Props, doc.type);
    queryAdd(`CREATE OR ALTER VIEW dbo.[${type}.v] WITH SCHEMABINDING AS
    ${select.trim()};`);

    // INDEX SECTION BEGIN
    queryAdd(`CREATE UNIQUE CLUSTERED INDEX [${type}.v] ON [${type}.v](id);`, undefined, '');

    const addIndex = (column: string, name: string, includeColumns: string[]) =>
      `CREATE NONCLUSTERED INDEX [${name}] ON [${type}.v]([${column}]) INCLUDE(${includeColumns.map(e => `[${e}]`).join(',')});`;

    const unique = Object.keys(Props).filter(key => Props[key].isUnique).map(key => key);
    const indexed = Object.keys(Props).filter(key => Props[key].isUnique).map(key => key);

    const uniqueIndex = unique.map(column => addIndex(column, `${type}.v.${column}.u`, ['company', 'description', 'id'])).join('\n');
    const indexedIndex = indexed.map(column => addIndex(column, `${type}.v.${column}.c`, ['company'])).join('\n');

    queryAdd(uniqueIndex, undefined, '');
    queryAdd(indexedIndex, undefined, '');


    if (Type.isDocument(type))
      queryAdd(`
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.date] ON [${type}.v](date,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.parent] ON [${type}.v](parent,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,date,id);`, undefined, '');
    else
      queryAdd(`
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code.f] ON [${type}.v](parent,isfolder,code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description.f] ON [${type}.v](parent,isfolder,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description] ON [${type}.v](description,id);`, undefined, '');

    queryAdd(`
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code] ON [${type}.v](code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.user] ON [${type}.v]([user],id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.company] ON [${type}.v](company,id);`, undefined);
    // INDEX SECTION END

    queryAdd(`GRANT SELECT ON dbo.[${type}.v] TO jetti;`, undefined, '');
    queryAdd(`GRANT SELECT ON dbo.[${type}.v] TO PUBLIC;`, undefined, '');

    if (withSecurityPolicy)
      queryAdd(`ALTER SECURITY POLICY[rls].[companyAccessPolicy] ADD FILTER PREDICATE [rls].[fn_companyAccessPredicate]([company]) ON[dbo].[${type}.v];`);

    return result();

  }

  static CreateViewCatalogIndexOLD(type: string, withSecurityPolicy = true, asArrayOfQueries = false) {
    const subQueries: string[] = [];
    const doc = createDocument(type);
    if (!doc['QueryList']) {
      const Props = doc.Props();
      const select = SQLGenegator.QueryListRaw(Props, doc.type);
      subQueries.push(`DROP TABLE IF EXISTS dbo.[${type}.v]`);
      subQueries.push(`DROP TRIGGER IF EXISTS dbo.[${type}.t]`);
      if (withSecurityPolicy)
        subQueries.push(`
      BEGIN TRY
        ALTER SECURITY POLICY[rls].[companyAccessPolicy] DROP FILTER PREDICATE ON[dbo].[${type}.v];
      END TRY
      BEGIN CATCH
      END CATCH;`);
      subQueries.push(`CREATE OR ALTER VIEW dbo.[${type}.v] WITH SCHEMABINDING AS${select};`);
      subQueries.push(`CREATE UNIQUE CLUSTERED INDEX [${type}.v] ON [${type}.v](id);${Object.keys(Props)
        .filter(key => Props[key].isIndexed)
        .map(key => `CREATE NONCLUSTERED INDEX[${doc.type}.v.${key}] ON [${doc.type}.v]([${key}]) INCLUDE([company]);`)
        .join('\n')
        }
        ${Type.isDocument(doc.type) ? `
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.date] ON [${type}.v](date,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.parent] ON [${type}.v](parent,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,date,id);` : `
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,description,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code.f] ON [${type}.v](parent,isfolder,code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description.f] ON [${type}.v](parent,isfolder,description,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description] ON [${type}.v](description,id);`}
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code] ON [${type}.v](code,id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.user] ON [${type}.v]([user],id);
      CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.company] ON [${type}.v](company,id);`);

      subQueries.push(`GRANT SELECT ON dbo.[${type}.v]TO jetti;`);

      if (withSecurityPolicy)
        subQueries.push(`
      ALTER SECURITY POLICY [rls].[companyAccessPolicy] ADD FILTER PREDICATE [rls].[fn_companyAccessPredicate]([company]) ON [dbo].[${type}.v];`);
    }

    return asArrayOfQueries ? subQueries : subQueries.join(`\nGO\n`);

  }

  static CreateDocumentIndexes() {

    const types = {
      catalogs: [...RegisteredDocuments().values()].filter(t => Type.isCatalog(t.type)),
      documents: [...RegisteredDocuments().values()].filter(t => Type.isDocument(t.type))
    };

    // const registeredCatalogs = ;
    // const allTypes = lib.util.groupArray<any>(registeredDocuments, 'type').sort();
    // const allCatalogs = registeredCatalogs.sort();

    let select = '';
    for (const catalog of types.catalogs) {
      const doc = createDocument(catalog.type);
      if (doc['QueryList']) continue;
      select += `
    DROP INDEX IF EXISTS [${catalog.type}] ON Documents;
    CREATE UNIQUE NONCLUSTERED INDEX [${catalog.type}]
    ON [dbo].[Documents]([description],[id],[parent])
    INCLUDE([posted],[deleted],[isfolder],[date],[code],[doc],[user],[info],[timestamp],[ExchangeCode],[ExchangeBase],[type],[company])
    WHERE ([type]='${catalog.type}')`;
    }
    for (const document of types.documents) {
      select += `
    DROP INDEX IF EXISTS [${document.type}] ON Documents;
    CREATE UNIQUE NONCLUSTERED INDEX [${document.type}]
    ON [dbo].[Documents]([date],[id],[parent])
    INCLUDE([posted],[deleted],[isfolder],[description],[code],[doc],[user],[info],[timestamp],[ExchangeCode],[ExchangeBase],[type],[company])
    WHERE ([type]='${document.type}')`;
    }
    return select;
  }

  static CreateTableRegisterAccumulationTO() {

    const simleProperty = (prop: string, type: string) => {
      if (type.includes('.')) return `
        , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(data, N'$."${prop}"')) AS [${prop}]`;
      if (type === 'number') {
        return `
        , SUM(ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, 1, -1), 0)) [${prop}]
        , SUM(ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, 1, null), 0)) [${prop}.In]
        , SUM(ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(data, N'$."${prop}"')) * IIF(kind = 1, null, 1), 0)) [${prop}.Out]`;
      }
      if (type === 'boolean') return `
        , TRY_CONVERT(BIT, JSON_VALUE(data, N'$."${prop}"')) AS [${prop}]`;
      if (type === 'datetime') return `
        , TRY_CONVERT(DATETIME, JSON_VALUE(data, N'$."${prop}"'),127) AS [${prop}]`;
      if (type === 'date') return `
        , TRY_CONVERT(DATE, JSON_VALUE(data, N'$."${prop}"'),127) AS [${prop}]`;
      return `
        , TRY_CONVERT(VARCHAR(36), JSON_VALUE(data, N'$."${prop}"')) AS [${prop}]`;
    };

    let query = '';
    for (const register of RegisteredRegisterAccumulation) {
      const doc = createRegisterAccumulation({ type: register.type });
      const props = doc.Props();
      let select = ''; let groupBy = ''; let indexGroupBy = '';
      for (const prop in excludeRegisterAccumulatioProps(doc)) {
        const dimension = !!props[prop].dimension;
        const resource = !!props[prop].resource;
        const type = props[prop].type || 'string';
        const field = simleProperty(prop, type) || '';
        if (dimension) {
          groupBy += field.slice(0, field.indexOf(' AS ['));
          indexGroupBy += `, [${prop}]`;
        }
        if (dimension || resource) select += field;
      }

      query += `\n
      RAISERROR('${register.type} start', 0 ,1) WITH NOWAIT;
      GO
      CREATE OR ALTER VIEW [dbo].[${register.type}.TO.v] WITH SCHEMABINDING AS
      SELECT
          DATEADD(DAY, 1, CAST(EOMONTH([date], -1) AS DATE)) [date]
        , [company]${select}
        , COUNT_BIG(*) AS COUNT
      FROM [dbo].[Accumulation] WHERE [type] = N'${register.type}'
      GROUP BY
          DATEADD(DAY, 1, CAST(EOMONTH([date], -1) AS DATE))
        , [company]${groupBy}
      GO
      CREATE UNIQUE CLUSTERED INDEX [${register.type}.TO] ON [dbo].[${register.type}.TO.v] ([date], [company]${indexGroupBy});
      GO
      CREATE OR ALTER VIEW [dbo].[${register.type}.TO] AS SELECT * FROM [dbo].[${register.type}.TO.v] WITH (NOEXPAND);
      GO
      GRANT SELECT ON [dbo].[${register.type}.TO] TO jetti;
      GO
      RAISERROR('${register.type} end', 0 ,1) WITH NOWAIT;
      GO`;
    }

    return query;
  }

  static CreateTableRegisterAccumulationTOv2() {

    const simleProperty = (prop: string, type: string) => {
      if (type === 'number') {
        return `
        , SUM(ISNULL([${prop}], 0)) [${prop}]
        , SUM(ISNULL([${prop}.In], 0)) [${prop}.In]
        , SUM(ISNULL([${prop}.Out], 0)) [${prop}.Out]`;
      }
      return `
        , [${prop}]`;
    };

    let query = '';
    for (const register of RegisteredRegisterAccumulation) {
      const doc = createRegisterAccumulation({ type: register.type });
      const props = doc.Props();
      let select = ''; let groupBy = '';
      for (const prop in excludeRegisterAccumulatioProps(doc)) {
        const dimension = !!props[prop].dimension;
        const resource = !!props[prop].resource;
        const type = props[prop].type || 'string';
        const field = simleProperty(prop, type) || '';
        if (dimension) {
          groupBy += field;
        }
        if (dimension || resource) select += field;
      }

      query += `\n
      RAISERROR('${register.type} start', 0 ,1) WITH NOWAIT;
      GO
      CREATE OR ALTER VIEW [dbo].[${register.type}.TO.v] WITH SCHEMABINDING AS
      SELECT
          DATEADD(DAY, 1, CAST(EOMONTH([date], -1) AS DATE)) [date]
        , [company]${select}
        , COUNT_BIG(*) AS COUNT
      FROM [dbo].[${register.type}]
      GROUP BY
          DATEADD(DAY, 1, CAST(EOMONTH([date], -1) AS DATE))
        , [company]${groupBy}
      GO
      CREATE UNIQUE CLUSTERED INDEX [${register.type}.TO] ON [dbo].[${register.type}.TO.v] (
          [date],
          [company]${groupBy});
      GO
      CREATE OR ALTER VIEW [dbo].[${register.type}.TO] AS SELECT * FROM [dbo].[${register.type}.TO.v] WITH (NOEXPAND);
      GO
      GRANT SELECT ON [dbo].[${register.type}.TO] TO jetti;
      GO
      GRANT SELECT ON [dbo].[${register.type}.TO] TO PUBLIC;
      GO
      RAISERROR('${register.type} end', 0 ,1) WITH NOWAIT;
      GO`;
    }

    return query;
  }

  static QueryListRaw(doc: DocumentBase, type: string) {

    const simleProperty = (prop: string, type: string, maxLength: number | undefined) => {
      if (type === 'boolean') return `
      , ISNULL(TRY_CONVERT(BIT, JSON_VALUE(doc,N'$."${prop}"')), 0) [${prop}]`;
      if (type === 'number') return `
      , ISNULL(TRY_CONVERT(MONEY, JSON_VALUE(doc,N'$."${prop}"')), 0) [${prop}]`;
      if (type === 'date') return `
      , TRY_CONVERT(DATE, JSON_VALUE(doc,N'$."${prop}"'),127) [${prop}]`;
      if (type === 'datetime') return `
      , TRY_CONVERT(DATETIME, JSON_VALUE(doc,N'$."${prop}"'),127) [${prop}]`;
      if (type === 'enum') return `
      , ISNULL(TRY_CONVERT(NVARCHAR(150), JSON_VALUE(doc,N'$."${prop}"')), '') [${prop}]`;
      if (type === 'string') return `
      , ISNULL(TRY_CONVERT(NVARCHAR(${maxLength ?? 150}), JSON_VALUE(doc, N'$."${prop}"')), '') [${prop}]`;
      if (type.includes('.')) return `
      , TRY_CONVERT(UNIQUEIDENTIFIER, JSON_VALUE(doc, N'$."${prop}"')) [${prop}]`;
      return `
      , ISNULL(TRY_CONVERT(NVARCHAR(250), JSON_VALUE(doc,N'$."${prop}"')), '') [${prop}]`;
    };

    let query = ``;
    const columns = this.getDocColumns(doc);
    const docProps = doc.Props();
    for (const prop of columns.special) {
      const type = docProps[prop].type || 'string';
      query += simleProperty(prop, type, docProps[prop].maxLength);
    }

    query = `
      SELECT ${columns.common.map(e => `[${e}]`).join(',')}, [version]${query}
`;

    return query;
  }

  static getDocColumns(doc: DocumentBase) {
    const excludedProps = Type.isOperation(doc.type) ? ['f1', 'f2', 'f3'] : [];
    const docProps = doc.Props();
    const docPropsKeys = Object.keys(docProps);
    const special = Object.keys(excludeProps(doc))
      .filter(prop => !excludedProps.includes(prop) && docPropsKeys.includes(prop) && docProps[prop].type !== 'table');
    return { special, common: `id,type,date,code,description,posted,deleted,isfolder,timestamp,parent,company,user`.split(',') };
  }

  static CatalogsTablesAndTriggers(dynamic = false) {

    const inTables = Global.storedInTablesTypes();
    const registeredCatalogs = [...RegisteredDocuments().values()]
      .filter(e => !!inTables[e.type] && !Type.isOperation(e.type));

    let query = '';

    for (const registeredCatalog of registeredCatalogs) {
      const doc = createDocument(registeredCatalog.type);
      query += `${this.typeSpliter(registeredCatalog.type, true)}
      RAISERROR('${registeredCatalog.type} start', 0 ,1) WITH NOWAIT;
      GO
      ${this.CatalogTableAndTrigger(doc, registeredCatalog.type)}
      RAISERROR('${registeredCatalog.type} end', 0 ,1) WITH NOWAIT;
      ${this.typeSpliter(registeredCatalog.type, false)}`;
    }

    return query;
  }

  static CatalogTableAndTrigger(doc: DocumentBase, type: string, asArrayOfQueries = false) {

    const ql = this.QueryListRaw(doc, type);
    const props = doc.Props();
    const queries: string[] = [];
    const columns = this.getDocColumns(doc);
    const allColumns = [...columns.common, ...columns.special].map(e => `[${e}]`).join(',');
    const indexedColumns = [...new Set(Object.keys(props).filter(key => props[key].isIndexed || props[key].isUnique).map(key => key))];
    queries.push(`
    CREATE OR ALTER TRIGGER [${type}.t] ON [Documents] AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
      SET NOCOUNT ON;
      DECLARE @COUNT_D BIGINT = (SELECT COUNT(*) FROM deleted WHERE type = N'${type}');
      IF (@COUNT_D) > 1 DELETE FROM [${type}.v] WHERE id IN (SELECT id FROM deleted WHERE type = N'${type}');
      IF (@COUNT_D) = 1 DELETE FROM [${type}.v] WHERE id = (SELECT id FROM deleted WHERE type = N'${type}');
      IF (SELECT COUNT(*) FROM inserted WHERE type = N'${type}') = 0 RETURN;

      INSERT INTO [${type}.v] (${allColumns})
    ${ql.replace(', [version]', '')}
    FROM inserted r
    WHERE [type] = N'${type}'
    END`);

    queries.push(`
    DROP TABLE IF EXISTS [${type}.v];
    DROP VIEW IF EXISTS [${type}.v];`);

    queries.push(`
    ${ql}
    INTO [${type}.v]
    FROM [Documents] r
    WHERE r.type = N'${type}';`);

    queries.push(`
    GRANT SELECT,INSERT,DELETE ON [${type}.v] TO JETTI;`);

    queries.push(`
    GRANT SELECT ON [${type}.v] TO PUBLIC;`);

    queries.push(`
    ALTER TABLE [${type}.v] ADD CONSTRAINT [PK_${type}.v] PRIMARY KEY NONCLUSTERED ([id]);
    CREATE UNIQUE CLUSTERED INDEX [${type}.v] ON [${type}.v](id);${indexedColumns
        .map(key => `CREATE NONCLUSTERED INDEX[${type}.v.${key}] ON [${doc.type}.v]([${key}]) INCLUDE([company]);`)
        .join('\n')
      }
      ${Type.isDocument(type) ? `
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.date] ON [${type}.v](date,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.parent] ON [${type}.v](parent,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,date,id);` : `
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.deleted] ON [${type}.v](deleted,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code.f] ON [${type}.v](parent,isfolder,code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description.f] ON [${type}.v](parent,isfolder,description,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.description] ON [${type}.v](description,id);`}
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.code] ON [${type}.v](code,id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.user] ON [${type}.v]([user],id);
    CREATE UNIQUE NONCLUSTERED INDEX [${type}.v.company] ON [${type}.v](company,id);`);

    return asArrayOfQueries ? queries : queries.join(`\t\nGO\n`);
  }

  // TODO add drop TO, drop first, then create table, then create trigger
  static RegisterAccumulationClusteredTable(doc: { [x: string]: any }, type: string) {

    const simleProperty = (prop: string, type: string) => {
      if (type === 'boolean') {
        return `
        , [${prop}] BIT N'$.${prop}'`;
      }
      if (type === 'number') {
        return `
        , [${prop}] MONEY N'$.${prop}'`;
      }
      if (type === 'date') {
        return `
        , [${prop}] DATE N'$.${prop}'`;
      }
      if (type === 'datetime') {
        return `
        , [${prop}] DATETIME N'$.${prop}'`;
      }
      return `
        , [${prop}] NVARCHAR(250) N'$.${prop}'`;
    };

    const complexProperty = (prop: string, type: string) => `
        , [${prop}] UNIQUEIDENTIFIER N'$.${prop}'`;

    let insert = ''; let select = ''; let fields = ''; let columns = '';
    for (const prop in excludeRegisterAccumulatioProps(doc)) {
      const type: string = doc[prop].type || 'string';
      columns += `, [${prop}]`;
      if (type === 'number') {
        columns += `, [${prop}.In], [${prop}.Out]`;
        fields += `
      , d.[${prop}] * IIF(r.kind = 1, 1, -1) [${prop}], d.[${prop}] * IIF(r.kind = 1, 1, null) [${prop}.In], d.[${prop}] * IIF(r.kind = 1, null, 1) [${prop}.Out]`;
      } else fields += `, [${prop}]`;

      insert += `
        , "${prop}"`;
      if (type === 'number') {
        insert += `
        , "${prop}.In"
        , "${prop}.Out"`;
      }

      if (type.includes('.')) {
        select += complexProperty(prop, type);
      } else {
        select += simleProperty(prop, type);
      }
    }

    const query = `
    RAISERROR('${type} start', 0 ,1) WITH NOWAIT;
    GO
    CREATE OR ALTER TRIGGER [${type}.t] ON [Accumulation] AFTER INSERT, UPDATE, DELETE
    AS
    BEGIN
      SET NOCOUNT ON;
      DECLARE @COUNT_D BIGINT = (SELECT COUNT(*) FROM deleted WHERE type = N'${type}');
      IF (@COUNT_D) > 1 DELETE FROM [${type}] WHERE id IN (SELECT id FROM deleted WHERE type = N'${type}');
      IF (@COUNT_D) = 1 DELETE FROM [${type}] WHERE id = (SELECT id FROM deleted WHERE type = N'${type}');
      IF (SELECT COUNT(*) FROM inserted WHERE type = N'${type}') = 0 RETURN;

      INSERT INTO [${type}]
      SELECT
        r.id, r.parent, r.date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate${fields}
        FROM inserted r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'${select}
        ) AS d
        WHERE r.type = N'${type}';
    END
    GO
    DROP TABLE IF EXISTS [${type}];
    DROP VIEW IF EXISTS [${type}];
    DROP VIEW IF EXISTS [${type}.v];
    SELECT
      r.id, r.parent,  ISNULL(CAST(r.date AS DATE), '1800-01-01') [date], r.document, r.company, r.kind, r.calculated,
      d.exchangeRate${fields}
    INTO [${type}]
    FROM [Accumulation] r
    CROSS APPLY OPENJSON (data, N'$')
    WITH (
      exchangeRate NUMERIC(15,10) N'$.exchangeRate'${select}
    ) AS d
    WHERE r.type = N'${type}';
    GO
    GRANT SELECT,INSERT,DELETE ON [${type}] TO JETTI;
    GO
    GRANT SELECT ON [${type}] TO PUBLIC;
    GO
    ALTER TABLE [${type}] ADD CONSTRAINT [PK_${type}] PRIMARY KEY NONCLUSTERED ([id]);
    CREATE CLUSTERED COLUMNSTORE INDEX [${type}] ON [${type}];
    RAISERROR('${type} finish', 0 ,1) WITH NOWAIT;
    GO
    `;
    return query;
  }

  static RegisterAccumulationClusteredTables() {
    let query = '';
    for (const type of RegisteredRegisterAccumulation) {
      const register = createRegisterAccumulation({ type: type.type });
      query += `${this.typeSpliter(type.type, true)}`;
      query += SQLGenegatorMetadata.RegisterAccumulationClusteredTable(register.Props(), register.Prop().type.toString());
      query += `${this.typeSpliter(type.type, false)}`;
    }
    query = `
    DROP INDEX IF EXISTS [Documents.parent] ON [dbo].[Documents];
    CREATE UNIQUE NONCLUSTERED INDEX [Documents.parent] ON [dbo].[Documents]([parent], [id]);
    ${query}
    `;
    return query;
  }


  static RegisterAccumulationViewQuery(doc: { [x: string]: any }, type: string) {

    const simleProperty = (prop: string, type: string) => {
      if (type === 'boolean') {
        return `
        , [${prop}] BIT N'$.${prop}'`;
      }
      if (type === 'number') {
        return `
        , [${prop}] MONEY N'$.${prop}'`;
      }
      if (type === 'date') {
        return `
        , [${prop}] DATE N'$.${prop}'`;
      }
      if (type === 'datetime') {
        return `
        , [${prop}] DATETIME N'$.${prop}'`;
      }
      return `
        , [${prop}] NVARCHAR(250) N'$.${prop}'`;
    };

    const complexProperty = (prop: string, type: string) => `
        , [${prop}] UNIQUEIDENTIFIER N'$.${prop}'`;

    let insert = ''; let select = ''; let fields = '';
    for (const prop in excludeRegisterAccumulatioProps(doc)) {
      const type: string = doc[prop].type || 'string';
      if (type === 'number') fields += `
      , d.[${prop}] * IIF(r.kind = 1, 1, -1) [${prop}], d.[${prop}] * IIF(r.kind = 1, 1, null) [${prop}.In], d.[${prop}] * IIF(r.kind = 1, null, 1) [${prop}.Out]`;
      else fields += ', ' + prop;

      insert += `
        , "${prop}"`;
      if (type === 'number') {
        insert += `
        , "${prop}.In"
        , "${prop}.Out"`;
      }

      if (type.includes('.')) {
        select += complexProperty(prop, type);
      } else {
        select += simleProperty(prop, type);
      }
    }

    const query = `
    CREATE OR ALTER VIEW [${type}]
    AS
      SELECT
        r.id, r.owner, r.parent, CAST(r.date AS DATE) date, r.document, r.company, r.kind, r.calculated,
        d.exchangeRate${fields}
        FROM [dbo].Accumulation r
        CROSS APPLY OPENJSON (data, N'$')
        WITH (
          exchangeRate NUMERIC(15,10) N'$.exchangeRate'${select}
        ) AS d
        WHERE r.type = N'${type}';
    GO
    GRANT SELECT,DELETE ON [${type}] TO JETTI;
    GO
    GRANT SELECT ON [${type}] TO PUBLIC;
    GO
    `;
    return query;
  }

  static RegisterAccumulationView() {
    let query = '';
    for (const type of RegisteredRegisterAccumulation) {
      const register = createRegisterAccumulation({ type: type.type });
      query += `${this.typeSpliter(type.type, true)}`;
      query += SQLGenegatorMetadata.RegisterAccumulationViewQuery(register.Props(), register.Prop().type.toString());
      query += `${this.typeSpliter(type.type, false)}`;
      query += `
      ------------+++++++++++SPECIAL START++++++++++++--------------------

      ALTER VIEW [dbo].[Register.Accumulation.Salary]
      AS SELECT * FROM [dbo].[Register.Accumulation.Salary.v] WITH (NOEXPAND) GO;
      ALTER VIEW [dbo].[Register.Accumulation.CashToPay]
      AS SELECT * FROM [dbo].[Register.Accumulation.CashToPay.v] WITH (NOEXPAND) GO;

      ------------+++++++++++SPECIAL END++++++++++++------------------
      `;
    }
    query = `
    ${query}
    `;
    return query;
  }

}
