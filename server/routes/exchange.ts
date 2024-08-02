import { Request, Response, NextFunction, Router } from 'express';
import * as jwt from 'jsonwebtoken';
import { JTW_KEY } from '../env/environment';
import { authHTTP } from './middleware/check-auth';
import { MSSQL } from '../mssql';
import { TASKS_POOL } from '../sql.pool.tasks';
import { IJWTPayload } from 'jetti-middle';
import { getUser } from './auth';

export const router = Router();

router.post('/login', async (req, res, next) => {
  // setka.service.account@sushi-master.net
  try {
    const { email, password } = req.body;
    if (!email) { return res.status(401).json({ message: 'Auth failed: user name required' }); }
    if (!password) { return res.status(401).json({ message: 'Auth failed: password required' }); }
    if (!(
      email === 'exchange@sushi-master.net' ||
      email === 'setka.service.account@sushi-master.net' ||
      email === 'kolpakov.d@sushi-master.net'
    )) {
      return res.status(401).json({ message: 'Auth failed: wrong user name' });
    }
    if (password !== process.env.EXCHANGE_ACCESS_KEY) { return res.status(401).json({ message: 'Auth failed: wrong password' }); }

    const user = await getUser(email);

    const payload: IJWTPayload = {
      timezoneOffset: req.body.timezoneOffset || 0,
      email,
      description: user ? user.description : 'exchange',
      isAdmin: true,
      roles: [],
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
