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


