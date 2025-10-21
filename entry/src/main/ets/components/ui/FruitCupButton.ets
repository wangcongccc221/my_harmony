/**
 * 果杯按钮组件
 * 功能：统一的果杯按钮样式和交互
 * 用途：底部控制栏的果杯按钮
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

@Component
export struct FruitCupButton {
  @Prop cupNumber: number = 1  // 果杯编号
  onCupClick?: (cupNumber: number) => void  // 点击回调

  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: string = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  build() {
    Button(this.cupNumber.toString())
      .fontSize(18)  // 调大到18px
      .fontWeight(FontWeight.Medium)
      .fontColor(this.getCurrentTheme().textColor)  // 使用主题文字颜色
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(4)
      .width(50)  // 增加宽度
      .height(40)  // 增加高度
      .margin({ right: 4 })
      .onClick(() => {
        console.log(`果杯按钮${this.cupNumber}被点击`)
        if (this.onCupClick) {
          this.onCupClick(this.cupNumber)
        }
      })
  }
}
