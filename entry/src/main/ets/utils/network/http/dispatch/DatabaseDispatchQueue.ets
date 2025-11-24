import { DispatchQueue, DispatchTask, QueueType } from '@magicnumber/dispatch';
import { Context } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { taskpool } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ProcessingHistoryData } from '../../../../database/types';

const DOMAIN = 0x0000;

// ESObject 类型别名（Dispatch 库使用但未导出）
type ESObject = object;

/**
 * 数据库操作类型
 */
export enum DatabaseTaskType {
  QUERY_ALL = 'QUERY_ALL',
  QUERY_PAGE = 'QUERY_PAGE',
  COUNT_ALL = 'COUNT_ALL',
  INSERT = 'INSERT',
  BATCH_INSERT = 'BATCH_INSERT',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE'
}

/**
 * 数据库任务参数接口
 */
export interface DatabaseTaskParams {
  type: DatabaseTaskType;
  // 查询分页参数
  page?: number;
  size?: number;
  // 插入/更新参数
  values?: relationalStore.ValuesBucket;
  valuesList?: Array<relationalStore.ValuesBucket>;
  // 更新/删除参数
  id?: number;
}

/**
 * 数据库任务结果
 */
export interface DatabaseTaskResult {
  success: boolean;
  data?: ProcessingHistoryData[] | number;
  error?: string;
}

/**
 * 数据库任务类（继承 DispatchTask）
 * 注意：Context 不能序列化，所以不包含在任务数据中
 */
export class DatabaseTask extends DispatchTask {
  type: DatabaseTaskType;
  page?: number;
  size?: number;
  values?: relationalStore.ValuesBucket;
  valuesList?: Array<relationalStore.ValuesBucket>;
  id?: number;

  constructor(params: DatabaseTaskParams) {
    super({ type: params.type });
    this.type = params.type;
    this.page = params.page;
    this.size = params.size;
    this.values = params.values;
    this.valuesList = params.valuesList;
    this.id = params.id;
  }
}

/**
 * 数据库操作 Dispatch 队列
 * 注意：数据库操作函数在 TaskPool 中执行（需要 @Concurrent 函数）
 * Context 通过 Map 存储映射，避免序列化问题
 */
export class DatabaseDispatchQueue extends DispatchQueue {
  // 存储 Context 的映射（key: task uniqueId, value: Context）
  private contextMap: Map<string, Context> = new Map();

  /**
   * 创建串行队列（用于写入操作：INSERT、UPDATE、DELETE）
   */
  static queue_create_serial(label: string): DatabaseDispatchQueue {
    return new DatabaseDispatchQueue(label, QueueType.SERIAL);
  }

  /**
   * 创建并发队列（用于查询操作：QUERY、COUNT）
   */
  static queue_create_concurrent(label: string): DatabaseDispatchQueue {
    return new DatabaseDispatchQueue(label, QueueType.CONCURRENT);
  }

  /**
   * 执行任务
   * 注意：数据库操作函数在 TaskPool 中执行（需要 @Concurrent 函数）
   */
  override runTask(taskData: DispatchTask): void {
    const dbTask = taskData as DatabaseTask;
    const taskId = dbTask.uniqueId;
    const ctx = this.contextMap.get(taskId);

    if (!ctx) {
      const errorResult: DatabaseTaskResult = {
        success: false,
        error: 'Context 未找到'
      };
      this.finishTask(taskData, errorResult as ESObject);
      return;
    }

    // 在 TaskPool 中执行数据库操作
    const executeDbOperation = async () => {
      try {
        let result: ProcessingHistoryData[] | number;
        
        switch (dbTask.type) {
          case DatabaseTaskType.QUERY_ALL:
            result = await this.executeQueryAll(ctx);
            break;
          case DatabaseTaskType.QUERY_PAGE:
            if (dbTask.page === undefined || dbTask.size === undefined) {
              throw new Error('查询分页参数缺失');
            }
            result = await this.executeQueryPage(ctx, dbTask.page, dbTask.size);
            break;
          case DatabaseTaskType.COUNT_ALL:
            result = await this.executeCountAll(ctx);
            break;
          case DatabaseTaskType.INSERT:
            if (!dbTask.values) {
              throw new Error('插入参数缺失');
            }
            result = await this.executeInsert(ctx, dbTask.values);
            break;
          case DatabaseTaskType.BATCH_INSERT:
            if (!dbTask.valuesList) {
              throw new Error('批量插入参数缺失');
            }
            result = await this.executeBatchInsert(ctx, dbTask.valuesList);
            break;
          case DatabaseTaskType.UPDATE:
            if (dbTask.id === undefined || !dbTask.values) {
              throw new Error('更新参数缺失');
            }
            result = await this.executeUpdate(ctx, dbTask.id, dbTask.values);
            break;
          case DatabaseTaskType.DELETE:
            if (dbTask.id === undefined) {
              throw new Error('删除参数缺失');
            }
            result = await this.executeDelete(ctx, dbTask.id);
            break;
          default:
            throw new Error(`未知的数据库操作类型: ${dbTask.type}`);
        }

        const taskResult: DatabaseTaskResult = {
          success: true,
          data: result
        };
        this.finishTask(taskData, taskResult as ESObject);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        hilog.error(DOMAIN, 'DatabaseDispatchQueue', `数据库操作失败: ${errorMsg}`);
        const errorResult: DatabaseTaskResult = {
          success: false,
          error: errorMsg
        };
        this.finishTask(taskData, errorResult as ESObject);
      } finally {
        // 清理映射
        this.contextMap.delete(taskId);
      }
    };

    // 异步执行，不阻塞队列调度
    executeDbOperation();
  }

  /**
   * 设置任务的 Context（在添加任务前调用）
   */
  setTaskContext(taskId: string, ctx: Context): void {
    this.contextMap.set(taskId, ctx);
  }

  // 以下是数据库操作函数，需要在 TaskPool 中执行
  // 这些函数需要导入 ProcessingApiHandler 中的 @Concurrent 函数
  // 或者在这里重新定义 @Concurrent 函数

  private async executeQueryAll(ctx: Context): Promise<ProcessingHistoryData[]> {
    // 导入 ProcessingApiHandler 中的 PH_QueryAll 函数
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_QueryAll, ctx);
    const result = await taskpool.execute(task);
    return result as ProcessingHistoryData[];
  }

  private async executeQueryPage(ctx: Context, page: number, size: number): Promise<ProcessingHistoryData[]> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_QueryPage, ctx, page, size);
    const result = await taskpool.execute(task);
    return result as ProcessingHistoryData[];
  }

  private async executeCountAll(ctx: Context): Promise<number> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_CountAll, ctx);
    const result = await taskpool.execute(task);
    return result as number;
  }

  private async executeInsert(ctx: Context, values: relationalStore.ValuesBucket): Promise<number> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_Insert, ctx, values);
    const result = await taskpool.execute(task);
    return result as number;
  }

  private async executeBatchInsert(ctx: Context, valuesList: Array<relationalStore.ValuesBucket>): Promise<number> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_BatchInsert, ctx, valuesList);
    const result = await taskpool.execute(task);
    return result as number;
  }

  private async executeUpdate(ctx: Context, id: number, values: relationalStore.ValuesBucket): Promise<number> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_Update, ctx, id, values);
    const result = await taskpool.execute(task);
    return result as number;
  }

  private async executeDelete(ctx: Context, id: number): Promise<number> {
    const ProcessingApiHandler = await import('../handlers/ProcessingApiHandler');
    const task = new taskpool.Task(ProcessingApiHandler.PH_Delete, ctx, id);
    const result = await taskpool.execute(task);
    return result as number;
  }
}

