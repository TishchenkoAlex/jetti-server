import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import { BusinessProcessTask, BusinessProcessTaskStatus } from '../types/business-process.types';
import { toJson } from './bp-json';

type TaskRow = {
  id: string;
  instanceId: string;
  objectType: string;
  objectId: string;
  stepKey: string;
  title: string;
  status: BusinessProcessTaskStatus;
  assigneeUser?: string | null;
  assigneeRole?: string | null;
  activeFrom?: Date | null;
  dueAt?: Date | null;
  completedAt?: Date | null;
  decisionUser?: string | null;
  decisionComment?: string | null;
  delegatedFromUser?: string | null;
  redirectedFromUser?: string | null;
  penaltyRuleSnapshot?: unknown;
  penaltyAmount?: number | null;
  createdAt?: Date;
};

export type CreateBusinessProcessTaskInput = {
  instanceId: string;
  objectType: string;
  objectId: string;
  stepKey: string;
  title: string;
  status: BusinessProcessTaskStatus;
  assigneeUser?: string | null;
  assigneeRole?: string | null;
  activeFrom?: Date | null;
  dueAt?: Date | null;
  delegatedFromUser?: string | null;
  redirectedFromUser?: string | null;
  penaltyRuleSnapshot?: unknown;
  penaltyAmount?: number | null;
};

export class BusinessProcessTaskRepository {
  constructor(private readonly db: MSSQL) {}

  async getById(id: string): Promise<BusinessProcessTask | null> {
    const row = await this.db.oneOrNone<TaskRow>(`${this.selectSql()} WHERE id = @p1`, [id]);
    return row ? this.mapTask(row) : null;
  }

  async listByInstance(instanceId: string): Promise<BusinessProcessTask[]> {
    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()} WHERE instanceId = @p1 ORDER BY createdAt, id`,
      [instanceId],
    );
    return rows.map(row => this.mapTask(row));
  }

  async listByInstanceStep(args: {
    instanceId: string;
    stepKey: string;
    statuses?: BusinessProcessTaskStatus[];
  }): Promise<BusinessProcessTask[]> {
    const params: unknown[] = [args.instanceId, args.stepKey];
    const statusWhere = args.statuses && args.statuses.length
      ? ` AND status IN (${args.statuses.map(status => {
        params.push(status);
        return `@p${params.length}`;
      }).join(', ')})`
      : '';

    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE instanceId = @p1
         AND stepKey = @p2
         ${statusWhere}
       ORDER BY createdAt, id`,
      params,
    );
    return rows.map(row => this.mapTask(row));
  }

  async create(input: CreateBusinessProcessTaskInput): Promise<BusinessProcessTask> {
    const id = uuid();
    await this.db.none(
      `INSERT INTO dbo.BusinessProcessTask (
        id, instanceId, objectType, objectId, stepKey, title, status,
        assigneeUser, assigneeRole, activeFrom, dueAt, delegatedFromUser,
        redirectedFromUser, penaltyRuleSnapshot, penaltyAmount
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, @p6, @p7,
        @p8, @p9, @p10, @p11, @p12,
        @p13, JSON_QUERY(@p14), @p15
      )`,
      [
        id,
        input.instanceId,
        input.objectType,
        input.objectId,
        input.stepKey,
        input.title,
        input.status,
        input.assigneeUser || null,
        input.assigneeRole || null,
        input.activeFrom || null,
        input.dueAt || null,
        input.delegatedFromUser || null,
        input.redirectedFromUser || null,
        toJson(input.penaltyRuleSnapshot),
        input.penaltyAmount == null ? null : input.penaltyAmount,
      ],
    );

    const task = await this.getById(id);
    if (!task) throw new Error(`BusinessProcessTaskRepository.create failed to load created task ${id}`);
    return task;
  }

  async createMany(inputs: CreateBusinessProcessTaskInput[]): Promise<BusinessProcessTask[]> {
    const tasks: BusinessProcessTask[] = [];
    for (const input of inputs) tasks.push(await this.create(input));
    return tasks;
  }

  async setDecision(args: {
    taskId: string;
    status: 'APPROVED' | 'REJECTED' | 'REDIRECTED' | 'CANCELLED';
    decisionUser?: string | null;
    decisionComment?: string | null;
    redirectedFromUser?: string | null;
  }): Promise<BusinessProcessTask> {
    const task = await this.getById(args.taskId);
    if (!task) throw new Error(`Business process task ${args.taskId} not found`);

    await this.db.none(
      `UPDATE dbo.BusinessProcessTask
       SET status = @p2,
           decisionUser = @p3,
           decisionComment = @p4,
           redirectedFromUser = COALESCE(@p5, redirectedFromUser),
           completedAt = SYSUTCDATETIME()
       WHERE id = @p1`,
      [
        args.taskId,
        args.status,
        args.decisionUser || null,
        args.decisionComment || null,
        args.redirectedFromUser || null,
      ],
    );

    const updated = await this.getById(args.taskId);
    if (!updated) throw new Error(`Business process task ${args.taskId} not found after decision update`);
    return updated;
  }

  async cancelSiblingTasks(args: {
    instanceId: string;
    stepKey: string;
    exceptTaskId: string;
    decisionUser?: string | null;
    reason?: string | null;
  }): Promise<BusinessProcessTask[]> {
    const siblings = await this.listByInstanceStep({
      instanceId: args.instanceId,
      stepKey: args.stepKey,
      statuses: ['ACTIVE', 'WAITING', 'OVERDUE'],
    });
    const cancelled: BusinessProcessTask[] = [];

    for (const sibling of siblings.filter(task => task.id !== args.exceptTaskId)) {
      cancelled.push(await this.setDecision({
        taskId: sibling.id,
        status: 'CANCELLED',
        decisionUser: args.decisionUser || null,
        decisionComment: args.reason || null,
      }));
    }

    return cancelled;
  }

  async listActiveByAssignee(args: {
    userId: string;
    roles?: string[];
  }): Promise<BusinessProcessTask[]> {
    const params: unknown[] = [args.userId];
    const roleWhere = args.roles && args.roles.length
      ? ` OR assigneeRole IN (${args.roles.map(role => {
        params.push(role);
        return `@p${params.length}`;
      }).join(', ')})`
      : '';

    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE status IN (N'ACTIVE', N'WAITING', N'OVERDUE')
         AND (assigneeUser = @p1${roleWhere})
       ORDER BY dueAt, activeFrom, createdAt`,
      params,
    );
    return rows.map(row => this.mapTask(row));
  }

  private selectSql(): string {
    return `SELECT
      id, instanceId, objectType, objectId, stepKey, title, status,
      assigneeUser, assigneeRole, activeFrom, dueAt, completedAt,
      decisionUser, decisionComment, delegatedFromUser, redirectedFromUser,
      penaltyRuleSnapshot, penaltyAmount, createdAt
    FROM dbo.BusinessProcessTask`;
  }

  private mapTask(row: TaskRow): BusinessProcessTask {
    return {
      id: row.id,
      instanceId: row.instanceId,
      objectType: row.objectType,
      objectId: row.objectId,
      stepKey: row.stepKey,
      title: row.title,
      status: row.status,
      assigneeUser: row.assigneeUser || null,
      assigneeRole: row.assigneeRole || null,
      activeFrom: row.activeFrom || null,
      dueAt: row.dueAt || null,
      completedAt: row.completedAt || null,
      decisionUser: row.decisionUser || null,
      decisionComment: row.decisionComment || null,
      delegatedFromUser: row.delegatedFromUser || null,
      redirectedFromUser: row.redirectedFromUser || null,
      penaltyRuleSnapshot: row.penaltyRuleSnapshot,
      penaltyAmount: row.penaltyAmount == null ? null : Number(row.penaltyAmount),
      createdAt: row.createdAt,
    };
  }
}
