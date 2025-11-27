# 快速开始指南

## 🎯 在其他项目中使用数据库模块

### 步骤 1: 复制数据库模块

将整个 `database` 目录复制到你的新项目中：

```
你的项目/
  └── src/main/ets/
      └── database/          ← 复制整个目录
          ├── index.ets     ← 统一导出入口
          ├── DatabaseHelper.ets
          ├── adapters/
          ├── orm/
          └── ...
```

**注意**：可以删除 `database/init.ets` 和 `database/models/ProcessingHistory.ets`（这些是当前项目专用的）

### 步骤 2: 导入并使用

#### 方式 A: 基本使用（不自动迁移模型）

```typescript
// 在任何文件中
import { DatabaseHelper } from './database';

// 直接使用，数据库会在首次调用时自动初始化
export async function myFunction(ctx: Context) {
  // 查询数据（表需要手动创建或使用原生SQL创建）
  const data = await DatabaseHelper.queryAll(ctx, 'my_table');
  
  // 插入数据
  const id = await DatabaseHelper.insert(ctx, 'my_table', {
    name: '测试',
    value: 100
  });
  
  // 更新数据
  await DatabaseHelper.update(ctx, 'my_table', id, {
    name: '更新后的名称'
  });
  
  // 删除数据
  await DatabaseHelper.delete(ctx, 'my_table', id);
}
```

#### 方式 B: 带配置使用（自动迁移模型）

```typescript
import { DatabaseHelper, DatabaseAdapterFactory } from './database';
import { User, Product } from './models';  // 你的模型

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

### 步骤 3: 完成！

就这么简单！数据库会自动初始化。

## 📋 完整示例

```typescript
import { Context } from '@kit.AbilityKit';
import { DatabaseHelper } from './database';

// 示例：用户管理服务
export class UserService {
  // 获取所有用户
  static async getAllUsers(ctx: Context) {
    return await DatabaseHelper.queryAll(ctx, 'users');
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
}
```

## 🔧 需要切换数据库？

只需一行代码：

```typescript
import { DatabaseAdapterFactory, MySQLAdapter } from './database';

// 在应用启动时切换
DatabaseAdapterFactory.setAdapter(new MySQLAdapter());

// 之后所有 DatabaseHelper 的调用都会使用新数据库
```

## 📚 更多文档

- 完整 API 文档：查看 `README.md`
- 使用示例：查看 `USAGE_EXAMPLE.ets`

