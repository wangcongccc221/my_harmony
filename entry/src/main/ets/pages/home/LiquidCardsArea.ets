/**
 * 液体卡片区域组件
 * 
 * 功能说明：
 * - 显示多个液体卡片的滚动区域
 * - 支持垂直滚动查看更多卡片
 * - 使用Flex布局实现卡片网格排列
 * - 支持主题配置和样式定制
 * 
 * 组件特点：
 * - 响应式布局：自动换行显示卡片
 * - 性能优化：限制可见卡片数量，提升滚动性能
 * - 主题支持：使用主题管理器的颜色配置
 * - 滚动优化：配置滚动条和滚动效果
 * 
 * 布局说明：
 * - 卡片排列：水平排列，自动换行
 * - 卡片间距：右边距6px，下边距6px
 * - 区域高度：占父容器的30%
 * - 滚动方向：垂直滚动
 * 
 * 性能优化：
 * - 可见卡片数量：限制为20个，减少渲染开销
 * - 滚动摩擦：设置为0.6，提升滚动流畅度
 * - 滚动条：自动显示，宽度6px
 * 
 * 使用方式：
 * ```typescript
 * LiquidCardsArea()
 * ```
 * 
 * 样式配置：
 * - 背景色：使用主题的控制背景色
 * - 边框：1px边框，使用主题边框色
 * - 圆角：10px
 * - 内边距：左右20px，上下0px和4px
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { ThreeLayerCard, ThreeLayerCardData } from '../../components/cards/ThreeLayerCard'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { GRID_DRAG_ACTIVE_KEY } from '../../components/layout/DraggableGridTable'
import { getCurrentCellDragData, CellDragData, CELL_DRAG_ACTIVE_KEY } from '../../components/ui/SimpleDraggableCell'
import { GlobalCardDataManager } from '../../utils/GlobalCardDataManager'
import { CardDataManager } from '../../utils/card/CardDataManager'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { HomeDataManager } from './core/HomeDataManager'
import { HomeContent } from './HomeContent'

// 移除源数据接口
interface RemoveSourceData {
  sourceCardId: string
  sourceValue: number
}


@Component
export struct LiquidCardsArea {
  // 拖拽数据状态
  @State private dragData: CellDragData | null = null
  // 每张卡片的数据（索引从0开始，对应UI里的1..N）
  @State private cardDataList: ThreeLayerCardData[] = []
  @State private isDragging: boolean = false
  // 监听强制移除信号
  @StorageLink(StorageKeys.FORCE_REMOVE_SOURCE) private forceRemoveSource: RemoveSourceData | null = null
  @State private hoverIndex: number = -1
  @StorageLink(GRID_DRAG_ACTIVE_KEY) private gridDragActive: boolean = false
  // FSM状态监听
  @StorageLink(HOME_SELECTED_FSM) @Watch('onFSMChange') private selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  // 简化：不记录几何，直接在卡片自身接收抬手投放
  
  // 全局数据管理器实例
  private globalDataManager: GlobalCardDataManager = GlobalCardDataManager.getInstance()
  
  // 模块化的卡片数据管理器
  private cardDataManager: CardDataManager = CardDataManager.getInstance()
  
  // 拖拽回调（预留扩展位）
  // onDataDropped?: (data: CellDragData) => void
  // onDataRemoved?: () => void
  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从主题管理器获取当前主题样式
   * - 用于液体卡片的颜色配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 生成数字序列
   * 
   * 功能说明：
   * - 生成从指定开始数字到指定长度的数字序列
   * - 用于液体卡片的索引生成
   * - 支持自定义起始数字和数量
   * 
   * @param start 起始数字
   * @param count 序列长度
   * @returns 数字序列数组
   * 
   * 使用示例：
   * ```typescript
   * const numbers = this.buildNumberRange(1, 5)
   * // 返回 [1, 2, 3, 4, 5]
   * ```
   */
  private buildNumberRange(start: number, count: number): number[] {
    const result: number[] = []
    for (let i = 0; i < count; i++) {
      result.push(start + i)
    }
    return result
  }

  /**
   * 获取可见卡片数量（性能优化）
   * 
   * 功能说明：
   * - 根据屏幕高度动态计算可见卡片数量
   * - 减少渲染开销，提升滚动性能
   * - 避免渲染过多卡片导致的性能问题
   * 
   * @returns 可见卡片数量
   * 
   * 性能优化说明：
   * - 限制可见卡片数量为20个
   * - 减少内存占用和渲染时间
   * - 提升滚动流畅度
   */
  private getVisibleCardCount(): number {
    // 根据屏幕高度动态计算可见卡片数量，减少渲染开销
    return 20 // 减少到20个卡片，提升滚动性能
  }

  /**
   * 获取波浪图数量（根据FSM状态）
   * 
   * 功能说明：
   * - FSM1：显示3个波浪图
   * - FSM2：显示5个波浪图
   * 
   * @returns 波浪图数量
   */
  private getWaveCount(): number {
    return this.selectedFSM === 'FSM1' ? 3 : 5
  }

  /**
   * 初始化卡片数据
   */
  private initializeCardData(): void {
    console.log('开始初始化卡片数据...')
    
    // 使用全局数据管理器
    this.cardDataList = this.globalDataManager.initializeCardData()
    console.log('从全局数据管理器获取数据:', this.cardDataList.length, '个卡片')
  }

  /**
   * 清空所有卡片的第三层数据
   */
  public clearAllCardData(): void {
    console.log('LiquidCardsArea: 开始清空所有卡片数据...')
    
    // 使用全局数据管理器清空数据
    this.globalDataManager.clearAllCardData()
    
    // 更新本地状态
    this.cardDataList = this.globalDataManager.getCardDataList()
    
    // 同时清空等级统计表的出口信息
    this.clearStatisticsTableExits()
    
    console.log('LiquidCardsArea: 所有卡片数据和等级统计表出口信息已清空')
  }

  /**
   * 清空等级统计表的出口信息
   */
  private clearStatisticsTableExits(): void {
    // 通过AppStorage获取HomeDataManager实例
    const homeDataManager = AppStorage.get('HOME_DATA_MANAGER') as HomeDataManager | null
    if (homeDataManager) {
      homeDataManager.clearStatisticsTableExits()
      
      // 通过AppStorage获取HomeContent实例来触发UI刷新
      const homeContentRef = AppStorage.get('HOME_CONTENT_REF') as HomeContent | null
      if (homeContentRef) {
        homeContentRef.refreshStatisticsTable()
        console.log('LiquidCardsArea: 等级统计表出口信息已清空，UI已刷新')
      } else {
        console.warn('LiquidCardsArea: 无法获取HomeContent实例，数据已清空但UI可能未刷新')
      }
    } else {
      console.warn('LiquidCardsArea: 无法获取HomeDataManager实例，跳过清空等级统计表出口信息')
    }
  }

  /**
   * 组件出现时注册到AppStorage
   */
  aboutToAppear(): void {
    // 将当前实例注册到AppStorage，供其他组件调用
    AppStorage.setOrCreate('LIQUID_CARDS_AREA_REF', this)
    // 初始化卡片数据
    this.initializeCardData()
  }

  aboutToDisappear(): void {
    // 离开时释放保存的组件实例引用，避免阻止GC
    AppStorage.setOrCreate('LIQUID_CARDS_AREA_REF', null)
  }

  /**
   * 监听FSM状态变化
   */
  onFSMChange(): void {
    console.log(`LiquidCardsArea: FSM状态变化到 ${this.selectedFSM}`)
    this.globalDataManager.setFSM(this.selectedFSM)
    this.cardDataList = this.globalDataManager.getCardDataList()
    console.log(`LiquidCardsArea: 已切换到 ${this.selectedFSM} 的卡片数据，共 ${this.cardDataList.length} 个卡片`)
  }

  /**
   * 监听强制移除信号
   */
  aboutToUpdate(): void {
    // 监听强制移除信号
    if (this.forceRemoveSource && this.forceRemoveSource.sourceCardId && this.forceRemoveSource.sourceValue) {
      console.log('监听到强制移除信号:', this.forceRemoveSource)
      this.performRemoveSourceData(this.forceRemoveSource)
      // 清除信号
      AppStorage.set(StorageKeys.FORCE_REMOVE_SOURCE, null)
    }
  }



  /**
   * 处理卡片拖拽投放
   */
  private handleCardDrop(cardIndex: number, data: ThreeLayerCardData): void {
    console.log(`handleCardDrop - 卡片${cardIndex + 1} 接收到数据:`, JSON.stringify(data.thirdLayer.chartData))
    console.log(`🔍 handleCardDrop - 接收到的ID:`, data.id, ' 期望的ID: card_${cardIndex}')
    
    // 使用模块化的卡片数据管理器修正ID
    const correctedData = this.cardDataManager.correctCardId(data, cardIndex)
    
    // 验证数据有效性
    if (!this.cardDataManager.validateCardData(correctedData)) {
      console.error('❌ 卡片数据验证失败，跳过更新')
      return
    }
    
    // 更新全局数据管理器
    this.globalDataManager.updateCardData(cardIndex, correctedData)
    
    // 更新本地状态
    this.cardDataList = this.globalDataManager.getCardDataList()
    console.log(`卡片${cardIndex + 1} 已更新第三层数据:`, correctedData.thirdLayer)
    console.log('更新后的cardDataList:', JSON.stringify(this.cardDataList[cardIndex].thirdLayer.chartData))
    
    // 检查是否有移除操作需要处理
    this.handleRemoveSourceData()
  }

  /**
   * 处理移除源卡片数据
   */
  private handleRemoveSourceData(): void {
    const removeData = AppStorage.get(StorageKeys.REMOVE_SOURCE_DATA) as RemoveSourceData | null
    if (removeData && removeData.sourceCardId && removeData.sourceValue) {
      console.log('处理移除源卡片数据:', removeData)
      this.performRemoveSourceData(removeData)
      // 清除移除操作标记
      AppStorage.set(StorageKeys.REMOVE_SOURCE_DATA, null)
    }
  }

  /**
   * 执行移除源卡片数据的具体操作
   */
  private performRemoveSourceData(removeData: RemoveSourceData): void {
    // 验证卡片ID有效性
    if (!this.cardDataManager.isValidCardId(removeData.sourceCardId)) {
      console.error('❌ 无效的卡片ID:', removeData.sourceCardId)
      return
    }
    
    // 使用全局数据管理器移除数据
    this.globalDataManager.removeDataFromCard(removeData.sourceCardId, removeData.sourceValue)
    
    // 更新本地状态
    this.cardDataList = this.globalDataManager.getCardDataList()
    
    // 使用模块化管理器获取卡片摘要信息
    const cardSummary = this.cardDataManager.getCardDataSummary(
      this.cardDataList[this.cardDataManager.parseCardIndex(removeData.sourceCardId)]
    )
    console.log(`已从${cardSummary}删除值${removeData.sourceValue}的数据`)
  }

  /**
   * 组件构建方法
   * 
   * 功能说明：
   * - 构建液体卡片区域的UI结构
   * - 使用Scroll和Flex布局实现卡片网格排列
   * - 配置滚动效果和样式
   * 
   * 布局说明：
   * - 使用Scroll组件实现垂直滚动
   * - 使用Flex布局实现卡片网格排列
   * - 卡片自动换行，左对齐排列
   * - 区域高度占父容器的30%
   * 
   * 滚动配置：
   * - 滚动方向：垂直滚动
   * - 滚动条：自动显示，宽度6px
   * - 滚动效果：弹簧效果
   * - 滚动摩擦：0.6，提升流畅度
   * 
   * 样式配置：
   * - 背景色：使用主题的控制背景色
   * - 边框：1px边框，使用主题边框色
   * - 圆角：10px
   * - 内边距：左右20px，上下0px和4px
   */
  build() {
    Scroll() {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(this.cardDataList, (cardData: ThreeLayerCardData, idx: number) => {
          // 使用新的三层卡片
          ThreeLayerCard({
            cardData: cardData,
            cardWidth: 120,
            cardHeight: 160,
            mainColor: this.getCurrentTheme().primary,
            enableWave: idx < this.getWaveCount() && (!cardData.thirdLayer.chartData || cardData.thirdLayer.chartData.length === 0),
            onCardDrop: (data: ThreeLayerCardData) => {
              this.handleCardDrop(idx, data)
            }
          })
          .margin({ right: 6, bottom: 6 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('36%') // 液体卡片区域占36%
    // 拖拽激活时禁用滚动，避免抢占onDrop事件
    .enabled(!this.gridDragActive)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBarColor(this.getCurrentTheme().borderColor)
    .scrollBarWidth(6)
    .friction(0.6) // 进一步减少摩擦系数，提升流畅度
    .padding({ left: 20, right: 20, top: 0, bottom: 4 })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(10)
    .onAppear(() => {
      this.initializeCardData()
    })
  }

}
