/**
 * 重量设置页面组件
 * 功能：显示重量相关的设置内容
 * 用途：在工程设置对话框的"重量设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { IBestButton } from '@ibestservices/ibest-ui'
import { FormInputField } from '../../ui/forms/FormInputField'

@Component
export struct WeightSettingsPage {
  @State private theme: ExtendedOmniThemeStyle = getCurrentTheme()
  @State private workingStatusCode: number = 0
  @State private globalTargetWeight: number = 150
  @State private globalTolerance: number = 5
  @State private globalMaxLoad: number = 2000
  @State private globalMinWeight: number = 80
  @State private channelGain: number = 100
  @State private channelOffset: number = 0
  @State private channelSmoothing: number = 3
  @State private channelAlarmThreshold: number = 120
  @State private grossWeight: number = 2000
  @State private tareWeight: number = 120
  @State private netWeight: number = 1880
  @State private averageWeight: number = 150

  aboutToAppear() {
    this.theme = getCurrentTheme()
  }

  build() {
    Row() {
      // 左边大卡片容器
      Column() {
        // 工作状态区域 - 左上角
        Row() {
          FormInputField({
            config: {
              label: '工作状态',
              value: this.workingStatusCode,
              minValue: 0,
              maxValue: 10,
              labelWidth: 96,
              inputMinWidth: 140,
              inputMaxWidth: 160,
              inputHeight: 40,
              fontSize: 18
            },
            onValueChange: (value: number) => {
              this.workingStatusCode = value
            }
          })
            .layoutWeight(1)
            .margin({ right: 12 })

          // 复位按钮（矩形）- 与输入框垂直对齐
          IBestButton({
            text: '复位',
            type: 'primary'
          })
            .width(80)  // 宽度80px
            .height(40)  // 高度40px
            .onClick(() => {
              // 复位按钮点击事件
              console.log('复位按钮被点击')
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)  // 垂直居中对齐
        .margin({ bottom: 20 })
        
        // 参数卡片区域 - 并排显示
        Row() {
          // 全局参数卡片
          Column() {
            // 卡片标题 - 放在边框上
            Text('全局参数')
              .fontSize(18)  // 标题字体
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme.textColor)
              .backgroundColor(this.theme.surfaceColor)  // 背景色与卡片一致
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
              .alignSelf(ItemAlign.Start)
            
            // 卡片内容区域
            Column() {
              Row() {
                FormInputField({
                  config: {
                    label: '目标重量',
                    value: this.globalTargetWeight,
                    unit: 'g',
                    minValue: 0,
                    maxValue: 5000
                  },
                  onValueChange: (value: number) => {
                    this.globalTargetWeight = value
                  }
                })
                  .margin({ right: 12 })

                FormInputField({
                  config: {
                    label: '重量公差',
                    value: this.globalTolerance,
                    unit: 'g',
                    minValue: 0,
                    maxValue: 100
                  },
                  onValueChange: (value: number) => {
                    this.globalTolerance = value
                  }
                })
              }
              .width('100%')
              .margin({ bottom: 10 })

              Row() {
                FormInputField({
                  config: {
                    label: '最大载重',
                    value: this.globalMaxLoad,
                    unit: 'g',
                    minValue: 0,
                    maxValue: 100000
                  },
                  onValueChange: (value: number) => {
                    this.globalMaxLoad = value
                  }
                })
                  .margin({ right: 12 })

                FormInputField({
                  config: {
                    label: '最小重量',
                    value: this.globalMinWeight,
                    unit: 'g',
                    minValue: 0,
                    maxValue: 5000
                  },
                  onValueChange: (value: number) => {
                    this.globalMinWeight = value
                  }
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(8)
            .layoutWeight(1)
          }
          .width('50%')  // 宽度50%
          .height('60%')  // 高度60px
          .border({ width: 1, color: this.theme.borderColor })
          .borderRadius(8)
          .backgroundColor(this.theme.surfaceColor)
          .margin({ right: 12 })
          
          // 通道参数卡片
          Column() {
            // 卡片标题 - 放在边框上
            Text('通道参数')
              .fontSize(18)  // 标题字体
              .fontWeight(FontWeight.Medium)
              .fontColor(this.theme.textColor)
              .backgroundColor(this.theme.surfaceColor)  // 背景色与卡片一致
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
              .alignSelf(ItemAlign.Start)
            
            // 卡片内容区域
            Column() {
              Row() {
                FormInputField({
                  config: {
                    label: '增益',
                    value: this.channelGain,
                    unit: '%',
                    minValue: 0,
                    maxValue: 200
                  },
                  onValueChange: (value: number) => {
                    this.channelGain = value
                  }
                })
                  .margin({ right: 12 })

                FormInputField({
                  config: {
                    label: '偏移',
                    value: this.channelOffset,
                    unit: 'g',
                    minValue: -500,
                    maxValue: 500
                  },
                  onValueChange: (value: number) => {
                    this.channelOffset = value
                  }
                })
              }
              .width('100%')
              .margin({ bottom: 10 })

              Row() {
                FormInputField({
                  config: {
                    label: '平滑系数',
                    value: this.channelSmoothing,
                    minValue: 0,
                    maxValue: 10
                  },
                  onValueChange: (value: number) => {
                    this.channelSmoothing = value
                  }
                })
                  .margin({ right: 12 })

                FormInputField({
                  config: {
                    label: '报警阈值',
                    value: this.channelAlarmThreshold,
                    unit: 'g',
                    minValue: 0,
                    maxValue: 5000
                  },
                  onValueChange: (value: number) => {
                    this.channelAlarmThreshold = value
                  }
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(8)
            .layoutWeight(1)
          }
          .width('50%')  // 宽度50%
          .height('60%')  // 高度60px
          .border({ width: 1, color: this.theme.borderColor })
          .borderRadius(8)
          .backgroundColor(this.theme.surfaceColor)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 20 })
        
        // 重量参数卡片
        Column() {
          // 卡片标题 - 放在边框上
          Text('重量参数')
            .fontSize(18)  // 标题字体
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.textColor)
            .backgroundColor(this.theme.surfaceColor)  // 背景色与卡片一致
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
            .alignSelf(ItemAlign.Start)
          
          // 卡片内容区域
          Column() {
            Row() {
              FormInputField({
                config: {
                  label: '毛重',
                  value: this.grossWeight,
                  unit: 'kg',
                  minValue: 0,
                  maxValue: 10000
                },
                onValueChange: (value: number) => {
                  this.grossWeight = value
                }
              })
                .margin({ right: 12 })

              FormInputField({
                config: {
                  label: '皮重',
                  value: this.tareWeight,
                  unit: 'kg',
                  minValue: 0,
                  maxValue: 1000
                },
                onValueChange: (value: number) => {
                  this.tareWeight = value
                }
              })
            }
            .width('100%')
            .margin({ bottom: 10 })

            Row() {
              FormInputField({
                config: {
                  label: '净重',
                  value: this.netWeight,
                  unit: 'kg',
                  minValue: 0,
                  maxValue: 10000
                },
                onValueChange: (value: number) => {
                  this.netWeight = value
                }
              })
                .margin({ right: 12 })

              FormInputField({
                config: {
                  label: '平均重量',
                  value: this.averageWeight,
                  unit: 'g',
                  minValue: 0,
                  maxValue: 5000
                },
                onValueChange: (value: number) => {
                  this.averageWeight = value
                }
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(8)
          .layoutWeight(1)
        }
        .width('100%')  // 宽度100%
        .height('30%')  // 高度30%
        .border({ width: 1, color: this.theme.borderColor })
        .borderRadius(8)
        .backgroundColor(this.theme.surfaceColor)
        .alignSelf(ItemAlign.Start)  // 左对齐，对齐全局参数
        .margin({ bottom: 20 })
      }
      .width('55%')
      .height('100%')
      .padding(24)
      .backgroundColor(this.theme.surfaceColor)
      .borderRadius(12)
      .border({ width: 1, color: this.theme.borderColor })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
      
      // 右边大卡片容器
      Column() {
        // 内部大卡片 - 包含表格
        Column() {
          // 表格标题
          Text('重量数据表格')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.theme.textColor)
            .margin({ bottom: 16 })
          
          // 简化表格
          Column() {
            // 表头
            Row() {
              Text('车号').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('果重G').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('车重G').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('AD0').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('AD1').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
            }
            .width('100%').backgroundColor(this.theme.backgroundColor)
            
            // 数据行
            Row() {
              Text('001').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('150.5').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('2000.0').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('1024').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
              Text('512').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.theme.borderColor }).padding(8)
            }
            .width('100%').backgroundColor(this.theme.surfaceColor)
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .padding(16)
        .backgroundColor(this.theme.backgroundColor)
        .borderRadius(8)
        .border({ width: 1, color: this.theme.borderColor })
      }
      .width('45%')
      .height('100%')
      .padding(24)
      .backgroundColor(this.theme.surfaceColor)
      .borderRadius(12)
      .border({ width: 1, color: this.theme.borderColor })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
      .margin({ left: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
