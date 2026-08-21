import { Request, Response, NextFunction, Router } from 'express';
import { execFile } from 'child_process';
import { isIP } from 'net';
import { promisify } from 'util';
import * as jwt from 'jsonwebtoken';
import { getEnvironment, JTW_KEY, SERVICE_ACCOUNTS } from '../env/environment';
import { authHTTP } from './middleware/check-auth';
import { MSSQL } from '../mssql';
import { TASKS_POOL } from '../sql.pool.tasks';
import { IJWTPayload } from 'jetti-middle';
import { getUser } from './auth';
import { getUserRoles } from '../fuctions/UsersPermissions';
import { getLog } from '../logger';

export const router = Router();

const execFileAsync = promisify(execFile);

function isValidNetworkHost(host: string): boolean {
  return isIP(host) !== 0 || /^(?=.{1,253}$)(?!-)[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?$/.test(host);
}

function isValidCurlUrl(value: string): boolean {
  try {
    const url = new URL(value);
    return (url.protocol === 'http:' || url.protocol === 'https:') && !url.username && !url.password;
  } catch (_) {
    return false;
  }
}

const ALLOWED_CURL_ARGS = new Set([
  '-4', '--ipv4', '-6', '--ipv6', '-f', '--fail', '--fail-with-body', '-I', '--head', '-k', '--insecure',
  '-L', '--location', '--compressed', '--raw', '--http1.0', '--http1.1', '--http2', '--no-keepalive',
  '--retry-connrefused', '--tlsv1.2', '--tlsv1.3', '--trace-time', '-v', '--verbose',
]);

router.post('/login', async (req, res, next) => {
  // setka.service.account@sushi-master.net
  try {
    const { email, password } = req.body as { email: string; password: string };
    if (!email) { return res.status(401).json({ message: 'Auth failed: user name required' }); }
    if (!password) { return res.status(401).json({ message: 'Auth failed: password required' }); }
    if (!SERVICE_ACCOUNTS.includes(email.toLowerCase())) {
      return res.status(401).json({ message: 'Auth failed: wrong user name' });
    }
    if (password !== process.env.EXCHANGE_ACCESS_KEY) { return res.status(401).json({ message: 'Auth failed: wrong password' }); }

    const user = await getUser(email.toLowerCase());

    const roles = user && email.toLowerCase().startsWith('kolpakov.d@') ? await getUserRoles(user) : [];

    const payload: IJWTPayload = {
      timezoneOffset: req.body.timezoneOffset || 0,
      email,
      description: user ? user.description : 'exchange',
      isAdmin: true,
      roles,
      env: { view: { id: user ? user.id : null } },
    };
    const token = jwt.sign(payload, JTW_KEY, { expiresIn: '24h' });
    return res.json({ account: payload, token });
  } catch (err) { next(err); }
});


router.get('/v1.0/hello', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // const user = User(req);
    return res.json('hello');
  } catch (err) { next(err); }
});

router.post('/v1.0/hello', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    // const user = User(req);
    return res.json('hello');
  } catch (err) { next(err); }
});

router.post('/v1.0/income/invoice', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Invoice', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v1.0/income/order', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Order', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v1.0/income/expense', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Expense', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.patch('/v1.0/Employee', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Employee', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v1.0/Employee', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Employee', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v1.0/queue', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });
    await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc])
      VALUES (N'Queue', JSON_QUERY(@p1))`, [JSON.stringify(req.body)]);
    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v1.1/queue', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {

    const insertRow = async (row) => {
      await sdba.none(`
      INSERT INTO [exc].[Queue]([type],[doc],[ExchangeCode],[ExchangeBase])
      VALUES (@p4, JSON_QUERY(@p1), @p2, @p3)`,
        [JSON.stringify(row),
        row.ExchangeCode || null,
        row.ExchangeBase || null,
        row.DataType || 'Queue_v1.1']
      );
    };

    const sdba = new MSSQL(TASKS_POOL,
      { email: 'service@service.com', isAdmin: true, description: 'service account', env: {}, roles: [] });

    if (Array.isArray(req.body))
      while (req.body.length)
        await Promise.all(req.body.splice(0, 10).map(row => insertRow(row)));
    else
      await insertRow(req.body);

    return res.json(200);
  } catch (err) { next(err); }
});

router.post('/v2/info', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { pwd = '' } = req.body as { pwd: string } || {};
    if (pwd !== process.env.EXCHANGE_ACCESS_KEY) {
      return res.status(401).json({ message: "Auth failed: wrong password" });
    }
    
    const PROCESS_ENV = Object.assign({}, process.env)
    const ENVIRONMENT = getEnvironment();

    return res.json({PROCESS_ENV, ENVIRONMENT, LOG_GLOBAL: getLog() });
  } catch (err) { next(err); }
});

router.post('/v2/network', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { pwd = '', host, action } = req.body as { pwd?: string, host?: unknown, action?: unknown } || {};
    if (pwd !== process.env.EXCHANGE_ACCESS_KEY) {
      return res.status(401).json({ message: 'Auth failed: wrong password' });
    }

    if (typeof host !== 'string' || !isValidNetworkHost(host)) {
      return res.status(400).json({ message: 'host must be a valid IP address or hostname' });
    }

    if (action !== 'ping' && action !== 'tracert') {
      return res.status(400).json({ message: 'action must be ping or tracert' });
    }

    const command = action === 'ping' ? 'ping' : 'traceroute';
    const args = action === 'ping'
      ? ['-c', '4', '-W', '2', host]
      : ['-n', '-m', '15', '-w', '2', host];

    try {
      const { stdout, stderr } = await execFileAsync(command, args, {
        timeout: 35_000,
        maxBuffer: 128 * 1024,
      });
      return res.json({ host, action, stdout, stderr });
    } catch (err) {
      const commandError = err as Error & { code?: number | string, stdout?: string, stderr?: string, killed?: boolean };
      return res.status(200).json({
        host,
        action,
        exitCode: commandError.code || null,
        timedOut: commandError.killed === true,
        stdout: commandError.stdout || '',
        stderr: commandError.stderr || commandError.message,
      });
    }
  } catch (err) { next(err); }
});

router.post('/v2/curl', authHTTP, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { pwd = '', url, method = 'GET', headers = {}, body, args: curlArgs = [] } = req.body as {
      pwd?: string, url?: unknown, method?: unknown, headers?: unknown, body?: unknown, args?: unknown
    } || {};
    if (pwd !== process.env.EXCHANGE_ACCESS_KEY) {
      return res.status(401).json({ message: 'Auth failed: wrong password' });
    }

    if (typeof url !== 'string' || !isValidCurlUrl(url)) {
      return res.status(400).json({ message: 'url must be an HTTP or HTTPS URL without credentials' });
    }

    if (typeof method !== 'string' || !/^[A-Z]{1,16}$/.test(method)) {
      return res.status(400).json({ message: 'method must contain 1 to 16 uppercase letters' });
    }

    if (!headers || Array.isArray(headers) || typeof headers !== 'object') {
      return res.status(400).json({ message: 'headers must be an object' });
    }

    const headerArgs: string[] = [];
    for (const [name, value] of Object.entries(headers as Record<string, unknown>)) {
      if (!/^[!#$%&'*+.^_`|~0-9A-Za-z-]+$/.test(name) || typeof value !== 'string' || /[\r\n]/.test(value)) {
        return res.status(400).json({ message: 'headers must contain valid names and single-line string values' });
      }
      headerArgs.push('--header', `${name}: ${value}`);
    }

    if (headerArgs.length > 40 || typeof body !== 'undefined' && typeof body !== 'string') {
      return res.status(400).json({ message: 'too many headers or body is not a string' });
    }

    if (!Array.isArray(curlArgs) || curlArgs.length > 20 || !curlArgs.every(arg => typeof arg === 'string' && ALLOWED_CURL_ARGS.has(arg))) {
      return res.status(400).json({ message: 'args must contain up to 20 supported curl flags without values' });
    }

    const commandArgs = ['--disable', '--silent', '--show-error', '--include', '--connect-timeout', '5', '--max-time', '30',
      '--request', method, ...headerArgs, ...curlArgs];
    if (typeof body === 'string') commandArgs.push('--data-raw', body);
    commandArgs.push(url);

    try {
      const { stdout, stderr } = await execFileAsync('curl', commandArgs, { timeout: 35_000, maxBuffer: 256 * 1024 });
      return res.json({ url, method, stdout, stderr });
    } catch (err) {
      const commandError = err as Error & { code?: number | string, stdout?: string, stderr?: string, killed?: boolean };
      return res.status(200).json({
        url,
        method,
        exitCode: commandError.code || null,
        timedOut: commandError.killed === true,
        stdout: commandError.stdout || '',
        stderr: commandError.stderr || commandError.message,
      });
    }
  } catch (err) { next(err); }
});

