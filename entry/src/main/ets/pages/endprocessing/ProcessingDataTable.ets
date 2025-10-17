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
      // 表头
      Row() {
        Text('加工时间')
          .fontSize(18)  // 表头字体调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('结束时间')
          .fontSize(18)  // 表头字体调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('加工品种')
          .fontSize(18)  // 表头字体调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('总重量(吨)')
          .fontSize(18)  // 表头字体调大到18px
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

      // 表格内容区域
      Column() {
        ForEach(this.data, (record: ProcessingRecord) => {
          Row() {
            Text(record.startTime)
              .fontSize(16)  // 数据行字体调大到16px
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            
            Text(record.endTime)
              .fontSize(16)  // 数据行字体调大到16px
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            
            Text(record.productType)
              .fontSize(16)  // 数据行字体调大到16px
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            
            Text(record.totalWeight.toString())
              .fontSize(16)  // 数据行字体调大到16px
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
          .onClick(() => {
            this.onRowClick?.(record)
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('85%')
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .borderRadius(8)
  }
}
