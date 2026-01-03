import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'
import { NumericInput } from '../../ui/inputs/NumericInput'
import { DirectionalNumericInput } from '../../ui/inputs/DirectionalNumericInput'

@Component
export struct ChannelRangePage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0

  @State selectedChannel: string = '通道1'
  @State cameraType: string = 'Color Camera'
  @State cameraPosition: string = 'Middle'
  @State continuousAcquisition: boolean = false
  @State displayBlob: boolean = false
  // 图像区域参数状态变量
  @State imageAreaValue1: number = 0
  @State imageAreaValue2: number = 0
  // 图像校对状态变量
  @State imageCalibrationEnabled: boolean = false
  @State imageCalibrationValue: number = 0
  // 图像偏移状态变量
  @State imageOffsetValue: number = 0
  // 相机白平衡参数状态变量
  @State whiteBalanceR: number = 0
  @State whiteBalanceG: number = 0
  @State whiteBalanceB: number = 0
  // 白平衡校正状态变量
  @State whiteBalanceCorrectionEnabled: boolean = false
  @State autoWhiteBalanceEnabled: boolean = false
  @State whiteBalanceCorrectionR: number = 0
  @State whiteBalanceCorrectionG: number = 0
  @State whiteBalanceCorrectionB: number = 0
  @State whiteBalanceCorrectionRDisplay: string = ''
  @State whiteBalanceCorrectionGDisplay: string = ''
  @State whiteBalanceCorrectionBDisplay: string = ''
  // 其它相机参数状态变量
  @State shutter: number = 120
  @State gamma: number = 0.50
  @State cameraDelay: number = 120
  // 算法参数状态变量
  @State separateFruitThreshold: number = 100
  @State separateWhiteboardThreshold: number = 1056964608
  @State fruitOverlapThreshold: number = 0
  // 多相机校准状态变量
  @State multiCameraCalibrationEnabled: boolean = false
  @State colorYL: string = ''
  @State colorYM: string = ''
  @State colorYR: string = ''
  @State hL: string = ''
  @State hM: string = ''
  @State hR: string = ''
  @State nir1YL: string = ''
  @State nir1YM: string = ''
  @State nir1YR: string = ''
  @State nir2YL: string = ''
  @State nir2YM: string = ''
  @State nir2YR: string = ''
  // 像素当量状态变量
  @State physicalLength: number = 0
  @State pixelEquivalent: number = 0.100
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

          Row() {
            Row() {
              Radio({ value: 'Color Camera', group: 'cameraType' })
                .checked(this.cameraType === 'Color Camera')
                .width(14)
                .height(14)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.cameraType = 'Color Camera'
                  }
                })
              Text('Color Camera')
                .fontSize(14)
                .fontColor(this.resolveTheme().textColor)
                .margin({ left: 4 })
            }
            .alignItems(VerticalAlign.Center)
            .margin({ right: 16 })
            
            Row() {
              Radio({ value: 'NIR Camera', group: 'cameraType' })
                .checked(this.cameraType === 'NIR Camera')
                .width(14)
                .height(14)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.cameraType = 'NIR Camera'
                  }
                })
              Text('NIR Camera')
                .fontSize(14)
                .fontColor(this.resolveTheme().textColor)
                .margin({ left: 4 })
            }
            .alignItems(VerticalAlign.Center)
          }
          .alignItems(VerticalAlign.Center)

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

        Row() {

          Column() {

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
                  // 第一个输入框（居中）
                  NumericInput({ value: $imageAreaValue1, min: 0, max: 9999, step: 1 })
                    .width(120)
                    .height(30)
                  
                  // 第二个输入框及其周围的按钮（使用DirectionalNumericInput组件）
                  DirectionalNumericInput({ 
                    value: $imageAreaValue2, 
                    min: 0, 
                    max: 9999, 
                    step: 1,
                    inputWidth: 120,
                    inputHeight: 30
                  })
                  .margin({ top: 5 })
                }
                .width('100%')
                .height('100%')
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Center)
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
                    // 内容区域：带方向按钮的输入框（单按钮模式：↑↓←→）
                    DirectionalNumericInput({ 
                      value: $imageCalibrationValue, 
                      min: 0, 
                      max: 9999, 
                      step: 1,
                      inputWidth: 120,
                      inputHeight: 30,
                      buttonMode: 'single'
                    })
                  }
                  .width('100%')
                  .height('100%')
                  .padding(12)
                  .padding({ top: 20 })
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(this.resolveTheme().surfaceColor)
                  .borderRadius(6)
                  .border({ width: 2, color: this.resolveTheme().borderColor })

                  // 标题横跨在边框顶部（复选框+文本）
                  Row() {
                    Column()
                      .width(8)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)

                    Row() {
                      Checkbox()
                        .select(this.imageCalibrationEnabled)
                        .onChange((value: boolean) => {
                          this.imageCalibrationEnabled = value
                        })
                        .width(16)
                        .height(16)
                        .shape(CheckBoxShape.ROUNDED_SQUARE)
                        .margin({ right: 6 })

                      Text('图像校对')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.resolveTheme().textColor)
                    }
                    .padding({ left: 6, right: 6 })
                    .backgroundColor(this.resolveTheme().surfaceColor)
                    .alignItems(VerticalAlign.Center)
                    .justifyContent(FlexAlign.Start)
                    .height(18)

                    Column()
                      .layoutWeight(1)
                      .height(2)
                      .backgroundColor(this.resolveTheme().borderColor)
                  }
                  .margin({ top: -8, left: 12, right: 12 })
                  .alignItems(VerticalAlign.Center)
                }
                .layoutWeight(1)
                .height('100%')

                // 图像偏移卡片
                Stack({ alignContent: Alignment.TopStart }) {
                  Column() {
                    // 上方↑按钮
                    Button() {
                      Text('↑')
                        .fontSize(9)
                        .fontColor(this.resolveTheme().textColor)
                    }
                    .type(ButtonType.Normal)
                    .width(16)
                    .height(16)
                    .padding(0)
                    .backgroundColor('#F5F5F5')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(2)
                    .margin({ bottom: 4 })
                    .onClick(() => {
                      if (this.imageOffsetValue + 1 <= 9999) {
                        this.imageOffsetValue += 1
                      }
                    })
                    
                    // 带上下按钮的输入框
                    NumericInput({ value: $imageOffsetValue, min: 0, max: 9999, step: 1 })
                      .width(120)
                      .height(30)
                    
                    // 下方↓按钮
                    Button() {
                      Text('↓')
                        .fontSize(9)
                        .fontColor(this.resolveTheme().textColor)
                    }
                    .type(ButtonType.Normal)
                    .width(16)
                    .height(16)
                    .padding(0)
                    .backgroundColor('#F5F5F5')
                    .border({ width: 1, color: '#CCCCCC' })
                    .borderRadius(2)
                    .margin({ top: 4 })
                    .onClick(() => {
                      if (this.imageOffsetValue - 1 >= 0) {
                        this.imageOffsetValue -= 1
                      }
                    })
                  }
                  .width('100%')
                  .height('100%')
                  .padding(12)
                  .padding({ top: 20 })
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
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
                Column({ space: 8 }) {
                  // 图例项：最小直径（蓝色）
                  Row() {
                    Column()
                      .width(150)
                      .height(2)
                      .backgroundColor('#0000FF') // 蓝色
                      .margin({ right: 8 })
                    
                    Text('最小直径')
                      .fontSize(12)
                      .fontColor(this.resolveTheme().textColor)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  
                  // 图例项：最大直径（绿色）
                  Row() {
                    Column()
                      .width(150)
                      .height(2)
                      .backgroundColor('#00FF00') // 绿色
                      .margin({ right: 8 })
                    
                    Text('最大直径')
                      .fontSize(12)
                      .fontColor(this.resolveTheme().textColor)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  
                  // 图例项：对称轴（红色）
                  Row() {
                    Column()
                      .width(150)
                      .height(2)
                      .backgroundColor('#FF0000') // 红色
                      .margin({ right: 8 })
                    
                    Text('对称轴')
                      .fontSize(12)
                      .fontColor(this.resolveTheme().textColor)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  
                  // 图例项：最大弦（黄色）
                  Row() {
                    Column()
                      .width(150)
                      .height(2)
                      .backgroundColor('#FFFF00') // 黄色
                      .margin({ right: 8 })
                    
                    Text('最大弦')
                      .fontSize(12)
                      .fontColor(this.resolveTheme().textColor)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  
                  // 图例项：垂轴径（品红色）
                  Row() {
                    Column()
                      .width(150)
                      .height(2)
                      .backgroundColor('#FF00FF') // 品红色/粉色
                      .margin({ right: 8 })
                    
                    Text('垂轴径')
                      .fontSize(12)
                      .fontColor(this.resolveTheme().textColor)
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .height('100%')
                .padding(12)
                .padding({ top: 20 })
                .justifyContent(FlexAlign.Start)
                .alignItems(HorizontalAlign.Start)
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
            .width('45%')
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
          this.buildWhiteBalanceCard()

          // 卡片2：白平衡校正
          this.buildWhiteBalanceCorrectionCard()

          // 卡片3：其它相机参数
          this.buildOtherCameraParamsCard()

          // 卡片4：多相机校准
          this.buildMultiCameraCalibrationCard()

          // 卡片5：算法参数
          this.buildAlgorithmParamsCard()

          // 卡片6：像素当量
          this.buildPixelEquivalentCard()
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

  @Builder
  buildWhiteBalanceCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        // R分量
        Row() {
          Text('R分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(60)
          
          NumericInput({ value: $whiteBalanceR, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // G分量
        Row() {
          Text('G分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(60)
          
          NumericInput({ value: $whiteBalanceG, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // B分量
        Row() {
          Text('B分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(60)
          
          NumericInput({ value: $whiteBalanceB, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Text('相机白平衡参数')
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

  @Builder
  buildWhiteBalanceCorrectionCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        // 输入标准值区域
        Row() {
          Text('输入标准值')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
          
          Blank()
          
          Button('获取系数')
            .type(ButtonType.Normal)
            .fontSize(12)
            .fontColor(this.resolveTheme().textColor)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .width(80)
            .height(28)
            .onClick(() => {
              // TODO: 实现获取系数逻辑
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 4 })
        
        // R分量
        Row() {
          Text('R分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(50)
          
          NumericInput({ value: $whiteBalanceCorrectionR, min: 0, max: 9999, step: 1 })
            .width(80)
            .height(30)
          
          // 右侧显示区域
          TextInput({ text: this.whiteBalanceCorrectionRDisplay, placeholder: '' })
            .width(60)
            .height(30)
            .margin({ left: 6 })
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // G分量
        Row() {
          Text('G分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(50)
          
          NumericInput({ value: $whiteBalanceCorrectionG, min: 0, max: 9999, step: 1 })
            .width(80)
            .height(30)
          
          // 右侧显示区域
          TextInput({ text: this.whiteBalanceCorrectionGDisplay, placeholder: '' })
            .width(60)
            .height(30)
            .margin({ left: 6 })
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // B分量
        Row() {
          Text('B分量:')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(50)
          
          NumericInput({ value: $whiteBalanceCorrectionB, min: 0, max: 9999, step: 1 })
            .width(80)
            .height(30)
          
          // 右侧显示区域
          TextInput({ text: this.whiteBalanceCorrectionBDisplay, placeholder: '' })
            .width(60)
            .height(30)
            .margin({ left: 6 })
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部（两个复选框+文本）
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Row({ space: 8 }) {
          // 第一个复选框：白平衡校正
          Row() {
            Checkbox()
              .select(this.whiteBalanceCorrectionEnabled)
              .onChange((value: boolean) => {
                this.whiteBalanceCorrectionEnabled = value
              })
              .width(14)
              .height(14)
              .shape(CheckBoxShape.ROUNDED_SQUARE)
              .margin({ right: 4 })

            Text('白平衡校正')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.resolveTheme().textColor)
          }
          .alignItems(VerticalAlign.Center)

          // 第二个复选框：自动白平衡
          Row() {
            Checkbox()
              .select(this.autoWhiteBalanceEnabled)
              .onChange((value: boolean) => {
                this.autoWhiteBalanceEnabled = value
              })
              .width(14)
              .height(14)
              .shape(CheckBoxShape.ROUNDED_SQUARE)
              .margin({ right: 4 })

            Text('自动白平衡')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.resolveTheme().textColor)
          }
          .alignItems(VerticalAlign.Center)
        }
        .padding({ left: 4, right: 4 })
        .backgroundColor(this.resolveTheme().surfaceColor)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .height(18)

        Column()
          .layoutWeight(1)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)
      }
      .margin({ top: -8, left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .layoutWeight(1)
    .height(220)
  }

  @Builder
  buildOtherCameraParamsCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        // 快门
        Row() {
          Text('快门')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(80)
          
          NumericInput({ value: $shutter, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // Gamma
        Row() {
          Text('Gamma')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(80)
          
          NumericInput({ value: $gamma, min: 0, max: 10, step: 0.01 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 相机延时μs
        Row() {
          Text('相机延时μs')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(80)
          
          NumericInput({ value: $cameraDelay, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Text('其它相机参数')
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

  @Builder
  buildAlgorithmParamsCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        // 分离水果阈值
        Row() {
          Text('分离水果阈值')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(100)
          
          NumericInput({ value: $separateFruitThreshold, min: 0, max: 999999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 分离白板阈值
        Row() {
          Text('分离白板阈值')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(100)
          
          NumericInput({ value: $separateWhiteboardThreshold, min: 0, max: 9999999999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 水果重叠阈值
        Row() {
          Text('水果重叠阈值')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(100)
          
          NumericInput({ value: $fruitOverlapThreshold, min: 0, max: 999999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Text('算法参数')
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

  @Builder
  buildMultiCameraCalibrationCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 6 }) {
        // 列标题行
        Row() {
          Blank()
            .width(55) // 占位，对齐行标题列
          
          Text('L')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(40)
            .textAlign(TextAlign.Center)
          
          Text('M')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(40)
            .textAlign(TextAlign.Center)
          
          Text('R')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(40)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .margin({ bottom: 2 })
        
        // COLOR Y 行
        Row() {
          Text('COLOR Y')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(55)
          
          TextInput({ text: this.colorYL, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.colorYM, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.colorYR, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // H 行
        Row() {
          Text('H')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(55)
          
          TextInput({ text: this.hL, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.hM, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.hR, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // NIR1 Y 行
        Row() {
          Text('NIR1 Y')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(55)
          
          TextInput({ text: this.nir1YL, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.nir1YM, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.nir1YR, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // NIR2 Y 行
        Row() {
          Text('NIR2 Y')
            .fontSize(10)
            .fontColor(this.resolveTheme().textColor)
            .width(55)
          
          TextInput({ text: this.nir2YL, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.nir2YM, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
          
          TextInput({ text: this.nir2YR, placeholder: '' })
            .width(40)
            .height(24)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .fontSize(10)
            .margin({ left: 3 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(10)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部（复选框+文本）
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Row() {
          Checkbox()
            .select(this.multiCameraCalibrationEnabled)
            .onChange((value: boolean) => {
              this.multiCameraCalibrationEnabled = value
            })
            .width(14)
            .height(14)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .margin({ right: 4 })

          Text('校准开关')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.resolveTheme().textColor)
            .margin({ right: 8 })

          Text('多相机校准')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.resolveTheme().textColor)
        }
        .padding({ left: 4, right: 4 })
        .backgroundColor(this.resolveTheme().surfaceColor)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .height(18)

        Column()
          .layoutWeight(1)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)
      }
      .margin({ top: -8, left: 12, right: 12 })
      .alignItems(VerticalAlign.Center)
    }
    .layoutWeight(1)
    .height(220)
  }

  @Builder
  buildPixelEquivalentCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column({ space: 12 }) {
        // 物理长度(mm)
        Row() {
          Text('物理长度(mm)')
            .fontSize(14)
            .fontColor(this.resolveTheme().textColor)
            .width(100)
          
          NumericInput({ value: $physicalLength, min: 0, max: 9999, step: 1 })
            .width(100)
            .height(30)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 自动计算按钮和像素当量输入框
        Row() {
          Button('自动计算')
            .type(ButtonType.Normal)
            .fontSize(12)
            .fontColor(this.resolveTheme().textColor)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(4)
            .width(80)
            .height(30)
            .onClick(() => {
              // TODO: 实现自动计算逻辑
            })
          
          NumericInput({ value: $pixelEquivalent, min: 0, max: 999.999, step: 0.001 })
            .width(100)
            .height(30)
            .margin({ left: 12 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        
        // 立即生效按钮
        Row() {
          Button('立即生效')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50') // 绿色背景
            .borderRadius(4)
            .width(100)
            .height(36)
            .onClick(() => {
              // TODO: 实现立即生效逻辑
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .padding({ top: 24 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(this.resolveTheme().surfaceColor)
      .borderRadius(6)
      .border({ width: 2, color: this.resolveTheme().borderColor })

      // 标题横跨在边框顶部
      Row() {
        Column()
          .width(8)
          .height(2)
          .backgroundColor(this.resolveTheme().borderColor)

        Text('像素当量')
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
    .height(180)
  }
}