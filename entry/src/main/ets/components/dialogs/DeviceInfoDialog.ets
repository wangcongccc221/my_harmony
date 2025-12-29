/**
 * 设备信息对话框组件
 * 功能：显示和编辑设备信息
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'

@Component
export struct DeviceInfoDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 设备信息状态变量
  @State deviceNumber: string = 'RMFC20258013-1'
  @State deviceName: string = ''
  @State customerName: string = ''
  @State fruitVariety: string = ''
  @State exFactoryDate: string = '2021-05-11'
  @State expirationDate: string = '2021-05-11'
  @State personInCharge: string = ''
  @State contactPhone: string = ''
  @State location1: string = ''
  @State location2: string = ''
  @State location3: string = ''
  @State location4: string = ''
  @State detailedAddress: string = ''
  @State ipmVersion: string = ''
  @State rssVersion: string = ''
  @State scmVersion: string = ''
  @State fsmVersion: string = ''
  @State dwmVersion: string = ''
  @State wamVersion: string = ''
  @State iqmVersion: string = ''
  @State bdmVersion: string = ''
  @State debugger: string = ''
  @State updater: string = ''
  @State remarks: string = ''

  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('DeviceInfoDialog: 主题已变化，重新渲染')
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
        // 标题栏
        Row() {
          Text('设备信息')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button() {
            Text('×')
              .fontSize(24)
              .fontColor(this.getCurrentTheme().textColor)
          }
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .width(32)
          .height(32)
          .onClick(() => {
            this.handleCancel()
          })
        }
        .width('100%')
        .height(50)
        .padding({ left: 20, right: 12, top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 内容区域
        Scroll() {
          Row({ space: 20 }) {
            // 左列
            Column({ space: 0 }) {
              // 设备编号
              Row() {
                Text('设备编号:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.deviceNumber })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.deviceNumber = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 客户名称
              Row() {
                Text('客户名称:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.customerName })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.customerName = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 出厂日期
              Row() {
                Text('出厂日期:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                Row() {
                  TextInput({ text: this.exFactoryDate })
                    .layoutWeight(1)
                    .height(32)
                    .backgroundColor('#FFFFFF')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(4)
                    .fontSize(13)
                    .onChange((value: string) => {
                      this.exFactoryDate = value
                    })

                  Button() {
                    Text('📅')
                      .fontSize(16)
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor('transparent')
                  .width(32)
                  .height(32)
                  .margin({ left: 4 })
                  .onClick(() => {
                    // TODO: 打开日期选择器
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 负责人
              Row() {
                Text('负责人:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.personInCharge })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.personInCharge = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 所在地
              Row() {
                Text('所在地:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                Column({ space: 8 }) {
                  Row({ space: 8 }) {
                    Select([{ value: this.location1 || '请选择' }])
                      .selected(0)
                      .value(this.location1 || '请选择')
                      .layoutWeight(1)
                      .height(32)
                      .onSelect((index: number) => {
                        // TODO: 实现选择逻辑
                      })

                    Select([{ value: this.location2 || '请选择' }])
                      .selected(0)
                      .value(this.location2 || '请选择')
                      .layoutWeight(1)
                      .height(32)
                      .onSelect((index: number) => {
                        // TODO: 实现选择逻辑
                      })
                  }

                  Row({ space: 8 }) {
                    Select([{ value: this.location3 || '请选择' }])
                      .selected(0)
                      .value(this.location3 || '请选择')
                      .layoutWeight(1)
                      .height(32)
                      .onSelect((index: number) => {
                        // TODO: 实现选择逻辑
                      })

                    Select([{ value: this.location4 || '请选择' }])
                      .selected(0)
                      .value(this.location4 || '请选择')
                      .layoutWeight(1)
                      .height(32)
                      .onSelect((index: number) => {
                        // TODO: 实现选择逻辑
                      })
                  }
                }
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // IPM版本
              Row() {
                Text('IPM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.ipmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.ipmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // SCM版本
              Row() {
                Text('SCM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.scmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.scmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // DWM版本
              Row() {
                Text('DWM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.dwmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.dwmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // IQM版本
              Row() {
                Text('IQM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.iqmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.iqmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 调试人
              Row() {
                Text('调试人:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.debugger })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.debugger = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 备注
              Row() {
                Text('备注:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.remarks })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.remarks = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .layoutWeight(1)

            // 右列
            Column({ space: 0 }) {
              // 设备名称
              Row() {
                Text('设备名称:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.deviceName })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.deviceName = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 加工水果品种
              Row() {
                Text('加工水果品种:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.fruitVariety })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.fruitVariety = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 到期日期
              Row() {
                Text('到期日期:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                Row() {
                  TextInput({ text: this.expirationDate })
                    .layoutWeight(1)
                    .height(32)
                    .backgroundColor('#FFFFFF')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(4)
                    .fontSize(13)
                    .onChange((value: string) => {
                      this.expirationDate = value
                    })

                  Button() {
                    Text('📅')
                      .fontSize(16)
                  }
                  .type(ButtonType.Normal)
                  .backgroundColor('transparent')
                  .width(32)
                  .height(32)
                  .margin({ left: 4 })
                  .onClick(() => {
                    // TODO: 打开日期选择器
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 联系电话
              Row() {
                Text('联系电话:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.contactPhone })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.contactPhone = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 详细地址
              Row() {
                Text('详细地址:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.detailedAddress })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.detailedAddress = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // RSS版本
              Row() {
                Text('RSS版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.rssVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.rssVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // FSM版本
              Row() {
                Text('FSM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.fsmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.fsmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // WAM版本
              Row() {
                Text('WAM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.wamVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.wamVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // BDM版本
              Row() {
                Text('BDM版本:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.bdmVersion })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.bdmVersion = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)

              // 更新人
              Row() {
                Text('更新人:')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(80)
                  .textAlign(TextAlign.End)
                  .margin({ right: 8 })

                TextInput({ text: this.updater })
                  .layoutWeight(1)
                  .height(32)
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#CCCCCC' })
                  .borderRadius(4)
                  .fontSize(13)
                  .onChange((value: string) => {
                    this.updater = value
                  })
              }
              .width('100%')
              .margin({ bottom: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(20)
        }
        .layoutWeight(1)
        .width('100%')

        // 底部按钮区域
        Row({ space: 12 }) {
          Button('确定')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50') // 绿色背景
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              this.handleConfirm()
            })

          Button('取消')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor('#E0E0E0') // 浅灰色背景
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              this.handleCancel()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
        .border({ width: { top: 1 }, color: this.getCurrentTheme().borderColor })
      }
      .width('85%')
      .height('85%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.3)', offsetY: 4 })
      .alignSelf(ItemAlign.Center)
      .constraintSize({ maxWidth: 1000, maxHeight: 800 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

