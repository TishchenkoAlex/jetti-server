import { MSSQL } from '../../mssql';
import {
  BusinessProcessStartInput,
  BusinessProcessStartResult,
  BusinessProcessStep,
  BusinessProcessTemplate,
} from '../types/business-process.types';
import { BusinessProcessObjectAdapterRegistry } from '../integration/object-adapter.registry';
import { BusinessProcessObjectStatusChange } from '../types/object-integration.types';
import {
  BusinessProcessInstanceRepository,
  createBusinessProcessTemplateHash,
} from '../repositories/bp-instance.repository';
import { BusinessProcessEventRepository } from '../repositories/bp-event.repository';
import { BusinessProcessTaskRepository } from '../repositories/bp-task.repository';
import { BusinessProcessTemplateRepository } from '../repositories/bp-template.repository';
import { RuleEngine } from './rule-engine';
import { BusinessProcessTaskFactory } from './task-factory.service';

export type BusinessProcessStartEvent = 'MANUAL' | 'ON_SAVE' | 'ON_POST' | 'ON_STATUS_CHANGE';

export interface TryStartForObjectArgs {
  objectType: string;
  objectId: string;
  event: BusinessProcessStartEvent;
  user?: string | null;
  tx?: MSSQL;
  templateCode?: string | null;
  company?: string | null;
  context?: Record<string, unknown>;
  idempotencyKey?: string | null;
}

export class BusinessProcessService {
  constructor(
    private readonly db: MSSQL,
    private readonly templates = new BusinessProcessTemplateRepository(db),
    private readonly instances = new BusinessProcessInstanceRepository(db),
    private readonly tasks = new BusinessProcessTaskRepository(db),
    private readonly events = new BusinessProcessEventRepository(db),
    private readonly ruleEngine = new RuleEngine(),
    private readonly taskFactory = new BusinessProcessTaskFactory(),
  ) {}

  async start(input: BusinessProcessStartInput): Promise<BusinessProcessStartResult> {
    try {
      let result: BusinessProcessStartResult | null = null;
      await this.db.tx(async tx => {
        result = await this.startInDb(tx, input);
      });
      return result!;
    } catch (err) {
      if (this.isDuplicateKeyError(err)) {
        const instance = await this.instances.getRunningForObject({
          objectType: input.objectType,
          objectId: input.objectId,
          templateCode: input.templateCode,
        });
        if (instance) {
          return {
            instance,
            tasks: await this.tasks.listByInstance(instance.id),
            alreadyRunning: true,
            objectStatusChanges: [],
          };
        }
      }
      throw err;
    }
  }

  async tryStartForObject(args: TryStartForObjectArgs): Promise<BusinessProcessStartResult | null> {
    const results = await this.tryStartForObjectMany(args);
    return results[0] || null;
  }

  async tryStartForObjectMany(args: TryStartForObjectArgs): Promise<BusinessProcessStartResult[]> {
    if (args.event === 'MANUAL') {
      if (!args.templateCode) throw new Error('templateCode is required for manual business process start');
      const input: BusinessProcessStartInput = {
        templateCode: args.templateCode,
        objectType: args.objectType,
        objectId: args.objectId,
        user: args.user || null,
        company: args.company || null,
        context: args.context || {},
        idempotencyKey: args.idempotencyKey || null,
      };
      const result = args.tx ? await this.startInDb(args.tx, input) : await this.start(input);
      return [result];
    }

    const db = args.tx || this.db;
    const templates = await new BusinessProcessTemplateRepository(db).listActiveForStart({
      objectType: args.objectType,
      startMode: args.event,
      templateCode: args.templateCode || null,
    });
    if (!templates.length) return [];

    const adapter = new BusinessProcessObjectAdapterRegistry().get(args.objectType);
    const adapterContext = adapter
      ? await adapter.buildStartContext({
        objectId: args.objectId,
        user: args.user || null,
        tx: db,
      })
      : {
        objectType: args.objectType,
        objectId: args.objectId,
        company: args.company || null,
        context: args.context || {},
      };

    const results: BusinessProcessStartResult[] = [];
    for (const template of templates) {
      const context = {
        ...(adapterContext.context || {}),
        ...(args.context || {}),
      };
      const input: BusinessProcessStartInput = {
        templateCode: template.code,
        objectType: adapterContext.objectType,
        objectId: adapterContext.objectId,
        user: args.user || null,
        company: adapterContext.company || args.company || null,
        context,
        idempotencyKey: args.idempotencyKey || `${args.event}:${template.code}:${args.objectType}:${args.objectId}`,
      };

      if (!this.ruleEngine.evaluate(template.startCondition, this.ruleContext(input))) continue;
      results.push(await this.startFromTemplate(db, template, input, args.event));
    }

    return results;
  }

  private async startInDb(db: MSSQL, input: BusinessProcessStartInput): Promise<BusinessProcessStartResult> {
    const templates = new BusinessProcessTemplateRepository(db);

    const template = await templates.getActiveByCode(input.templateCode);
    if (!template) throw new Error(`Active business process template ${input.templateCode} not found`);
    return this.startFromTemplate(db, template, input, 'MANUAL');
  }

  private async startFromTemplate(
    db: MSSQL,
    template: BusinessProcessTemplate,
    input: BusinessProcessStartInput,
    expectedStartMode?: BusinessProcessStartEvent | null,
  ): Promise<BusinessProcessStartResult> {
    const instances = new BusinessProcessInstanceRepository(db);
    const tasks = new BusinessProcessTaskRepository(db);
    const events = new BusinessProcessEventRepository(db);

    if (template.status !== 'ACTIVE') throw new Error(`Business process template ${input.templateCode} is not active`);
    if (!template.active) throw new Error(`Business process template ${input.templateCode} is not active`);
    if (!template.objectTypes.includes(input.objectType)) {
      throw new Error(`Business process template ${input.templateCode} does not support object type ${input.objectType}`);
    }
    if (expectedStartMode && template.startMode !== expectedStartMode) {
      throw new Error(`Business process template ${input.templateCode} cannot be started by ${expectedStartMode}`);
    }

    const ruleContext = this.ruleContext(input);
    if (!this.ruleEngine.evaluate(template.startCondition, ruleContext)) {
      throw new Error(`Business process template ${input.templateCode} start condition is not satisfied`);
    }

    const running = await instances.getRunningForObject({
      objectType: input.objectType,
      objectId: input.objectId,
      templateCode: input.templateCode,
    });
    if (running) {
      return {
        instance: running,
        tasks: await tasks.listByInstance(running.id),
        alreadyRunning: true,
        objectStatusChanges: [],
      };
    }

    const objectStatusChanges: BusinessProcessObjectStatusChange[] = [];
    const step = this.resolveStartStep(template.steps, template.parameters);
    const templateHash = createBusinessProcessTemplateHash(template);
    const instance = await instances.create({
      template,
      templateHash,
      objectType: input.objectType,
      objectId: input.objectId,
      currentStepKey: step.key,
      author: input.user || null,
      company: input.company || null,
      context: input.context || {},
      idempotencyKey: input.idempotencyKey || null,
    });

    const createdTasks = await this.taskFactory.createTasksForStep({
      db,
      step,
      instanceId: instance.id,
      objectType: input.objectType,
      objectId: input.objectId,
      user: input.user || null,
      author: input.user || null,
      templateCode: template.code,
      company: input.company || null,
      context: ruleContext,
    });

    await events.appendOnce({
      instanceId: instance.id,
      eventType: 'PROCESS_STARTED',
      user: input.user || null,
      payload: {
        templateCode: template.code,
        templateVersion: template.version,
        objectType: input.objectType,
        objectId: input.objectId,
      },
      eventKey: `process-started:${instance.id}`,
    });

    for (const task of createdTasks) {
      await events.appendOnce({
        instanceId: instance.id,
        taskId: task.id,
        eventType: 'TASK_CREATED',
        user: input.user || null,
        payload: {
          stepKey: task.stepKey,
          title: task.title,
          assigneeUser: task.assigneeUser || null,
          assigneeRole: task.assigneeRole || null,
        },
        eventKey: `task-created:${task.id}`,
      });

      if (task.status === 'ACTIVE') {
        await events.appendOnce({
          instanceId: instance.id,
          taskId: task.id,
          eventType: 'TASK_ACTIVATED',
          user: input.user || null,
          payload: {
            stepKey: task.stepKey,
            title: task.title,
          },
          eventKey: `task-activated:${task.id}`,
        });
      }

      if (task.delegatedFromUser) {
        await events.appendOnce({
          instanceId: instance.id,
          taskId: task.id,
          eventType: 'TASK_DELEGATED',
          user: input.user || null,
          payload: {
            stepKey: task.stepKey,
            delegatedFromUser: task.delegatedFromUser,
            assigneeUser: task.assigneeUser || null,
          },
          eventKey: `task-delegated:${task.id}`,
        });
      }
    }

    const adapter = new BusinessProcessObjectAdapterRegistry().get(input.objectType);
    if (adapter) {
      const statusChange = await adapter.onProcessStarted({
        instance,
        tasks: createdTasks,
        user: input.user || null,
        tx: db,
      });
      await this.appendObjectStatusChanged(events, instance.id, input.user || null, statusChange, 'PROCESS_STARTED');
      if (statusChange) objectStatusChanges.push(statusChange);
    }

    return {
      instance,
      tasks: createdTasks,
      objectStatusChanges,
    };
  }

  private resolveStartStep(steps: BusinessProcessStep[], parameters?: Record<string, unknown>): BusinessProcessStep {
    const startStepKey = parameters && typeof parameters.startStepKey === 'string' ? parameters.startStepKey : null;
    const step = startStepKey
      ? steps.find(item => item.key === startStepKey)
      : steps[0];

    if (!step) throw new Error(`Start step ${startStepKey || '<first>'} not found`);
    return step;
  }

  private ruleContext(input: BusinessProcessStartInput): Record<string, unknown> {
    return {
      ...(input.context || {}),
      objectType: input.objectType,
      objectId: input.objectId,
      user: input.user || null,
      company: input.company || null,
      context: input.context || {},
    };
  }

  private async appendObjectStatusChanged(
    events: BusinessProcessEventRepository,
    instanceId: string,
    user: string | null,
    statusChange: BusinessProcessObjectStatusChange | null,
    reason: 'PROCESS_STARTED' | 'PROCESS_COMPLETED' | 'PROCESS_REJECTED' | 'PROCESS_CANCELLED',
  ): Promise<void> {
    if (!statusChange) return;
    await events.appendOnce({
      instanceId,
      eventType: 'OBJECT_STATUS_CHANGED',
      user,
      payload: {
        objectType: statusChange.objectType,
        objectId: statusChange.objectId,
        fromStatus: statusChange.fromStatus || null,
        toStatus: statusChange.toStatus || null,
        reason,
      },
      eventKey: `object-status-changed:${instanceId}:${reason}`,
    });
  }

  private isDuplicateKeyError(err: unknown): boolean {
    const error = err as { number?: number; message?: string };
    return error.number === 2601
      || error.number === 2627
      || String(error.message || '').includes('UX_BusinessProcessInstance_IdempotencyKey');
  }
}
