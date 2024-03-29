// tslint:disable: max-line-length
import { PostResult } from '../post.interfaces';
import { MSSQL } from '../../mssql';
import { IServerDocument, createDocumentServer, DocumentBaseServer } from '../documents.factory.server';
import { DocumentCashRequestRegistry, CashRequest } from './Document.CashRequestRegistry';
import { RegisterAccumulationCashToPay } from '../Registers/Accumulation/CashToPay';
import { lib } from '../../std.lib';
import { DocumentCashRequest } from './Document.CashRequest';
import { createDocument } from '../documents.factory';
import { insertDocument, upsertDocument } from '../../routes/utils/post';
import { BankStatementUnloader } from '../../fuctions/BankStatementUnloader';
import { DocumentOperation } from './Document.Operation';
import { Ref } from 'jetti-middle';
import { CatalogOperation } from './../Catalogs/Catalog.Operation';
export class DocumentCashRequestRegistryServer extends DocumentCashRequestRegistry implements IServerDocument {

  private static DynamicOperationId = '8F58AE90-963C-11EB-B245-F3054AA54AB9'; 

  async dynamicOperation(tx: MSSQL) {
    return (await lib.doc.byId(DocumentCashRequestRegistryServer.DynamicOperationId, tx)) as CatalogOperation;
  }

  async dynamicPostScript(tx: MSSQL) {
    const oper = await this.dynamicOperation(tx);
    if (!oper?.script) return;

    const script = `
    ${oper?.script
        .replace(/\$\./g, 'doc.')
        .replace(/tx\./g, 'await tx.')
        .replace(/lib\./g, 'await lib.')
        .replace(/\'doc\./g, '\'$.')}
    `;
    const AsyncFunction = Object.getPrototypeOf(async function () { }).constructor;
    return new AsyncFunction('doc, Registers, tx, lib', script);
  }

  async dynamicModule(tx: MSSQL) {
    const oper = await this.dynamicOperation(tx);
    if (oper) return new Function('', oper.module || '').bind(this, tx)();
  }

  async dynamicHandler(eventKey: string, tx: MSSQL, params?: any) {
    const dynamicModule = await this.dynamicModule(tx);
    if (!dynamicModule || !dynamicModule[eventKey]) return false;
    await dynamicModule[eventKey](this, tx, params);
    return true;
  }

  async onCommand(command: string, args: any, tx: MSSQL) {

    if (await this.dynamicHandler(command, tx, args))
      return this;

    switch (command) {
      case 'Fill':
        await this.Fill(tx);
        return this;
      case 'RefreshLinkedDocuments':
        await this.RefreshLinkedDocuments(tx);
        return this;
      case 'Create':
        await this.Create(tx);
        return this;
      case 'UnloadToText':
        await this.UnloadToText(tx);
        return this;
      case 'ExportSalaryToCSV':
        await this.ExportSalaryToCSV(tx);
        return this;
      default:
        return this;
    }
  }

  private async FillOperationTypes(tx: MSSQL) {
    if (this.Operation === 'Выплата заработной платы (наличные)') {
      for (const row of this.CashRequests) { row.OperationType = this.Operation; }
      return;
    }
    const CashRequests = [...new Set(this.CashRequests.map(x => '\'' + x.CashRequest + '\''))].join(',');
    const query = `SELECT id CashRequest, Operation OperationType FROM [dbo].[Document.CashRequest.v] WHERE id IN (${CashRequests})`;
    const operations = await tx.manyOrNone<{ CashRequest, OperationType }>(query);
    for (const row of this.CashRequests) {
      const operType = operations.find(e => e.CashRequest === row.CashRequest);
      if (operType) row.OperationType = operType.OperationType;
    }
  }

  // удаляет из ТЧ помеченные на удаления операции
  async RefreshLinkedDocuments(tx: MSSQL) {
    const docsIdString = [...new Set(this.CashRequests.filter(c => c.LinkedDocument).map(x => '\'' + x.LinkedDocument + '\''))].join(',');
    if (!docsIdString) return;
    const query = `SELECT id FROM [dbo].[Document.Operation] WHERE id IN (${docsIdString}) and deleted = 1`;
    const deletedDocs = await tx.manyOrNone<{ id }>(query);
    for (const deletedDoc of deletedDocs) {
      this.CashRequests
        .filter(e => e.LinkedDocument === deletedDoc.id)
        .forEach(e => e.LinkedDocument = null);
    }
  }

  public async Create(tx: MSSQL) {
    if (this.Status !== 'APPROVED') throw new Error(`${this.description} cоздание возможно только в документе со статусом "APPROVED"!`);
    if (this.CashRequests.filter(c => !c.OperationType || (this.Operation && this.Operation !== c.OperationType))) {
      await this.FillOperationTypes(tx);
      await upsertDocument(this, tx);
    }
    await lib.doc.postById(this.id, tx);
    const OperationTypes = [...new Set(this.CashRequests.filter(c => (c.Amount > 0)).map(x => x.OperationType))];
    for (const OperationType of OperationTypes) {
      await this.CreateByOperationType(OperationType, tx);
    }
    this.DocumentsCreationDate = new Date as any;
    await upsertDocument(this, tx);
    await lib.doc.postById(this.id, tx);
  }

  private async CreateByOperationType(OperationType: string | null, tx: MSSQL) {
    if (!OperationType) OperationType = this.Operation;
    const rowsWithAmount = this.CashRequests.filter(c => (c.OperationType === OperationType && c.Amount > 0));
    let Operation: DocumentOperation | null;
    let BankAccountSupplier, currentCR, addBaseOnParams, LinkedDocument;
    const usedCashRegisters: Ref[] = [];
    const usedLinkedDocuments: string[] = [];
    const cashOper = OperationType === 'Выплата заработной платы (наличные)';
    const UniqCashRequest = [...new Set(rowsWithAmount.map(x => x.CashRequest))];

    if (OperationType === 'Выплата заработной платы') {
      if (UniqCashRequest.length > 1) throw Error('Для корректной выгрузки, в реестре на выплату должна присутствовать только ОДНА Заявка на расход ДС (Ведомость на выплату З/П)');
    }

    for (const CashRequestId of UniqCashRequest) {
      const rowsByCashReqest = rowsWithAmount.filter(row => row.CashRequest === CashRequestId);
      usedCashRegisters.length = 0;
      for (const row of rowsByCashReqest) {
        if ((currentCR === row.CashRequest && !cashOper) || usedCashRegisters.indexOf(row.CashRegister) !== -1) continue;
        addBaseOnParams = [];
        usedCashRegisters.push(row.CashRegister);
        LinkedDocument = row.LinkedDocument;
        currentCR = row.CashRequest;
        if (OperationType === 'Выплата заработной платы') {
          rowsByCashReqest.filter(el => (el.CashRequest === currentCR)).forEach(el => {
            addBaseOnParams.push({ CashRecipient: el.CashRecipient, BankAccountPerson: el.BankAccountPerson, Amount: el.Amount });
            if (el.LinkedDocument && usedLinkedDocuments.indexOf(el.LinkedDocument) === -1) LinkedDocument = el.LinkedDocument;
          });
        }
        if (cashOper) {
          rowsByCashReqest.filter(el => (el.CashRequest === currentCR && el.CashRegister === row.CashRegister)).forEach(el => {
            addBaseOnParams.push({ CashRecipient: el.CashRecipient, Amount: el.Amount });
            if (el.LinkedDocument && usedLinkedDocuments.indexOf(el.LinkedDocument) === -1) LinkedDocument = el.LinkedDocument;
          });
        }
        if (LinkedDocument && usedLinkedDocuments.indexOf(LinkedDocument) === -1) {
          usedLinkedDocuments.push(LinkedDocument);
          Operation = await lib.doc.byIdT<DocumentOperation>(LinkedDocument, tx);
        } else {
          Operation = createDocument<DocumentOperation>('Document.Operation');
        }
        const OperationServer = await createDocumentServer('Document.Operation', Operation!, tx);
        if (!OperationServer.code) OperationServer.code = await lib.doc.docPrefix(OperationServer.type, tx);
        if (OperationType !== 'Выплата заработной платы') {
          // исключение ошибки при проверке заполненности счета в базеон
          if (row.CashRecipientBankAccount) OperationServer['BankAccountSupplier'] = row.CashRecipientBankAccount;
          if (row.BankAccount) OperationServer['BankAccount'] = row.BankAccount;
          BankAccountSupplier =
            OperationType === 'Оплата ДС в другую организацию' ? row.BankAccountIn : row.CashRecipientBankAccount;
          if (OperationType === 'Оплата по кредитам и займам полученным' && row.BankAccount) OperationServer['BankAccount'] = row.BankAccount;
          OperationServer['BankAccountSupplier'] = BankAccountSupplier;
        }

        if (OperationType !== 'Выплата заработной платы' && !cashOper && OperationType !== 'Выплата заработной платы без ведомости') OperationServer['Amount'] = row.Amount;
        await OperationServer.baseOn!(row.CashRequest, tx, addBaseOnParams);
        // переопределение счета
        if (OperationType !== 'Выплата заработной платы' && !cashOper && BankAccountSupplier) OperationServer['BankAccountSupplier'] = BankAccountSupplier;

        if (cashOper) { OperationServer['CashRegister'] = row.CashRegister; OperationServer['f1'] = OperationServer['CashRegister']; }
        if (OperationType === 'Выплата заработной платы без ведомости' && row.Amount < OperationServer['Amount'] && cashOper) OperationServer['Amount'] = row.Amount;
        if (OperationServer.timestamp) await upsertDocument(OperationServer, tx); else await insertDocument(OperationServer, tx);
        await lib.doc.postById(OperationServer.id, tx);
        rowsByCashReqest.filter(el => (el.CashRequest === currentCR && (!cashOper || el.CashRegister === row.CashRegister))).forEach(el => { el.LinkedDocument = OperationServer.id; });
      }
    }


  }

  private async UnloadToText(tx: MSSQL) {
    if (!['APPROVED', 'PAID'].includes(this.Status)) throw new Error(`${this.description} выгрузка возможна только в документе со статусом "APPROVED" или "PAID"!`);
    const Operations = this.CashRequests.filter(c => (c.LinkedDocument)).map(c => (c.LinkedDocument));
    this.info = await BankStatementUnloader.getBankStatementAsString(Operations, tx);
    this.BankUploadDate = new Date as any;
    await upsertDocument(this, tx);
    await lib.doc.postById(this.id, tx);
  }

  private async ExportSalaryToCSV(tx: MSSQL) {
    if (!['APPROVED', 'PAID'].includes(this.Status)) throw new Error(`Possible only in the APPROVED or PAID document!`);
    // if (this.Operation !== 'Выплата заработной платы (наличные)') throw new Error(`Доступно только для операции "Выплата заработной платы (наличные)"`);
    const query = `
    SELECT
    per.description Person,
    ISNULL(jt.description,'') JobTitle,
    ISNULL(CR.description,'') CashRegister,
    ISNULL(bap.description,'') BankAccountPerson,
    Amount
    FROM Documents d
        CROSS APPLY OPENJSON (d.doc, N'$.CashRequests')
        WITH (CashRecipient VARCHAR(40),
             CashRegister VARCHAR(40),
             BankAccountPerson VARCHAR(40),
            [Amount] MONEY
        ) AS CashRequests
    LEFT JOIN [dbo].[Catalog.Person.v] per on per.id = CashRecipient
    LEFT JOIN [dbo].[Catalog.JobTitle.v] jt on jt.id = per.JobTitle
    LEFT JOIN [dbo].[Catalog.CashRegister.v] CR on CR.id = CashRequests.CashRegister
    LEFT JOIN [dbo].[Catalog.Person.BankAccount.v] bap on bap.id = CashRequests.BankAccountPerson
      where d.id = @p1 and @p2 <> N'Оплата по кредитам и займам полученным'
      AND Amount > 0
    UNION ALL
      SELECT
	  cp.description Person,
    '' JobTitle,
    ISNULL(ba.description,'') CashRegister,
    crb.description BankAccountPerson,
    Amount
    FROM Documents d
        CROSS APPLY OPENJSON (d.doc, N'$.CashRequests')
        WITH (CashRecipient VARCHAR(40),
             BankAccount VARCHAR(40),
             CashRecipientBankAccount VARCHAR(40),
            [Amount] MONEY
        ) AS CashRequests
    LEFT JOIN Documents cp on cp.id = CashRequests.CashRecipient
    LEFT JOIN Documents ba on ba.id = CashRequests.BankAccount
    LEFT JOIN Documents crb on crb.id = CashRequests.CashRecipientBankAccount
      where d.id = @p1 and @p2 = N'Оплата по кредитам и займам полученным'
      AND Amount > 0
      ORDER BY CashRegister, Person `;

    const salaryData = await tx.manyOrNone<{ CashRegister, Person, JobTitle, BankAccountPerson, Amount }>
      (query, [this.id, this.Operation]);

    let result = '№;Касса;Сотрудник;Должность;Счет;Сумма;Подпись;Примечание';
    for (let index = 0; index < salaryData.length; index++) {
      const row = salaryData[index];
      result += `\n${index + 1};${row.CashRegister};${row.Person};${row.JobTitle};${row.BankAccountPerson};${row.Amount};;`;
    }

    this.info = result;
    await upsertDocument(this, tx);
    await lib.doc.postById(this.id, tx);
  }

  isSalaryOperation(): boolean {
    return this.salaryOperations().indexOf(this.Operation) !== -1;
  }

  salaryOperations(): string[] {
    return ['Выплата заработной платы',
      'Выплата заработной платы (наличные)',
      'Выплата заработной платы без ведомости'];
  }

  unsupportedOperations(): string[] {
    return [
      'Прочий расход ДС',
      'Возврат оплаты клиенту',
      'Внутренний займ'
    ];
  }

  async isSuperuser(tx: MSSQL) {
    return lib.util.isRoleAvailable('Cash request registry admin', tx);
  }

  async beforePost(tx: MSSQL) {

    if (!['APPROVED', 'PAID'].includes(this.Status) || (await this.isSuperuser(tx))) return this;

    if (await this.dynamicHandler('beforePost', tx))
      return this;

    // const emptyRows = this.CashRequests
    //   .filter(row => !row.LinkedDocument)
    //   .map((row, ind) => ind++)
    //   .join(',');
    // if (emptyRows) throw new Error(`Не созданы операции в строках: ${emptyRows}`);

    const operations = this.CashRequests.map(row => `'${row.LinkedDocument}'`).join(',');
    const query = `SELECT amount, posted, id, code FROM [dbo].[Document.Operation.v] WHERE id IN (${operations})`;
    const operData = await tx.manyOrNone<{ amount: number, posted: boolean, id: string, code: string }>(query);
    const crRowIndex = (opId: string) => this.CashRequests.indexOf(this.CashRequests.find(cr => cr.LinkedDocument === opId)!);

    const unposted = operData
      .filter(op => !op.posted)
      .map(op => crRowIndex(op.id) + 1).join(',');
    if (unposted) throw new Error(`Не проведены операции в строках: ${unposted}`);

    const unamounted = operData
      .filter(op => this.CashRequests.find(cr => cr.LinkedDocument === op.id)!.Amount !== op.amount)
      .map(op => crRowIndex(op.id) + 1)
      .join(',');
    if (unamounted) throw new Error(`Отраженные операциями суммы не соответствуют данным реестра, строки: ${unamounted}`);

    return this;
  }

  private async Fill(tx: MSSQL) {
    if (this.Status !== 'PREPARED') throw new Error(`Filling is possible only in the PREPARED document!`);
    if (this.unsupportedOperations().includes(this.Operation)) throw new Error(`Unsupported operation type ${this.Operation}`);
    let query = '';
    const isCashSalary = this.Operation === 'Выплата заработной платы (наличные)';
    this.CashRequests = [];
    query = `
    DROP TABLE IF EXISTS #CashRequestBalance;
    DROP TABLE IF EXISTS #SalaryAmount;
    DROP TABLE IF EXISTS #SalaryAmountCashRequest;
    SELECT
        Balance.[currency] AS сurrency,
        Balance.[CashRequest] AS CashRequest,
        Balance.[CashRecipient] AS CashRecipient,
        SUM(Balance.[Amount]) AS AmountBalance,
        Balance.[OperationType] as OperationType,
        Balance.[BankAccountPerson] as BankAccountPerson
    INTO #CashRequestBalance
    FROM [dbo].[Register.Accumulation.CashToPay] AS Balance
    WHERE (1 = 1)
        AND (Balance.[company]  IN (SELECT id FROM dbo.[Descendants](@p1, '')) OR @p1 IS NULL)
        AND (Balance.[CashFlow] IN (SELECT id FROM dbo.[Descendants](@p2, '')) OR @p2 IS NULL)
        AND Balance.[currency] = @p3
        AND Balance.[OperationType] = @p4
    GROUP BY
        Balance.[currency], Balance.[CashRequest],Balance.[CashRecipient], Balance.[OperationType],Balance.[BankAccountPerson]
    HAVING SUM(Balance.[Amount]) > 0;
    SELECT
        Balance.[CashRequest] AS CashRequest,
        Balance.[CashRecipient] AS CashRecipient,
        Balance.[BankAccountPerson] as BankAccountPerson,
        SUM(Balance.[Amount]) AS Amount
    INTO #SalaryAmount
    FROM [dbo].[Register.Accumulation.CashToPay] AS Balance
    INNER JOIN #CashRequestBalance cr
    ON cr.CashRecipient = Balance.CashRecipient
    and cr.CashRequest = Balance.CashRequest
    and cr.OperationType = N'Выплата заработной платы'
      GROUP BY
          Balance.[CashRequest],Balance.[CashRecipient],Balance.[BankAccountPerson]
  HAVING SUM(Balance.[Amount]) > 0;

  SELECT
  Balance.[CashRequest] AS CashRequest,
  Balance.[CashRecipient] AS CashRecipient,
  Balance.[BankAccountPerson] as BankAccountPerson,
  SUM(Balance.[Amount]) AS Amount
INTO #SalaryAmountCashRequest
FROM [dbo].[Register.Accumulation.CashToPay] AS Balance
INNER JOIN #CashRequestBalance cr
ON cr.CashRecipient = Balance.CashRecipient
and cr.CashRequest = Balance.CashRequest
and cr.CashRequest = Balance.Document
and cr.OperationType = N'Выплата заработной платы'
GROUP BY
    Balance.[CashRequest],Balance.[CashRecipient],Balance.[BankAccountPerson]
HAVING SUM(Balance.[Amount]) > 0;

    SELECT
        CRT.[CashRequest] AS CashRequest
        , CAST(IIF(DocCR.Operation = N'Выплата заработной платы', sacr.Amount, DocCR.[Amount]) AS MONEY)  AS CashRequestAmount
        , CAST(IIF(DocCR.Operation = N'Выплата заработной платы', sacr.Amount, DocCR.[Amount]) AS MONEY) - IIF(DocCR.Operation = N'Выплата заработной платы',sa.Amount,CRT.[AmountBalance]) AS AmountPaid
        , CAST(IIF(DocCR.Operation = N'Выплата заработной платы',sa.Amount,CRT.[AmountBalance]) AS MONEY) AS AmountBalance
        , CRT.OperationType OperationType
        , IIF(@p5 = 1,cpb.id,CRT.BankAccountPerson) AS BankAccountPerson
        , CAST(0 AS MONEY) AS AmountRequest
        , DATEDIFF(DAY, GETDATE(), DocCR.[PayDay]) AS Delayed
        , CAST(IIF(DocCR.Operation = N'Выплата заработной платы',sa.Amount,CRT.[AmountBalance]) AS MONEY) AS Amount
        , CAST(0 AS BIT) AS Confirm
        , CRT.[CashRecipient] AS CashRecipient
        , DocCR.[company.id] AS company
        , IIF(@p5 = 1 OR
          (DocCR.Operation = N'Оплата по кредитам и займам полученным' AND DocCR.[CashKind] <> 'BANK')
          ,DocCR.[CashOrBank.id],NULL) AS CashRegister
        , IIF(@p5 = 1,NULL,DocCR.[CashOrBank.id]) AS BankAccount
        , DocCR.[CashOrBankIn.id] AS BankAccountIn
        , DocCR.[CashRecipientBankAccount.id] AS CashRecipientBankAccount
        , (SELECT COUNT(*) FROM [dbo].[Catalog.Counterpartie.BankAccount] AS CBA
    WHERE CBA.[owner.id] = DocCR.[CashRecipient.id]
      AND CBA.[currency.id] = DocCR.[сurrency.id]
      AND CBA.[deleted] = 0) AS CountOfBankAccountCashRecipient
        , null as LinkedDocument
    FROM #CashRequestBalance AS CRT
      LEFT JOIN #SalaryAmount sa ON CRT.CashRequest = sa.CashRequest and CRT.CashRecipient = sa.CashRecipient and (CRT.BankAccountPerson = sa.BankAccountPerson or @p5 = 1)
      LEFT JOIN #SalaryAmountCashRequest sacr ON CRT.CashRequest = sacr.CashRequest and CRT.CashRecipient = sacr.CashRecipient and (CRT.BankAccountPerson = sacr.BankAccountPerson or @p5 = 1)
      INNER JOIN [dbo].[Document.CashRequest] AS DocCR ON DocCR.[id] = CRT.[CashRequest] and (DocCR.[CashKind] = @p6 or @p6 = 'ANY')
      LEFT JOIN dbo.[Catalog.Person.BankAccount.v] cpb ON
      (DocCR.[SalaryProject.id] = cpb.SalaryProject or (cpb.SalaryProject is NULL and DocCR.[SalaryProject.id] is NULL))
      and CRT.[CashRecipient] = cpb.owner and cpb.deleted = 0 and @p5 = 1
    ORDER BY OperationType, Delayed, CashRequest, AmountBalance DESC, CashRecipient`;

    if (!this.Operation) {
      const filter = this.salaryOperations().concat(this.unsupportedOperations()).map(e => `AND Balance.[OperationType] <> N\'${e}\'`).join('\n');
      query = query.replace('AND Balance.[OperationType] = @p4', filter);
    }

    if (isCashSalary) query = query.replace('LEFT JOIN #SalaryAmount', 'INNER JOIN #SalaryAmount');
    const CashRequests = await tx.manyOrNone<CashRequest>(query,
      [this.company
        , this.CashFlow
        , this.сurrency
        , this.getDocumentCashRequestsOperationType()
        , isCashSalary ? 1 : 0
        , this.CashKind || 'ANY']
    );

    for (const row of CashRequests) {
      this.CashRequests.push({
        OperationType: row.OperationType,
        BankAccountPerson: row.BankAccountPerson,
        Amount: row.Amount,
        AmountBalance: row.AmountBalance,
        AmountPaid: row.AmountPaid,
        AmountRequest: row.AmountBalance,
        BankAccount: row.BankAccount,
        CashRegister: row.CashRegister,
        CashRecipient: row.CashRecipient,
        CashRequest: row.CashRequest,
        CashRequestAmount: row.CashRequestAmount,
        Confirm: row.Confirm,
        Delayed: row.Delayed,
        company: row.company,
        BankAccountIn: row.BankAccountIn,
        CashRecipientBankAccount: row.CashRecipientBankAccount,
        CountOfBankAccountCashRecipient: row.CountOfBankAccountCashRecipient,
        LinkedDocument: null
      });
    }
    this.Amount = 0;
    this.CashRequests.forEach(row => this.Amount += row.Amount);
  }

  private getDocumentCashRequestsOperationType() {
    if (!this.Operation) return null;
    switch (this.Operation) {
      case 'Выплата заработной платы (наличные)':
        return 'Выплата заработной платы';
      default:
        return this.Operation;
    }
  }

  async onCopy(tx: MSSQL) {
    this.Status = 'PREPARED';
    this.CashRequests = [];
    this.Amount = 0;
    this.info = '';
    this.DocumentsCreationDate = null;
    this.BankUploadDate = null;
    return this;
  }

  async onPost(tx: MSSQL) {
    const Registers: PostResult = { Account: [], Accumulation: [], Info: [] };

    const dynamic = await this.dynamicPostScript(tx);
    if (dynamic) return await dynamic(this, Registers, tx, lib);

    if (['REJECTED', 'APPROVED', 'PAID'].includes(this.Status)) return Registers;

    for (const row of this.CashRequests
      .filter(c => (c.AmountRequest > 0 || c.Amount > 0) && !c.LinkedDocument)) {
      if ((row.AmountRequest > row.AmountBalance) ||
        (row.Amount > row.AmountBalance)) {
        throw new Error('field [AmountRequest] or [Amount] is out of [AmountBalance]!');
      }
      const CashRequestObject = (await lib.doc.byIdT<DocumentCashRequest>(row.CashRequest, tx))!;
      Registers.Accumulation.push(new RegisterAccumulationCashToPay({
        kind: false,
        CashRecipient: row.CashRecipient,
        Amount: ['PREPARED', 'AWAITING'].indexOf(this.Status) > -1 ? row.AmountRequest : row.Amount,
        PayDay: CashRequestObject.PayDay,
        CashRequest: row.CashRequest,
        BankAccountPerson: row.BankAccountPerson,
        currency: this.сurrency,
        CashFlow: this.CashFlow,
        OperationType: CashRequestObject.Operation,
      }));
    }
    Registers.Accumulation = (Registers.Accumulation as RegisterAccumulationCashToPay[]).filter(r => r.Amount > 0);
    return Registers;
  }

}
