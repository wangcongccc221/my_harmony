/**
 * 模块化使用示例
 * 功能：展示如何使用新创建的模块
 * 用途：提供标准化的模块使用指南
 */

import { DragManager, DragHandlers, DragData } from '../drag/DragManager'
import { WaveConfigManager } from '../animation/WaveConfig'
import { CardDataManager } from '../card/CardDataManager'
import { ThemeUtils } from '../theme/ThemeUtils'

/**
 * 模块化使用示例类
 * 展示如何在组件中使用新的模块
 */
export class ModuleUsageExample {
  private dragManager: DragManager
  private dragHandlers: DragHandlers
  private waveConfigManager: WaveConfigManager
  private cardDataManager: CardDataManager
  private themeUtils: ThemeUtils

  constructor() {
    // 初始化所有管理器
    this.dragManager = DragManager.getInstance()
    this.dragHandlers = new DragHandlers()
    this.waveConfigManager = WaveConfigManager.getInstance()
    this.cardDataManager = CardDataManager.getInstance()
    this.themeUtils = ThemeUtils.getInstance()
  }

  /**
   * 示例：在ThreeLayerCard中使用拖拽管理器
   */
  public exampleThreeLayerCardUsage(): void {
    // 1. 开始拖拽
    const dragData: DragData = {
      value: '测试数据',
      sourceTable: '等级表',
      rowIndex: 0,
      colIndex: 1,
      sourceCardId: 'card_0',
      sourceValue: '测试值',
      itemIndex: 0
    }

    this.dragHandlers.handleDragStart(dragData)

    // 2. 处理拖拽结束
    this.dragHandlers.handleDragEnd(
      () => {
        console.log('执行删除逻辑')
      },
      () => {
        console.log('执行复制逻辑')
      }
    )

    // 3. 处理拖拽投放
    this.dragHandlers.handleDrop('card_1', true)
  }

  /**
   * 示例：在WaveCard中使用波浪配置管理器
   */
  public exampleWaveCardUsage(): void {
    const cardIndex = 0
    const containerHeight = 200

    // 1. 获取波浪配置
    const config = this.waveConfigManager.getWaveConfig(cardIndex)
    console.log('波浪配置:', config)

    // 2. 计算波浪高度
    const waveHeight = this.waveConfigManager.calculateWaveHeight(cardIndex, containerHeight)
    console.log('波浪高度:', waveHeight)

    // 3. 计算波浪基准位置
    const baseline = this.waveConfigManager.calculateWaveBaseline(cardIndex, containerHeight)
    console.log('波浪基准位置:', baseline)

    // 4. 计算波浪中心Y坐标
    const centerY = this.waveConfigManager.calculateWaveCenterY(cardIndex, containerHeight)
    console.log('波浪中心Y坐标:', centerY)
  }

  /**
   * 示例：在LiquidCardsArea中使用卡片数据管理器
   */
  public exampleCardDataManagerUsage(): void {
    // 1. 修正卡片ID
    const cardData = {
      id: 'card_0',
      firstLayer: {},
      secondLayer: {},
      thirdLayer: { chartData: [] }
    } as any

    const correctedData = this.cardDataManager.correctCardId(cardData, 0)
    console.log('修正后的卡片数据:', correctedData)

    // 2. 验证卡片数据
    const isValid = this.cardDataManager.validateCardData(correctedData)
    console.log('卡片数据是否有效:', isValid)

    // 3. 获取卡片编号
    const cardNumber = this.cardDataManager.getCardNumber('card_0')
    console.log('卡片编号:', cardNumber)

    // 4. 获取卡片数据摘要
    const summary = this.cardDataManager.getCardDataSummary(correctedData)
    console.log('卡片数据摘要:', summary)
  }

  /**
   * 示例：在组件中使用主题工具
   */
  public exampleThemeUtilsUsage(): void {
    // 1. 获取卡片背景颜色
    const cardBgColor = this.themeUtils.getCardBackgroundColor(false)
    console.log('卡片背景颜色:', cardBgColor)

    // 2. 获取拖拽状态颜色
    const dragColor = this.themeUtils.getDragStateColor(true, false)
    console.log('拖拽状态颜色:', dragColor)

    // 3. 获取波浪图颜色
    const waveColor = this.themeUtils.getWaveColor(0)
    console.log('波浪图颜色:', waveColor)

    // 4. 计算颜色透明度
    const transparentColor = this.themeUtils.calculateColorWithOpacity('#FF0000', 0.5)
    console.log('透明颜色:', transparentColor)

    // 5. 获取阴影样式
    const shadowStyle = this.themeUtils.getShadowStyle(4)
    console.log('阴影样式:', shadowStyle)
  }

  /**
   * 示例：在LevelTable中使用拖拽处理器
   */
  public exampleLevelTableUsage(): void {
    // 1. 处理表格拖拽开始
    const tableDragData: DragData = {
      value: '表格数据',
      sourceTable: '等级表',
      rowIndex: 0,
      colIndex: 1
    }

    this.dragHandlers.handleDragStart(tableDragData)

    // 2. 处理表格拖拽结束
    this.dragHandlers.handleDragEnd(
      () => {
        console.log('表格拖拽到空白区域，执行删除')
      },
      () => {
        console.log('表格拖拽到卡片，执行复制')
      }
    )

    // 3. 处理表格拖拽投放
    this.dragHandlers.handleTableDrop(tableDragData)

    // 4. 处理拖拽到空白区域
    this.dragHandlers.handleBlankAreaDrop(tableDragData)
  }

  /**
   * 示例：综合使用多个模块
   */
  public exampleComprehensiveUsage(): void {
    // 1. 创建拖拽数据
    const dragData = this.dragHandlers.createDragData(
      '综合测试数据',
      '等级表',
      0,
      1,
      'card_0',
      '测试值',
      0
    )

    // 2. 开始拖拽
    this.dragHandlers.handleDragStart(dragData)

    // 3. 获取目标卡片的波浪配置
    const targetCardIndex = 1
    const waveConfig = this.waveConfigManager.getWaveConfig(targetCardIndex)

    // 4. 获取主题颜色
    const themeColor = this.themeUtils.getWaveColor(targetCardIndex)

    // 5. 处理拖拽投放
    this.dragHandlers.handleThirdLayerDrop(
      dragData,
      `card_${targetCardIndex}`,
      true, // 来自其他卡片
      false // 不是来自表格
    )

    // 6. 修正目标卡片数据
    const targetCardData = {
      id: `card_${targetCardIndex}`,
      firstLayer: {},
      secondLayer: {},
      thirdLayer: { chartData: [] }
    } as any

    const correctedData = this.cardDataManager.correctCardId(targetCardData, targetCardIndex)

    console.log('综合使用示例完成:', {
      dragData,
      waveConfig,
      themeColor,
      correctedData
    })
  }
}
