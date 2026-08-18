import { MSSQL } from '../../mssql';
import { v4 as uuid } from 'uuid';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessInstanceRepository } from '../repositories/bp-instance.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { BusinessProcessTemplateRepository } from '../repositories/bp-template.repository';
import {
  BusinessProcessInstance,
  BusinessProcessSchedulerTickResult,
  BusinessProcessSchedulerStatus,
  BusinessProcessStep,
  BusinessProcessTask,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import { BusinessProcessTaskDeadlineRuleResolver } from './task-deadline-rule-resolver';
import { BusinessProcessSchedulerLock } from './scheduler-lock.service';
import { TaskService } from './task.service';

export class SchedulerService {
  constructor(
    private readonly db: MSSQL,
    private readonly deadlineRules = new BusinessProcessTaskDeadlineRuleResolver(),
    private readonly schedulerLock = new BusinessProcessSchedulerLock(),
  ) {}

  async tick(args: {
    now?: Date;
    limit?: number;
  } = {}): Promise<BusinessProcessSchedulerTickResult> {
    const runId = uuid();
    const startedAt = new Date();

    const execution = await this.schedulerLock.runExclusive(
      this.db,
      db => this.tickLocked(db, args, runId, startedAt),
    );
    if (execution.acquired) return execution.result!;
    return this.emptyResult({
      id: runId,
      status: 'SKIPPED_LOCKED',
      startedAt,
      completedAt: new Date(),
    }, 1);
  }

  async status(): Promise<BusinessProcessSchedulerStatus> {
    return this.schedulerLock.status(this.db);
  }

  private async tickLocked(
    db: MSSQL,
    args: { now?: Date; limit?: number },
    runId: string,
    startedAt: Date,
  ): Promise<BusinessProcessSchedulerTickResult> {
    const now = args.now || new Date();
    const limit = args.limit || 500;
    const result = this.emptyResult({
      id: runId,
      status: 'COMPLETED',
      startedAt,
      completedAt: startedAt,
    });
    const tasks = new BusinessProcessTaskRepository(db);

    const activatedCandidates = await tasks.listWaitingToActivate(now, limit);
    for (const candidate of activatedCandidates) {
      try {
        const task = await this.inTransaction(db, async tx => {
          const tasks = new BusinessProcessTaskRepository(tx);
          const events = new BusinessProcessEventRepository(tx);
          const activated = await tasks.activateIfWaiting({ taskId: candidate.id, now });
          if (!activated) return null;
          await events.appendOnce({
            instanceId: activated.instanceId,
            taskId: activated.id,
            eventType: 'TASK_ACTIVATED',
            user: null,
            payload: {
              stepKey: activated.stepKey,
              activeFrom: activated.activation.at,
              activatedBy: 'scheduler',
            },
            eventKey: `task-activated:${activated.id}`,
          });
          return activated;
        });
        if (!task) {
          result.skipped++;
          continue;
        }
        result.activatedTasks++;
      } catch (err) {
        this.pushError(result, candidate, err);
      }
    }

    const overdueCandidates = await tasks.listActiveDue(now, limit);
    for (const candidate of overdueCandidates) {
      try {
        const outcome = await this.inTransaction(db, async tx => {
          const tasks = new BusinessProcessTaskRepository(tx);
          const events = new BusinessProcessEventRepository(tx);
          await new BusinessProcessInstanceRepository(tx).getByIdForUpdate(candidate.instanceId);
          const overdue = await tasks.markOverdueIfActive({ taskId: candidate.id, now });
          if (!overdue) return null;
          await events.appendOnce({
            instanceId: overdue.instanceId,
            taskId: overdue.id,
            eventType: 'TASK_OVERDUE',
            user: null,
            payload: {
              stepKey: overdue.stepKey,
              deadlineAt: overdue.deadline.at,
              deadlineReachedAt: overdue.deadline.reachedAt,
            },
            eventKey: `task-overdue:${overdue.id}`,
          });
          const runtime = await this.loadRuntime(tx, overdue);
          const autoDecision = await this.deadlineRules.resolveAutoDecision({
            db: tx,
            ...runtime,
            task: overdue,
            now,
          });
          if (autoDecision) {
            await new TaskService(tx).decideSystem(overdue.id, {
              decision: autoDecision,
            }, tx);
          }
          return { task: overdue, autoCompleted: !!autoDecision };
        });
        if (!outcome) {
          result.skipped++;
          continue;
        }
        result.overdueTasks++;
        if (outcome.autoCompleted) result.autoCompletedTasks++;
      } catch (err) {
        this.pushError(result, candidate, err);
      }
    }

    const penaltyCandidates = await tasks.listPenaltyDue(now, limit);
    for (const candidate of penaltyCandidates) {
      result.penaltyCandidates++;
      try {
        const applied = await this.inTransaction(db, async tx => {
          const tasks = new BusinessProcessTaskRepository(tx);
          const events = new BusinessProcessEventRepository(tx);
          await new BusinessProcessInstanceRepository(tx).getByIdForUpdate(candidate.instanceId);
          const task = await tasks.getById(candidate.id);
          if (!task || task.status !== 'OVERDUE') return null;
          const runtime = await this.loadRuntime(tx, task);
          const penalty = await this.deadlineRules.resolvePenalty({
            db: tx,
            ...runtime,
            task,
            now,
          });
          const updated = await tasks.applyPenaltyCycle({
            taskId: task.id,
            amount: penalty.amount,
            now,
            nextCalculationAt: penalty.nextCalculationAt,
          });
          if (!updated) return null;
          if (penalty.amount > 0) {
            await events.appendOnce({
              instanceId: updated.instanceId,
              taskId: updated.id,
              eventType: 'PENALTY_APPLIED',
              user: null,
              payload: {
                stepKey: updated.stepKey,
                amount: penalty.amount,
                totalAmount: updated.penalty.amount,
                calculatedAt: now,
                nextCalculationAt: updated.penalty.nextCalculationAt,
              },
              eventKey: `penalty-applied:${updated.id}:${now.getTime()}`,
            });
          }
          return { updated, amount: penalty.amount };
        });
        if (!applied) {
          result.skipped++;
          continue;
        }
        if (applied.amount > 0) result.penaltiesApplied++;
      } catch (err) {
        this.pushError(result, candidate, err);
      }
    }

    result.run.status = result.errors.length ? 'COMPLETED_WITH_ERRORS' : 'COMPLETED';
    result.run.completedAt = new Date();
    return result;
  }

  /**
   * DB is the source of truth.
   * Bull delayed jobs may be rebuilt later, but runtime correctness must not depend on Redis.
   */
  async rebuild(): Promise<BusinessProcessSchedulerTickResult> {
    return this.tick();
  }

  private async loadRuntime(db: MSSQL, task: BusinessProcessTask): Promise<{
    instance: BusinessProcessInstance;
    template: BusinessProcessTemplate;
    step: BusinessProcessStep;
  }> {
    const instance = await new BusinessProcessInstanceRepository(db).getById(task.instanceId);
    if (!instance) throw new Error(`Business process instance ${task.instanceId} not found`);
    if (instance.status !== 'RUNNING') {
      throw new Error(`Business process instance ${instance.id} is not running`);
    }
    const template = await new BusinessProcessTemplateRepository(db)
      .getByCodeAndVersion(instance.templateCode, instance.templateVersion);
    if (!template) {
      throw new Error(`Business process template ${instance.templateCode} v${instance.templateVersion} not found`);
    }
    const step = template.steps.find(item => item.key === task.stepKey);
    if (!step) throw new Error(`Business process step ${task.stepKey} not found`);
    return { instance, template, step };
  }

  private async inTransaction<TResult>(
    db: MSSQL,
    action: (tx: MSSQL) => Promise<TResult>,
  ): Promise<TResult> {
    let result: TResult | undefined;
    await db.tx(async tx => {
      result = await action(tx);
    });
    return result!;
  }

  private emptyResult(
    run: BusinessProcessSchedulerTickResult['run'],
    skipped = 0,
  ): BusinessProcessSchedulerTickResult {
    return {
      run,
      activatedTasks: 0,
      overdueTasks: 0,
      autoCompletedTasks: 0,
      penaltyCandidates: 0,
      penaltiesApplied: 0,
      skipped,
      errors: [],
    };
  }

  private pushError(
    result: BusinessProcessSchedulerTickResult,
    task: BusinessProcessTask,
    err: unknown,
  ): void {
    result.errors.push({
      taskId: task.id,
      message: err instanceof Error ? err.message : String(err),
    });
  }
}
