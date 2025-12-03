# 服务层使用指南

## 📋 概述

本项目的服务层基于 **`DatabaseQueueManager`** 构建，提供了三个专用的业务服务类：

- **`FruitInfoService`** - 水果信息服务 (`tb_fruitinfo`)
- **`GradeInfoService`** - 等级信息服务 (`tb_gradeinfo`)
- **`ExportInfoService`** - 导出信息服务 (`tb_exportinfo`)

## ✨ 核心优势

### 1. **性能优化**
- ✅ 使用**并发队列**处理查询操作（提高查询性能）
- ✅ 使用**串行队列**处理写入操作（避免并发写入冲突）
- ✅ 使用 **`queryByCondition`** 进行条件查询（数据库级别过滤，避免全量查询后内存过滤）

### 2. **自动化处理**
- ✅ 自动添加 `created_at` 和 `updated_at` 时间戳
- ✅ 自动进行数据验证和默认值设置
- ✅ 自动记录操作日志（hilog）

### 3. **类型安全**
- ✅ 使用 TypeScript 类型系统
- ✅ 基于 ORM 模型类（`FruitInfo`, `GradeInfo`, `ExportInfo`）

## 📖 使用示例

### 1. FruitInfoService - 水果信息服务

```typescript
import { FruitInfoService } from './services';
import { Context } from '@kit.AbilityKit';

// 保存单条水果信息
async function saveFruitInfo(ctx: Context) {
  const id = await FruitInfoService.save(ctx, {
    FruitName: '苹果',
    CustomerName: '客户A',
    FarmName: '农场1',
    BatchWeight: 100.5,
    BatchNumber: 1000,
    SortType: 1,
    StartTime: new Date().toISOString(),
  });
  console.log(`保存成功，ID: ${id}`);
}

// 批量保存水果信息
async function batchSaveFruitInfo(ctx: Context) {
  const dataList = [
    { FruitName: '苹果', BatchWeight: 100.5, SortType: 1 },
    { FruitName: '香蕉', BatchWeight: 80.3, SortType: 2 },
    { FruitName: '橙子', BatchWeight: 120.7, SortType: 1 },
  ];
  const count = await FruitInfoService.batchSave(ctx, dataList);
  console.log(`批量保存成功，数量: ${count}`);
}

// 查询所有水果信息
async function queryAllFruits(ctx: Context) {
  const list = await FruitInfoService.queryAll(ctx);
  return list;
}

// 分页查询水果信息
async function queryFruitsPage(ctx: Context, page: number, size: number) {
  const list = await FruitInfoService.queryPage(ctx, page, size);
  return list;
}

// 统计水果信息总数
async function countFruits(ctx: Context) {
  const total = await FruitInfoService.count(ctx);
  return total;
}

// 更新水果信息
async function updateFruitInfo(ctx: Context, id: number) {
  const affected = await FruitInfoService.update(ctx, id, {
    FruitName: '新苹果',
    BatchWeight: 150.5
  });
  console.log(`更新成功，影响行数: ${affected}`);
}

// 删除水果信息
async function deleteFruitInfo(ctx: Context, id: number) {
  const affected = await FruitInfoService.delete(ctx, id);
  console.log(`删除成功，影响行数: ${affected}`);
}
```

#### FruitInfoService 方法列表

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `save` | `ctx, data` | `Promise<number>` | 保存单条记录，返回ID |
| `batchSave` | `ctx, dataList` | `Promise<number>` | 批量保存，返回插入数量 |
| `update` | `ctx, id, data` | `Promise<number>` | 更新记录，返回影响行数 |
| `delete` | `ctx, id` | `Promise<number>` | 删除记录，返回影响行数 |
| `queryAll` | `ctx` | `Promise<FruitInfo[]>` | 查询所有记录 |
| `queryPage` | `ctx, page, size` | `Promise<FruitInfo[]>` | 分页查询 |
| `count` | `ctx` | `Promise<number>` | 统计总数 |

---

### 2. GradeInfoService - 等级信息服务

```typescript
import { GradeInfoService } from './services';

// 保存单条等级信息
async function saveGradeInfo(ctx: Context) {
  const id = await GradeInfoService.save(ctx, {
    CustomerID: 1,
    ChannelID: 2,
    QualityIndex: 1,
    SizeID: 3,
    SizeIndex: 1,
    BoxNumber: 100,
    FruitNumber: 500,
    FruitWeight: 250.5,
    FPrice: 10.5,
    GradeID: 1,
    QualityName: 'A级',
    WeightOrSizeName: '大果',
  });
  console.log(`保存成功，ID: ${id}`);
}

// 批量保存等级信息
async function batchSaveGradeInfo(ctx: Context) {
  const dataList = [
    { CustomerID: 1, ChannelID: 1, QualityName: 'A级', GradeID: 1 },
    { CustomerID: 1, ChannelID: 2, QualityName: 'B级', GradeID: 2 },
    { CustomerID: 2, ChannelID: 1, QualityName: 'A级', GradeID: 1 },
  ];
  const count = await GradeInfoService.batchSave(ctx, dataList);
  console.log(`批量保存成功，数量: ${count}`);
}

// 查询所有等级信息
async function queryAllGrades(ctx: Context) {
  const list = await GradeInfoService.queryAll(ctx);
  return list;
}

// 根据客户ID查询等级信息（数据库级别条件查询）
async function queryGradesByCustomer(ctx: Context, customerId: number) {
  const list = await GradeInfoService.queryByCustomerId(ctx, customerId);
  console.log(`客户 ${customerId} 有 ${list.length} 条等级信息`);
  return list;
}
```

#### GradeInfoService 方法列表

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `save` | `ctx, data` | `Promise<number>` | 保存单条记录，返回ID |
| `batchSave` | `ctx, dataList` | `Promise<number>` | 批量保存，返回插入数量 |
| `update` | `ctx, id, data` | `Promise<number>` | 更新记录，返回影响行数 |
| `delete` | `ctx, id` | `Promise<number>` | 删除记录，返回影响行数 |
| `queryAll` | `ctx` | `Promise<GradeInfo[]>` | 查询所有记录 |
| `queryPage` | `ctx, page, size` | `Promise<GradeInfo[]>` | 分页查询 |
| `count` | `ctx` | `Promise<number>` | 统计总数 |
| `queryByCustomerId` | `ctx, customerId` | `Promise<GradeInfo[]>` | 根据客户ID查询 |

---

### 3. ExportInfoService - 导出信息服务

```typescript
import { ExportInfoService } from './services';

// 保存单条导出信息
async function saveExportInfo(ctx: Context) {
  const id = await ExportInfoService.save(ctx, {
    CustomerID: 1,
    ChannelID: 2,
    ExportID: 100,
    FruitNumber: 500,
    FruitWeight: 250.5,
    BoxNumber: 10,
    ExitName: '出口A',
  });
  console.log(`保存成功，ID: ${id}`);
}

// 批量保存导出信息
async function batchSaveExportInfo(ctx: Context) {
  const dataList = [
    { CustomerID: 1, ChannelID: 1, ExportID: 100, ExitName: '出口A' },
    { CustomerID: 1, ChannelID: 2, ExportID: 101, ExitName: '出口B' },
    { CustomerID: 2, ChannelID: 1, ExportID: 102, ExitName: '出口C' },
  ];
  const count = await ExportInfoService.batchSave(ctx, dataList);
  console.log(`批量保存成功，数量: ${count}`);
}

// 查询所有导出信息
async function queryAllExports(ctx: Context) {
  const list = await ExportInfoService.queryAll(ctx);
  return list;
}

// 根据客户ID查询导出信息
async function queryExportsByCustomer(ctx: Context, customerId: number) {
  const list = await ExportInfoService.queryByCustomerId(ctx, customerId);
  return list;
}

// 根据导出ID查询
async function queryExportsByExportId(ctx: Context, exportId: number) {
  const list = await ExportInfoService.queryByExportId(ctx, exportId);
  return list;
}

// 根据通道ID查询
async function queryExportsByChannel(ctx: Context, channelId: number) {
  const list = await ExportInfoService.queryByChannelId(ctx, channelId);
  return list;
}
```

#### ExportInfoService 方法列表

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `save` | `ctx, data` | `Promise<number>` | 保存单条记录，返回ID |
| `batchSave` | `ctx, dataList` | `Promise<number>` | 批量保存，返回插入数量 |
| `update` | `ctx, id, data` | `Promise<number>` | 更新记录，返回影响行数 |
| `delete` | `ctx, id` | `Promise<number>` | 删除记录，返回影响行数 |
| `queryAll` | `ctx` | `Promise<ExportInfo[]>` | 查询所有记录 |
| `queryPage` | `ctx, page, size` | `Promise<ExportInfo[]>` | 分页查询 |
| `count` | `ctx` | `Promise<number>` | 统计总数 |
| `queryByCustomerId` | `ctx, customerId` | `Promise<ExportInfo[]>` | 根据客户ID查询 |
| `queryByExportId` | `ctx, exportId` | `Promise<ExportInfo[]>` | 根据导出ID查询 |
| `queryByChannelId` | `ctx, channelId` | `Promise<ExportInfo[]>` | 根据通道ID查询 |

---

## 🔧 在 HTTP API 中使用

如果需要提供外部 HTTP 接口，可以在 Handler 中调用这些服务：

```typescript
import { FruitInfoService, GradeInfoService, ExportInfoService } from '../../../services';

/**
 * 处理保存水果信息的 HTTP 请求
 */
private static async handleSaveFruitInfo(body: string, ctx?: Context): Promise<string> {
  try {
    if (!ctx) {
      return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
    }
    
    const data = JSON.parse(body);
    const id = await FruitInfoService.save(ctx, data);
    
    return HttpResponseUtils.buildSuccessResponse({ id }, '保存成功');
  } catch (error) {
    return HttpResponseUtils.buildErrorResponse('保存失败', 500);
  }
}

/**
 * 处理批量保存的 HTTP 请求
 */
private static async handleBatchSave(body: string, ctx?: Context): Promise<string> {
  try {
    if (!ctx) {
      return HttpResponseUtils.buildErrorResponse('Context 未提供', 500);
    }
    
    const dataList = JSON.parse(body);
    const count = await FruitInfoService.batchSave(ctx, dataList);
    
    return HttpResponseUtils.buildSuccessResponse({ count }, `批量保存成功，共 ${count} 条`);
  } catch (error) {
    return HttpResponseUtils.buildErrorResponse('批量保存失败', 500);
  }
}
```

---

## 📌 注意事项

### 1. **数据验证**
各服务会自动验证和设置默认值：

| 服务 | 自动设置的默认值 |
|------|------------------|
| `FruitInfoService` | `SortType = 0` |
| `GradeInfoService` | `CustomerID`, `ChannelID`, `QualityIndex`, `SizeID`, `SizeIndex`, `BoxNumber`, `FruitNumber`, `FruitWeight`, `FPrice`, `GradeID` 均为 `0` |
| `ExportInfoService` | `CustomerID`, `ChannelID`, `ExportID` 均为 `0` |

### 2. **业务规则验证**
- 批次重量/水果重量不能为负数
- 批次数量/水果数量不能为负数
- 箱重/箱数不能为负数
- 价格不能为负数

### 3. **时间戳**
- `created_at` 和 `updated_at` 会自动添加
- 更新操作会自动更新 `updated_at`

### 4. **性能**
- 查询操作使用并发队列，性能更好
- 写入操作使用串行队列，保证数据一致性
- `queryByXxx` 方法使用 `queryByCondition` 进行数据库级别过滤

---

## 🎯 总结

### ✅ 推荐做法
1. **内部调用**: 使用 `FruitInfoService`、`GradeInfoService`、`ExportInfoService`
2. **外部 API**: 在 HTTP Handler 中调用服务层
3. **直接操作**: 如需更底层控制，可使用 `DatabaseQueueManager`

### ❌ 不推荐
- 直接在 UI 或 HTTP Handler 中调用 `DatabaseHelper`
- 绕过服务层直接操作数据库

---

## 📁 文件结构

```
entry/src/main/ets/
├── services/
│   ├── index.ets              # 统一导出
│   ├── FruitInfoService.ets   # 水果信息服务
│   ├── GradeInfoService.ets   # 等级信息服务
│   ├── ExportInfoService.ets  # 导出信息服务
│   └── README.md              # 本文档
├── utils/network/database/
│   └── dispatch/
│       └── DatabaseQueueManager.ets  # 底层队列管理器
└── database/
    ├── DatabaseHelper.ets     # 数据库抽象层
    └── models/
        ├── FruitInfo.ets      # 水果信息模型
        ├── GradeInfo.ets      # 等级信息模型
        └── ExportInfo.ets     # 导出信息模型
```

---

**更新时间**: 2025-12-03  
**版本**: v2.0
