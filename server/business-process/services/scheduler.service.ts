export class SchedulerService {
  async tick(tx?: unknown): Promise<void> {
    throw new Error('SchedulerService.tick is not implemented');
  }

  async rebuild(tx?: unknown): Promise<void> {
    throw new Error('SchedulerService.rebuild is not implemented');
  }
}

