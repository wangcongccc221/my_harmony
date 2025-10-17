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

      // 表格容器
      Column() {
        // 表头
        Row() {
          Text('序号')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('8%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('客户名称')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('农场名称')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('水果名称')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('10%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('加工状态')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('10%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('开始时间')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('完成时间')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('批重量（吨）')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)

          Text('批个数')
            .fontSize(16)  // 调大到16px
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .width('12%')
            .height(32)
            .backgroundColor(this.getCurrentTheme().primary)
            .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
            .padding(4)
        }
        .width('100%')

        // 表格数据区域
        Column() {
          ForEach(this.tableManager.getData(), (item: HistoryTableData, index: number) => {
            Row() {
              Text(item.id.toString())
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('8%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.customerName)
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.farmName)
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.fruitName)
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('10%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.status)
                .fontSize(16)  // 调大到16px
                .fontColor(this.getStatusColor(item.status))
                .textAlign(TextAlign.Center)
                .width('10%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.startTime)
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.endTime)
                .fontSize(16)  // 调大到16px
                .fontColor(item.endTime === '-' ? this.getCurrentTheme().subTextColor : this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.weight.toString())
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)

              Text(item.count.toString())
                .fontSize(16)  // 调大到16px
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('12%')
                .height(32)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                .padding(4)
            }
            .width('100%')
            .onClick(() => {
              this.handleRowClick(item)
            })
          })
        }
        .width('100%')
      }
      .width('100%')
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
