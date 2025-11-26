import { relationalStore } from '@kit.ArkData'; // ArkData 数据库接口
import { Context } from '@kit.AbilityKit'; // 应用上下文
import { Class, GetColumnMeta, GetTableName } from '../decorator/Index'; // 获取注解元数据
import { camelToSnakeCase, createTableSQLByMeta, formatCastExpressions, getLocalTimeString} from '../utils/Utils'; // 工具函数
import { FieldType } from "../model/Global.type";    // 字段类型常量
import { RelationQueryExtension } from './RelationQueryExtension'; // 关联查询扩展
import { getMetadataCollector } from './MetadataCollector'; // 元数据收集
import { LazyLoadManager, LazyLoadProxy } from './LazyLoad'; // 延迟加载相关
import { CascadeManager, CascadeResult } from './CascadeManager'; // 级联操作相关

const TAG = "ibest-orm";  // TAG 统一打 log

/**
 * 数据迁移器类
 * 负责表的创建、删除、字段新增删除、结构变更等
 */
class Migrator {
  private orm: IBestORM;
  private rdbStore: relationalStore.RdbStore;

  /**
   * 构造方法
   * @param rdbStore 数据库存储实例
   * @param orm ORM 主对象（用于元数据收集等）
   */
  constructor(rdbStore: relationalStore.RdbStore, orm: IBestORM) {
    this.rdbStore = rdbStore;
    this.orm = orm;
  }

  /**
   * 创建表
   * @param model 实体类
   */
  CreateTable(model: Class) {
    // 避免重复建表
    if(this.HasTable(model)) {
      return;
    }
    const table = GetTableName(model);               
    const meta = GetColumnMeta(model);                
    console.log(TAG, createTableSQLByMeta(table, meta))
    this.rdbStore!.executeSql(createTableSQLByMeta(table, meta));  
    
    // 收集实际表的元数据，并自动建多对多中间表等
    getMetadataCollector().collect(model, this.orm);
  }

  /**
   * 删除表
   * @param model 实体类
   */
  DropTable(model: Class) {
    const table = GetTableName(model);
    return this.rdbStore!.executeSql(`DROP TABLE IF EXISTS ${table};`);
  }

  /**
   * 判断表是否存在
   * @param model 实体类或表名字符串
   * @returns 是否存在表   
   */
  HasTable(model: Class|string): boolean {
    let table = "";
    if(typeof model === "string") {
      table = model;
    } else {
      table = GetTableName(model);
    }

    const sql = `SELECT name FROM sqlite_master WHERE type = 'table' AND name = '${table}'`
    let resultSet = this.rdbStore!.querySqlSync(sql);
    let res: boolean = false;
    if(resultSet.rowCount > 0) {
      res = true;
    }
    resultSet.close();
    return res;
  }

  /**
   * 获取表结构信息（字段、类型等，PRAGMA table_info）
   * @param model 实体类或表名
   * @returns 字段信息数组
   */
  GetTableInfo(model: Class|string) {
    let table = "";
    if(typeof model === "string") {
      table = model;
    } else {
      table = GetTableName(model);
    }
    let resultData: Array<Record<string, relationalStore.ValueType>> = []
    let resultSet = this.rdbStore!.querySqlSync(`PRAGMA table_info('${table}');`);
    if(resultSet.columnCount > 0) {
      if (resultSet.goToFirstRow()) {
        while (!resultSet.isEnded) {
          let Model: Record<string, relationalStore.ValueType> = {}
          for (let i = 0; i < resultSet.columnNames.length; i++) {
            let value = resultSet.columnNames[i]
            Model[value] = resultSet.getValue(resultSet.getColumnIndex(value))
          }
          // 性能优化：移除不必要的去重检查
          // PRAGMA table_info不会返回重复记录
          resultData.push(Model)
          resultSet.goToNextRow()
        }
      }
    }
    return resultData;
  }

  /**
   * 重命名表
   * @param oldName 旧表名
   * @param newName 新表名
   */
  async RenameTable(oldName: string, newName: string) {
    if(!this.HasTable(oldName)) {
      console.log(TAG, "未创建数据表");
      return false;
    }
    await this.rdbStore!.executeSql(`ALTER TABLE ${oldName} RENAME TO ${newName};`);
    return true;
  }

  /**
   * 检查字段是否存在
   * @param model 实体类或表名
   * @param field 字段名
   */
  HasColumn(model: Class|string, field: string): boolean {
    let table = "";
    if(typeof model === "string") {
      table = model;
    } else {
      table = GetTableName(model); 
    }
    let resultSet = this.rdbStore!.querySqlSync(`SELECT COUNT(*) FROM pragma_table_info('${table}') WHERE name = '${field}';`);
    if(resultSet.rowCount > 0 && resultSet.goToFirstRow()) {
      let value = resultSet.columnNames[0];
      let count = resultSet.getDouble(resultSet.getColumnIndex(value));
      return count >= 1;
    }
    return false;
  }

  /**
   * 给已有的表增加字段（只会对"新增"的字段生效）
   * @param model 实体类
   */
  async AddColumn(model: Class) {
    if(!this.HasTable(model)) {
      console.log(TAG, "未创建数据表");
      return false;
    }
    let fields: string[] = this.GetTableFields(model);
    const table = GetTableName(model);
    const meta = GetColumnMeta(model);
    for (let i = 0; i < meta.length; i++) {
      const item = meta[i];
      const name = item.name!;
      const fieldType = item.type;
      const tag = item.tag ? item.tag: [];
      const isNotNull = tag.includes('notNull') ? "NOT NULL" : "";
      const isPrimaryKey = tag.includes('primaryKey') ? "PRIMARY KEY" : "";
      // 只在 INTEGER 主键 + 自增 时加 AUTOINCREMENT
      const autoIncrement = (fieldType == FieldType.INTEGER && tag.includes('autoIncrement')) ? "AUTOINCREMENT" : "";
      if(!fields.includes(name)) {
        let sqlStr = `ALTER TABLE ${table} ADD COLUMN ${name} ${fieldType} ${isNotNull} ${isPrimaryKey} ${autoIncrement};`
        // 如果有自动填充时间的字段，默认值赋为当前时间
        if(fieldType == FieldType.TEXT && (tag.includes('autoCreateTime') || tag.includes('autoUpdateTime'))) {
          sqlStr += ` DEFAULT (DATETIME('now', 'localtime'))`;
        }
        await this.rdbStore!.executeSql(`${sqlStr};`);
      }
    }
    return true;
  }

  /**
   * 删除多余的字段（字段移除场景，需数据库支持 ALTER TABLE DROP COLUMN）
   * @param model 实体类
   */
  async DropColumn(model: Class) {
    if(!this.HasTable(model)) {
      console.log(TAG, "未创建数据表");
      return false;
    }
    let fields: string[] = this.GetTableFields(model);
    let metaFields: string[] = [];
    const table = GetTableName(model);
    const meta = GetColumnMeta(model);
    for (let i = 0; i < meta.length; i++) {
      metaFields.push(meta[i].name!)
    }
    // 存在多余的字段（需要删除）
    if(!this.DiffStringArray(metaFields, fields)) {
      for (let i = 0; i < fields.length; i++) {
        if(!metaFields.includes(fields[i])) {
          await this.rdbStore!.executeSql(`ALTER TABLE ${table} DROP COLUMN ${fields[i]};`);
        }
      }
    }
    return true;
  }

  /**
   * 变更字段类型（SQLite 直接支持性有限，采用新建临时表再拷贝的方式）
   * @param model 实体类
   */
  async AlterColumn(model: Class) {
    if(!this.HasTable(model)) {
      console.log(TAG, "未创建数据表");
      return false;
    }
    let isAlter: boolean = false;
    const info = this.GetTableInfo(model);
    const table = GetTableName(model);
    const meta = GetColumnMeta(model);
    let newFields: string[] = [];
    let newTypes: FieldType[] = [];
    // 检查字段类型是否变动
    for (let i = 0; i < meta.length; i++) {
      const metaType = meta[i].type;
      const name = meta[i].name!
      newFields.push(name);
      newTypes.push(metaType);
      for (let j = 0; j < info.length; j++) {
        const field = info[j]["name"];
        const fieldType = info[j]["type"];
        if(field === name && fieldType !== metaType) {
          isAlter = true;
          break;
        }
      }
    }
    // 若类型变更，执行临时表数据copy、表结构替换
    if(isAlter) {
      await this.rdbStore!.executeSql(createTableSQLByMeta("temp_"+table, meta));
      await this.rdbStore!.executeSql(`INSERT INTO temp_${table} (${newFields.join(', ')}) SELECT ${formatCastExpressions(newFields, newTypes)} FROM ${table};`);
      await this.DropTable(model);
      await this.RenameTable("temp_"+table, table);
    }
    return true;
  }

  /**
   * 获取表的所有字段名（物理表结构）
   * @param model 实体类
   * @returns 字段字符串数组
   */
  private GetTableFields(model: Class): string[] {
    let fields: string[] = [];
    const info = this.GetTableInfo(model);
    for (let i = 0; i < info.length; i++) {
      let item = info[i];
      fields.push(item["name"] as string)
    }
    return fields;
  }

  /**
   * 字符串数组"内容"判等
   * @param arr1 数组1
   * @param arr2 数组2
   */
  private DiffStringArray(arr1: string[], arr2: string[]): boolean {
    if(arr1.length !== arr2.length) {
      return false;
    }
    return !arr1.some((item) => !arr2.includes(item));
  }
}

/**
 * ORM主类，提供链式数据操作API、关系与延迟加载支持
 */
export class IBestORM {
  // 数据库存储对象
  private rdbStore: relationalStore.RdbStore|null = null
  // 数据库Store配置
  private storeConfig: relationalStore.StoreConfig
  // 错误信息（最近一次出错时赋值）
  private error: string|null = null
  // 当前操作表名
  private tableName: string|null = null
  // 查询/插入/更新列集合
  private columns: Array<string> = []
  // 查询谓词（RdbPredicates 对象）
  private predicates: relationalStore.RdbPredicates|null = null
  // 数据迁移器
  private migrator: Migrator|null = null
  // 关联查询扩展
  private relationExtension: RelationQueryExtension|null = null
  // 延迟加载管理器
  private lazyLoadManager: LazyLoadManager|null = null
  // 级联操作管理器
  private cascadeManager: CascadeManager | null = null
  // 已迁移的表缓存（性能优化：避免重复执行迁移检查）
  private migratedTables: Set<string> = new Set()

  /**
   * 构造函数（请勿直接调用，用 IBestORM.Init 作为入口）
   */
  private constructor(
    rdbStore: relationalStore.RdbStore,
    storeConfig: relationalStore.StoreConfig
  ) {
    this.rdbStore = rdbStore;
    this.storeConfig = storeConfig;
    this.migrator = new Migrator(rdbStore, this);         // 初始化迁移器
    this.relationExtension = new RelationQueryExtension(this); // 关联查询扩展
    this.lazyLoadManager = new LazyLoadManager(this);         // 延迟加载
    this.cascadeManager = CascadeManager.getInstance(this);   // 级联管理
    console.log(TAG, "SQLiteORM Init");
  }

  /**
   * ORM初始化
   * @param Context 应用上下文
   * @param Config 数据库Store配置
   * @returns IBestORM实例（Promise）
   */
  static async Init(Context: Context, Config: relationalStore.StoreConfig): Promise<IBestORM> {
    try {
      const rdbStore = await relationalStore.getRdbStore(Context, Config);
      const orm = new IBestORM(rdbStore, Config);
      
      // 性能优化：配置 PRAGMA 设置以提升查询性能
      try {
        const core = orm.GetCore();
        if (core) {
          // 设置缓存大小为 64MB（负值表示 KB，-64000 = 64MB）
          core.executeSql('PRAGMA cache_size = -64000;');
          // 临时表存储在内存中，提升性能
          core.executeSql('PRAGMA temp_store = MEMORY;');
          // 平衡性能和安全性（WAL 模式下推荐使用 NORMAL）
          core.executeSql('PRAGMA synchronous = NORMAL;');
          // WAL 模式已在配置中设置，这里确保启用
          core.executeSql('PRAGMA journal_mode = WAL;');
          // 优化查询计划器
          core.executeSql('PRAGMA optimize;');
          console.log(TAG, 'PRAGMA 性能优化配置已应用');
        }
      } catch (pragmaError) {
        // PRAGMA 配置失败不影响数据库初始化
        console.warn(TAG, 'PRAGMA 配置失败（不影响使用）:', pragmaError);
      }
      
      return orm;
    } catch (err) {
      const error = err instanceof Error ? err : new Error(String(err));
      console.log(TAG, "SQLiteORM Init Error:", error.message);
      throw error;
    }
  }

  /**
   * 获取迁移器对象
   */
  Migrator() {
    return this.migrator!
  }

  /**
   * 自动迁移
   * 会执行：新建表/加字段/字段类型同步
   * @param model 实体类
   * @param force 是否强制迁移（忽略缓存）
   */
  AutoMigrate(model: Class, force: boolean = false) {
    const tableName = GetTableName(model);
    
    // 性能优化：如果表已迁移且不强制，跳过迁移检查
    if (!force && this.migratedTables.has(tableName)) {
      return;
    }
    
    if(!this.Migrator().HasTable(model)) {
      this.Migrator().CreateTable(model);
      this.migratedTables.add(tableName);
      return;
    }
    this.Migrator().AddColumn(model);
    //this.Migrator().DropColumn(model); // 视业务需要决定是否启用
    this.Migrator().AlterColumn(model);
    
    // 标记为已迁移
    this.migratedTables.add(tableName);

    getMetadataCollector().collect(model, this);
  }

  /**
   * 获取底层 rdbStore
   */
  GetCore() {
    return this.rdbStore;
  }

  /**
   * 创建实体记录（支持级联）
   * @param model 对象或对象数组
   * @param options.cascade 是否级联
   * @param options.entityClass 强制指定原型（可选）
   */
  async Create(model: Object|Array<Object>, options?: { cascade?: boolean, entityClass?: Class }): Promise<number> { 
    const cascade = options?.cascade ?? false;
    const entityClass = options?.entityClass;

    if (cascade && this.cascadeManager) {
      if(entityClass) {
        Object.setPrototypeOf(model, entityClass.prototype);
      }
      // 多条批量执行级联
      if (Array.isArray(model)) {
        let totalCreated = 0;
        for (const item of model) {
          const result: CascadeResult = await this.cascadeManager.cascadeCreate(item, item.constructor);
          //this.cascadeResultLog(result); // 可开启详细日志
          if (result.operationCount > 0) totalCreated++;
        }
        return totalCreated;
      } else {
        const result = await this.cascadeManager.cascadeCreate(model, model.constructor as Class);
        return result.operationCount;
      }
    }

    return this.createInternal(model);
  }

  /**
   * 级联结果打印（内部调试用）
   * @param result 级联返回结构
   */
  private cascadeResultLog(result: CascadeResult) {
    console.log('级联创建结果:');
    console.log('- 成功:', result.success);
    console.log('- 执行时间:', result.executionTime, 'ms');
    console.log('- 操作数量:', result.operationCount);
    console.log('- 受影响的实体:');
    const map = result.affectedEntities;
    const keys = map.keys();
    let key = keys.next();
    while (!key.done) {
      const tableName = key.value;
      const entities = map.get(tableName);
      if (entities) {
        console.log(`  ${tableName}: ${entities.length} 条记录`);
      }
      key = keys.next();
    }
    if (result.errors.length > 0) {
      console.log('- 错误信息:');
      result.errors.forEach((error, index) => {
        console.log(`  ${index + 1}. ${error.relation}: ${error.error.message}`);
      });
    }
  }

  /**
   * 内部数据插入
   * @param model 单对象或对象数组
   * @returns 新增主键值或行数
   */
  private createInternal(model: Object|Array<Object>): number {
    let table = "";
    let values: relationalStore.ValuesBucket|Array<relationalStore.ValuesBucket> = {};
    if(Array.isArray(model)) {
      values = new Array() as Array<relationalStore.ValuesBucket>;
      for (let i = 0; i < model.length; i++) {
        table = GetTableName(model[i].constructor);
        const meta = GetColumnMeta(model[i].constructor);
        let tmp: relationalStore.ValuesBucket = {}
        for (let j = 0; j < meta.length; j++) {
          const propertyKey = meta[j].propertyKey!;
          const columnName = meta[j].name!;
          if((this.columns.length > 0 && this.columns.includes(columnName)) || this.columns.length == 0) {
            // 跳过主键和自动时间字段（这些由数据库自动处理）
            if (meta[j].tag?.includes('primaryKey') || meta[j].tag?.includes('autoIncrement')) {
              continue;
            }
            const propertyValue = (model[i] as Record<string, relationalStore.ValueType>)[propertyKey];
            if (propertyValue !== undefined && propertyValue !== null) {
              tmp[columnName] = propertyValue;
            }
          }
        }
        values.push(tmp)
      }
    } else {
      table = GetTableName(model.constructor as Class);
      const meta = GetColumnMeta(model.constructor as Class);
      for (let i = 0; i < meta.length; i++) {
        const propertyKey = meta[i].propertyKey!;
        const columnName = meta[i].name!;
        // 跳过主键和自动时间字段（这些由数据库自动处理）
        if (meta[i].tag?.includes('primaryKey') || meta[i].tag?.includes('autoIncrement')) {
          continue;
        }
        if((this.columns.length > 0 && this.columns.includes(columnName)) || this.columns.length == 0) {
          const propertyValue = (model as Record<string, relationalStore.ValueType>)[propertyKey];
          if (propertyValue !== undefined && propertyValue !== null) {
            values[columnName] = propertyValue;
          }
        }
      }
    }
    return this.Table(table).Insert(values);
  }

  /**
   * 删除实体（支持级联）
   * @param model 实体对象
   * @param options.cascade 是否级联
   * @param options.entityClass 强制原型
   */
  async DeleteByEntity(model: Object, options?: { cascade?: boolean, entityClass?: Class }) {
    const cascade = options?.cascade ?? false;
    const entityClass = options?.entityClass;

    if (cascade && this.cascadeManager) {
      if(entityClass) {
        Object.setPrototypeOf(model, entityClass.prototype);
      }
      const rest = await this.cascadeManager.cascadeDelete(model, model.constructor as Class);
      return rest.operationCount;
    }

    // 常规主键匹配后删除
    const meta = GetColumnMeta(model.constructor as Class);
    let res: number = 0;
    for (let i = 0; i < meta.length; i++) {
      if(meta[i].tag?.includes('primaryKey')) {
        const propertyKey = meta[i].propertyKey!
        res = this.DeleteByKey(model.constructor as Class, ((model as relationalStore.ValuesBucket)[propertyKey]) as number)
        break;
      }
    }
    return res;
  }

  /**
   * 主键删除
   * @param model 实体类
   * @param keyValue 主键值（数字或数字数组）
   */
  DeleteByKey(model: Class, keyValue: number|number[]): number {
    const table = GetTableName(model);
    const meta = GetColumnMeta(model);
    let primaryKey = "id";
    for (let i = 0; i < meta.length; i++) {
      if(meta[i].tag?.includes('primaryKey')) {
        primaryKey = meta[i].name!
      }
    }
    return this.Table(table).Where(primaryKey, keyValue).Delete()
  }

  /**
   * 保存（支持级联）
   * @param model 实体对象
   * @param options.cascade 是否级联
   * @returns 更新行数
   */
  async Save(model: Object, options?: { cascade?: boolean, entityClass?: Class }): Promise<number> {
    const cascade = options?.cascade ?? false;
    const entityClass = options?.entityClass;

    if (cascade && this.cascadeManager) {
      if(entityClass) {
        Object.setPrototypeOf(model, entityClass.prototype);
      }
      const rest = await this.cascadeManager.cascadeUpdate(model, model.constructor as Class);
      return rest.operationCount;
    }

    const table = GetTableName(model.constructor as Class);
    const meta = GetColumnMeta(model.constructor as Class);
    let primaryKey = "id";
    let key = 0;
    let data: relationalStore.ValuesBucket = {};
    for (let i = 0; i < meta.length; i++) {
      if(meta[i].tag?.includes('autoUpdateTime')) {
        data[meta[i].name!] = getLocalTimeString();
        continue
      }
      if(meta[i].tag?.includes('primaryKey')) {
        primaryKey = meta[i].name!
        key = (model as relationalStore.ValuesBucket)[meta[i].propertyKey!] as number
        continue
      }
      data[meta[i].name!] = (model as relationalStore.ValuesBucket)[meta[i].propertyKey!]
    }
    if(key > 0) {
      return this.Table(table).Where(primaryKey, key).Update(data);
    }
    return 0;
  }

  /**
   * 指定表（链式调用基础）
   * @param TableName 表名
   * @returns this
   */
  Table(TableName: string) {
    this.tableName = TableName
    this.columns = []
    this.predicates = new relationalStore.RdbPredicates(this.tableName)
    return this
  }

  /**
   * 会话启动（指定实体类）
   * @param model 实体类
   * @returns this
   */
  Session(model: Class) {
    const table = GetTableName(model);
    this.tableName = table
    this.columns = []
    this.predicates = new relationalStore.RdbPredicates(this.tableName)

    // 设置给关联扩展
    if (this.relationExtension) {
      this.relationExtension.setEntityClass(model);
    }

    return this
  }

  ////////////////////// 关联查询API //////////////////////

  /**
   * 配置预加载的关联字段（with）
   * @param relations 关联名称或数组
   */
  With(relations: string | string[]) {
    if (this.relationExtension) {
      this.relationExtension.with(relations);
    }
    return this;
  }

  /**
   * 预加载（别名）
   */
  Preload(relations: string | string[]) {
    return this.With(relations);
  }

  /**
   * 执行带关联的查询，返回第一条数据
   * @param Ref 实体对象（可选）
   M_关联查询First
   * @param FailureCall 失败回调（可选）
   */
  async FirstWithRelations(Ref?: Object, FailureCall?: (msg: string) => void) {
    if (this.relationExtension) {
      try {
        return await this.relationExtension.firstWithRelations(Ref);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        this.error = errorMsg;
        if (FailureCall) FailureCall(errorMsg);
        return null;
      }
    }
    return this.First(Ref, FailureCall);
  }

  /**
   * 执行带关联的查询，返回所有数据
   * @param FailureCall 失败回调
   M_关联查询ALL
   */
  async FindWithRelations(FailureCall?: (msg: string) => void) {
    if (this.relationExtension) {
      try {
        const result = await this.relationExtension.findWithRelations();
        return result;
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        this.error = errorMsg;
        if (FailureCall) FailureCall(errorMsg);
        return [];
      }
    }
    return this.Find(undefined, FailureCall);
  }

  ////////////////////// 延迟加载API //////////////////////

  /**
   * 启用实体的延迟加载代理
   * @param entity 原始实体对象
   * @param entityClass 实体类（可选）
   */
  EnableLazyLoading(entity: Object, entityClass?: Class): LazyLoadProxy {
    if (!this.lazyLoadManager) {
      throw new Error('延迟加载管理器未初始化');
    }
    const actualEntityClass = entityClass || (entity.constructor as Class);
    return this.lazyLoadManager.createProxy(entity, actualEntityClass);
  }

  /**
   * 延迟加载指定关联
   * @param proxy 延迟加载代理
   * @param relationName 关联名
   * @param force 是否强制重载
   */
  LoadRelation(proxy: LazyLoadProxy, relationName: string, force: boolean = false) {
    if (!this.lazyLoadManager) {
      throw new Error('延迟加载管理器未初始化');
    }
    return this.lazyLoadManager.loadRelation(proxy, relationName, force);
  }

  /**
   * 预加载一个或多个关联
   * @param proxy 延迟加载代理对象
   * @param relationName 关联名(字符串或数组)
   */
  async PreloadRelation(proxy: LazyLoadProxy, relationName: string | string[]): Promise<void> {
    if (!this.lazyLoadManager) {
      throw new Error('延迟加载管理器未初始化');
    }
    return this.lazyLoadManager.preloadRelation(proxy, relationName);
  }

  /**
   * 重新加载一个或多个关联
   * @param proxy 延迟加载代理对象
   * @param relationName 关联名
   */
  ReloadRelation(proxy: LazyLoadProxy, relationName: string | string[]) {
    if (!this.lazyLoadManager) {
      throw new Error('延迟加载管理器未初始化');
    }

    return this.lazyLoadManager.reloadRelation(proxy, relationName);
  }

  /**
   * 检查关联是否已加载
   * @param proxy 延迟加载代理对象
   * @param relationName 关联名称
   * @returns 是否已加载
   */
  IsRelationLoaded(proxy: LazyLoadProxy, relationName: string): boolean {
    return proxy.isRelationLoaded(relationName);
  }

  /**
   * 获取已加载的关联数据（同步）
   * @param proxy 延迟加载代理对象
   * @param relationName 关联名称
   * @returns 已加载的关联数据，如果未加载则返回undefined
   */
  GetLoadedRelation(proxy: LazyLoadProxy, relationName: string) {
    return proxy.getLoadedRelation(relationName);
  }

  /**
   * 清除延迟加载缓存
   */
  ClearLazyLoadCache(): void {
    if (this.lazyLoadManager) {
      this.lazyLoadManager.clearCache();
    }
  }

  /**
   * 获取延迟加载管理器
   */
  GetLazyLoadManager(): LazyLoadManager | null {
    return this.lazyLoadManager;
  }
  ////////////////////////////////////////////////////////////
  /**
   * 插入数据
   * @param Data 可以是 ValuesBucket、实体对象、或它们的数组
   * @returns 插入的主键ID或受影响的行数
   */
  Insert(Data: relationalStore.ValuesBucket|Array<relationalStore.ValuesBucket>|Object|Array<Object>) {
    if(this.notSetTableError()) return -1
    
    // 判断是否是实体对象：检查是否有Model基类的特征
    // 实体对象通常有constructor且不是普通Object，并且有@Field装饰器的元数据
    const isEntityObject = (obj: any): boolean => {
      if (!obj || typeof obj !== 'object') return false;
      if (!obj.constructor || obj.constructor === Object) return false;
      // 检查是否有@Field装饰器的元数据（通过GetColumnMeta判断）
      try {
        const meta = GetColumnMeta(obj.constructor as Class);
        return meta && meta.length > 0;
      } catch {
        return false;
      }
    };
    
    // 如果是实体对象，转换为ValuesBucket
    let values: relationalStore.ValuesBucket|Array<relationalStore.ValuesBucket>;
    
    if(Array.isArray(Data)) {
      if(Data.length === 0) return 0
      // 检查第一个元素是否是实体对象
      const firstItem = Data[0];
      if (isEntityObject(firstItem)) {
        // 是实体对象数组，需要转换
        values = [];
        for (let i = 0; i < Data.length; i++) {
          const entity = Data[i] as Object;
          const meta = GetColumnMeta(entity.constructor as Class);
          const bucket: relationalStore.ValuesBucket = {};
          for (let j = 0; j < meta.length; j++) {
            const propertyKey = meta[j].propertyKey!;
            const columnName = meta[j].name!;
            // 跳过主键和自动时间字段
            if (meta[j].tag?.includes('primaryKey') || meta[j].tag?.includes('autoIncrement')) {
              continue;
            }
            const value = (entity as Record<string, relationalStore.ValueType>)[propertyKey];
            if (value !== undefined && value !== null) {
              bucket[columnName] = value;
            }
          }
          values.push(bucket);
        }
      } else {
        // 已经是ValuesBucket数组
        values = Data as Array<relationalStore.ValuesBucket>;
      }
      return this.rdbStore!.batchInsertSync(this.tableName!, values)
    } else {
      // 单个对象
      if (isEntityObject(Data)) {
        // 是实体对象，需要转换
        const entity = Data as Object;
        const meta = GetColumnMeta(entity.constructor as Class);
        const bucket: relationalStore.ValuesBucket = {};
        for (let j = 0; j < meta.length; j++) {
          const propertyKey = meta[j].propertyKey!;
          const columnName = meta[j].name!;
          // 跳过主键和自动时间字段
          if (meta[j].tag?.includes('primaryKey') || meta[j].tag?.includes('autoIncrement')) {
            continue;
          }
          const value = (entity as Record<string, relationalStore.ValueType>)[propertyKey];
          if (value !== undefined && value !== null) {
            bucket[columnName] = value;
          }
        }
        values = bucket;
      } else {
        // 已经是ValuesBucket
        values = Data as relationalStore.ValuesBucket;
      }
      return this.rdbStore!.insertSync(this.tableName!, values)
    }
  }
  /**   M_查询First
   * 查询并返回第一条符合条件的数据。
   * @param Ref 可选，用于接收结果的对象，会根据字段元数据将查询到的值赋值给对象的对应属性。
   * @param FailureCall 可选，查询失败时的回调函数，接收错误消息。
   */
  /**
   * 你可以什么参数都不传，直接调用 First() 就能查出数据库里的第一条数据。
   * 
   * 比如：
   *    let data = orm.First();
   *    // data 现在就是查到的首行对象（如果没有则是空对象）
   */
  First(Ref?: Object, FailureCall?: (msg: string) => void) {
    let Model: Record<string, relationalStore.ValueType> = Ref as Record<string, relationalStore.ValueType> || {}
    let resultSet = this.rdbStore!.querySync(this.predicates, this.columns)
    if(resultSet.rowCount > 0) {
      if (resultSet.goToFirstRow()) {
        // 性能优化：预先计算列映射
        let columnNameMap: Record<string, string> | null = null;
        if(Ref) {
          const meta = GetColumnMeta(Ref.constructor as Class);
          columnNameMap = {};
          for (let j = 0; j < meta.length; j++) {
            if(meta[j].name) {
              columnNameMap[meta[j].name] = meta[j].propertyKey || meta[j].name;
            }
          }
        }
        
        const hasColumnFilter = this.columns.length > 0;
        const columnSet = hasColumnFilter ? new Set(this.columns) : null;
        
        for (let i = 0; i < resultSet.columnNames.length; i++) {
          let value = resultSet.columnNames[i]
          if (!hasColumnFilter || (columnSet && columnSet.has(value))) {
            const columnIndex = resultSet.getColumnIndex(value);
            const columnValue = resultSet.getValue(columnIndex);
            if(Ref && columnNameMap) {
              const propertyKey = columnNameMap[value];
              if(propertyKey) {
                Model[propertyKey] = columnValue;
              } else {
                Model[value] = columnValue;
              }
            } else {
              Model[value] = columnValue;
            }
          }
        }
      } else {
        this.error = "Go To First Row Failed"
        if (FailureCall) FailureCall(this.error)
      }
    }
    resultSet.close()
    return Model
  }
      //M_查询Last
  Last(Ref?: Object, FailureCall?: (msg: string) => void) {
    let Model: Record<string, relationalStore.ValueType> = Ref as Record<string, relationalStore.ValueType> || {}
    let resultSet = this.rdbStore!.querySync(this.predicates, this.columns)
    if(resultSet.rowCount > 0) {
      if (resultSet.goToLastRow()) {
        // 性能优化：预先计算列映射
        let columnNameMap: Record<string, string> | null = null;
        if(Ref) {
          const meta = GetColumnMeta(Ref.constructor as Class);
          columnNameMap = {};
          for (let j = 0; j < meta.length; j++) {
            if(meta[j].name) {
              columnNameMap[meta[j].name] = meta[j].propertyKey || meta[j].name;
            }
          }
        }
        
        const hasColumnFilter = this.columns.length > 0;
        const columnSet = hasColumnFilter ? new Set(this.columns) : null;
        
        for (let i = 0; i < resultSet.columnNames.length; i++) {
          let value = resultSet.columnNames[i]
          if (!hasColumnFilter || (columnSet && columnSet.has(value))) {
            const columnIndex = resultSet.getColumnIndex(value);
            const columnValue = resultSet.getValue(columnIndex);
            if(Ref && columnNameMap) {
              const propertyKey = columnNameMap[value];
              if(propertyKey) {
                Model[propertyKey] = columnValue;
              } else {
                Model[value] = columnValue;
              }
            } else {
              Model[value] = columnValue;
            }
          }
        }
      } else {
        this.error = "Go To Last Row Failed"
        if (FailureCall) FailureCall(this.error)
      }
    }
    resultSet.close()
    return Model
  }
  //M_查询ALL
  Find(ModelClass?: Class, FailureCall?: (msg: string) => void) {
    let resultSet = this.rdbStore!.querySync(this.predicates, this.columns)
    let resultData: Array<Record<string, relationalStore.ValueType>> = []
    if(resultSet.rowCount > 0) {
      // 性能优化：预先获取元数据，避免在循环中重复调用
      let meta: any[] | null = null;
      if(ModelClass) {
        meta = GetColumnMeta(ModelClass);
      }
      
      // 性能优化：预先计算列名映射，避免在循环中重复查找
      const columnNameMap: Record<string, string> = {};
      if(meta && ModelClass) {
        for (let j = 0; j < meta.length; j++) {
          if(meta[j].name) {
            columnNameMap[meta[j].name] = meta[j].propertyKey || meta[j].name;
          }
        }
      }
      
      // 性能优化：预先计算列索引和过滤条件，避免在循环中重复计算
      const columnIndices: Array<{index: number, name: string, propertyKey?: string}> = [];
      const hasColumnFilter = this.columns.length > 0;
      const columnSet = hasColumnFilter ? new Set(this.columns) : null;
      
      for (let i = 0; i < resultSet.columnNames.length; i++) {
        const columnName = resultSet.columnNames[i];
        // 如果指定了列过滤，检查是否包含此列
        if (!hasColumnFilter || (columnSet && columnSet.has(columnName))) {
          const propertyKey = ModelClass && meta ? (columnNameMap[columnName] || columnName) : columnName;
          columnIndices.push({
            index: resultSet.getColumnIndex(columnName),
            name: columnName,
            propertyKey: propertyKey !== columnName ? propertyKey : undefined
          });
        }
      }
      
      if (resultSet.goToFirstRow()) {
        while (!resultSet.isEnded) {
          // 如果传入了ModelClass，创建实体类对象；否则创建普通对象
          let Model: Record<string, relationalStore.ValueType>;
          if (ModelClass) {
            // 创建实体类实例，但类型仍然是Record以便兼容
            Model = Object.create(ModelClass.prototype) as Record<string, relationalStore.ValueType>;
          } else {
            Model = {};
          }
          
          // 性能优化：使用预计算的列索引，避免在循环中重复调用getColumnIndex
          for (let i = 0; i < columnIndices.length; i++) {
            const col = columnIndices[i];
            const value = resultSet.getValue(col.index);
            if (col.propertyKey) {
              Model[col.propertyKey] = value;
            } else {
              Model[col.name] = value;
            }
          }

          // 性能优化：移除不必要的去重检查
          // 数据库查询本身不会返回重复记录，includes检查会导致O(n²)复杂度
          // 对于12760条数据，includes检查会导致约1.6亿次比较操作！
          resultData.push(Model);
          resultSet.goToNextRow()
        }
      } else {
        this.error = "Go To First Row Failed"
        if (FailureCall) FailureCall(this.error)
      }
    }
    resultSet.close()
    return resultData
  }
  // M_更新
  Update(Data: relationalStore.ValuesBucket) {
    let values: relationalStore.ValuesBucket = {};
    const keys = Object.keys(Data);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      if((this.columns.length > 0 && this.columns.includes(camelToSnakeCase(key))) || this.columns.length == 0) {
        values[key] = Data[key];
      }
    }
    if(this.Migrator().HasColumn(this.tableName!, "updated_at")) {
      values["updated_at"] = getLocalTimeString();
    }
    return this.rdbStore!.updateSync(values, this.predicates)
  }
  //M_删除
  Delete() {
    return this.rdbStore!.deleteSync(this.predicates)
  }
  
  /** M_选择列
   * 选择需要查询的列（Select 区间）
   * @param Columns 需要查询的字段名数组
   * @returns this
   */
  Select(Columns: Array<string>) {
    this.columns = Columns.map(col => camelToSnakeCase(col));
    return this;
  }
  //M_选择条件
  Where(Key: string|Array<string>, Value: string|number|boolean|Array<string|number|boolean>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && (Value === undefined || Value === null)) {
      this.predicates!.isNull(Key)
    }else if(typeof Key === 'object' && (Value === undefined || Value === null)) {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.isNull(Key[i])
      }
    }else if(typeof Key === 'string' && (typeof Value === 'string' || typeof Value === 'number' || typeof Value === 'boolean')) {
      this.predicates!.equalTo(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.equalTo(Key[i], Value[i])
      }
    }else if(typeof Key === 'string' && typeof Value === 'object') {
      this.predicates!.in(Key, Value)
    }
    return this
  }
  //M_选择不等于
  Not(Key: string|Array<string>, Value: string|number|boolean|Array<string|number|boolean>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && (Value === undefined || Value === null)) {
      this.predicates!.isNotNull(Key)
    }else if(typeof Key === 'object' && (Value === undefined || Value === null)) {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.isNotNull(Key[i])
      }
    }else if(typeof Key === 'string' && (typeof Value === 'string' || typeof Value === 'number' || typeof Value === 'boolean')) {
      this.predicates!.notEqualTo(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.notEqualTo(Key[i], Value[i])
      }
    }else if(typeof Key === 'string' && typeof Value === 'object') {
      this.predicates!.notIn(Key, Value)
    }
    return this
  }
  //M_近似查询
  Like(Key: string|Array<string>, Value: string|Array<string>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && typeof Value === 'string') {
      this.predicates!.like(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'string') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.like(Key[i], Value)
      }
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.like(Key[i], Value[i])
      }
    }
    return this
  }

  // M_区间查询
  Between(Key: string, Min: relationalStore.ValueType = 0, Max: relationalStore.ValueType = 0) {
    if(this.notSetTableError()) return this
    this.predicates!.between(Key, Min, Max)
    return this
  }
  //M_选择不等于区间
  NotBetween(Key: string, Min: relationalStore.ValueType = 0, Max: relationalStore.ValueType = 0) {
    if(this.notSetTableError()) return this
    this.predicates!.notBetween(Key, Min, Max)
    return this
  }
  //M_选择大于
  Greater(Key: string|Array<string>, Value: number|Array<number>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && typeof Value === 'number') {
      this.predicates!.greaterThan(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'number') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.greaterThan(Key[i], Value)
      }
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.greaterThan(Key[i], Value[i])
      }
    }
    return this
  }
  //M_选择小于
  Less(Key: string|Array<string>, Value: number|Array<number>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && typeof Value === 'number') {
      this.predicates!.lessThan(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'number') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.lessThan(Key[i], Value)
      }
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.lessThan(Key[i], Value[i])
      }
    }
    return this
  }
  //M_选择大于等于
  GreaterOrEqualTo(Key: string|Array<string>, Value: number|Array<number>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && typeof Value === 'number') {
      this.predicates!.greaterThanOrEqualTo(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'number') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.greaterThanOrEqualTo(Key[i], Value)
      }
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.greaterThanOrEqualTo(Key[i], Value[i])
      }
    }
    return this
  }
  //M_选择小于等于
  LessOrEqualTo(Key: string|Array<string>, Value: number|Array<number>) {
    if(this.notSetTableError()) return this
    if(typeof Key === 'string' && typeof Value === 'number') {
      this.predicates!.lessThanOrEqualTo(Key, Value)
    }else if(typeof Key === 'object' && typeof Value === 'number') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.lessThanOrEqualTo(Key[i], Value)
      }
    }else if(typeof Key === 'object' && typeof Value === 'object') {
      for(let i = 0; i < Key.length; i++) {
        this.predicates!.lessThanOrEqualTo(Key[i], Value[i])
      }
    }
    return this
  }
  //M_选择或
  Or() {
    this.predicates!.or()
    return this
  }
  //M_选择与
  And() {
    this.predicates!.and()
    return this
  }
  //M_选择升序
  OrderByAsc(Key: string) {
    if(this.notSetTableError()) return this
    this.predicates!.orderByAsc(Key)
    return this
  }
  //M_选择降序
  OrderByDesc(Key: string) {
    if(this.notSetTableError()) return this
    this.predicates!.orderByDesc(Key)
    return this
  }
  //M_选择限制
  Limit(Len: number) {
    if(this.notSetTableError()) return this
    this.predicates!.limitAs(Len)
    return this
  }
  //M_选择偏移
  Offset(Len: number) {
    if(this.notSetTableError()) return this
    this.predicates!.offsetAs(Len)
    return this
  }
  //M_选择分组
  Group(Keys: string|Array<string>) {
    if(this.notSetTableError()) return this
    if(typeof Keys === 'string') {
      this.predicates!.groupBy([Keys])
    }else if(typeof Keys === 'object') {
      this.predicates!.groupBy(Keys)
    }
    return this
  }
  //M_选择开始
  Begin() {
    this.rdbStore!.beginTransaction()
  }
  //M_选择回滚
  Rollback() {
    this.rdbStore!.rollBack()
  }
  //M_选择提交
  Commit() {
    this.rdbStore!.commit()
  }

  //M_选择错误
  GetError() {
    return this.error
  }

  private notSetTableError() {
    if(this.tableName == null || this.predicates == null) {
      this.error = 'Not Set Table Error'
      return true
    }
    if(this.rdbStore == null) {
      this.error = 'rdbStore Error'
      return true
    }
    return false
  }
}