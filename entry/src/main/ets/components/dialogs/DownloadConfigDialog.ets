import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct DownloadConfigDialog {
  @Prop isVisible: boolean = false
  @Prop snapshotPath: string = ''
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  onExport?: () => void
  onImport?: () => void
  onCancel?: () => void

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  onThemeChange(): void {
    console.log('DownloadConfigDialog: theme changed')
  }

  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    Stack() {
      if (!this.isVisible) {
        Blank()
      } else {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        Column({ space: 16 }) {
          Row() {
            Text(t('下载配置', '下载配置'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
            Button('×')
              .type(ButtonType.Normal)
              .backgroundColor(Color.Transparent)
              .fontSize(22)
              .fontColor(this.getCurrentTheme().textColor)
              .width(32)
              .height(32)
              .onClick(() => {
                this.handleCancel()
              })
          }
          .width('100%')

          Text(t('对齐48的“下载配置”能力：当前先实现配置快照导出/回读。', '对齐48的“下载配置”能力：当前先实现配置快照导出/回读。'))
            .fontSize(13)
            .fontColor(this.getCurrentTheme().subTextColor)
            .width('100%')

          Column({ space: 8 }) {
            Text(t('快照文件路径', '快照文件路径'))
              .fontSize(14)
              .fontColor(this.getCurrentTheme().textColor)
              .width('100%')
            Text(this.snapshotPath.length > 0 ? this.snapshotPath : '--')
              .fontSize(12)
              .fontColor(this.getCurrentTheme().subTextColor)
              .width('100%')
              .maxLines(3)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.getCurrentTheme().backgroundColor)
          .borderRadius(8)

          Button(t('导出当前配置', '导出当前配置'))
            .width('100%')
            .height(42)
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor(Color.White)
            .onClick(() => {
              if (this.onExport) {
                this.onExport()
              }
            })

          Button(t('导入最近快照', '导入最近快照'))
            .width('100%')
            .height(42)
            .backgroundColor('#4CAF50')
            .fontColor(Color.White)
            .onClick(() => {
              if (this.onImport) {
                this.onImport()
              }
            })

          Button(t('关闭', '关闭'))
            .width('100%')
            .height(40)
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .fontColor(this.getCurrentTheme().textColor)
            .onClick(() => {
              this.handleCancel()
            })
        }
        .width('68%')
        .constraintSize({ maxWidth: 520 })
        .padding(20)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .align(Alignment.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
