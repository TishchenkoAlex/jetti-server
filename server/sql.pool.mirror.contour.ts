import { sqlConfigMirrorContour } from './env/environment';
import { SqlPool } from './mssql';

export const MIRROR_CONTOUR_POOL = new SqlPool(sqlConfigMirrorContour);
