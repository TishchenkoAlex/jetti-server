import { LOGIC_USECASHREQUESTAPPROVING } from './../env/environment';
import { getUserRoles } from './../fuctions/UsersPermissions';
import * as express from 'express';
import axios from 'axios';
import * as jwt from 'jsonwebtoken';
import { JTW_KEY } from '../env/environment';
import { authHTTP } from './middleware/check-auth';
import { CatalogUser } from '../models/Catalogs/Catalog.User';
import { MSSQL } from '../mssql';
import { JETTI_POOL } from '../sql.pool.jetti';
import { lib } from '../std.lib';
import { CatalogSubSystem } from '../models/Catalogs/Catalog.SubSystem';
import { createDocument } from '../models/documents.factory';
import { DocumentOptions, Ref, IFlatDocument, INoSqlDocument, IJWTPayload } from 'jetti-middle';
import { createForm } from '../models/Forms/form.factory';
import { CatalogOperationGroup } from '../models/Catalogs/Catalog.Operation.Group';

export const router = express.Router();

function getUserEnviroment(user: CatalogUser) {
  return {
    view: { id: user.id, code: user.code, type: user.type, value: user.description },
    settings: { LOGIC_USECASHREQUESTAPPROVING: LOGIC_USECASHREQUESTAPPROVING }
  };
}

const sdba = new MSSQL(JETTI_POOL, {
  email: 'service@service.com',
  isAdmin: true,
  description: 'service account',
  env: {},
  roles: []
});

export async function getUser(email: string): Promise<CatalogUser | null> {
  let user: CatalogUser | null = null;
  const userId = await getUserIdByEmail(email);
  if (userId)
    user = await lib.doc.byIdT<CatalogUser>(userId, sdba);
  if (user?.isDisabled) return null;
  return user;
}

async function getUserIdByEmail(email: string) {
  return await lib.doc.byCode('Catalog.User', email, sdba) || await getUserIdByAccountEntraID(email);
}

async function getUserIdByAccountEntraID(id: string) {
  if (!id) return null;
  const normalizeId = () => {
    const [base] = id.split('#ext#');
    return `${base.replace('@', '_')}#ext#@sushimasternet.onmicrosoft.com`;
  }
  const query = `
  SELECT TOP 1
    u.id 
  FROM 
    [dbo].[Catalog.User.v] u WITH (NOEXPAND) 
    INNER JOIN dbo.[Catalog.Person.v] pers WITH (NOEXPAND) 
      ON u.[Person] = pers.id AND
      pers.AccountEntraID = @p1`;
  const qRes = await sdba.oneOrNone<{ id: string }>(query, [normalizeId()]);

  return qRes?.id ?? null;
}

router.post('/login', async (req, res, next) => {
  try {
    const mail = req.body.email;
    const user = await getUser(mail);
    if (!user) { return res.status(401).json({ message: 'Auth failed' }); }

    const instance = axios.create({ baseURL: 'https://graph.microsoft.com' });
    instance.defaults.headers.common['Authorization'] = `Bearer ${req.body.token}`;
    const me = (await instance.get('/v1.0/me/')).data;

    let photo;
    try {
      const photoArraybuffer = (await instance.get('/v1.0/me/photos/48x48/$value', { responseType: 'arraybuffer' })).data;
      photo = Buffer.from(photoArraybuffer, 'binary').toString('base64');
    } catch { }

    const payload: IJWTPayload = {
      email: user.code ?? me.userPrincipalName,
      description: me.displayName,
      isAdmin: user.isAdmin === true,
      roles: await getUserRoles(user),
      env: getUserEnviroment(user),
    };

    const token = jwt.sign(payload, JTW_KEY, { expiresIn: '72h' });

    return res.json({ account: payload, token, photo });
  } catch (err) { next(err); }
});

router.get('/account', authHTTP, async (req, res, next) => {
  try {
    const user = await getUser((<any>req).user.email);
    if (!user) { return res.status(401).json({ message: 'Auth failed' }); }
    const payload: IJWTPayload = {
      email: user.code,
      description: user.description,
      isAdmin: user.isAdmin === true,
      roles: await getUserRoles(user),
      env: getUserEnviroment(user),
    };
    res.json(payload);
  } catch (err) { next(err); }
});

router.post('/refresh', authHTTP, async (req, res, next) => {
  try {
    const payload: IJWTPayload = (<any>req).user;
    const user = await getUser(payload.email);
    if (!user) { return res.status(401).json({ message: 'Auth failed' }); }
    const new_payload: IJWTPayload = {
      email: user.id,
      description: user.description,
      isAdmin: user.isAdmin === true,
      roles: await getUserRoles(user),
      env: getUserEnviroment(user),
    };
    const token = jwt.sign(new_payload, JTW_KEY, { expiresIn: '72h' });
    return res.json({ account: user, token });
  } catch (err) { next(err); }
});

const RolesQuery = `
  DROP TABLE IF EXISTS #UserOrGroup;
  SELECT @p1 id INTO #UserOrGroup
  UNION ALL
  SELECT id FROM Documents
  CROSS APPLY OPENJSON (doc, N'$.Users')
  WITH
  (
    [UsersGroup.User] UNIQUEIDENTIFIER N'$.User'
  ) AS Users
  WHERE (1=1) AND
    type = 'Catalog.UsersGroup' AND
    [UsersGroup.User] = @p1;

  DROP TABLE IF EXISTS #Roles;
  SELECT [Role] INTO #Roles FROM Documents
  CROSS APPLY OPENJSON (doc, N'$.RoleList')
  WITH
  (
    [Role] UNIQUEIDENTIFIER N'$.Role'
  ) AS Roles
  INNER JOIN #UserOrGroup ON #UserOrGroup.id = CAST(JSON_VALUE(doc, N'$.UserOrGroup') AS UNIQUEIDENTIFIER)
  WHERE (1=1) AND
  posted = 1 AND
  type = 'Document.UserSettings';

  DROP TABLE IF EXISTS #Subsystems;
  SELECT SubSystem INTO #Subsystems FROM Documents r
  CROSS APPLY OPENJSON (doc, N'$.Subsystems')
  WITH
  (
    SubSystem  UNIQUEIDENTIFIER N'$.SubSystem'
  ) AS Subsystems
  WHERE (1=1) AND
    type = 'Catalog.Role' AND
    id IN (SELECT [Role] FROM #Roles);

  SELECT * FROM Documents r
  WHERE (1=1) AND
    type = 'Catalog.SubSystem' AND posted = 1 AND
  (id IN (SELECT SubSystem FROM #Subsystems) OR @p2 = 1)
  ORDER BY code;
`;

interface MenuItem { type: string; icon: string; label: string; items?: MenuItem[]; routerLink?: string[]; }
router.get('/subsystems', authHTTP, async (req, res, next) => {
  try {
    const payload: IJWTPayload = (<any>req).user;
    const existing = await getUser(payload.email);
    if (!existing) { return res.status(401).json({ message: 'Auth failed' }); }
    const SubSystemsRaw = await sdba.manyOrNone<INoSqlDocument>(RolesQuery, [existing.id, existing.isAdmin]);
    const result = SubSystemsRaw.map(s => lib.doc.flatDocument(s));
    res.json(result);
  } catch (err) { next(err); }
});

router.get('/subsystems/menu', authHTTP, async (req, res, next) => {
  try {
    const payload: IJWTPayload = (<any>req).user;
    const existing = await getUser(payload.email);
    if (!existing) { return []; }
    const result = await buildMenu(existing);
    res.json(result || []);
  } catch (err) { next(err); }
});

export async function buildMenu(user: CatalogUser): Promise<MenuItem[]> {
  const SubSystemsRaw = await sdba.manyOrNone<INoSqlDocument>(RolesQuery, [user.id, user.isAdmin]);
  const sub = SubSystemsRaw.map(async (s) => {
    const flat = lib.doc.flatDocument(s)!;
    const SubSystem = createDocument<CatalogSubSystem>('Catalog.SubSystem', flat);
    return {
      type: SubSystem.type,
      icon: SubSystem.icon,
      label: SubSystem.description,
      items: await Promise.all([
        ...SubSystem.Documents.map(async el => {
          const Group = await lib.doc.byIdT<CatalogOperationGroup>(el.Group, sdba);
          if (Group) {
            return {
              type: el.Document as string, icon: Group.icon,
              routerLink: [`/${el.Document}/group/${Group.id}`], label: Group.menu
            };
          } else {
            const prop = createDocument(el.Document as string).Prop() as DocumentOptions;
            return { type: prop.type, icon: prop.icon, routerLink: ['/' + prop.type], label: prop.menu };
          }
        }),
        ...SubSystem.Catalogs.map(async el => {
          const prop = createDocument(el.Catalog as string).Prop() as DocumentOptions;
          return { type: prop.type, icon: prop.icon, routerLink: ['/' + prop.type], label: prop.menu };
        }),
        ...SubSystem.Forms.filter(el => el.Form).map(async el => {
          const prop = createForm({ type: el.Form as any }).Prop() as DocumentOptions;
          return { type: prop.type, icon: prop.icon, routerLink: ['/' + prop.type], label: prop.menu };
        }),
      ])
    };
  });
  const subs = await Promise.all(sub);
  return subs;
}
