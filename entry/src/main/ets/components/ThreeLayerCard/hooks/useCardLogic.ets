/**
 * 卡片逻辑工具类
 * 提供卡片相关的工具方法和计算逻辑
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { CardColorManager, CardColorConfig, getCardColorsByTheme } from '../../../utils/theme/CardColors'
import { GlobalCardDataManager } from '../../../utils/managers/GlobalCardDataManager'
import { ThreeLayerCardData } from '../types'

export class UseCardLogic {
  /**
   * 获取当前主题
   */
  static getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 获取卡片颜色配置（基于当前主题）
   */
  static getCardColors(): CardColorConfig {
    const currentTheme = UseCardLogic.getCurrentTheme()
    return getCardColorsByTheme(currentTheme)
  }

  /**
   * 限制百分比值在0-100范围内
   */
  static clampPercent(v: number): number {
    if (v < 0) { return 0 }
    if (v > 100) { return 100 }
    return Math.floor(v)
  }

  /**
   * 根据卡片ID获取波浪图高度百分比
   * 注意：现在主要依赖实时数据，此方法仅作为后备默认值
   */
  static getWaveHeightPercent(cardData: ThreeLayerCardData): number {
    if (cardData && cardData.secondLayer && typeof cardData.secondLayer.percent === 'number') {
      return cardData.secondLayer.percent
    }
    return 0 // 默认值改为0，确保无数据时不显示波浪
  }

  /**
   * 根据卡片ID获取波浪基准位置百分比：第1/2/3张卡分别 0%/40%/60%
   * 注意：波浪从底部开始填充，baselinePercent越小波浪越满
   */
  static getWaveBaselinePercent(cardData: ThreeLayerCardData): number {
    const idStr: string = String(cardData?.id ?? '')
    // 从 "card_0" 格式中提取数字，对应 0%/20%/30%
    const match = idStr.match(/card_(\d+)/)
    if (match && match[1]) {
      const index = parseInt(match[1])
      if (index === 0) { return 0 }   // card_0 -> 0%（100%高度时从底部开始占满）
      if (index === 1) { return 20 }  // card_1 -> 20%（30%高度时从底部开始）
      if (index === 2) { return 30 }  // card_2 -> 30%（60%高度时从底部开始）
    }
    return 50  // 其他卡片默认 50%（中间位置）
  }

  /**
   * 获取卡片序号（从card_0, card_1等格式中提取数字+1）
   */
  static getCardNumber(cardData: ThreeLayerCardData): number {
    const idStr: string = String(cardData?.id ?? '')
    // 从 "card_0" 格式中提取数字，然后+1显示为1,2,3...
    const match = idStr.match(/card_(\d+)/)
    if (match && match[1]) {
      return parseInt(match[1]) + 1
    }
    return 1 // 默认返回1
  }

  /**
   * 获取卡片索引（从card_0, card_1等格式中提取数字）
   */
  static getCardIndex(cardData: ThreeLayerCardData): number {
    const idStr: string = String(cardData?.id ?? '')
    const match = idStr.match(/card_(\d+)/)
    if (match && match[1]) {
      return parseInt(match[1])
    }
    return 0 // 默认返回0
  }

  /**
   * 检查数组是否为空
   */
  static isEmpty<T>(arr: T[] | undefined): boolean {
    return !arr || arr.length === 0
  }

  /**
   * 安全获取数组元素
   */
  static safeGet<T>(arr: T[] | undefined, index: number): T | undefined {
    return arr && index >= 0 && index < arr.length ? arr[index] : undefined
  }

  /**
   * 深度比较两个数组是否相等
   */
  static deepEqual<T>(a: T[], b: T[]): boolean {
    if (a.length !== b.length) return false
    return a.every((val, index) => val === b[index])
  }

  /**
   * 安全切片，避免 undefined 错误
   */
  static safeSlice<T>(arr: T[] | undefined): T[] {
    return arr?.slice() ?? []
  }

}

/**
 * 预计算的卡片属性接口
 */
export interface CardComputedProps {
  theme: ExtendedOmniThemeStyle
  colors: CardColorConfig
  cardNumber: number
  waveHeightPercent: number
  waveBaselinePercent: number
}

export class UseCardComputed {
  /**
   * 计算三层卡片 UI 所需的聚合属性，减少重复 getter 调用
   */
  static getComputedCardProps(cardData: ThreeLayerCardData): CardComputedProps {
    const result: CardComputedProps = {
      theme: UseCardLogic.getCurrentTheme(),
      colors: UseCardLogic.getCardColors(),
      cardNumber: UseCardLogic.getCardNumber(cardData),
      waveHeightPercent: UseCardLogic.getWaveHeightPercent(cardData),
      waveBaselinePercent: UseCardLogic.getWaveBaselinePercent(cardData)
    }
    return result
  }
}
