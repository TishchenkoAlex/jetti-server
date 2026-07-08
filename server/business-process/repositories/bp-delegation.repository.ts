export class BusinessProcessDelegationRepository {
  constructor(private readonly db?: unknown) {}

  async getById(id: string): Promise<unknown | null> {
    throw new Error('BusinessProcessDelegationRepository.getById is not implemented');
  }
}

