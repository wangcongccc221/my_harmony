import { HomeDataManager } from './core/HomeDataManager'
import { LiquidCardsArea } from './LiquidCardsArea'
import { DataTablesTabBar } from './DataTablesTabBar'
import { SortingInfoCard } from './SortingInfoCard'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY } from '../../utils/theme/useOmniTheme'
import { TableRow } from '../../components/layout/LevelTable'
import { DragData } from '../../components/layout/DraggableGridTable'
import { HOME_SELECTED_FSM } from '../../constants/TopBarKeys'
import { getConfigSender } from '../../protocol/ConfigSender'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { GradeInfoConfigManager } from './core/GradeInfoConfigManager'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { GlobalDataInterface } from '../../protocol/GlobalDataInterface'
import { StGradeInfo, StStatistics } from '../../protocol/Structures'

interface ExtraInfoWrapper {
  extraInfo?: string
}

interface DragPayload {
  type?: string
  sourceTable?: string
  value?: string
  values?: string[]
  rowData?: string[]
  columnData?: string[]
  fullRowData?: string
  fullColumnData?: string
  sourceCardId?: string
  sourceValue?: string
  dragSession?: string
}

interface LevelStatPayload {
  levelName?: string
  exit?: number
}

interface LevelStatBatchPayload {
  levelNames?: string[]
  exit?: number
}

/**
 * 主页内容组件
 * 
 * 功能说明：
 * - 整合主页的三个核心区域：
 *   1. 分选信息卡片 (SortingInfoCard)
 *   2. 液体卡片区域 (LiquidCardsArea)
 *   3. 数据表格区域 (DataTablesTabBar)
 * - 管理数据刷新和交互
 */
@Component
export struct HomeContent {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink('HOME_CONTENT_REF') homeContentRef: HomeContent | null = null
  @StorageLink(HOME_SELECTED_FSM) @Watch('onFSMChange') selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  @StorageLink(StorageKeys.LEVEL_STAT_UPDATE) @Watch('onLevelStatUpdate') private levelStatUpdate: LevelStatPayload | null = null
  @StorageLink(StorageKeys.LEVEL_STAT_REMOVE) @Watch('onLevelStatRemove') private levelStatRemove: LevelStatPayload | null = null
  @StorageLink(StorageKeys.LEVEL_STAT_UPDATE_BATCH) @Watch('onLevelStatBatch') private levelStatBatch: LevelStatBatchPayload | null = null

  // 数据表格状态
  @State levelTableData: TableRow[] = []
  @State levelHeaderTitles: string[] = []
  @State containerTableData: TableRow[] = []
  @State statisticsTableData: TableRow[] = []
  @State dynamicPackingTableData: TableRow[] = []
  @State finishedProductsTableData: TableRow[] = []
  
  // 刷新 Trigger
  @State refreshKey: number = 0

  private dataManager = HomeDataManager.getInstance()
  private dataInterface = GlobalDataInterface.getInstance()
  private statisticsListener: ((stats: StStatistics) => void) | null = null
  private gradeInfoListener: ((info: StGradeInfo) => void) | null = null

  aboutToAppear() {
    // 注册实例到 AppStorage，供 LiquidCardsArea 调用
    AppStorage.setOrCreate('HOME_CONTENT_REF', this)
    
    // 初始化数据
    this.dataManager.initializeAllTableData()
    this.refreshAllTables()
    this.statisticsListener = (_stats: StStatistics) => {
      this.refreshStatisticsTable()
    }
    this.gradeInfoListener = (_info: StGradeInfo) => {
      this.refreshStatisticsTable()
    }
    this.dataInterface.addStatisticsListener(this.statisticsListener)
    this.dataInterface.addGradeInfoListener(this.gradeInfoListener)
  }

  aboutToDisappear() {
    AppStorage.setOrCreate('HOME_CONTENT_REF', null)
    if (this.statisticsListener) {
      this.dataInterface.removeStatisticsListener(this.statisticsListener)
      this.statisticsListener = null
    }
    if (this.gradeInfoListener) {
      this.dataInterface.removeGradeInfoListener(this.gradeInfoListener)
      this.gradeInfoListener = null
    }
  }

  onFSMChange() {
    this.dataManager.setFSM(this.selectedFSM)
    this.refreshAllTables()
  }

  public refreshStatisticsTable() {
    this.dataManager.initializeStatisticsTableData()
    this.statisticsTableData = this.dataManager.getTableData('等级统计表')
    this.refreshKey++
    console.log('HomeContent: refreshStatisticsTable triggered')
  }

  private onLevelStatUpdate() {
    const payload = this.levelStatUpdate
    if (payload && payload.levelName && payload.exit) {
      this.dataManager.updateStatisticsTableExit(payload.levelName, Number(payload.exit))
      this.refreshStatisticsTable()
    }
    AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE, null)
  }

  private onLevelStatRemove() {
    const payload = this.levelStatRemove
    if (payload && payload.levelName && payload.exit) {
      this.dataManager.removeStatisticsTableExit(payload.levelName, Number(payload.exit))
      this.refreshStatisticsTable()
    }
    AppStorage.set(StorageKeys.LEVEL_STAT_REMOVE, null)
  }

  private onLevelStatBatch() {
    const payload = this.levelStatBatch
    if (payload && Array.isArray(payload.levelNames) && payload.levelNames.length > 0 && payload.exit) {
      this.dataManager.updateStatisticsTableExits(payload.levelNames, Number(payload.exit))
      this.refreshStatisticsTable()
    }
    AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE_BATCH, null)
  }

  public refreshAllTables() {
    this.levelTableData = this.dataManager.getTableData('等级表')
    this.levelHeaderTitles = this.dataManager.getLevelTableHeaderTitles()
    this.containerTableData = this.dataManager.getTableData('容器表')
    this.dataManager.initializeStatisticsTableData()
    this.statisticsTableData = this.dataManager.getTableData('等级统计表')
    this.dynamicPackingTableData = this.dataManager.getTableData('动态装箱')
    this.finishedProductsTableData = this.dataManager.getTableData('成品')
    this.refreshKey++
  }

  // // 拖拽回调处理 (示例)
  // private handleRowDragStart(dragData: DragData) {
  //   console.log('HomeContent: Drag started', dragData)
  // }
  //
  // private handleRowDragEnd() {
  //   console.log('HomeContent: Drag ended')
  // }
  //
  // private getCurrentTheme(): ExtendedOmniThemeStyle {
  //   return resolveTheme(this.consumedTheme)
  // }

  build() {
    Column() {
      // 1. 液体卡片区域 (顶部)
      LiquidCardsArea({
        onCardClick: (cardIndex) => {
          AppStorage.set('HOME_LIQUID_CARD_DOUBLE_CLICK_INDEX', cardIndex + 1)
        }
      })
        .height('38%')
        .margin({ bottom: '1%' })

      // 2. 分选信息卡片 (中间)
      SortingInfoCard()
        .margin({ bottom: 8 })

      // 3. 数据表格区域 (底部)
      DataTablesTabBar({
        levelTableData: this.levelTableData,
        levelHeaderTitles: this.levelHeaderTitles,
        containerTableData: this.containerTableData,
        statisticsTableData: this.statisticsTableData,
        dynamicPackingTableData: this.dynamicPackingTableData,
        finishedProductsTableData: this.finishedProductsTableData,
        refreshKey: this.refreshKey,
        //先注释掉 不值得用
        // onRowDragStart: (data) => this.handleRowDragStart(data),
        // onRowDragEnd: () => this.handleRowDragEnd()
      })
      .layoutWeight(1) // 占据剩余空间
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 0 })
    // .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
  }
}
