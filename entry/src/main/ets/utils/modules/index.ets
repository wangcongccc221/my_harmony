/**
 * 模块化索引文件
 * 功能：统一导出所有模块化组件
 * 用途：简化模块导入，提供统一的API入口
 */

// 拖拽相关模块
export { DragManager, DragHandlers, DragData, MultiSelectDragData, DragStatus, DragResult, DRAG_STORAGE_KEYS } from '../drag/DragManager'
export { DragHandlers as DragHandlersClass } from '../drag/DragHandlers'

// 波浪动画相关模块
export { WaveConfigManager, WaveConfig } from '../animation/WaveConfig'

// 卡片数据相关模块
export { CardDataManager } from '../card/CardDataManager'

// 主题相关模块
export { ThemeUtils } from '../theme/ThemeUtils'

// 使用示例
export { ModuleUsageExample } from './ModuleUsageExample'

/**
 * 模块化工具类
 * 提供快速访问所有模块的便捷方法
 */
export class ModularUtils {
  private static instance: ModularUtils

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ModularUtils {
    if (!ModularUtils.instance) {
      ModularUtils.instance = new ModularUtils()
    }
    return ModularUtils.instance
  }

  /**
   * 获取拖拽管理器
   */
  public getDragManager(): DragManager {
    return DragManager.getInstance()
  }

  /**
   * 获取拖拽处理器
   */
  public getDragHandlers(): DragHandlers {
    return new DragHandlers()
  }

  /**
   * 获取波浪配置管理器
   */
  public getWaveConfigManager(): WaveConfigManager {
    return WaveConfigManager.getInstance()
  }

  /**
   * 获取卡片数据管理器
   */
  public getCardDataManager(): CardDataManager {
    return CardDataManager.getInstance()
  }

  /**
   * 获取主题工具
   */
  public getThemeUtils(): ThemeUtils {
    return ThemeUtils.getInstance()
  }

  /**
   * 获取使用示例
   */
  public getUsageExample(): ModuleUsageExample {
    return new ModuleUsageExample()
  }
}
