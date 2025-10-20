import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { HistoryTableManager, HistoryTableData } from './core/HistoryTableManager'

/**
 * 历史数据表格组件
 */
@Component
export struct HistoryDataTable {
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()
  private tableManager = HistoryTableManager.getInstance()

  // 事件回调
  onRowClick?: (rowData: HistoryTableData) => void
  onEditClick?: (rowData: HistoryTableData) => void
  onDeleteClick?: (rowData: HistoryTableData) => void

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
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
          GridItem() {
            Text('序号')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('客户名称')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('农场名称')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('水果名称')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('加工状态')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('开始时间')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('完成时间')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('批重量(吨)')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
          GridItem() {
            Text('批个数')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding(4)
          }
        }
        .columnsTemplate('8fr 12fr 12fr 10fr 10fr 12fr 12fr 12fr 12fr')
        .height(36)
        .columnsGap(0)
        .rowsGap(0)
        .width('100%')
        .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().controlBg)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })

        // 可滚动数据区域（List + ListItem）
        List() {
          ForEach(this.tableManager.getData(), (item: HistoryTableData, rowIdx?: number) => {
            ListItem() {
              Row() {
                Text(item.id.toString())
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('8%')

                Text(item.customerName)
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')

                Text(item.farmName)
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')

                Text(item.fruitName)
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('10%')

                Text(item.status)
                  .fontSize(14)
                  .fontColor(this.getStatusColor(item.status))
                  .textAlign(TextAlign.Center)
                  .width('10%')

                Text(item.startTime)
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')

                Text(item.endTime)
                  .fontSize(14)
                  .fontColor(item.endTime === '-' ? this.getCurrentTheme().subTextColor : this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')

                Text(item.weight.toString())
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')

                Text(item.count.toString())
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .textAlign(TextAlign.Center)
                  .width('12%')
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
          }, (item: HistoryTableData, idx?: number) => `${idx}`)
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
