/**
 * 主题管理器
 * 功能：管理应用的主题切换和主题配置
 * 用途：统一管理应用的外观风格，支持主题切换
 */

// 主题类型枚举
export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark'
}

// 颜色配置接口
export interface ColorConfig {
  primary: string
  secondary: string
  accent: string
  background: string
  surface: string
  text: string
  subtext: string
  border: string
  header: string
}

// 阴影配置接口
export interface ShadowConfig {
  radius: number
  color: string
  offsetX: number
  offsetY: number
}

// 字体配置接口
export interface FontConfig {
  title: number
  subtitle: number
  body: number
  caption: number
}

// 主题配置接口
export interface ThemeConfig {
  name: string
  colors: ColorConfig
  borderRadius: number
  shadow: ShadowConfig
  fonts: FontConfig
}

// 浅色主题配置
const LIGHT_THEME: ThemeConfig = {
  name: "浅色主题",
  colors: {
    primary: "#007AFF",
    secondary: "#34C759",
    accent: "#FF9500",
    background: "#F2F2F7",
    surface: "#FFFFFF",
    text: "#1C1C1E",
    subtext: "#8E8E93",
    border: "#C6C6C8",
    header: "#000000"
  } as ColorConfig,
  borderRadius: 12,
  shadow: {
    radius: 8,
    color: "#00000020",
    offsetX: 0,
    offsetY: 2
  } as ShadowConfig,
  fonts: {
    title: 24,
    subtitle: 18,
    body: 16,
    caption: 12
  } as FontConfig
}

// 深色主题配置
const DARK_THEME: ThemeConfig = {
  name: "深色主题",
  colors: {
    primary: "#0A84FF",
    secondary: "#30D158",
    accent: "#FF9F0A",
    background: "#000000",
    surface: "#1C1C1E",
    text: "#FFFFFF",
    subtext: "#8E8E93",
    border: "#38383A",
    header: "#1C1C1E"
  } as ColorConfig,
  borderRadius: 12,
  shadow: {
    radius: 8,
    color: "#FFFFFF10",
    offsetX: 0,
    offsetY: 2
  } as ShadowConfig,
  fonts: {
    title: 24,
    subtitle: 18,
    body: 16,
    caption: 12
  } as FontConfig
}

// 主题配置数据
const THEME_CONFIGS: Record<ThemeType, ThemeConfig> = {
  [ThemeType.LIGHT]: LIGHT_THEME,
  [ThemeType.DARK]: DARK_THEME
}

// 主题管理器类
export class ThemeManager {
  private static instance: ThemeManager
  private currentTheme: ThemeType = ThemeType.LIGHT
  
  // 单例模式
  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager()
    }
    return ThemeManager.instance
  }
  
  // 获取当前主题配置
  getCurrentTheme(): ThemeConfig {
    return THEME_CONFIGS[this.currentTheme]
  }
  
  // 获取当前主题类型
  getCurrentThemeType(): ThemeType {
    return this.currentTheme
  }
  
  // 设置主题
  setTheme(theme: ThemeType): void {
    this.currentTheme = theme
    // 这里可以添加主题切换的通知机制
    console.log(`主题已切换到: ${THEME_CONFIGS[theme].name}`)
  }
  
  // 切换主题（在浅色和深色之间切换）
  toggleTheme(): void {
    this.currentTheme = this.currentTheme === ThemeType.LIGHT 
      ? ThemeType.DARK 
      : ThemeType.LIGHT
    console.log(`主题已切换到: ${THEME_CONFIGS[this.currentTheme].name}`)
  }
  
  // 获取所有可用主题
  getAllThemes(): Record<ThemeType, ThemeConfig> {
    return THEME_CONFIGS
  }
}
