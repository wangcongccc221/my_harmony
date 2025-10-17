/**
 * 箭头切换按钮组件
 * 功能：用于侧边栏展开/收缩的三角形箭头按钮
 * 用途：可复用的箭头切换控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

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
            .fontWeight(FontWeight.Bold)
        } else {
          // 收缩状态：显示右箭头
          Text('›')
            .fontSize(20)
            .fontColor(this.getCurrentTheme().primary)
            .fontWeight(FontWeight.Bold)
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
      width: 1,
      color: this.getCurrentTheme().borderColor,
      style: BorderStyle.Solid
    })
    .borderRadius(20)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle()
      }
    })
  }
}
