import { v4 as uuid } from 'uuid';
import { MSSQL } from '../../mssql';
import { BusinessProcessTask, BusinessProcessTaskStatus } from '../types/business-process.types';

type TaskRow = {
  id: string;
  instanceId: string;
  objectType: string;
  objectId: string;
  stepKey: string;
  title: string;
  status: BusinessProcessTaskStatus;
  assigneeUser: string;
  activeFrom?: Date | null;
  deadlineAt?: Date | null;
  deadlineReachedAt?: Date | null;
  completedAt?: Date | null;
  decisionKey?: string | null;
  decisionUser?: string | null;
  decisionComment?: string | null;
  decisionSource?: 'USER' | 'SYSTEM' | null;
  delegatedFromUser?: string | null;
  redirectedFromUser?: string | null;
  penaltyStartedAt?: Date | null;
  penaltyAmount?: number | null;
  penaltyLastCalculatedAt?: Date | null;
  nextPenaltyCalculationAt?: Date | null;
  createdAt?: Date;
};

export type CreateBusinessProcessTaskInput = {
  instanceId: string;
  objectType: string;
  objectId: string;
  stepKey: string;
  title: string;
  status: BusinessProcessTaskStatus;
  assignee: BusinessProcessTask['assignee'];
  activation?: BusinessProcessTask['activation'];
  deadline?: BusinessProcessTask['deadline'];
  penalty?: BusinessProcessTask['penalty'];
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
        assigneeUser, activeFrom, deadlineAt, deadlineReachedAt, delegatedFromUser,
        redirectedFromUser, penaltyStartedAt, penaltyAmount,
        penaltyLastCalculatedAt, nextPenaltyCalculationAt
      )
      VALUES (
        @p1, @p2, @p3, @p4, @p5, @p6, @p7,
        @p8, @p9, @p10, @p11, @p12,
        @p13, @p14, @p15,
        @p16, @p17
      )`,
      [
        id,
        input.instanceId,
        input.objectType,
        input.objectId,
        input.stepKey,
        input.title,
        input.status,
        input.assignee.user,
        input.activation?.at || null,
        input.deadline?.at || null,
        input.deadline?.reachedAt || null,
        input.assignee.delegatedFrom || null,
        input.assignee.redirectedFrom || null,
        input.penalty?.startedAt || null,
        input.penalty?.amount == null ? null : input.penalty.amount,
        input.penalty?.lastCalculatedAt || null,
        input.penalty?.nextCalculationAt || null,
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
    status: 'COMPLETED' | 'APPROVED' | 'REJECTED' | 'REDIRECTED' | 'AUTO_COMPLETED' | 'TIMEOUT' | 'CANCELLED';
    decision?: BusinessProcessTask['decision'];
    redirectedFromUser?: string | null;
  }): Promise<BusinessProcessTask> {
    const task = await this.getById(args.taskId);
    if (!task) throw new Error(`Business process task ${args.taskId} not found`);

    await this.db.none(
      `UPDATE dbo.BusinessProcessTask
       SET status = @p2,
           decisionUser = @p3,
           decisionComment = @p4,
           decisionKey = @p5,
           decisionSource = @p6,
           redirectedFromUser = COALESCE(@p7, redirectedFromUser),
           completedAt = SYSUTCDATETIME()
       WHERE id = @p1`,
      [
        args.taskId,
        args.status,
        args.decision?.user || null,
        args.decision?.comment || null,
        args.decision?.key || null,
        args.decision?.source || null,
        args.redirectedFromUser || null,
      ],
    );

    const updated = await this.getById(args.taskId);
    if (!updated) throw new Error(`Business process task ${args.taskId} not found after decision update`);
    return updated;
  }

  async setDecisionIfStatusIn(args: {
    taskId: string;
    allowedStatuses: BusinessProcessTaskStatus[];
    status: 'COMPLETED' | 'APPROVED' | 'REJECTED' | 'REDIRECTED' | 'AUTO_COMPLETED' | 'TIMEOUT' | 'CANCELLED';
    decision?: BusinessProcessTask['decision'];
    redirectedFromUser?: string | null;
  }): Promise<BusinessProcessTask | null> {
    if (!args.allowedStatuses.length) return null;

    const params: unknown[] = [
      args.taskId,
      args.status,
      args.decision?.user || null,
      args.decision?.comment || null,
      args.decision?.key || null,
      args.decision?.source || null,
      args.redirectedFromUser || null,
      ...args.allowedStatuses,
    ];
    const statusParams = args.allowedStatuses.map((status, index) => `@p${index + 8}`).join(', ');

    const row = await this.db.oneOrNone<TaskRow>(
      `UPDATE dbo.BusinessProcessTask
       SET status = @p2,
           decisionUser = @p3,
           decisionComment = @p4,
           decisionKey = @p5,
           decisionSource = @p6,
           redirectedFromUser = COALESCE(@p7, redirectedFromUser),
           completedAt = SYSUTCDATETIME()
       OUTPUT
           inserted.id,
           inserted.instanceId,
           inserted.objectType,
           inserted.objectId,
           inserted.stepKey,
           inserted.title,
           inserted.status,
           inserted.assigneeUser,
           inserted.activeFrom,
           inserted.deadlineAt,
           inserted.deadlineReachedAt,
           inserted.completedAt,
           inserted.decisionKey,
           inserted.decisionUser,
           inserted.decisionComment,
           inserted.decisionSource,
           inserted.delegatedFromUser,
           inserted.redirectedFromUser,
           inserted.penaltyStartedAt,
           inserted.penaltyAmount,
           inserted.penaltyLastCalculatedAt,
           inserted.nextPenaltyCalculationAt,
           inserted.createdAt
       WHERE id = @p1
         AND status IN (${statusParams})`,
      params,
    );

    return row ? this.mapTask(row) : null;
  }

  async listWaitingToActivate(now: Date, limit: number = 500): Promise<BusinessProcessTask[]> {
    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE id IN (
         SELECT TOP (CAST(@p2 AS INT)) id
         FROM dbo.BusinessProcessTask
         WHERE status = N'WAITING'
           AND activeFrom IS NOT NULL
           AND activeFrom <= @p1
         ORDER BY activeFrom, createdAt, id
       )
       ORDER BY activeFrom, createdAt, id`,
      [now, limit],
    );
    return rows.map(row => this.mapTask(row));
  }

  async activateIfWaiting(args: {
    taskId: string;
    now: Date;
  }): Promise<BusinessProcessTask | null> {
    const row = await this.db.oneOrNone<TaskRow>(
      `${this.updateOutputSql()}
       WHERE id = @p1
         AND status = N'WAITING'
         AND activeFrom <= @p2`,
      [args.taskId, args.now],
    );
    return row ? this.mapTask(row) : null;
  }

  async listActiveDue(now: Date, limit: number = 500): Promise<BusinessProcessTask[]> {
    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE id IN (
         SELECT TOP (CAST(@p2 AS INT)) id
         FROM dbo.BusinessProcessTask
         WHERE status = N'ACTIVE'
           AND deadlineAt IS NOT NULL
           AND deadlineAt <= @p1
         ORDER BY deadlineAt, createdAt, id
       )
       ORDER BY deadlineAt, createdAt, id`,
      [now, limit],
    );
    return rows.map(row => this.mapTask(row));
  }

  async markOverdueIfActive(args: {
    taskId: string;
    now: Date;
  }): Promise<BusinessProcessTask | null> {
    const row = await this.db.oneOrNone<TaskRow>(
      `UPDATE dbo.BusinessProcessTask
       SET status = N'OVERDUE',
           deadlineReachedAt = @p2,
           penaltyStartedAt = COALESCE(penaltyStartedAt, @p2)
       ${this.outputSql()}
       WHERE id = @p1
         AND status = N'ACTIVE'
         AND deadlineAt IS NOT NULL
         AND deadlineAt <= @p2`,
      [args.taskId, args.now],
    );
    return row ? this.mapTask(row) : null;
  }

  async applyPenaltyCycle(args: {
    taskId: string;
    amount: number;
    now: Date;
    nextCalculationAt?: Date | null;
  }): Promise<BusinessProcessTask | null> {
    const row = await this.db.oneOrNone<TaskRow>(
      `UPDATE dbo.BusinessProcessTask
       SET penaltyAmount = COALESCE(penaltyAmount, 0) + @p2,
           penaltyLastCalculatedAt = @p3,
           nextPenaltyCalculationAt = @p4
       ${this.outputSql()}
       WHERE id = @p1
         AND status = N'OVERDUE'
         AND (
           penaltyLastCalculatedAt IS NULL
           OR (nextPenaltyCalculationAt IS NOT NULL AND nextPenaltyCalculationAt <= @p3)
         )`,
      [args.taskId, args.amount, args.now, args.nextCalculationAt || null],
    );
    return row ? this.mapTask(row) : null;
  }

  async listPenaltyDue(now: Date, limit: number = 500): Promise<BusinessProcessTask[]> {
    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE id IN (
         SELECT TOP (CAST(@p2 AS INT)) id
         FROM dbo.BusinessProcessTask
         WHERE status = N'OVERDUE'
           AND (
             penaltyLastCalculatedAt IS NULL
             OR (nextPenaltyCalculationAt IS NOT NULL AND nextPenaltyCalculationAt <= @p1)
           )
         ORDER BY COALESCE(nextPenaltyCalculationAt, deadlineReachedAt, deadlineAt), createdAt, id
       )
       ORDER BY COALESCE(nextPenaltyCalculationAt, deadlineReachedAt, deadlineAt), createdAt, id`,
      [now, limit],
    );
    return rows.map(row => this.mapTask(row));
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
      const cancelledTask = await this.setDecisionIfStatusIn({
        taskId: sibling.id,
        allowedStatuses: ['ACTIVE', 'WAITING', 'OVERDUE'],
        status: 'CANCELLED',
        decision: {
          key: 'CANCELLED',
          user: args.decisionUser || null,
          comment: args.reason || null,
          source: args.decisionUser ? 'USER' : 'SYSTEM',
        },
      });
      if (cancelledTask) cancelled.push(cancelledTask);
    }

    return cancelled;
  }

  async listActiveByAssignee(args: {
    userId: string;
  }): Promise<BusinessProcessTask[]> {
    const rows = await this.db.manyOrNone<TaskRow>(
      `${this.selectSql()}
       WHERE status IN (N'ACTIVE', N'WAITING', N'OVERDUE')
         AND assigneeUser = @p1
       ORDER BY deadlineAt, activeFrom, createdAt`,
      [args.userId],
    );
    return rows.map(row => this.mapTask(row));
  }

  private selectSql(): string {
    return `SELECT
      id, instanceId, objectType, objectId, stepKey, title, status,
      assigneeUser, activeFrom, deadlineAt, deadlineReachedAt, completedAt,
      decisionKey, decisionUser, decisionComment, decisionSource,
      delegatedFromUser, redirectedFromUser, penaltyStartedAt,
      penaltyAmount, penaltyLastCalculatedAt,
      nextPenaltyCalculationAt, createdAt
    FROM dbo.BusinessProcessTask`;
  }

  private updateOutputSql(): string {
    return `UPDATE dbo.BusinessProcessTask
       SET status = N'ACTIVE'
       ${this.outputSql()}`;
  }

  private outputSql(): string {
    return `OUTPUT
           inserted.id,
           inserted.instanceId,
           inserted.objectType,
           inserted.objectId,
           inserted.stepKey,
           inserted.title,
           inserted.status,
           inserted.assigneeUser,
           inserted.activeFrom,
           inserted.deadlineAt,
           inserted.deadlineReachedAt,
           inserted.completedAt,
           inserted.decisionKey,
           inserted.decisionUser,
           inserted.decisionComment,
           inserted.decisionSource,
           inserted.delegatedFromUser,
           inserted.redirectedFromUser,
           inserted.penaltyStartedAt,
           inserted.penaltyAmount,
           inserted.penaltyLastCalculatedAt,
           inserted.nextPenaltyCalculationAt,
           inserted.createdAt`;
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
      assignee: {
        user: row.assigneeUser,
        delegatedFrom: row.delegatedFromUser || null,
        redirectedFrom: row.redirectedFromUser || null,
      },
      activation: { at: row.activeFrom || null },
      deadline: {
        at: row.deadlineAt || null,
        reachedAt: row.deadlineReachedAt || null,
      },
      decision: {
        key: row.decisionKey || null,
        user: row.decisionUser || null,
        comment: row.decisionComment || null,
        source: row.decisionSource || null,
        at: row.completedAt || null,
      },
      penalty: {
        amount: row.penaltyAmount == null ? null : Number(row.penaltyAmount),
        startedAt: row.penaltyStartedAt || null,
        lastCalculatedAt: row.penaltyLastCalculatedAt || null,
        nextCalculationAt: row.nextPenaltyCalculationAt || null,
      },
      createdAt: row.createdAt,
    };
  }
}
