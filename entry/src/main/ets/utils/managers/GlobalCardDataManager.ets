/**
 * 全局卡片数据管理器
 * 用于管理所有卡片的数据，避免页面切换时数据丢失
 */
import { ThreeLayerCardData, FirstLayerData, SecondLayerData, ThirdLayerData } from '../../components/ThreeLayerCard/types'

export class GlobalCardDataManager {
  private static instance: GlobalCardDataManager | null = null
  private cardDataList: ThreeLayerCardData[] = []
  private isInitialized: boolean = false
  private readonly CARD_COUNT = 20
  private currentFSM: 'FSM1' | 'FSM2' = 'FSM1'
  // 为每个FSM状态维护独立的卡片数据
  private fsmCardData: Record<string, ThreeLayerCardData[]> = {
    'FSM1': [],
    'FSM2': []
  }
  
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
   * 设置当前FSM状态
   */
  public setFSM(fsm: 'FSM1' | 'FSM2'): void {
    this.currentFSM = fsm
    // 切换到对应FSM的卡片数据，如果数据不存在则初始化
    if (!this.fsmCardData[fsm] || this.fsmCardData[fsm].length === 0) {
      this.initializeCardData()
    } else {
      this.cardDataList = this.fsmCardData[fsm]
    }
    console.log(`GlobalCardDataManager 切换到: ${fsm}，数据长度: ${this.cardDataList.length}`)
  }

  /**
   * 初始化卡片数据
   */
  public initializeCardData(): ThreeLayerCardData[] {
    console.log('GlobalCardDataManager 初始化卡片数据...')
    
    // 检查当前FSM状态的数据是否已初始化
    if (this.fsmCardData[this.currentFSM].length > 0) {
      console.log(`${this.currentFSM}数据已初始化，返回现有数据:`, this.fsmCardData[this.currentFSM].length, '个卡片')
      this.cardDataList = this.fsmCardData[this.currentFSM]
      return this.cardDataList.slice() // 返回副本，避免外部修改
    }

    console.log(`创建新的${this.currentFSM}卡片数据...`)
    const newCardDataList: ThreeLayerCardData[] = []
    
    for (let i = 0; i < this.CARD_COUNT; i++) {
      const firstLayer: FirstLayerData = {
        iconText: `${String.fromCharCode(65 + i)}`, // A, B, C, D...
        title: `卡片${i + 1}`,
        status: '正常'
      }
      const secondLayer: SecondLayerData = {
        serialNumber: i + 1,
        percent: (i % 2 === 0 ? 60 : 45),
        value: `${Math.floor(Math.random() * 100)}`,
        unit: 'kg'
      }
      const thirdLayer: ThirdLayerData = {
        chartType: 'waveform',
        chartData: [],
        chartConfig: {} as Record<string, string | number>
      }
      const cardData: ThreeLayerCardData = {
        id: `card_${i}`,
        firstLayer: firstLayer,
        secondLayer: secondLayer,
        thirdLayer: thirdLayer
      }
      newCardDataList.push(cardData)
    }
    
    // 保存到对应FSM状态的数据中
    this.fsmCardData[this.currentFSM] = newCardDataList
    this.cardDataList = newCardDataList
    this.isInitialized = true
    console.log(`创建了新的${this.currentFSM}卡片数据:`, newCardDataList.length, '个卡片')
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
      // 同时更新FSM状态的数据
      this.fsmCardData[this.currentFSM][cardIndex] = JSON.parse(JSON.stringify(newData))
      console.log(`更新${this.currentFSM}卡片${cardIndex + 1}的数据:`, newData.thirdLayer.chartData)
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
        const updatedThirdLayer: ThirdLayerData = {
          chartType: card.thirdLayer.chartType,
          chartData: currentData,
          chartConfig: card.thirdLayer.chartConfig
        }
        const updatedCard: ThreeLayerCardData = {
          id: card.id,
          firstLayer: card.firstLayer,
          secondLayer: card.secondLayer,
          thirdLayer: updatedThirdLayer
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
    
    // 清空FSM1的数据
    for (let i = 0; i < this.fsmCardData['FSM1'].length; i++) {
      const card = this.fsmCardData['FSM1'][i]
      const clearedThirdLayer: ThirdLayerData = {
        chartType: 'waveform',
        chartData: [],
        chartConfig: {} as Record<string, string | number>
      }
      const clearedCard: ThreeLayerCardData = {
        id: card.id,
        firstLayer: card.firstLayer,
        secondLayer: card.secondLayer,
        thirdLayer: clearedThirdLayer
      }
      this.fsmCardData['FSM1'][i] = clearedCard
    }
    
    // 清空FSM2的数据
    for (let i = 0; i < this.fsmCardData['FSM2'].length; i++) {
      const card = this.fsmCardData['FSM2'][i]
      const clearedThirdLayer: ThirdLayerData = {
        chartType: 'waveform',
        chartData: [],
        chartConfig: {} as Record<string, string | number>
      }
      const clearedCard: ThreeLayerCardData = {
        id: card.id,
        firstLayer: card.firstLayer,
        secondLayer: card.secondLayer,
        thirdLayer: clearedThirdLayer
      }
      this.fsmCardData['FSM2'][i] = clearedCard
    }
    
    // 更新当前显示的卡片数据
    this.cardDataList = this.fsmCardData[this.currentFSM]
    
    console.log('所有FSM状态的卡片第三层数据已清空')
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

  /**
   * 从 AppStorage 同步出口数据到卡片数据
   * 对应 UIDataSync 中的 EXIT_COUNT_ 和 EXIT_WEIGHT_
   */
  public syncExitDataFromStorage(): void {
    const EXIT_COUNT_PREFIX = 'EXIT_COUNT_'
    const EXIT_WEIGHT_PREFIX = 'EXIT_WEIGHT_'
    
    let hasUpdate = false
    
    // 遍历当前卡片数据
    // 注意：这里假设卡片索引 i 对应出口 i+1
    for (let i = 0; i < this.cardDataList.length; i++) {
      const exitIndex = i + 1
      const countKey = `${EXIT_COUNT_PREFIX}${exitIndex}`
      const weightKey = `${EXIT_WEIGHT_PREFIX}${exitIndex}`
      
      // 获取数据，如果不存在则默认为0
      const count = AppStorage.get<number>(countKey) ?? 0
      const weight = AppStorage.get<number>(weightKey) ?? 0
      
      // 转换重量为 kg (假设原始单位是 g)
      const weightInKg = (weight / 1000).toFixed(2)
      
      // 获取当前卡片引用
      const card = this.cardDataList[i]
      
      // 检查是否有数据变化，只在变化时更新
      if (card.secondLayer.value !== weightInKg) {
        // 更新 value
        card.secondLayer.value = weightInKg
        // 确保单位正确
        if (card.secondLayer.unit !== 'kg') {
          card.secondLayer.unit = 'kg'
        }
        
        // 同时更新 FSM 存储的数据
        if (this.fsmCardData[this.currentFSM] && this.fsmCardData[this.currentFSM][i]) {
          this.fsmCardData[this.currentFSM][i].secondLayer.value = weightInKg
          this.fsmCardData[this.currentFSM][i].secondLayer.unit = 'kg'
        }
        
        hasUpdate = true
      }
    }
    
    if (hasUpdate) {
      // 发送更新信号通知 UI
      // LiquidCardsArea 监听了 'GLOBAL_CARD_DATA_UPDATE_SIGNAL'
      AppStorage.setOrCreate('GLOBAL_CARD_DATA_UPDATE_SIGNAL', Date.now())
      // console.log('GlobalCardDataManager: 已从 AppStorage 同步出口数据并触发 UI 更新')
    }
  }
}
