import { BusinessProcessObjectAdapter } from '../types/object-integration.types';
import { CashRequestProcessAdapter } from './cash-request.adapter';

export class BusinessProcessObjectAdapterRegistry {
  private readonly adapters = new Map<string, BusinessProcessObjectAdapter>();

  constructor(adapters: BusinessProcessObjectAdapter[] = [
    new CashRequestProcessAdapter(),
  ]) {
    adapters.forEach(adapter => this.register(adapter));
  }

  register(adapter: BusinessProcessObjectAdapter): void {
    this.adapters.set(adapter.objectType, adapter);
  }

  get(objectType: string): BusinessProcessObjectAdapter | null {
    return this.adapters.get(objectType) || null;
  }

  require(objectType: string): BusinessProcessObjectAdapter {
    const adapter = this.get(objectType);
    if (!adapter) throw new Error(`Business process object adapter for ${objectType} not found`);
    return adapter;
  }
}
