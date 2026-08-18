import { MSSQL } from '../../mssql';
import { BusinessProcessSchedulerStatus } from '../types/business-process.types';

export interface BusinessProcessSchedulerLockResult<TResult> {
  acquired: boolean;
  result?: TResult;
}

export class BusinessProcessSchedulerLock {
  static readonly RESOURCE = 'BusinessProcess.Scheduler.Tick';

  async runExclusive<TResult>(
    db: MSSQL,
    action: (session: MSSQL) => Promise<TResult>,
  ): Promise<BusinessProcessSchedulerLockResult<TResult>> {
    return db.session(async session => {
      const acquired = await this.acquire(session);
      if (!acquired) return { acquired: false };

      try {
        return { acquired: true, result: await action(session) };
      } finally {
        await this.release(session);
      }
    });
  }

  async status(db: MSSQL): Promise<BusinessProcessSchedulerStatus> {
    const row = await db.oneOrNone<{
      lockAvailable: number;
      databaseTime: Date;
    }>(
      `SELECT
         APPLOCK_TEST(N'public', @p1, N'Exclusive', N'Session') lockAvailable,
         SYSUTCDATETIME() databaseTime`,
      [BusinessProcessSchedulerLock.RESOURCE],
    );
    if (!row) throw new Error('Cannot read business process scheduler status');
    return {
      lock: {
        resource: BusinessProcessSchedulerLock.RESOURCE,
        available: Number(row.lockAvailable) === 1,
      },
      databaseTime: row.databaseTime,
    };
  }

  private async acquire(db: MSSQL): Promise<boolean> {
    const row = await db.oneOrNone<{ lockResult: number }>(
      `DECLARE @lockResult INT;
       EXEC @lockResult = sys.sp_getapplock
         @Resource = @p1,
         @LockMode = N'Exclusive',
         @LockOwner = N'Session',
         @LockTimeout = 0;
       SELECT @lockResult lockResult;`,
      [BusinessProcessSchedulerLock.RESOURCE],
    );
    return !!row && Number(row.lockResult) >= 0;
  }

  private async release(db: MSSQL): Promise<void> {
    await db.none(
      `EXEC sys.sp_releaseapplock
         @Resource = @p1,
         @LockOwner = N'Session';`,
      [BusinessProcessSchedulerLock.RESOURCE],
    );
  }
}
