/**
 * 加工数据表格组件
 * 功能：显示加工记录数据的表格
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ProcessingRecord } from './core/ProcessingDataManager'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct ProcessingDataTable {
  @Prop data: ProcessingRecord[] = []
  onRowClick?: (record: ProcessingRecord) => void

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  build() {
    Column() {
      // 固定表头（Grid）
      Grid() {
        GridItem() {
          Text(t('加工时间', '加工时间'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        GridItem() {
          Text(t('结束时间', '结束时间'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        GridItem() {
          Text(t('加工品种', '加工品种'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
        }
        GridItem() {
          Text(t('总重量(吨)', '总重量(吨)'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
            .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
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

              // 总重量(吨) - 保留一位小数
              Text(`${record.totalWeight.toFixed(1)}`)
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
