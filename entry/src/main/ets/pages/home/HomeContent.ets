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

  // 数据表格状态
  @State levelTableData: TableRow[] = []
  @State containerTableData: TableRow[] = []
  @State statisticsTableData: TableRow[] = []
  @State dynamicPackingTableData: TableRow[] = []
  @State finishedProductsTableData: TableRow[] = []
  
  // 刷新 Trigger
  @State refreshKey: number = 0

  private dataManager = HomeDataManager.getInstance()

  aboutToAppear() {
    // 注册实例到 AppStorage，供 LiquidCardsArea 调用
    AppStorage.setOrCreate('HOME_CONTENT_REF', this)
    
    // 初始化数据
    this.dataManager.initializeAllTableData()
    this.refreshAllTables()
  }

  aboutToDisappear() {
    AppStorage.setOrCreate('HOME_CONTENT_REF', null)
  }

  onFSMChange() {
    this.dataManager.setFSM(this.selectedFSM)
    this.refreshAllTables()
  }

  public refreshStatisticsTable() {
    this.statisticsTableData = this.dataManager.getTableData('等级统计表')
    this.refreshKey++
    console.log('HomeContent: refreshStatisticsTable triggered')
  }

  private refreshAllTables() {
    this.levelTableData = this.dataManager.getTableData('等级表')
    this.containerTableData = this.dataManager.getTableData('容器表')
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
      // 1. 分选信息卡片 (顶部)
      SortingInfoCard()
        .margin({ bottom: 8 })

      // 2. 液体卡片区域 (中间)
      LiquidCardsArea()
        .height('30%')
        .margin({ bottom: 8 })

      // 3. 数据表格区域 (底部)
      DataTablesTabBar({
        levelTableData: this.levelTableData,
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
    .padding(12)
    // .backgroundColor(this.getCurrentTheme().pageBg ?? this.getCurrentTheme().backgroundColor)
  }
}
