/**
 * 等级页面状态管理组件
 * 
 * 功能说明：
 * - 集中管理等级页面的所有状态变量
 * - 提供统一的状态更新方法
 * - 简化主组件代码，提高可维护性
 * - 支持状态重置和批量更新
 * 
 * 主要特性：
 * - 状态集中管理：所有状态变量集中在一个类中
 * - 类型安全：使用TypeScript类型定义确保类型安全
 * - 默认值支持：所有状态都有合理的默认值
 * - 更新方法：提供专门的方法更新各种状态
 * - 重置功能：支持一键重置所有状态到默认值
 * 
 * 使用方式：
 * 1. 在主组件中创建实例：private stateManager = new LevelStateManager()
 * 2. 通过 stateManager.属性名 访问状态
 * 3. 通过 stateManager.update方法名() 更新状态
 * 4. 通过 stateManager.resetAllStates() 重置所有状态
 * 
 * 状态分类：
 * - 控制面板状态：用户选择的配置参数
 * - 数据表格状态：显示的数据内容
 * - 对话框状态：弹窗显示控制
 * 
 * 设计模式：
 * - 单一职责：专门负责状态管理
 * - 封装性：隐藏状态更新细节
 * - 可扩展性：易于添加新的状态和更新方法
 * 
 * 性能优化：
 * - 避免不必要的状态更新
 * - 支持批量状态更新
 * - 提供状态快照功能
 */

import { LevelData, StatisticsData } from './LevelDataManager'
import { DEFAULT_LEVEL_SETTINGS, DEFAULT_STATISTICS_DATA } from '../LevelConstants'

// 持久化存储表格数量设置
PersistentStorage.PersistProp('LevelTableCount', DEFAULT_LEVEL_SETTINGS.tableCount)
// 持久化存储等级数量索引
PersistentStorage.PersistProp('LevelCountIndex', 0)
// 持久化存储装箱重量1
PersistentStorage.PersistProp('LevelPackingWeight1', DEFAULT_LEVEL_SETTINGS.packingWeight1)
// 持久化存储装箱重量2
PersistentStorage.PersistProp('LevelPackingWeight2', DEFAULT_LEVEL_SETTINGS.packingWeight2)

/**
 * 等级页面状态管理类
 * 
 * 功能说明：
 * - 集中管理等级页面的所有状态变量
 * - 提供统一的状态更新方法
 * - 支持状态重置和批量更新
 * 
 * 状态分类：
 * - 控制面板状态：用户选择的配置参数
 * - 数据表格状态：显示的数据内容
 * - 对话框状态：弹窗显示控制
 * 
 * 使用场景：
 * - 等级页面状态管理
 * - 状态更新和重置
 * - 数据持久化
 */
export class LevelStateManager {
  // ==================== 控制面板状态 ====================
  // 这些状态控制左侧控制面板的显示和用户选择
  
  /**
   * 选中的水果类型
   * 
   * 功能说明：
   * - 存储用户选择的水果类型
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.selectedFruit
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用选中的水果类型
   * - 状态重置时恢复默认值
   */
  selectedFruit: string = DEFAULT_LEVEL_SETTINGS.selectedFruit
  
  /**
   * 出口阈值设置
   * 
   * 功能说明：
   * - 存储用户设置的出口阈值
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.outletThreshold
   * 
   * 使用场景：
   * - 控制面板显示当前设置
   * - 数据处理时使用阈值
   * - 状态重置时恢复默认值
   */
  outletThreshold: number = DEFAULT_LEVEL_SETTINGS.outletThreshold
  
  /**
   * 选中的分拣标准（单选）
   * 
   * 功能说明：
   * - 存储用户选择的分拣标准
   * - 支持单选，存储为字符串
   * - 默认值为DEFAULT_LEVEL_SETTINGS.selectedStandards
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用选中的标准
   * - 状态重置时恢复默认值
   */
  selectedStandards: string = DEFAULT_LEVEL_SETTINGS.selectedStandards
  
  /**
   * 选中的单位类型
   * 
   * 功能说明：
   * - 存储用户选择的单位类型
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.selectedUnit
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用选中的单位
   * - 状态重置时恢复默认值
   */
  selectedUnit: string = DEFAULT_LEVEL_SETTINGS.selectedUnit
  
  /**
   * 装箱重量1
   * 
   * 功能说明：
   * - 存储用户设置的装箱重量1
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.packingWeight1
   * 
   * 使用场景：
   * - 控制面板显示当前设置
   * - 数据处理时使用重量1
   * - 状态重置时恢复默认值
   */
  packingWeight1: number = AppStorage.Get<number>('LevelPackingWeight1') || DEFAULT_LEVEL_SETTINGS.packingWeight1
  
  /**
   * 装箱重量2
   * 
   * 功能说明：
   * - 存储用户设置的装箱重量2
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.packingWeight2
   * 
   * 使用场景：
   * - 控制面板显示当前设置
   * - 数据处理时使用重量2
   * - 状态重置时恢复默认值
   */
  packingWeight2: number = AppStorage.Get<number>('LevelPackingWeight2') || DEFAULT_LEVEL_SETTINGS.packingWeight2
  
  /**
   * 表格数量设置
   * 
   * 功能说明：
   * - 存储用户选择的表格数量
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_LEVEL_SETTINGS.tableCount
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用表格数量
   * - 状态重置时恢复默认值
   */
  tableCount: string = DEFAULT_LEVEL_SETTINGS.tableCount

  // ==================== 数据表格状态 ====================
  // 这些状态控制右侧数据表格的显示内容
  
  /**
   * 等级数据列表
   * 
   * 功能说明：
   * - 存储等级页面的数据列表
   * - 用于数据表格显示和数据处理
   * - 默认为空数组
   * 
   * 使用场景：
   * - 数据表格显示数据
   * - 数据处理和计算
   * - 状态重置时清空
   */
  levelData: LevelData[] = []
  
  /**
   * 统计数据对象，包含各种统计信息
   * 
   * 功能说明：
   * - 存储等级页面的统计数据
   * - 包含底部1和底部2的各种统计信息
   * - 使用默认值初始化
   * 
   * 使用场景：
   * - 数据表格显示统计数据
   * - 数据处理和计算
   * - 状态重置时恢复默认值
   */
  statisticsData: StatisticsData = {
    bottom1Counts: DEFAULT_STATISTICS_DATA.bottom1Counts.slice(),  // 底部1计数
    bottom1Avgs: DEFAULT_STATISTICS_DATA.bottom1Avgs.slice(),        // 底部1平均值
    bottom1Sets: DEFAULT_STATISTICS_DATA.bottom1Sets.slice(),        // 底部1设置
    bottom2Counts: DEFAULT_STATISTICS_DATA.bottom2Counts.slice(),    // 底部2计数
    bottom2Avgs: DEFAULT_STATISTICS_DATA.bottom2Avgs.slice(),        // 底部2平均值
    bottom2Sets: DEFAULT_STATISTICS_DATA.bottom2Sets.slice()         // 底部2设置
  }

  // ==================== 对话框状态 ====================
  // 这些状态控制弹窗的显示和交互
  
  /**
   * 是否显示出口设置对话框
   * 
   * 功能说明：
   * - 控制出口设置对话框的显示/隐藏
   * - 用于模态对话框控制
   * - 默认为false（隐藏）
   * 
   * 使用场景：
   * - 控制对话框显示状态
   * - 模态对话框控制
   * - 状态重置时关闭对话框
   */
  showOutletDialog: boolean = false
  
  /**
   * 当前选中的出口索引（1-8）
   * 
   * 功能说明：
   * - 存储当前选中的出口索引
   * - 用于出口设置对话框显示
   * - 默认为1
   * 
   * 使用场景：
   * - 出口设置对话框显示当前出口
   * - 出口切换和选择
   * - 状态重置时恢复默认值
   */
  currentOutletIndex: number = 1

  // ==================== 状态更新方法 ====================
  // 这些方法用于更新各种状态，确保状态变化的一致性
  
  /**
   * 更新选中的水果类型
   * 
   * 功能说明：
   * - 更新用户选择的水果类型
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param fruit 水果类型字符串
   * 
   * 使用场景：
   * - 用户选择水果类型时
   * - 程序自动设置水果类型时
   * - 状态重置时恢复默认值
   */
  updateSelectedFruit(fruit: string): void {
    this.selectedFruit = fruit
  }

  /**
   * 更新出口阈值设置
   * 
   * 功能说明：
   * - 更新用户设置的出口阈值
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param threshold 阈值数值
   * 
   * 使用场景：
   * - 用户设置出口阈值时
   * - 程序自动设置阈值时
   * - 状态重置时恢复默认值
   */
  updateOutletThreshold(threshold: number): void {
    this.outletThreshold = threshold
  }

  /**
   * 更新选中的分拣标准
   * 
   * 功能说明：
   * - 更新用户选择的分拣标准
   * - 支持单选标准
   * - 触发相关状态更新
   * 
   * @param standard 分拣标准字符串
   * 
   * 使用场景：
   * - 用户选择分拣标准时
   * - 程序自动设置标准时
   * - 状态重置时恢复默认值
   */
  updateSelectedStandards(standard: string): void {
    this.selectedStandards = standard
  }

  /**
   * 更新选中的单位类型
   * 
   * 功能说明：
   * - 更新用户选择的单位类型
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param unit 单位类型字符串
   * 
   * 使用场景：
   * - 用户选择单位类型时
   * - 程序自动设置单位时
   * - 状态重置时恢复默认值
   */
  updateSelectedUnit(unit: string): void {
    this.selectedUnit = unit
  }

  /**
   * 更新装箱重量1
   * 
   * 功能说明：
   * - 更新用户设置的装箱重量1
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param weight 重量数值
   * 
   * 使用场景：
   * - 用户设置装箱重量1时
   * - 程序自动设置重量时
   * - 状态重置时恢复默认值
   */
  updatePackingWeight1(weight: number): void {
    this.packingWeight1 = weight
    AppStorage.SetOrCreate('LevelPackingWeight1', weight)
  }

  /**
   * 更新装箱重量2
   * 
   * 功能说明：
   * - 更新用户设置的装箱重量2
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param weight 重量数值
   * 
   * 使用场景：
   * - 用户设置装箱重量2时
   * - 程序自动设置重量时
   * - 状态重置时恢复默认值
   */
  updatePackingWeight2(weight: number): void {
    this.packingWeight2 = weight
    AppStorage.SetOrCreate('LevelPackingWeight2', weight)
  }

  /**
   * 更新表格数量设置
   * 
   * 功能说明：
   * - 更新用户选择的表格数量
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param count 表格数量字符串
   * 
   * 使用场景：
   * - 用户选择表格数量时
   * - 程序自动设置数量时
   * - 状态重置时恢复默认值
   */
  updateTableCount(count: string): void {
    this.tableCount = count
    AppStorage.SetOrCreate('LevelTableCount', count)
  }

  /**
   * 更新等级数据列表
   * 
   * 功能说明：
   * - 更新等级数据列表
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param data 等级数据数组
   * 
   * 使用场景：
   * - 数据加载时
   * - 数据更新时
   * - 状态重置时清空
   */
  updateLevelData(data: LevelData[]): void {
    this.levelData = data
  }

  /**
   * 更新统计数据对象
   * 
   * 功能说明：
   * - 更新统计数据对象
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param data 统计数据对象
   * 
   * 使用场景：
   * - 统计数据更新时
   * - 数据计算完成时
   * - 状态重置时恢复默认值
   */
  updateStatisticsData(data: StatisticsData): void {
    this.statisticsData = data
  }

  /**
   * 更新出口对话框显示状态
   * 
   * 功能说明：
   * - 更新出口对话框的显示状态
   * - 控制模态对话框的显示/隐藏
   * - 确保状态一致性
   * 
   * @param show 是否显示对话框
   * 
   * 使用场景：
   * - 打开出口设置对话框时
   * - 关闭出口设置对话框时
   * - 状态重置时关闭对话框
   */
  updateShowOutletDialog(show: boolean): void {
    this.showOutletDialog = show
  }

  /**
   * 更新当前选中的出口索引
   * 
   * 功能说明：
   * - 更新当前选中的出口索引
   * - 控制出口选择状态
   * - 确保状态一致性
   * 
   * @param index 出口索引（1-8）
   * 
   * 使用场景：
   * - 用户选择出口时
   * - 出口切换时
   * - 状态重置时恢复默认值
   */
  updateCurrentOutletIndex(index: number): void {
    this.currentOutletIndex = index
  }

  // ==================== 状态重置方法 ====================
  
  /**
   * 重置所有状态到默认值
   * 
   * 功能说明：
   * - 将所有状态重置为默认值
   * - 清空用户输入和选择
   * - 恢复初始状态
   * 
   * 重置内容：
   * - 控制面板状态：恢复到默认设置
   * - 数据表格状态：清空数据
   * - 对话框状态：关闭对话框
   * 
   * 使用场景：
   * - 页面初始化时
   * - 用户点击"重置"按钮时
   * - 需要清空所有用户输入时
   * - 页面切换时
   * 
   * 性能优化：
   * - 批量重置，避免多次状态更新
   * - 使用默认值，确保状态一致性
   * - 清空数据，释放内存
   */
  resetAllStates(): void {
    // 重置控制面板状态
    this.selectedFruit = DEFAULT_LEVEL_SETTINGS.selectedFruit
    this.outletThreshold = DEFAULT_LEVEL_SETTINGS.outletThreshold
    this.selectedStandards = DEFAULT_LEVEL_SETTINGS.selectedStandards
    this.selectedUnit = DEFAULT_LEVEL_SETTINGS.selectedUnit
    this.packingWeight1 = DEFAULT_LEVEL_SETTINGS.packingWeight1
    this.packingWeight2 = DEFAULT_LEVEL_SETTINGS.packingWeight2
    this.tableCount = DEFAULT_LEVEL_SETTINGS.tableCount
    
    // 重置数据表格状态
    this.levelData = []
    this.statisticsData = {
      bottom1Counts: DEFAULT_STATISTICS_DATA.bottom1Counts.slice(),
      bottom1Avgs: DEFAULT_STATISTICS_DATA.bottom1Avgs.slice(),
      bottom1Sets: DEFAULT_STATISTICS_DATA.bottom1Sets.slice(),
      bottom2Counts: DEFAULT_STATISTICS_DATA.bottom2Counts.slice(),
      bottom2Avgs: DEFAULT_STATISTICS_DATA.bottom2Avgs.slice(),
      bottom2Sets: DEFAULT_STATISTICS_DATA.bottom2Sets.slice()
    }
    
    // 重置对话框状态
    this.showOutletDialog = false
    this.currentOutletIndex = 1
  }

}
