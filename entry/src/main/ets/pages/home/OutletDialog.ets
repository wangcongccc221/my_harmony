/**
 * 出口设置对话框组件
 * 
 * 功能说明：
 * - 提供出口设置的对话框界面
 * - 包含装箱量、贴标、电机、出口控制、出口规格、名称等设置
 * - 支持等级表配置
 * 
 * 交互功能：
 * - 出口切换：点击上一个/下一个按钮
 * - 确认操作：点击确认按钮保存设置
 * - 取消操作：点击取消按钮关闭对话框
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { LevelTable, TableRow } from '../../components/layout/LevelTable'

// 定义数据接口


// 选择项类型与常量
interface SelectOption {
  value: string;
}

const SPEC_OPTIONS: SelectOption[] = [
  { value: '' },
  { value: '规格A' },
  { value: '规格B' },
]

@Component
struct GroupContainer {
  @Prop title: string = ''
  @BuilderParam content: () => void = this.defaultContent

  @Builder defaultContent() {}

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Column() {
      // 标题（嵌入在边框线上，通过定位实现，或者简单的内部标题）
      Stack({ alignContent: Alignment.TopStart }) {
        // 边框容器
        Column() {
          this.content()
        }
        .width('100%')
        .margin({ top: 10 })
        .padding({ top: 15, bottom: 10, left: 10, right: 10 })
        .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 4 })
        
        // 标题背景遮盖
        Text(this.title)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .padding({ left: 4, right: 4 })
          .margin({ left: 10, top: 0 })
          .height(20)
      }
      .width('100%')
    }
    .margin({ bottom: 10 })
  }
}

@Component
export struct OutletDialog {
  // ==================== Props ====================
  @Prop isVisible: boolean = false
  @Prop currentOutletIndex: number = 1
  @Prop levelTableData: TableRow[] = []
  
  // 回调函数
  onPrevious?: () => void
  onNext?: () => void
  onConfirm?: () => void
  onCancel?: () => void

  // ==================== State ====================
  // 装箱量
  @State exportMode: string = '默认'
  @State countChecked: boolean = true
  @State countValue: number = 50
  @State weightChecked: boolean = false
  @State weightValue: number = 0
  @State volumeChecked: boolean = false
  @State volumeValue: number = 0
  @State flowMode: string = ''
  @State packTime: number = 1
  @State disableCount: number = 1

  // 贴标
  @State label1Checked: boolean = false
  @State label2Checked: boolean = false
  @State label3Checked: boolean = false
  @State label4Checked: boolean = false
  
  // 电机
  @State motorEnableMode: string = '装箱量'
  @State delayTime: number = 0.0
  @State durationTime: number = 0.0
  
  // 出口控制
  @State outletEnable: string = ''
  
  // 出口规格
  @State spec: string = ''
  @State netWeight: number = 1
  @State dimensions: string = ''
  
  // 名称
  @State customName: string = ''
  @State productName: string = ''
  @State displayNameChecked: boolean = false
  @State displayName: string = ''

  // 底部状态
  @State isGeneral: boolean = true // 常规
  @State isMissingBox: boolean = false // 缺箱

  // 表格数据（模拟）


  // ==================== Helpers ====================
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  @Builder
  CheckboxInput(label: string, isChecked: boolean, onCheckChange: (val: boolean) => void, 
                value?: number | string, onValueChange?: (val: string) => void, unit?: string) {
    Row() {
      Checkbox({ name: label, group: 'group' })
        .select(isChecked)
        .onChange((val: boolean) => onCheckChange(val))
        .width(16)
        .height(16)
        .margin({ right: 4 })
      
      Text(label)
        .fontSize(14)
        .fontColor(this.getCurrentTheme().textColor)
        .width(70) // 统一标签宽度
        .margin({ right: 8 })
      
      if (value !== undefined) {
        TextInput({ text: String(value) })
          .height(24)
          .fontSize(11) // 调整字体大小，避免显示不全
          .padding({ top: 0, bottom: 0, left: 4, right: 4 }) // 移除垂直内边距，解决显示不全问题
          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
          .width(240) // 固定宽度
          .onChange((val) => {
             if (onValueChange) onValueChange(val)
          })
        
        if (unit) {
          Text(unit)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ left: 4 })
        }
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 8 })
  }

  @Builder
  SimpleInput(label: string, value: number | string, onValueChange: (val: string) => void, unit?: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ right: 8 })
        .width(70) // 统一标签宽度
      
      TextInput({ text: String(value) })
        .height(24)
        .fontSize(11)
        .padding({ top: 0, bottom: 0, left: 4, right: 4 }) // 移除垂直内边距
        .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
        .width(240) // 固定宽度
        .onChange((val) => onValueChange(val))
      
      if (unit) {
        Text(unit)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().textColor)
          .margin({ left: 4 })
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 8 })
  }

  @Builder
  LabeledSelectShort(label: string, value: string, options: SelectOption[], onSelect: (index: number, value: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .width(70) // 统一标签宽度
        .margin({ right: 8 })
      Select(options)
        .selected(0)
        .value(value)
        .font({ size: 14 })
        .height(28)
        .width(240)
        .onSelect(onSelect)
    }
    .margin({ bottom: 8 })
    .width('100%')
  }

  @Builder
  LabeledInputShort(label: string, value: number | string, onChange: (val: string) => void, inputWidth: number = 240) {
    Row() {
      Text(label)
        .fontSize(14)
        .width(70) // 统一标签宽度
        .margin({ right: 8 })
      TextInput({ text: String(value) })
        .height(32)
        .fontSize(12)
        .width(inputWidth)
        .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
        .onChange(onChange)
    }
    .margin({ bottom: 8 })
    .width('100%')
  }

  @Builder
  LabeledInputWithUnitShort(label: string, value: number | string, unit: string, onChange: (val: string) => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .width(70) // 统一标签宽度
        .margin({ right: 8 })
      TextInput({ text: String(value) })
        .height(32)
        .fontSize(12)
        .width(240) // 固定宽度
        .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
        .onChange(onChange)
      Text(unit)
        .fontSize(14)
        .margin({ left: 4 })
    }
    .margin({ bottom: 8 })
    .width('100%')
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            if (this.onCancel) this.onCancel()
          })

        // 对话框主体
        Column() {
          // 标题栏
          Row() {
            Text(`出口-${this.currentOutletIndex} 设置`)
              .fontSize(16)
              .fontColor(this.getCurrentTheme().textColor)
              .fontWeight(FontWeight.Medium)
            
            Blank()
            
            // 关闭按钮
            Text('×')
              .fontSize(20)
              .fontColor(this.getCurrentTheme().textColor)
              .onClick(() => {
                if (this.onCancel) this.onCancel()
              })
          }
          .width('100%')
          .height(32)
          .backgroundColor(this.getCurrentTheme().primary)
          .padding({ left: 10, right: 10 })
          .alignItems(VerticalAlign.Center)

          // 内容区域
          Row() {
            // 左侧列 (40%)
            Column() {
              // 左侧父容器卡片
              Column() {
                Column() {
                  // 第一行：装箱量 + 贴标
                  Row() {
                    // 装箱量
                    Column() {
                      GroupContainer({ title: '装箱量' }) {
                        Column() {
                          Row() {
                            Text('出口模式')
                              .fontSize(14)
                              .margin({ right: 8 })
                            Select([
                              { value: '默认' }, 
                              { value: '包装台' }, 
                              { value: '自动装箱' }
                            ])
                              .selected(0)
                              .value(this.exportMode)
                              .font({ size: 14 })
                              .height(28)
                              .layoutWeight(1)
                              .onSelect((index: number, value: string) => {
                                this.exportMode = value
                              })
                          }
                          .margin({ bottom: 8 })

                          if (this.exportMode === '包装台') {
                            // 包装台模式内容
                            Row() {
                              Text('流量模式')
                                .fontSize(14)
                                .margin({ right: 8 })
                              Select([
                                { value: '' }, 
                                { value: '模式1' }, 
                                { value: '模式2' }
                              ])
                                .selected(0)
                                .value(this.flowMode)
                                .font({ size: 14 })
                                .height(28)
                                .layoutWeight(1)
                                .onSelect((index: number, value: string) => {
                                  this.flowMode = value
                                })
                            }
                            .margin({ bottom: 8 })

                            this.SimpleInput('个数', this.countValue, (v) => this.countValue = Number(v))
                            this.SimpleInput('时间', this.packTime, (v) => this.packTime = Number(v), 's')

                          } else if (this.exportMode === '自动装箱') {
                            // 自动装箱模式内容（带禁用次数）
                            Row() {
                              // 个数 (复用 CheckboxInput 但宽度调整)
                              Row() {
                                Checkbox({ name: '个数', group: 'group' })
                                  .select(this.countChecked)
                                  .onChange((val: boolean) => this.countChecked = val)
                                  .width(16)
                                  .height(16)
                                  .margin({ right: 4 })
                                
                                Text('个数')
                                  .fontSize(14)
                                  .fontColor(this.getCurrentTheme().textColor)
                                  .margin({ right: 8 })
                                
                                TextInput({ text: String(this.countValue) })
                                  .height(24)
                                  .fontSize(11)
                                  .padding({ top: 0, bottom: 0, left: 4, right: 4 }) // 移除垂直内边距
                                  .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                                  .width(240) // 固定宽度
                                  .onChange((val) => this.countValue = Number(val))
                              }
                              .layoutWeight(1)
                              .margin({ right: 10 })

                              // 禁用次数
                              Column() {
                                Text('禁用次数')
                                  .fontSize(12)
                                  .fontColor(this.getCurrentTheme().textColor)
                                  .margin({ bottom: 2 })
                                
                                TextInput({ text: String(this.disableCount) })
                                  .height(24)
                                  .fontSize(11)
                                  .padding({ top: 0, bottom: 0, left: 4, right: 4 }) // 移除垂直内边距
                                  .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                                  .width('100%')
                                  .onChange((val) => this.disableCount = Number(val))
                              }
                              .width(70)
                            }
                            .width('100%')
                            .alignItems(VerticalAlign.Center)
                            .margin({ bottom: 8 })

                            this.CheckboxInput('重量', this.weightChecked, (v) => this.weightChecked = v, this.weightValue, (v) => this.weightValue = Number(v), '克')
                            this.CheckboxInput('体积', this.volumeChecked, (v) => this.volumeChecked = v, this.volumeValue, (v) => this.volumeValue = Number(v), '立方厘米')
                          } else {
                            // 默认模式内容（无禁用次数）
                            this.CheckboxInput('个数', this.countChecked, (v) => this.countChecked = v, this.countValue, (v) => this.countValue = Number(v))
                            this.CheckboxInput('重量', this.weightChecked, (v) => this.weightChecked = v, this.weightValue, (v) => this.weightValue = Number(v), '克')
                            this.CheckboxInput('体积', this.volumeChecked, (v) => this.volumeChecked = v, this.volumeValue, (v) => this.volumeValue = Number(v), '立方厘米')
                          }
                        }
                      }
                    }
                    .layoutWeight(8) // 调整为80%
                    .margin({ right: 8 })

                    // 贴标
                    Column() {
                      GroupContainer({ title: '贴标' }) {
                        Column() {
                          this.CheckboxInput('贴标1', this.label1Checked, (v) => this.label1Checked = v)
                          this.CheckboxInput('贴标2', this.label2Checked, (v) => this.label2Checked = v)
                          this.CheckboxInput('贴标3', this.label3Checked, (v) => this.label3Checked = v)
                          this.CheckboxInput('贴标4', this.label4Checked, (v) => this.label4Checked = v)
                        }
                      }
                    }
                    .layoutWeight(2) // 调整为20%
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Top)

                  // 电机
                  GroupContainer({ title: '电机' }) {
                    Column() {
                      Row() {
                        Text('使能模式')
                          .fontSize(14)
                          .margin({ right: 8 })
                        Select([{ value: '装箱量' }, { value: '时间' }])
                          .selected(0)
                          .value(this.motorEnableMode)
                          .font({ size: 14 })
                          .height(28)
                          .layoutWeight(1)
                          .onSelect((index, value) => this.motorEnableMode = value)
                      }
                      .margin({ bottom: 8 })

                      Row() {
                        Text('延时时间')
                          .fontSize(13)
                          .width(70)
                          .margin({ right: 6 })
                        TextInput({ text: String(this.delayTime) })
                          .height(32)
                          .fontSize(12)
                          .layoutWeight(1)
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                          .onChange((v) => this.delayTime = Number(v))
                        Text('s')
                          .fontSize(12)
                          .margin({ left: 4, right: 12 })
                        
                        Text('持续时间')
                          .fontSize(13)
                          .width(70)
                          .margin({ right: 6 })
                        TextInput({ text: String(this.durationTime) })
                          .height(32)
                          .fontSize(12)
                          .layoutWeight(1)
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                          .onChange((v) => this.durationTime = Number(v))
                        Text('s')
                          .fontSize(12)
                          .margin({ left: 4 })
                      }
                      .width('100%')
                    }
                  }

                  // 出口控制
                  GroupContainer({ title: '出口控制' }) {
                    Column() {
                      Row() {
                        Text('出口使能')
                          .fontSize(14)
                          .margin({ right: 8 })
                        Select([{ value: '' }, { value: '开启' }, { value: '关闭' }])
                          .selected(0)
                          .value(this.outletEnable)
                          .font({ size: 14 })
                          .height(28)
                          .layoutWeight(1)
                          .onSelect((index, value) => this.outletEnable = value)
                      }
                    }
                  }

                  // 出口规格
                  GroupContainer({ title: '出口规格' }) {
                    Row() {
                      Column() {
                        this.LabeledSelectShort('规格', this.spec, SPEC_OPTIONS, (index, value) => this.spec = value)
                        this.LabeledInputWithUnitShort('净重', this.netWeight, 'g', (v) => this.netWeight = Number(v))
                        this.LabeledInputShort('尺寸', this.dimensions, (v) => this.dimensions = v, 240)
                      }
                      .layoutWeight(1)
                      .margin({ right: 10 })

                      Column() {
                        Row()
                          .width('100%')
                          .height('100%')
                          .backgroundColor(this.getCurrentTheme().backgroundColor)
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 4 })
                      }
                      .width('25%')
                      .height(110)
                    }
                  }

                  // 名称
                  GroupContainer({ title: '名称' }) {
                    Column() {
                      // 自定义
                      Row() {
                        // 占位符，对齐复选框 (16 + 4 = 20)
                        Row().width(20)
                        
                        Text('自定义')
                          .fontSize(14)
                          .width(70)
                          .margin({ right: 8 })
                        
                        TextInput({ text: this.customName })
                          .height(32)
                          .fontSize(12)
                          .layoutWeight(1) // 充满剩余空间
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                          .onChange((v) => this.customName = v)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                      .margin({ bottom: 8 })

                      // 产品名称
                      Row() {
                        // 占位符，对齐复选框
                        Row().width(20)

                        Text('产品名称')
                          .fontSize(14)
                          .width(70)
                          .margin({ right: 8 })
                        
                        TextInput({ text: this.productName })
                          .height(32)
                          .fontSize(12)
                          .layoutWeight(1) // 充满剩余空间
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                          .onChange((v) => this.productName = v)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                      .margin({ bottom: 8 })

                      // 显示名称
                      Row() {
                        Checkbox({ name: 'display', group: 'display' })
                          .select(this.displayNameChecked)
                          .onChange((v) => this.displayNameChecked = v)
                          .width(16)
                          .height(16)
                        
                        Text('显示名称')
                          .fontSize(14)
                          .width(70)
                          .margin({ left: 4, right: 8 })
                        
                        TextInput({ text: this.displayName })
                          .height(32)
                          .fontSize(12)
                          .layoutWeight(1) // 充满剩余空间
                          .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 2 })
                          .onChange((v) => this.displayName = v)
                      }
                      .width('100%')
                      .alignItems(VerticalAlign.Center)
                    }
                  }
                }
            }
            .width('100%')
            .height('100%')
            .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 8 }) // 左侧父类卡片边框
            .padding(10)
          }
          .width('40%') // 恢复为40%宽度
          .height('100%')
          .padding({ right: 5 })

          // 右侧表格 (60%)
          Column() {
            // 右侧父容器卡片
            Column() {
              LevelTable({
                tableName: `outlet-dialog-level-table`,
                tableTitle: '等级表',
                headerTitles: ['等级', '30', '20', '10', '0'], // 默认表头，如果需要动态的可能需要传参
                tableRows: this.levelTableData,
                tableWidth: '100%',
                maxHeight: '100%', // 恢复最大高度限制，由LevelTable内部的constraintSize控制实际高度
                enableDrag: false,
                containerBg: this.getCurrentTheme().surfaceColor,
                fontSize: 14,
                cellPadding: 4
              })
            }
            .width('100%')
            .height('100%')
            .border({ width: 1, color: this.getCurrentTheme().borderColor, radius: 8 }) // 与左侧一致的边框样式
            .padding(10)
          }
          .width('60%')
          .height('100%')
          .padding({ left: 5 })
          .justifyContent(FlexAlign.Start)


          }
          .layoutWeight(1) // 内容区域自动填充高度
          .width('100%')
          .padding(10)
          .backgroundColor(this.getCurrentTheme().surfaceColor)

          // 底部按钮栏
          Row() {
            // 左侧：取消、确定
            Row() {
              Button('取消')
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
                .fontColor(this.getCurrentTheme().textColor)
                .fontSize(14)
                .height(32)
                .margin({ right: 10 })
                .onClick(() => {
                  if (this.onCancel) this.onCancel()
                })
              
              Button('确定')
                .backgroundColor(this.getCurrentTheme().primary)
                .fontColor(this.getCurrentTheme().textColor)
                .fontSize(14)
                .height(32)
                .onClick(() => {
                  if (this.onConfirm) this.onConfirm()
                })
            }

            // 中间：上一个、下一个
            Row() {
              Button('上一个出口')
                .backgroundColor(this.getCurrentTheme().primary)
                .fontColor(this.getCurrentTheme().textColor)
                .fontSize(14)
                .height(32)
                .margin({ right: 20 })
                .onClick(() => {
                  if (this.onPrevious) this.onPrevious()
                })

              Button('下一个出口')
                .backgroundColor(this.getCurrentTheme().primary)
                .fontColor(this.getCurrentTheme().textColor)
                .fontSize(14)
                .height(32)
                .onClick(() => {
                  if (this.onNext) this.onNext()
                })
            }

            // 右侧：常规、缺箱
            Row() {
              // 常规 Toggle
              Row() {
                Text('常规').fontSize(14).fontColor(this.isGeneral ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
                Toggle({ type: ToggleType.Switch, isOn: this.isGeneral })
                  .onChange((isOn) => this.isGeneral = isOn)
                  .selectedColor(this.getCurrentTheme().primary)
                  .switchPointColor(this.getCurrentTheme().surfaceColor)
                  .height(20)
                  .margin({ left: 5 })
              }
              .margin({ right: 20 })

              Button('缺箱')
                .backgroundColor(this.isMissingBox ? '#FFA500' : (this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor))
                .fontColor(this.isMissingBox ? this.getCurrentTheme().surfaceColor : this.getCurrentTheme().textColor)
                .fontSize(14)
                .height(32)
                .onClick(() => this.isMissingBox = !this.isMissingBox)
            }
          }
          .width('100%')
          .height(50)
          .backgroundColor(this.getCurrentTheme().backgroundColor)
          .padding({ left: 10, right: 10 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)

        }
        .width('90%')
        .height('90%')
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(4)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(9999) // 确保最上层
    }
  }


}
