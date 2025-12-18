import { ProcessingHistory } from '../models/ProcessingHistory';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 历史加工数据CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class ProcessingHistoryService {
  /**
   * Create - 创建记录
   */
  static create(history: ProcessingHistory): ProcessingHistory {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(ProcessingHistory).Insert(history) as number;
    const result = orm.Session(ProcessingHistory).Where('id', id).Find(ProcessingHistory);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as ProcessingHistory;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): ProcessingHistory | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(ProcessingHistory).Where('id', id).Find(ProcessingHistory);
    return results.length > 0 ? (results[0] as ProcessingHistory) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): ProcessingHistory[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(ProcessingHistory).Find(ProcessingHistory) as ProcessingHistory[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, history: Partial<ProcessingHistory>): ProcessingHistory {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (history.CustomerID !== undefined) values['customer_id'] = history.CustomerID;
    if (history.CustomerName !== undefined) values['customer_name'] = history.CustomerName;
    if (history.FarmName !== undefined) values['farm_name'] = history.FarmName;
    if (history.FruitName !== undefined) values['fruit_name'] = history.FruitName;
    if (history.Status !== undefined) values['status'] = history.Status;
    if (history.StartTime !== undefined) values['start_time'] = history.StartTime;
    if (history.EndTime !== undefined) values['end_time'] = history.EndTime;
    if (history.Weight !== undefined) values['weight'] = history.Weight;
    if (history.Quantity !== undefined) values['quantity'] = history.Quantity;
    if (history.BatchNo !== undefined) values['batch_no'] = history.BatchNo;
    if (history.OrderID !== undefined) values['order_id'] = history.OrderID;
    if (history.ProgramName !== undefined) values['program_name'] = history.ProgramName;
    if (history.ChannelNum !== undefined) values['channel_num'] = history.ChannelNum;
    if (history.ExportSum !== undefined) values['export_sum'] = history.ExportSum;
    if (history.QualityGradeSum !== undefined) values['quality_grade_sum'] = history.QualityGradeSum;
    if (history.WeightOrSizeGradeSum !== undefined) values['weight_or_size_grade_sum'] = history.WeightOrSizeGradeSum;
    if (history.CompletedState !== undefined) values['completed_state'] = history.CompletedState;

    orm.Session(ProcessingHistory).Where('id', id).Update(values);
    const updated = ProcessingHistoryService.findById(id);
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

    orm.Session(ProcessingHistory).Where('id', id).Delete();
  }
}
