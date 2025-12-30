/**
 * 出口屏设置对话框组件
 * 功能：配置出口屏的休眠开关、开屏时间、息屏时间等参数
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct ExitScreenSettingsDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 休眠开关状态
  @State sleepEnabled: boolean = true

  // 开屏时间
  @State screenOnTime: string = '10:53:02'
  @State selectedOnTime: Date = new Date()
  @State showOnTimePicker: boolean = false

  // 息屏时间
  @State screenOffTime: string = '00:00:00'
  @State selectedOffTime: Date = new Date()
  @State showOffTimePicker: boolean = false

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('ExitScreenSettingsDialog: 主题已变化，重新渲染')
  }

  // 将时间字符串转换为 Date 对象
  private parseTimeString(timeStr: string): Date {
    const parts = timeStr.split(':')
    const date = new Date()
    date.setHours(parseInt(parts[0] || '0'), parseInt(parts[1] || '0'), parseInt(parts[2] || '0'))
    return date
  }

  // 将 Date 对象格式化为时间字符串 (HH:mm:ss)
  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${hours}:${minutes}:${seconds}`
  }

  // 初始化时间
  aboutToAppear(): void {
    this.selectedOnTime = this.parseTimeString(this.screenOnTime)
    this.selectedOffTime = this.parseTimeString(this.screenOffTime)
  }

  // 确认按钮点击
  private handleConfirm(): void {
    if (this.onConfirm) {
      this.onConfirm()
    }
  }

  // 取消/关闭按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    // 对话框遮罩层
    Stack() {
      if (!this.isVisible) {
        // 不可见时返回空内容
        Blank()
      } else {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.handleCancel()
          })

        // 对话框内容
        Column() {
          // 标题栏（绿色背景）
          Row() {
            Text(t('出口屏设置', '出口屏设置'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Button() {
              Image($r('sys.media.ohos_ic_public_close'))
                .width(20)
                .height(20)
                .fillColor(Color.White)
            }
            .type(ButtonType.Normal)
            .backgroundColor(Color.Transparent)
            .width(32)
            .height(32)
            .onClick(() => {
              this.handleCancel()
            })
          }
          .width('100%')
          .height(48)
          .padding({ left: 20, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#4CAF50')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          // 内容区域
          Column() {
            // 休眠开关复选框
            Row() {
              Checkbox({ name: 'sleepEnabled' })
                .select(this.sleepEnabled)
                .onChange((value: boolean) => {
                  this.sleepEnabled = value
                })
                .width(20)
                .height(20)
                .shape(CheckBoxShape.ROUNDED_SQUARE)

              Text(t('休眠开关', '休眠开关'))
                .fontSize(16)
                .fontColor(this.getCurrentTheme().textColor)
                .margin({ left: 8 })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding({ top: 20, bottom: 20, left: 20, right: 20 })

            // 开屏时间设置
            Column() {
              Row() {
                Text(t('开屏时间:', '开屏时间:'))
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(100)

                TextInput({ text: this.screenOnTime })
                  .width(150)
                  .height(36)
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(4)
                  .padding({ left: 8, right: 8 })
                  .onChange((value: string) => {
                    this.screenOnTime = value
                    this.selectedOnTime = this.parseTimeString(value)
                  })

                // 日历图标按钮
                Button() {
                  Text('📅')
                    .fontSize(18)
                    .fontColor(this.getCurrentTheme().textColor)
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .width(32)
                .height(32)
                .margin({ left: 8 })
                .onClick(() => {
                  this.showOnTimePicker = !this.showOnTimePicker
                })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              // 时间选择器
              if (this.showOnTimePicker) {
                TimePicker({
                  selected: this.selectedOnTime,
                  format: TimePickerFormat.HOUR_MINUTE_SECOND
                })
                  .useMilitaryTime(true)
                  .onChange((value: TimePickerResult) => {
                    if (value.hour >= 0) {
                      this.selectedOnTime.setHours(value.hour, value.minute, value.second || 0)
                      this.screenOnTime = this.formatTime(this.selectedOnTime)
                    }
                  })
                  .margin({ top: 8 })
                  .width('100%')
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 20, right: 20, bottom: 16 })

            // 息屏时间设置
            Column() {
              Row() {
                Text(t('息屏时间:', '息屏时间:'))
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(100)

                TextInput({ text: this.screenOffTime })
                  .width(150)
                  .height(36)
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(4)
                  .padding({ left: 8, right: 8 })
                  .onChange((value: string) => {
                    this.screenOffTime = value
                    this.selectedOffTime = this.parseTimeString(value)
                  })

                // 日历图标按钮
                Button() {
                  Text('📅')
                    .fontSize(18)
                    .fontColor(this.getCurrentTheme().textColor)
                }
                .type(ButtonType.Normal)
                .backgroundColor(Color.Transparent)
                .width(32)
                .height(32)
                .margin({ left: 8 })
                .onClick(() => {
                  this.showOffTimePicker = !this.showOffTimePicker
                })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              // 时间选择器
              if (this.showOffTimePicker) {
                TimePicker({
                  selected: this.selectedOffTime,
                  format: TimePickerFormat.HOUR_MINUTE_SECOND
                })
                  .useMilitaryTime(true)
                  .onChange((value: TimePickerResult) => {
                    if (value.hour >= 0) {
                      this.selectedOffTime.setHours(value.hour, value.minute, value.second || 0)
                      this.screenOffTime = this.formatTime(this.selectedOffTime)
                    }
                  })
                  .margin({ top: 8 })
                  .width('100%')
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(this.getCurrentTheme().surfaceColor)

          // 底部按钮区域
          Row() {
            Blank().layoutWeight(1)

            // 确定按钮
            Button(t('确定', '确定'))
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#4CAF50')
              .borderRadius(8)
              .width(100)
              .height(40)
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 20 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width(600)
        .height(500)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

