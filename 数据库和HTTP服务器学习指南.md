# 数据库和HTTP服务器学习指南

## 📚 一、数据库部分（DatabaseManager）

### 1. 核心文件位置
- **主文件**：`entry/src/main/ets/database/DatabaseManager.ets`
- **模型文件**：`entry/src/main/ets/database/models/`（User.ets, ProcessingHistory.ets 等）
- **类型定义**：`entry/src/main/ets/database/types.ets`

### 2. 关键概念

#### 2.1 ORM（对象关系映射）
**什么是 ORM？**
- ORM = Object-Relational Mapping（对象关系映射）
- **作用**：把数据库表映射成编程语言中的类（Class）
- **好处**：不用写 SQL，直接用代码操作对象

**例子：**
```typescript
// 1. 定义类（对应数据库表）
@Table
export class User extends Model {
  @Field({ type: FieldType.TEXT })
  Name?: string;
  
  @Field({ type: FieldType.INTEGER })
  Age?: number;
}

// 2. 创建对象（对应数据库的一行数据）
const user = new User("张三", 25);

// 3. 保存到数据库（ORM 自动生成 SQL）
db.Create(user);
```

**我们用的 ORM 框架：**
- **IBest-ORM**（HarmonyOS 专用）
- 底层使用 ArkData 关系存储

#### 2.2 单例模式（Singleton）
**为什么用单例？**
- 确保整个应用只有一个数据库管理器实例
- 避免重复初始化，节省资源

**代码：**
```typescript
export class DatabaseManager {
  private static instance: DatabaseManager | null = null;
  
  // 私有构造函数，外部不能直接 new
  private constructor() {}
  
  // 获取单例（全局唯一）
  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }
}
```

**使用方式：**
```typescript
// 不是 new DatabaseManager()，而是：
const dbManager = DatabaseManager.getInstance();
```

#### 2.3 自动建表（AutoMigrate）
**什么是 AutoMigrate？**
- 根据模型类自动创建数据库表
- 如果表已存在，会检查字段是否一致（对齐）

**代码：**
```typescript
public async initDatabase(): Promise<void> {
  // 根据模型自动创建表（不存在则创建，存在则对齐）
  this.db.AutoMigrate(User);
  this.db.AutoMigrate(TestModel);
  this.db.AutoMigrate(ProcessingHistory);
}
```

**什么时候调用？**
- 应用启动时调用一次（在 `EntryAbility.ets` 中）

#### 2.4 事务（Transaction）
**什么是事务？**
- 把多个数据库操作打包成一个整体
- **要么全部成功，要么全部失败**（原子性）
- 保证数据一致性

**例子：用户表和权限表同时写入**
```typescript
// 问题：如果用户创建成功，但权限创建失败，怎么办？
// 答案：用事务，要么都成功，要么都回滚

await dbManager.executeInTransaction(async () => {
  // 步骤1：创建用户
  dbManager.addUser("张三", 25);
  
  // 步骤2：创建权限
  // addPermission(...);
  
  // 如果任何一步失败，全部回滚（撤销）
  // 如果全部成功，自动提交（保存）
});
```

**事务的四个特性（ACID）：**
- **A**tomicity（原子性）：要么全部成功，要么全部失败
- **C**onsistency（一致性）：数据保持一致状态
- **I**solation（隔离性）：多个事务互不干扰
- **D**urability（持久性）：提交后数据永久保存

#### 2.5 CRUD 封装
**什么是 CRUD？**
- **C**reate（创建）：`addUser()`, `createUser()`
- **R**ead（读取）：`getAllUsers()`, `getUserById()`
- **U**pdate（更新）：`updateUser()`
- **D**elete（删除）：`deleteUser()`

**为什么封装？**
- 简化使用：一行代码搞定，不用写 SQL
- 统一接口：所有表都用同样的方法
- 易于维护：修改逻辑只需要改一个地方

**使用示例：**
```typescript
const dbManager = DatabaseManager.getInstance();

// 添加数据（一行代码）
dbManager.addUser("张三", 25);

// 查询数据
const users = dbManager.getAllUsers();

// 更新数据
dbManager.updateUser(1, "李四", 30);

// 删除数据
dbManager.deleteUser(1);
```

### 3. 关键代码片段

#### 3.1 初始化数据库
```typescript
// EntryAbility.ets 中
await IBestORMInit(this.context, {
  name: "database.db",
  securityLevel: relationalStore.SecurityLevel.S1
});

const dbManager = DatabaseManager.getInstance();
await dbManager.initDatabase();
```

#### 3.2 添加数据（两种方式）
```typescript
// 方式1：使用实体对象
const user = new User("张三", 25);
dbManager.createUser(user);

// 方式2：使用便捷方法（推荐）
dbManager.addUser("张三", 25);
```

#### 3.3 查询数据
```typescript
// 查询所有
const users = dbManager.getAllUsers();

// 根据ID查询
const user = dbManager.getUserById(1);

// 条件查询
const users = dbManager.getUsersByAge(25);
```

#### 3.4 事务使用
```typescript
const success = await dbManager.executeInTransaction(async () => {
  dbManager.addUser("张三", 25);
  // 其他操作...
});

if (success) {
  console.info("事务成功");
} else {
  console.error("事务失败，已回滚");
}
```

---

## 🌐 二、HTTP 服务器部分

### 1. 核心文件位置
- **路由处理**：`entry/src/main/ets/utils/network/HttpServerHandler.ets`
- **API 处理器**：`entry/src/main/ets/utils/network/handlers/ProcessingApiHandler.ets`
- **文件浏览器**：`entry/src/main/ets/utils/network/handlers/FileBrowserHandler.ets`
- **API 文档**：`entry/src/main/ets/utils/network/docs/ApiDocumentation.ets`

### 2. 关键概念

#### 2.1 HTTP 服务器工作原理
**流程：**
1. 应用启动时，在 `EntryAbility.ets` 中启动 HTTP 服务器（端口 8080）
2. 收到 HTTP 请求后，`HttpServerHandler` 解析请求路径
3. 根据路径路由到不同的处理器（API、文件浏览器等）
4. 处理器生成响应（HTML 或 JSON）
5. 返回给客户端

**代码：**
```typescript
// EntryAbility.ets 中启动服务器
await startHttpServer(8080, HttpServerHandler.createRouterHandler(), this.context);
```

#### 2.2 路由（Routing）
**什么是路由？**
- 根据请求的 URL 路径，决定调用哪个处理函数

**路由表：**
```typescript
// HttpServerHandler.ets 中
if (path === '/' || path === '/index') {
  // 文件浏览器首页
  return await FileBrowserHandler.getRootResponse(context);
}
if (path.startsWith('/file/')) {
  // 文件内容
  return await FileBrowserHandler.getFileContentResponse(filePath);
}
if (path === '/api/status') {
  // 服务器状态
  return ResponseHandler.getStatusResponse();
}
if (path === '/api/docs') {
  // API 文档
  return ApiDocumentation.getApiDocsResponse();
}
if (path.startsWith('/api/processing')) {
  // 加工历史 API
  return await ProcessingApiHandler.handle(method, path, body);
}
```

#### 2.3 RESTful API 风格
**什么是 RESTful？**
- 用 HTTP 方法（GET/POST/PUT/DELETE）表示操作
- 用 URL 路径表示资源

**我们的接口：**
- `GET /api/processing` - 获取列表（支持分页：`?page=1&size=20`）
- `POST /api/processing` - 创建记录
- `PUT /api/processing/:id` - 更新记录
- `DELETE /api/processing/:id` - 删除记录

**例子：**
```typescript
// 获取列表
fetch('http://localhost:8080/api/processing?page=1&size=20')

// 创建记录
fetch('http://localhost:8080/api/processing', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ startTime: '...', endTime: '...', ... })
})

// 更新记录
fetch('http://localhost:8080/api/processing/1', {
  method: 'PUT',
  body: JSON.stringify({ status: '已完成' })
})

// 删除记录
fetch('http://localhost:8080/api/processing/1', {
  method: 'DELETE'
})
```

#### 2.4 页面生成方式
**两种方式：**

**1. 代码动态生成（字符串模板）**
- API 文档页面：`ApiDocumentation.ets` 中写 HTML 字符串
- 文件浏览器：`FileBrowserHandler.ets` 中动态生成 HTML
- 状态页面：`ResponseHandler.ets` 中生成 HTML

**代码示例：**
```typescript
// ApiDocumentation.ets
static getApiDocsResponse(): string {
  const htmlContent = `<!DOCTYPE html>
<html>
  <head>...</head>
  <body>...</body>
</html>`;
  return HttpResponseUtils.buildHtmlResponse(htmlContent);
}
```

**2. 从 rawfile 资源读取（静态文件）**
- 静态 HTML 文件放在：`entry/src/main/resources/rawfile/file/`
- 通过 `context.resourceManager.getRawFileContentSync()` 读取

**代码示例：**
```typescript
// FileBrowserHandler.ets
const uint8Array = context.resourceManager.getRawFileContentSync(rawFilePath);
const content = textDecoder.decode(uint8Array);
return HttpResponseUtils.buildHtmlResponse(content);
```

**重要：不是"映射"，是代码生成或资源读取！**

#### 2.5 第三方访问接口
**问题：第三方系统如何访问数据？**

**答案：通过 RESTful API 接口**

**接口列表：**
- `GET /api/processing?page=1&size=20` - 获取数据列表（JSON）
- `POST /api/processing` - 创建数据（JSON Body）
- `PUT /api/processing/:id` - 更新数据（JSON Body）
- `DELETE /api/processing/:id` - 删除数据

**API 文档：**
- 访问 `http://localhost:8080/api/docs` 查看完整文档

---

## 💡 三、常见问题回答模板

### 问题1：你用了 ORM 吗？
**回答：**
"是的，我使用了 IBest-ORM 框架。它可以把数据库表映射成类，我只需要操作对象，不用写 SQL。比如 `db.Create(new User("张三", 25))` 就能自动插入数据。"

### 问题2：事务是怎么实现的？
**回答：**
"我封装了 `executeInTransaction` 方法，可以把多个操作打包成一个事务。如果任何一步失败，全部回滚；如果全部成功，自动提交。比如用户表和权限表同时写入，用事务可以保证要么都成功，要么都失败。"

### 问题3：插入数据是不是很麻烦？
**回答：**
"不麻烦，我已经封装好了。一行代码就能添加数据：`dbManager.addUser("张三", 25)`。所有 CRUD 操作都封装成了函数，使用很简单。"

### 问题4：HTTP 服务器页面是怎么生成的？
**回答：**
"有两种方式：
1. 动态页面（API 文档、文件浏览器）是在代码中通过字符串模板生成的
2. 静态页面（如历史加工数据表.html）是从 rawfile 资源目录读取的，打包在应用中"

### 问题5：第三方如何访问数据？
**回答：**
"通过 RESTful API 接口。我实现了：
- GET /api/processing - 获取列表（支持分页）
- POST /api/processing - 创建记录
- PUT /api/processing/:id - 更新记录
- DELETE /api/processing/:id - 删除记录
所有接口都返回 JSON 格式，支持 JSON Body 传参。API 文档在 /api/docs 页面。"

---

## 📖 四、学习建议

### 1. 先看这些文件（按顺序）
1. `database/models/User.ets` - 理解 ORM 模型定义
2. `database/DatabaseManager.ets` - 理解 CRUD 封装和事务
3. `utils/network/HttpServerHandler.ets` - 理解路由
4. `utils/network/handlers/ProcessingApiHandler.ets` - 理解 API 处理

### 2. 关键代码要理解
- 单例模式：为什么用单例？
- ORM：如何把类映射成表？
- 事务：如何保证一致性？
- 路由：如何根据路径分发请求？
- 页面生成：动态生成 vs 资源读取

### 3. 可以尝试
- 添加一个新的数据表（如 FruitInfo）
- 添加一个新的 API 接口
- 修改页面样式

---

## ✅ 五、检查清单

下次主管问的时候，确保你能回答：

- [ ] 什么是 ORM？我们用的什么框架？
- [ ] 什么是事务？如何保证用户表和权限表同时写入？
- [ ] 如何添加数据？是不是很麻烦？
- [ ] HTTP 服务器页面是怎么生成的？
- [ ] 第三方如何访问数据？有哪些接口？
- [ ] 什么是 RESTful API？
- [ ] 分页功能是怎么实现的？

---

**记住：代码可以改，但理解原理更重要！** 🚀

