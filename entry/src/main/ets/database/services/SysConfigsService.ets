import { Context } from '@kit.AbilityKit';
import { SysConfigs } from '../models/SysConfigs';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 系统配置CRUD接口
 * 对应48项目：DataBaseOperation中的SysConfigs相关方法
 * 用于存储系统配置参数（键值对形式）
 * 这是48项目中非常重要的表，用于存储各种系统配置参数
 */
export class SysConfigsService {
  /**
   * Create - 创建记录
   */
  static create(sysConfigs: SysConfigs): SysConfigs {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 设置创建时间
    if (!sysConfigs.FCreateDate) {
      const now = new Date();
      sysConfigs.FCreateDate = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    // 设置默认模块名称
    if (!sysConfigs.FModuleName) {
      sysConfigs.FModuleName = 'RSS';
    }

    const id = orm.Session(SysConfigs).Insert(sysConfigs) as number;
    const result = orm.Session(SysConfigs).Where('fid', id).Find(SysConfigs);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as SysConfigs;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): SysConfigs | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(SysConfigs).Where('fid', id).Find(SysConfigs);
    return results.length > 0 ? (results[0] as SysConfigs) : null;
  }

  /**
   * Read - 根据FModuleName和FType查询配置值
   * 对应48项目：GetConfigValue方法
   */
  static getConfigValue(moduleName: string, fType: string): string {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(SysConfigs)
      .Where('f_module_name', moduleName)
      .Where('f_type', fType)
      .Find(SysConfigs);
    
    if (results.length > 0) {
      return (results[0] as SysConfigs).FValue || '';
    }
    return '';
  }

  /**
   * Read - 根据FType查询（支持模糊查询）
   * 对应48项目：GetDataTable_tb_Sys_Config方法
   */
  static findByType(fType?: string, fVisible?: number): SysConfigs[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const core = orm.GetCore();
    if (!core) {
      throw new Error('无法获取数据库核心对象');
    }

    let sql = 'SELECT * FROM tb_sys_configs WHERE 1=1';
    const params: relationalStore.ValueType[] = [];

    if (fVisible !== undefined) {
      sql += ' AND f_visible = ?';
      params.push(fVisible);
    } else {
      // 默认只查询可见的配置
      sql += ' AND f_visible = ?';
      params.push(1);
    }

    if (fType && fType.trim() !== '') {
      sql += ' AND f_type LIKE ?';
      params.push(`%${fType}%`);
    }

    sql += ' ORDER BY f_module_name, f_type';

    const rs = core.querySqlSync(sql, params);
    const results: SysConfigs[] = [];

    if (rs.columnCount > 0 && rs.goToFirstRow()) {
      do {
        const config = new SysConfigs();
        config.FID = rs.getLong(rs.getColumnIndex('fid')) as number;
        config.FModuleName = rs.getString(rs.getColumnIndex('f_module_name')) as string;
        config.FType = rs.getString(rs.getColumnIndex('f_type')) as string;
        config.FValue = rs.getString(rs.getColumnIndex('f_value')) as string;
        config.FCreateDate = rs.getString(rs.getColumnIndex('f_create_date')) as string;
        config.FModifyDate = rs.getString(rs.getColumnIndex('f_modify_date')) as string;
        config.FVisible = rs.getLong(rs.getColumnIndex('f_visible')) as number;
        results.push(config);
      } while (rs.goToNextRow());
    }

    rs.close();
    return results;
  }

  /**
   * Read - 根据FModuleName查询
   */
  static findByModuleName(moduleName: string): SysConfigs[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysConfigs)
      .Where('f_module_name', moduleName)
      .Find(SysConfigs) as SysConfigs[];
  }

  /**
   * Read - 查询所有
   */
  static findAll(): SysConfigs[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysConfigs).Find(SysConfigs) as SysConfigs[];
  }

  /**
   * Update - 更新记录（如果不存在则创建）
   * 对应48项目：SaveConfigValue方法
   */
  static saveConfigValue(moduleName: string, fType: string, fValue: string): SysConfigs {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 先查询是否存在
    const existing = orm.Session(SysConfigs)
      .Where('f_module_name', moduleName)
      .Where('f_type', fType)
      .Find(SysConfigs);

    const now = new Date();
    const currentDate = now.toISOString().replace('T', ' ').substring(0, 19);

    if (existing.length > 0) {
      // 更新
      const values: relationalStore.ValuesBucket = {
        'f_value': fValue,
        'f_modify_date': currentDate
      };
      orm.Session(SysConfigs)
        .Where('f_module_name', moduleName)
        .Where('f_type', fType)
        .Update(values);
      
      const updated = orm.Session(SysConfigs)
        .Where('f_module_name', moduleName)
        .Where('f_type', fType)
        .Find(SysConfigs);
      
      if (updated.length > 0) {
        return updated[0] as SysConfigs;
      }
      throw new Error('更新后查询失败');
    } else {
      // 创建
      const newConfig = new SysConfigs({
        FModuleName: moduleName,
        FType: fType,
        FValue: fValue,
        FCreateDate: currentDate,
        FVisible: 1
      });
      return SysConfigsService.create(newConfig);
    }
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, sysConfigs: Partial<SysConfigs>): SysConfigs {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const now = new Date();
    const modifyDate = now.toISOString().replace('T', ' ').substring(0, 19);

    const values: relationalStore.ValuesBucket = {};
    if (sysConfigs.FModuleName !== undefined) values['f_module_name'] = sysConfigs.FModuleName;
    if (sysConfigs.FType !== undefined) values['f_type'] = sysConfigs.FType;
    if (sysConfigs.FValue !== undefined) values['f_value'] = sysConfigs.FValue;
    if (sysConfigs.FVisible !== undefined) values['f_visible'] = sysConfigs.FVisible;
    values['f_modify_date'] = modifyDate;

    orm.Session(SysConfigs).Where('fid', id).Update(values);
    const updated = SysConfigsService.findById(id);
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

    orm.Session(SysConfigs).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: SysConfigs, ctx?: Context): Promise<number> {
    const result = SysConfigsService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<SysConfigs[]> {
    return SysConfigsService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<SysConfigs[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(SysConfigs).Limit(size).Offset(offset).Find(SysConfigs) as SysConfigs[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(SysConfigs).Find();
    return results.length;
  }

  static async batchSave(list: SysConfigs[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(SysConfigs).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, sysConfigs: Partial<SysConfigs>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const now = new Date();
    const modifyDate = now.toISOString().replace('T', ' ').substring(0, 19);

    const values: relationalStore.ValuesBucket = {};
    if (sysConfigs.FModuleName !== undefined) values['f_module_name'] = sysConfigs.FModuleName;
    if (sysConfigs.FType !== undefined) values['f_type'] = sysConfigs.FType;
    if (sysConfigs.FValue !== undefined) values['f_value'] = sysConfigs.FValue;
    if (sysConfigs.FVisible !== undefined) values['f_visible'] = sysConfigs.FVisible;
    values['f_modify_date'] = modifyDate;

    return orm.Session(SysConfigs).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(SysConfigs).Where('fid', id).Delete() as number;
  }
}

