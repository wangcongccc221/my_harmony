/**
 * 导航按钮组件
 * 功能：统一的导航按钮样式，确保所有按钮大小一致，文字左右对齐
 * 用途：侧边栏导航按钮
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

@Component
export struct NavButton {
  @Prop text: string = ''  // 按钮文字
  @Prop isActive: boolean = false  // 是否激活状态
  onBtnClick?: () => void  // 点击回调

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {   //导航栏按钮
    Button(this.formatText())
      .width('80%') // 缩短按钮宽度，从100%改为80%
      .height(56)   // 按钮高度调大到56px
      .margin({ top: 6, bottom: 6, right: 20 }) // 增加上下边距
      .fontSize(18) // 字体大小调大到18px
      .fontWeight(FontWeight.Bolder)
      .fontColor(this.isActive ? Color.White : this.getCurrentTheme().textColor)
      .backgroundColor(this.isActive ? this.getCurrentTheme().primary : this.getCurrentTheme().surfaceColor)
      .border({ 
        width: 1, 
        color: this.isActive ? this.getCurrentTheme().primary : this.getCurrentTheme().borderColor 
      })
      .borderRadius(0)
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
