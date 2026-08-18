import * as Bull from 'bull';
import {
  BUSINESS_PROCESS_SCHEDULER_ENABLED,
  BUSINESS_PROCESS_SCHEDULER_INTERVAL_MS,
  BUSINESS_PROCESS_SCHEDULER_LIMIT,
} from '../../env/environment';

export const BUSINESS_PROCESS_SCHEDULER_JOB_ID = 'business-process-scheduler-tick';
export const BUSINESS_PROCESS_SCHEDULER_HANDLER = 'businessProcessSchedulerTick';

export interface BusinessProcessSchedulerConfiguration {
  enabled: boolean;
  intervalMs: number;
  limit: number;
}

export interface BusinessProcessSchedulerRegistration extends BusinessProcessSchedulerConfiguration {
  registered: boolean;
  registeredAt?: Date | null;
  repeatKey?: string | null;
  removedRepeatKeys?: string[];
  lastError?: string | null;
}

export function businessProcessSchedulerConfiguration(): BusinessProcessSchedulerConfiguration {
  return {
    enabled: BUSINESS_PROCESS_SCHEDULER_ENABLED,
    intervalMs: BUSINESS_PROCESS_SCHEDULER_INTERVAL_MS,
    limit: BUSINESS_PROCESS_SCHEDULER_LIMIT,
  };
}

let registrationState: BusinessProcessSchedulerRegistration = {
  ...businessProcessSchedulerConfiguration(),
  registered: false,
  registeredAt: null,
  lastError: null,
};

export function businessProcessSchedulerRegistrationState(): BusinessProcessSchedulerRegistration {
  return { ...registrationState };
}

export async function ensureBusinessProcessSchedulerJob(
  queue: Bull.Queue,
  configuration = businessProcessSchedulerConfiguration(),
): Promise<BusinessProcessSchedulerRegistration> {
  if (!configuration.enabled) {
    registrationState = {
      ...configuration,
      registered: false,
      registeredAt: null,
      lastError: null,
    };
    return businessProcessSchedulerRegistrationState();
  }

  try {
    const repeatableJobs = await queue.getRepeatableJobs();
    const stale = repeatableJobs.filter(job => job.id === BUSINESS_PROCESS_SCHEDULER_JOB_ID
      && Number(job.every || 0) !== configuration.intervalMs);
    for (const job of stale) await queue.removeRepeatableByKey(job.key);

    await queue.add(
      {
        job: {
          id: BUSINESS_PROCESS_SCHEDULER_HANDLER,
          description: 'Business process scheduler tick',
        },
        user: 'SYSTEM',
        limit: configuration.limit,
      },
      {
        jobId: BUSINESS_PROCESS_SCHEDULER_JOB_ID,
        repeat: { every: configuration.intervalMs },
        attempts: 1,
        removeOnComplete: 20,
        removeOnFail: false,
      },
    );
    const registeredJobs = await queue.getRepeatableJobs();
    const registered = registeredJobs.find(job => job.id === BUSINESS_PROCESS_SCHEDULER_JOB_ID
      && Number(job.every || 0) === configuration.intervalMs);

    registrationState = {
      ...configuration,
      registered: !!registered,
      registeredAt: new Date(),
      repeatKey: registered ? registered.key : null,
      removedRepeatKeys: stale.map(job => job.key),
      lastError: registered ? null : 'Repeatable job was not found after registration',
    };
    return businessProcessSchedulerRegistrationState();
  } catch (error) {
    registrationState = {
      ...configuration,
      registered: false,
      registeredAt: new Date(),
      lastError: error instanceof Error ? error.message : String(error),
    };
    throw error;
  }
}
