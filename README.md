# HarmonyOS 加工管理系统

## 项目概述

这是一个基于HarmonyOS开发的加工管理系统，提供完整的数据管理、HTTP服务和用户界面功能。系统支持加工历史数据的存储、查询、修改和删除，并通过RESTful API接口提供数据访问能力。

### 主要功能

- **加工历史管理**：记录和管理加工过程的详细信息
- **数据持久化**：使用关系型数据库存储结构化数据
- **HTTP服务**：内置轻量级HTTP服务器，提供RESTful API接口
- **文件浏览**：支持应用内文件资源的访问和浏览
- **数据可视化**：提供图表展示功能，直观呈现数据统计信息

### 技术栈

- **开发语言**：TypeScript (ArkTS)
- **开发框架**：HarmonyOS SDK
- **ORM框架**：@ibestservices/ibest-orm
- **UI组件库**：
  - @wuba58/omni-ui
  - @ibestservices/ibest-ui
  - @mcui/mccharts
- **测试框架**：@ohos/hypium, @ohos/hamock
- **网络实现**：基于NetworkKit TCP Socket

## 快速开始

### 运行应用

1. 在DevEco Studio中选择目标设备（模拟器或真机）
2. 点击运行按钮或使用快捷键Shift+F10启动应用

### 启动HTTP服务器

HTTP服务器会在应用启动时自动初始化，默认监听端口可在配置中修改。在`EntryAbility.ets`中可以找到服务器初始化相关代码。

在主机上映射模拟器端口：hdc fport tcp:8080 tcp:8080

```typescript
// 启动HTTP服务器示例
import { startHttpServer } from './utils/network/http/HttpServer';
import { HttpServerHandler } from './utils/network/http/HttpServerHandler';

// 在应用启动时初始化
onCreate(want, launchParam) {
  // 设置文件浏览基础路径
  HttpServerHandler.setFileBasePath(this.context);
  
  // 启动HTTP服务器
  startHttpServer(8080).then(() => {
    console.info('HTTP服务器启动成功');
  }).catch((error) => {
    console.error('HTTP服务器启动失败:', error);
  });
}
```

## 核心功能

### 数据库管理

系统使用关系型数据库存储数据，通过ORM框架提供便捷的数据访问接口。

#### 主要数据模型

1. **ProcessingHistory** - 加工历史记录
   - 客户名称、农场名称、水果名称
   - 开始时间、结束时间、状态
   - 重量、数量等关键信息

2. **User** - 用户信息

3. **TestModel** - 测试数据模型

#### 数据库初始化

数据库在应用启动时自动初始化，包括表结构创建和迁移：

```typescript
// 数据库初始化示例
const dbManager = DatabaseManager.getInstance();
await dbManager.initDatabase(); // 自动创建和迁移表结构
```

### HTTP接口

系统提供完整的RESTful API接口，用于数据访问和操作。

#### 状态检查接口

- **GET /api/status**
  - 功能：检查HTTP服务器运行状态
  - 响应：返回服务器状态信息和时间戳

#### 加工历史API

- **GET /api/processing**
  - 功能：获取加工历史列表，支持分页
  - 参数：page（页码）、size（每页条数）
  - 响应：返回加工记录列表和分页信息

- **POST /api/processing**
  - 功能：创建新的加工记录
  - 请求体：包含加工记录的详细信息
  - 响应：返回操作结果和更新后的记录列表

- **PUT /api/processing/:id**
  - 功能：更新指定ID的加工记录
  - 路径参数：记录ID
  - 请求体：要更新的字段信息
  - 响应：返回操作结果和更新后的记录列表

- **DELETE /api/processing/:id**
  - 功能：删除指定ID的加工记录
  - 路径参数：记录ID
  - 响应：返回操作结果和更新后的记录列表

## 关键文件位置

### 应用核心结构

- **entry/src/main/ets/entryability/EntryAbility.ets** - 应用入口能力
- **entry/src/main/ets/pages/** - 页面组件目录
  - **Home.ets** - 首页
  - **history/** - 历史记录相关页面
  - **realtime/** - 实时监控相关页面

### 数据库相关

- **entry/src/main/ets/database/DatabaseManager.ets** - 数据库管理类
- **entry/src/main/ets/database/models/** - 数据模型定义
  - **ProcessingHistory.ets** - 加工历史模型
  - **User.ets** - 用户模型

### HTTP服务器相关

- **entry/src/main/ets/utils/network/http/HttpServer.ets** - HTTP服务器核心实现
- **entry/src/main/ets/utils/network/http/HttpServerHandler.ets** - 路由处理器
- **entry/src/main/ets/utils/network/http/handlers/ProcessingApiHandler.ets** - 加工数据API处理器

### UI组件

- **entry/src/main/ets/components/** - 公共组件目录
  - **charts/** - 图表组件
  - **common/** - 通用UI组件

## 测试验证

### 单元测试

系统使用HarmonyOS的测试框架进行单元测试：

```bash
# 运行单元测试
hvigor test
```

### API接口测试

可以使用以下方法测试HTTP接口：

1. **使用浏览器访问**：直接在浏览器中访问API接口
   ```
   http://[设备IP]:8080/api/status
   ```

2. **使用curl命令**：
   ```bash
   curl http://[设备IP]:8080/api/processing?page=1&size=20
   ```

3. **使用Postman等工具**：发送HTTP请求并查看响应

### 功能验证

1. **数据库功能验证**：
   - 检查数据库是否正确创建
   - 验证数据增删改查操作

2. **HTTP服务验证**：
   - 确认服务器正常启动
   - 验证各API接口响应是否正确
   - 测试错误处理和边界情况

## 版本信息

- **版本**：1.0.0


---

如需更多详细信息，请参考项目中的具体文档：
- HTTP服务器详细文档：HTTP服务器文档.md
- 数据库设计文档：数据库文档.md