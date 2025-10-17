/**
 * 卡片颜色系统
 * 功能：为卡片提供独立的配色方案，与主题色形成强烈对比
 * 用途：确保卡片内容清晰可读，避免与主题色混淆
 */

import { ExtendedOmniThemeStyle } from './OmniThemeManager'

// 卡片颜色配置接口
export interface CardColorConfig {
  // 第一层颜色（图标+标题+状态）
  firstLayerBg: string
  firstLayerText: string
  firstLayerIcon: string
  
  // 第二层颜色（序列号+百分比+数值）
  secondLayerBg: string
  secondLayerText: string
  secondLayerValue: string
  
  // 第三层颜色（波形图区域）
  thirdLayerBg: string
  thirdLayerText: string
  
  // 卡片边框和阴影
  cardBorder: string
  cardShadow: string
  
  // 主题相关颜色（新增）
  cardNumberText: string           // 卡片序号文字颜色
  wavePercentText: string          // 波浪百分比文字颜色
  dataListText: string             // 数据列表文字颜色
  waveGradientLeft: string         // 波浪渐变左色
  waveGradientMid: string          // 波浪渐变中间色
  waveGradientRight: string        // 波浪渐变右色
}

// 默认卡片配色方案 - 黑色边框 + 白色字体
export const DEFAULT_CARD_COLORS: CardColorConfig = {
  // 第一层：黑色背景 + 白色文字
  firstLayerBg: '#000000',      // 纯黑色
  firstLayerText: '#FFFFFF',    // 纯白色
  firstLayerIcon: '#FFFFFF',     // 白色图标
  
  // 第二层：黑色背景 + 白色文字
  secondLayerBg: '#000000',     // 纯黑色
  secondLayerText: '#FFFFFF',   // 纯白色
  secondLayerValue: '#FFFFFF',  // 白色数值
  
  // 第三层：黑色背景
  thirdLayerBg: '#000000',      // 纯黑色
  thirdLayerText: '#FFFFFF',    // 纯白色
  
  // 卡片边框和阴影
  cardBorder: '#000000',        // 黑色边框
  cardShadow: 'rgba(0,0,0,0.3)', // 黑色阴影
  
  // 主题相关颜色（默认值）
  cardNumberText: '#333333',           // 卡片序号文字颜色
  wavePercentText: '#666666',          // 波浪百分比文字颜色
  dataListText: '#333333',             // 数据列表文字颜色
  waveGradientLeft: 'rgba(0,0,0,0.7)',   // 波浪渐变左色
  waveGradientMid: 'rgba(0,0,0,0.8)',    // 波浪渐变中间色
  waveGradientRight: 'rgba(0,0,0,0.7)'   // 波浪渐变右色
}

// 深色主题卡片配色
export const DARK_CARD_COLORS: CardColorConfig = {
  firstLayerBg: '#34495E',      // 深灰色
  firstLayerText: '#FFFFFF',    // 白色
  firstLayerIcon: '#5DADE2',     // 浅蓝色
  
  secondLayerBg: '#2C3E50',     // 深蓝灰色
  secondLayerText: '#FFFFFF',   // 白色
  secondLayerValue: '#E67E22',  // 橙色
  
  thirdLayerBg: '#1A252F',      // 深色
  thirdLayerText: '#BDC3C7',    // 浅灰色
  
  cardBorder: '#5D6D7E',        // 中灰色边框
  cardShadow: 'rgba(0,0,0,0.3)', // 深色阴影
  
  // 主题相关颜色（默认值）
  cardNumberText: '#FFFFFF',           // 卡片序号文字颜色
  wavePercentText: '#BDC3C7',          // 波浪百分比文字颜色
  dataListText: '#FFFFFF',             // 数据列表文字颜色
  waveGradientLeft: 'rgba(93, 173, 226, 0.7)',   // 波浪渐变左色
  waveGradientMid: 'rgba(52, 152, 219, 0.8)',    // 波浪渐变中间色
  waveGradientRight: 'rgba(93, 173, 226, 0.7)'   // 波浪渐变右色
}

// 亮色主题卡片配色
export const LIGHT_CARD_COLORS: CardColorConfig = {
  firstLayerBg: '#FFFFFF',      // 纯白色
  firstLayerText: '#2C3E50',    // 深蓝灰色
  firstLayerIcon: '#2980B9',     // 深蓝色
  
  secondLayerBg: '#F8F9FA',     // 极浅灰色
  secondLayerText: '#2C3E50',   // 深蓝灰色
  secondLayerValue: '#E74C3C',  // 红色
  
  thirdLayerBg: '#FFFFFF',      // 纯白色
  thirdLayerText: '#6C757D',    // 中灰色
  
  cardBorder: '#D5DBDB',        // 浅灰色边框
  cardShadow: 'rgba(0,0,0,0.1)', // 浅色阴影
  
  // 主题相关颜色（默认值）
  cardNumberText: '#2C3E50',           // 卡片序号文字颜色
  wavePercentText: '#6C757D',          // 波浪百分比文字颜色
  dataListText: '#2C3E50',             // 数据列表文字颜色
  waveGradientLeft: 'rgba(41, 128, 185, 0.7)',   // 波浪渐变左色
  waveGradientMid: 'rgba(52, 152, 219, 0.8)',    // 波浪渐变中间色
  waveGradientRight: 'rgba(41, 128, 185, 0.7)'   // 波浪渐变右色
}

// 卡片颜色管理器
export class CardColorManager {
  private static instance: CardColorManager
  private currentColors: CardColorConfig = DEFAULT_CARD_COLORS
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): CardColorManager {
    if (!CardColorManager.instance) {
      CardColorManager.instance = new CardColorManager()
    }
    return CardColorManager.instance
  }
  
  /**
   * 设置卡片配色方案
   * @param colors 卡片颜色配置
   */
  setCardColors(colors: CardColorConfig): void {
    this.currentColors = colors
  }
  
  /**
   * 获取当前卡片配色
   * @returns 当前卡片颜色配置
   */
  getCardColors(): CardColorConfig {
    return this.currentColors
  }
  
  /**
   * 根据主题类型自动选择卡片配色
   * @param themeType 主题类型
   */
  setCardColorsByTheme(themeType: string): void {
    switch (themeType.toLowerCase()) {
      case 'dark':
      case '深色':
        this.setCardColors(DARK_CARD_COLORS)
        break
      case 'light':
      case '浅色':
        this.setCardColors(LIGHT_CARD_COLORS)
        break
      default:
        this.setCardColors(DEFAULT_CARD_COLORS)
        break
    }
  }
  
  /**
   * 重置为默认配色
   */
  resetToDefault(): void {
    this.setCardColors(DEFAULT_CARD_COLORS)
  }
}

/**
 * 根据当前主题动态生成卡片颜色配置
 * @param theme 当前主题配置
 * @returns 卡片颜色配置
 */
export function getCardColorsByTheme(theme: ExtendedOmniThemeStyle): CardColorConfig {
  return {
    // 基础颜色（保持原有逻辑）
    firstLayerBg: theme.backgroundColor || '#000000',
    firstLayerText: theme.textColor || '#FFFFFF',
    firstLayerIcon: theme.textColor || '#FFFFFF',
    secondLayerBg: theme.backgroundColor || '#000000',
    secondLayerText: theme.textColor || '#FFFFFF',
    secondLayerValue: theme.textColor || '#FFFFFF',
    thirdLayerBg: theme.backgroundColor || '#000000',
    thirdLayerText: theme.textColor || '#FFFFFF',
    cardBorder: theme.cardBorderColor || theme.borderColor || '#000000',
    cardShadow: 'rgba(0,0,0,0.3)',
    
    // 主题相关颜色（从主题配置获取）
    cardNumberText: theme.cardNumberTextColor || theme.textColor || '#333333',
    wavePercentText: theme.cardWavePercentTextColor || theme.subTextColor || '#666666',
    dataListText: theme.cardDataListTextColor || theme.textColor || '#333333',
    waveGradientLeft: theme.cardWaveGradientLeft || 'rgba(0,0,0,0.7)',
    waveGradientMid: theme.cardWaveGradientMid || 'rgba(0,0,0,0.8)',
    waveGradientRight: theme.cardWaveGradientRight || 'rgba(0,0,0,0.7)'
  }
}
