import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { ExitScreenConfigRecord, getExitScreenStorage } from '../../utils/storage/ExitScreenStorage'

@Component
export struct ExitScreenSettingsDialog {
  @Prop isVisible: boolean = false
  @Prop initialSleepEnabled: boolean = true
  @Prop initialScreenOnTime: string = '08:00:00'
  @Prop initialScreenOffTime: string = '20:00:00'
  @Prop initialConfigsJson: string = '[]'
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State sleepEnabled: boolean = true
  @State screenOnTime: string = '08:00:00'
  @State selectedOnTime: Date = new Date()
  @State showOnTimePicker: boolean = false
  @State screenOffTime: string = '20:00:00'
  @State selectedOffTime: Date = new Date()
  @State showOffTimePicker: boolean = false
  @State selectedExitNo: number = 1
  @State exitConfigs: ExitScreenConfigRecord[] = []

  onConfirm?: (sleepEnabled: boolean, screenOnTime: string, screenOffTime: string, configsJson: string) => void
  onCancel?: () => void

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  onThemeChange(): void {
    console.log('ExitScreenSettingsDialog: 主题已变化，重新渲染')
  }

  private parseTimeString(timeStr: string): Date {
    const parts = timeStr.split(':')
    const date = new Date()
    date.setHours(parseInt(parts[0] || '0'), parseInt(parts[1] || '0'), parseInt(parts[2] || '0'))
    return date
  }

  private formatTime(date: Date): string {
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')
    return `${hours}:${minutes}:${seconds}`
  }

  aboutToAppear(): void {
    this.sleepEnabled = this.initialSleepEnabled
    this.screenOnTime = this.initialScreenOnTime
    this.screenOffTime = this.initialScreenOffTime
    this.selectedOnTime = this.parseTimeString(this.screenOnTime)
    this.selectedOffTime = this.parseTimeString(this.screenOffTime)
    this.exitConfigs = getExitScreenStorage().parseConfigs(this.initialConfigsJson)
    if (this.exitConfigs.length > 0) {
      this.selectedExitNo = this.exitConfigs[0].exitNo
    }
  }

  private getSelectedConfig(): ExitScreenConfigRecord {
    for (let i = 0; i < this.exitConfigs.length; i++) {
      if (this.exitConfigs[i].exitNo === this.selectedExitNo) {
        return this.exitConfigs[i]
      }
    }
    return new ExitScreenConfigRecord(1, '', '', true)
  }

  private updateSelectedConfig(field: string, value: string | boolean): void {
    const nextList: ExitScreenConfigRecord[] = []
    for (let i = 0; i < this.exitConfigs.length; i++) {
      const item = this.exitConfigs[i]
      const next = new ExitScreenConfigRecord(item.exitNo, item.customName, item.additionalInfo, item.useAutoName)
      if (item.exitNo === this.selectedExitNo) {
        if (field === 'customName' && typeof value === 'string') {
          next.customName = value
        } else if (field === 'additionalInfo' && typeof value === 'string') {
          next.additionalInfo = value
        } else if (field === 'useAutoName' && typeof value === 'boolean') {
          next.useAutoName = value
        }
      }
      nextList.push(next)
    }
    this.exitConfigs = nextList
  }

  private buildConfigsJson(): string {
    return JSON.stringify(this.exitConfigs)
  }

  private handleConfirm(): void {
    console.log(`[EXIT_SCREEN_SETTINGS_UI] confirm selectedExit=${this.selectedExitNo} sleep=${this.sleepEnabled} on=${this.screenOnTime} off=${this.screenOffTime}`)
    if (this.onConfirm) {
      this.onConfirm(this.sleepEnabled, this.screenOnTime, this.screenOffTime, this.buildConfigsJson())
    }
  }

  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  @Builder
  private buildTimeRow(label: string, timeText: string, pickerVisible: boolean, selectedTime: Date, onToggle: () => void, onTimeChange: (value: TimePickerResult) => void, onTextChange: (value: string) => void): void {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor(this.getCurrentTheme().textColor)
          .width(92)

        TextInput({ text: timeText })
          .layoutWeight(1)
          .height(38)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .onChange((value: string) => {
            onTextChange(value)
          })

        Button('⏱')
          .type(ButtonType.Normal)
          .width(40)
          .height(38)
          .margin({ left: 8 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(8)
          .onClick(() => {
            onToggle()
          })
      }
      .width('100%')

      if (pickerVisible) {
        TimePicker({
          selected: selectedTime,
          format: TimePickerFormat.HOUR_MINUTE_SECOND
        })
          .useMilitaryTime(true)
          .width('100%')
          .onChange((value: TimePickerResult) => {
            onTimeChange(value)
          })
      }
    }
    .width('100%')
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

        Column() {
          Row() {
            Text(t('出口屏设置', '出口屏设置'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)

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
          .padding({ left: 20, right: 12 })
          .backgroundColor('#4CAF50')

          Row({ space: 16 }) {
            Column({ space: 16 }) {
              Row() {
                Text('休眠开关')
                  .fontSize(15)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.sleepEnabled })
                  .onChange((value: boolean) => {
                    this.sleepEnabled = value
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().surfaceColor)
              .borderRadius(12)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })

              Column({ space: 12 }) {
                this.buildTimeRow('开屏时间', this.screenOnTime, this.showOnTimePicker, this.selectedOnTime,
                  () => {
                    this.showOnTimePicker = !this.showOnTimePicker
                  },
                  (value: TimePickerResult) => {
                    if (value.hour >= 0) {
                      this.selectedOnTime.setHours(value.hour, value.minute, value.second || 0)
                      this.screenOnTime = this.formatTime(this.selectedOnTime)
                    }
                  },
                  (value: string) => {
                    this.screenOnTime = value
                    this.selectedOnTime = this.parseTimeString(value)
                  })

                this.buildTimeRow('息屏时间', this.screenOffTime, this.showOffTimePicker, this.selectedOffTime,
                  () => {
                    this.showOffTimePicker = !this.showOffTimePicker
                  },
                  (value: TimePickerResult) => {
                    if (value.hour >= 0) {
                      this.selectedOffTime.setHours(value.hour, value.minute, value.second || 0)
                      this.screenOffTime = this.formatTime(this.selectedOffTime)
                    }
                  },
                  (value: string) => {
                    this.screenOffTime = value
                    this.selectedOffTime = this.parseTimeString(value)
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().surfaceColor)
              .borderRadius(12)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
            }
            .width('34%')

            Column({ space: 16 }) {
              Row({ space: 8 }) {
                Text('出口选择')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                ForEach(this.exitConfigs, (item: ExitScreenConfigRecord) => {
                  Button(item.exitNo.toString())
                    .width(34)
                    .height(34)
                    .fontSize(13)
                    .borderRadius(8)
                    .fontColor(this.selectedExitNo === item.exitNo ? Color.White : this.getCurrentTheme().textColor)
                    .backgroundColor(this.selectedExitNo === item.exitNo ? this.getCurrentTheme().primary : this.getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: this.getCurrentTheme().borderColor })
                    .onClick(() => {
                      this.selectedExitNo = item.exitNo
                    })
                })
              }
              .width('100%')

              Column({ space: 12 }) {
                Row() {
                  Checkbox({ name: 'useAutoName' })
                    .select(this.getSelectedConfig().useAutoName)
                    .onChange((value: boolean) => {
                      this.updateSelectedConfig('useAutoName', value)
                    })
                    .width(18)
                    .height(18)
                    .margin({ right: 8 })
                  Text('使用自动等级名称')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)

                Column({ space: 6 }) {
                  Text('显示名称')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().subTextColor)
                  TextInput({ text: this.getSelectedConfig().customName })
                    .height(40)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(8)
                    .enabled(!this.getSelectedConfig().useAutoName)
                    .onChange((value: string) => {
                      this.updateSelectedConfig('customName', value)
                    })
                }
                .width('100%')

                Column({ space: 6 }) {
                  Text('附加信息')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().subTextColor)
                  TextInput({ text: this.getSelectedConfig().additionalInfo })
                    .height(72)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(8)
                    .onChange((value: string) => {
                      this.updateSelectedConfig('additionalInfo', value)
                    })
                }
                .width('100%')

                Column({ space: 6 }) {
                  Text('屏幕预览')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().subTextColor)
                  Column({ space: 6 }) {
                    Text(`出口 ${this.getSelectedConfig().exitNo}`)
                      .fontSize(13)
                      .fontColor('#9EC5FF')
                    Text(this.getSelectedConfig().useAutoName ? '自动等级名称' : (this.getSelectedConfig().customName || '未设置显示名称'))
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                    Text(this.getSelectedConfig().additionalInfo && this.getSelectedConfig().additionalInfo.length > 0 ? this.getSelectedConfig().additionalInfo : '无附加信息')
                      .fontSize(13)
                      .fontColor('#B8C7D9')
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#0F2744')
                  .borderRadius(14)
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.getCurrentTheme().surfaceColor)
              .borderRadius(12)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .layoutWeight(1)
          .padding(20)

          Row() {
            Blank().layoutWeight(1)
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
          .padding({ left: 20, right: 20, top: 0, bottom: 20 })
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width('80%')
        .height('78%')
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.12)',
          offsetX: 0,
          offsetY: 4
        })
        .constraintSize({ maxWidth: 980, maxHeight: 760 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
