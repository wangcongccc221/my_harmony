/**
 * 主题工具函数
 * 功能：提供统一的主题获取方法，减少重复代码
 * 用途：替代每个组件中重复的 BaseComponentHelper 实例化
 */

import { OmniThemeManager, ExtendedOmniThemeStyle, OmniThemeType } from './OmniThemeManager'

/**
 * 获取当前主题配置
 * 直接调用主题管理器，无需创建 BaseComponentHelper 实例
 * @param consumedTheme 可选的主题样式，如果提供则优先使用
 */
export function getCurrentTheme(consumedTheme?: ExtendedOmniThemeStyle): ExtendedOmniThemeStyle {
  return consumedTheme ?? OmniThemeManager.getInstance().getCurrentTheme()
}

/**
 * 获取当前主题类型
 */
export function getCurrentThemeType(): OmniThemeType {
  return OmniThemeManager.getInstance().getCurrentThemeType()
}

/**
 * 获取主题管理器实例
 */
export function getThemeManager(): OmniThemeManager {
  return OmniThemeManager.getInstance()
}
