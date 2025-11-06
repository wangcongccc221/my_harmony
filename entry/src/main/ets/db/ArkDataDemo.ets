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

// 水果信息接口
export interface FruitInfoRow {
  id: number;
  lane: string;  // 通道，如 'lane-1'
  level: string;  // 等级
  diameterMm: number;  // 直径(mm)
  weightG: number;  // 重量(g)
  projectionAreaMm2: number;  // 投影面积(mm²)
  densityKgPerM3: number;  // 密度(kg/m³)
  volumeMm3: number;  // 体积(mm³)
  brix: number;  // 糖度
  color1Pct: number;  // 颜色1比例(%)
  acidity: number;  // 酸度
  color2Pct: number;  // 颜色2比例(%)
  drynessPct: number;  // 干燥度(%)
  color3Pct: number;  // 颜色3比例(%)
  maturityPct: number;  // 成熟度(%)
  defectAreaMm2: number;  // 瑕疵面积(mm²)
  pulpColorPct: number;  // 果肉颜色比例(%)
  defectCount: number;  // 瑕疵数量
  outlet: string;  // 出口
  verticalAxis: number;  // 垂直轴
  horizontalRatio: number;  // 水平比例
  flatEllipticalRatioMm: number;  // 扁平椭圆比例(mm)
  detectionTime: string;  // 检测时间
  processingId?: number;  // 关联的加工批次ID（可选）
}

export interface FruitInfoInsertParams {
  lane: string;
  level: string;
  diameterMm: number;
  weightG: number;
  projectionAreaMm2: number;
  densityKgPerM3: number;
  volumeMm3: number;
  brix: number;
  color1Pct: number;
  acidity: number;
  color2Pct: number;
  drynessPct: number;
  color3Pct: number;
  maturityPct: number;
  defectAreaMm2: number;
  pulpColorPct: number;
  defectCount: number;
  outlet: string;
  verticalAxis: number;
  horizontalRatio: number;
  flatEllipticalRatioMm: number;
  detectionTime: string;
  processingId?: number;
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

  /**
   * 更新加工记录（支持所有字段）
   */
  static async updateProcessingFull(id: number, params: ProcessingInsertParams): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'UPDATE processing_history SET startTime=?, endTime=?, productType=?, totalWeight=?, customerName=?, farmName=?, fruitName=?, status=?, count=?, weight=? WHERE id=?';
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
        typeof params.weight === 'number' ? params.weight : params.totalWeight,
        id
      ]);
      hilog.info(DOMAIN, TAG, 'updateProcessingFull ok, id: %{public}d', id);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'updateProcessingFull failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  /**
   * 检查记录是否存在
   */
  static async checkProcessingExists(id: number): Promise<boolean> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'SELECT id FROM processing_history WHERE id=? LIMIT 1';
      const resultSet = await store.querySql(sql, [id]);
      try {
        const exists = resultSet.goToFirstRow();
        return exists;
      } finally {
        resultSet.close();
      }
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'checkProcessingExists failed: %{public}s', JSON.stringify(err));
      return false;
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

  /**
   * 分页查询加工历史（带时间过滤）
   * @param limit 每页数量（默认100，最大1000）
   * @param offset 跳过多少条（用于翻页）
   * @param startTime 开始时间（可选，格式：'2024-01-01 00:00:00'）
   * @param endTime 结束时间（可选）
   * @returns 加工记录数组
   */
  static async queryProcessingPaged(limit: number = 100, offset: number = 0, startTime?: string, endTime?: string): Promise<ProcessingRow[]> {
    try {
      // 限制最大数量，防止一次性查询太多
      const maxLimit = Math.min(limit, 1000);
      const store = await ArkDataDemoService.getStore();
      
      // 构建SQL（带时间过滤）
      let sql = 'SELECT id, startTime, endTime, productType, totalWeight, customerName, farmName, fruitName, status, count, weight FROM processing_history WHERE 1=1';
      const params: (string | number)[] = [];
      
      if (startTime) {
        sql += ' AND startTime >= ?';
        params.push(startTime);
      }
      if (endTime) {
        sql += ' AND startTime <= ?';
        params.push(endTime);
      }
      
      sql += ' ORDER BY id DESC LIMIT ? OFFSET ?';
      params.push(maxLimit, offset);
      
      const rs = await store.querySql(sql, params);
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
      hilog.info(DOMAIN, TAG, `queryProcessingPaged: 返回 ${out.length} 条记录 (limit=${maxLimit}, offset=${offset})`);
      return out;
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'queryProcessingPaged failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  /**
   * 获取加工历史总数（用于分页计算总页数）
   * @param startTime 开始时间（可选）
   * @param endTime 结束时间（可选）
   * @returns 总记录数
   */
  static async getProcessingCount(startTime?: string, endTime?: string): Promise<number> {
    try {
      const store = await ArkDataDemoService.getStore();
      let sql = 'SELECT COUNT(*) as total FROM processing_history WHERE 1=1';
      const params: string[] = [];
      
      if (startTime) {
        sql += ' AND startTime >= ?';
        params.push(startTime);
      }
      if (endTime) {
        sql += ' AND startTime <= ?';
        params.push(endTime);
      }
      
      const rs = await store.querySql(sql, params);
      try {
        if (rs.goToFirstRow()) {
          const total = rs.getLong(0);
          return Number(total);
        }
        return 0;
      } finally {
        rs.close();
      }
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'getProcessingCount failed: %{public}s', JSON.stringify(err));
      return 0;
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

  // ========== 水果信息表操作 ==========
  static async createFruitInfoTable(): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'CREATE TABLE IF NOT EXISTS fruit_info (\n' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,\n' +
        '  lane TEXT NOT NULL,\n' +
        '  level TEXT,\n' +
        '  diameterMm REAL,\n' +
        '  weightG REAL,\n' +
        '  projectionAreaMm2 REAL,\n' +
        '  densityKgPerM3 REAL,\n' +
        '  volumeMm3 REAL,\n' +
        '  brix REAL,\n' +
        '  color1Pct REAL,\n' +
        '  acidity REAL,\n' +
        '  color2Pct REAL,\n' +
        '  drynessPct REAL,\n' +
        '  color3Pct REAL,\n' +
        '  maturityPct REAL,\n' +
        '  defectAreaMm2 REAL,\n' +
        '  pulpColorPct REAL,\n' +
        '  defectCount INTEGER,\n' +
        '  outlet TEXT,\n' +
        '  verticalAxis REAL,\n' +
        '  horizontalRatio REAL,\n' +
        '  flatEllipticalRatioMm REAL,\n' +
        '  detectionTime TEXT NOT NULL,\n' +
        '  processingId INTEGER\n' +
        ');';
      await store.executeSql(sql, []);
      hilog.info(DOMAIN, TAG, 'createFruitInfoTable ok');
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'createFruitInfoTable failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async insertFruitInfo(params: FruitInfoInsertParams): Promise<number> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'INSERT INTO fruit_info(lane, level, diameterMm, weightG, projectionAreaMm2, densityKgPerM3, volumeMm3, brix, color1Pct, acidity, color2Pct, drynessPct, color3Pct, maturityPct, defectAreaMm2, pulpColorPct, defectCount, outlet, verticalAxis, horizontalRatio, flatEllipticalRatioMm, detectionTime, processingId) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
      await store.executeSql(sql, [
        params.lane,
        params.level || '',
        params.diameterMm || 0,
        params.weightG || 0,
        params.projectionAreaMm2 || 0,
        params.densityKgPerM3 || 0,
        params.volumeMm3 || 0,
        params.brix || 0,
        params.color1Pct || 0,
        params.acidity || 0,
        params.color2Pct || 0,
        params.drynessPct || 0,
        params.color3Pct || 0,
        params.maturityPct || 0,
        params.defectAreaMm2 || 0,
        params.pulpColorPct || 0,
        params.defectCount || 0,
        params.outlet || '',
        params.verticalAxis || 0,
        params.horizontalRatio || 0,
        params.flatEllipticalRatioMm || 0,
        params.detectionTime,
        params.processingId || null
      ]);
      // 获取插入的ID
      // 方法1：尝试使用 last_insert_rowid()
      let id = 0;
      try {
        const resultSet = await store.querySql('SELECT last_insert_rowid() as id', []);
        try {
          if (resultSet.goToFirstRow()) {
            // 尝试通过列名获取
            try {
              const idIndex = resultSet.getColumnIndex('id');
              id = Number(resultSet.getLong(idIndex));
            } catch (e) {
              // 如果通过列名获取失败，尝试通过索引获取
              id = Number(resultSet.getLong(0));
            }
          }
        } finally {
          resultSet.close();
        }
      } catch (e) {
        hilog.warn(DOMAIN, TAG, 'last_insert_rowid() failed, trying alternative method');
      }
      
      // 方法2：如果 last_insert_rowid() 返回0或失败，查询最后插入的记录
      if (id === 0) {
        try {
          const resultSet2 = await store.querySql('SELECT id FROM fruit_info ORDER BY id DESC LIMIT 1', []);
          try {
            if (resultSet2.goToFirstRow()) {
              const idIndex2 = resultSet2.getColumnIndex('id');
              id = Number(resultSet2.getLong(idIndex2));
            }
          } finally {
            resultSet2.close();
          }
        } catch (e2) {
          hilog.warn(DOMAIN, TAG, 'Alternative ID query failed: %{public}s', JSON.stringify(e2));
        }
      }
      
      hilog.info(DOMAIN, TAG, 'insertFruitInfo ok, id: %{public}d', id);
      return id;
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'insertFruitInfo failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async queryAllFruitInfo(): Promise<FruitInfoRow[]> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'SELECT * FROM fruit_info ORDER BY detectionTime DESC, id DESC';
      const resultSet = await store.querySql(sql, []);
      const rows: FruitInfoRow[] = [];
      try {
        let hasNext = resultSet.goToFirstRow();
        while (hasNext) {
          rows.push({
            id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
            lane: resultSet.getString(resultSet.getColumnIndex('lane')) || '',
            level: resultSet.getString(resultSet.getColumnIndex('level')) || '',
            diameterMm: Number(resultSet.getDouble(resultSet.getColumnIndex('diameterMm'))),
            weightG: Number(resultSet.getDouble(resultSet.getColumnIndex('weightG'))),
            projectionAreaMm2: Number(resultSet.getDouble(resultSet.getColumnIndex('projectionAreaMm2'))),
            densityKgPerM3: Number(resultSet.getDouble(resultSet.getColumnIndex('densityKgPerM3'))),
            volumeMm3: Number(resultSet.getDouble(resultSet.getColumnIndex('volumeMm3'))),
            brix: Number(resultSet.getDouble(resultSet.getColumnIndex('brix'))),
            color1Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color1Pct'))),
            acidity: Number(resultSet.getDouble(resultSet.getColumnIndex('acidity'))),
            color2Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color2Pct'))),
            drynessPct: Number(resultSet.getDouble(resultSet.getColumnIndex('drynessPct'))),
            color3Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color3Pct'))),
            maturityPct: Number(resultSet.getDouble(resultSet.getColumnIndex('maturityPct'))),
            defectAreaMm2: Number(resultSet.getDouble(resultSet.getColumnIndex('defectAreaMm2'))),
            pulpColorPct: Number(resultSet.getDouble(resultSet.getColumnIndex('pulpColorPct'))),
            defectCount: Number(resultSet.getLong(resultSet.getColumnIndex('defectCount'))),
            outlet: resultSet.getString(resultSet.getColumnIndex('outlet')) || '',
            verticalAxis: Number(resultSet.getDouble(resultSet.getColumnIndex('verticalAxis'))),
            horizontalRatio: Number(resultSet.getDouble(resultSet.getColumnIndex('horizontalRatio'))),
            flatEllipticalRatioMm: Number(resultSet.getDouble(resultSet.getColumnIndex('flatEllipticalRatioMm'))),
            detectionTime: resultSet.getString(resultSet.getColumnIndex('detectionTime')) || '',
            processingId: resultSet.isColumnNull(resultSet.getColumnIndex('processingId')) ? undefined : Number(resultSet.getLong(resultSet.getColumnIndex('processingId')))
          });
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
      hilog.error(DOMAIN, TAG, 'queryAllFruitInfo failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  static async deleteFruitInfoById(id: number): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'DELETE FROM fruit_info WHERE id = ?';
      await store.executeSql(sql, [id]);
      hilog.info(DOMAIN, TAG, 'deleteFruitInfoById ok, id: %{public}d', id);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'deleteFruitInfoById failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  /**
   * 根据通道查询水果信息（如果存在）
   */
  static async queryFruitInfoByLane(lane: string): Promise<FruitInfoRow | null> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'SELECT * FROM fruit_info WHERE lane = ? ORDER BY detectionTime DESC, id DESC LIMIT 1';
      const resultSet = await store.querySql(sql, [lane]);
      try {
        if (resultSet.goToFirstRow()) {
          const row: FruitInfoRow = {
            id: Number(resultSet.getLong(resultSet.getColumnIndex('id'))),
            lane: resultSet.getString(resultSet.getColumnIndex('lane')) || '',
            level: resultSet.getString(resultSet.getColumnIndex('level')) || '',
            diameterMm: Number(resultSet.getDouble(resultSet.getColumnIndex('diameterMm'))),
            weightG: Number(resultSet.getDouble(resultSet.getColumnIndex('weightG'))),
            projectionAreaMm2: Number(resultSet.getDouble(resultSet.getColumnIndex('projectionAreaMm2'))),
            densityKgPerM3: Number(resultSet.getDouble(resultSet.getColumnIndex('densityKgPerM3'))),
            volumeMm3: Number(resultSet.getDouble(resultSet.getColumnIndex('volumeMm3'))),
            brix: Number(resultSet.getDouble(resultSet.getColumnIndex('brix'))),
            color1Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color1Pct'))),
            acidity: Number(resultSet.getDouble(resultSet.getColumnIndex('acidity'))),
            color2Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color2Pct'))),
            drynessPct: Number(resultSet.getDouble(resultSet.getColumnIndex('drynessPct'))),
            color3Pct: Number(resultSet.getDouble(resultSet.getColumnIndex('color3Pct'))),
            maturityPct: Number(resultSet.getDouble(resultSet.getColumnIndex('maturityPct'))),
            defectAreaMm2: Number(resultSet.getDouble(resultSet.getColumnIndex('defectAreaMm2'))),
            pulpColorPct: Number(resultSet.getDouble(resultSet.getColumnIndex('pulpColorPct'))),
            defectCount: Number(resultSet.getLong(resultSet.getColumnIndex('defectCount'))),
            outlet: resultSet.getString(resultSet.getColumnIndex('outlet')) || '',
            verticalAxis: Number(resultSet.getDouble(resultSet.getColumnIndex('verticalAxis'))),
            horizontalRatio: Number(resultSet.getDouble(resultSet.getColumnIndex('horizontalRatio'))),
            flatEllipticalRatioMm: Number(resultSet.getDouble(resultSet.getColumnIndex('flatEllipticalRatioMm'))),
            detectionTime: resultSet.getString(resultSet.getColumnIndex('detectionTime')) || '',
            processingId: resultSet.isColumnNull(resultSet.getColumnIndex('processingId')) ? undefined : Number(resultSet.getLong(resultSet.getColumnIndex('processingId')))
          };
          return row;
        }
        return null;
      } finally {
        resultSet.close();
      }
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'queryFruitInfoByLane failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  /**
   * 更新水果信息（根据ID）
   */
  static async updateFruitInfoById(id: number, params: FruitInfoInsertParams): Promise<void> {
    try {
      const store = await ArkDataDemoService.getStore();
      const sql = 'UPDATE fruit_info SET lane=?, level=?, diameterMm=?, weightG=?, projectionAreaMm2=?, densityKgPerM3=?, volumeMm3=?, brix=?, color1Pct=?, acidity=?, color2Pct=?, drynessPct=?, color3Pct=?, maturityPct=?, defectAreaMm2=?, pulpColorPct=?, defectCount=?, outlet=?, verticalAxis=?, horizontalRatio=?, flatEllipticalRatioMm=?, detectionTime=?, processingId=? WHERE id=?';
      await store.executeSql(sql, [
        params.lane,
        params.level || '',
        params.diameterMm || 0,
        params.weightG || 0,
        params.projectionAreaMm2 || 0,
        params.densityKgPerM3 || 0,
        params.volumeMm3 || 0,
        params.brix || 0,
        params.color1Pct || 0,
        params.acidity || 0,
        params.color2Pct || 0,
        params.drynessPct || 0,
        params.color3Pct || 0,
        params.maturityPct || 0,
        params.defectAreaMm2 || 0,
        params.pulpColorPct || 0,
        params.defectCount || 0,
        params.outlet || '',
        params.verticalAxis || 0,
        params.horizontalRatio || 0,
        params.flatEllipticalRatioMm || 0,
        params.detectionTime,
        params.processingId || null,
        id
      ]);
      hilog.info(DOMAIN, TAG, 'updateFruitInfoById ok, id: %{public}d', id);
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'updateFruitInfoById failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }

  /**
   * 插入或更新水果信息（根据通道，存在则更新，不存在则插入）
   */
  static async upsertFruitInfo(params: FruitInfoInsertParams): Promise<number> {
    try {
      // 先查询该通道是否已有数据
      const existing = await ArkDataDemoService.queryFruitInfoByLane(params.lane);
      
      if (existing) {
        // 如果存在，则更新
        await ArkDataDemoService.updateFruitInfoById(existing.id, params);
        hilog.info(DOMAIN, TAG, 'upsertFruitInfo: 更新数据，id: %{public}d, lane: %{public}s', existing.id, params.lane);
        return existing.id;
      } else {
        // 如果不存在，则插入
        const newId = await ArkDataDemoService.insertFruitInfo(params);
        hilog.info(DOMAIN, TAG, 'upsertFruitInfo: 插入新数据，id: %{public}d, lane: %{public}s', newId, params.lane);
        return newId;
      }
    } catch (error) {
      const err = error as object;
      hilog.error(DOMAIN, TAG, 'upsertFruitInfo failed: %{public}s', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    }
  }
}


