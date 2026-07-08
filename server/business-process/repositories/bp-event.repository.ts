import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import { BusinessProcessEvent, BusinessProcessEventType } from '../types/business-process.types';
import { parseJsonObject, toJson } from './bp-json';

type EventRow = {
  id: string;
  instanceId: string;
  taskId?: string | null;
  eventType: BusinessProcessEventType;
  eventUser?: string | null;
  eventAt: Date;
  payload?: unknown;
  eventKey?: string | null;
};

export class BusinessProcessEventRepository {
  constructor(private readonly db: MSSQL) {}

  async getById(id: string): Promise<BusinessProcessEvent | null> {
    const row = await this.db.oneOrNone<EventRow>(`${this.selectSql()} WHERE id = @p1`, [id]);
    return row ? this.mapEvent(row) : null;
  }

  async append(input: {
    instanceId: string;
    taskId?: string | null;
    eventType: BusinessProcessEventType;
    user?: string | null;
    payload?: Record<string, unknown> | null;
    eventKey?: string | null;
  }): Promise<BusinessProcessEvent> {
    const id = uuid();
    await this.db.none(
      `INSERT INTO dbo.BusinessProcessEvent (
        id, instanceId, taskId, eventType, eventUser, payload, eventKey
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, JSON_QUERY(@p6), @p7
      )`,
      [
        id,
        input.instanceId,
        input.taskId || null,
        input.eventType,
        input.user || null,
        toJson(input.payload),
        input.eventKey || null,
      ],
    );

    const event = await this.getById(id);
    if (!event) throw new Error(`BusinessProcessEventRepository.append failed to load created event ${id}`);
    return event;
  }

  async appendOnce(input: {
    instanceId: string;
    taskId?: string | null;
    eventType: BusinessProcessEventType;
    user?: string | null;
    payload?: Record<string, unknown> | null;
    eventKey: string;
  }): Promise<BusinessProcessEvent | null> {
    const existing = await this.getByEventKey(input.eventKey);
    if (existing) return null;

    try {
      return await this.append(input);
    } catch (err) {
      if (this.isDuplicateKeyError(err)) return null;
      throw err;
    }
  }

  async listByInstance(instanceId: string): Promise<BusinessProcessEvent[]> {
    const rows = await this.db.manyOrNone<EventRow>(
      `${this.selectSql()} WHERE instanceId = @p1 ORDER BY eventAt, id`,
      [instanceId],
    );
    return rows.map(row => this.mapEvent(row));
  }

  private async getByEventKey(eventKey: string): Promise<BusinessProcessEvent | null> {
    const row = await this.db.oneOrNone<EventRow>(`${this.selectSql()} WHERE eventKey = @p1`, [eventKey]);
    return row ? this.mapEvent(row) : null;
  }

  private selectSql(): string {
    return `SELECT
      id, instanceId, taskId, eventType, eventUser, eventAt, payload, eventKey
    FROM dbo.BusinessProcessEvent`;
  }

  private mapEvent(row: EventRow): BusinessProcessEvent {
    return {
      id: row.id,
      instanceId: row.instanceId,
      taskId: row.taskId || null,
      eventType: row.eventType,
      user: row.eventUser || null,
      date: row.eventAt,
      payload: parseJsonObject<Record<string, unknown>>(row.payload, null as any),
      eventKey: row.eventKey || null,
    };
  }

  private isDuplicateKeyError(err: unknown): boolean {
    const error = err as { number?: number; code?: string; message?: string };
    return error.number === 2601
      || error.number === 2627
      || String(error.message || '').includes('UX_BusinessProcessEvent_EventKey');
  }
}
