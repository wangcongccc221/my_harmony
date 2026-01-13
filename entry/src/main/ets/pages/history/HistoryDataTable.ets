import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'
import { HistoryTableManager, HistoryTableData } from './core/HistoryTableManager'
import { TableHeaderCell } from '../../components/ui/tables/TableHeaderCell'
import { TableCell } from '../../components/ui/tables/TableCell'

interface ListDataChangeListener {
  onDataReload?: () => void
  onDataAdd?: (index: number) => void
  onDataDelete?: (index: number) => void
  onDataChange?: (index: number) => void
  onDataMove?: (from: number, to: number) => void
}

class HistoryTableLazyDataSource implements IDataSource {
  private listeners: ListDataChangeListener[] = []
  private data: HistoryTableData[]

  constructor(data: HistoryTableData[] = []) {
    this.data = data
  }

  updateData(data: HistoryTableData[]): void {
    this.data = data
    this.notifyDataReload()
  }

  private notifyDataReload(): void {
    this.listeners.forEach(listener => listener.onDataReload && listener.onDataReload())
  }

  totalCount(): number {
    return this.data.length
  }

  getData(index: number): HistoryTableData {
    return this.data[index]
  }

  registerDataChangeListener(listener: ListDataChangeListener): void {
    if (!listener || this.listeners.includes(listener)) {
      return
    }
    this.listeners.push(listener)
  }

  unregisterDataChangeListener(listener?: ListDataChangeListener): void {
    if (!listener) {
      this.listeners = []
      return
    }
    this.listeners = this.listeners.filter(item => item !== listener)
  }
}

/**
 * 历史数据表格组件
 */
@Component
export struct HistoryDataTable {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  
  // 提供主题给子组件
  @Provide providedTheme: ExtendedOmniThemeStyle = this.consumedTheme
  
  private tableManager = HistoryTableManager.getInstance()
  
  // 选中状态管理
  @State private selectedIds: number[] = []
  // 表格数据状态
  @State private tableData: HistoryTableData[] = []
  // 外部传入的筛选数据（使用空数组作为默认值，避免可选参数）
  @Prop @Watch('onFilteredDataChange') filteredData: HistoryTableData[] = []
  // 是否处于筛选模式
  @Prop @Watch('onFilterModeChange') isFilterMode: boolean = false
  // 外部传入的全部数据（用于重置功能，显示所有数据）
  @Prop externalData: HistoryTableData[] = []
  // 防重复加载标志，避免aboutToUpdate循环触发
  private isLoading: boolean = false
  private lastUpdateKey: number = 0
  @State private page: number = 1
  @State private pageSize: number = 50
  @State private hasMore: boolean = true
  private isLoadingMore: boolean = false
  // 页面可见性标志：只有页面可见时才刷新UI
  @State private isPageVisible: boolean = false
  private lazyDataSource: HistoryTableLazyDataSource = new HistoryTableLazyDataSource([])

  // 事件回调
  onRowClick?: (rowData: HistoryTableData) => void
  onDoubleClick?: (rowData: HistoryTableData) => void
  onEditClick?: (rowData: HistoryTableData) => void
  onDeleteClick?: (rowData: HistoryTableData) => void
  onDataChange?: (data: HistoryTableData[]) => void
  onSelectionChange?: (selectedIds: number[]) => void

  // 双击检测相关状态
  @State private lastClickTime: number = 0
  @State private lastClickItemId: number = -1
  private readonly DOUBLE_CLICK_INTERVAL: number = 300 // 双击间隔时间（毫秒）
  private clickTimer: number = -1 // 用于延迟执行单击事件

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  /**
   * 获取状态颜色
   */
  private getStatusColor(status: string): Color {
    switch (status) {
      case '已完成':
        return Color.Green
      case '进行中':
        return Color.Orange
      case '待开始':
        return Color.Gray
      default:
        return Color.Black
    }
  }

  /**
   * 处理行点击
   */
  private handleRowClick(rowData: HistoryTableData): void {
    console.log('行点击:', rowData)
    this.onRowClick?.(rowData)
  }

  /**
   * 处理双击事件
   */
  private handleDoubleClick(rowData: HistoryTableData): void {
    console.log('行双击:', rowData)
    // 清除延迟的单击事件
    if (this.clickTimer !== -1) {
      clearTimeout(this.clickTimer)
      this.clickTimer = -1
    }
    this.onDoubleClick?.(rowData)
  }

  /**
   * 处理触摸事件（用于检测双击）
   */
  private handleTouchEvent(event: TouchEvent | undefined, item: HistoryTableData): void {
    if (!event) return
    
    const currentTime = Date.now()
    const isDoubleClick = (currentTime - this.lastClickTime < this.DOUBLE_CLICK_INTERVAL) && 
                         (this.lastClickItemId === item.id)
    
    if (isDoubleClick) {
      // 检测到双击
      this.handleDoubleClick(item)
      // 重置状态
      this.lastClickTime = 0
      this.lastClickItemId = -1
    } else {
      // 可能是单击，延迟执行
      this.lastClickTime = currentTime
      this.lastClickItemId = item.id
      
      // 清除之前的延迟
      if (this.clickTimer !== -1) {
        clearTimeout(this.clickTimer)
      }
      
      // 延迟执行单击事件，如果在延迟期间发生双击，则取消单击
      const timer: number = setTimeout(() => {
        this.handleRowClick(item)
        this.clickTimer = -1
      }, this.DOUBLE_CLICK_INTERVAL)
      this.clickTimer = timer
    }
  }

  /**
   * 处理编辑点击
   */
  private handleEditClick(rowData: HistoryTableData): void {
    console.log('编辑点击:', rowData)
    this.onEditClick?.(rowData)
  }

  /**
   * 处理删除点击
   */
  private handleDeleteClick(rowData: HistoryTableData): void {
    console.log('删除点击:', rowData)
    this.onDeleteClick?.(rowData)
  }

  /**
   * 处理复选框选择
   */
  private handleCheckboxChange(id: number, checked: boolean): void {
    if (checked) {
      if (!this.selectedIds.includes(id)) {
        this.selectedIds.push(id)
      }
    } else {
      this.selectedIds = this.selectedIds.filter(selectedId => selectedId !== id)
    }
    
    console.log('选中项:', this.selectedIds)
    this.onSelectionChange?.(this.selectedIds)
  }

  /**
   * 检查是否选中
   */
  private isSelected(id: number): boolean {
    return this.selectedIds.includes(id)
  }

  /**
   * 监听筛选数据变化
   */
  private onFilteredDataChange(): void {
    if (this.isFilterMode) {
      console.log('HistoryDataTable: 筛选数据更新，共', this.filteredData.length, '条')
      this.syncLazyDataSource()
      if (this.onDataChange) {
        this.onDataChange(this.filteredData)
      }
    }
  }

  /**
   * 监听筛选模式变化
   */
  private onFilterModeChange(): void {
    console.log('HistoryDataTable: 筛选模式变更为', this.isFilterMode)
    this.syncLazyDataSource()
  }

  /**
   * 获取当前表格数据
   */
  getCurrentData(): HistoryTableData[] {
    return this.getDisplayData();
  }

  /**
   * 从数据库加载数据
   */
  private async loadData(): Promise<void> {
    try {
      console.log('HistoryDataTable loadData: 开始从数据库分页加载数据')
      const data = await this.tableManager.getPage(this.page, this.pageSize)
      console.log('HistoryDataTable loadData: 获取到分页数据', data.length, '条')
      // 更新 @State tableData，这会触发UI重新渲染
      this.tableData = data
      console.log('HistoryDataTable loadData: tableData已更新，长度:', this.tableData.length)
      this.syncLazyDataSource()
      // 通知父组件数据变化
      if (this.onDataChange) {
        this.onDataChange(this.tableData)
      }
      this.hasMore = data.length >= this.pageSize
    } catch (error) {
      console.error('HistoryDataTable loadData: 加载数据失败', error)
      this.tableData = []
    }
  }

  /**
   * 获取要显示的数据（优先使用 externalData，然后是筛选数据，最后是分页数据）
   */
  private getDisplayData(): HistoryTableData[] {
    // 如果提供了 externalData（重置功能），使用它并支持分页显示
    if (this.externalData && this.externalData.length > 0) {
      return [...this.externalData]
    }
    // 如果处于筛选模式，使用筛选数据（即使为空也返回，显示无数据）
    if (this.isFilterMode) {
      return [...this.filteredData]
    }
    // 否则使用分页数据
    return [...this.tableData]
  }

  private syncLazyDataSource(): void {
    this.lazyDataSource.updateData(this.getDisplayData())
  }

  /**
   * 公开的刷新方法（供外部调用）
   */
  public async refreshData(): Promise<void> {
    await this.loadData()
  }

  /**
   * 组件挂载时从数据库加载数据
   */
  aboutToAppear() {
    console.log('HistoryDataTable aboutToAppear: 组件已挂载，页面可见')
    // 标记页面为可见状态
    this.isPageVisible = true
    
    // 如果提供了 externalData（重置功能），直接展示全部
    if (this.externalData && this.externalData.length > 0) {
      console.log(`重置功能：直接展示 ${this.externalData.length} 条数据`)
      this.syncLazyDataSource()
      return
    }
    // 如果处于筛选模式，直接显示筛选数据（即使为空）
    if (this.isFilterMode) {
      console.log(`筛选模式：直接展示 ${this.filteredData.length} 条数据`)
      this.syncLazyDataSource()
      return
    }
    // 若父组件已传入筛选数据，则直接显示，避免重新加载覆盖筛选结果
    if (this.filteredData && this.filteredData.length > 0) {
      this.syncLazyDataSource()
      return
    }
    // 否则加载分页数据（页面可见时才加载）
    this.loadData().then(() => {
      console.log('HistoryDataTable aboutToAppear: 数据加载完成')
    }).catch((error: Error) => {
      console.error('HistoryDataTable aboutToAppear: 数据加载失败', error)
    })
  }

  /**
   * 组件消失时标记页面为不可见
   */
  aboutToDisappear() {
    console.log('HistoryDataTable aboutToDisappear: 组件已隐藏，停止UI刷新')
    // 标记页面为不可见状态，停止后台刷新
    this.isPageVisible = false
  }

  /**
   * 组件更新时检查筛选数据和数据变化
   * 优化：只有页面可见时才刷新UI，避免后台不必要的刷新
   */
  aboutToUpdate() {
    // 如果页面不可见，不执行任何刷新操作（性能优化）
    if (!this.isPageVisible) {
      return
    }
    
    // 如果提供了 externalData（重置功能），直接使用
    if (this.externalData && this.externalData.length > 0) {
      this.syncLazyDataSource()
      return
    }

    // 如果处于筛选模式，由 @Watch 处理，不需要在这里处理
    if (this.isFilterMode) {
      return
    }
    
    // 否则加载分页数据（用于"重置"等场景）
    // 添加防重复加载机制，避免循环触发
    if (!this.isLoading) {
      this.isLoading = true
      const currentKey = Date.now()
      this.lastUpdateKey = currentKey
      // 使用异步延迟，避免在更新过程中同步加载导致循环
      Promise.resolve().then(() => {
        // 再次检查页面可见性（可能在异步过程中页面已隐藏）
        if (!this.isPageVisible) {
          this.isLoading = false
          return
        }
        // 检查是否仍然是最新的更新请求
        if (this.lastUpdateKey === currentKey) {
          this.loadData().then(() => {
            this.isLoading = false
            // 清空选中状态（当数据更新时，避免选中已删除的数据）
            this.selectedIds = []
          }).catch(() => {
            this.isLoading = false
          })
        } else {
          this.isLoading = false
        }
      })
    }
  }

  private async loadMore(): Promise<void> {
    // 如果提供了 externalData（重置功能），已经一次性展示全部数据
    if (this.externalData && this.externalData.length > 0) {
      return
    }
    
    // 如果提供了筛选数据，不支持加载更多
    if (this.filteredData && this.filteredData.length > 0) return
    
    // 否则从数据库加载更多分页数据
    if (this.isLoadingMore || !this.hasMore) return
    this.isLoadingMore = true
    const nextPage = this.page + 1
    try {
      const more = await this.tableManager.getPage(nextPage, this.pageSize)
      if (more.length > 0) {
        this.tableData = this.tableData.concat(more)
        this.page = nextPage
        this.hasMore = more.length >= this.pageSize
        this.syncLazyDataSource()
        if (this.onDataChange) {
          this.onDataChange(this.tableData)
        }
      } else {
        this.hasMore = false
      }
    } catch (_) {}
    this.isLoadingMore = false
  }

  build() {
    Column() {
      // 表格标题
      Text('加工历史数据表')
        .fontSize(20)  // 标题字体
        .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: AppleDesignStyle.SPACING_SMALL }) // Apple风格：统一间距
        .alignSelf(ItemAlign.Start)

      // 表格容器（Grid 实现）
      Column() {
        // 固定表头
        Grid() {
          ForEach(['选择', '序号', '客户名称', '农场名称', '水果名称', '加工状态', '开始时间', '完成时间', '批重量(吨)', '批个数'], (title: string) => {
            GridItem() {
              TableHeaderCell({
                text: title,
                fontSize: 14,
                cellHeight: 36,
                cellPadding: 4,
                showRightBorder: false,
                showBottomBorder: false
              })
            }
          })
        }
        .columnsTemplate('6fr 8fr 12fr 12fr 10fr 10fr 12fr 12fr 12fr 12fr')
        .height(36)
        .columnsGap(0)
        .rowsGap(0)
        .width('100%')
        .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg)
        .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框

        // 可滚动数据区域（List + ListItem）
        List() {
          LazyForEach(
            this.lazyDataSource,
            (item: HistoryTableData, rowIdx?: number) => {
              ListItem() {
                Row() {
                  // 复选框列
                  Checkbox({ name: `checkbox_${item.id}`, group: 'tableCheckbox' })
                    .select(this.isSelected(item.id))
                    .onChange((value: boolean) => {
                      this.handleCheckboxChange(item.id, value)
                    })
                    .layoutWeight(6)
                    .height(20)

                  // 序号：自增序号（1, 2, 3...），不是批次号
                  Text((rowIdx !== undefined ? (rowIdx + 1) : 1).toString())
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(8)

                  Text(item.customerName)
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)

                  Text(item.farmName)
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)

                  Text(item.fruitName)
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(10)

                  Text(item.status)
                    .fontSize(14)
                    .fontColor(this.getStatusColor(item.status))
                    .textAlign(TextAlign.Center)
                    .layoutWeight(10)

                  Text(item.startTime)
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)

                  Text(item.endTime)
                    .fontSize(14)
                    .fontColor(item.endTime === '-' ? this.getCurrentTheme().subTextColor : this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)

                  Text(item.weight.toString())
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)

                  Text(item.count.toString())
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(12)
                }
                .width('100%')
                .height(36)
                .backgroundColor((rowIdx ?? 0) % 2 === 0 ? (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor) : (this.getCurrentTheme().surfaceColor))
                .padding({ left: 4, right: 4 })
              }
              .onTouch((event: TouchEvent) => {
                this.handleTouchEvent(event, item)
              })
              .border({ width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor })
            },
            (item: HistoryTableData) => `${item.id}`
          )
          
          // 哨兵行：当滚动到底部时自动加载更多（仅在使用 externalData 或分页数据时）
          if (!(this.filteredData && this.filteredData.length > 0) &&
              !(this.externalData && this.externalData.length > 0) &&
              this.hasMore && !this.isLoadingMore) {
            ListItem() {
              Row() {
                Text('加载中...')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().subTextColor)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height(40)
              .justifyContent(FlexAlign.Center)
            }
            .onAppear(() => {
              // 当哨兵行出现时，自动加载更多
              this.loadMore()
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .onReachEnd(() => {
          if (!this.externalData || this.externalData.length === 0) {
            this.loadMore()
          }
        })
        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
        .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
      }
      .width('100%')
      .height('70%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
    }
    .width('100%')
    .padding(AppleDesignStyle.SPACING_MEDIUM) // Apple风格：统一间距
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: AppleDesignStyle.BORDER_WIDTH_THIN, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：中等圆角
    .shadow(AppleDesignStyle.getShadowSmall()) // Apple风格：柔和阴影
    .margin({ top: AppleDesignStyle.SPACING_SMALL, bottom: AppleDesignStyle.SPACING_SMALL, left: AppleDesignStyle.SPACING_LARGE, right: AppleDesignStyle.SPACING_LARGE })
  }
}
