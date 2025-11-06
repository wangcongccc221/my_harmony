# 测试运行说明

## 保留的测试

1. **K6 极限测试** - `k6-load-test-extreme.js`（8000并发，约1小时）
2. **Playwright 稳定性测试** - `tests/database-stability.spec.ts`（1200条记录，约1小时）

## 运行 K6 极限测试

### 1. 安装 K6（如果还没安装）

**Windows:**
```bash
# 使用 Chocolatey
choco install k6

# 或使用 Scoop
scoop install k6

# 或使用 npm
npm install -g k6
```

### 2. 运行测试

```bash
cd playwright-tests

# 运行 K6 极限测试（8000并发，约1小时）
k6 run k6-load-test-extreme.js
```

## 运行 Playwright 稳定性测试

### 1. 安装依赖（如果还没安装）

```bash
cd playwright-tests
npm install
```

### 2. 安装浏览器（首次运行需要）

```bash
npx playwright install
```

### 3. 运行测试

```bash
cd playwright-tests

# 运行长时间稳定性测试（1200条记录，约1小时）
npx playwright test -g "长时间稳定性测试"

# 或者运行所有测试
npx playwright test
```

## 测试说明

### K6 极限测试
- **并发数**: 最高 1000 个虚拟用户（已降低，避免服务器崩溃）
- **测试时长**: 约 60 分钟
- **测试内容**: 模拟高并发请求，测试数据库稳定性

### Playwright 稳定性测试
- **测试记录**: 1200 条数据
- **测试时长**: 约 60 分钟（每3秒一条记录）
- **测试内容**: 模拟用户持续添加数据，测试数据库稳定性

## 注意事项

1. **确保服务器运行**: 测试前确保 HTTP 服务器在 `http://127.0.0.1:8080` 上运行
2. **测试时间**: 两个测试都需要约1小时，可以在吃饭时运行
3. **查看结果**: 测试完成后会显示详细的统计信息

## 快速运行（两个测试一起）

如果你想同时运行两个测试（在不同终端）：

**终端1（K6）:**
```bash
cd playwright-tests
k6 run k6-load-test-extreme.js
```

**终端2（Playwright）:**
```bash
cd playwright-tests
npx playwright test -g "长时间稳定性测试"
```

