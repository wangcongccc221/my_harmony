/**
 * 重量设置页面组件
 * 功能：显示重量相关的设置内容
 * 用途：在工程设置对话框的"重量设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'
import { NumericInput } from '../../ui/inputs/NumericInput'

@Component
export struct WeightSettingsPage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0
  
  // 状态变量
  @State workStatus: string = ''
  @State filterCoef: number = 0.0400
  @State currentAlgo: string = '算法 1'
  @State minLevelThreshold: number = 20
  @State cupOffsetThreshold: number = 5
  @State cupBreakThreshold: number = 60
  @State validCupThreshold: number = 100
  @State baseCupCount: number = 100
  @State totalCupCount: number = 500
  @State cupAvgWeight: string = ''

  // 复选框状态
  @State internalSignal: boolean = false
  @State testCup: boolean = false

  // 系统校准参数
  @State systemSelection: string = '1'
  @State channelSelection: string = '通道 1'
  @State correctionCoef: number = 0.000000
  @State weightInput: number = 0
  @State adValueInput: string = ''
  @State calibrationValue: string = ''
  @State zeroValue: number = 0.034500

  // 底部参数
  @State currentWeight: number = 200
  @State threshold: number = 10
  @State avgWeightDisplay: string = ''

  // 回调函数
  onCancel?: () => void
  onSave?: () => void

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  // 通用样式：区域边框
  @Styles sectionStyle() {
    .padding(10)
    .borderRadius(4)
    .border({ width: 1, color: '#DCDCDC' }) // 浅灰色边框
    .backgroundColor(Color.White)
  }

  // 单元格构建器
  @Builder buildCell(text: string, width: string | number, isHeader: boolean = false) {
    Text(text)
      .width(width)
      .height(30)
      .fontSize(14)
      .fontWeight(isHeader ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .textOverflow({ overflow: TextOverflow.Ellipsis})
      .border({ width: 0.5, color: '#DCDCDC' })
      .backgroundColor(isHeader ? '#FFFACD' : Color.White) // 表头浅黄
  }

  build() {
    Column({ space: 10 }) {
      // 主要内容区域 (左右分栏)
      Row({ space: 10 }) {
        // ==================== 左侧区域 ====================
        Column({ space: 10 }) {
          // 1. 工作状态栏
          Row() {
            Text('工作状态').fontSize(14).margin({ right: 10 })
            TextInput({ text: this.workStatus }).width(100).height(30)
            
            Button('复位')
              .backgroundColor('#F0F0F0')
              .fontColor(Color.Black)
              .fontSize(14)
              .height(30)
              .margin({ left: 20 })
              .border({ width: 1, color: '#DCDCDC' })
          }
          .width('100%')
          .padding({ bottom: 10 })

          // 2. 参数设置与系统校准 (左右分栏)
          Row({ space: 10 }) {
            // 左下：参数设置
            Column({ space: 8 }) {
              Row() {
                Checkbox({ name: 'internalSignal' }).select(this.internalSignal)
                  .onChange(v => this.internalSignal = v).width(16).height(16)
                Text('内信号源').fontSize(14).margin({ left: 5, right: 15 })

                Checkbox({ name: 'testCup' }).select(this.testCup)
                  .onChange(v => this.testCup = v).width(16).height(16)
                Text('测试果杯').fontSize(14).margin({ left: 5 })
              }
              .width('100%')

              // 滤波系数
              Row() {
                Text('滤波系数').fontSize(14).width(90)
                NumericInput({ value: $filterCoef, min: 0, max: 1, step: 0.0001 }).width(100).height(30)
              }.width('100%')
              
              Row() {
                Text('当前算法').fontSize(14).width(90)
                Row() {
                  Row() {
                    Radio({ value: '算法 1', group: 'algorithm' })
                      .checked(this.currentAlgo === '算法 1')
                      .width(14)
                      .height(14)
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.currentAlgo = '算法 1'
                        }
                      })
                    Text('算法 1')
                      .fontSize(14)
                      .margin({ left: 4 })
                  }
                  .alignItems(VerticalAlign.Center)
                  .margin({ right: 16 })
                  
                  Row() {
                    Radio({ value: '算法 2', group: 'algorithm' })
                      .checked(this.currentAlgo === '算法 2')
                      .width(14)
                      .height(14)
                      .onChange((isChecked: boolean) => {
                        if (isChecked) {
                          this.currentAlgo = '算法 2'
                        }
                      })
                    Text('算法 2')
                      .fontSize(14)
                      .margin({ left: 4 })
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .alignItems(VerticalAlign.Center)
              }.width('100%')

              // 阈值设置
              Row() {
                Text('最小等级阈值').fontSize(14).width(90)
                NumericInput({ value: $minLevelThreshold, min: 0, max: 100 }).width(100).height(30)
              }.width('100%')

              Row() {
                Text('杯偏差阈值').fontSize(14).width(90)
                NumericInput({ value: $cupOffsetThreshold, min: 0, max: 100 }).width(100).height(30)
              }.width('100%')

              Row() {
                Text('杯破损阈值').fontSize(14).width(90)
                NumericInput({ value: $cupBreakThreshold, min: 0, max: 100 }).width(100).height(30)
              }.width('100%')

              Row() {
                Text('有效果杯阈值').fontSize(14).width(90)
                NumericInput({ value: $validCupThreshold, min: 0, max: 200 }).width(100).height(30)
              }.width('100%')

              Row() {
                Text('基准果杯数').fontSize(14).width(90)
                NumericInput({ value: $baseCupCount, min: 1, max: 1000 }).width(100).height(30)
              }.width('100%')

              Divider().color('#DCDCDC').strokeWidth(1).margin({ top: 5, bottom: 5 })

              Row() {
                Text('果杯总数').fontSize(14).width(90)
                NumericInput({ value: $totalCupCount, min: 1, max: 10000 }).width(100).height(30)
              }.width('100%')
              
              Row() {
                Text('果杯均重').fontSize(14).width(90)
                TextInput({ text: this.cupAvgWeight }).width(100).height(30)
              }.width('100%')
            }
            .sectionStyle()
            .layoutWeight(1)
            .height('100%')

            // 右下：系统校准
            Column({ space: 10 }) {
              this.buildRadioRow('系统', '1', '2', this.systemSelection, (v) => this.systemSelection = v)
              this.buildRadioRow('通道', '通道 1', '通道 2', this.channelSelection, (v) => this.channelSelection = v)
              
              Row() {
                Text('校正系数').fontSize(14).width(60)
                NumericInput({ value: $correctionCoef, min: 0, max: 1, step: 0.000001 }).width(100).height(30).layoutWeight(1)
              }.width('100%')

              // G-AD系数 (ADO)
              Stack({ alignContent: Alignment.TopStart }) {
                Column({ space: 8 }) {
                  Row() {
                    Text('重量').fontSize(14).margin({ right: 5 })
                    NumericInput({ value: $weightInput, min: 0, max: 10000 }).width(60).height(30)
                    Text('AD值').fontSize(14).margin({ left: 10, right: 5 })
                    TextInput({ text: this.adValueInput }).width(60).height(30)
                  }.width('100%')

                  Row() {
                    Button('标定')
                      .backgroundColor('#F0F0F0')
                      .fontColor(Color.Black)
                      .fontSize(14)
                      .height(30)
                      .width(80)
                      .border({ width: 1, color: '#DCDCDC' })
                      .margin({ right: 10 })
                    
                    TextInput({ text: this.calibrationValue }).layoutWeight(1).height(30)
                  }.width('100%')

                  Row() {
                    Button('归零')
                      .backgroundColor('#F0F0F0')
                      .fontColor(Color.Black)
                      .fontSize(14)
                      .height(30)
                      .width(80)
                      .border({ width: 1, color: '#DCDCDC' })
                      .margin({ right: 10 })
                    
                    NumericInput({ value: $zeroValue, min: 0, max: 1, step: 0.000001 }).layoutWeight(1).height(30)
                  }.width('100%')
                }
                .sectionStyle()
                .margin({ top: 8 })
                .padding({ top: 16 })

                Text(' G-AD系数 (AD0) ') // 加空格遮挡边框
                  .fontSize(12)
                  .backgroundColor(Color.White)
                  .position({ x: 10, y: 0 })
                  .zIndex(1)
              }
            }
            .sectionStyle()
            .layoutWeight(1)
            .height('100%')
          }
          .layoutWeight(1) // 占满剩余高度

          // 3. 底部区域 (当前重量、阈值等)
          Column({ space: 10 }) {
            Row() {
              Text('当前重量').fontSize(14).margin({ right: 5 })
              NumericInput({ value: $currentWeight, min: 0, max: 10000 }).width(80).height(30)

              Text('阈值').fontSize(14).margin({ left: 20, right: 5 })
              NumericInput({ value: $threshold, min: 0, max: 1000 }).width(60).height(30)

              Blank()

              Button('清零')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .fontSize(14)
                .height(30)
                .width(80)
                .border({ width: 1, color: '#DCDCDC' })
            }
            .width('100%')

            Row({ space: 10 }) {
               // 第一排方框
               ForEach([1,2,3,4,5], (i: number) => {
                 TextInput({ text: '' })
                   .width(60)
                   .height(30)
                   .backgroundColor(Color.White)
                   .border({ width: 1, color: '#DCDCDC' })
                   .borderRadius(0)
               })
            }
             Row({ space: 10 }) {
               // 第二排方框 (前4个)
               ForEach([1,2,3,4], (i: number) => {
                 TextInput({ text: '' })
                   .width(60)
                   .height(30)
                   .backgroundColor(Color.White)
                   .border({ width: 1, color: '#DCDCDC' })
                   .borderRadius(0)
               })
               
               // 第5个位置：平均重量
               Column() {
                 Text('平均重量').fontSize(12).margin({ bottom: 2 })
                 TextInput({ text: this.avgWeightDisplay })
                   .width(60)
                   .height(30)
                   .backgroundColor(Color.White)
                   .border({ width: 1, color: '#DCDCDC' })
                   .borderRadius(0)
               }
               .alignItems(HorizontalAlign.Center)
               .justifyContent(FlexAlign.End) // 底部对齐输入框
            }
          }
          .sectionStyle()
          .width('100%')
        }
        .layoutWeight(1)

        // ==================== 右侧区域 ====================
        Column() {
          // 表格区域
          Column() {
            // 表头
            Row() {
              this.buildCell('车号', '20%', true)
              this.buildCell('果重G', '20%', true)
              this.buildCell('车重G', '20%', true)
              this.buildCell('AD0', '20%', true)
              this.buildCell('AD1', '20%', true)
            }
            .width('100%')

            // 空白内容区 (模拟)
            Blank()
          }
          .sectionStyle()
          .width('100%')
          .layoutWeight(1)

          // 底部操作按钮
          Grid() {
            GridItem() {
              Button('波形捕捉')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .fontSize(14)
                .height(30)
                .width('100%')
                .border({ width: 1, color: '#DCDCDC' })
            }
            GridItem() {
              Button('数据追踪')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .fontSize(14)
                .height(30)
                .width('100%')
                .border({ width: 1, color: '#DCDCDC' })
            }
            GridItem() {
              Button('清除数据')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .fontSize(14)
                .height(30)
                .width('100%')
                .border({ width: 1, color: '#DCDCDC' })
            }
            GridItem() {
               // 占位
            }
            GridItem() {
              Button('数据导出')
                .backgroundColor('#F0F0F0')
                .fontColor(Color.Black)
                .fontSize(14)
                .height(30)
                .width('100%')
                .border({ width: 1, color: '#DCDCDC' })
            }
            GridItem() {
              Button('立即生效')
                .backgroundColor('#228B22') // ForestGreen
                .fontColor(Color.White)
                .fontSize(14)
                .height(30)
                .width('100%')
            }
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsGap(10)
          .columnsGap(10)
          .margin({ top: 10 })
          .height(80)
        }
        .layoutWeight(1)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .alignItems(HorizontalAlign.Start)
  }

  // 辅助构建器：参数行
  @Builder buildParamRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).width(90)
      TextInput({ text: value }).width(100).height(30)
    }
    .width('100%')
    .margin({ bottom: 5 })
  }

  // 辅助构建器：单选按钮行（用于2个选项）
  @Builder buildRadioRow(label: string, option1: string, option2: string, selectedValue: string, onSelect: (v: string) => void) {
    Row() {
      Text(label).fontSize(14).width(60)
      Row() {
        Row() {
          Radio({ value: option1, group: label })
            .checked(selectedValue === option1)
            .width(14)
            .height(14)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                onSelect(option1)
              }
            })
          Text(option1)
            .fontSize(14)
            .margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ right: 16 })
        
        Row() {
          Radio({ value: option2, group: label })
            .checked(selectedValue === option2)
            .width(14)
            .height(14)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                onSelect(option2)
              }
            })
          Text(option2)
            .fontSize(14)
            .margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 5 })
  }
}
