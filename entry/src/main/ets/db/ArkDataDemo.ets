import { Context } from '@kit.AbilityKit';
import relationalStore from '@ohos.data.relationalStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'ArkDataDemoService';

interface UserRow {
  id: number;
  name: string;
  age: number;
}

export interface ProcessingRow {
  id: number;
  startTime: string;
  endTime: string;
  productType: string;
  totalWeight: number;
  // 扩展字段（仅用于HTTP缓存/页面展示，RDB未持久化这些字段）
  customerName?: string;
  farmName?: string;
  fruitName?: string;
  status?: string;
  count?: number;
  weight?: number;
}

export interface ProcessingInsertParams {
  startTime: string;
  endTime: string;
  productType: string;
  totalWeight: number;
  customerName?: string;
  farmName?: string;
  fruitName?: string;
  status?: string;
  count?: number;
  weight?: number;
}

export class ArkDataDemoService {
  private static appContext: Context | null = null;
  private static store: relationalStore.RdbStore | null = null;
  private static readonly dbName: string = 'app_demo.db';
  private static readonly tableUsers: string = 'users';

  static init(context: Context): void {
    ArkDataDemoService.appContext = context;
    hilog.info(DOMAIN, TAG, 'DB init context set');
  }

  private static async getStore(): Promise<relationalStore.RdbStore> {
    if (ArkDataDemoService.store) {
      return ArkDataDemoService.store as relationalStore.RdbStore;
    }
    const context = ArkDataDemoService.appContext;
    if (!context) {
      throw new Error('ArkDataDemoService not initialized. Call init(context) first.');
    }

    const config: relationalStore.StoreConfig = {
      name: ArkDataDemoService.dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    const store = await new Promise<relationalStore.RdbStore>((resolve, reject) => {
      try {
        relationalStore.getRdbStore(context, config, (err, rdb) => {
          if (err) {
            reject(err);
            return;
          }
          resolve(rdb);
        });
      } catch (e) {
        const err = e as object;
        reject(new Error(JSON.stringify(err)));
      }
    });
    ArkDataDemoService.store = store;
    return store;
  }

  static async createUsersTable(): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'CREATE TABLE IF NOT EXISTS ' + ArkDataDemoService.tableUsers + ' (\n' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
        '  name TEXT NOT NULL,\n' +
        '  age INTEGER\n' +
        ');';
      await store.executeSql(sql, []);
      hilog.info(DOMAIN, TAG, 'createUsersTable ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'createUsersTable failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async createProcessingHistoryTable(): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'CREATE TABLE IF NOT EXISTS processing_history (\n' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
        '  startTime TEXT,\n' +
        '  endTime TEXT,\n' +
        '  productType TEXT,\n' +
        '  totalWeight REAL\n' +
        ');';
      await store.executeSql(sql, []);
      // 尝试补充新增列（兼容升级），忽略已存在的错误
      const addCols: string[] = [
        'ALTER TABLE processing_history ADD COLUMN customerName TEXT;',
        'ALTER TABLE processing_history ADD COLUMN farmName TEXT;',
        'ALTER TABLE processing_history ADD COLUMN fruitName TEXT;',
        'ALTER TABLE processing_history ADD COLUMN status TEXT;',
        'ALTER TABLE processing_history ADD COLUMN count INTEGER;',
        'ALTER TABLE processing_history ADD COLUMN weight REAL;'
      ];
      for (let i = 0; i < addCols.length; i++) {
        try { await store.executeSql(addCols[i], []); } catch (_) {}
      }
      hilog.info(DOMAIN, TAG, 'createProcessingHistoryTable ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'createProcessingHistoryTable failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async insertProcessingFull(params: ProcessingInsertParams): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'INSERT INTO processing_history(startTime, endTime, productType, totalWeight, customerName, farmName, fruitName, status, count, weight) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
      await store.executeSql(sql, [
        params.startTime,
        params.endTime,
        params.productType,
        params.totalWeight,
        params.customerName || '',
        params.farmName || '',
        params.fruitName || params.productType || '',
        params.status || '',
        typeof params.count === 'number' ? params.count : 0,
        typeof params.weight === 'number' ? params.weight : params.totalWeight
      ]);
      hilog.info(DOMAIN, TAG, 'insertProcessingFull ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'insertProcessingFull failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async insertProcessing(startTime: string, endTime: string, productType: string, totalWeight: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'INSERT INTO processing_history(startTime, endTime, productType, totalWeight) VALUES(?, ?, ?, ?)';
      await store.executeSql(sql, [startTime, endTime, productType, totalWeight]);
      hilog.info(DOMAIN, TAG, 'insertProcessing ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'insertProcessing failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async updateProcessingById(id: number, startTime: string, endTime: string, productType: string, totalWeight: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'UPDATE processing_history SET startTime=?, endTime=?, productType=?, totalWeight=? WHERE id=?';
      await store.executeSql(sql, [startTime, endTime, productType, totalWeight, id]);
      hilog.info(DOMAIN, TAG, 'updateProcessing ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'updateProcessing failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async deleteProcessingById(id: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'DELETE FROM processing_history WHERE id=?';
      await store.executeSql(sql, [id]);
      hilog.info(DOMAIN, TAG, 'deleteProcessing ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'deleteProcessing failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async queryAllProcessing(): Promise<ProcessingRow[]> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'SELECT id, startTime, endTime, productType, totalWeight, customerName, farmName, fruitName, status, count, weight FROM processing_history ORDER BY id DESC';
      const rs = await store.querySql(sql, []);
      const out: ProcessingRow[] = [];
      try {
        let has = rs.goToFirstRow();
        while (has) {
          const idVal = rs.getLong(0);
          const s = rs.getString(1);
          const e = rs.getString(2);
          const p = rs.getString(3);
          const w = rs.getDouble(4);
          const cn = rs.getString(5);
          const fn = rs.getString(6);
          const fruit = rs.getString(7);
          const st = rs.getString(8);
          const cnt = rs.getLong(9);
          const wt = rs.getDouble(10);
          out.push({
            id: Number(idVal),
            startTime: s,
            endTime: e,
            productType: p,
            totalWeight: Number(w),
            customerName: cn || '',
            farmName: fn || '',
            fruitName: fruit || p || '',
            status: st || '',
            count: typeof cnt === 'number' ? Number(cnt) : 0,
            weight: typeof wt === 'number' ? Number(wt) : Number(w)
          });
          has = rs.goToNextRow();
        }
      } catch (inner) {
        const err = inner as object;
        hilog.error(DOMAIN, TAG, 'iterate processing rs failed: %{public}s', JSON.stringify(err));
        throw new Error(JSON.stringify(err));
      } finally {
        try { rs.close(); } catch (_) {}
      }
      return out;
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'queryAllProcessing failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async insertUser(name: string, age: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'INSERT INTO ' + ArkDataDemoService.tableUsers + ' (name, age) VALUES (?, ?)';
      await store.executeSql(sql, [name, age]);
      hilog.info(DOMAIN, TAG, 'insertUser ok %{public}s', name);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'insertUser failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async queryAllUsers(): Promise<UserRow[]> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'SELECT id, name, age FROM ' + ArkDataDemoService.tableUsers + ' ORDER BY id ASC';
      const resultSet = await store.querySql(sql, []);
      const rows: UserRow[] = [];
      try {
        let hasNext = resultSet.goToFirstRow();
        while (hasNext) {
          const idVal = resultSet.getLong(0);
          const nameVal = resultSet.getString(1);
          const ageVal = resultSet.getLong(2);
          rows.push({ id: Number(idVal), name: nameVal, age: Number(ageVal) });
          hasNext = resultSet.goToNextRow();
        }
      } catch (inner) {
        const err = inner as object;
        hilog.error(DOMAIN, TAG, 'iterate ResultSet failed: %{public}s', JSON.stringify(err));
        throw new Error(JSON.stringify(err));
      } finally {
        try {
          resultSet.close();
        } catch (closeErr) {
          const err = closeErr as object;
          hilog.warn(DOMAIN, TAG, 'ResultSet close warn: %{public}s', JSON.stringify(err));
        }
      }
      return rows;
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'queryAllUsers failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async updateUserAgeByName(name: string, age: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'UPDATE ' + ArkDataDemoService.tableUsers + ' SET age = ? WHERE name = ?';
      await store.executeSql(sql, [age, name]);
      hilog.info(DOMAIN, TAG, 'updateUserAgeByName ok %{public}s', name);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'updateUserAgeByName failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async deleteUserByName(name: string): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'DELETE FROM ' + ArkDataDemoService.tableUsers + ' WHERE name = ?';
      await store.executeSql(sql, [name]);
      hilog.info(DOMAIN, TAG, 'deleteUserByName ok %{public}s', name);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'deleteUserByName failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }
}


