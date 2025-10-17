/**
 * 水果信息设置页面组件
 * 功能：显示水果信息相关的设置内容
 * 用途：在工程设置对话框的"水果信息设置"Tab中使用
 */

import { BaseComponentHelper } from '../../common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct FruitInfoPage {
  private baseComponentHelper = new BaseComponentHelper()

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  build() {
    Column() {
      Text('水果信息设置')
        .fontSize(24)  // 标题字体调大到24px
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: 20 })

      // 水果信息设置内容
      Column() {
        Text('这里显示水果信息相关的设置内容')
          .fontSize(18)  // 描述文字字体调大到18px
          .fontColor(this.getCurrentTheme().subTextColor)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 16 })

        // 示例设置项
        Row() {
          Text('水果类型:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('苹果')
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.getCurrentTheme().primary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text('检测项目:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('重量、颜色、大小')
            .fontSize(18)  // 值字体调大到18px
            .fontColor(this.getCurrentTheme().primary)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 8 })

        Row() {
          Text('质量标准:')
            .fontSize(18)  // 标签字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .width(80)
          
          Text('A级标准')
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
