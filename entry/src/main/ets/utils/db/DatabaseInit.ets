import common from '@ohos.app.ability.common';
import { IBestORMInit, GetIBestORM } from '@ibestservices/ibest-orm';
import { relationalStore } from '@kit.ArkData';
import { HistoryRecord } from './models/HistoryRecord';
import { ProcessingRecord } from './models/ProcessingRecord';

export async function initializeDatabase(context: common.UIAbilityContext): Promise<void> {
  await IBestORMInit(context, {
    name: 'app_database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  });

  const db = GetIBestORM();
  db.AutoMigrate(HistoryRecord);
  db.AutoMigrate(ProcessingRecord);
}


