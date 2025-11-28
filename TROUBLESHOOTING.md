# 问题排查指南

## 如果遇到性能问题或卡顿

### 方法1：暂时禁用波浪图动画（最快）

编辑 `entry/src/main/ets/pages/home/LiquidCardsArea.ets`，找到 `isWaveAnimationEnabled()` 方法：

```typescript
private isWaveAnimationEnabled(): boolean {
  // 如果出现性能问题，可以暂时改为 false 来禁用波浪图
  return false  // 改为 false 可以禁用波浪图动画
}
```

将 `return true` 改为 `return false`，波浪图动画就会被完全禁用。

### 方法2：查看日志

查看应用日志，定位性能问题：

```bash
# 在终端中运行
hdc hilog | grep "WaveCard"
```

### 常见问题排查

1. **波浪图卡顿**
   - 先尝试方法1禁用波浪图，如果禁用后流畅，说明问题在波浪图
   - 检查是否有多个波浪图同时渲染
   - 检查设备性能是否足够

2. **整体卡顿**
   - 检查是否有其他动画或渲染任务
   - 检查是否有大量数据操作
   - 检查内存使用情况

3. **不确定问题在哪**
   - 先禁用波浪图（方法1）
   - 如果还是卡顿，问题不在波浪图
   - 如果流畅了，问题在波浪图，可以进一步优化

## 性能优化建议

1. **减少同时显示的波浪图数量**
   - 修改 `getWaveCount()` 方法，减少返回的数量

2. **降低动画更新频率**
   - 编辑 `entry/src/main/ets/utils/ui/WavePhaseManager.ets`
   - 增加 `setInterval` 的间隔时间（当前是17ms，约60fps）

3. **简化绘制逻辑**
   - 编辑 `entry/src/main/ets/components/charts/WaveCard.ets`
   - 增加 `drawWave()` 中的 `step` 值，减少绘制点数量

## 需要帮助？

如果以上方法都无法解决问题，请提供：
1. 具体的卡顿现象（什么时候卡顿、卡顿多久）
2. 性能诊断日志
3. 设备信息（型号、系统版本）

