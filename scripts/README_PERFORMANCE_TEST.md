# 压力测试脚本使用说明

## 安装依赖

```bash
pip install requests
```

## 使用方法

### 1. 基础测试（100请求，10并发）

```bash
python scripts/performance_test.py
```

### 2. 自定义参数

```bash
# 1000个请求，50并发
python scripts/performance_test.py --requests 1000 --concurrency 50

# 只测试查询接口
python scripts/performance_test.py --test query --requests 500 --concurrency 20

# 只测试插入接口
python scripts/performance_test.py --test insert --requests 200 --concurrency 10

# 指定服务器地址
python scripts/performance_test.py --url http://192.168.1.100:8080
```

### 3. 测试所有接口

```bash
python scripts/performance_test.py --test all --requests 200 --concurrency 20
```

## 多人 CRUD 压测脚本 (`db_crud_benchmark.py`)

这个脚本会模拟多名用户同时执行 Query/Insert/Update/Delete，并分别统计每类操作的耗时分布。

### 1. 快速运行

```bash
python scripts/db_crud_benchmark.py
```

默认配置：20 个并发用户，每人 50 次操作，操作占比 `query=50%, insert=20%, update=15%, delete=15%`，并会在压测前自动插入 20 条数据用于更新/删除。

### 2. 自定义参数

```bash
# 40 个用户，每人 80 次操作，增加查询占比
python scripts/db_crud_benchmark.py \
  --workers 40 \
  --ops-per-worker 80 \
  --mix query=60,insert=20,update=10,delete=10

# 指定服务器地址，并跳过预热
python scripts/db_crud_benchmark.py \
  --url http://192.168.1.100:8080 \
  --warmup 0
```

### 3. 输出指标

- **整体 QPS**：所有 CRUD 操作合计的吞吐
- **每类操作的成功/失败次数**
- **单类操作的耗时分布**：min / avg / median / p90 / p95 / p99 / max / std

可以直观看到“单次 CRUD 的耗时”与“多人同时 CRUD 的性能差异”。

## 输出说明

脚本会输出以下性能指标：

- **总请求数**: 发送的请求总数
- **并发数**: 同时发送的请求数
- **成功数/失败数**: 成功和失败的请求数量
- **成功率**: 成功请求的百分比
- **总耗时**: 所有请求完成的总时间（秒）
- **QPS**: 每秒处理的请求数（Queries Per Second）
- **响应时间统计**:
  - 最小延迟: 最快响应时间
  - 最大延迟: 最慢响应时间
  - 平均延迟: 平均响应时间
  - 中位数: 50%的请求响应时间
  - P95延迟: 95%的请求在这个时间内完成
  - P99延迟: 99%的请求在这个时间内完成
  - 标准差: 响应时间的波动程度

## 测试报告

测试结果会自动保存到 JSON 文件：`performance_report_YYYYMMDD_HHMMSS.json`

## 推荐测试场景

### 场景1: 轻量级测试
```bash
python scripts/performance_test.py --requests 100 --concurrency 10 --test query
```

### 场景2: 中等压力测试
```bash
python scripts/performance_test.py --requests 500 --concurrency 20 --test all
```

### 场景3: 高并发测试
```bash
python scripts/performance_test.py --requests 1000 --concurrency 50 --test query
```

### 场景4: 极限压力测试
```bash
python scripts/performance_test.py --requests 5000 --concurrency 100 --test query
```

### 场景5: 多人 CRUD 真实模拟
```bash
python scripts/db_crud_benchmark.py --workers 30 --ops-per-worker 100 --mix query=40,insert=30,update=15,delete=15
```

## 注意事项

1. **端口映射**: 如果设备IP不是localhost，需要先执行端口映射：
   ```bash
   hdc fport tcp:8080 tcp:8080
   ```

2. **更新/删除测试**: 更新和删除接口需要先有数据，建议先运行插入测试

3. **并发数建议**: 
   - 查询接口: 可以设置较高并发（50-100）
   - 插入接口: 建议较低并发（10-20），避免数据库锁竞争
   - 更新/删除: 建议较低并发（5-10）

4. **观察指标**:
   - QPS 越高越好
   - 平均延迟越低越好
   - P99延迟应该控制在合理范围内（如 < 500ms）
   - 成功率应该接近 100%

