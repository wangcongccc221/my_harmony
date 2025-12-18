import { Context } from '@kit.AbilityKit';
import { FaultInfo } from '../models/FaultInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 故障信息CRUD接口
 * 对应48项目：DataBaseOperation中的FaultInfo相关方法
 * 用于存储实际发生的故障记录
 */
export class FaultInfoService {
  /**
   * Create - 创建记录
   */
  static create(faultInfo: FaultInfo): FaultInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 设置开始时间
    if (!faultInfo.FBeginDate) {
      const now = new Date();
      faultInfo.FBeginDate = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    const id = orm.Session(FaultInfo).Insert(faultInfo) as number;
    const result = orm.Session(FaultInfo).Where('fid', id).Find(FaultInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as FaultInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): FaultInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(FaultInfo).Where('fid', id).Find(FaultInfo);
    return results.length > 0 ? (results[0] as FaultInfo) : null;
  }

  /**
   * Read - 根据FType查询（0=硬件类, 1=电气类）
   */
  static findByType(fType: number): FaultInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FaultInfo).Where('f_type', fType).Find(FaultInfo) as FaultInfo[];
  }

  /**
   * Read - 查询未完成的故障（FStatus = 0）
   */
  static findUnfinished(fType?: number): FaultInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    let query = orm.Session(FaultInfo).Where('f_status', 0);
    if (fType !== undefined) {
      query = query.Where('f_type', fType);
    }
    return query.Find(FaultInfo) as FaultInfo[];
  }

  /**
   * Read - 根据时间范围查询
   */
  static findByDateRange(beginDate: string, endDate: string, fMessage?: string): FaultInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const core = orm.GetCore();
    if (!core) {
      throw new Error('无法获取数据库核心对象');
    }

    let sql = `SELECT * FROM tb_faultinfo WHERE f_begin_date BETWEEN ? AND ?`;
    const params: relationalStore.ValueType[] = [beginDate, endDate];

    if (fMessage && fMessage.trim() !== '') {
      sql += ` AND f_message LIKE ?`;
      params.push(`%${fMessage}%`);
    }

    sql += ` ORDER BY f_begin_date DESC`;

    const rs = core.querySqlSync(sql, params);
    const results: FaultInfo[] = [];

    if (rs.columnCount > 0 && rs.goToFirstRow()) {
      do {
        const faultInfo = new FaultInfo();
        faultInfo.FID = rs.getLong(rs.getColumnIndex('fid')) as number;
        faultInfo.FType = rs.getLong(rs.getColumnIndex('f_type')) as number;
        faultInfo.FCode = rs.getString(rs.getColumnIndex('f_code')) as string;
        faultInfo.FName = rs.getString(rs.getColumnIndex('f_name')) as string;
        faultInfo.FMessage = rs.getString(rs.getColumnIndex('f_message')) as string;
        faultInfo.FStatus = rs.getLong(rs.getColumnIndex('f_status')) as number;
        faultInfo.FBeginDate = rs.getString(rs.getColumnIndex('f_begin_date')) as string;
        faultInfo.FEndDate = rs.getString(rs.getColumnIndex('f_end_date')) as string;
        results.push(faultInfo);
      } while (rs.goToNextRow());
    }

    rs.close();
    return results;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): FaultInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FaultInfo).OrderBy('f_begin_date', 'DESC').Find(FaultInfo) as FaultInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, faultInfo: Partial<FaultInfo>): FaultInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (faultInfo.FType !== undefined) values['f_type'] = faultInfo.FType;
    if (faultInfo.FCode !== undefined) values['f_code'] = faultInfo.FCode;
    if (faultInfo.FName !== undefined) values['f_name'] = faultInfo.FName;
    if (faultInfo.FMessage !== undefined) values['f_message'] = faultInfo.FMessage;
    if (faultInfo.FStatus !== undefined) values['f_status'] = faultInfo.FStatus;
    if (faultInfo.FBeginDate !== undefined) values['f_begin_date'] = faultInfo.FBeginDate;
    if (faultInfo.FEndDate !== undefined) values['f_end_date'] = faultInfo.FEndDate;

    // 如果状态变为已修复（1），设置结束时间
    if (faultInfo.FStatus === 1 && !faultInfo.FEndDate) {
      const now = new Date();
      values['f_end_date'] = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    orm.Session(FaultInfo).Where('fid', id).Update(values);
    const updated = FaultInfoService.findById(id);
    if (!updated) {
      throw new Error('更新后查询失败');
    }
    return updated;
  }

  /**
   * Update - 标记故障为已修复
   */
  static markAsFixed(id: number): FaultInfo {
    const now = new Date();
    const endDate = now.toISOString().replace('T', ' ').substring(0, 19);
    return FaultInfoService.update(id, { FStatus: 1, FEndDate: endDate });
  }

  /**
   * Delete - 删除记录
   */
  static delete(id: number): void {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    orm.Session(FaultInfo).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: FaultInfo, ctx?: Context): Promise<number> {
    const result = FaultInfoService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<FaultInfo[]> {
    return FaultInfoService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<FaultInfo[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(FaultInfo).Limit(size).Offset(offset).OrderBy('f_begin_date', 'DESC').Find(FaultInfo) as FaultInfo[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(FaultInfo).Find();
    return results.length;
  }

  static async batchSave(list: FaultInfo[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(FaultInfo).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, faultInfo: Partial<FaultInfo>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (faultInfo.FType !== undefined) values['f_type'] = faultInfo.FType;
    if (faultInfo.FCode !== undefined) values['f_code'] = faultInfo.FCode;
    if (faultInfo.FName !== undefined) values['f_name'] = faultInfo.FName;
    if (faultInfo.FMessage !== undefined) values['f_message'] = faultInfo.FMessage;
    if (faultInfo.FStatus !== undefined) values['f_status'] = faultInfo.FStatus;
    if (faultInfo.FBeginDate !== undefined) values['f_begin_date'] = faultInfo.FBeginDate;
    if (faultInfo.FEndDate !== undefined) values['f_end_date'] = faultInfo.FEndDate;

    if (faultInfo.FStatus === 1 && !faultInfo.FEndDate) {
      const now = new Date();
      values['f_end_date'] = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    return orm.Session(FaultInfo).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(FaultInfo).Where('fid', id).Delete() as number;
  }
}

