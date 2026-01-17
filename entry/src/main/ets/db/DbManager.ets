import { getORM, initORM, createRelationalStoreAdapter, setTimeFormat, LogLevel } from '@ibestservices/ibest-orm';
import { relationalStore } from '@kit.ArkData';
import common from '@ohos.app.ability.common';
import { User } from './entities/User';
// import { 表名 } from './entities/表名';
// import { TbFruitinfo } from './entities/TbFruitinfo';
// import { TbGradeinfo } from './entities/TbGradeinfo';
// import { TbExportinfo } from './entities/TbExportinfo';
// import { TbSysFruitinfo } from './entities/TbSysFruitinfo';
// import { TbFruitprocessinfo } from './entities/TbFruitprocessinfo';
// import { TbUploadinfo } from './entities/TbUploadinfo';
// import { TbRunningtimeinfo } from './entities/TbRunningtimeinfo';
// import { TbSeparationefficiencyinfo } from './entities/TbSeparationefficiencyinfo';
// import { TbPriceinfo } from './entities/TbPriceinfo';
// import { TbBaseFault } from './entities/TbBaseFault';
// import { TbFaultinfo } from './entities/TbFaultinfo';
// import { TbClientinfo } from './entities/TbClientinfo';
// import { TbCustomer } from './entities/TbCustomer';
// import { TbSysConfigs } from './entities/TbSysConfigs';
// import { TbSqlinfo } from './entities/TbSqlinfo';
// import { TbUpdateversion } from './entities/TbUpdateversion';
// import { TbFileinfo } from './entities/TbFileinfo';
// import { TbFtpinfo } from './entities/TbFtpinfo';
// import { TbLocation } from './entities/TbLocation';

export class DbManager {
  private static instance: DbManager;

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
      getORM().migrate(User);

      console.info('【database】: DbManager initialized successfully');
    } catch (e) {
      console.error(`【database】: DbManager init failed: ${JSON.stringify(e)}`);
    }
  }

  public getOrm() {
    return getORM();
  }
}