/**
 * 通用圆形按钮组件
 * 功能：封装统一的圆形按钮样式（40x40，圆角，主题色）
 * 用途：底部控制栏SCM按钮、果杯按钮等
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../../utils/theme/useOmniTheme'
import { IBestButton } from '@ibestservices/ibest-ui'

@Component
export struct StandardRoundButton {
  @Prop text: string = ''
  onClickAction?: () => void = () => {}

  // 主题相关
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: string = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  build() {
    IBestButton({
      text: this.text,
      type: "default",
      round: true,
      buttonSize: "normal",
      btnWidth: 40,
      btnHeight: 40,
      color: this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor,
      fontColor: this.getCurrentTheme().textColor,
      btnBorderColor: this.getCurrentTheme().borderColor,
    })
      .onClick(() => {
        if (this.onClickAction) {
          this.onClickAction()
        }
      })
  }
}
