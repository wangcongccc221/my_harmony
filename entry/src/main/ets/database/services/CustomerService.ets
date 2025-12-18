import { Context } from '@kit.AbilityKit';
import { Customer } from '../models/Customer';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 客户信息CRUD接口
 * 对应48项目：DataBaseOperation中的Customer相关方法
 * 使用ORM同步方法，直接内部调用
 */
export class CustomerService {
  /**
   * Create - 创建记录
   */
  static create(customer: Customer): Customer {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    // 设置创建时间
    if (!customer.FCreateDate) {
      const now = new Date();
      customer.FCreateDate = now.toISOString().replace('T', ' ').substring(0, 19);
    }

    const id = orm.Session(Customer).Insert(customer) as number;
    const result = orm.Session(Customer).Where('fid', id).Find(Customer);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as Customer;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): Customer | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(Customer).Where('fid', id).Find(Customer);
    return results.length > 0 ? (results[0] as Customer) : null;
  }

  /**
   * Read - 根据FCode查询
   */
  static findByCode(code: string): Customer | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(Customer).Where('f_code', code).Find(Customer);
    return results.length > 0 ? (results[0] as Customer) : null;
  }

  /**
   * Read - 根据FName查询
   */
  static findByName(name: string): Customer | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(Customer).Where('f_name', name).Find(Customer);
    return results.length > 0 ? (results[0] as Customer) : null;
  }

  /**
   * Read - 查询所有（按创建时间排序）
   */
  static findAll(): Customer[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(Customer).OrderBy('f_create_date', 'ASC').Find(Customer) as Customer[];
  }

  /**
   * Read - 查询所有启用的客户（FIsUse = '1'）
   */
  static findActive(): Customer[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(Customer).Where('f_is_use', '1').OrderBy('f_create_date', 'ASC').Find(Customer) as Customer[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, customer: Partial<Customer>): Customer {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (customer.FName !== undefined) values['f_name'] = customer.FName;
    if (customer.FPassWord !== undefined) values['f_pass_word'] = customer.FPassWord;
    if (customer.FCode !== undefined) values['f_code'] = customer.FCode;
    if (customer.FIsUse !== undefined) values['f_is_use'] = customer.FIsUse;

    orm.Session(Customer).Where('fid', id).Update(values);
    const updated = CustomerService.findById(id);
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

    orm.Session(Customer).Where('fid', id).Delete();
  }

  // 兼容旧代码的方法（用于API Handler）
  static async save(data: Customer, ctx?: Context): Promise<number> {
    const result = CustomerService.create(data);
    return result.FID ?? 0;
  }

  static async queryAll(ctx?: Context): Promise<Customer[]> {
    return CustomerService.findAll();
  }

  static async queryPage(page: number, size: number, ctx?: Context): Promise<Customer[]> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const offset = (page - 1) * size;
    return orm.Session(Customer).Limit(size).Offset(offset).OrderBy('f_create_date', 'ASC').Find(Customer) as Customer[];
  }

  static async count(ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    const results = orm.Session(Customer).Find();
    return results.length;
  }

  static async batchSave(list: Customer[], ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }
    return orm.Session(Customer).Insert(list) as number;
  }

  // API Handler 需要的方法：返回受影响的行数
  static async updateReturnAffected(id: number, customer: Partial<Customer>, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (customer.FName !== undefined) values['f_name'] = customer.FName;
    if (customer.FPassWord !== undefined) values['f_pass_word'] = customer.FPassWord;
    if (customer.FCode !== undefined) values['f_code'] = customer.FCode;
    if (customer.FIsUse !== undefined) values['f_is_use'] = customer.FIsUse;

    return orm.Session(Customer).Where('fid', id).Update(values) as number;
  }

  static async deleteReturnAffected(id: number, ctx?: Context): Promise<number> {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(Customer).Where('fid', id).Delete() as number;
  }
}

