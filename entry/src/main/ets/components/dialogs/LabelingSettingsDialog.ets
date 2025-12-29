/**
 * 贴标设置对话框组件
 * 功能：配置贴标工作方式和贴标机参数
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'


@Component
export struct LabelingSettingsDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 贴标工作方式复选框状态
  @State noLabeling: boolean = false        // 不贴标
  @State byExport: boolean = false          // 按出口方式
  @State byGrade: boolean = false           // 按等级方式
  @State byContainer: boolean = false       // 按容器方式

  // 贴标机数据
  @State machine1Name: string = ''
  @State machine1LabelCount: string = ''
  @State machine1TotalCount: number = 1

  @State machine2Name: string = ''
  @State machine2LabelCount: string = ''
  @State machine2TotalCount: number = 1

  @State machine3Name: string = ''
  @State machine3LabelCount: string = ''
  @State machine3TotalCount: number = 1

  @State machine4Name: string = ''
  @State machine4LabelCount: string = ''
  @State machine4TotalCount: number = 1

  // 生成总数下拉框选项（1-10）
  private getTotalCountOptions(): SelectOption[] {
    const options: SelectOption[] = []
    for (let i = 1; i <= 10; i++) {
      options.push({ value: i.toString() })
    }
    return options
  }


  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('LabelingSettingsDialog: 主题已变化，重新渲染')
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
            Text('贴标设置')
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
          Scroll() {
            Column() {
              // 贴标工作方式
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  // 复选框区域 - 2x2布局
                  Row({ space: 20 }) {
                    // 左列
                    Column({ space: 12 }) {
                      // 不贴标
                      Row() {
                        Checkbox()
                          .select(this.noLabeling)
                          .onChange((value: boolean) => {
                            this.noLabeling = value
                          })
                          .width(14)
                          .height(14)
                          .shape(CheckBoxShape.ROUNDED_SQUARE)
                          .margin({ right: 6 })

                        Text('不贴标')
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().textColor)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)

                      // 按出口方式
                      Row() {
                        Checkbox()
                          .select(this.byExport)
                          .onChange((value: boolean) => {
                            this.byExport = value
                          })
                          .width(14)
                          .height(14)
                          .shape(CheckBoxShape.ROUNDED_SQUARE)
                          .margin({ right: 6 })

                        Text('按出口方式')
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().textColor)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                    }
                    .layoutWeight(1)

                    // 右列
                    Column({ space: 12 }) {
                      // 按等级方式
                      Row() {
                        Checkbox()
                          .select(this.byGrade)
                          .onChange((value: boolean) => {
                            this.byGrade = value
                          })
                          .width(14)
                          .height(14)
                          .shape(CheckBoxShape.ROUNDED_SQUARE)
                          .margin({ right: 6 })

                        Text('按等级方式')
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().textColor)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)

                      // 按容器方式
                      Row() {
                        Checkbox()
                          .select(this.byContainer)
                          .onChange((value: boolean) => {
                            this.byContainer = value
                          })
                          .width(14)
                          .height(14)
                          .shape(CheckBoxShape.ROUNDED_SQUARE)
                          .margin({ right: 6 })

                        Text('按容器方式')
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().textColor)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .height(120)
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)

                  Text('贴标工作方式')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.getCurrentTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 贴标1
              Stack({ alignContent: Alignment.TopStart }) {
                Column({ space: 12 }) {
                  // 贴标名称
                  Row() {
                    Text('贴标名称：')
                      .fontSize(14)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(80)
                    TextInput({ text: this.machine1Name, placeholder: '请输入贴标名称' })
                      .layoutWeight(1)
                      .height(32)
                      .fontSize(14)
                      .backgroundColor(Color.White)
                      .border({ width: 1, color: this.getCurrentTheme().borderColor })
                      .borderRadius(4)
                      .onChange((value: string) => {
                        this.machine1Name = value
                      })
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)

                  // 贴标个数和总数
                  Row({ space: 16 }) {
                    // 贴标个数
                    Row() {
                      Text('贴标个数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                      TextInput({ text: this.machine1LabelCount, placeholder: '0' })
                        .type(InputType.Number)
                        .layoutWeight(1)
                        .height(32)
                        .fontSize(14)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onChange((value: string) => {
                          this.machine1LabelCount = value
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    // 总数
                    Row() {
                      Text('总数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(60)
                      Select(this.getTotalCountOptions())
                        .selected(this.machine1TotalCount - 1)
                        .value(this.machine1TotalCount.toString())
                        .font({ size: 14 })
                        .height(32)
                        .layoutWeight(1)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onSelect((index: number) => {
                          this.machine1TotalCount = index + 1
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                }
                .width('100%')
                .height(120)
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)

                  Text('贴标1')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.getCurrentTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 贴标2
              Stack({ alignContent: Alignment.TopStart }) {
                Column({ space: 12 }) {
                  // 贴标名称
                  Row() {
                    Text('贴标名称：')
                      .fontSize(14)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(80)
                    TextInput({ text: this.machine2Name, placeholder: '请输入贴标名称' })
                      .layoutWeight(1)
                      .height(32)
                      .fontSize(14)
                      .backgroundColor(Color.White)
                      .border({ width: 1, color: this.getCurrentTheme().borderColor })
                      .borderRadius(4)
                      .onChange((value: string) => {
                        this.machine2Name = value
                      })
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)

                  // 贴标个数和总数
                  Row({ space: 16 }) {
                    // 贴标个数
                    Row() {
                      Text('贴标个数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                      TextInput({ text: this.machine2LabelCount, placeholder: '0' })
                        .type(InputType.Number)
                        .layoutWeight(1)
                        .height(32)
                        .fontSize(14)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onChange((value: string) => {
                          this.machine2LabelCount = value
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    // 总数
                    Row() {
                      Text('总数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(60)
                      Select(this.getTotalCountOptions())
                        .selected(this.machine2TotalCount - 1)
                        .value(this.machine2TotalCount.toString())
                        .font({ size: 14 })
                        .height(32)
                        .layoutWeight(1)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onSelect((index: number) => {
                          this.machine2TotalCount = index + 1
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                }
                .width('100%')
                .height(120)
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)

                  Text('贴标2')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.getCurrentTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 贴标3
              Stack({ alignContent: Alignment.TopStart }) {
                Column({ space: 12 }) {
                  // 贴标名称
                  Row() {
                    Text('贴标名称：')
                      .fontSize(14)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(80)
                    TextInput({ text: this.machine3Name, placeholder: '请输入贴标名称' })
                      .layoutWeight(1)
                      .height(32)
                      .fontSize(14)
                      .backgroundColor(Color.White)
                      .border({ width: 1, color: this.getCurrentTheme().borderColor })
                      .borderRadius(4)
                      .onChange((value: string) => {
                        this.machine3Name = value
                      })
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)

                  // 贴标个数和总数
                  Row({ space: 16 }) {
                    // 贴标个数
                    Row() {
                      Text('贴标个数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                      TextInput({ text: this.machine3LabelCount, placeholder: '0' })
                        .type(InputType.Number)
                        .layoutWeight(1)
                        .height(32)
                        .fontSize(14)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onChange((value: string) => {
                          this.machine3LabelCount = value
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    // 总数
                    Row() {
                      Text('总数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(60)
                      Select(this.getTotalCountOptions())
                        .selected(this.machine3TotalCount - 1)
                        .value(this.machine3TotalCount.toString())
                        .font({ size: 14 })
                        .height(32)
                        .layoutWeight(1)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onSelect((index: number) => {
                          this.machine3TotalCount = index + 1
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                }
                .width('100%')
                .height(120)
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)

                  Text('贴标3')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.getCurrentTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 贴标4
              Stack({ alignContent: Alignment.TopStart }) {
                Column({ space: 12 }) {
                  // 贴标名称
                  Row() {
                    Text('贴标名称：')
                      .fontSize(14)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(80)
                    TextInput({ text: this.machine4Name, placeholder: '请输入贴标名称' })
                      .layoutWeight(1)
                      .height(32)
                      .fontSize(14)
                      .backgroundColor(Color.White)
                      .border({ width: 1, color: this.getCurrentTheme().borderColor })
                      .borderRadius(4)
                      .onChange((value: string) => {
                        this.machine4Name = value
                      })
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)

                  // 贴标个数和总数
                  Row({ space: 16 }) {
                    // 贴标个数
                    Row() {
                      Text('贴标个数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(80)
                      TextInput({ text: this.machine4LabelCount, placeholder: '0' })
                        .type(InputType.Number)
                        .layoutWeight(1)
                        .height(32)
                        .fontSize(14)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onChange((value: string) => {
                          this.machine4LabelCount = value
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)

                    // 总数
                    Row() {
                      Text('总数：')
                        .fontSize(14)
                        .fontColor(this.getCurrentTheme().textColor)
                        .width(60)
                      Select(this.getTotalCountOptions())
                        .selected(this.machine4TotalCount - 1)
                        .value(this.machine4TotalCount.toString())
                        .font({ size: 14 })
                        .height(32)
                        .layoutWeight(1)
                        .backgroundColor(Color.White)
                        .border({ width: 1, color: this.getCurrentTheme().borderColor })
                        .borderRadius(4)
                        .onSelect((index: number) => {
                          this.machine4TotalCount = index + 1
                        })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')
                }
                .width('100%')
                .height(120)
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor(this.getCurrentTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.getCurrentTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)

                  Text('贴标4')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.getCurrentTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.getCurrentTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .margin({ bottom: 16 })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 20, bottom: 20 })
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)

          // 底部按钮区域
          Row() {
            Blank().layoutWeight(1)

            // 取消按钮
            Button('取消')
              .fontSize(16)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().backgroundColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .width(100)
              .height(40)
              .onClick(() => {
                this.handleCancel()
              })

            // 确定按钮
            Button('确定')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#4CAF50')
              .borderRadius(8)
              .width(100)
              .height(40)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 20 })
        }
        .width(900)
        .height(700)
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

