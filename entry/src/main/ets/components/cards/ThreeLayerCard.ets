import { getCurrentCellDragData, CellDragData, CELL_DRAG_ACTIVE_KEY, CELL_DRAG_STORAGE_KEY, MULTI_SELECT_CELLS_KEY, MULTI_SELECT_ACTIVE_KEY, CLEAR_ALL_HIGHLIGHTS_KEY } from '../ui/tables/SimpleDraggableCell'
import { DragData as GridDragData, GRID_DRAG_DATA_KEY, GRID_DRAG_ACTIVE_KEY } from '../layout/DraggableGridTable'
// 导入模块化的拖拽管理器
import { DragManager, DragData as ModuleDragData } from '../../utils/ui/DragManager'
import { DragHandlers } from '../../utils/ui/DragHandlers'
import { GlobalCardDataManager } from '../../utils/managers/GlobalCardDataManager'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { ExitConfigManager, FsmKey, OutletConfig } from '../../pages/home/core/ExitConfigManager'

import { WaveCard } from '../charts/WaveCard'

// 导入新的模块化组件
import { 
  SystemWrapper, 
  OuterDropParsed, 
  ThirdLayerDragPayload, 
  FirstLayerData, 
  SecondLayerData, 
  ThirdLayerData, 
  ThreeLayerCardData,
  FirstLayerDataInterface,
  SecondLayerDataInterface,
  ThirdLayerDataInterface,
  DragData,
  RemoveSourceData,
  DragConfig,
  DragOuterPayload,
  LoosePayload,
  LevelStatBatchPayload,
  MultiSelectCell
} from '../ThreeLayerCard/types'
import { UseCardLogic } from '../ThreeLayerCard/hooks/useCardLogic'
import { UseDragHandlers } from '../ThreeLayerCard/hooks/useDragHandlers'
import { UseDragDrop } from '../ThreeLayerCard/hooks/useDragDrop'
import { UseCardState } from '../ThreeLayerCard/hooks/useCardState'
import { UseDataSync, SyncState } from '../ThreeLayerCard/hooks/useDataSync'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { FirstLayer } from '../ThreeLayerCard/FirstLayer'
import { SecondLayer } from '../ThreeLayerCard/SecondLayer'
import { ThirdLayer } from '../ThreeLayerCard/ThirdLayer'
import { CardColorConfig } from '../../utils/theme/CardColors'
import { HomeDataManager } from '../../pages/home/core/HomeDataManager'
import { OmniUIUtils } from '../../utils/helpers/OmniUIUtils'

// 接口定义已移至 ThreeLayerCard/types.ets
export { ThreeLayerCardData } from '../ThreeLayerCard/types'

interface CardMouseEvent {
  button?: number
}

interface ClipboardPayload {
  chartData: number[]
  chartDataStrings?: string[]
  hasOriginalFormatData?: boolean
}

@Component
export struct ThreeLayerCard {
  // 卡片数据
  @Prop cardData: ThreeLayerCardData
  
  // 卡片尺寸
  @Prop cardWidth: string | number = 150
  @Prop cardHeight: string | number = 200
  
  // 主色调
  @Prop mainColor: string | number | Color = '#EA7A10'
  // 控制第三层是否显示波浪图
  @Prop enableWave: boolean = false
  
  // 拖拽回调
  onCardDrop?: (data: ThreeLayerCardData) => void
  // 第三层点击回调
  onThirdLayerClick?: () => void
  @State private isHovering: boolean = false
  // 本地可见渲染用列表，确保立即可见
  @State private localChartData: number[] = []
  @State private localChartDataStrings: string[] = [] // 存储原始字符串（包括%符号）
  @State private hasOriginalFormatData: boolean = false // 标记是否包含原始格式数据
  // 第三层条目拖拽的本地兜底缓存（避免AppStorage丢失）
  @State private pendingDragValue: string = ''
  @State private pendingDragIndex: number = -1
  @State private showContextMenu: boolean = false
  private readonly clipboardKey: string = 'LIQUID_CARD_CLIPBOARD'
  
  // 模块化的拖拽管理器
  private dragManager: DragManager = DragManager.getInstance()
  private dragHandlers: DragHandlers = new DragHandlers()

  aboutToAppear() {
    // 初始化本地可见数组，避免首次为空看不到
    this.syncLocalData()
    console.log('ThreeLayerCard aboutToAppear - 同步数据:', JSON.stringify(this.localChartData))
  }
  
  aboutToUpdate() {
    // 同步本地数据，确保UI更新
    this.syncLocalData()
  }

  
  private syncLocalData(): void {
    const next = UseDataSync.syncLocalData(this.cardData, {
      localChartData: this.localChartData,
      localChartDataStrings: this.localChartDataStrings,
      hasOriginalFormatData: this.hasOriginalFormatData
    })
    this.localChartData = next.localChartData
    this.localChartDataStrings = next.localChartDataStrings
    this.hasOriginalFormatData = next.hasOriginalFormatData
  }
  
  // 删除第三层项目的方法
  private deleteItemFromThirdLayer(): void {
    // 直接使用当前本地数据进行删除，不强制同步父组件数据，避免多选拖拽后父组件数据更新延迟导致的数据丢失
    const current: SyncState = {
      localChartData: this.localChartData,
      localChartDataStrings: this.localChartDataStrings,
      hasOriginalFormatData: this.hasOriginalFormatData
    }
    const afterDel = UseDataSync.deleteItemFromThirdLayer(current, this.pendingDragValue, this.pendingDragIndex)
    this.localChartData = afterDel.localChartData
    this.localChartDataStrings = afterDel.localChartDataStrings
    this.hasOriginalFormatData = afterDel.hasOriginalFormatData
    UseDataSync.updateCardData(this.cardData, this.localChartData, this.localChartDataStrings, this.onCardDrop)
    this.pendingDragValue = ''
    this.pendingDragIndex = -1
  }
  
  // 更新卡片数据的方法
  private updateCardData(newChartData: number[]): void {
    UseDataSync.updateCardData(this.cardData, newChartData, this.localChartDataStrings, this.onCardDrop)
  }
  
  private getCurrentTheme() {
    return UseCardLogic.getCurrentTheme()
  }

  private getCardColors() {
    return UseCardLogic.getCardColors()
  }
  
  private clampPercent(v: number): number {
    return UseCardLogic.clampPercent(v)
  }

  private getSelectedFsm(): FsmKey {
    const value = AppStorage.get(HOME_SELECTED_FSM) as FsmKey | undefined
    return value ?? 'FSM1'
  }

  private getExitConfig(): OutletConfig {
    const fsm = this.getSelectedFsm()
    const exitIndex = this.getCardNumber()
    return ExitConfigManager.getInstance().getExitConfig(fsm, exitIndex)
  }

  private async setExitEnabled(enabled: boolean): Promise<void> {
    const fsm = this.getSelectedFsm()
    const exitIndex = this.getCardNumber()
    const config = ExitConfigManager.getInstance().getExitConfig(fsm, exitIndex)
    config.outletEnable = enabled ? '开启' : '关闭'
    config.enabled = enabled
    ExitConfigManager.getInstance().setExitConfig(fsm, config)
    await ExitConfigManager.getInstance().sendExitConfig(fsm)
  }

  private clearCardMapping(): void {
    const cardId = String(this.cardData.id || '')
    const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
    if (!mapRaw || !mapRaw[cardId]) {
      return
    }
    const next: Record<string, Record<string, string>> = {}
    Object.keys(mapRaw).forEach(key => {
      if (key !== cardId) {
        next[key] = mapRaw[key]
      }
    })
    AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', next)
  }

  private clearCardData(): void {
    this.localChartData = []
    this.localChartDataStrings = []
    this.hasOriginalFormatData = false
    this.clearCardMapping()
    UseDataSync.updateCardData(this.cardData, [], [], this.onCardDrop)
  }

  private copyCardData(): void {
    const payload: ClipboardPayload = {
      chartData: this.localChartData.slice(),
      chartDataStrings: this.localChartDataStrings.slice(),
      hasOriginalFormatData: this.hasOriginalFormatData
    }
    AppStorage.setOrCreate(this.clipboardKey, payload)
  }

  private hasClipboardData(): boolean {
    const payload = AppStorage.get(this.clipboardKey) as ClipboardPayload | undefined
    return !!payload && Array.isArray(payload.chartData) && payload.chartData.length > 0
  }

  private pasteCardData(): void {
    const payload = AppStorage.get(this.clipboardKey) as ClipboardPayload | undefined
    if (!payload || !Array.isArray(payload.chartData)) {
      return
    }
    const nextData = payload.chartData.slice()
    const nextStrings = Array.isArray(payload.chartDataStrings) && payload.chartDataStrings.length > 0
      ? payload.chartDataStrings.slice()
      : nextData.map(item => String(item))
    const hasOriginal = typeof payload.hasOriginalFormatData === 'boolean'
      ? payload.hasOriginalFormatData
      : nextStrings.some(str => str.includes('%'))
    this.localChartData = nextData
    this.localChartDataStrings = nextStrings
    this.hasOriginalFormatData = hasOriginal
    UseDataSync.updateCardData(this.cardData, nextData, nextStrings, this.onCardDrop)
  }

  private cutCardData(): void {
    this.copyCardData()
    this.clearCardData()
  }

  private isExitRunning(): boolean {
    const config = this.getExitConfig()
    return config.outletEnable === '开启' && config.enabled
  }

  private canPaste(): boolean {
    return this.hasClipboardData()
  }

  private getMappedLevelNames(): string[] {
    const cardId = String(this.cardData.id || '')
    const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
    if (!mapRaw || !mapRaw[cardId]) {
      return []
    }
    const names = Object.values(mapRaw[cardId]).map(v => String(v ?? '')).filter(v => v.length > 0)
    return Array.from(new Set(names))
  }

  private splitExitLabels(value: string): string[] {
    if (!value) {
      return []
    }
    return value.split(/[,，/、\s]+/).map(item => item.trim()).filter(item => item.length > 0)
  }

  private getLevelsOnlyInThisExit(): string[] {
    const exitNumber = this.getCardNumber()
    const exitLabel = `出口${exitNumber}`
    const dataManager = HomeDataManager.getInstance()
    dataManager.setFSM(this.getSelectedFsm())
    const rows = dataManager.getTableData('等级统计表')
    const targets = new Set(this.getMappedLevelNames())
    const result: string[] = []
    rows.forEach(row => {
      const levelName = String(row[0] ?? '')
      if (!targets.has(levelName)) {
        return
      }
      const labels = this.splitExitLabels(String(row[2] ?? ''))
      if (labels.length === 1 && labels[0] === exitLabel) {
        result.push(levelName)
      }
    })
    return result
  }

  private removeExitFromStatistics(levelNames: string[], exit: number): void {
    if (!Array.isArray(levelNames) || levelNames.length === 0) {
      return
    }
    levelNames.forEach(levelName => {
      AppStorage.setOrCreate(StorageKeys.LEVEL_STAT_REMOVE, { levelName: levelName, exit: exit })
    })
  }
  
  // 根据卡片ID获取波浪图高度百分比：使用实时数据
  private getWaveHeightPercent(): number {
    // 优先使用卡片数据中的实时百分比
    if (this.cardData && this.cardData.secondLayer && typeof this.cardData.secondLayer.percent === 'number') {
      return this.cardData.secondLayer.percent
    }
    return UseCardLogic.getWaveHeightPercent(this.cardData)
  }
  
  // 根据卡片ID获取波浪基准位置百分比：第1/2/3张卡分别 20%/40%/60%
  private getWaveBaselinePercent(): number {
    return UseCardLogic.getWaveBaselinePercent(this.cardData)
  }
  
  // 获取卡片序号（从card_0, card_1等格式中提取数字+1）
  private getCardNumber(): number {
    return UseCardLogic.getCardNumber(this.cardData)
  }

  // 获取卡片索引（从card_0, card_1等格式中提取数字）
  private getCardIndex(): number {
    return UseCardLogic.getCardIndex(this.cardData)
  }

  // 判断卡片是否为空白格子（没有数据且不显示波浪图）
  private isEmptyCard(): boolean {
    const hasData = this.localChartData && this.localChartData.length > 0
    const hasWave = this.enableWave
    // 注意：如果有数据 OR 有波浪，都不算空卡片
    return !hasData && !hasWave
  }


  /**
   * 处理SimpleDraggableCell的拖拽投放
   * @param dragData 拖拽数据
   */
  private handleCellDragDrop(dragData: CellDragData): void {
    console.log('处理SimpleDraggableCell拖拽数据:', dragData)
    UseDragDrop.handleCellDragDrop(
      this.cardData,
      String(dragData.value),
      String(dragData.sourceTable || '等级表'),
      Number(dragData.rowIndex || 0),
      Number(dragData.colIndex || 0),
      this.onCardDrop
    )
    AppStorage.set(CELL_DRAG_ACTIVE_KEY, false)
  }

  /**
   * 获取当前Grid拖拽数据
   */
  private getCurrentGridDragData(): GridDragData | null {
    const data = AppStorage.get(GRID_DRAG_DATA_KEY) as GridDragData | null
    return data ?? null
  }

  /**
   * 处理Grid拖拽投放
   * @param dragData Grid拖拽数据
   */
  private handleGridDragDrop(dragData: GridDragData): void {
    console.log('处理Grid拖拽数据:', dragData)
    UseDragDrop.handleGridDragDrop(
      this.cardData,
      String(dragData.item.text),
      String(dragData.sourceTable || '等级表'),
      Number(dragData.item.rowIndex || 0),
      Number(dragData.item.colIndex || 0),
      this.onCardDrop
    )
  }

  /**
   * 触发移除源卡片数据
   */
  private triggerRemoveSourceData(): void {
    const removeData = AppStorage.get('REMOVE_SOURCE_DATA') as RemoveSourceData | null
    if (removeData && removeData.sourceCardId && removeData.sourceValue) {
      console.log('ThreeLayerCard触发移除源卡片数据:', removeData)
      // 通过AppStorage发送移除信号
      AppStorage.set('FORCE_REMOVE_SOURCE', removeData)
      // 清除原始移除数据
      AppStorage.set('REMOVE_SOURCE_DATA', null)
    }
  }

  /**
   * 处理多选拖拽投放
   * @param cells 选中的单元格数组
   */
  private handleMultiSelectDrop(cells: MultiSelectCell[], levelNames?: string[]): void {
    console.log('🎯 处理多选拖拽，单元格数量:', cells.length)
    const result = UseDragDrop.handleMultiSelectDrop(this.cardData, cells, levelNames, this.onCardDrop)
    this.localChartData = result.localChartData
    this.localChartDataStrings = result.localChartDataStrings
    this.hasOriginalFormatData = result.hasOriginalFormatData

    // 来自等级表的多选：按等级名去重，批量上报出口统计（保留原逻辑）
    try {
      const sourceIsLevelTable = String(cells[0]?.sourceTable || '') === '等级表'
      if (sourceIsLevelTable) {
        try {
          if (Array.isArray(levelNames) && levelNames.length === cells.length) {
            const cardId = String(this.cardData.id || '')
            const mapRaw = AppStorage.get('CARD_ITEM_LEVEL_MAP') as Record<string, Record<string, string>> | null
            let mapObj: Record<string, Record<string, string>> = mapRaw ? mapRaw : {}
            
            // 限制映射大小，防止内存泄漏
            const MAX_MAPPINGS_PER_CARD = 1000
            const MAX_CARDS = 50
            const cardIds = Object.keys(mapObj)
            if (cardIds.length > MAX_CARDS) {
              const limited: Record<string, Record<string, string>> = {}
              cardIds.slice(-MAX_CARDS).forEach(cid => {
                limited[cid] = mapObj[cid]
              })
              mapObj = limited
            }
            
            if (!mapObj[cardId]) { mapObj[cardId] = {} }
            const cardKeys = Object.keys(mapObj[cardId])
            for (let i = 0; i < cells.length; i++) {
              const valStr = String(cells[i]?.value ?? '')
              const ln = String(levelNames[i] ?? '')
              if (valStr && ln) {
                // 如果超过限制，移除最旧的映射（使用重新创建对象的方式，避免使用 delete）
                if (cardKeys.length >= MAX_MAPPINGS_PER_CARD && !mapObj[cardId][valStr]) {
                  const oldestKey = cardKeys[0]
                  // 重新创建对象，排除要删除的键
                  const newCardMap: Record<string, string> = {}
                  Object.keys(mapObj[cardId]).forEach(key => {
                    if (key !== oldestKey) {
                      newCardMap[key] = mapObj[cardId][key]
                    }
                  })
                  mapObj[cardId] = newCardMap
                  cardKeys.shift()
                }
                mapObj[cardId][valStr] = ln
                if (!cardKeys.includes(valStr)) {
                  cardKeys.push(valStr)
                }
              }
            }
            AppStorage.setOrCreate('CARD_ITEM_LEVEL_MAP', mapObj)
          }
        } catch (_e) {}
        let collected: string[] = Array.isArray(levelNames) ? levelNames : []
        if (!Array.isArray(levelNames) || levelNames.length === 0) {
          collected = cells.map((_cell: MultiSelectCell) => '')
        }
        const uniqueLevels = Array.from(new Set(collected)).filter(s => s && s.length > 0)
        if (uniqueLevels.length > 0) {
          const exitNum = this.getCardNumber()
          const batchPayload: LevelStatBatchPayload = { levelNames: uniqueLevels, exit: exitNum }
          AppStorage.setOrCreate('LEVEL_STAT_UPDATE_BATCH', batchPayload)
        }
      }
    } catch (_e) {}
    
    console.log('多选拖拽完成，当前本地数量:', this.localChartData.length)
  }

  /**
   * 处理第三层的拖拽投放事件
   * @param event 拖拽事件
   * @param extraParams 额外参数
   */
  private handleThirdLayerDrop(event: DragEvent, extraParams: string): void {
    if (!extraParams) {
      UseCardState.resetDragStates()
      this.isHovering = false
            return
          }
    try {
      const next = UseDragDrop.handleThirdLayerDrop(
        extraParams,
        this.cardData,
        {
          localChartData: this.localChartData,
          localChartDataStrings: this.localChartDataStrings,
          hasOriginalFormatData: this.hasOriginalFormatData
        },
        this.onCardDrop,
        () => this.getCardNumber()
      )
      this.localChartData = next.localChartData
      this.localChartDataStrings = next.localChartDataStrings
      this.hasOriginalFormatData = next.hasOriginalFormatData
      } catch (error) {
      console.error('处理拖拽数据失败:', error)
    }
    UseCardState.resetDragStates()
    this.isHovering = false
  }

  private handleMouseEvent(event?: CardMouseEvent): void {
    if (!event) {
      return
    }
    if (event.button === 2) {
      this.showContextMenu = true
    }
  }
  
  @Builder
  private buildContextMenu() {
    Column() {
      Button() {
        Text('启动')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .enabled(!this.isExitRunning())
      .onClick(() => {
        this.showContextMenu = false
        this.setExitEnabled(true)
      })
      Button() {
        Text('暂停')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .enabled(this.isExitRunning())
      .onClick(() => {
        this.showContextMenu = false
        this.setExitEnabled(false)
        const lost = this.getLevelsOnlyInThisExit()
        if (lost.length > 0) {
          OmniUIUtils.getInstance().showInfo(`以下等级仅在出口${this.getCardNumber()}：${lost.join('、')}`)
        }
      })
      Button() {
        Text('打开')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .onClick(() => {
        this.showContextMenu = false
        if (!this.isExitRunning()) {
          return
        }
        if (this.onThirdLayerClick) {
          this.onThirdLayerClick()
        }
      })
      Button() {
        Text('清空')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .onClick(() => {
        this.showContextMenu = false
        if (!this.isExitRunning()) {
          return
        }
        const levelNames = this.getMappedLevelNames()
        this.removeExitFromStatistics(levelNames, this.getCardNumber())
        this.clearCardData()
      })
      Button() {
        Text('复制')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .onClick(() => {
        this.showContextMenu = false
        this.copyCardData()
      })
      Button() {
        Text('剪切')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .onClick(() => {
        this.showContextMenu = false
        if (!this.isExitRunning()) {
          return
        }
        const levelNames = this.getMappedLevelNames()
        this.removeExitFromStatistics(levelNames, this.getCardNumber())
        this.cutCardData()
      })
      Button() {
        Text('粘贴')
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .width(140)
      .height(40)
      .backgroundColor(Color.Transparent)
      .stateEffect(true)
      .enabled(this.canPaste())
      .onClick(() => {
        this.showContextMenu = false
        this.pasteCardData()
      })
    }
    .width(160)
    .padding(4)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .borderRadius(12)
    .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.12)', offsetX: 0, offsetY: 4 })
    .border({ width: 1, color: this.getCurrentTheme().borderColor + '40' })
  }

  build() {
    Column() {
      // 第一层：图片/文字层
      FirstLayer({
        cardData: this.cardData,
        cardColors: this.getCardColors()
      })
      
      // 第一层和第二层之间的分隔线
      Divider()
        .strokeWidth(1)
        .color(this.getCardColors().cardBorder)
        .opacity(0.8)
      
      // 第二层：信息显示层
      SecondLayer({
        cardData: this.cardData,
        enableWave: this.enableWave,
        cardColors: this.getCardColors(),
        cardNumber: this.getCardNumber(),
        waveHeightPercent: this.getWaveHeightPercent()
      })
      
      // 第二层和第三层之间的分隔线
      Divider()
        .strokeWidth(1)
        .color(this.getCardColors().cardBorder)
        .opacity(0.8)
      
      // 第三层：波形图层（支持拖拽投放）
      ThirdLayer({
        cardData: this.cardData,
        enableWave: this.enableWave,
        localChartData: this.localChartData,
        localChartDataStrings: this.localChartDataStrings,
        hasOriginalFormatData: this.hasOriginalFormatData,
        pendingDragValue: this.pendingDragValue,
        pendingDragIndex: this.pendingDragIndex,
        cardColors: this.getCardColors(),
        waveHeightPercent: this.getWaveHeightPercent(),
        waveBaselinePercent: this.getWaveBaselinePercent(),
        cardNumber: this.getCardNumber(),
        onCachePending: (value: string, index: number) => {
          // 同步子组件的拖拽缓存到父组件，确保删除逻辑可命中
          this.pendingDragValue = value
          this.pendingDragIndex = index
        },
        onDropCallback: (event, params) => this.handleThirdLayerDrop(event, params),
        onDragEnterCallback: () => { this.isHovering = true },
        onDragLeaveCallback: () => { this.isHovering = false },
        onTouchCallback: () => {
          // 检查是否有Grid拖拽数据
          const gridDragData = this.getCurrentGridDragData()
          if (gridDragData) {
            console.log('第三层接收到Grid拖拽数据:', gridDragData)
            this.handleGridDragDrop(gridDragData)
          }
        },
        onClickCallback: () => {
          // 点击第三层时通知父组件
          console.log('第三层被点击，通知父组件显示详情对话框')
          if (this.onThirdLayerClick) {
            this.onThirdLayerClick()
          }
        },
        deleteItemFromThirdLayer: () => this.deleteItemFromThirdLayer()
      })
    }
    .width(this.cardWidth)
    .height(this.cardHeight)
    .backgroundColor(this.isEmptyCard() ? '#f8fafc' : '#E6F0FF') // 空白卡片：浅色背景(#f8fafc)；有数据的卡片：柔和的深蓝色背景(#E6F0FF)
    .borderRadius(12) // Apple风格：中等圆角
    .border({ width: 0.5, color: UseCardLogic.getCardColors().cardBorder }) // Apple风格：细边框
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 }) // Apple风格：柔和阴影
    .clip(true) // 裁剪子组件
    .onMouse((event?: CardMouseEvent) => {
      this.handleMouseEvent(event)
    })
    .onClick(() => {
      this.showContextMenu = false
      this.onCardDrop?.(this.cardData)
    })
    .bindContextMenu(this.showContextMenu, this.buildContextMenu, {
      placement: Placement.Right
    })
    // 大卡片外层：落在卡片容器（第一/第二层或卡片边内空白）视为"内容不变"
    .onDrop((event: DragEvent, extraParams: string) => {
      UseDragDrop.handleOuterDrop(extraParams)
      // 外层容器不改变 handled 标志，避免覆盖真实目标层的处理结果
    })
  }
  
  /**
   * 构建拖拽预览
   */
  @Builder
  private buildDragPreview(value: number) {
    Text(`${value}`)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .backgroundColor(this.mainColor)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(4)
  }
}
