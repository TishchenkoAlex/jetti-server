import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import {
  BusinessProcessStep,
  BusinessProcessTemplate,
  BusinessProcessTemplateStatus,
  BusinessProcessTransition,
} from '../types/business-process.types';
import { parseJsonArray, parseJsonObject, toJson } from './bp-json';

type TemplateRow = {
  id: string;
  code: string;
  description?: string | null;
  active: boolean;
  version: number;
  status: BusinessProcessTemplateStatus;
  objectTypes: unknown;
  startMode: BusinessProcessTemplate['startMode'];
  startCondition?: unknown;
  steps: unknown;
  transitions: unknown;
  parameters?: unknown;
  createdAt?: Date;
  updatedAt?: Date;
  createdBy?: string | null;
  activatedAt?: Date | null;
  archivedAt?: Date | null;
};

export type CreateBusinessProcessTemplateDraftInput =
  Omit<BusinessProcessTemplate, 'id' | 'active' | 'version' | 'status'> & {
    createdBy?: string | null;
  };

export class BusinessProcessTemplateRepository {
  constructor(private readonly db: MSSQL) {}

  async getById(id: string): Promise<BusinessProcessTemplate | null> {
    const row = await this.db.oneOrNone<TemplateRow>(`${this.selectSql()} WHERE id = @p1`, [id]);
    return row ? this.mapTemplate(row) : null;
  }

  async getByCodeAndVersion(code: string, version: number): Promise<BusinessProcessTemplate | null> {
    const row = await this.db.oneOrNone<TemplateRow>(`${this.selectSql()} WHERE code = @p1 AND version = @p2`, [code, version]);
    return row ? this.mapTemplate(row) : null;
  }

  async getActiveByCode(code: string): Promise<BusinessProcessTemplate | null> {
    const row = await this.db.oneOrNone<TemplateRow>(
      `${this.selectSql()} WHERE code = @p1 AND status = N'ACTIVE'`,
      [code],
    );
    return row ? this.mapTemplate(row) : null;
  }

  async list(filter: {
    code?: string;
    status?: BusinessProcessTemplateStatus;
    objectType?: string;
  } = {}): Promise<BusinessProcessTemplate[]> {
    const where: string[] = ['1 = 1'];
    const params: unknown[] = [];

    if (filter.code) {
      params.push(filter.code);
      where.push(`code = @p${params.length}`);
    }

    if (filter.status) {
      params.push(filter.status);
      where.push(`status = @p${params.length}`);
    }

    if (filter.objectType) {
      params.push(filter.objectType);
      where.push(`EXISTS (SELECT 1 FROM OPENJSON(objectTypes) WHERE [value] = @p${params.length})`);
    }

    const rows = await this.db.manyOrNone<TemplateRow>(
      `${this.selectSql()} WHERE ${where.join(' AND ')} ORDER BY code, version DESC`,
      params,
    );
    return rows.map(row => this.mapTemplate(row));
  }

  async listActiveForStart(args: {
    objectType: string;
    startMode: BusinessProcessTemplate['startMode'];
    templateCode?: string | null;
  }): Promise<BusinessProcessTemplate[]> {
    const where = [
      'status = N\'ACTIVE\'',
      'active = 1',
      'startMode = @p1',
      `EXISTS (
        SELECT 1
        FROM OPENJSON(objectTypes)
        WHERE [value] = @p2
      )`,
    ];
    const params: unknown[] = [args.startMode, args.objectType];

    if (args.templateCode) {
      params.push(args.templateCode);
      where.push(`code = @p${params.length}`);
    }

    const rows = await this.db.manyOrNone<TemplateRow>(
      `${this.selectSql()}
       WHERE ${where.join(' AND ')}
       ORDER BY code, version DESC`,
      params,
    );
    return rows.map(row => this.mapTemplate(row));
  }

  async createDraft(input: CreateBusinessProcessTemplateDraftInput): Promise<BusinessProcessTemplate> {
    const id = uuid();
    const versionRow = await this.db.oneOrNone<{ version: number }>(
      `SELECT ISNULL(MAX(version), 0) + 1 version
       FROM dbo.BusinessProcessTemplate
       WHERE code = @p1`,
      [input.code],
    );
    const version = versionRow ? Number(versionRow.version) : 1;

    await this.db.none(
      `INSERT INTO dbo.BusinessProcessTemplate (
        id, code, description, active, version, status, objectTypes, startMode,
        startCondition, steps, transitions, parameters, createdBy
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, N'DRAFT', JSON_QUERY(@p6), @p7,
        JSON_QUERY(@p8), JSON_QUERY(@p9), JSON_QUERY(@p10), JSON_QUERY(@p11), @p12
      )`,
      [
        id,
        input.code,
        input.description || null,
        false,
        version,
        toJson(input.objectTypes),
        input.startMode,
        toJson(input.startCondition),
        toJson(input.steps),
        toJson(input.transitions),
        toJson(input.parameters),
        input.createdBy || null,
      ],
    );

    const template = await this.getById(id);
    if (!template) throw new Error(`BusinessProcessTemplateRepository.createDraft failed to load created template ${id}`);
    return template;
  }

  async activate(id: string, user?: string | null): Promise<BusinessProcessTemplate> {
    const run = async (db: MSSQL) => {
      const template = await new BusinessProcessTemplateRepository(db).getById(id);
      if (!template) throw new Error(`Business process template ${id} not found`);
      if (template.status === 'ARCHIVED') {
        throw new Error(`Business process template ${id} is archived and cannot be activated`);
      }

      await db.none(
        `UPDATE dbo.BusinessProcessTemplate
         SET status = N'ARCHIVED',
             active = 0,
             archivedAt = COALESCE(archivedAt, SYSUTCDATETIME()),
             updatedAt = SYSUTCDATETIME()
         WHERE code = @p1
           AND status = N'ACTIVE'
           AND id <> @p2`,
        [template.code, id],
      );

      await db.none(
        `UPDATE dbo.BusinessProcessTemplate
         SET status = N'ACTIVE',
             active = 1,
             activatedAt = SYSUTCDATETIME(),
             archivedAt = NULL,
             updatedAt = SYSUTCDATETIME()
         WHERE id = @p1`,
        [id],
      );
    };

    if (this.isTransaction()) {
      await run(this.db);
    } else {
      await this.db.tx(async tx => run(tx));
    }

    const activated = await this.getById(id);
    if (!activated) throw new Error(`Business process template ${id} not found after activation`);
    return activated;
  }

  async archive(id: string, user?: string | null): Promise<void> {
    await this.db.none(
      `UPDATE dbo.BusinessProcessTemplate
       SET status = N'ARCHIVED',
           active = 0,
           archivedAt = SYSUTCDATETIME(),
           updatedAt = SYSUTCDATETIME()
       WHERE id = @p1`,
      [id],
    );
  }

  private selectSql(): string {
    return `SELECT
      id, code, description, active, version, status, objectTypes, startMode,
      startCondition, steps, transitions, parameters, createdAt, updatedAt,
      createdBy, activatedAt, archivedAt
    FROM dbo.BusinessProcessTemplate`;
  }

  private mapTemplate(row: TemplateRow): BusinessProcessTemplate {
    return {
      id: row.id,
      code: row.code,
      description: row.description || undefined,
      active: Boolean(row.active),
      version: Number(row.version),
      status: row.status,
      objectTypes: parseJsonArray<string>(row.objectTypes, []),
      startMode: row.startMode,
      startCondition: row.startCondition == null ? undefined : row.startCondition,
      steps: parseJsonArray<BusinessProcessStep>(row.steps, []),
      transitions: parseJsonArray<BusinessProcessTransition>(row.transitions, []),
      parameters: parseJsonObject<Record<string, unknown>>(row.parameters, undefined as any),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      createdBy: row.createdBy || null,
      activatedAt: row.activatedAt || null,
      archivedAt: row.archivedAt || null,
    };
  }

  private isTransaction(): boolean {
    return Boolean((this.db as any).connection);
  }
}
