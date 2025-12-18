import { Context } from '@kit.AbilityKit';
import { BaseFault } from '../models/BaseFault';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 基础故障CRUD接口
 * 对应48项目：DataBaseOperation中的BaseFault相关方法
 * 用于存储故障模板/基础故障信息
 */
export class BaseFaultService {
  /**
   * Create - 创建记录
   */
  static create(baseFault: BaseFault): BaseFault {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 设置创建时间
    if (!baseFault.FCreateDate) {
      const now = new Date();
      baseFault.FCreateDate = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    const id = orm.Session(BaseFault).Insert(baseFault) as number;
    const result = orm.Session(BaseFault).Where('fid', id).Find(BaseFault);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as BaseFault;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): BaseFault | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(BaseFault).Where('fid', id).Find(BaseFault);
    return results.length > 0 ? (results[0] as BaseFault) : null;
  }

  /**
   * Read - 根据FType查询（0=硬件类, 1=电气类）
   */
  static findByType(fType: number): BaseFault[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(BaseFault).Where('f_type', fType).Find(BaseFault) as BaseFault[];
  }

  /**
   * Read - 根据FCode查询
   */
  static findByCode(code: string): BaseFault | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(BaseFault).Where('f_code', code).Find(BaseFault);
    return results.length > 0 ? (results[0] as BaseFault) : null;
  }

  /**
   * Read - 根据FGroupName查询
   */
  static findByGroupName(groupName: string): BaseFault[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(BaseFault).Where('f_group_name', groupName).Find(BaseFault) as BaseFault[];
  }

  /**
   * Read - 查询所有
   */
  static findAll(): BaseFault[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(BaseFault).Find(BaseFault) as BaseFault[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, baseFault: Partial<BaseFault>): BaseFault {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 设置修改时间
    const now = new Date();
    const modifyDate = now.toISOString().replace('T', ' ').substring(0, 19);

    const values: relationalStore.ValuesBucket = {};
    if (baseFault.FType !== undefined) values['f_type'] = baseFault.FType;
    if (baseFault.FCode !== undefined) values['f_code'] = baseFault.FCode;
    if (baseFault.FName !== undefined) values['f_name'] = baseFault.FName;
    if (baseFault.FGroupName !== undefined) values['f_group_name'] = baseFault.FGroupName;
    if (baseFault.FMessage !== undefined) values['f_message'] = baseFault.FMessage;
    if (baseFault.FShutdownCondition !== undefined) values['f_shutdown_condition'] = baseFault.FShutdownCondition;
    if (baseFault.FDecelerationCondition !== undefined) values['f_deceleration_condition'] = baseFault.FDecelerationCondition;
    if (baseFault.FPopupCondition !== undefined) values['f_popup_condition'] = baseFault.FPopupCondition;
    if (baseFault.FPromptCondition !== undefined) values['f_prompt_condition'] = baseFault.FPromptCondition;
    values['f_modify_date'] = modifyDate;

    orm.Session(BaseFault).Where('fid', id).Update(values);
    const updated = BaseFaultService.findById(id);
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

    orm.Session(BaseFault).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: BaseFault, ctx?: Context): Promise<number> {
    const result = BaseFaultService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<BaseFault[]> {
    return BaseFaultService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<BaseFault[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(BaseFault).Limit(size).Offset(offset).Find(BaseFault) as BaseFault[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(BaseFault).Find();
    return results.length;
  }

  static async batchSave(list: BaseFault[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(BaseFault).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, baseFault: Partial<BaseFault>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const now = new Date();
    const modifyDate = now.toISOString().replace('T', ' ').substring(0, 19);

    const values: relationalStore.ValuesBucket = {};
    if (baseFault.FType !== undefined) values['f_type'] = baseFault.FType;
    if (baseFault.FCode !== undefined) values['f_code'] = baseFault.FCode;
    if (baseFault.FName !== undefined) values['f_name'] = baseFault.FName;
    if (baseFault.FGroupName !== undefined) values['f_group_name'] = baseFault.FGroupName;
    if (baseFault.FMessage !== undefined) values['f_message'] = baseFault.FMessage;
    if (baseFault.FShutdownCondition !== undefined) values['f_shutdown_condition'] = baseFault.FShutdownCondition;
    if (baseFault.FDecelerationCondition !== undefined) values['f_deceleration_condition'] = baseFault.FDecelerationCondition;
    if (baseFault.FPopupCondition !== undefined) values['f_popup_condition'] = baseFault.FPopupCondition;
    if (baseFault.FPromptCondition !== undefined) values['f_prompt_condition'] = baseFault.FPromptCondition;
    values['f_modify_date'] = modifyDate;

    return orm.Session(BaseFault).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(BaseFault).Where('fid', id).Delete() as number;
  }
}

