/**
 * 全局卡片数据管理器
 * 用于管理所有卡片的数据，避免页面切换时数据丢失
 */
import { ThreeLayerCardData } from '../components/cards/ThreeLayerCard'

export class GlobalCardDataManager {
  private static instance: GlobalCardDataManager | null = null
  private cardDataList: ThreeLayerCardData[] = []
  private isInitialized: boolean = false
  private readonly CARD_COUNT = 20
  
  // 波浪高度配置：每个卡片的波浪高度百分比
  // 卡片0: 100%, 卡片1: 30%, 卡片2: 60%
  private waveHeightConfig: number[] = [100, 30, 60, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70, 70]

  private constructor() {
    console.log('GlobalCardDataManager 构造函数被调用')
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): GlobalCardDataManager {
    if (!GlobalCardDataManager.instance) {
      GlobalCardDataManager.instance = new GlobalCardDataManager()
    }
    return GlobalCardDataManager.instance
  }

  /**
   * 初始化卡片数据
   */
  public initializeCardData(): ThreeLayerCardData[] {
    console.log('GlobalCardDataManager 初始化卡片数据...')
    
    if (this.isInitialized && this.cardDataList.length > 0) {
      console.log('数据已初始化，返回现有数据:', this.cardDataList.length, '个卡片')
      return this.cardDataList.slice() // 返回副本，避免外部修改
    }

    console.log('创建新的卡片数据...')
    const newCardDataList: ThreeLayerCardData[] = []
    
    for (let i = 0; i < this.CARD_COUNT; i++) {
      newCardDataList.push({
        id: `card_${i}`,
        firstLayer: {
          iconText: `${String.fromCharCode(65 + i)}`, // A, B, C, D...
          title: `卡片${i + 1}`,
          status: '正常'
        },
        secondLayer: {
          serialNumber: i + 1,
          percent: (i % 2 === 0 ? 60 : 45),
          value: `${Math.floor(Math.random() * 100)}`,
          unit: 'kg'
        },
        thirdLayer: {
          chartType: 'waveform',
          chartData: [],
          chartConfig: {}
        }
      })
    }
    
    this.cardDataList = newCardDataList
    this.isInitialized = true
    console.log('创建了新的卡片数据:', newCardDataList.length, '个卡片')
    return this.cardDataList.slice() // 返回副本
  }

  /**
   * 获取所有卡片数据
   */
  public getCardDataList(): ThreeLayerCardData[] {
    return this.cardDataList.slice() // 返回副本，避免外部修改
  }

  /**
   * 更新指定卡片的数据
   */
  public updateCardData(cardIndex: number, newData: ThreeLayerCardData): void {
    if (cardIndex >= 0 && cardIndex < this.cardDataList.length) {
      this.cardDataList[cardIndex] = JSON.parse(JSON.stringify(newData)) // 深拷贝
      console.log(`更新卡片${cardIndex + 1}的数据:`, newData.thirdLayer.chartData)
    }
  }

  /**
   * 从指定卡片移除数据
   */
  public removeDataFromCard(cardId: string, value: number): void {
    const cardIndex = this.cardDataList.findIndex(card => card.id === cardId)
    if (cardIndex !== -1) {
      const card = this.cardDataList[cardIndex]
      const currentData = Array.isArray(card.thirdLayer.chartData) 
        ? (card.thirdLayer.chartData as number[]).slice()
        : []
      
      const valueIndex = currentData.findIndex(v => v === value)
      if (valueIndex !== -1) {
        currentData.splice(valueIndex, 1)
        
        // 更新卡片数据
        const updatedCard: ThreeLayerCardData = {
          id: card.id,
          firstLayer: card.firstLayer,
          secondLayer: card.secondLayer,
          thirdLayer: {
            chartType: card.thirdLayer.chartType,
            chartData: currentData,
            chartConfig: card.thirdLayer.chartConfig
          }
        }
        this.cardDataList[cardIndex] = JSON.parse(JSON.stringify(updatedCard))
        console.log(`从卡片${cardIndex + 1}删除值${value}的数据`)
      }
    }
  }

  /**
   * 检查是否已初始化
   */
  public isDataInitialized(): boolean {
    return this.isInitialized
  }

  /**
   * 重置数据（用于测试或清理）
   */
  public resetData(): void {
    this.cardDataList = []
    this.isInitialized = false
    console.log('GlobalCardDataManager 数据已重置')
  }

  /**
   * 清空所有卡片的第三层数据（保留卡片结构，只清空拖拽数据）
   */
  public clearAllCardData(): void {
    console.log('开始清空所有卡片的第三层数据...')
    
    for (let i = 0; i < this.cardDataList.length; i++) {
      const card = this.cardDataList[i]
      this.cardDataList[i] = {
        id: card.id,
        firstLayer: card.firstLayer,
        secondLayer: card.secondLayer,
        thirdLayer: {
          chartType: 'waveform',
          chartData: [],
          chartConfig: {}
        }
      }
    }
    
    console.log('所有卡片的第三层数据已清空')
  }

  /**
   * 获取指定卡片的波浪高度百分比
   * @param cardIndex 卡片索引（0-19）
   * @returns 波浪高度百分比
   */
  public getWaveHeightPercent(cardIndex: number): number {
    if (cardIndex >= 0 && cardIndex < this.waveHeightConfig.length) {
      return this.waveHeightConfig[cardIndex]
    }
    return 70 // 默认值
  }

  /**
   * 设置指定卡片的波浪高度百分比
   * @param cardIndex 卡片索引（0-19）
   * @param heightPercent 波浪高度百分比（0-100）
   */
  public setWaveHeightPercent(cardIndex: number, heightPercent: number): void {
    if (cardIndex >= 0 && cardIndex < this.waveHeightConfig.length) {
      this.waveHeightConfig[cardIndex] = Math.max(0, Math.min(100, heightPercent))
      console.log(`卡片${cardIndex}的波浪高度已设置为${this.waveHeightConfig[cardIndex]}%`)
    }
  }

  /**
   * 获取所有卡片的波浪高度配置
   * @returns 波浪高度配置数组
   */
  public getAllWaveHeightConfig(): number[] {
    return [...this.waveHeightConfig] // 返回副本，避免外部修改
  }

  /**
   * 批量设置波浪高度配置
   * @param config 新的波浪高度配置数组
   */
  public setAllWaveHeightConfig(config: number[]): void {
    if (config.length === this.waveHeightConfig.length) {
      this.waveHeightConfig = config.map(h => Math.max(0, Math.min(100, h)))
      console.log('所有卡片的波浪高度配置已更新')
    }
  }
}
