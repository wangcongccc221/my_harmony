/**
 * 导航按钮组件
 * 功能：统一的导航按钮样式，确保所有按钮大小一致，文字左右对齐
 * 用途：侧边栏导航按钮
 * Apple Design 风格优化：柔和的圆角、阴影效果
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

@Component
export struct NavButton {
  @Prop text: string = ''  // 按钮文字
  @Prop isActive: boolean = false  // 是否激活状态
  onBtnClick?: () => void  // 点击回调

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {   //导航栏按钮 - Apple Design 风格
    Button(this.formatText())
      .width('80%') // 缩短按钮宽度，从100%改为80%
      .height(56)   // 按钮高度调大到56px
      .margin({ top: 6, bottom: 6, right: 20 }) // 增加上下边距
      .fontSize(18) // 字体大小调大到18px
      .fontWeight(this.isActive ? FontWeight.Bold : FontWeight.Medium) // Apple风格：激活时加粗
      .fontColor(this.isActive ? Color.White : this.getCurrentTheme().textColor)
      .backgroundColor(this.isActive ? this.getCurrentTheme().primary : this.getCurrentTheme().surfaceColor)
      .border({ 
        width: this.isActive ? 0 : AppleDesignStyle.BORDER_WIDTH_THIN, // Apple风格：激活时无边框
        color: this.isActive ? Color.Transparent : this.getCurrentTheme().borderColor 
      })
      .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM) // Apple风格：中等圆角12px
      .shadow(this.isActive ? AppleDesignStyle.getShadowSmall('rgba(0, 0, 0, 0.15)') : undefined) // Apple风格：激活时添加柔和阴影
      .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
      .onClick(() => {
        if (this.onBtnClick) {
          this.onBtnClick()
        }
      })
  }

  // 格式化文字，让两个字之间有空格对齐
  private formatText(): string {
    if (this.text.length === 2) {
      // 两个字的情况，在中间加4个空格（2个中文字符 = 4个字符宽度）
      return this.text.charAt(0) + '  ' + this.text.charAt(1)
    } else if (this.text.length === 3) {
      // 三个字的情况，在中间加空格
      return this.text.charAt(0) + '  ' + this.text.charAt(1) + '  ' + this.text.charAt(2)
    } else {
      // 四个字或更多，保持原样（四个字已经是8个字符宽度，不需要调整）
      return this.text
    }
  }
}
