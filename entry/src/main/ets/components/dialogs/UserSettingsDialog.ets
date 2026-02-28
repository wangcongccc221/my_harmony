import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { CustomerRecord, SystemSettingsDataService } from '../../db/services/SystemSettingsDataService'

@Component
export struct UserSettingsDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State users: CustomerRecord[] = []
  @State selectedIndex: number = 0

  onConfirm?: () => void
  onCancel?: () => void

  aboutToAppear(): void {
    void this.loadUsers()
  }

  private async loadUsers(): Promise<void> {
    this.users = await SystemSettingsDataService.getInstance().getCustomers()
    let matched = 0
    for (let i = 0; i < this.users.length; i++) {
      if (this.users[i].isUse) {
        matched = i
        break
      }
    }
    this.selectedIndex = matched
  }

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  onThemeChange(): void {
    console.log('UserSettingsDialog: theme changed')
  }

  private handleConfirm(): void {
    void this.switchCurrentUser()
  }

  private async switchCurrentUser(): Promise<void> {
    if (this.selectedIndex >= 0 && this.selectedIndex < this.users.length) {
      await SystemSettingsDataService.getInstance().setCurrentCustomer(this.users[this.selectedIndex].id)
      AppStorage.setOrCreate('TOP_USER_LABEL', this.users[this.selectedIndex].name)
      console.log(`[USER_SETTINGS_SAVE] current=${this.users[this.selectedIndex].name}`)
    }
    if (this.onConfirm) {
      this.onConfirm()
    }
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

        Column({ space: 12 }) {
          Row() {
            Text(t('用户设置', '用户设置'))
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

          Text(t('对齐48的“用户切换/用户管理”入口：当前先实现本地用户切换。', '对齐48的“用户切换/用户管理”入口：当前先实现本地用户切换。'))
            .fontSize(13)
            .fontColor(this.getCurrentTheme().subTextColor)
            .width('100%')

          List({ space: 8 }) {
            ForEach(this.users, (item: CustomerRecord, index: number) => {
              ListItem() {
                Row() {
                  Checkbox()
                    .select(this.selectedIndex === index)
                    .onChange((checked: boolean) => {
                      if (checked) {
                        this.selectedIndex = index
                      }
                    })
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .margin({ right: 12 })
                  Column() {
                    Text(item.code && item.code.length > 0 ? `${item.name} (${item.code})` : item.name)
                      .fontSize(15)
                      .fontColor(this.getCurrentTheme().textColor)
                    Text(item.isUse ? t('当前用户', '当前用户') : t('可切换用户', '可切换用户'))
                      .fontSize(12)
                      .fontColor(this.getCurrentTheme().subTextColor)
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.selectedIndex === index ? this.getCurrentTheme().primary + '18' : this.getCurrentTheme().surfaceColor)
                .borderRadius(8)
              }
            }, (item: CustomerRecord) => `${item.id}`)
          }
          .width('100%')
          .height(260)

          Row() {
            Button(t('取消', '取消'))
              .layoutWeight(1)
              .height(40)
              .margin({ right: 8 })
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .fontColor(this.getCurrentTheme().textColor)
              .onClick(() => {
                this.handleCancel()
              })
            Button(t('切换用户', '切换用户'))
              .layoutWeight(1)
              .height(40)
              .margin({ left: 8 })
              .backgroundColor(this.getCurrentTheme().primary)
              .fontColor(Color.White)
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
        }
        .width('70%')
        .constraintSize({ maxWidth: 560 })
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
