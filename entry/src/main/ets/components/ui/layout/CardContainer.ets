/**
 * 卡片容器组件
 * 功能：统一的卡片容器样式
 * 用途：可复用的卡片容器控件
 * Apple Design 风格优化：柔和的圆角、阴影效果
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

@Component
export struct CardContainer {
  @Consume providedTheme: ExtendedOmniThemeStyle
  
  // 可配置参数
  @Prop cardPadding: number | Padding = 16  // 内边距，默认16
  @Prop cardBorderRadius?: number  // 圆角，默认使用Apple Design风格
  @Prop cardBorderWidth?: number  // 边框宽度，默认使用Apple Design风格
  @Prop showShadow: boolean = true  // 是否显示阴影，默认true
  @Prop shadowRadius?: number  // 阴影半径，默认使用Apple Design风格
  @Prop shadowColor?: string  // 阴影颜色，默认使用Apple Design风格
  @Prop shadowOffsetY?: number  // 阴影Y偏移，默认使用Apple Design风格
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
    .borderRadius(this.cardBorderRadius ?? AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：默认中等圆角
    .border({ 
      width: this.cardBorderWidth ?? AppleDesignStyle.BORDER_WIDTH_THIN, // Apple风格：默认细边框
      color: this.getCurrentTheme().borderColor 
    })
    .shadow(this.showShadow ? { 
      radius: this.shadowRadius ?? 12, // Apple风格：默认柔和阴影
      color: this.shadowColor ?? 'rgba(0, 0, 0, 0.1)', // Apple风格：默认柔和阴影颜色
      offsetX: 0,
      offsetY: this.shadowOffsetY ?? 4 // Apple风格：默认Y偏移
    } : undefined)
    .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
    .margin(this.cardMargin ?? {})
  }
}

