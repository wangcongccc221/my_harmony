import { Context } from '@kit.AbilityKit';
import { DatabaseQueueManager } from '../../utils/network/database/dispatch/DatabaseQueueManager';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import GlobalStore from '../orm/model/GlobalStore';
import { Class } from '../orm';

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
      const context = Service.getContext(ctx);
      validate(data);
      const values = Service.toValuesBucket(data, columnMap);
      const id = await DatabaseQueueManager.insert(context, values, table);
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 保存成功 ID=${id}`);
      return id;
    }

    /**
     * 批量保存数据
     */
    static async batchSave(list: ESObject[], ctx?: Context): Promise<number> {
      if (!list || list.length === 0) return 0;
      
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

    /**
     * 更新数据
     */
    static async update(id: number, data: ESObject, ctx?: Context): Promise<number> {
      if (!id) throw new Error('更新必须提供有效 ID');
      
      const context = Service.getContext(ctx);
      validate(data);
      const values = Service.toValuesBucket(data, columnMap);
      const affected = await DatabaseQueueManager.update(context, id, values, table);
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 更新成功 ID=${id} 影响行数=${affected}`);
      return affected;
    }

    /**
     * 删除数据
     */
    static async delete(id: number, ctx?: Context): Promise<number> {
      if (!id) throw new Error('删除必须提供有效 ID');
      
      const context = Service.getContext(ctx);
      const affected = await DatabaseQueueManager.delete(context, id, table);
      hilog.info(DOMAIN, 'Service', `${table.name || 'Unknown'} 删除成功 ID=${id} 影响行数=${affected}`);
      return affected;
    }

    /**
     * 查询所有数据
     */
    static async queryAll(ctx?: Context): Promise<ESObject[]> {
      const context = Service.getContext(ctx);
      return await DatabaseQueueManager.queryAll<ESObject>(context, table);
    }

    /**
     * 分页查询数据
     */
    static async queryPage(page: number, size: number, ctx?: Context): Promise<ESObject[]> {
      const context = Service.getContext(ctx);
      return await DatabaseQueueManager.queryPage<ESObject>(context, page, size, table);
    }

    /**
     * 统计总数
     */
    static async count(ctx?: Context): Promise<number> {
      const context = Service.getContext(ctx);
      return await DatabaseQueueManager.countAll(context, table);
    }
  }

  return Service;
}

