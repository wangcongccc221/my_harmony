# 数据库模块使用文档

## 📦 简介

这是一个通用的数据库抽象层模块，可以在任何 HarmonyOS 项目中使用。支持 SQLite（默认），未来可扩展支持 MySQL、PostgreSQL 等。

## 🚀 快速开始

### 1. 复制数据库模块

将整个 `database` 目录复制到你的新项目中（可以删除 `init.ets` 和项目特定的模型文件）。

### 2. 导入模块

```typescript
import { DatabaseHelper, DatabaseAdapterFactory } from './database';
```

### 3. 使用方式

#### 方式 A: 基本使用（不自动迁移模型）

```typescript
import { Context } from '@kit.AbilityKit';
import { DatabaseHelper } from './database';

// 直接使用，数据库会在首次调用时自动初始化
// 注意：表需要手动创建或使用原生SQL创建
export async function myFunction(ctx: Context) {
  // 查询所有数据
  const allData = await DatabaseHelper.queryAll(ctx, 'my_table');
  
  // 插入数据
  const id = await DatabaseHelper.insert(ctx, 'my_table', {
    name: '张三',
    age: 25
  });
  
  // 更新、删除、统计等操作...
}
```

#### 方式 B: 带配置使用（自动迁移模型，推荐）

```typescript
import { Context } from '@kit.AbilityKit';
import { DatabaseHelper, DatabaseAdapterFactory } from './database';
import { User, Product } from './models';  // 你的模型类

// 在应用启动时（如 EntryAbility 的 onCreate）初始化
DatabaseAdapterFactory.initialize({
  dbName: 'my_app.db',
  models: [User, Product]  // 需要自动迁移的模型
});

// 之后正常使用
export async function myFunction(ctx: Context) {
  const users = await DatabaseHelper.queryAll(ctx, 'users');
  // ...
}
```

## 📚 API 文档

### DatabaseHelper

所有方法都是静态方法，可以直接调用。

#### queryAll

查询所有记录

```typescript
static async queryAll<T>(
  ctx: Context,
  tableName: string,
  modelClass?: Class
): Promise<T[]>
```

**示例：**
```typescript
const data = await DatabaseHelper.queryAll<MyData>(ctx, 'my_table', MyModel);
```

#### queryPage

分页查询

```typescript
static async queryPage<T>(
  ctx: Context,
  tableName: string,
  page: number,      // 页码（从1开始）
  size: number,       // 每页大小
  modelClass?: Class
): Promise<T[]>
```

**示例：**
```typescript
const page1 = await DatabaseHelper.queryPage(ctx, 'my_table', 1, 20);
```

#### count

统计记录总数

```typescript
static async count(ctx: Context, tableName: string): Promise<number>
```

#### insert

插入单条记录

```typescript
static async insert(
  ctx: Context,
  tableName: string,
  values: relationalStore.ValuesBucket
): Promise<number>  // 返回插入的记录ID
```

#### batchInsert

批量插入

```typescript
static async batchInsert(
  ctx: Context,
  tableName: string,
  valuesList: Array<relationalStore.ValuesBucket>
): Promise<number>  // 返回插入的记录数
```

#### update

更新记录

```typescript
static async update(
  ctx: Context,
  tableName: string,
  id: number,
  values: relationalStore.ValuesBucket
): Promise<number>  // 返回受影响的行数
```

#### delete

删除记录

```typescript
static async delete(
  ctx: Context,
  tableName: string,
  id: number
): Promise<number>  // 返回受影响的行数
```

#### querySql

执行原生 SQL 查询

```typescript
static async querySql<T>(
  ctx: Context,
  sql: string
): Promise<T[]>
```

#### executeSql

执行原生 SQL 更新

```typescript
static async executeSql(
  ctx: Context,
  sql: string
): Promise<number>  // 返回受影响的行数
```

## 🔧 高级用法

### 切换数据库

如果需要切换到其他数据库（如 MySQL），只需：

```typescript
import { DatabaseAdapterFactory, MySQLAdapter } from './database';

// 在应用启动时切换
DatabaseAdapterFactory.setAdapter(new MySQLAdapter());

// 之后所有 DatabaseHelper 的调用都会使用 MySQL
const data = await DatabaseHelper.queryAll(ctx, 'my_table');
```

### 自定义适配器

实现 `IDatabaseAdapter` 接口：

```typescript
import { IDatabaseAdapter } from './database';

class MyCustomAdapter implements IDatabaseAdapter {
  async initialize(ctx: Context): Promise<void> {
    // 初始化逻辑
  }
  
  async queryAll<T>(ctx: Context, tableName: string, modelClass?: Class): Promise<T[]> {
    // 查询逻辑
  }
  
  // ... 实现其他方法
}

// 使用自定义适配器
DatabaseAdapterFactory.setAdapter(new MyCustomAdapter());
```

## 📝 完整示例

```typescript
import { Context } from '@kit.AbilityKit';
import { DatabaseHelper } from './database';

export class UserService {
  // 查询所有用户
  static async getAllUsers(ctx: Context) {
    return await DatabaseHelper.queryAll(ctx, 'users');
  }
  
  // 分页查询用户
  static async getUsersByPage(ctx: Context, page: number, size: number) {
    return await DatabaseHelper.queryPage(ctx, 'users', page, size);
  }
  
  // 添加用户
  static async addUser(ctx: Context, name: string, email: string) {
    return await DatabaseHelper.insert(ctx, 'users', {
      name: name,
      email: email,
      created_at: new Date().toISOString()
    });
  }
  
  // 更新用户
  static async updateUser(ctx: Context, id: number, name: string) {
    return await DatabaseHelper.update(ctx, 'users', id, {
      name: name
    });
  }
  
  // 删除用户
  static async deleteUser(ctx: Context, id: number) {
    return await DatabaseHelper.delete(ctx, 'users', id);
  }
  
  // 统计用户数
  static async getUserCount(ctx: Context) {
    return await DatabaseHelper.count(ctx, 'users');
  }
}
```

## ⚙️ 配置

数据库配置在 `SQLiteAdapter` 中，可以根据需要修改：

```typescript
// 在 SQLiteAdapter.ets 中
private readonly config: relationalStore.StoreConfig = {
  name: 'article.db',              // 数据库文件名
  securityLevel: relationalStore.SecurityLevel.S2  // 安全级别
};
```

## 🔍 注意事项

1. **数据库初始化**：
   - 如果使用 `DatabaseAdapterFactory.initialize()` 配置了模型，会在初始化时自动迁移
   - 如果直接使用 `DatabaseHelper`，数据库会在首次调用时自动初始化，但**不会自动迁移模型**，需要手动创建表
2. **模型迁移**：如果使用 ORM 模型，建议在应用启动时调用 `DatabaseAdapterFactory.initialize()` 配置需要迁移的模型
3. **Context 参数**：所有方法都需要传入 `Context`，通常从 `UIAbility` 或组件中获取
4. **异步操作**：所有数据库操作都是异步的，需要使用 `await`
5. **类型安全**：建议使用泛型指定返回类型，如 `queryAll<MyType>`
6. **项目特定文件**：复制模块时可以删除 `init.ets` 和项目特定的模型文件（如 `ProcessingHistory.ets`）

## 📦 在其他项目中使用

### 方式一：直接复制模块

1. 复制整个 `database` 目录到新项目
2. 导入使用：
   ```typescript
   import { DatabaseHelper } from './database';
   ```

### 方式二：作为 npm/ohpm 包（未来）

1. 将模块发布到 npm/ohpm
2. 安装：
   ```bash
   ohpm install @your-org/database
   ```
3. 导入使用：
   ```typescript
   import { DatabaseHelper } from '@your-org/database';
   ```

##  问题排查

### 数据库未初始化错误

确保传入的 `Context` 是正确的，通常从 `UIAbility` 获取：

```typescript
// 在 UIAbility 中
onWindowStageCreate(windowStage: window.WindowStage) {
  const ctx = this.context;
  // 使用 ctx
}
```

### 表不存在错误

确保表已经创建，可以通过 ORM 的 `AutoMigrate` 或手动创建。


