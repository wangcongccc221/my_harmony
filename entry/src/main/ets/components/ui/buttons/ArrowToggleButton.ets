/**
 * 箭头切换按钮组件
 * 功能：用于侧边栏展开/收缩的三角形箭头按钮
 * 用途：可复用的箭头切换控件
 * Apple Design 风格优化：柔和的圆角、阴影效果、流畅动画
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

@Component
export struct ArrowToggleButton {
  @Prop isExpanded: boolean = false  // 是否展开状态
  onToggle?: () => void  // 切换回调函数

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Button() {
      Row() {
        if (this.isExpanded) {
          // 展开状态：显示左箭头
          Text('‹')
            .fontSize(20)
            .fontColor(this.getCurrentTheme().primary)
            .fontWeight(FontWeight.Medium) // Apple风格：使用Medium而非Bold
        } else {
          // 收缩状态：显示右箭头
          Text('›')
            .fontSize(20)
            .fontColor(this.getCurrentTheme().primary)
            .fontWeight(FontWeight.Medium) // Apple风格：使用Medium而非Bold
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(40)
    .height(40)
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .border({
      width: AppleDesignStyle.BORDER_WIDTH_THIN, // Apple风格：细边框
      color: this.getCurrentTheme().borderColor,
      style: BorderStyle.Solid
    })
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_CIRCLE) // Apple风格：圆形按钮
    .shadow(AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.12)')) // Apple风格：柔和阴影
    .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle()
      }
    })
  }
}
