/**
 * 通道范围设置页面组件
 * 功能：显示通道范围相关的设置内容
 * 用途：在工程设置对话框的"通道范围设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'

@Component
export struct ChannelRangePage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0 // 监听语言变化，触发 UI 更新
  // 状态变量
  @State selectedChannel: string = '通道1'
  @State cameraType: string = 'Color Camera'
  @State cameraPosition: string = 'Middle'
  @State continuousAcquisition: boolean = false
  @State displayBlob: boolean = false
  // 通道1参数状态变量
  @State maxDiameter: string = ''
  @State minDiameter: string = ''
  @State sortingDiameter: string = ''
  @State horizontalDiameterRatio: string = ''
  @State oblateEllipticalRatio: string = ''
  @State color1Ratio: string = ''
  @State color2Ratio: string = ''
  @State color3Ratio: string = ''
  @State projectionArea: string = ''
  @State defectArea: string = ''
  @State defectCount: string = ''
  @State volume: string = ''
  @State grade: string = ''

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  @Builder
  buildParameterRow(label: string, value: string, onChange: (value: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.resolveTheme().textColor)
        .width(120)

      TextInput({ placeholder: '', text: value })
        .width(150)
        .height(32)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#000000' })
        .borderRadius(4)
        .onChange((value: string) => {
          onChange(value)
        })
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Column() {
      // 大卡片
      Column() {
        // 底部控制栏
        Row({ space: 16 }) {
          Text('通道:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)

          Select([
            { value: '通道1' },
            { value: '通道2' },
            { value: '通道3' }
          ])
            .value(this.selectedChannel)
            .onSelect((index: number, value: string) => {
              this.selectedChannel = value
            })
            .width(100)
            .height(32)

          Text('相机类型:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)

          Select([
            { value: 'Color Camera' },
            { value: 'NIR Camera' }
          ])
            .value(this.cameraType)
            .onSelect((index: number, value: string) => {
              this.cameraType = value
            })
            .width(120)
            .height(32)

          Text('相机位置:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)

          Select([
            { value: 'Middle' },
            { value: 'Left' },
            { value: 'Right' }
          ])
            .value(this.cameraPosition)
            .onSelect((index: number, value: string) => {
              this.cameraPosition = value
            })
            .width(100)
            .height(32)

          // 连续采集复选框
          Checkbox()
            .select(this.continuousAcquisition)
            .onChange((value: boolean) => {
              this.continuousAcquisition = value
            })
            .width(20)
            .height(20)
            .shape(CheckBoxShape.ROUNDED_SQUARE)

          Text('连续采集')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)

          // 显示blob复选框
          Checkbox()
            .select(this.displayBlob)
            .onChange((value: boolean) => {
              this.displayBlob = value
            })
            .width(20)
            .height(20)
            .shape(CheckBoxShape.ROUNDED_SQUARE)

          Text('显示blob')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
        }
        .width('100%')
        .padding(12)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        // 主要内容区域：左侧相机预览 + 右侧设置卡片
        Row() {
          // 左侧：摄像机内容占位卡片
          Column() {
            // Text('摄像机预览区域')
            //   .fontSize(16)
            //   .fontColor('#FFFFFF')
            //   .opacity(0.5)
          }
          .width('40%')
          .height(420)
          .backgroundColor('#000000')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          // 右侧：3个垂直排列的卡片 + 通道1卡片
          Row({ space: 12 }) {
            // 3个垂直排列的卡片
            Column({ space: 12 }) {
              // 卡片1：图像区域
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  // 内容区域
                }
                .width('100%')
                .height('100%')
                .padding(12)
                .padding({ top: 20 })
                .backgroundColor(this.resolveTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.resolveTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.resolveTheme().borderColor)

                  Text('图像区域')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.resolveTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.resolveTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.resolveTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .layoutWeight(1)

              // 卡片2：图像校对和图像偏移（并排）
              Row({ space: 8 }) {
                // 图像校对卡片
                Stack({ alignContent: Alignment.TopStart }) {
                  Column() {
                    // 内容区域
                  }
                  .width('100%')
                  .height('100%')
                  .padding(12)
                  .padding({ top: 20 })
                  .backgroundColor(this.resolveTheme().surfaceColor)
                  .borderRadius(6)
                  .border({ width: 2, color: this.resolveTheme().borderColor })

                  // 标题横跨在边框顶部
                  Row() {
                    Column()
                      .width(8)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)

                    Text('图像校对')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.resolveTheme().textColor)
                      .padding({ left: 6, right: 6 })
                      .backgroundColor(this.resolveTheme().surfaceColor)

                    Column()
                      .layoutWeight(1)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)
                  }
                  .margin({ top: -8, left: 12, right: 12 })
                }
                .layoutWeight(1)
                .height('100%')

                // 图像偏移卡片
                Stack({ alignContent: Alignment.TopStart }) {
                  Column() {
                    // 内容区域
                  }
                  .width('100%')
                  .height('100%')
                  .padding(12)
                  .padding({ top: 20 })
                  .backgroundColor(this.resolveTheme().surfaceColor)
                  .borderRadius(6)
                  .border({ width: 2, color: this.resolveTheme().borderColor })

                  // 标题横跨在边框顶部
                  Row() {
                    Column()
                      .width(8)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)

                    Text('图像偏移')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.resolveTheme().textColor)
                      .padding({ left: 6, right: 6 })
                      .backgroundColor(this.resolveTheme().surfaceColor)

                    Column()
                      .layoutWeight(1)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)
                  }
                  .margin({ top: -8, left: 12, right: 12 })
                }
                .layoutWeight(1)
                .height('100%')
              }
              .width('100%')
              .layoutWeight(1)

              // 卡片3：直径示意图
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  // 内容区域
                }
                .width('100%')
                .height('100%')
                .padding(12)
                .padding({ top: 20 })
                .backgroundColor(this.resolveTheme().surfaceColor)
                .borderRadius(6)
                .border({ width: 2, color: this.resolveTheme().borderColor })

                // 标题横跨在边框顶部
                Row() {
                  Column()
                    .width(8)
                    .height(2)
                    .backgroundColor(this.resolveTheme().borderColor)

                  Text('直径示意图')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.resolveTheme().textColor)
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.resolveTheme().surfaceColor)

                  Column()
                    .layoutWeight(1)
                    .height(2)
                    .backgroundColor(this.resolveTheme().borderColor)
                }
                .margin({ top: -8, left: 12, right: 12 })
              }
              .width('100%')
              .layoutWeight(1)
            }
            .width(300)
            .height(420)
            .alignItems(HorizontalAlign.Start)

            // 通道1卡片
            Stack({ alignContent: Alignment.TopStart }) {
              Scroll() {
                Column({ space: 8 }) {
                  // 参数行：最大直径
                  this.buildParameterRow('最大直径', this.maxDiameter, (value: string) => {
                    this.maxDiameter = value
                  })

                  // 参数行：最小直径
                  this.buildParameterRow('最小直径', this.minDiameter, (value: string) => {
                    this.minDiameter = value
                  })

                  // 参数行：分选直径
                  this.buildParameterRow('分选直径', this.sortingDiameter, (value: string) => {
                    this.sortingDiameter = value
                  })

                  // 参数行：横径比
                  this.buildParameterRow('横径比', this.horizontalDiameterRatio, (value: string) => {
                    this.horizontalDiameterRatio = value
                  })

                  // 参数行：扁椭型横径比
                  this.buildParameterRow('扁椭型横径比', this.oblateEllipticalRatio, (value: string) => {
                    this.oblateEllipticalRatio = value
                  })

                  // 参数行：颜色1比例
                  this.buildParameterRow('颜色1比例', this.color1Ratio, (value: string) => {
                    this.color1Ratio = value
                  })

                  // 参数行：颜色2比例
                  this.buildParameterRow('颜色2比例', this.color2Ratio, (value: string) => {
                    this.color2Ratio = value
                  })

                  // 参数行：颜色3比例
                  this.buildParameterRow('颜色3比例', this.color3Ratio, (value: string) => {
                    this.color3Ratio = value
                  })

                  // 参数行：投影面积
                  this.buildParameterRow('投影面积', this.projectionArea, (value: string) => {
                    this.projectionArea = value
                  })

                  // 参数行：瑕疵面积
                  this.buildParameterRow('瑕疵面积', this.defectArea, (value: string) => {
                    this.defectArea = value
                  })

                  // 参数行：瑕疵个数
                  this.buildParameterRow('瑕疵个数', this.defectCount, (value: string) => {
                    this.defectCount = value
                  })


                  this.buildParameterRow('体积', this.volume, (value: string) => {
                    this.volume = value
                  })


                  this.buildParameterRow('等级', this.grade, (value: string) => {
                    this.grade = value
                  })
                }
                .width('100%')
                .padding(12)
                .padding({ top: 20 })
              }
              .width('100%')
              .height('100%')
              .backgroundColor(this.resolveTheme().surfaceColor)
              .borderRadius(6)
              .border({ width: 1, color: this.resolveTheme().borderColor })

              // 标题横跨在边框顶部
              Row() {
                Column()
                  .width(8)
                  .height(2)
                  .backgroundColor(this.resolveTheme().borderColor)

                Text('通道1')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
            .fontColor(this.resolveTheme().textColor)
                  .padding({ left: 6, right: 6 })
                  .backgroundColor(this.resolveTheme().surfaceColor)

                Column()
                  .layoutWeight(1)
                  .height(2)
                  .backgroundColor(this.resolveTheme().borderColor)
              }
              .margin({ top: -8, left: 12, right: 12 })
            }
            .layoutWeight(1)
            .height(420)
          }
          .layoutWeight(1)
          .margin({ left: 12 })
        }
        .width('100%')
        .margin({ top: 12 })

        // 底部6个卡片区域
        Row({ space: 16 }) {
          // 卡片1：相机白平衡参数
          this.buildBottomCard('相机白平衡参数')

          // 卡片2：白平衡校正
          this.buildBottomCard('白平衡校正')

          // 卡片3：其它相机参数
          this.buildBottomCard('其它相机参数')

          // 卡片4：多相机校准
          this.buildBottomCard('多相机校准')

          // 卡片5：算法参数
          this.buildBottomCard('算法参数')

          // 卡片6：像素当量
          this.buildBottomCard('像素当量')
        }
        .width('100%')
        .margin({ top: 35 })
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(8)
      .border({ width: 1, color: this.resolveTheme().borderColor })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }

  @Builder
  buildBottomCard(title: string) {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        // 内容区域（暂时为空）
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.resolveTheme().textColor)
          .padding({ left: 6, right: 6 })
          .backgroundColor(this.resolveTheme().surfaceColor)

        Column()
          .layoutWeight(1)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)
  }
      .margin({ top: -8, left: 12, right: 12 })
    }
    .layoutWeight(1)
    .height(220)

  }
}