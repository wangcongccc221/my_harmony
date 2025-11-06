/**
 * 卡片数据管理器
 * 功能：统一管理卡片数据操作和ID修正逻辑
 * 用途：提供标准化的卡片数据管理API
 */

import { ThreeLayerCardData } from '../../components/cards/ThreeLayerCard'

/**
 * 卡片数据管理器类
 * 提供统一的卡片数据操作和验证
 */
export class CardDataManager {
  private static instance: CardDataManager

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): CardDataManager {
    if (!CardDataManager.instance) {
      CardDataManager.instance = new CardDataManager()
    }
    return CardDataManager.instance
  }

  /**
   * 修正卡片ID
   * @param data 卡片数据
   * @param expectedIndex 期望的索引
   */
  public correctCardId(data: ThreeLayerCardData, expectedIndex: number): ThreeLayerCardData {
    const correctId = `card_${expectedIndex}`
    
    if (data.id !== correctId) {
      console.log(`🔧 修正ID: ${data.id} -> ${correctId}`)
      data.id = correctId
    }
    
    return data
  }

  /**
   * 验证卡片数据
   * @param data 卡片数据
   */
  public validateCardData(data: ThreeLayerCardData): boolean {
    if (!data) {
      console.error('❌ 卡片数据为空')
      return false
    }

    if (!data.id) {
      console.error('❌ 卡片ID为空')
      return false
    }

    if (!data.firstLayer) {
      console.error('❌ 第一层数据为空')
      return false
    }

    if (!data.secondLayer) {
      console.error('❌ 第二层数据为空')
      return false
    }

    if (!data.thirdLayer) {
      console.error('❌ 第三层数据为空')
      return false
    }

    return true
  }

  /**
   * 创建新的卡片数据
   * @param originalData 原始数据
   * @param updates 更新数据
   */
  public createNewCardData(
    originalData: ThreeLayerCardData,
    updates: Partial<ThreeLayerCardData>
  ): ThreeLayerCardData {
    return {
      id: originalData.id, // 保留原始ID
      firstLayer: updates.firstLayer || originalData.firstLayer,
      secondLayer: updates.secondLayer || originalData.secondLayer,
      thirdLayer: updates.thirdLayer || originalData.thirdLayer
    }
  }

  /**
   * 更新卡片数据
   * @param originalData 原始数据
   * @param updates 更新数据
   */
  public updateCardData(
    originalData: ThreeLayerCardData,
    updates: Partial<ThreeLayerCardData>
  ): ThreeLayerCardData {
    const newData = this.createNewCardData(originalData, updates)
    
    if (!this.validateCardData(newData)) {
      console.error('❌ 更新后的卡片数据验证失败')
      return originalData
    }

    return newData
  }

  /**
   * 从卡片ID解析索引
   * @param cardId 卡片ID
   */
  public parseCardIndex(cardId: string): number {
    if (!cardId || !cardId.startsWith('card_')) {
      console.error('❌ 无效的卡片ID格式:', cardId)
      return 0
    }

    const indexStr = cardId.replace('card_', '')
    const index = parseInt(indexStr, 10)
    
    if (isNaN(index)) {
      console.error('❌ 无法解析卡片索引:', cardId)
      return 0
    }

    return index
  }

  /**
   * 从卡片ID获取显示编号
   * @param cardId 卡片ID
   */
  public getCardNumber(cardId: string): number {
    const index = this.parseCardIndex(cardId)
    return index + 1
  }

  /**
   * 生成卡片ID
   * @param index 索引
   */
  public generateCardId(index: number): string {
    return `card_${index}`
  }

  /**
   * 检查卡片ID是否有效
   * @param cardId 卡片ID
   */
  public isValidCardId(cardId: string): boolean {
    if (!cardId) return false
    return cardId.startsWith('card_') && !isNaN(parseInt(cardId.replace('card_', ''), 10))
  }

  /**
   * 深度复制卡片数据
   * @param data 原始数据
   */
  public deepCopyCardData(data: ThreeLayerCardData): ThreeLayerCardData {
    try {
      return JSON.parse(JSON.stringify(data)) as ThreeLayerCardData
    } catch (error) {
      console.error('❌ 深度复制卡片数据失败:', error)
      return data
    }
  }

  /**
   * 比较两个卡片数据是否相等
   * @param data1 数据1
   * @param data2 数据2
   */
  public areCardDataEqual(data1: ThreeLayerCardData, data2: ThreeLayerCardData): boolean {
    if (!data1 || !data2) return false
    if (data1.id !== data2.id) return false
    
    try {
      const str1 = JSON.stringify(data1)
      const str2 = JSON.stringify(data2)
      return str1 === str2
    } catch (error) {
      console.error('❌ 比较卡片数据失败:', error)
      return false
    }
  }

  /**
   * 获取卡片数据摘要
   * @param data 卡片数据
   */
  public getCardDataSummary(data: ThreeLayerCardData): string {
    if (!data) return '无数据'
    
    const cardNumber = this.getCardNumber(data.id || 'card_0')
    const thirdLayerCount = data.thirdLayer?.chartData?.length || 0
    
    return `卡片${cardNumber} (ID: ${data.id || 'unknown'}, 第三层数据: ${thirdLayerCount}项)`
  }

  /**
   * 批量更新卡片数据
   * @param cardDataList 卡片数据列表
   * @param updates 更新数据映射
   */
  public batchUpdateCardData(
    cardDataList: ThreeLayerCardData[],
    updates: Map<number, Partial<ThreeLayerCardData>>
  ): ThreeLayerCardData[] {
    const newList: ThreeLayerCardData[] = []
    
    for (let i = 0; i < cardDataList.length; i++) {
      const originalData = cardDataList[i]
      const updateData = updates.get(i)
      
      if (updateData) {
        const newData = this.updateCardData(originalData, updateData)
        newList.push(newData)
      } else {
        newList.push(originalData)
      }
    }
    
    return newList
  }
}

