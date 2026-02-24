/**
 * 修改农户信息对话框组件
 * 功能：修改客户名称、农场名称、水果名称
 * 用途：在双击"进行中"状态的历史数据时弹出
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

// 农户信息接口
export interface CustomerInfo {
  customerName: string
  farmName: string
  fruitName: string
}

@Component
export struct ModifyCustomerInfoDialog {
  @Prop isVisible: boolean = false
  @Prop initialData?: CustomerInfo
  
  // 表单数据
  @State customerName: string = ''
  @State farmName: string = ''
  @State fruitName: string = ''
  
  // 水果名称选项（可以根据实际需求从数据库或配置中获取）
  @State fruitOptions: string[] = ['橙', '苹果', '梨', '葡萄', '草莓']
  @State showFruitPicker: boolean = false
  
  // 对话框回调
  onConfirm?: (data: CustomerInfo) => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(OmniThemeManager.getInstance().getCurrentTheme())
  }

  private normalizeFruitName(name: string): string {
    let t = (name ?? '').trim()
    const prefixes = ['FruitName/', 'FruitName:', 'fruitName/', 'fruitName:', 'fruitname/', 'fruitname:']
    for (const p of prefixes) {
      if (t.startsWith(p)) {
        t = t.slice(p.length).trim()
        break
      }
    }
    return t
  }

  // 初始化数据
  aboutToAppear(): void {
    if (this.initialData) {
      this.customerName = this.initialData.customerName
      this.farmName = this.initialData.farmName
      this.fruitName = this.normalizeFruitName(this.initialData.fruitName)
    }
  }

  // 监听 initialData 变化
  aboutToUpdate(): void {
    if (this.initialData) {
      this.customerName = this.initialData.customerName
      this.farmName = this.initialData.farmName
      this.fruitName = this.normalizeFruitName(this.initialData.fruitName)
    }
  }

  // 确认按钮点击
  private handleConfirm(): void {
    if (this.onConfirm) {
      this.onConfirm({
        customerName: this.customerName,
        farmName: this.farmName,
        fruitName: this.fruitName
      })
    }
  }

  // 取消按钮点击
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 遮罩层
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
            Text('修改农户信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)

            // 关闭按钮
            Image($r('sys.media.ohos_ic_public_close'))
              .width(22)
              .height(22)
              .fillColor(this.getCurrentTheme().textColor)
              .onClick(() => {
                this.handleCancel()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 12 })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

          // 内容区域
          Scroll() {
            Column({ space: 12 }) {
            // 客户名称
            Row() {
              Text('客户名称:')
                .fontSize(15)
                .fontColor(this.getCurrentTheme().textColor)
                .width(90)
                .textAlign(TextAlign.End)
                .margin({ right: 10 })

              TextInput({ text: this.customerName })
                .layoutWeight(1)
                .height(36)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(6)
                .fontSize(15)
                .fontColor(this.getCurrentTheme().textColor)
                .padding({ left: 10, right: 10 })
                .onChange((value: string) => {
                  this.customerName = value
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // 农场名称
            Row() {
              Text('农场名称:')
                .fontSize(15)
                .fontColor(this.getCurrentTheme().textColor)
                .width(90)
                .textAlign(TextAlign.End)
                .margin({ right: 10 })

              TextInput({ text: this.farmName })
                .layoutWeight(1)
                .height(36)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(6)
                .fontSize(15)
                .fontColor(this.getCurrentTheme().textColor)
                .padding({ left: 10, right: 10 })
                .onChange((value: string) => {
                  this.farmName = value
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Column() {
              Row() {
                Text('水果名称:')
                  .fontSize(15)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(90)
                  .textAlign(TextAlign.End)
                  .margin({ right: 10 })

                Stack() {
                  TextInput({ text: this.fruitName })
                    .height(36)
                    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                    .border({ width: 1, color: this.getCurrentTheme().borderColor })
                    .borderRadius(6)
                    .fontSize(15)
                    .fontColor(this.getCurrentTheme().textColor)
                    .padding({ left: 10, right: 36 })
                    .onChange((value: string) => {
                      this.fruitName = value
                    })

                  Button() {
                    Text('▼')
                      .fontSize(11)
                      .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
                  }
                  .width(28)
                  .height(28)
                  .backgroundColor(Color.Transparent)
                  .margin({ right: 4 })
                  .onClick(() => {
                    this.showFruitPicker = !this.showFruitPicker
                  })
                }
                .layoutWeight(1)
                .alignContent(Alignment.TopEnd)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)

              if (this.showFruitPicker) {
                Row() {
                  Blank()
                    .width(100)
                  Scroll() {
                    Column() {
                      ForEach(this.fruitOptions, (fruit: string) => {
                        Text(fruit)
                          .fontSize(14)
                          .fontColor(this.getCurrentTheme().textColor)
                          .width('100%')
                          .height(28)
                          .padding({ left: 10, right: 10 })
                          .backgroundColor(this.fruitName === fruit ? 
                            (this.getCurrentTheme().primary + '20') : 
                            (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor))
                          .onClick(() => {
                            this.fruitName = this.normalizeFruitName(fruit)
                            this.showFruitPicker = false
                          })
                      }, (fruit: string) => fruit)
                    }
                  }
                  .layoutWeight(1)
                  .height(140)
                  .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
                  .border({ width: 1, color: this.getCurrentTheme().borderColor })
                  .borderRadius(6)
                  .shadow(AppleDesignStyle.getShadowSmall())
                  .margin({ top: 4 })
                }
                .width('100%')
              }
            }
            .width('100%')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(300)
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          // 按钮区域
          Row({ space: 12 }) {
            Button('确定')
              .type(ButtonType.Normal)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .height(38)
              .borderRadius(6)
              .onClick(() => {
                this.handleConfirm()
              })

            Button('返回')
              .type(ButtonType.Normal)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .fontColor(this.getCurrentTheme().textColor)
              .fontSize(15)
              .layoutWeight(1)
              .height(38)
              .borderRadius(6)
              .onClick(() => {
                this.handleCancel()
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 16 })
        }
        .width('92%')
        .height(440)
        .constraintSize({ maxWidth: 680 })
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
        .shadow(AppleDesignStyle.getShadowMedium())
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }
}

