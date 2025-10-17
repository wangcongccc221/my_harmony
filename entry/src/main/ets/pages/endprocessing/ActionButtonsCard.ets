/**
 * 操作按钮卡片组件
 * 功能：显示操作按钮的卡片容器
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

// 按钮配置接口
export interface ButtonConfig {
  text: string
  onClick: () => void
  type?: 'primary' | 'secondary' | 'danger'
}

// 按钮样式接口
interface ButtonStyle {
  fontSize: number
  border: BorderOptions
  borderRadius: number
  padding: PaddingOptions
  fontColor: Color
  backgroundColor: string
}

// 边框选项接口
interface BorderOptions {
  width: number
  color: string
}

// 内边距选项接口
interface PaddingOptions {
  left: number
  right: number
  top: number
  bottom: number
}

@Component
export struct ActionButtonsCard {
  @Prop buttons: ButtonConfig[] = []
  @Prop cardBackgroundColor: string = ''

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  private baseComponentHelper = new BaseComponentHelper()

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 获取按钮样式
   */
  private getButtonStyle(type: string = 'secondary'): ButtonStyle {
    const baseStyle: ButtonStyle = {
      fontSize: 22,  // 按钮字体调大到22px
      border: { width: 1, color: this.getCurrentTheme().borderColor },
      borderRadius: 10,  // 圆角调大到10px
      padding: { left: 30, right: 30, top: 15, bottom: 15 },  // 内边距调大
      fontColor: Color.Black,
      backgroundColor: this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor
    }

    switch (type) {
      case 'primary':
        baseStyle.fontColor = Color.White
        baseStyle.backgroundColor = this.getCurrentTheme().primary as string
        break
      case 'danger':
        baseStyle.fontColor = Color.White
        baseStyle.backgroundColor = '#D93025'
        break
    }

    return baseStyle
  }

  build() {
    Column() {
      Row() {
        ForEach(this.buttons, (button: ButtonConfig, index: number) => {
          Button(button.text)
            .fontSize(22)  // 按钮字体调大到22px
            .fontColor(this.getButtonStyle(button.type).fontColor)
            .backgroundColor(this.getButtonStyle(button.type).backgroundColor)
            .border(this.getButtonStyle(button.type).border)
            .borderRadius(10)  // 圆角调大到10px
            .padding({ left: 30, right: 30, top: 15, bottom: 15 })  // 内边距调大
            .margin({ left: index > 0 ? 10 : 0 })
            .onClick(() => {
              button.onClick()
            })
        })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 0, bottom: 20 })
    .backgroundColor(Color.Transparent)
    .margin({ left: 16, right: 16, top: 0, bottom: 0 })
  }
}
