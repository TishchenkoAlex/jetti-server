import { config as dotenv } from 'dotenv';
import { ConnectionConfig } from 'tedious';

dotenv();
export type ConnectionConfigAndPool = ConnectionConfig & { pool: { min: number, max: number, idleTimeoutMillis: number } };

export const APP_VERSION = process.env.APP_VERSION || '1.0.05';
export const CONTOUR = parseInt(process.env.CONTOUR || "1");
export const DB_NAME = process.env.DB_NAME!;
export const JETTI_IS_HOST = process.env.JETTI_IS_HOST || 'http://localhost:3500';
export const JTW_KEY = process.env.JTW_KEY!;
export const bpApiHost = 'https://bp.x100-group.com/JettiProcesses/hs';
export const LOGIC_USECASHREQUESTAPPROVING = process.env.LOGIC_USECASHREQUESTAPPROVING || '0';
export const REGISTER_ACCUMULATION_SOURCE = process.env.REGISTER_ACCUMULATION_SOURCE || '';
export const TRANSFORMED_REGISTER_MOVEMENTS_TABLE = '[dbo].[Register.Accumulation.Balance.RC]';
export const ARCH_USER = process.env.ARCH_USER || 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA';
export const COMMON_COMPANY = process.env.COMMON_COMPANY || '00000000-0000-0000-0000-000000000000';
export const EXCHANGE_SERVICE_USER = process.env.EXCHANGE_SERVICE_USER || '63C8AE00-5985-11EA-B2B2-7DD8BECCDACF';

export const SERVICE_ACCOUNTS = (process.env.SERVICE_ACCOUNTS || 'exchange@sushi-master.net,kolpakov.d@sushi-master.net,setka.service.account@sushi-master.net,exchange@sushi-m.net').split(',');

const DB_PORT = parseInt(process.env.DB_PORT as string, undefined);

export let LINK = process.env.LINK || "https://x100-jetti.web.app";
export let REDIS_DB_HOST = process.env.REDIS_DB_HOST!;
export let REDIS_DB_AUTH = process.env.REDIS_DB_AUTH;
export let REDIS_DB_PORT = parseInt(process.env.REDIS_DB_PORT as string, undefined) || 6379;
export let DB_HOST_MIRROR_CONTOUR = process.env.DB_HOST_MIRROR_CONTOUR;
export let DB_USER_MIRROR_CONTOUR = process.env.DB_USER_MIRROR_CONTOUR;
export let DB_PASSWORD_MIRROR_CONTOUR = process.env.DB_PASSWORD_MIRROR_CONTOUR;
export let DB_PORT_MIRROR_CONTOUR = parseInt(process.env.DB_PORT_MIRROR_CONTOUR as string, undefined) || 1433;

if (CONTOUR === 2) {
  throw new Error('Contour 2 is not supported');
};

export const portal1CApiConfig = {
  baseURL: process.env.PORTAL1C_API_HOST,
  auth: {
    username: process.env.PORTAL1C_API_USER,
    password: process.env.PORTAL1C_API_PASSWORD
  }
};

export const sqlConfig: ConnectionConfigAndPool = {
  server: process.env.DB_HOST!,
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_USER,
      password: process.env.DB_PASSWORD
    }
  },
  options: {
    encrypt: false,
    database: DB_NAME,
    port: DB_PORT,
    requestTimeout: 5 * 60 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};


export const sqlConfigX100DATA: ConnectionConfigAndPool = {
  server: process.env.DB_HOST!,
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_USER,
      password: process.env.DB_PASSWORD
    }
  },
  options: {
    encrypt: false,
    database: 'x100-DATA',
    port: DB_PORT,
    requestTimeout: 5 * 60 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};

export const sqlConfigTask: ConnectionConfigAndPool = {
  server: process.env.DB_HOST!,
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_TASK_USER,
      password: process.env.DB_TASK_PASSWORD
    }
  },
  options: {
    encrypt: false,
    database: DB_NAME,
    port: DB_PORT,
    requestTimeout: 3 * 60 * 60 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};

export const sqlConfigMeta: ConnectionConfigAndPool = {
  server: process.env.DB_HOST!,
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_TASK_USER,
      password: process.env.DB_TASK_PASSWORD
    }
  },
  options: {
    encrypt: false,
    database: DB_NAME,
    port: DB_PORT,
    requestTimeout: 120 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};

export const sqlConfigExchange: ConnectionConfigAndPool = {
  server: '34.91.140.192',
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_USER,
      password: process.env.DB_PASSWORD
    }
  },
  options: {
    encrypt: false,
    database: 'Exchange',
    port: DB_PORT,
    requestTimeout: 20 * 60 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};

export const sqlConfigMirrorContour: ConnectionConfigAndPool = {
  server: process.env.DB_HOST_MIRROR_CONTOUR!,
  authentication: {
    type: 'default',
    options: {
      userName: process.env.DB_USER_MIRROR_CONTOUR!,
      password: process.env.DB_PASSWORD_MIRROR_CONTOUR!
    }
  },
  options: {
    encrypt: false,
    database: process.env.DB_NAME_MIRROR_CONTOUR!,
    port: DB_PORT_MIRROR_CONTOUR,
    requestTimeout: 3 * 60 * 60 * 1000,
    rowCollectionOnRequestCompletion: true,
  },
  pool: {
    min: 0,
    max: 1000,
    idleTimeoutMillis: 20 * 60 * 1000
  }
};


export function getEnvironment() {
  return {
    APP_VERSION,
    CONTOUR,
    DB: {
      DB_NAME,
      DB_PORT
    },
    JETTI_IS_HOST,
    LOGIC_USECASHREQUESTAPPROVING,
    REGISTER_ACCUMULATION_SOURCE,
    TRANSFORMED_REGISTER_MOVEMENTS_TABLE,
    ARCH_USER,
    COMMON_COMPANY,
    SERVICE_ACCOUNTS,
    LINK,
    REDIS: {
      REDIS_DB_HOST,
      REDIS_DB_AUTH,
      REDIS_DB_PORT
    },
    MIRROR_CONTOUR_DB: {
      DB_HOST_MIRROR_CONTOUR,
      DB_USER_MIRROR_CONTOUR,
      DB_PASSWORD_MIRROR_CONTOUR,
      DB_PORT_MIRROR_CONTOUR
    },
    SQL_CONFIGS: {
      sqlConfig,
      sqlConfigX100DATA,
      sqlConfigTask,
      sqlConfigMeta,
      sqlConfigExchange,
      sqlConfigMirrorContour
    }
  }
}
