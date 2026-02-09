import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme as resolveTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct EndProcessingConfirmDialog {
  @Prop isVisible: boolean = false
  @Prop title: string = ''
  @Prop message: string = ''

  onYes?: () => void
  onNo?: () => void
  onCancel?: () => void

  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return resolveTheme(this.consumedTheme)
  }

  build() {
    if (this.isVisible) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.45)')

        Column() {
          if (this.title) {
            Text(this.title)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 10 })
          }

          if (this.message) {
            Text(this.message)
              .fontSize(16)
              .fontColor(this.getCurrentTheme().subTextColor)
              .textAlign(TextAlign.Start)
              .width('100%')
              .margin({ bottom: 18 })
          }

          Row() {
            Button(t('是', '是'))
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(this.getCurrentTheme().primary as string)
              .borderRadius(10)
              .padding({ left: 18, right: 18, top: 10, bottom: 10 })
              .onClick(() => {
                this.onYes?.()
              })

            Button(t('否', '否'))
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#6B7280')
              .borderRadius(10)
              .padding({ left: 18, right: 18, top: 10, bottom: 10 })
              .margin({ left: 10 })
              .onClick(() => {
                this.onNo?.()
              })

            if (this.onCancel) {
              Button(t('取消', '取消'))
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(10)
                .padding({ left: 18, right: 18, top: 10, bottom: 10 })
                .margin({ left: 10 })
                .onClick(() => {
                  this.onCancel?.()
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('86%')
        .constraintSize({ maxWidth: 460 })
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(14)
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetX: 0, offsetY: 8 })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
      .zIndex(1000)
      .opacity(this.i18nVersion >= 0 ? 1 : 1)
    }
  }
}

