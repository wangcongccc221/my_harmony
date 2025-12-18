import { ProcessingTask } from '../models/ProcessingTask';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 加工任务CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class ProcessingTaskService {
  /**
   * Create - 创建记录
   */
  static create(task: ProcessingTask): ProcessingTask {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(ProcessingTask).Insert(task) as number;
    const result = orm.Session(ProcessingTask).Where('task_id', id).Find(ProcessingTask);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as ProcessingTask;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): ProcessingTask | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(ProcessingTask).Where('task_id', id).Find(ProcessingTask);
    return results.length > 0 ? (results[0] as ProcessingTask) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): ProcessingTask[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(ProcessingTask).Find(ProcessingTask) as ProcessingTask[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, task: Partial<ProcessingTask>): ProcessingTask {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (task.FarmerID !== undefined) values['farmer_id'] = task.FarmerID;
    if (task.CustomerName !== undefined) values['customer_name'] = task.CustomerName;
    if (task.FruitName !== undefined) values['fruit_name'] = task.FruitName;
    if (task.TotalWeight !== undefined) values['total_weight'] = task.TotalWeight;
    if (task.Status !== undefined) values['status'] = task.Status;
    if (task.BoundOrderID !== undefined) values['bound_order_id'] = task.BoundOrderID;
    if (task.CreatedAt !== undefined) values['created_at'] = task.CreatedAt;

    orm.Session(ProcessingTask).Where('task_id', id).Update(values);
    const updated = ProcessingTaskService.findById(id);
    if (!updated) {
      throw new Error('更新后查询失败');
    }
    return updated;
  }

  /**
   * Delete - 删除记录
   */
  static delete(id: number): void {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    orm.Session(ProcessingTask).Where('task_id', id).Delete();
  }
}
