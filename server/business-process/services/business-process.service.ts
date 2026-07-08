import { MSSQL } from '../../mssql';
import {
  BusinessProcessStartInput,
  BusinessProcessStartResult,
  BusinessProcessStep,
} from '../types/business-process.types';
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
  user?: string;
  tx?: MSSQL;
  templateCode?: string;
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
          };
        }
      }
      throw err;
    }
  }

  async tryStartForObject(args: TryStartForObjectArgs): Promise<BusinessProcessStartResult | null> {
    if (args.event !== 'MANUAL') return null;
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

    return args.tx ? this.startInDb(args.tx, input) : this.start(input);
  }

  private async startInDb(db: MSSQL, input: BusinessProcessStartInput): Promise<BusinessProcessStartResult> {
    const templates = new BusinessProcessTemplateRepository(db);
    const instances = new BusinessProcessInstanceRepository(db);
    const tasks = new BusinessProcessTaskRepository(db);
    const events = new BusinessProcessEventRepository(db);

    const template = await templates.getActiveByCode(input.templateCode);
    if (!template) throw new Error(`Active business process template ${input.templateCode} not found`);
    if (template.status !== 'ACTIVE') throw new Error(`Business process template ${input.templateCode} is not active`);
    if (!template.objectTypes.includes(input.objectType)) {
      throw new Error(`Business process template ${input.templateCode} does not support object type ${input.objectType}`);
    }
    if (template.startMode !== 'MANUAL') {
      throw new Error(`Business process template ${input.templateCode} cannot be started manually`);
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
      };
    }

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
    }

    return {
      instance,
      tasks: createdTasks,
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

  private isDuplicateKeyError(err: unknown): boolean {
    const error = err as { number?: number; message?: string };
    return error.number === 2601
      || error.number === 2627
      || String(error.message || '').includes('UX_BusinessProcessInstance_IdempotencyKey');
  }
}
