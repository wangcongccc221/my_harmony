/**
 * 加工数据表格组件
 * 功能：显示加工记录数据的表格
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ProcessingRecord } from './core/ProcessingDataManager'

@Component
export struct ProcessingDataTable {
  @Prop data: ProcessingRecord[] = []
  onRowClick?: (record: ProcessingRecord) => void

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  build() {
    Column() {
      // 固定表头（Grid）
      Grid() {
        GridItem() {
          Text('加工时间')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
        }
        GridItem() {
          Text('结束时间')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
        }
        GridItem() {
          Text('加工品种')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
        }
        GridItem() {
          Text('总重量(吨)')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(0)
      .rowsGap(0)
      .width('100%')
      .height(40)
      .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor))
      .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

      // 可滚动数据区域（List + ListItem）
      List() {
        ForEach(this.data, (record: ProcessingRecord, rowIdx?: number) => {
          ListItem() {
            Row() {
              // 加工时间
              Text(record.startTime)
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('25%')

              // 结束时间
              Text(record.endTime)
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('25%')

              // 加工品种
              Text(record.productType)
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('25%')

              // 总重量(吨)
              Text(`${record.totalWeight}`)
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .width('25%')
            }
            .width('100%')
            .height(40)
            .backgroundColor((rowIdx ?? 0) % 2 === 0 ? (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor) : (this.getCurrentTheme().surfaceColor))
            .padding({ left: 4, right: 4 })
          }
          .onClick(() => {
            this.onRowClick?.(record)
          })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
        }, (record: ProcessingRecord, idx?: number) => `${idx}`)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('85%')
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(8)
  }
}
