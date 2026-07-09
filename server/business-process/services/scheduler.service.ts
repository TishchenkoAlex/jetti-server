import { MSSQL } from '../../mssql';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessInstanceRepository } from '../repositories/bp-instance.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import {
  BusinessProcessSchedulerTickResult,
  BusinessProcessTask,
} from '../types/business-process.types';
import { PenaltyResolver } from './penalty-resolver';

export class SchedulerService {
  constructor(
    private readonly db: MSSQL,
    private readonly tasks = new BusinessProcessTaskRepository(db),
    private readonly instances = new BusinessProcessInstanceRepository(db),
    private readonly events = new BusinessProcessEventRepository(db),
    private readonly penaltyResolver = new PenaltyResolver(),
  ) {}

  async tick(args: {
    now?: Date;
    limit?: number;
  } = {}): Promise<BusinessProcessSchedulerTickResult> {
    const now = args.now || new Date();
    const limit = args.limit || 500;
    const result: BusinessProcessSchedulerTickResult = {
      activatedTasks: 0,
      overdueTasks: 0,
      penaltyCandidates: 0,
      penaltiesApplied: 0,
      skipped: 0,
      errors: [],
    };

    const activatedCandidates = await this.tasks.listWaitingToActivate(now, limit);
    for (const candidate of activatedCandidates) {
      try {
        const task = await this.tasks.activateIfWaiting({ taskId: candidate.id, now });
        if (!task) {
          result.skipped++;
          continue;
        }

        await this.events.appendOnce({
          instanceId: task.instanceId,
          taskId: task.id,
          eventType: 'TASK_ACTIVATED',
          user: 'business-process@scheduler',
          payload: {
            stepKey: task.stepKey,
            activeFrom: task.activeFrom,
            activatedBy: 'scheduler',
          },
          eventKey: `task-activated:${task.id}`,
        });
        result.activatedTasks++;
      } catch (err) {
        this.pushError(result, candidate, err);
      }
    }

    const overdueCandidates = await this.tasks.listActiveDue(now, limit);
    for (const candidate of overdueCandidates) {
      try {
        const task = await this.tasks.markOverdueIfActive({ taskId: candidate.id, now });
        if (!task) {
          result.skipped++;
          continue;
        }

        await this.events.appendOnce({
          instanceId: task.instanceId,
          taskId: task.id,
          eventType: 'TASK_OVERDUE',
          user: 'business-process@scheduler',
          payload: {
            stepKey: task.stepKey,
            dueAt: task.dueAt,
            overdueAt: task.overdueAt,
          },
          eventKey: `task-overdue:${task.id}`,
        });
        result.overdueTasks++;
      } catch (err) {
        this.pushError(result, candidate, err);
      }
    }

    const penaltyCandidates = await this.tasks.listOverdueWithoutPenalty(limit);
    result.penaltyCandidates = penaltyCandidates.length;
    for (const task of penaltyCandidates) {
      try {
        const amount = await this.resolvePenaltyAmount(task);
        if (amount == null) {
          result.skipped++;
          continue;
        }

        const updated = await this.tasks.applyPenaltyIfNeeded({
          taskId: task.id,
          amount,
          now,
        });
        if (!updated) {
          result.skipped++;
          continue;
        }

        await this.events.appendOnce({
          instanceId: updated.instanceId,
          taskId: updated.id,
          eventType: 'PENALTY_APPLIED',
          user: 'business-process@scheduler',
          payload: {
            stepKey: updated.stepKey,
            amount,
            penaltyAmount: updated.penaltyAmount,
          },
          eventKey: `penalty-applied:${updated.id}`,
        });
        result.penaltiesApplied++;
      } catch (err) {
        this.pushError(result, task, err);
      }
    }

    return result;
  }

  /**
   * DB is the source of truth.
   * Bull delayed jobs may be rebuilt later, but runtime correctness must not depend on Redis.
   */
  async rebuild(): Promise<BusinessProcessSchedulerTickResult> {
    return this.tick();
  }

  private async resolvePenaltyAmount(task: BusinessProcessTask): Promise<number | null> {
    if (!task.penaltyRuleSnapshot) return null;

    const instance = await this.instances.getById(task.instanceId);
    if (!instance) throw new Error(`Business process instance ${task.instanceId} not found`);

    return this.penaltyResolver.resolveAmount(task.penaltyRuleSnapshot, {
      ...(instance.context || {}),
      task,
      context: instance.context || {},
      objectType: task.objectType,
      objectId: task.objectId,
      stepKey: task.stepKey,
    });
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
