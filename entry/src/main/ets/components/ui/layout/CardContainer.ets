/**
 * 卡片容器组件
 * 功能：统一的卡片容器样式
 * 用途：可复用的卡片容器控件
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct CardContainer {
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop cardPadding: number | Padding = 16  // 内边距，默认16
  @Prop cardBorderRadius: number = 12  // 圆角，默认12
  @Prop cardBorderWidth: number = 1  // 边框宽度，默认1
  @Prop showShadow: boolean = true  // 是否显示阴影，默认true
  @Prop shadowRadius: number = 4  // 阴影半径，默认4
  @Prop shadowColor: string = 'rgba(0,0,0,0.06)'  // 阴影颜色
  @Prop shadowOffsetY: number = 1  // 阴影Y偏移，默认1
  @Prop cardMargin?: Margin | number  // 外边距（可选）
  @Prop cardBackgroundColor?: string  // 自定义背景色（可选）
  
  // 使用 @BuilderParam 支持传入子组件内容
  @BuilderParam content: () => void = () => {}
  
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.providedTheme)
  }
  
  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.cardPadding)
    .backgroundColor(this.cardBackgroundColor ?? this.getCurrentTheme().surfaceColor)
    .borderRadius(this.cardBorderRadius)
    .border({ width: this.cardBorderWidth, color: this.getCurrentTheme().borderColor })
    .shadow(this.showShadow ? { 
      radius: this.shadowRadius, 
      color: this.shadowColor, 
      offsetY: this.shadowOffsetY 
    } : undefined)
    .margin(this.cardMargin ?? {})
  }
}

