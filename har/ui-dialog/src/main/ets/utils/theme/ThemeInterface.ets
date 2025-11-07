/**
 * 主题接口定义
 * 用于HAR模块的对话框组件主题支持
 */

// 基础主题样式接口
export interface ThemeStyle {
  // 基础颜色
  primary: string
  backgroundColor: string
  surfaceColor: string
  textColor: string
  subTextColor: string
  borderColor: string
}

// 主题管理器接口
export interface IThemeManager {
  getCurrentTheme(): ThemeStyle
}

