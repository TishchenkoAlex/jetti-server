export class DelegationResolver {
  resolve(userId: string, date: Date = new Date(), tx?: unknown): Promise<unknown> {
    throw new Error('DelegationResolver.resolve is not implemented');
  }
}

