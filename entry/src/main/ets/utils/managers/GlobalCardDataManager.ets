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
  

  // 定时器引用，用于定期从 AppStorage 同步出口数据
  private syncTimer: number | null = null

  private constructor() {
    console.log('GlobalCardDataManager 构造函数被调用')
    // 启动数据同步定时器
    this.startDataSync()
  }

  /**
   * 启动数据同步定时器
   * 定期从 AppStorage 获取 EXIT_COUNT_X 数据并更新到卡片
   */
  private startDataSync(): void {
    if (this.syncTimer !== null) return

    // 每 500ms 同步一次
    this.syncTimer = setInterval(() => {
      this.syncExitDataFromStorage()
    }, 500)
  }

  /**
   * 停止数据同步
   */
  public stopDataSync(): void {
    if (this.syncTimer !== null) {
      clearInterval(this.syncTimer)
      this.syncTimer = null
    }
  }

  /**
   * 从 AppStorage 同步出口数据到卡片
   */
  private syncExitDataFromStorage(): void {
    // 只有当卡片数据已初始化时才同步
    if (!this.isInitialized || this.cardDataList.length === 0) return

    // 获取总产量（用于计算百分比）
    // 使用全局总产量作为分母，遵循 C++ 逻辑：(当前个数 / 总个数) * 100
    const totalYieldStr = AppStorage.get('TOP_SUM_COUNTS') as string || '0'
    let totalYield = parseInt(totalYieldStr)
    
    // 如果总产量为0，尝试累加当前显示的出口数据（兜底策略）
    if (totalYield === 0) {
      let tempSum = 0
      for (let i = 0; i < this.cardDataList.length; i++) {
        const key = `EXIT_COUNT_${i + 1}`
        const count = AppStorage.get(key) as number || 0
        tempSum += count
      }
      totalYield = tempSum
    }
    
    // 避免除以0
    if (totalYield === 0) totalYield = 1

    // 更新卡片数据
    let hasChanges = false
    for (let i = 0; i < this.cardDataList.length; i++) {
      // 键名格式：EXIT_COUNT_1, EXIT_COUNT_2...
      // 卡片索引 0 对应 EXIT_COUNT_1
      const key = `EXIT_COUNT_${i + 1}`
      const count = AppStorage.get(key) as number || 0
      
      // 计算百分比：(当前个数 / 总个数) * 100
      const percent = (count / totalYield) * 100
      
      // 检查数据是否有变化
      const currentCard = this.cardDataList[i]
      const currentPercent = currentCard.secondLayer.percent
      const currentValue = parseInt(currentCard.secondLayer.value) || 0

      // 允许 0.01 的浮点误差 (保留2位小数精度)
      if (Math.abs(currentPercent - percent) > 0.01 || currentValue !== count) {
        // 创建新对象，确保引用变化，触发UI更新
        // ArkTS 不支持对象展开运算符，需要手动构建
        const newSecondLayer: SecondLayerData = {
          serialNumber: currentCard.secondLayer.serialNumber,
          percent: percent,
          value: count.toString(),
          unit: currentCard.secondLayer.unit
        }
        
        // 更新 ThirdLayerData，确保 chartData 也被更新（如果需要波浪图跟随变化）
        // 这里假设波浪图的数据也需要跟随百分比变化，或者只是刷新 UI
        // 如果 chartData 是用于绘制波浪的，应该在这里更新它
        // 目前 ThirdLayerData 中的 chartData 似乎主要用于拖拽内容，波浪高度由 waveHeightPercent 控制
        // 但 waveHeightPercent 现在是直接读取 secondLayer.percent
        
        const newCard: ThreeLayerCardData = {
          id: currentCard.id,
          firstLayer: currentCard.firstLayer,
          secondLayer: newSecondLayer,
          thirdLayer: currentCard.thirdLayer
        }
        
        // 更新列表
        this.cardDataList[i] = newCard
        this.fsmCardData[this.currentFSM][i] = newCard
        
        hasChanges = true
      }
    }

    if (hasChanges) {
      // 触发一个全局更新信号
      AppStorage.setOrCreate('GLOBAL_CARD_DATA_UPDATE_SIGNAL', Date.now())
    }
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
        percent: 0,
        value: '0',
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
   * @deprecated 已废弃，请使用 cardData.secondLayer.percent 获取实时数据
   */
  public getWaveHeightPercent(cardIndex: number): number {
    return 0
  }

  /**
   * 设置指定卡片的波浪高度百分比
   * @param cardIndex 卡片索引（0-19）
   * @param heightPercent 波浪高度百分比（0-100）
   * @deprecated 已废弃，波浪高度现由实时数据驱动
   */
  public setWaveHeightPercent(cardIndex: number, heightPercent: number): void {
  }

  /**
   * 获取所有卡片的波浪高度配置
   * @returns 波浪高度配置数组
   * @deprecated 已废弃
   */
  public getAllWaveHeightConfig(): number[] {
    return []
  }

  /**
   * 批量设置波浪高度配置
   * @param config 新的波浪高度配置数组
   * @deprecated 已废弃
   */
  public setAllWaveHeightConfig(config: number[]): void {
  }
}
