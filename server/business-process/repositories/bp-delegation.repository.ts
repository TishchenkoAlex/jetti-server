import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import { BusinessProcessDelegation } from '../types/business-process.types';

type DelegationRow = {
  id: string;
  userFrom: string;
  userTo: string;
  role?: string | null;
  processTemplate?: string | null;
  company?: string | null;
  dateFrom: Date;
  dateTo?: Date | null;
  active: boolean;
};

export class BusinessProcessDelegationRepository {
  constructor(private readonly db: MSSQL) {}

  async create(input: {
    userFrom: string;
    userTo: string;
    role?: string | null;
    processTemplate?: string | null;
    company?: string | null;
    dateFrom: Date;
    dateTo?: Date | null;
    comment?: string | null;
  }): Promise<BusinessProcessDelegation> {
    const id = uuid();
    await this.db.none(
      `INSERT INTO dbo.BusinessProcessDelegation (
        id, userFrom, userTo, role, processTemplate, company, dateFrom, dateTo, active, comment
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, 1, @p9
      )`,
      [
        id,
        input.userFrom,
        input.userTo,
        input.role || null,
        input.processTemplate || null,
        input.company || null,
        input.dateFrom,
        input.dateTo || null,
        input.comment || null,
      ],
    );

    const delegation = await this.getById(id);
    if (!delegation) throw new Error(`BusinessProcessDelegationRepository.create failed to load created delegation ${id}`);
    return delegation;
  }

  async getById(id: string): Promise<BusinessProcessDelegation | null> {
    const row = await this.db.oneOrNone<DelegationRow>(`${this.selectSql()} WHERE id = @p1`, [id]);
    return row ? this.mapDelegation(row) : null;
  }

  async listActiveForUserTo(args: {
    userTo: string;
    date: Date;
    processTemplate?: string | null;
    company?: string | null;
  }): Promise<BusinessProcessDelegation[]> {
    const rows = await this.db.manyOrNone<DelegationRow>(
      `${this.selectSql()}
       WHERE userTo = @p1
         AND active = 1
         AND dateFrom <= @p2
         AND (dateTo IS NULL OR dateTo >= @p2)
         AND (@p3 IS NULL OR processTemplate IS NULL OR processTemplate = @p3)
         AND (@p4 IS NULL OR company IS NULL OR company = @p4)
       ORDER BY dateFrom DESC, createdAt DESC`,
      [args.userTo, args.date, args.processTemplate || null, args.company || null],
    );
    return rows.map(row => this.mapDelegation(row));
  }

  async listActiveForUserFrom(args: {
    userFrom: string;
    date: Date;
    processTemplate?: string | null;
    company?: string | null;
  }): Promise<BusinessProcessDelegation[]> {
    const rows = await this.db.manyOrNone<DelegationRow>(
      `${this.selectSql()}
       WHERE userFrom = @p1
         AND active = 1
         AND dateFrom <= @p2
         AND (dateTo IS NULL OR dateTo >= @p2)
         AND (@p3 IS NULL OR processTemplate IS NULL OR processTemplate = @p3)
         AND (@p4 IS NULL OR company IS NULL OR company = @p4)
       ORDER BY dateFrom DESC, createdAt DESC`,
      [args.userFrom, args.date, args.processTemplate || null, args.company || null],
    );
    return rows.map(row => this.mapDelegation(row));
  }

  async listMine(user: string, date: Date = new Date()): Promise<BusinessProcessDelegation[]> {
    const rows = await this.db.manyOrNone<DelegationRow>(
      `${this.selectSql()}
       WHERE (userFrom = @p1 OR userTo = @p1)
         AND active = 1
         AND dateFrom <= @p2
         AND (dateTo IS NULL OR dateTo >= @p2)
       ORDER BY dateFrom DESC, createdAt DESC`,
      [user, date],
    );
    return rows.map(row => this.mapDelegation(row));
  }

  async cancel(id: string): Promise<void> {
    await this.db.none(
      `UPDATE dbo.BusinessProcessDelegation
       SET active = 0
       WHERE id = @p1`,
      [id],
    );
  }

  private selectSql(): string {
    return `SELECT
      id, userFrom, userTo, role, processTemplate, company, dateFrom, dateTo, active
    FROM dbo.BusinessProcessDelegation`;
  }

  private mapDelegation(row: DelegationRow): BusinessProcessDelegation {
    return {
      id: row.id,
      userFrom: row.userFrom,
      userTo: row.userTo,
      role: row.role || null,
      processTemplate: row.processTemplate || null,
      company: row.company || null,
      dateFrom: row.dateFrom,
      dateTo: row.dateTo || null,
      active: Boolean(row.active),
    };
  }
}
