import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { getExitScreenStorage } from '../../utils/storage/ExitScreenStorage'

class ExitDisplayRow {
  exitNo: number = 0
  label: string = ''
  status: string = ''
  countText: string = ''

  constructor(exitNo: number, label: string, status: string, countText: string) {
    this.exitNo = exitNo
    this.label = label
    this.status = status
    this.countText = countText
  }
}

@Component
export struct ExitDisplayDialog {
  @Prop isVisible: boolean = false
  @Prop initialEnabled: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State private displayEnabled: boolean = true
  @State private rows: ExitDisplayRow[] = [
    new ExitDisplayRow(1, 'A级大果', '显示中', '128 箱'),
    new ExitDisplayRow(2, 'A级中果', '显示中', '94 箱'),
    new ExitDisplayRow(3, 'B级果', '待机', '0 箱'),
    new ExitDisplayRow(4, '礼盒口', '显示中', '36 箱'),
    new ExitDisplayRow(5, '抽检口', '待机', '0 箱'),
    new ExitDisplayRow(6, '混装口', '显示中', '11 箱')
  ]

  onConfirm?: (enabled: boolean) => void
  onCancel?: () => void

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  onThemeChange(): void {
    console.log('ExitDisplayDialog: 主题已变化，重新渲染')
  }

  aboutToAppear(): void {
    this.displayEnabled = this.initialEnabled
    const snapshot = getExitScreenStorage().buildBroadcastSnapshot()
    const nextRows: ExitDisplayRow[] = []
    for (let i = 0; i < snapshot.items.length; i++) {
      const item = snapshot.items[i]
      const status = this.displayEnabled ? '显示中' : '待机'
      const countText = item.additionalInfo.length > 0 ? item.additionalInfo : `来源: ${item.sourceType}`
      nextRows.push(new ExitDisplayRow(item.exitNo, item.displayName, status, countText))
    }
    if (nextRows.length > 0) {
      this.rows = nextRows
    }
  }

  private handleConfirm(): void {
    console.log(`[EXIT_DISPLAY_UI] confirm enabled=${this.displayEnabled}`)
    if (this.onConfirm) {
      this.onConfirm(this.displayEnabled)
    }
  }

  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  private getStatusColor(status: string): string {
    return status === '显示中' ? '#28A745' : '#B0B7C3'
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
            Text(t('出口屏显示', '出口屏显示'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .layoutWeight(1)

            Button() {
              Text('×').fontSize(22).fontColor(Color.White)
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

          Column({ space: 16 }) {
            Row() {
              Column({ space: 4 }) {
                Text('出口屏广播开关')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                Text('对齐 48 的 ExitDisplay 总开关。这里只先实现 UI 入口。')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().subTextColor)
              }
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.displayEnabled })
                .onChange((value: boolean) => {
                  this.displayEnabled = value
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(12)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })

            Column({ space: 10 }) {
              Row() {
                Text('出口屏预览').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.getCurrentTheme().textColor)
                Blank().layoutWeight(1)
                Text(this.displayEnabled ? '广播开启' : '广播关闭')
                  .fontSize(13)
                  .fontColor(this.displayEnabled ? '#28A745' : '#D93025')
              }
              .width('100%')

              Scroll() {
                Grid() {
                  ForEach(this.rows, (row: ExitDisplayRow) => {
                    GridItem() {
                      Column({ space: 8 }) {
                        Row() {
                          Text(`出口 ${row.exitNo}`)
                            .fontSize(15)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(this.getCurrentTheme().textColor)
                          Blank().layoutWeight(1)
                          Text(row.status)
                            .fontSize(12)
                            .fontColor(this.getStatusColor(row.status))
                        }
                        .width('100%')

                        Text(row.label)
                          .fontSize(20)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(this.getCurrentTheme().primary)

                        Text(row.countText)
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().subTextColor)
                      }
                      .width('100%')
                      .padding(16)
                      .backgroundColor('#0F2744')
                      .borderRadius(14)
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .width('100%')
              }
              .width('100%')
              .height(320)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(12)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
          }
          .width('100%')
          .layoutWeight(1)
          .padding(20)

          Row({ space: 12 }) {
            Blank().layoutWeight(1)

            Button(t('取消', '取消'))
              .width(100)
              .height(40)
              .fontSize(15)
              .backgroundColor('#E0E0E0')
              .fontColor(this.getCurrentTheme().textColor)
              .borderRadius(8)
              .onClick(() => {
                this.handleCancel()
              })

            Button(t('确定', '确定'))
              .width(100)
              .height(40)
              .fontSize(15)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .width('74%')
        .height('70%')
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
        .constraintSize({ maxWidth: 900, maxHeight: 680 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}
