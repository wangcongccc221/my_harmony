import { Context } from '@kit.AbilityKit';
import { FruitInfo } from '../models/FruitInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 水果信息CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class FruitInfoService {
  /**
   * Create - 创建记录
   */
  static create(fruitInfo: FruitInfo): FruitInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 直接插入实体对象，ORM会自动转换
    const id = orm.Session(FruitInfo).Insert(fruitInfo) as number;    
    // 查询刚插入的记录
    const result = orm.Session(FruitInfo).Where('customer_i_d', id).Find(FruitInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as FruitInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): FruitInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(FruitInfo).Where('customer_i_d', id).Find(FruitInfo);
    return results.length > 0 ? (results[0] as FruitInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): FruitInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitInfo).Find(FruitInfo) as FruitInfo[];
  }

  /**
   * Update - 更新记录（返回更新后的对象）
   */
  static update(id: number, fruitInfo: Partial<FruitInfo>): FruitInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 转换为ValuesBucket
    const values: relationalStore.ValuesBucket = {};
    if (fruitInfo.SysID !== undefined) values['sys_i_d'] = fruitInfo.SysID;
    if (fruitInfo.FeedPortID !== undefined) values['feed_port_i_d'] = fruitInfo.FeedPortID;
    if (fruitInfo.MajorCustomerID !== undefined) values['major_customer_i_d'] = fruitInfo.MajorCustomerID;
    if (fruitInfo.FBatchNo !== undefined) values['f_batch_no'] = fruitInfo.FBatchNo;
    if (fruitInfo.OrderID !== undefined) values['order_i_d'] = fruitInfo.OrderID;
    if (fruitInfo.ChainIdx !== undefined) values['chain_idx'] = fruitInfo.ChainIdx;
    if (fruitInfo.CustomerName !== undefined) values['customer_name'] = fruitInfo.CustomerName;
    if (fruitInfo.FarmName !== undefined) values['farm_name'] = fruitInfo.FarmName;
    if (fruitInfo.FruitName !== undefined) values['fruit_name'] = fruitInfo.FruitName;
    if (fruitInfo.StartTime !== undefined) values['start_time'] = fruitInfo.StartTime;
    if (fruitInfo.EndTime !== undefined) values['end_time'] = fruitInfo.EndTime;
    if (fruitInfo.StartedState !== undefined) values['started_state'] = fruitInfo.StartedState;
    if (fruitInfo.CompletedState !== undefined) values['completed_state'] = fruitInfo.CompletedState;
    if (fruitInfo.BatchWeight !== undefined) values['batch_weight'] = fruitInfo.BatchWeight;
    if (fruitInfo.BatchNumber !== undefined) values['batch_number'] = fruitInfo.BatchNumber;
    if (fruitInfo.SortType !== undefined) values['sort_type'] = fruitInfo.SortType;
    if (fruitInfo.SystemNum !== undefined) values['system_num'] = fruitInfo.SystemNum;
    if (fruitInfo.SizeIDNum !== undefined) values['size_i_d_num'] = fruitInfo.SizeIDNum;
    if (fruitInfo.ChannelNum !== undefined) values['channel_num'] = fruitInfo.ChannelNum;
    if (fruitInfo.QualityGradeSum !== undefined) values['quality_grade_sum'] = fruitInfo.QualityGradeSum;
    if (fruitInfo.WeightOrSizeGradeSum !== undefined) values['weight_or_size_grade_sum'] = fruitInfo.WeightOrSizeGradeSum;
    if (fruitInfo.ColorGradeName !== undefined) values['color_grade_name'] = fruitInfo.ColorGradeName;
    if (fruitInfo.ShapeGradeName !== undefined) values['shape_grade_name'] = fruitInfo.ShapeGradeName;
    if (fruitInfo.FlawGradeName !== undefined) values['flaw_grade_name'] = fruitInfo.FlawGradeName;
    if (fruitInfo.HardGradeName !== undefined) values['hard_grade_name'] = fruitInfo.HardGradeName;
    if (fruitInfo.DensityGradeName !== undefined) values['density_grade_name'] = fruitInfo.DensityGradeName;
    if (fruitInfo.SugarDegreeGradeName !== undefined) values['sugar_degree_grade_name'] = fruitInfo.SugarDegreeGradeName;
    if (fruitInfo.ExportSum !== undefined) values['export_sum'] = fruitInfo.ExportSum;
    if (fruitInfo.ProgramName !== undefined) values['program_name'] = fruitInfo.ProgramName;

    orm.Session(FruitInfo).Where('customer_i_d', id).Update(values);
    const updated = FruitInfoService.findById(id);
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

    orm.Session(FruitInfo).Where('customer_i_d', id).Delete();
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: FruitInfo, ctx?: Context): Promise<number> {
    const result = FruitInfoService.create(data);
    return result.CustomerID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<FruitInfo[]> {
    return FruitInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<FruitInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(FruitInfo).Limit(size).Offset(offset).Find(FruitInfo) as FruitInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(FruitInfo).Find();
    return results.length;
  }

  static async batchSave(list: FruitInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(FruitInfo).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, fruitInfo: Partial<FruitInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (fruitInfo.SysID !== undefined) values['sys_i_d'] = fruitInfo.SysID;
    if (fruitInfo.FeedPortID !== undefined) values['feed_port_i_d'] = fruitInfo.FeedPortID;
    if (fruitInfo.MajorCustomerID !== undefined) values['major_customer_i_d'] = fruitInfo.MajorCustomerID;
    if (fruitInfo.FBatchNo !== undefined) values['f_batch_no'] = fruitInfo.FBatchNo;
    if (fruitInfo.OrderID !== undefined) values['order_i_d'] = fruitInfo.OrderID;
    if (fruitInfo.ChainIdx !== undefined) values['chain_idx'] = fruitInfo.ChainIdx;
    if (fruitInfo.CustomerName !== undefined) values['customer_name'] = fruitInfo.CustomerName;
    if (fruitInfo.FarmName !== undefined) values['farm_name'] = fruitInfo.FarmName;
    if (fruitInfo.FruitName !== undefined) values['fruit_name'] = fruitInfo.FruitName;
    if (fruitInfo.StartTime !== undefined) values['start_time'] = fruitInfo.StartTime;
    if (fruitInfo.EndTime !== undefined) values['end_time'] = fruitInfo.EndTime;
    if (fruitInfo.StartedState !== undefined) values['started_state'] = fruitInfo.StartedState;
    if (fruitInfo.CompletedState !== undefined) values['completed_state'] = fruitInfo.CompletedState;
    if (fruitInfo.BatchWeight !== undefined) values['batch_weight'] = fruitInfo.BatchWeight;
    if (fruitInfo.BatchNumber !== undefined) values['batch_number'] = fruitInfo.BatchNumber;
    if (fruitInfo.SortType !== undefined) values['sort_type'] = fruitInfo.SortType;
    if (fruitInfo.SystemNum !== undefined) values['system_num'] = fruitInfo.SystemNum;
    if (fruitInfo.SizeIDNum !== undefined) values['size_i_d_num'] = fruitInfo.SizeIDNum;
    if (fruitInfo.ChannelNum !== undefined) values['channel_num'] = fruitInfo.ChannelNum;
    if (fruitInfo.QualityGradeSum !== undefined) values['quality_grade_sum'] = fruitInfo.QualityGradeSum;
    if (fruitInfo.WeightOrSizeGradeSum !== undefined) values['weight_or_size_grade_sum'] = fruitInfo.WeightOrSizeGradeSum;
    if (fruitInfo.ColorGradeName !== undefined) values['color_grade_name'] = fruitInfo.ColorGradeName;
    if (fruitInfo.ShapeGradeName !== undefined) values['shape_grade_name'] = fruitInfo.ShapeGradeName;
    if (fruitInfo.FlawGradeName !== undefined) values['flaw_grade_name'] = fruitInfo.FlawGradeName;
    if (fruitInfo.HardGradeName !== undefined) values['hard_grade_name'] = fruitInfo.HardGradeName;
    if (fruitInfo.DensityGradeName !== undefined) values['density_grade_name'] = fruitInfo.DensityGradeName;
    if (fruitInfo.SugarDegreeGradeName !== undefined) values['sugar_degree_grade_name'] = fruitInfo.SugarDegreeGradeName;
    if (fruitInfo.ExportSum !== undefined) values['export_sum'] = fruitInfo.ExportSum;
    if (fruitInfo.ProgramName !== undefined) values['program_name'] = fruitInfo.ProgramName;

    return orm.Session(FruitInfo).Where('customer_i_d', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FruitInfo).Where('customer_i_d', id).Delete() as number;
  }
}
