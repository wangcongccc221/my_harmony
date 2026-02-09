import { relationalStore } from '@kit.ArkData'

export class YearlyTableManager {
  static getFruitProcessInfoTableName(year: number): string {
    const y = Math.max(1970, Math.floor(year))
    return `tb_fruitprocessinfo_${y}`
  }

  static async ensureFruitProcessInfoYearTable(store: relationalStore.RdbStore, year: number): Promise<void> {
    const tableName = YearlyTableManager.getFruitProcessInfoTableName(year)
    const sql =
      `CREATE TABLE IF NOT EXISTS ${tableName} (` +
      `FID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,` +
      `RealWeightCount REAL,` +
      `RealWeightCountPer REAL,` +
      `SeparationEfficiency REAL,` +
      `SpeedPercent REAL,` +
      `AvgWeight REAL,` +
      `RunningDate TEXT` +
      `);`
    await store.executeSql(sql)
  }
}
