/**
 * 章节标题组件
 * 功能：统一的标题文本样式
 * 用途：可复用的标题控件
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct SectionTitle {
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop title: string = ''  // 标题文本
  @Prop titleFontSize: number = 16  // 字体大小，默认16
  @Prop titleFontWeight: FontWeight = FontWeight.Medium  // 字体粗细，默认Medium
  @Prop titleMargin: Margin = { bottom: 4 }  // 外边距，默认bottom: 4
  @Prop titleAlign: ItemAlign = ItemAlign.Start  // 对齐方式，默认Start
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  build() {
    Text(this.title)
      .fontSize(this.titleFontSize)
      .fontWeight(this.titleFontWeight)
      .fontColor(this.getCurrentTheme().textColor)
      .alignSelf(this.titleAlign)
      .margin(this.titleMargin)
  }
}

