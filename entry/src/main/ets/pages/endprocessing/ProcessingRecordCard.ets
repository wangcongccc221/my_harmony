/**
 * 加工记录卡片组件
 * 功能：显示加工记录数据的卡片容器
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { ProcessingDataTable } from './ProcessingDataTable'
import { ProcessingRecord } from './core/ProcessingDataManager'

@Component
export struct ProcessingRecordCard {
  @Prop title: string = '加工记录'
  @Prop data: ProcessingRecord[] = []
  onRowClick?: (record: ProcessingRecord) => void

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  build() {
    Column() {
      // 卡片标题
      Text(this.title)
        .fontSize(24)  // 标题字体调大到24px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 20 })
        .alignSelf(ItemAlign.Start)

      // 数据表格
      ProcessingDataTable({
        data: this.data,
        onRowClick: (record: ProcessingRecord) => {
          this.onRowClick?.(record)
        }
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .borderRadius(12)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.06)', offsetY: 1 })
    .margin({ top: 0, left: 16, right: 16, bottom: 0 })
  }
}
