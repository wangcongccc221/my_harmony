import { getORM, initORM, createRelationalStoreAdapter, setTimeFormat, LogLevel } from '@ibestservices/ibest-orm';
import { relationalStore } from '@kit.ArkData';
import common from '@ohos.app.ability.common';
import { User } from './entities/User';
import { TbFruitinfo } from './entities/TbFruitinfo';
import { TbGradeinfo } from './entities/TbGradeinfo';
import { TbExportinfo } from './entities/TbExportinfo';
import { TbSysFruitinfo } from './entities/TbSysFruitinfo';
import { TbFruitprocessinfo } from './entities/TbFruitprocessinfo';
import { TbUploadinfo } from './entities/TbUploadinfo';
import { TbRunningtimeinfo } from './entities/TbRunningtimeinfo';
import { TbSeparationefficiencyinfo } from './entities/TbSeparationefficiencyinfo';
import { TbPriceinfo } from './entities/TbPriceinfo';
import { TbBaseFault } from './entities/TbBaseFault';
import { TbFaultinfo } from './entities/TbFaultinfo';
import { TbClientinfo } from './entities/TbClientinfo';
import { TbCustomer } from './entities/TbCustomer';
import { TbSysConfigs } from './entities/TbSysConfigs';
import { TbSqlinfo } from './entities/TbSqlinfo';
import { TbUpdateversion } from './entities/TbUpdateversion';
import { TbFileinfo } from './entities/TbFileinfo';
import { TbFtpinfo } from './entities/TbFtpinfo';
import { TbLocation } from './entities/TbLocation';
import { YearlyTableManager } from './YearlyTableManager'

export class DbManager {
  private static instance: DbManager;
  private rdbStore: relationalStore.RdbStore | null = null

  public static getInstance(): DbManager {
    if (!DbManager.instance) {
      DbManager.instance = new DbManager();
    }
    return DbManager.instance;
  }

  /**
   * Initialize database configuration
   */
  public async init(context: common.Context): Promise<void> {
    // Set time format
    setTimeFormat('datetime');

    try {
      // Create adapter
      const adapter = await createRelationalStoreAdapter(context, {
        name: 'app.db',
        securityLevel: relationalStore.SecurityLevel.S1
      });

      // Initialize ORM
      initORM({ adapter, logLevel: LogLevel.DEBUG });
      
      // Auto migrate tables (Create/Update tables based on entities)
      const orm = getORM();
      orm.migrate(User);
      orm.migrate(TbSysConfigs);
      orm.migrate(TbCustomer);
      orm.migrate(TbFruitinfo);
      orm.migrate(TbGradeinfo);
      orm.migrate(TbExportinfo);
      orm.migrate(TbSysFruitinfo);
      orm.migrate(TbFruitprocessinfo);
      orm.migrate(TbUploadinfo);
      orm.migrate(TbRunningtimeinfo);
      orm.migrate(TbSeparationefficiencyinfo);
      orm.migrate(TbPriceinfo);
      orm.migrate(TbBaseFault);
      orm.migrate(TbFaultinfo);
      orm.migrate(TbClientinfo);
      orm.migrate(TbSqlinfo);
      orm.migrate(TbUpdateversion);
      orm.migrate(TbFileinfo);
      orm.migrate(TbFtpinfo);
      orm.migrate(TbLocation);

      const rdb = await relationalStore.getRdbStore(context, {
        name: 'app.db',
        securityLevel: relationalStore.SecurityLevel.S1
      })
      this.rdbStore = rdb
      await YearlyTableManager.ensureFruitProcessInfoYearTable(rdb, new Date().getFullYear())

      console.info('【database】: DbManager initialized successfully');
    } catch (e) {
      console.error(`【database】: DbManager init failed: ${JSON.stringify(e)}`);
    }
  }

  public getOrm() {
    return getORM();
  }

  public getRdbStore(): relationalStore.RdbStore | null {
    return this.rdbStore
  }
}
