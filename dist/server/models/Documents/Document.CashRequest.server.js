"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DocumentCashRequestServer = void 0;
const environment_1 = require("./../../env/environment");
const std_lib_1 = require("../../std.lib");
const documents_factory_server_1 = require("../documents.factory.server");
const Document_CashRequest_1 = require("./Document.CashRequest");
const AP_1 = require("../Registers/Accumulation/AP");
const CashToPay_1 = require("../Registers/Accumulation/CashToPay");
const bp_1 = require("../../routes/bp");
const post_1 = require("../../routes/utils/post");
const documents_factory_1 = require("../documents.factory");
const x100_lib_1 = require("../../x100.lib");
const Catalog_Person_Contract_server_1 = require("../Catalogs/Catalog.Person.Contract.server");
class DocumentCashRequestServer extends Document_CashRequest_1.DocumentCashRequest {
    async onValueChanged(prop, value, tx) {
        let query = '';
        switch (prop) {
            case 'company':
                this.CashOrBank = null;
                this.tempCompanyParent = null;
                this.TaxBasisPayment = null;
                this.TaxDocDate = null;
                this.TaxOfficeCode2 = '';
                this.TaxDocNumber = '';
                this.TaxPaymentPeriod = null;
                this.TaxPayerStatus = null;
                this.TaxPaymentCode = null;
                this.CashRecipient = null;
                this.CashRecipientBankAccount = null;
                this.Contract = null;
                this.Department = null;
                this.TaxKPP = '';
                const company = await std_lib_1.lib.doc.byIdT(value.id, tx);
                if (company) {
                    this.сurrency = company.currency;
                    switch (this.CashKind) {
                        case 'BANK':
                            query = `
              SELECT TOP 1 id
              FROM [dbo].[Catalog.BankAccount]
              WHERE
              [currency.id] = @p1
              and [company.id] = @p2
              ORDER BY isDefault desc`;
                            const bankAccount = await tx.oneOrNone(query, [this.сurrency, this.company]);
                            if (bankAccount)
                                this.CashOrBank = bankAccount.id;
                            break;
                        case 'CASH':
                            query = `
              SELECT TOP 1 id
              FROM [dbo].[Catalog.CashRegister]
              WHERE
              [currency.id] = @p1
              and [company.id] = @p2`;
                            const CashRegister = await tx.oneOrNone(query, [this.сurrency, this.company]);
                            if (CashRegister)
                                this.CashOrBank = CashRegister.id;
                            break;
                        default:
                            break;
                    }
                    this.tempCompanyParent = company.parent;
                    const TaxOffice = await std_lib_1.lib.doc.byIdT(company.TaxOffice, tx);
                    this.TaxOfficeCode2 = (TaxOffice ? TaxOffice.Code2 : null);
                    this.TaxKPP = company.Code2;
                }
                return this;
            case 'CashRecipient':
                this.Contract = null;
                this.CashRecipientBankAccount = null;
                if (this.CashRecipient) {
                    const CashRecipient = await std_lib_1.lib.doc.byId(this.CashRecipient, tx);
                    if (CashRecipient && CashRecipient.type === 'Catalog.Counterpartie' && CashRecipient['Manager'])
                        this.Manager = CashRecipient['Manager'];
                }
                if (this.Operation === 'Оплата ДС в другую организацию') {
                    this.CashOrBankIn = null;
                    return this;
                }
                if (!value.id || value.type !== 'Catalog.Counterpartie') {
                    this.Contract = null;
                    return this;
                }
                query = `
          SELECT TOP 1 id
          FROM dbo.[Catalog.Contract]
          WHERE
          [owner.id] = @p1
          and [currency.id] = @p2
          and [company.id] = @p3
          ORDER BY isDefault desc`;
                const contractId = await tx.oneOrNone(query, [value.id, this.сurrency, this.company]);
                if (!contractId) {
                    this.Contract = null;
                    return this;
                }
                this.Contract = contractId.id;
                return this.onValueChanged('Contract', { id: this.Contract }, tx);
            case 'Contract':
                if (!value.id) {
                    this.CashRecipientBankAccount = null;
                    return this;
                }
                const CatalogContractObject = await std_lib_1.lib.doc.byIdT(value.id, tx);
                if (!CatalogContractObject || !CatalogContractObject.BankAccount) {
                    this.CashRecipientBankAccount = null;
                    return this;
                }
                if (this.Operation === 'Оплата ДС в другую организацию') {
                    this.CashOrBankIn = CatalogContractObject.BankAccount;
                }
                else {
                    this.CashRecipientBankAccount = CatalogContractObject.BankAccount;
                }
                return this;
            default:
                return this;
        }
    }
    async onCommand(command, args, tx) {
        switch (command) {
            case 'returnToStatusPrepared':
                await this.returnToStatusPrepared(tx);
                return this;
            case 'FillSalaryBalanceByPersons':
                await this.FillSalaryBalance(tx, true, false);
                return this;
            case 'FillSalaryBalanceByDepartment':
                await this.FillSalaryBalance(tx, false, false);
                return this;
            case 'FillSalaryBalanceByDepartmentWithCurrentMonth':
                await this.FillSalaryBalance(tx, false, true);
                return this;
            case 'FillSalaryBalanceByPersonsWithCurrentMonth':
                await this.FillSalaryBalance(tx, true, true);
                return this;
            case 'CloseCashRequest':
                await this.CloseCashRequest(tx);
                return this;
            case 'FillTaxInfo':
                await this.FillTaxInfo(tx);
                return this;
            default:
                await this[command](tx);
                return this;
        }
    }
    async baseOn(source, tx) {
        return this;
    }
    async isSuperuser(tx) {
        return std_lib_1.lib.util.isRoleAvailable('Cash request admin', tx.user);
    }
    async doCheckTaxCheck(tx) {
        return std_lib_1.lib.util.isRoleAvailable('Dont check tax check', tx.user);
    }
    async FillByWebAPIBody(body, tx) {
        const query = `
          SELECT [id]
                ,[company]
            FROM [dbo].[Documents] where ExchangeCode = @p1 and type = 'Catalog.Department'`;
        const dep = await tx.oneOrNone(query, [body.DepartmentId]);
        if (dep) {
            this['Department'] = dep.id;
            this['company'] = dep.company;
        }
        this['CashFlow'] = await std_lib_1.lib.doc.byCode('Catalog.CashFlow', body.CashFlowCode, tx);
        this['CashRecipient'] = await x100_lib_1.x100.catalog.counterpartieByINNAndKPP(body.INN, body.KPP ? body.KPP : '', tx);
        this['Amount'] = body.Amount;
        this['TaxRate'] = '7CFE6E50-35EA-11EA-A185-21EAFAF35D68'; // Без НДС
        this['Status'] = 'PREPARED';
        this['Operation'] = 'Оплата поставщику';
        this['CashKind'] = 'BANK';
        this['Status'] = 'PREPARED';
        this['PayDay'] = body.PayDay;
        this['info'] = body.Info;
        this['date'] = body.Date ? body.Date : new Date;
        this['user'] = '63C8AE00-5985-11EA-B2B2-7DD8BECCDACF'; // Exchange-PORTAL
        if (this.workflowID) {
            await bp_1.DeleteProcess(this.workflowID);
            this.workflowID = '';
        }
        this.posted = false;
        this.deleted = false;
        if (body.RelatedURL)
            this['RelatedURL'] = body.RelatedURL;
        this.map(await std_lib_1.lib.doc.saveDoc(this, tx));
    }
    async FillTaxInfo(tx) {
        const info = await this.getTaxInfo(tx, this.Amount);
        if (info)
            this.info = info;
    }
    async getTaxInfo(tx, amount) {
        if (this.ManualInfo || `Выплата заработной платы
    Выплата заработной платы без ведомости`.indexOf(this.Operation) !== -1)
            return;
        if (!this.company)
            throw Error('Не заполнена компания');
        if (!this.сurrency)
            throw Error('Не заполнена валюта');
        if (!this.TaxRate)
            throw Error('Не заполнена ставка НДС');
        if (!amount)
            throw Error('Не заполнена сумма');
        if (!this.info.trim())
            throw Error('Не заполнен комментарий');
        const countryCode = await std_lib_1.lib.util.getObjectPropertyById(this.company, 'Country.code', tx);
        if (!countryCode)
            throw Error('Не определена страна организации');
        const currencyShortName = await std_lib_1.lib.util.getObjectPropertyById(this.сurrency, 'ShortName', tx);
        if (!currencyShortName)
            throw Error('Не определено краткое наименование валюты');
        const taxRate = await std_lib_1.lib.util.getObjectPropertyById(this.TaxRate, 'Rate', tx);
        const infoArr = String(this.info).trim().split('\n');
        const Tax = amount - amount / (taxRate * 0.01 + 1);
        const newInfo = [];
        let taxInfo = '';
        if (countryCode === 'UKR') {
            // tslint:disable-next-line: max-line-length
            taxInfo = taxRate ? `В т.ч. ПДВ (${taxRate}%) ${String(Tax.toFixed(2)).replace('.', '-')} ${currencyShortName}.` : 'Без податку (ПДВ)';
        }
        else {
            taxInfo = taxRate ? `В т.ч. НДС (${taxRate}%) ${String(Tax.toFixed(2)).replace('.', '-')} ${currencyShortName}.` : 'Без налога (НДС)';
        }
        newInfo.push(infoArr[0].trim());
        newInfo.push(`${countryCode === 'UKR' ? 'Сума' : 'Сумма'} ${String(amount.toFixed(2)).replace('.', '-')} ${currencyShortName}. ${taxInfo}`);
        return newInfo.join('\n');
    }
    async returnToStatusPrepared(tx) {
        if (this.Status === 'PREPARED')
            return;
        if (!(await this.isSuperuser(tx))) {
            if (!this.user)
                throw new Error(`Не заполнен автор документа`);
            const mail = tx.user.email;
            if (!mail)
                throw new Error(`Не заполнен адрес электронной почты текущего пользователя`);
            const currentUser = await std_lib_1.lib.doc.byCode('Catalog.User', mail, tx);
            if (!currentUser)
                throw new Error(`Не удалось опеределить текущего пользователя`);
            if (currentUser !== this.user)
                throw new Error(`Операция разрешена только автору документа`);
            const relatedDocs = await this.getRelatedDocuments(tx);
            if (relatedDocs.length) {
                let relatedDocsString = '';
                relatedDocs.forEach(doc => { relatedDocsString += '\n' + doc.description; });
                throw new Error(`Операция не может быть выполнена, есть связанные документы: \n ${relatedDocsString}`);
            }
            if (this.workflowID) {
                await bp_1.DeleteProcess(this.workflowID);
                this.workflowID = '';
            }
        }
        this.Status = 'PREPARED';
        await post_1.updateDocument(this, tx);
    }
    async CloseCashRequest(tx) {
        if (this.Status === 'CLOSED')
            throw new Error(`Заявка уже закрыта`);
        if (await this.getAmountBalance(tx) !== 0) {
            const Operation = documents_factory_1.createDocument('Document.Operation');
            Operation.Group = 'A92DFE20-151D-11EA-A72F-6785F1E54D13';
            Operation.Operation = '6A374EA0-4F57-11EA-821D-9904759DD7D7'; // ЗАКРЫТИЕ - Заявки на расход ДС
            const OperationServer = await documents_factory_server_1.createDocumentServer('Document.Operation', Operation, tx);
            OperationServer.company = this.company;
            OperationServer.currency = this.сurrency;
            OperationServer.Group = 'A92DFE20-151D-11EA-A72F-6785F1E54D13';
            OperationServer.Operation = '6A374EA0-4F57-11EA-821D-9904759DD7D7';
            OperationServer['CashRequest'] = this.id;
            OperationServer.parent = this.id;
            OperationServer.code = await std_lib_1.lib.doc.docPrefix(OperationServer.type, tx);
            const Fill = OperationServer['serverModule']['Fill'];
            await Fill();
            await post_1.insertDocument(OperationServer, tx);
            await std_lib_1.lib.doc.postById(OperationServer.id, tx);
        }
        this.Status = 'CLOSED';
        await post_1.updateDocument(this, tx);
    }
    async FillSalaryBalance(tx, byPersons, withCurrentMonth) {
        if (!(await this.isSuperuser(tx)) && this.Status !== 'PREPARED')
            throw new Error(`Заполнение возможно только в статусе \"PREPARED\"`);
        let query = `
DROP TABLE IF EXISTS #Person;
DROP TABLE IF EXISTS #Salary;
DROP TABLE IF EXISTS #ExceptDocs;
    SELECT id personId
    INTO #Person
    FROM
        [dbo].[Catalog.Person]
    WHERE [Department.id] = @p1 AND @p6 = 0
UNION
    SELECT DISTINCT
        id personId
    FROM
        [dbo].[Catalog.Person]
    WHERE id IN (@p5) AND @p6 = 1;

    SELECT
doc.id
INTO #ExceptDocs
FROM [dbo].[Register.Accumulation.Salary] s
INNER JOIN [dbo].[Documents] doc
ON doc.id = document
and [ExchangeBase]='PortalNach'
and s.date BETWEEN @p7 AND @p8
and @p9 = 0;

SELECT
    Person PersonID,
    SUM(Amount) Salary
INTO #Salary
FROM [dbo].[Register.Accumulation.Salary] register
WHERE (1=1)
    AND register.document NOT IN (SELECT id FROM #ExceptDocs)
    AND ((@p6 = 0
    AND (Person in (SELECT personId
    FROM #Person) OR @p1 is NULL))
    OR (@p6 = 1 AND Person in (SELECT personId
    FROM #Person)))
    AND currency = @p2
    AND date <= @p3
    AND company in (SELECT id FROM [dbo].Descendants(@p4, ''))
GROUP BY Person
HAVING SUM(Amount) > 0;

SELECT
    PersonID Employee,
    ROUND(SUM(Salary),0) Salary
FROM (        SELECT *
        FROM #Salary

    UNION

        SELECT
            res.PersonID,
            SUM(res.Amount)
        FROM (
                SELECT
                ft.CashRecipient PersonID,
                -IIF(d.[type] = 'Document.Operation'
                AND JSON_VALUE(d.doc, '$.Group') in ('269BBFE8-BE7A-11E7-9326-472896644AE4', '3BCDFD50-BE79-11E7-A223-BB955AD4DD9E')
                AND CAST(ISNULL(JSON_VALUE(d.doc, N'$.BankConfirm'),0) AS BIT) = 0,0,SUM(ft.Amount)) Amount
            FROM [dbo].[Register.Accumulation.CashToPay] ft
                LEFT JOIN [dbo].[Documents] d ON d.id = ft.document
            WHERE (1=1)
                AND ft.document NOT IN (SELECT id FROM #ExceptDocs)
                AND (ft.CashRecipient IN (SELECT personId
                from #Person) or (@p1 is NULL and ft.CashRecipient IN (SELECT personId
                from #Salary)))
                AND ft.currency = @p2
                AND ft.date <= @p3
                AND ft.OperationType in (N'Выплата заработной платы без ведомости',N'Выплата заработной платы')
            GROUP BY
                    ft.CashRecipient,JSON_VALUE(d.doc, '$.Group'),CAST(ISNULL(JSON_VALUE(d.doc, N'$.BankConfirm'),0) AS BIT),d.type
            HAVING
                  IIF(d.[type] = 'Document.Operation'
                  AND JSON_VALUE(d.doc, '$.Group') IN ('269BBFE8-BE7A-11E7-9326-472896644AE4', '3BCDFD50-BE79-11E7-A223-BB955AD4DD9E')
                  AND CAST(ISNULL(JSON_VALUE(d.doc, N'$.BankConfirm'),0) AS BIT)  = 0,0,SUM([Amount])) <> 0) as res
        GROUP BY
              PersonID) as fin
    LEFT JOIN [dbo].[Catalog.Person] p ON fin.PersonID = p.id
GROUP BY
        PersonID, p.Person
HAVING SUM(Salary) >= 20 AND not PersonID is NULL
ORDER BY
        p.Person`;
        const CompanyEmployee = await std_lib_1.lib.util.salaryCompanyByCompany(this.company, tx);
        const CompanyParent = await std_lib_1.lib.doc.byId(CompanyEmployee, tx);
        const persons = '';
        if (byPersons)
            query = query.replace('@p5', this.PayRolls.map(el => '\'' + el.Employee + '\'').join(','));
        const currentMounth = {
            begin: new Date(this.date.getFullYear(), this.date.getMonth(), 1),
            end: new Date(this.date.getFullYear(), this.date.getMonth() + 1, 0, 23, 59, 59)
        };
        const params = [byPersons ? null : this.Department,
            this.сurrency,
            this.date, CompanyParent.parent, persons,
            byPersons ? 1 : 0,
            currentMounth.begin,
            currentMounth.end,
            withCurrentMonth ? 1 : 0];
        const salaryBalance = await tx.manyOrNone(query, params);
        this.PayRolls = [];
        this.Amount = 0;
        this.PayDay = new Date;
        salaryBalance.forEach(el => {
            this.PayRolls.push({ Employee: el.Employee, Salary: el.Salary, Tax: 0, BankAccount: null, SalaryPenalty: 0 });
            this.Amount += el.Salary;
        });
    }
    async beforeSave(tx) {
        if (this.Amount < 0.01)
            throw new Error(`${this.description} неверно указана сумма`);
        if (!this.CashKind)
            throw new Error(`${this.description} не указан тип платежа`);
        return this;
    }
    async beforeDelete(tx) {
        if (!(await this.isSuperuser(tx)) && this.Status === 'APPROVED' && this.posted) {
            const rest = await this.getAmountBalance(tx);
            if (this.Amount !== rest)
                throw new Error(`${this.description} не может быть удален:\n оплачено ${this.Amount - rest}`);
        }
        if (this.workflowID) {
            await bp_1.DeleteProcess(this.workflowID);
            this.workflowID = '';
        }
        this.Status = 'PREPARED';
        await post_1.updateDocument(this, tx);
        return this;
    }
    async onCommandcheckTaxCheck(tx) {
        const err = await this.checkTaxCheck(tx);
        throw new Error(err || 'Согласование возможно');
    }
    async checkTaxCheck(tx) {
        if (!this.doCheckTaxCheck(tx))
            return '';
        const q = `
    select
      document,
      receiptId
    from [dbo].[Register.Info.TaxCheck] where document in (
      select top 1 document from
        ${environment_1.REGISTER_ACCUMULATION_SOURCE}[dbo].[Register.Accumulation.Bank]
      where company = @p1
        and Analytics = @p2
        and CashFlow = @p3
        and Amount <> 0
      order by date desc)`;
        const qRes = await tx.oneOrNone(q, [this.company, this.CashRecipient, this.CashFlow]);
        if (!qRes || qRes.receiptId)
            return '';
        const cr = await std_lib_1.lib.doc.byId(qRes.document, tx);
        return `Проведение невозможно - не предоставлен чек по последней оплаченной заявке: ${cr.description}`;
    }
    async onPost(tx) {
        const superuser = await this.isSuperuser(tx);
        if (!superuser) {
            if (this.Operation && this.Operation === 'Оплата ДС в другую организацию' && this.company === this.CashRecipient)
                // tslint:disable-next-line: max-line-length
                throw new Error(`${this.description} не может быть проведен:\n организация-оправитель не может совпадать с организацией-получателем`);
            if (!this.CashFlow)
                throw new Error(`${this.description} не может быть проведен:\n не указана статья ДДС`);
            if (!this.EnforcementProceedings && await this.useSalaryPenalty(tx))
                throw new Error(`${this.description} не может быть проведен:\n не указан вид дохода`);
            if (this.info) {
                const curlength = this.info.split('\n')[0].length;
                if (curlength > 120 && await std_lib_1.lib.util.getObjectPropertyById(this.company, 'county.code', tx) !== 'UKR')
                    throw Error(`Назначение платежа превышает максимально допустимую длину (120 символов) на ${curlength - 120} символов`);
            }
        }
        if (this.Status !== 'REJECTED') {
            if (this.Operation === 'Оплата поставщику' && !this.Contract)
                throw new Error(`Не указан договор`);
            else
                await this.FillTaxInfo(tx);
        }
        const Registers = { Account: [], Accumulation: [], Info: [] };
        if (this.Status === 'PREPARED' || this.Status === 'REJECTED') {
            return Registers;
        }
        const cashOrBank = await std_lib_1.lib.doc.byId(this.CashOrBank, tx);
        const сurrency = cashOrBank ? cashOrBank.currency : this.сurrency;
        // const exchangeRate = await lib.info.exchangeRate(this.date, this.company, сurrency, tx) || 1;
        switch (this.Operation) {
            case 'Оплата поставщику':
                // AP
                Registers.Accumulation.push(new AP_1.RegisterAccumulationAP({
                    kind: false,
                    AO: this.Contract,
                    Department: this.Department,
                    Supplier: this.CashRecipient,
                    AmountIsPaid: (this.Status === 'APPROVED' ? this.Amount : 0),
                    AmountToPay: (this.Status === 'AWAITING' || this.Status === 'MODIFY' ? this.Amount : 0),
                    PayDay: this.PayDay,
                    currency: сurrency,
                    company: this.company
                }));
                break;
            default:
                break;
        }
        if (this.Status !== 'APPROVED')
            return Registers;
        // CashToPay
        if (this.Operation === 'Выплата заработной платы') {
            this.PayRolls.forEach(el => {
                Registers.Accumulation.push(new CashToPay_1.RegisterAccumulationCashToPay({
                    kind: true,
                    CashRecipient: el.Employee,
                    BankAccountPerson: el.BankAccount,
                    Amount: el.Salary - (el.SalaryPenalty || 0),
                    date: this.PayDay,
                    PayDay: this.PayDay,
                    CashRequest: this.id,
                    currency: сurrency,
                    CashFlow: this.CashFlow,
                    OperationType: this.Operation
                }));
            });
        }
        else {
            const movements = new CashToPay_1.RegisterAccumulationCashToPay({
                kind: true,
                CashRecipient: this.CashRecipient,
                Amount: this.Amount - (this.AmountPenalty || 0),
                date: this.PayDay,
                PayDay: this.PayDay,
                CashRequest: this.id,
                currency: сurrency,
                CashFlow: this.CashFlow,
                OperationType: this.Operation
            });
            if (this.Operation === 'Выплата заработной платы без ведомости' && this.CashKind === 'CASH')
                movements.Contract = this.PersonContract;
            Registers.Accumulation.push(movements);
        }
        return Registers;
    }
    // возвращает остаток по заявке
    async getAmountBalance(tx) {
        if (this.Status !== 'APPROVED')
            return 0;
        const query = `
      SELECT
        SUM(Balance.[Amount]) AS AmountBalance
      FROM [dbo].[Register.Accumulation.CashToPay] AS Balance -- WITH (NOEXPAND)
      WHERE Balance.[CashRequest] = @p1`;
        const queryRes = await tx.manyOrNone(query, [this.id]);
        if (queryRes.length)
            return queryRes[0].AmountBalance;
        return 0;
    }
    // возвращает остаток по заявке в разрезе получателей и счетов
    // todo: обратится в базу х100
    async getAmountBalanceWithCashRecipientsAndBankAccounts(tx, onlyWithPositiveBalance) {
        const query = `
    SELECT
        Balance.[CashRecipient] AS CashRecipient,
        Balance.[BankAccountPerson] AS BankAccountPerson,
        SUM(Balance.[Amount]) AS Amount
    FROM [dbo].[Register.Accumulation.CashToPay] AS Balance
    WHERE Balance.[CashRequest] = @p1
    GROUP BY
        Balance.[CashRecipient],Balance.[BankAccountPerson]
    ${onlyWithPositiveBalance ? 'HAVING SUM(Balance.[Amount]) > 0' : ''}`;
        return await tx.manyOrNone(query, [this.id]);
    }
    // возвращает связанные документы
    async getRelatedDocuments(tx) {
        const query = `
    select
    id,
      description
    from Documents
    where contains(doc, @p1)
    union
    select
    id,
      description
    from Documents
    where parent =  @p1`;
        return await tx.manyOrNone(query, [this.id]);
    }
    async useSalaryPenalty(tx) {
        const res = !!(this.date >= new Date(2020, 5, 1) && this.company && this.Operation.includes('Выплата заработной платы'));
        if (!res)
            return res;
        const country = await std_lib_1.lib.util.getObjectPropertyById(this.company, 'country', tx);
        return country && country.id === 'BA065230-4D6A-11EA-9419-5B6F020710B8';
    }
    async beforePostDocumentOperation(docOperation, tx) {
        if (await this.isSuperuser(tx))
            return;
        if (docOperation.Operation === '6A374EA0-4F57-11EA-821D-9904759DD7D7')
            return; // ЗАКРЫТИЕ - Заявки на расход ДС
        if (this.Operation === 'Выплата заработной платы') {
            const rest = await this.getAmountBalanceWithCashRecipientsAndBankAccounts(tx, false);
            const Errors = [];
            rest.forEach(el => {
                docOperation['PayRolls']
                    .filter(pr => (pr.Employee === el.CashRecipient &&
                    (pr.BankAccount === el.BankAccountPerson || !el.BankAccountPerson && !pr.BankAccount)
                    && el.Amount < pr.Amount - (pr.AmountPenalty || 0)))
                    .forEach(er => {
                    Errors.push({ Employee: er.Employee, BankAccount: er.BankAccount, Amount: er.Amount - el.Amount - (er.AmountPenalty || 0) });
                });
            });
            if (Errors.length) {
                let ErrorText = '';
                const query = `
          SELECT Description Employee FROM dbo.Documents WHERE id = @p1
          SELECT Description BankAccount FROM dbo.Documents WHERE id = @p2`;
                for (const err of Errors) {
                    const descriptions = await tx.oneOrNone(query, [err.Employee, err.BankAccount]);
                    ErrorText += `\n\t ${descriptions.Employee} ${descriptions.BankAccount ? 'по ' + descriptions.BankAccount : ''} на ${err.Amount.toFixed(2)} `;
                }
                throw new Error(`${docOperation.description} не может быть проведен, первышение остатка по заявке для: ${ErrorText} `);
            }
        }
        else {
            const rest = await this.getAmountBalance(tx);
            let docAmount = docOperation.Amount;
            if (this.Operation === 'Выплата заработной платы без ведомости')
                docAmount += docOperation['AmountPenalty'];
            if (rest < docAmount)
                throw new Error(`${docOperation.description} не может быть проведен: сумма ${docAmount} превышает остаток ${rest} на ${docAmount - rest} по ${this.description} `);
        }
    }
    async FillDocumentOperation(docOperation, tx, params) {
        docOperation.company = this.company;
        docOperation.currency = this.сurrency;
        docOperation.parent = this.id;
        docOperation.date = new Date();
        docOperation.Amount = docOperation.Amount || this.Amount;
        docOperation['CashFlow'] = this.CashFlow;
        docOperation['Department'] = this.Department;
        docOperation.info = this.info;
        switch (this.Operation) {
            case 'Оплата поставщику':
                await this.FillOperationОплатаПоставщику(docOperation, tx, params);
                break;
            case 'Перечисление налогов и взносов':
                await this.FillOperationПеречислениеНалоговИВзносов(docOperation, tx, params);
                break;
            case 'Оплата по кредитам и займам полученным':
                await this.FillOperationОплатаПоКредитамИЗаймамПолученным(docOperation, tx, params);
                break;
            case 'Оплата ДС в другую организацию':
                await this.FillOperationОплатаДСВДругуюОрганизацию(docOperation, tx, params);
                break;
            case 'Выплата заработной платы':
                await this.FillOperationВыплатаЗаработнойПлаты(docOperation, tx, params);
                break;
            case 'Выплата заработной платы без ведомости':
                await this.FillOperationВыплатаЗаработнойПлатыБезВедомости(docOperation, tx, params);
                break;
            case 'Выдача ДС подотчетнику':
                await this.FillOperationВыдачаДСПодотчетнику(docOperation, tx, params);
                break;
            case 'Перемещение ДС':
                await this.FillOperationПеремещениеДС(docOperation, tx, params);
                break;
            case 'Внутренний займ':
                await this.FillOperationВнутреннийЗайм(docOperation, tx, params);
                break;
            case 'Прочий расход ДС':
                await this.FillOperationПрочийРасходДС(docOperation, tx, params);
                break;
            case 'Выдача займа контрагенту':
                await this.FillOperationВыдачаЗаймаКонтрагенту(docOperation, tx, params);
                break;
            default:
                throw new Error(`Не реализовано создание документа для вида операции ${this.Operation} `);
        }
        if (docOperation.Amount !== this.Amount)
            docOperation.info = await this.getTaxInfo(tx, docOperation.Amount) || docOperation.info;
    }
    async FillOperationПеречислениеНалоговИВзносов(docOperation, tx, params) {
        let CashOrBank;
        if (docOperation['BankAccount']) {
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        }
        else {
            CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        }
        docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4';
        docOperation.Operation = '8D128C20-3E20-11EA-A722-63A01E818155';
        `TaxKPP
    TaxPaymentCode
    TaxOfficeCode2
    TaxPayerStatus
    TaxBasisPayment
    TaxDocNumber
    TaxDocDate
    TaxPaymentPeriod`.split('\n').forEach(el => { docOperation[el.trim()] = this[el.trim()]; });
        docOperation['Supplier'] = this.CashRecipient;
        docOperation['BankAccount'] = CashOrBank.id;
        docOperation.f1 = docOperation['CashRegister'];
        docOperation.f2 = docOperation['Supplier'];
        docOperation.f3 = docOperation['CashFlow'];
    }
    async FillOperationОплатаПоставщику(docOperation, tx, params) {
        let CashOrBank;
        if (docOperation['BankAccount']) {
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        }
        else {
            CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        }
        let CashRecipientBankAccount;
        docOperation['Contract'] = this.Contract;
        CashRecipientBankAccount = this.CashRecipientBankAccount;
        if (!CashRecipientBankAccount) {
            const query = `
    SELECT TOP 1 id FROM dbo.[Catalog.Counterpartie.BankAccount] WHERE[owner.id] = '${this.CashRecipient}'`;
            const queryResult = await tx.oneOrNone(query);
            if (queryResult)
                CashRecipientBankAccount = queryResult.id;
        }
        if (!CashRecipientBankAccount)
            throw new Error(`Расчетный счет получателя не определен`);
        docOperation['Supplier'] = this.CashRecipient;
        docOperation['BankConfirm'] = false;
        if (!CashOrBank)
            throw new Error('Источник оплат не заполнен в заявке на ДС');
        if (CashOrBank.type === 'Catalog.CashRegister') {
            docOperation.Operation = '770FA450-BB58-11E7-8996-53A59C675CDA'; // касса
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97';
            docOperation['CashRegister'] = CashOrBank.id;
            docOperation.f1 = docOperation['CashRegister'];
            docOperation.f2 = docOperation['Supplier'];
            docOperation.f3 = docOperation['CashFlow'];
        }
        else {
            docOperation.Operation = '68FA31F0-BDB0-11E7-9C95-E3F9522E1FC9'; // С р/с -  оплата поставщику (БЕЗНАЛИЧНЫЕ)
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4';
            docOperation['TaxAssignmentCode'] = this.TaxAssignmentCode; // КНП для Казахстана
            docOperation['BankAccountSupplier'] = CashRecipientBankAccount;
            docOperation['BankAccount'] = CashOrBank.id;
            docOperation['TaxPaymentCode'] = this.TaxPaymentCode;
            docOperation['TaxOfficeCode2'] = this.TaxOfficeCode2;
            docOperation.f1 = docOperation['BankAccount'];
            docOperation.f2 = docOperation['Supplier'];
            docOperation.f3 = docOperation['CashFlow'];
        }
    }
    async FillOperationПрочийРасходДС(docOperation, tx, params) {
        const CashOrBank = await std_lib_1.lib.doc.byId(this.CashOrBank, tx);
        if (!CashOrBank || CashOrBank.type !== 'Catalog.CashRegister')
            throw new Error('Источником может быть только касса');
        docOperation.Operation = 'C5BFBB30-DA4B-11E9-9A3A-E3F9D911F5D5'; // Из кассы -  Прочий расход ДС (Статья расходов)
        docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97';
        docOperation['Supplier'] = this.CashRecipient;
        docOperation['CashRegister'] = CashOrBank.id;
        docOperation['ExpenseAnalytics'] = this.CashFlow;
        docOperation['Expense'] = this.CashFlow;
        docOperation.f1 = docOperation['CashRegister'];
        docOperation.f2 = docOperation['ExpenseAnalytics'];
        docOperation.f3 = docOperation['Expense'];
    }
    async FillOperationВыплатаЗаработнойПлатыБезВедомости(docOperation, tx, params) {
        let CashOrBank;
        CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        if (docOperation['BankAccount'] && CashOrBank.type === 'Catalog.BankAccount') {
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        }
        docOperation.Amount = await this.getAmountBalance(tx);
        docOperation['SalaryAnalytics'] = this.SalaryAnalitics;
        docOperation['Employee'] = this.CashRecipient;
        docOperation.f2 = docOperation['SalaryAnalytics'];
        docOperation.f3 = docOperation['Employee'];
        docOperation['BankConfirm'] = false;
        if (CashOrBank.type === 'Catalog.CashRegister') {
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // Расходный кассовый ордер
            if (this.PersonContract) {
                docOperation.Operation = 'B7380C50-346F-11EB-BE52-014B0CAC0EFD'; // С кассы - выплата зарплаты (САМОЗАНЯТОМУ СОТРУДНИКУ)
                docOperation['PersonContract'] = this.PersonContract;
            }
            else
                docOperation.Operation = 'D354F830-459B-11EA-AAE2-A1796B9A826A'; // Из кассы - выплата зарплаты (СОТРУДНИКУ без ведомости)
            docOperation['CashRegister'] = CashOrBank.id;
            docOperation.f1 = docOperation['CashRegister'];
        }
        else if (CashOrBank.type === 'Catalog.BankAccount') {
            const personContract = await Catalog_Person_Contract_server_1.getPersonContract([this.CashRecipient, this.company, this.date], tx);
            if (personContract) {
                docOperation.Operation = 'DB1C4760-D0D0-11EA-AF5B-791AD1831643'; // С р/с - выплата зарплаты (САМОЗАНЯТОМУ СОТРУДНИКУ без ведомости)
                docOperation['PersonContract'] = personContract;
            }
            else {
                docOperation.Operation = 'E47A8910-4599-11EA-AAE2-A1796B9A826A'; // С р/с - выплата зарплаты (СОТРУДНИКУ без ведомости) (RUSSIA)
            }
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // 4.1 - Списание безналичных ДС
            docOperation['BankAccount'] = CashOrBank.id;
            docOperation['AmountPenalty'] = this.AmountPenalty;
            docOperation['EnforcementProceedings'] = this.EnforcementProceedings;
            docOperation['BankAccountPerson'] = this.CashRecipientBankAccount;
            docOperation.f1 = docOperation['BankAccount'];
            if (this.CashRecipientBankAccount) {
                const ba = await std_lib_1.lib.doc.byIdT(this.CashRecipientBankAccount, tx);
                if (ba) {
                    const owner = await std_lib_1.lib.doc.byId(ba.owner, tx);
                    const prefix = ba.code.trim().startsWith('408208') ? '{VO70060}' : '';
                    docOperation.info = `${prefix} Перечисление заработной платы на лицевой счет ${ba.code} на имя ${owner.description}. Без налога(НДС)`;
                }
            }
        }
    }
    async FillOperationОплатаПоКредитамИЗаймамПолученным(docOperation, tx, params) {
        let CashOrBank, CashRecipientBankAccount, CashRecipient;
        if (docOperation['BankAccount'])
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        else
            CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Не указан источник ДС в ${this.description} `);
        if (CashOrBank.type === 'Catalog.CashRegister') {
            CashRecipient = (await std_lib_1.lib.doc.byId(this.CashRecipient, tx));
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // 4.2 - Расходный кассовый ордер
            docOperation['Counterpartie'] = this.CashRecipient;
            docOperation['CashRegister'] = this.CashOrBank;
            docOperation['PaymentKind'] = this.PaymentKind;
            docOperation['Loan'] = this.Loan;
            docOperation.f1 = docOperation['CashRegister'];
            docOperation.f2 = docOperation['Counterpartie'];
            docOperation.f3 = docOperation['Loan'];
            if (CashRecipient.type === 'Catalog.Counterpartie') {
                docOperation.Operation = 'DBBCB3D0-1749-11EA-92AC-8B4BF8464BD9'; // Из кассы - Выдача/Возврат кредитов и займов (Контрагент)
            }
            else if (CashRecipient.type === 'Catalog.Person') {
                // tslint:disable-next-line: max-line-length
                docOperation.Operation = '8C3B61A0-6512-11EA-A8B2-95688F3F3592'; // Из кассы - Выдача/Возврат кредитов и займов (Физ.лицо) (МУЛЬТИВАЛЮТНЫЙ)
                const CurrencyLoan = await std_lib_1.lib.util.getObjectPropertyById(this.Loan, 'currency.id', tx);
                if (CurrencyLoan) {
                    docOperation['CurrencyLoan'] = CurrencyLoan.id;
                    const CompanyHolding = await std_lib_1.lib.doc.byCode('Catalog.Company', 'HOLDING', tx);
                    const ExchangeRateDoc = await std_lib_1.lib.info.exchangeRate(docOperation.date, CompanyHolding, docOperation.currency, tx);
                    const ExchangeRateLoan = await std_lib_1.lib.info.exchangeRate(docOperation.date, CompanyHolding, docOperation['CurrencyLoan'], tx);
                    docOperation['AmountLoan'] = (docOperation.Amount / ExchangeRateDoc) * ExchangeRateLoan;
                }
                else {
                    docOperation['CurrencyLoan'] = docOperation.currency;
                    docOperation['AmountLoan'] = docOperation.Amount;
                }
            }
        }
        else { // bank
            CashRecipientBankAccount = this.CashRecipientBankAccount;
            if (!CashRecipientBankAccount) {
                const query = `
    SELECT TOP 1 id FROM dbo.[Catalog.Counterpartie.BankAccount] WHERE[owner.id] = '${this.CashRecipient}'`;
                const queryResult = await tx.oneOrNone(query);
                if (queryResult)
                    CashRecipientBankAccount = queryResult.id;
            }
            if (!CashRecipientBankAccount)
                throw new Error(`Расчетный счет получателя не определен`);
            if (!CashOrBank)
                throw new Error(`Источник оплат не заполнен в ${this.description} `);
            docOperation['BankConfirm'] = false;
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4';
            docOperation.Operation = '54AA5310-102E-11EA-AA50-31ECFB22CD33';
            docOperation['Counterpartie'] = this.CashRecipient;
            docOperation['BankAccount'] = CashOrBank.id;
            docOperation['BankAccountSupplier'] = CashRecipientBankAccount;
            docOperation['PaymentKind'] = this.PaymentKind;
            docOperation['Loan'] = this.Loan;
            docOperation.f1 = docOperation['BankAccount'];
            docOperation.f2 = docOperation['Counterpartie'];
            docOperation.f3 = docOperation['Loan'];
        }
    }
    async FillOperationОплатаДСВДругуюОрганизацию(docOperation, tx, params) {
        let CashOrBank;
        const CashOrBankIn = (await std_lib_1.lib.doc.byId(this.CashOrBankIn, tx));
        if (!CashOrBankIn)
            throw new Error('Приемник оплат не заполнен в заявке на ДС');
        if (docOperation['BankAccount']) {
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        }
        else {
            CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        }
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        if (CashOrBank.type === 'Catalog.CashRegister')
            throw new Error('Создание платежного документа из кассы не поддерживается, обратитесь к разработчику');
        // docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // Расходный кассовый ордер
        //   if (CashOrBankIn!.type === 'Catalog.CashRegister') {
        //     docOperation.Operation = '1B411A80-DBF6-11E9-9DD5-EB2F495F92A0'; // Из кассы - в другую кассу (в путь)
        //     docOperation['CashRegisterOUT'] = CashOrBank.id;
        //     docOperation['CashRegisterIN'] = CashOrBankIn.id;
        //     docOperation.f1 = docOperation['CashRegisterOUT'];
        //     docOperation.f2 = docOperation['CashRegisterIN'];
        //     // const CashRecipient = (await lib.doc.byId(this.CashRecipient, tx));
        //     // if (CashRecipient!.type = 'Catalog.Person') {
        //     //   docOperation['Person'] = CashRecipient!.id;
        //     //   docOperation.f3 = docOperation['Person'];
        //     // }
        //   } else {
        //     docOperation.Operation = 'A6D6678C-BBA3-11E7-8E9F-1B4E8C03A1F5'; // Из кассы - на расчетный счет (в путь)
        //     docOperation['BankAccount'] = CashOrBankIn.id;
        //     docOperation['CashRegister'] = CashOrBank.id;
        //     docOperation.f1 = docOperation['CashRegister'];
        //     docOperation.f2 = docOperation['BankAccount'];
        //   }
        // } else {
        docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // Списание безналичных ДС
        if (CashOrBankIn.type === 'Catalog.CashRegister')
            throw new Error('Создание платежного документа в кассу не поддерживается, обратитесь к разработчику');
        //   docOperation.Operation = '369E2910-36CA-11EA-A774-7FBAF34E4AFA'; // С р/с - в кассу (в путь)
        //   docOperation['BankAccountOut'] = CashOrBank.id;
        //   docOperation['CashRegisterIn'] = CashOrBankIn.id;
        //   docOperation['BankConfirm'] = false;
        //   docOperation.f1 = docOperation['BankAccountOut'];
        //   docOperation.f2 = docOperation['CashRegisterIn'];
        // } else {
        docOperation['CashFlow'] = this.CashFlow;
        docOperation.Operation = '433D63DE-D849-11E7-83D2-2724888A9E4F'; // С р/с - на расчетный счет  (в путь)
        docOperation['BankAccountOut'] = CashOrBank.id;
        docOperation['BankAccountTransit'] = CashOrBankIn.id;
        docOperation['BankConfirm'] = false;
        docOperation.f1 = docOperation['BankAccountOut'];
        docOperation.f2 = docOperation['BankAccountTransit'];
    }
    async FillOperationВыдачаДСПодотчетнику(docOperation, tx, params) {
        const CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        if (CashOrBank.type === 'Catalog.CashRegister') {
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // Расходный кассовый ордер
            docOperation.Operation = 'EC0A7030-1C06-11EA-97FB-7FA5141CBBD4'; // Из кассы - Выдача в подотчет (Статья ДДС)
            docOperation['CashRegister'] = this.CashOrBank;
            docOperation['Employee'] = this.CashRecipient;
            docOperation.f1 = docOperation['CashRegister'];
            docOperation.f2 = docOperation['Employee'];
            docOperation.f3 = docOperation['CashFlow'];
        }
        else if (CashOrBank.type === 'Catalog.BankAccount') {
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // Списание безналичных ДС
            docOperation.Operation = 'BF4B4126-D835-11E7-9D5E-E7807DB3B488'; // С р/с - подотчетному
            docOperation['Person'] = this.CashRecipient;
            docOperation['BankAccount'] = this.CashOrBank;
            docOperation['BankAccountPerson'] = this.CashRecipientBankAccount;
            docOperation['BankConfirm'] = false;
            docOperation['BankDocNumber'] = '';
            docOperation['BankConfirmDate'] = null;
            docOperation.f1 = docOperation['BankAccount'];
            docOperation.f2 = docOperation['Person'];
            docOperation.f3 = docOperation['Department'];
        }
    }
    async FillOperationПеремещениеДС(docOperation, tx, params) {
        const CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        const CashOrBankIn = (await std_lib_1.lib.doc.byId(this.CashOrBankIn, tx));
        if (!CashOrBankIn)
            throw new Error(`Приемник оплат не заполнен в ${this.description} `);
        if (CashOrBank.type === 'Catalog.CashRegister' && CashOrBankIn.type === 'Catalog.BankAccount') {
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // 4.2 - Расходный кассовый ордер
            docOperation.Operation = 'A6D6678C-BBA3-11E7-8E9F-1B4E8C03A1F5'; // Из кассы - на расчетный счет (в путь)
            docOperation['CashRegister'] = this.CashOrBank;
            docOperation['BankAccount'] = this.CashOrBankIn;
            docOperation.f1 = docOperation['CashRegister'];
            docOperation.f2 = docOperation['BankAccount'];
        }
        else if (CashOrBank.type === 'Catalog.CashRegister' && CashOrBankIn.type === 'Catalog.CashRegister') {
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // 4.2 - Расходный кассовый ордер
            docOperation.Operation = '1B411A80-DBF6-11E9-9DD5-EB2F495F92A0'; // Из кассы - в другую кассу (в путь)
            docOperation['CashRegisterOUT'] = this.CashOrBank;
            docOperation['CashRegisterIN'] = this.CashOrBankIn;
            docOperation.f1 = docOperation['CashRegisterOUT'];
            docOperation.f2 = docOperation['CashRegisterIN'];
        }
        else if (CashOrBank.type === 'Catalog.BankAccount' && CashOrBankIn.type === 'Catalog.CashRegister') {
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // 4.1 - Списание безналичных ДС
            docOperation.Operation = '369E2910-36CA-11EA-A774-7FBAF34E4AFA'; // С р/с - в кассу (в путь)
            docOperation['BankAccountOut'] = this.CashOrBank;
            docOperation['CashRegisterIn'] = this.CashOrBankIn;
            docOperation.f1 = docOperation['BankAccountOut'];
            docOperation.f2 = docOperation['CashRegisterIn'];
        }
        else if (CashOrBank.type === 'Catalog.BankAccount' && CashOrBankIn.type === 'Catalog.BankAccount') {
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // 4.1 - Списание безналичных ДС
            docOperation.Operation = '433D63DE-D849-11E7-83D2-2724888A9E4F'; // С р/с - на расчетный счет  (в путь)
            docOperation['BankAccountOut'] = this.CashOrBank;
            docOperation['BankAccountTransit'] = this.CashOrBankIn;
            docOperation['CashFlow'] = this.CashFlow;
            docOperation.f1 = docOperation['BankAccountOut'];
            docOperation.f2 = docOperation['BankAccountTransit'];
        }
    }
    async FillOperationВнутреннийЗайм(docOperation, tx, params) {
        const CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        const CashOrBankIn = (await std_lib_1.lib.doc.byId(this.CashOrBankIn, tx));
        if (!CashOrBankIn)
            throw new Error(`Приемник оплат не заполнен в ${this.description} `);
        if (CashOrBank.type !== 'Catalog.CashRegister')
            throw new Error('Источником оплат может быть только касса!');
        if (CashOrBankIn.type !== 'Catalog.CashRegister')
            throw new Error('Приемником оплат может быть только касса!');
        docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // 4.2 - Расходный кассовый ордер
        docOperation.Operation = 'C6BE0180-E64E-11EA-BB25-5F90F237D3BA'; // Из кассы - в другую кассу ИНТЕРКОМПАНИ (CRUD vs X100)
        docOperation.date = this.date;
        docOperation['CashRegisterOUT'] = this.CashOrBank;
        docOperation['CashRegisterIN'] = this.CashOrBankIn;
        docOperation['CashFlow'] = this.CashFlow;
        docOperation['IntercompanyOUT'] = this.company;
        docOperation['SKU'] = this.SKU;
        docOperation['CurrencyVia'] = this.сurrency;
        docOperation['AmountVia'] = this.Amount;
        docOperation.f1 = docOperation['CashRegisterOUT'];
        docOperation.f2 = docOperation['CashRegisterIN'];
        docOperation.f2 = docOperation['SKU'];
    }
    async FillOperationВыдачаЗаймаКонтрагенту(docOperation, tx, params) {
        const CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        if (CashOrBank.type === 'Catalog.CashRegister') {
            throw Error(`Не верно указан источник: ${CashOrBank}, может быть только банк!`);
        }
        else if (CashOrBank.type === 'Catalog.BankAccount') {
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // Списание безналичных ДС
            docOperation.Operation = '54AA5310-102E-11EA-AA50-31ECFB22CD33'; // С р/с - Выдача/Возврат кредитов и займов (Контрагент)
            docOperation['Counterpartie'] = this.CashRecipient;
            docOperation['BankAccount'] = this.CashOrBank;
            docOperation['BankAccountSupplier'] = this.CashRecipientBankAccount;
            docOperation['BankConfirm'] = false;
            docOperation['PaymentKind'] = this.PaymentKind || 'BODY';
            docOperation['BankDocNumber'] = '';
            docOperation['Loan'] = this.Loan;
            docOperation['BankConfirmDate'] = null;
            docOperation.f1 = docOperation['BankAccount'];
            docOperation.f2 = docOperation['Counterpartie'];
            docOperation.f3 = docOperation['Loan'];
        }
    }
    async FillOperationВыплатаЗаработнойПлаты(docOperation, tx, params) {
        let CashOrBank;
        CashOrBank = (await std_lib_1.lib.doc.byId(this.CashOrBank, tx));
        if (docOperation['BankAccount'] && CashOrBank.type === 'Catalog.BankAccount') {
            CashOrBank = { id: docOperation['BankAccount'], type: 'Catalog.BankAccount' };
        }
        if (!CashOrBank)
            throw new Error(`Источник оплат не заполнен в ${this.description} `);
        // let AmountBalancFromDoc: { CashRecipient: TypesCashRecipient, BankAccountPerson: CatalogPersonBankAccount, Amount: number }[] = [];
        const AmountBalancFromDoc = params ? params : await this.getAmountBalanceWithCashRecipientsAndBankAccounts(tx, true);
        docOperation['SalaryProject'] = this.SalaryProject;
        docOperation['PayRolls'] = [];
        docOperation['SalaryAnalytics'] = this.SalaryAnalitics;
        docOperation.f2 = docOperation['SalaryAnalytics'];
        docOperation.f3 = docOperation['Department'];
        docOperation['BankConfirm'] = false;
        if (CashOrBank.type === 'Catalog.CashRegister') {
            docOperation.Group = '42512520-BE7A-11E7-A145-CF5C65BC8F97'; // Расходный кассовый ордер
            docOperation.Operation = 'ABA074C0-41BF-11EA-A3C3-75A64D409CDC'; // Из кассы - выплата зарплаты (ВЕДОМОСТЬ В КАССУ)
            docOperation['CashRegister'] = CashOrBank.id;
            docOperation.f1 = docOperation['CashRegister'];
            docOperation['SalaryKind'] = 'PAID';
            docOperation.Amount = 0;
            const knowEmployee1 = [];
            for (const row of this.PayRolls) {
                const EmployeeBalance = AmountBalancFromDoc.filter(el => (el.CashRecipient === row.Employee));
                for (const emp of EmployeeBalance) {
                    if (knowEmployee1.indexOf(emp.CashRecipient) === -1)
                        knowEmployee1.push(emp.CashRecipient);
                    docOperation.Amount += emp.Amount;
                    docOperation['PayRolls'].push({
                        Employee: emp.CashRecipient,
                        Amount: emp.Amount
                    });
                }
            }
        }
        else if (CashOrBank.type === 'Catalog.BankAccount') {
            docOperation.Group = '269BBFE8-BE7A-11E7-9326-472896644AE4'; // 4.1 - Списание безналичных ДС
            docOperation.Operation = 'E617A320-41BB-11EA-A3C3-75A64D409CDC'; // С р/с - выплата зарплаты (ВЕДОМОСТЬ В БАНК)
            docOperation['BankAccount'] = CashOrBank.id;
            docOperation['EnforcementProceedings'] = this.EnforcementProceedings;
            docOperation.f1 = docOperation['BankAccount'];
            const knowEmployee2 = [];
            if (params) {
                const AmountBalance = params;
                for (const row of this.PayRolls) {
                    const EmployeeBalance = AmountBalance
                        .filter(el => (el.CashRecipient === row.Employee && row.BankAccount === el.BankAccountPerson));
                    for (const emp of EmployeeBalance) {
                        if (knowEmployee2.indexOf({ CashRecipient: emp.CashRecipient, BankAccountPerson: emp.BankAccountPerson }) === -1) {
                            knowEmployee2.push({ CashRecipient: emp.CashRecipient, BankAccountPerson: emp.BankAccountPerson });
                            docOperation['PayRolls'].push({
                                Employee: emp.CashRecipient,
                                Amount: emp.Amount,
                                Tax: row.Tax,
                                AmountPenalty: row.SalaryPenalty,
                                BankAccount: row.BankAccount
                            });
                        }
                    }
                }
            }
            else {
                const knowEmployee3 = [];
                for (const row of this.PayRolls) {
                    const EmployeeBalance = AmountBalancFromDoc.filter(el => (row.Employee === el.CashRecipient
                        && row.BankAccount === el.BankAccountPerson));
                    for (const emp of EmployeeBalance) {
                        if (knowEmployee3.indexOf({ CashRecipient: emp.CashRecipient, BankAccountPerson: emp.BankAccountPerson }) === -1)
                            knowEmployee3.push({ CashRecipient: emp.CashRecipient, BankAccountPerson: emp.BankAccountPerson });
                        docOperation['PayRolls'].push({
                            Employee: emp.CashRecipient,
                            Amount: emp.Amount,
                            Tax: row.Tax,
                            AmountPenalty: row.SalaryPenalty,
                            BankAccount: row.BankAccount
                        });
                    }
                }
            }
            docOperation.Amount = 0;
            for (const row of docOperation['PayRolls'])
                docOperation.Amount += row.Amount;
            // docOperation['PayRolls'].forEach(el => {docOperation.Amount+=el.Amount});
        }
    }
}
exports.DocumentCashRequestServer = DocumentCashRequestServer;
//# sourceMappingURL=Document.CashRequest.server.js.map