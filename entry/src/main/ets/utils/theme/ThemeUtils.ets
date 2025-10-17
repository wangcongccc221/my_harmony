/**
 * 主题工具模块
 * 功能：提供通用的主题样式和颜色计算
 * 用途：减少主题相关代码重复，提供统一的主题API
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from './OmniThemeManager'

/**
 * 主题工具类
 * 提供通用的主题样式和颜色计算功能
 */
export class ThemeUtils {
  private static instance: ThemeUtils
  private themeManager: OmniThemeManager

  private constructor() {
    this.themeManager = OmniThemeManager.getInstance()
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): ThemeUtils {
    if (!ThemeUtils.instance) {
      ThemeUtils.instance = new ThemeUtils()
    }
    return ThemeUtils.instance
  }

  /**
   * 获取当前主题
   */
  public getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.themeManager.getCurrentTheme()
  }

  /**
   * 获取卡片背景颜色
   * @param isActive 是否激活状态
   */
  public getCardBackgroundColor(isActive: boolean = false): string {
    const theme = this.getCurrentTheme()
    return isActive ? theme.cardActiveBackground : theme.cardBackground
  }

  /**
   * 获取卡片边框颜色
   * @param isActive 是否激活状态
   */
  public getCardBorderColor(isActive: boolean = false): string {
    const theme = this.getCurrentTheme()
    return isActive ? theme.cardActiveBorder : theme.cardBorder
  }

  /**
   * 获取文本颜色
   * @param isPrimary 是否主要文本
   */
  public getTextColor(isPrimary: boolean = true): string {
    const theme = this.getCurrentTheme()
    return isPrimary ? theme.textPrimary : theme.textSecondary
  }

  /**
   * 获取按钮背景颜色
   * @param isActive 是否激活状态
   */
  public getButtonBackgroundColor(isActive: boolean = false): string {
    const theme = this.getCurrentTheme()
    return isActive ? theme.buttonActiveBackground : theme.buttonBackground
  }

  /**
   * 获取按钮文本颜色
   * @param isActive 是否激活状态
   */
  public getButtonTextColor(isActive: boolean = false): string {
    const theme = this.getCurrentTheme()
    return isActive ? theme.buttonActiveText : theme.buttonText
  }

  /**
   * 获取拖拽状态颜色
   * @param isDragging 是否拖拽中
   * @param isSelected 是否选中
   */
  public getDragStateColor(isDragging: boolean = false, isSelected: boolean = false): string {
    const theme = this.getCurrentTheme()
    
    if (isDragging) {
      return theme.dragActiveColor
    } else if (isSelected) {
      return theme.dragSelectedColor
    } else {
      return theme.dragDefaultColor
    }
  }

  /**
   * 获取表格单元格颜色
   * @param isHeader 是否表头
   * @param isSelected 是否选中
   */
  public getTableCellColor(isHeader: boolean = false, isSelected: boolean = false): string {
    const theme = this.getCurrentTheme()
    
    if (isHeader) {
      return theme.tableHeaderBackground
    } else if (isSelected) {
      return theme.tableCellSelectedBackground
    } else {
      return theme.tableCellBackground
    }
  }

  /**
   * 获取波浪图颜色
   * @param cardIndex 卡片索引
   */
  public getWaveColor(cardIndex: number): string {
    const theme = this.getCurrentTheme()
    const colors = [
      theme.waveColor1, theme.waveColor2, theme.waveColor3, theme.waveColor4, theme.waveColor5,
      theme.waveColor6, theme.waveColor7, theme.waveColor8, theme.waveColor9, theme.waveColor10,
      theme.waveColor11, theme.waveColor12, theme.waveColor13, theme.waveColor14, theme.waveColor15,
      theme.waveColor16, theme.waveColor17, theme.waveColor18, theme.waveColor19, theme.waveColor20
    ]
    return colors[cardIndex] || theme.waveColor1
  }

  /**
   * 获取状态指示器颜色
   * @param status 状态类型
   */
  public getStatusColor(status: 'success' | 'warning' | 'error' | 'info'): string {
    const theme = this.getCurrentTheme()
    
    switch (status) {
      case 'success':
        return theme.statusSuccess
      case 'warning':
        return theme.statusWarning
      case 'error':
        return theme.statusError
      case 'info':
        return theme.statusInfo
      default:
        return theme.statusInfo
    }
  }

  /**
   * 计算颜色透明度
   * @param color 原始颜色
   * @param opacity 透明度 (0-1)
   */
  public calculateColorWithOpacity(color: string, opacity: number): string {
    if (opacity < 0) opacity = 0
    if (opacity > 1) opacity = 1
    
    // 如果是十六进制颜色
    if (color.startsWith('#')) {
      const hex = color.replace('#', '')
      const r = parseInt(hex.substr(0, 2), 16)
      const g = parseInt(hex.substr(2, 2), 16)
      const b = parseInt(hex.substr(4, 2), 16)
      return `rgba(${r}, ${g}, ${b}, ${opacity})`
    }
    
    // 如果是rgba颜色
    if (color.startsWith('rgba')) {
      return color.replace(/[\d.]+\)$/g, `${opacity})`)
    }
    
    // 如果是rgb颜色
    if (color.startsWith('rgb')) {
      return color.replace('rgb', 'rgba').replace(')', `, ${opacity})`)
    }
    
    return color
  }

  /**
   * 获取阴影样式
   * @param elevation 阴影高度
   */
  public getShadowStyle(elevation: number = 2): object {
    const theme = this.getCurrentTheme()
    const shadowColor = this.calculateColorWithOpacity(theme.shadowColor, 0.1)
    
    return {
      shadowColor: shadowColor,
      shadowOffset: { width: 0, height: elevation },
      shadowOpacity: 0.1,
      shadowRadius: elevation * 2,
      elevation: elevation
    }
  }

  /**
   * 获取圆角样式
   * @param radius 圆角半径
   */
  public getBorderRadiusStyle(radius: number = 8): object {
    return {
      borderRadius: radius
    }
  }

  /**
   * 获取边框样式
   * @param width 边框宽度
   * @param color 边框颜色
   */
  public getBorderStyle(width: number = 1, color?: string): object {
    const borderColor = color || this.getCurrentTheme().cardBorder
    
    return {
      borderWidth: width,
      borderColor: borderColor
    }
  }

  /**
   * 获取渐变背景样式
   * @param startColor 起始颜色
   * @param endColor 结束颜色
   * @param direction 渐变方向
   */
  public getGradientStyle(
    startColor: string,
    endColor: string,
    direction: 'vertical' | 'horizontal' = 'vertical'
  ): object {
    return {
      background: `linear-gradient(${direction === 'vertical' ? 'to bottom' : 'to right'}, ${startColor}, ${endColor})`
    }
  }

  /**
   * 获取动画样式
   * @param duration 动画持续时间
   * @param easing 缓动函数
   */
  public getAnimationStyle(duration: number = 300, easing: string = 'ease-in-out'): object {
    return {
      transition: `all ${duration}ms ${easing}`
    }
  }

  /**
   * 获取响应式字体大小
   * @param baseSize 基础字体大小
   * @param scale 缩放比例
   */
  public getResponsiveFontSize(baseSize: number, scale: number = 1): number {
    return baseSize * scale
  }

  /**
   * 获取响应式间距
   * @param baseSpacing 基础间距
   * @param scale 缩放比例
   */
  public getResponsiveSpacing(baseSpacing: number, scale: number = 1): number {
    return baseSpacing * scale
  }
}
