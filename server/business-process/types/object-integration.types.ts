import { MSSQL } from '../../mssql';
import {
  BusinessProcessInstance,
  BusinessProcessTask,
} from './business-process.types';

export type BusinessProcessObjectEvent =
  | 'PROCESS_STARTED'
  | 'PROCESS_COMPLETED'
  | 'PROCESS_REJECTED'
  | 'PROCESS_CANCELLED'
  | 'PROCESS_FAILED';

export interface BusinessProcessObjectStatusChange {
  objectType: string;
  objectId: string;
  fromStatus?: string | null;
  toStatus?: string | null;
}

export interface BusinessProcessObjectContext {
  objectType: string;
  objectId: string;
  user?: string | null;
  company?: string | null;
  tx: MSSQL;
}

export interface BusinessProcessObjectAdapter {
  objectType: string;

  buildStartContext(args: {
    objectId: string;
    user?: string | null;
    tx: MSSQL;
  }): Promise<{
    objectType: string;
    objectId: string;
    company?: string | null;
    context: Record<string, unknown>;
  }>;

  onProcessStarted(args: {
    instance: BusinessProcessInstance;
    tasks: BusinessProcessTask[];
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null>;

  onProcessCompleted(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null>;

  onProcessRejected(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    rejectPolicy?: string | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null>;

  onProcessCancelled(args: {
    instance: BusinessProcessInstance;
    task?: BusinessProcessTask | null;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null>;

  onProcessFailed?(args: {
    instance: BusinessProcessInstance;
    error: Error;
    user?: string | null;
    tx: MSSQL;
  }): Promise<BusinessProcessObjectStatusChange | null>;
}
