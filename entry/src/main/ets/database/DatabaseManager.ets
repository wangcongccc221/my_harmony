// IBest-ORM 主入口，用于获取 ORM 实例并进行表迁移/CRUD
import { GetIBestORM } from '@ibestservices/ibest-orm';
import { relationalStore } from '@kit.ArkData';
// 数据模型（对应各张表）
import { User } from './models/User'; //导入用户模型
import { TestModel } from './models/TestModel'; //导入测试模型
import { ProcessingHistory } from './models/ProcessingHistory'; //导入历史加工模型
import { UserData, TestData, ProcessingHistoryData, CreateUserParams, CreateTestRecordParams, CreateProcessingHistoryParams } from './types';
// 表名映射（统一管理各表的实际名称）
import { TABLE_NAMES } from './utils/TableNameMapper';
// 数据转换工具（实体 <-> 值桶/查询结果）
import { processingHistoryToValueBucket, convertToProcessingHistoryData, testModelToValueBucket } from './utils/DataConverter';
import { setValueIfNotEmpty } from './utils/ValueBucketHelper';

/**
 * 数据库管理类
 * 封装所有数据库操作，提供统一的接口
 * 支持 User、TestModel 和 ProcessingHistory 数据模型
 */
export class DatabaseManager {
  // 单例实例，确保全局只存在一个数据库管理器
  private static instance: DatabaseManager | null = null;
  // ORM 实例（线程安全由底层保证）
  private db = GetIBestORM(); //初始化方式：在EntryAbility.ets中调用IBestORMInit()初始化  

  private constructor() {
    // 私有构造函数，实现单例模式
  }

  // 获取单例（首次调用时初始化）
  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  /**
   * 初始化数据库（自动建表/迁移）
   * 注意：应在应用启动阶段调用一次
   */
  public async initDatabase(): Promise<void> {
    try {
      // 根据模型自动迁移表结构（不存在则创建，存在则对齐） 可复用执行语句
      this.db.AutoMigrate(User);
      this.db.AutoMigrate(TestModel);
      this.db.AutoMigrate(ProcessingHistory);
      
      // 等待一小段时间确保迁移完成
      await new Promise<void>((resolve: () => void) => {
        setTimeout(() => {
          resolve();
        }, 100);
      });
      
      console.info('✅ 数据库表结构初始化成功（User, TestModel, ProcessingHistory）');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 数据库初始化失败:', errorMsg);
      throw new Error(`数据库初始化失败: ${errorMsg}`);
    }
  }

  //User 相关操作 封装

  /**
   * 新增用户（传入实体）
   * 优先使用 ORM 的 Create；失败则回退到 Insert（配合值桶）
   */
  public createUser(user: User): User {
    try {
      // 根据文档，优先使用 Create 方法（推荐方式）
      try {
        this.db.Create(user);
        console.info(`✅ 使用 Create 方法创建用户成功: ${user.Name}`);
      } catch (createError) {
        // 如果 Create 失败，尝试使用 Insert 方法，字段名使用 PascalCase
        // 使用辅助函数处理空字符串：空字符串字段不设置，让数据库使用默认值或 NULL
        console.warn('⚠️ Create 方法失败，尝试使用 Insert 方法:', createError);
        const valueBucket: relationalStore.ValuesBucket = {};
        setValueIfNotEmpty(valueBucket, 'Name', user.Name);
        if (user.Age !== undefined) valueBucket.Age = user.Age;
        this.db.Table(TABLE_NAMES.User).Insert(valueBucket);
        console.info(`✅ 使用 Insert 方法创建用户成功: ${user.Name}`);
      }
      return user;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 创建用户失败:', errorMsg);
      throw new Error(`创建用户失败: ${errorMsg}`);
    }
  }

  /**
   * 查询所有用户（返回数据接口 UserData）
   */
  public getAllUsers(): UserData[] {
    try {
      // 使用 Table 方法查询，根据文档应该使用表名字符串
      const rawResult = this.db.Table(TABLE_NAMES.User).Find();
      console.info(`📋 查询到 ${rawResult.length} 条用户数据（原始结果）`);
      
      // 调试：打印第一条记录的原始结构
      if (rawResult.length > 0) {
        console.info('📋 第一条用户记录的原始数据:', JSON.stringify(rawResult[0]));
        console.info('📋 第一条用户记录的键:', Object.keys(rawResult[0]));
      }
      
      // 使用 Record<string, ESObject> 类型来处理可能的不同字段名格式
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      
      // 转换字段名（适配不同的字段名格式）
      const converted = result.map((item: QueryResult) => {
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        const userData: UserData = {
          id: (getValue('id') as number) || undefined,
          Name: (getValue('Name') as string) || 
               (getValue('name') as string) || 
               (getValue('name') as string) || undefined,
          Age: (getValue('Age') as number) || 
              (getValue('age') as number) || undefined,
          created_at: getValue('created_at') as string,
          updated_at: getValue('updated_at') as string
        };
        return userData;
      });
      
      console.info(`📋 转换后的用户数据数量: ${converted.length}`);
      return converted;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询用户失败:', errorMsg);
      throw new Error(`查询用户失败: ${errorMsg}`);
    }
  }

  /**
   * 根据年龄查询用户
   * @param age 年龄
   * @returns 用户数组
   */
  public getUsersByAge(age: number): UserData[] {
    try {
      // 根据文档，字段名在数据库中是小写的
      const rawResult = this.db.Table(TABLE_NAMES.User).Where('age', age).Find();
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      
      // 转换字段名
      const converted = result.map((item: QueryResult) => {
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        const userData: UserData = {
          id: (getValue('id') as number) || undefined,
          Name: (getValue('name') as string) || undefined,
          Age: (getValue('age') as number) || undefined,
          created_at: getValue('created_at') as string,
          updated_at: getValue('updated_at') as string
        };
        return userData;
      });
      
      console.info(`📋 查询到 ${converted.length} 条年龄为 ${age} 的用户数据`);
      return converted;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询用户失败:', errorMsg);
      throw new Error(`查询用户失败: ${errorMsg}`);
    }
  }

  /**
   * 根据ID查询用户
   * @param id 用户ID
   * @returns 用户对象或null
   */
  public getUserById(id: number): UserData | null {
    try {
      const rawResult = this.db.Table(TABLE_NAMES.User).Where('id', id).Find();
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      if (result && result.length > 0) {
        const item = result[0];
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        const userData: UserData = {
          id: (getValue('id') as number) || undefined,
          Name: (getValue('name') as string) || undefined,
          Age: (getValue('age') as number) || undefined,
          created_at: getValue('created_at') as string,
          updated_at: getValue('updated_at') as string
        };
        return userData;
      }
      return null;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询用户失败:', errorMsg);
      throw new Error(`查询用户失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 删除用户
   */
  public deleteUser(id: number): void {
    try {
      this.db.Table(TABLE_NAMES.User).Where('id', id).Delete();
      console.info(`✅ 删除用户成功: ID=${id}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 删除用户失败:', errorMsg);
      throw new Error(`删除用户失败: ${errorMsg}`);
    }
  }

  // TestModel 相关操作 封装

  /**
   * 新增测试记录（传入实体）
   * 使用封装的转换函数生成 ValuesBucket，避免手写字段映射
   */
  public createTestRecord(testRecord: TestModel): TestModel {
    try {
      const valueBucket: relationalStore.ValuesBucket = testModelToValueBucket(testRecord);
      this.db.Table(TABLE_NAMES.TestModel).Insert(valueBucket);
      console.info(`✅ 使用 Insert 方法创建测试记录成功: ${testRecord.Title}`);
      return testRecord;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 创建测试记录失败:', errorMsg);
      throw new Error(`创建测试记录失败: ${errorMsg}`);
    }
  }

  /**
   * 便捷新增：一行创建用户
   * 封装使用：dbManager.addUser('张三', 25)  用户表
   */
  public addUser(name: string, age: number): User {
    const user = new User(name, age);
    return this.createUser(user);
  }

  /**
   * 便捷新增：一行创建测试记录
   * @example dbManager.addTestRecord('标题', '描述', 10, 1)
   */
  public addTestRecord(title: string, description?: string, count?: number, isEnabled?: number): TestModel {
    const test = new TestModel(title, description, count, isEnabled);
    return this.createTestRecord(test);
  }

   /**
    * 支持直接将已定义好的 ProcessingHistory 实例插入数据库。
    * 你可以先构造好 ProcessingHistory 对象，然后直接调用 insert 方法插入：
    * @example
    * // 方式1：用参数快速新增
    * dbManager.addProcessingHistory(
    *   '客户A',
    *   '农场B',
    *   '苹果',
    *   '已完成',
    *   '2025-11-08 11:40',
    *   '2025-11-11 11:40',
    *   123.5,
    *   100
    * );
    *
    * // 方式2：先定义对象，再传参插入
    * const history = new ProcessingHistory(
    *   '客户A',
    *   '农场B',
    *   '苹果',
    *   '已完成',
    *   '2025-11-08 11:40',
    *   '2025-11-11 11:40',
    *   123.5,
    *   100
    * );
    * dbManager.createProcessingHistory(history);
    *
    * // 注意：createProcessingHistory(history) 支持传入已定义好的对象，直接插入数据库。
    */
  public addProcessingHistory(
    customerName: string,
    farmName: string,
    fruitName: string,
    status: string,
    startTime: string,
    endTime: string | undefined,
    weight: number,
    quantity: number
  ): ProcessingHistory {
    const history = new ProcessingHistory(
      customerName,
      farmName,
      fruitName,
      status,
      startTime,
      endTime,
      weight,
      quantity
    );
    return this.createProcessingHistory(history);
  }

  /**
   * 查询所有测试记录
   */
  public getAllTestRecords(): TestData[] {
    try {
      const rawResult = this.db.Table(TABLE_NAMES.TestModel).Find();
      console.info(`📋 查询到 ${rawResult.length} 条测试记录数据（原始结果）`);
      
      // 调试：打印第一条记录的原始结构
      if (rawResult.length > 0) {
        console.info('📋 第一条测试记录的原始数据:', JSON.stringify(rawResult[0]));
        console.info('📋 第一条测试记录的键:', Object.keys(rawResult[0]));
      }
      
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      
      const converted = result.map((item: QueryResult) => {
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        const testData: TestData = {
          id: (getValue('id') as number) || undefined,
          Title: (getValue('Title') as string) || 
                (getValue('title') as string) || undefined,
          Description: (getValue('Description') as string) || 
                      (getValue('description') as string) || undefined,
          Count: (getValue('Count') as number) || 
                (getValue('count') as number) || undefined,
          IsEnabled: (getValue('IsEnabled') as number) || 
                    (getValue('isEnabled') as number) || 
                    (getValue('is_enabled') as number) || undefined,
          created_at: getValue('created_at') as string,
          updated_at: getValue('updated_at') as string
        };
        return testData;
      });
      
      console.info(`📋 转换后的测试记录数量: ${converted.length}`);
      return converted;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询测试记录失败:', errorMsg);
      throw new Error(`查询测试记录失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 查询测试记录
   */
  public getTestRecordById(id: number): TestData | null {
    try {
      const rawResult = this.db.Table(TABLE_NAMES.TestModel).Where('id', id).Find();
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      if (result && result.length > 0) {
        const item = result[0];
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        const testData: TestData = {
          id: (getValue('id') as number) || undefined,
          Title: (getValue('title') as string) || undefined,
          Description: (getValue('description') as string) || undefined,
          Count: (getValue('count') as number) || undefined,
          IsEnabled: (getValue('is_enabled') as number) || undefined,
          created_at: getValue('created_at') as string,
          updated_at: getValue('updated_at') as string
        };
        return testData;
      }
      return null;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询测试记录失败:', errorMsg);
      throw new Error(`查询测试记录失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 删除测试记录
   */
  public deleteTestRecord(id: number): void {
    try {
      this.db.Table(TABLE_NAMES.TestModel).Where('id', id).Delete();
      console.info(`✅ 删除测试记录成功: ID=${id}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 删除测试记录失败:', errorMsg);
      throw new Error(`删除测试记录失败: ${errorMsg}`);
    }
  }


  /**
   * 新增历史加工记录（传入实体）
   */
  public createProcessingHistory(historyRecord: ProcessingHistory): ProcessingHistory {
    try {
      // 使用封装的函数将实体对象转换为 ValuesBucket
      const valueBucket = processingHistoryToValueBucket(historyRecord);
      
      this.db.Table(TABLE_NAMES.ProcessingHistory).Insert(valueBucket);
      console.info(`✅ 创建历史加工记录成功: ${historyRecord.CustomerName} - ${historyRecord.FruitName}`);
      return historyRecord;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 创建历史加工记录失败:', errorMsg);
      throw new Error(`创建历史加工记录失败: ${errorMsg}`);
    }
  }

  /**
   * 查询所有历史加工记录
   */
  public getAllProcessingHistory(): ProcessingHistoryData[] {
    try {
      const rawResult = this.db.Table(TABLE_NAMES.ProcessingHistory).Find();
      console.info(`📋 查询到 ${rawResult.length} 条历史加工记录（原始结果）`);
      
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      
      // 使用封装的转换函数
      const converted = result.map((item: QueryResult) => {
        return convertToProcessingHistoryData(item);
      });
      
      console.info(`📋 转换后的历史加工记录数量: ${converted.length}`);
      return converted;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询历史加工记录失败:', errorMsg);
      throw new Error(`查询历史加工记录失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 查询历史加工记录
   */
  public getProcessingHistoryById(id: number): ProcessingHistoryData | null {
    try {
      const rawResult = this.db.Table(TABLE_NAMES.ProcessingHistory).Where('id', id).Find();
      type QueryResult = Record<string, ESObject>;
      const result = rawResult as QueryResult[];
      if (result && result.length > 0) {
        const item = result[0];
        const getValue = (key: string): ESObject | undefined => {
          return item[key];
        };
        
        // 使用封装的转换函数
        return convertToProcessingHistoryData(item);
      }
      return null;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 查询历史加工记录失败:', errorMsg);
      throw new Error(`查询历史加工记录失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 更新历史加工记录（传入更新后的实体）
   */
  public updateProcessingHistory(id: number, historyRecord: ProcessingHistory): void {
    try {
      // 使用封装的函数将实体对象转换为 ValuesBucket
      const valueBucket = processingHistoryToValueBucket(historyRecord);
      
      this.db.Table(TABLE_NAMES.ProcessingHistory).Where('id', id).Update(valueBucket);
      console.info(`✅ 更新历史加工记录成功: ID=${id}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 更新历史加工记录失败:', errorMsg);
      throw new Error(`更新历史加工记录失败: ${errorMsg}`);
    }
  }

  /**
   * 根据 ID 删除历史加工记录
   */
  public deleteProcessingHistory(id: number): void {
    try {
      this.db.Table(TABLE_NAMES.ProcessingHistory).Where('id', id).Delete();
      console.info(`✅ 删除历史加工记录成功: ID=${id}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 删除历史加工记录失败:', errorMsg);
      throw new Error(`删除历史加工记录失败: ${errorMsg}`);
    }
  }

  // 事务相关操作 封装

  /** 开始事务 */
  public beginTransaction(): void {
    try {
      this.db.Begin();
      console.info('✅ 事务已开始');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 开始事务失败:', errorMsg);
      throw new Error(`开始事务失败: ${errorMsg}`);
    }
  }

  /** 提交事务 */
  public commitTransaction(): void {
    try {
      this.db.Commit();
      console.info('✅ 事务已提交');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 提交事务失败:', errorMsg);
      throw new Error(`提交事务失败: ${errorMsg}`);
    }
  }

  /** 回滚事务 */
  public rollbackTransaction(): void {
    try {
      this.db.Rollback();
      console.info('✅ 事务已回滚');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 回滚事务失败:', errorMsg);
      throw new Error(`回滚事务失败: ${errorMsg}`);
    }
  }

  /** 获取 ORM 最近一次错误信息（若有） */
  public getError(): string | null {
    const error = this.db.GetError();
    return error ? String(error) : null;
  }

  /**
   * 事务包装器：将一组操作包裹在 Begin/Commit 之间（失败自动回滚）
   */
  public async executeInTransaction(operations: () => void | Promise<void>): Promise<boolean> {
    try {
      // 开始事务
      this.beginTransaction();
      
      // 执行操作
      await operations();
      
      // 检查是否有错误
      const error = this.getError();
      if (error) {
        console.warn('⚠️ 事务执行过程中发生错误，准备回滚:', error);
        this.rollbackTransaction();
        return false;
      }
      
      // 提交事务
      this.commitTransaction();
      return true;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('❌ 事务执行失败，准备回滚:', errorMsg);
      try {
        this.rollbackTransaction();
      } catch (rollbackError) {
        console.error('❌ 回滚事务也失败:', rollbackError);
      }
      return false;
    }
  }
}
