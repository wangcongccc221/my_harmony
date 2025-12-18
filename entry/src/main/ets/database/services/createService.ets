import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import GlobalStore from '../orm/model/GlobalStore';
import { Class, GetIBestORM, GetTableName, IBestORM } from '../orm';
import { GetColumnMeta } from '../orm/decorator/Index';

const DOMAIN = 0x0000;

// ESObject 类型别名
type ESObject = object;

/**
 * 数据验证函数类型
 */
type ValidateDataFunc = (data: ESObject) => void;

/**
 * Service 选项配置
 */
interface ServiceOptions {
  validateData?: ValidateDataFunc;
  mode?: 'queue' | 'orm';
}

/**
 * Service 接口定义（用于返回类型）
 */
interface ServiceInterface {
  save: (data: ESObject, ctx?: Context) => Promise<number>;
  batchSave: (list: ESObject[], ctx?: Context) => Promise<number>;
  update: (id: number, data: ESObject, ctx?: Context) => Promise<number>;
  delete: (id: number, ctx?: Context) => Promise<number>;
  queryAll: (ctx?: Context) => Promise<ESObject[]>;
  queryPage: (page: number, size: number, ctx?: Context) => Promise<ESObject[]>;
  count: (ctx?: Context) => Promise<number>;
}

/**
 * 工厂函数：创建 Service 类
 */
export function createService(
  table: Class,
  columnMap: Record<string, string>,
  options?: ServiceOptions
): ServiceInterface {
  const validate = options?.validateData || (() => {});
  const mode = options?.mode ?? 'queue';

  /**
   * Service 类
   */
  class Service {
    private constructor() {}

    /**
     * 获取 Context
     */
    private static getContext(ctx?: Context): Context {
      if (ctx) return ctx;
      if (GlobalStore.context) return GlobalStore.context;
      throw new Error(
        'Database Context 未初始化！请确保在 EntryAbility.onCreate() 中执行了 GlobalStore.init(this.context)'
      );
    }

    private static getOrm(): IBestORM {
      const orm = GetIBestORM();
      if (!orm) {
        throw new Error('ORM 未初始化！请确保在 EntryAbility.onCreate() 中完成 ORM 初始化');
      }
      return orm;
    }

    private static getTableName(): string {
      return GetTableName(table);
    }

    private static getPrimaryKeyColumnName(): string {
      const meta = GetColumnMeta(table);
      for (let i = 0; i < meta.length; i++) {
        if (meta[i].tag?.includes('primaryKey') && meta[i].name) {
          return meta[i].name;
        }
      }
      return 'id';
    }

    private static countAllSync(): number {
      const orm = Service.getOrm();
      const core = orm.GetCore();
      if (!core) {
        throw new Error('无法获取数据库核心对象');
      }

      const tableName = Service.getTableName();
      const rs = core.querySqlSync(`SELECT COUNT(*) AS cnt FROM ${tableName}`);
      let total = 0;

      if (rs.columnCount > 0 && rs.goToFirstRow()) {
        const colName = rs.columnNames[0];
        total = rs.getDouble(rs.getColumnIndex(colName)) as number;
      }

      rs.close();
      return total;
    }

    /**
     * 字段映射转换
     */
    private static toValuesBucket(data: ESObject, map: Record<string, string>): relationalStore.ValuesBucket {
      const values: relationalStore.ValuesBucket = {};
      const keys = Object.keys(data);
      
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        const columnName = map[key];
        if (columnName) {
          const dataObj = data as Record<string, ESObject>;
          const value = dataObj[key];
          if (value !== undefined) {
            values[columnName] = value as relationalStore.ValueType;
          }
        }
      }
      
      return values;
    }

    /**
     * 保存单条数据
     */
    static async save(data: ESObject, ctx?: Context): Promise<number> {
      validate(data);
      const values = Service.toValuesBucket(data, columnMap);
      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        const id = await DatabaseQueueManager.insert(context, values, table);
        hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 保存成功 ID=${id}`);
        return id;
      }

      Service.getContext(ctx);
      const orm = Service.getOrm();
      const id = orm.Table(Service.getTableName()).Insert(values) as number;
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 保存成功 ID=${id}`);
      return id;
    }

    /**
     * 批量保存数据
     */
    static async batchSave(list: ESObject[], ctx?: Context): Promise<number> {
      if (!list || list.length === 0) return 0;

      if (mode === 'queue') {
        const context = Service.getContext(ctx);

        for (let i = 0; i < list.length; i++) {
          validate(list[i]);
        }

        const valuesList: relationalStore.ValuesBucket[] = [];
        for (let i = 0; i < list.length; i++) {
          const values = Service.toValuesBucket(list[i], columnMap);
          valuesList.push(values);
        }

        const count = await DatabaseQueueManager.batchInsert(context, valuesList, table);
        hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 批量保存成功 数量=${count}`);
        return count;
      }

      Service.getContext(ctx);

      for (let i = 0; i < list.length; i++) {
        validate(list[i]);
      }

      const valuesList: relationalStore.ValuesBucket[] = [];
      for (let i = 0; i < list.length; i++) {
        const values = Service.toValuesBucket(list[i], columnMap);
        valuesList.push(values);
      }

      const orm = Service.getOrm();
      const count = orm.Table(Service.getTableName()).Insert(valuesList) as number;
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 批量保存成功 数量=${count}`);
      return count;
    }

    /**
     * 更新数据
     */
    static async update(id: number, data: ESObject, ctx?: Context): Promise<number> {
      if (!id) throw new Error('更新必须提供有效 ID');

      validate(data);
      const values = Service.toValuesBucket(data, columnMap);

      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        const affected = await DatabaseQueueManager.update(context, id, values, table);
        hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 更新成功 ID=${id} 影响行数=${affected}`);
        return affected;
      }

      Service.getContext(ctx);
      const orm = Service.getOrm();
      const primaryKey = Service.getPrimaryKeyColumnName();
      const affected = orm.Table(Service.getTableName()).Where(primaryKey, id).Update(values) as number;
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 更新成功 ID=${id} 影响行数=${affected}`);
      return affected;
    }

    /**
     * 删除数据
     */
    static async delete(id: number, ctx?: Context): Promise<number> {
      if (!id) throw new Error('删除必须提供有效 ID');

      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        const affected = await DatabaseQueueManager.delete(context, id, table);
        hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 删除成功 ID=${id} 影响行数=${affected}`);
        return affected;
      }

      Service.getContext(ctx);
      const orm = Service.getOrm();
      const primaryKey = Service.getPrimaryKeyColumnName();
      const affected = orm.Table(Service.getTableName()).Where(primaryKey, id).Delete() as number;
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 删除成功 ID=${id} 影响行数=${affected}`);
      return affected;
    }

    /**
     * 查询所有数据
     */
    static async queryAll(ctx?: Context): Promise<ESObject[]> {
      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        return await DatabaseQueueManager.queryAll<ESObject>(context, table);
      }

      Service.getContext(ctx);
      const orm = Service.getOrm();
      return orm.Table(Service.getTableName()).Find(table) as ESObject[];
    }

    /**
     * 分页查询数据
     */
    static async queryPage(page: number, size: number, ctx?: Context): Promise<ESObject[]> {
      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        return await DatabaseQueueManager.queryPage<ESObject>(context, page, size, table);
      }

      Service.getContext(ctx);
      const orm = Service.getOrm();
      const safePage = Math.max(1, page);
      const safeSize = Math.max(1, size);
      const offset = (safePage - 1) * safeSize;
      return orm.Table(Service.getTableName()).Limit(safeSize).Offset(offset).Find(table) as ESObject[];
    }

    /**
     * 统计总数
     */
    static async count(ctx?: Context): Promise<number> {
      if (mode === 'queue') {
        const context = Service.getContext(ctx);
        return await DatabaseQueueManager.countAll(context, table);
      }

      Service.getContext(ctx);
      return Service.countAllSync();
    }
  }

  return Service;
}

export function createOrmService(
  table: Class,
  columnMap: Record<string, string>,
  options?: Omit<ServiceOptions, 'mode'>
): ServiceInterface {
  return createService(table, columnMap, { ...options, mode: 'orm' });
}

