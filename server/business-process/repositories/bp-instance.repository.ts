import { createHash } from 'crypto';
import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessInstanceStatus,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import { parseJsonObject, toJson } from './bp-json';

type InstanceRow = {
  id: string;
  templateId: string;
  templateCode: string;
  templateVersion: number;
  templateHash: string;
  objectType: string;
  objectId: string;
  status: BusinessProcessInstanceStatus;
  currentStepKey?: string | null;
  startedAt: Date;
  completedAt?: Date | null;
  author?: string | null;
  company?: string | null;
  context?: unknown;
  idempotencyKey?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
};

export function createBusinessProcessTemplateHash(template: BusinessProcessTemplate): string {
  return createHash('sha256')
    .update(stableStringify({
      code: template.code,
      version: template.version,
      objectTypes: template.objectTypes,
      startMode: template.startMode,
      startCondition: template.startCondition,
      steps: template.steps,
      transitions: template.transitions,
      parameters: template.parameters,
    }))
    .digest('hex');
}

export class BusinessProcessInstanceRepository {
  constructor(private readonly db: MSSQL) {}

  async getById(id: string): Promise<BusinessProcessInstance | null> {
    const row = await this.db.oneOrNone<InstanceRow>(`${this.selectSql()} WHERE id = @p1`, [id]);
    return row ? this.mapInstance(row) : null;
  }

  async getRunningForObject(args: {
    objectType: string;
    objectId: string;
    templateCode: string;
  }): Promise<BusinessProcessInstance | null> {
    const row = await this.db.oneOrNone<InstanceRow>(
      `${this.selectSql()}
       WHERE objectType = @p1
         AND objectId = @p2
         AND templateCode = @p3
         AND status = N'RUNNING'`,
      [args.objectType, args.objectId, args.templateCode],
    );
    return row ? this.mapInstance(row) : null;
  }

  async getByObject(args: {
    objectType: string;
    objectId: string;
  }): Promise<BusinessProcessInstance[]> {
    const rows = await this.db.manyOrNone<InstanceRow>(
      `${this.selectSql()}
       WHERE objectType = @p1
         AND objectId = @p2
       ORDER BY startedAt DESC, createdAt DESC`,
      [args.objectType, args.objectId],
    );
    return rows.map(row => this.mapInstance(row));
  }

  async create(input: {
    template: BusinessProcessTemplate;
    templateHash: string;
    objectType: string;
    objectId: string;
    currentStepKey?: string | null;
    author?: string | null;
    company?: string | null;
    context?: Record<string, unknown> | null;
    idempotencyKey?: string | null;
  }): Promise<BusinessProcessInstance> {
    const id = uuid();
    await this.db.none(
      `INSERT INTO dbo.BusinessProcessInstance (
        id, templateId, templateCode, templateVersion, templateHash, objectType,
        objectId, status, currentStepKey, author, company, context, idempotencyKey
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, @p6,
        @p7, N'RUNNING', @p8, @p9, @p10, JSON_QUERY(@p11), @p12
      )`,
      [
        id,
        input.template.id,
        input.template.code,
        input.template.version,
        input.templateHash,
        input.objectType,
        input.objectId,
        input.currentStepKey || null,
        input.author || null,
        input.company || null,
        toJson(input.context),
        input.idempotencyKey || null,
      ],
    );

    const instance = await this.getById(id);
    if (!instance) throw new Error(`BusinessProcessInstanceRepository.create failed to load created instance ${id}`);
    return instance;
  }

  async setCurrentStep(args: {
    instanceId: string;
    stepKey?: string | null;
  }): Promise<void> {
    await this.db.none(
      `UPDATE dbo.BusinessProcessInstance
       SET currentStepKey = @p2,
           updatedAt = SYSUTCDATETIME()
       WHERE id = @p1`,
      [args.instanceId, args.stepKey || null],
    );
  }

  async complete(args: {
    instanceId: string;
    status: 'COMPLETED' | 'REJECTED' | 'CANCELLED' | 'FAILED';
  }): Promise<void> {
    const instance = await this.getById(args.instanceId);
    if (!instance) throw new Error(`Business process instance ${args.instanceId} not found`);
    if (instance.status !== 'RUNNING') {
      throw new Error(`Business process instance ${args.instanceId} is not running`);
    }

    await this.db.none(
      `UPDATE dbo.BusinessProcessInstance
       SET status = @p2,
           completedAt = SYSUTCDATETIME(),
           updatedAt = SYSUTCDATETIME()
       WHERE id = @p1`,
      [args.instanceId, args.status],
    );
  }

  async getTemplateSnapshotInfo(instanceId: string): Promise<{
    instance: BusinessProcessInstance;
    templateCode: string;
    templateVersion: number;
  }> {
    const instance = await this.getById(instanceId);
    if (!instance) throw new Error(`Business process instance ${instanceId} not found`);
    return {
      instance,
      templateCode: instance.templateCode,
      templateVersion: instance.templateVersion,
    };
  }

  private selectSql(): string {
    return `SELECT
      id, templateId, templateCode, templateVersion, templateHash, objectType,
      objectId, status, currentStepKey, startedAt, completedAt, author, company,
      context, idempotencyKey, createdAt, updatedAt
    FROM dbo.BusinessProcessInstance`;
  }

  private mapInstance(row: InstanceRow): BusinessProcessInstance {
    return {
      id: row.id,
      templateId: row.templateId,
      templateCode: row.templateCode,
      templateVersion: Number(row.templateVersion),
      templateHash: row.templateHash,
      objectType: row.objectType,
      objectId: row.objectId,
      status: row.status,
      currentStepKey: row.currentStepKey || undefined,
      startedAt: row.startedAt,
      completedAt: row.completedAt || null,
      author: row.author || null,
      company: row.company || null,
      context: parseJsonObject<Record<string, unknown>>(row.context, {}),
      idempotencyKey: row.idempotencyKey || null,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    };
  }
}

function stableStringify(value: unknown): string {
  if (value == null || typeof value !== 'object') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(item => stableStringify(item)).join(',')}]`;

  const source = value as Record<string, unknown>;
  return `{${Object.keys(source).sort().map(key => `${JSON.stringify(key)}:${stableStringify(source[key])}`).join(',')}}`;
}
