import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { HistoryTableManager, HistoryTableData } from './core/HistoryTableManager'
import { TableHeaderCell } from '../../components/ui/tables/TableHeaderCell'
import { TableCell } from '../../components/ui/tables/TableCell'

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
  @Prop filteredData: HistoryTableData[] = []
  // 防重复加载标志，避免aboutToUpdate循环触发
  private isLoading: boolean = false
  private lastUpdateKey: number = 0

  // 事件回调
  onRowClick?: (rowData: HistoryTableData) => void
  onEditClick?: (rowData: HistoryTableData) => void
  onDeleteClick?: (rowData: HistoryTableData) => void
  onDataChange?: (data: HistoryTableData[]) => void
  onSelectionChange?: (selectedIds: number[]) => void

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
   * 获取当前表格数据
   */
  getCurrentData(): HistoryTableData[] {
    return this.tableData;
  }

  /**
   * 从数据库加载数据
   */
  private async loadData(): Promise<void> {
    try {
      console.log('HistoryDataTable loadData: 开始从数据库加载数据')
      const data = await this.tableManager.getData()
      console.log('HistoryDataTable loadData: 获取到数据', data.length, '条')
      // 更新 @State tableData，这会触发UI重新渲染
      this.tableData = data
      console.log('HistoryDataTable loadData: tableData已更新，长度:', this.tableData.length)
      // 通知父组件数据变化
      if (this.onDataChange) {
        this.onDataChange(this.tableData)
      }
    } catch (error) {
      console.error('HistoryDataTable loadData: 加载数据失败', error)
      this.tableData = []
    }
  }

  /**
   * 获取要显示的数据（优先使用筛选数据）
   */
  private getDisplayData(): HistoryTableData[] {
    // 返回拷贝，避免框架复用导致的渲染错位
    if (this.filteredData && this.filteredData.length > 0) {
      return [...this.filteredData]
    }
    return [...this.tableData]
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
    console.log('HistoryDataTable aboutToAppear: 组件已挂载')
    // 若父组件已传入筛选数据，则直接显示，避免重新加载覆盖筛选结果
    if (this.filteredData && this.filteredData.length > 0) {
      return
    }
    // 否则加载全部数据
    this.loadData().then(() => {
      console.log('HistoryDataTable aboutToAppear: 数据加载完成')
    }).catch((error: Error) => {
      console.error('HistoryDataTable aboutToAppear: 数据加载失败', error)
    })
  }

  /**
   * 组件更新时检查筛选数据和数据变化
   */
  aboutToUpdate() {
    // 如果外部传入了筛选数据，直接作为显示数据来源
    if (this.filteredData && this.filteredData.length > 0) {
      this.tableData = this.filteredData
      if (this.onDataChange) {
        // 告知父组件当前显示的数据（父组件在筛选态会忽略该回调，避免循环）
        this.onDataChange(this.filteredData)
      }
      return
    }
    // 否则加载全部数据（用于"重置"等场景）
    // 添加防重复加载机制，避免循环触发
    if (!this.isLoading) {
      this.isLoading = true
      const currentKey = Date.now()
      this.lastUpdateKey = currentKey
      // 使用异步延迟，避免在更新过程中同步加载导致循环
      Promise.resolve().then(() => {
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

  build() {
    Column() {
      // 表格标题
      Text('加工历史数据表')
        .fontSize(20)  // 调大到20px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 8 })
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
        .border({ width: 1, color: this.getCurrentTheme().borderColor })

        // 可滚动数据区域（List + ListItem）
        List() {
          ForEach(this.getDisplayData(), (item: HistoryTableData, rowIdx?: number) => {
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
            .onClick(() => {
              this.handleRowClick(item)
            })
            .border({ width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor })
          }, (item: HistoryTableData, idx?: number) => `${item.id}`)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(4)
      }
      .width('100%')
      .height('70%')
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(4)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(6)
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
    .margin({ top: 8, bottom: 8, left: 16, right: 16 })
  }
}
