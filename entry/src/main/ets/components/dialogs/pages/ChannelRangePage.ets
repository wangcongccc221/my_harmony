/**
 * 通道范围设置页面组件
 * 功能：显示通道范围相关的设置内容
 * 用途：在工程设置对话框的"通道范围设置"Tab中使用
 */

import { BaseComponentHelper } from '../../common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct ChannelRangePage {
  private baseComponentHelper = new BaseComponentHelper()

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  build() {
    Column() {
      Text('通道范围设置')
        .fontSize(24)  // 标题字体调大到24px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 20 })

      // 通道范围设置内容
      Column() {
        Text('这里显示通道范围相关的设置内容')
          .fontSize(18)  // 描述文字字体调大到18px
          .fontColor(this.getCurrentTheme().subTextColor)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

        // 示例设置项
        Row() {
          Text('通道数量:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('16个')
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.getCurrentTheme().primary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text('检测范围:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('50-200mm')
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.getCurrentTheme().primary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text('精度等级:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('±0.5mm')
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.getCurrentTheme().primary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(8)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
    }
    .width('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Start)
  }
}
