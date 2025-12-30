/**
 * 电磁阀测试对话框组件
 * 功能：显示电磁阀测试界面，包含按通道测试和按出口测试
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { t, I18N_VERSION_KEY } from '../../utils/i18n/I18nManager'
import { NumericInput } from '../ui/inputs/NumericInput'

// 出口数据接口
interface OutletData {
  name: string
  offset: number
  distance: number
}

// Select选项接口
interface SelectOption {
  value: string
}

@Component
export struct ValveTestDialog {
  @Prop isVisible: boolean = false
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  // 按通道测试状态
  @State channelTestChannel: string = '通道 1'
  
  // 按出口测试状态
  @State outletTestChannel: string = '通道 1'
  @State parallelTest: boolean = false
  
  // 出口数据
  @State outletDataList: OutletData[] = [
    { name: '出口 1', offset: 0, distance: 42 },
    { name: '出口 2', offset: 45, distance: 0 },
    { name: '出口 3', offset: 52, distance: 5122 },
    { name: '出口 4', offset: 60, distance: 0 },
    { name: '出口 5', offset: 68, distance: 0 },
    { name: '出口 6', offset: 76, distance: 0 },
    { name: '出口 7', offset: 84, distance: 0 },
    { name: '出口 8', offset: 92, distance: 0 },
    { name: '出口 9', offset: 100, distance: 0 },
    { name: '出口 10', offset: 108, distance: 0 },
    { name: '出口 11', offset: 116, distance: 0 },
    { name: '出口 12', offset: 124, distance: 0 },
    { name: '出口 13', offset: 132, distance: 0 },
    { name: '出口 14', offset: 140, distance: 0 },
    { name: '出口 15', offset: 148, distance: 0 }
  ]

  // 通道选项
  private getChannelOptions(): SelectOption[] {
    const options: SelectOption[] = []
    options.push({ value: '通道 1' })
    options.push({ value: '通道 2' })
    options.push({ value: '通道 3' })
    options.push({ value: '通道 4' })
    return options
  }

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('ValveTestDialog: 主题已变化，重新渲染')
  }

  // 对话框回调
  onCancel?: () => void

  // 关闭对话框
  private handleClose(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 开始测试
  private handleStartTest(): void {
    console.log('开始按通道测试，通道:', this.channelTestChannel)
    // TODO: 实现测试逻辑
  }

  // 立即生效
  private handleApply(): void {
    console.log('立即生效，应用所有设置')
    // TODO: 实现应用逻辑
  }

  // 更新出口数据
  private updateOutletData(index: number, field: 'offset' | 'distance', value: number): void {
    const newList: OutletData[] = []
    for (let i = 0; i < this.outletDataList.length; i++) {
      if (i === index) {
        const newItem: OutletData = {
          name: this.outletDataList[i].name,
          offset: field === 'offset' ? value : this.outletDataList[i].offset,
          distance: field === 'distance' ? value : this.outletDataList[i].distance
        }
        newList.push(newItem)
      } else {
        newList.push(this.outletDataList[i])
      }
    }
    this.outletDataList = newList
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
          this.handleClose()
        })

      // 对话框内容
      Column() {
        // 标题栏
        Row() {
          Text('电磁阀测试')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)

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
            this.handleClose()
          })
        }
        .width('100%')
        .height(50)
        .padding({ left: 20, right: 12, top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
        // 内容区域
        Scroll() {
          Column({ space: 20 }) {
            // 按通道测试区域
            Column({ space: 12 }) {
              Text('按通道测试')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .alignSelf(ItemAlign.Start)

              Row() {
                Text('通道')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(60)

                Select(this.getChannelOptions())
                  .selected(this.getChannelOptions().findIndex(item => item.value === this.channelTestChannel))
                  .value(this.channelTestChannel)
                  .font({ size: 14 })
                  .height(36)
                  .onSelect((index: number) => {
                    this.channelTestChannel = this.getChannelOptions()[index].value
                  })
                  .layoutWeight(1)

                Button('开始测试')
                  .type(ButtonType.Normal)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#4CAF50')
                  .borderRadius(4)
                  .width(100)
                  .height(36)
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.handleStartTest()
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(8)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })

            // 按出口测试区域
            Column({ space: 12 }) {
              Text('按出口测试')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .alignSelf(ItemAlign.Start)

              Row() {
                Text('通道')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().textColor)
                  .width(60)

                Select(this.getChannelOptions())
                  .selected(this.getChannelOptions().findIndex(item => item.value === this.outletTestChannel))
                  .value(this.outletTestChannel)
                  .font({ size: 14 })
                  .height(36)
                  .onSelect((index: number) => {
                    this.outletTestChannel = this.getChannelOptions()[index].value
                  })
                  .layoutWeight(1)

                Row() {
                  Checkbox()
                    .select(this.parallelTest)
                    .onChange((value: boolean) => {
                      this.parallelTest = value
                    })
                    .width(18)
                    .height(18)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .margin({ right: 6 })

                  Text('并排测试')
                    .fontSize(14)
                    .fontColor(this.getCurrentTheme().textColor)
                }
                .margin({ left: 12 })
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
              .margin({ bottom: 8 })

              // 表格
              Column() {
                // 表头
                Row() {
                  Text('名称')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .width(100)
                    .textAlign(TextAlign.Center)
                    .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
                    .padding(8)

                  Text('偏移')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .border({ width: { right: 1, bottom: 1 }, color: this.getCurrentTheme().borderColor })
                    .padding(8)

                  Text('距离')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.getCurrentTheme().textColor)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
                    .padding(8)
                }
                .width('100%')
                .backgroundColor(this.getCurrentTheme().controlBg || this.getCurrentTheme().surfaceColor)

                // 表格内容
                ForEach(this.outletDataList, (item: OutletData, index: number) => {
                  Row() {
                    Text(item.name)
                      .fontSize(13)
                      .fontColor(this.getCurrentTheme().textColor)
                      .width(100)
                      .textAlign(TextAlign.Center)
                      .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
                      .padding(8)

                    TextInput({ text: item.offset.toString() })
                      .type(InputType.Number)
                      .layoutWeight(1)
                      .height(32)
                      .margin(4)
                      .backgroundColor('#FFFFFF')
                      .border({ width: 1, color: '#CCCCCC' })
                      .borderRadius(4)
                      .fontSize(13)
                      .onChange((value: string) => {
                        const num = parseInt(value)
                        if (!isNaN(num) && num >= 0 && num <= 9999) {
                          this.updateOutletData(index, 'offset', num)
                        }
                      })

                    TextInput({ text: item.distance.toString() })
                      .type(InputType.Number)
                      .layoutWeight(1)
                      .height(32)
                      .margin(4)
                      .backgroundColor('#FFFFFF')
                      .border({ width: 1, color: '#CCCCCC' })
                      .borderRadius(4)
                      .fontSize(13)
                      .onChange((value: string) => {
                        const num = parseInt(value)
                        if (!isNaN(num) && num >= 0 && num <= 9999) {
                          this.updateOutletData(index, 'distance', num)
                        }
                      })
                  }
                  .width('100%')
                  .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
                })
              }
              .width('100%')
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(4)
              .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .borderRadius(8)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })

            // 立即生效按钮
            Row() {
              Button('立即生效')
                .type(ButtonType.Normal)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#4CAF50')
                .borderRadius(4)
                .width(100)
                .height(36)
                .onClick(() => {
                  this.handleApply()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .margin({ top: 8 })
          }
          .width('100%')
          .padding(20)
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('80%')
      .height('85%')
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.3)', offsetY: 4 })
      .alignSelf(ItemAlign.Center)
      .constraintSize({ maxWidth: 800, maxHeight: 700 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
}

