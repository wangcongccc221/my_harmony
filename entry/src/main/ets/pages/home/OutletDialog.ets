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

  @Builder
  defaultContent() {}

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Column() {
      // 标题（Apple Style: 更柔和的标题展示）
      Stack({ alignContent: Alignment.TopStart }) {
        // 边框容器 (Apple Style: 更圆润的边框，更淡的颜色，磨砂玻璃感)
        Column() {
          this.content()
        }
        .width('100%')
        .margin({ top: 12 })
        .padding({ top: 20, bottom: 16, left: 16, right: 16 })
        .backgroundColor('#FFFFFF') // 强制白色背景，避免使用主题色可能导致的黄色问题
        .borderRadius(16) // 更大的圆角
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 4 }) // 柔和阴影
        // 移除显式边框，用阴影和背景色区分，或者使用极细的边框
        .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' }) 
        
        // 标题 (Apple Style: 放在左上角，更精致的字体)
        Text(this.title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8E8E93') // 使用标准的灰色
          .backgroundColor('#FFFFFF') // 强制白色背景
          .padding({ left: 8, right: 8 })
          .margin({ left: 16, top: 2 }) // 微调位置覆盖边框
          .height(20)
          .borderRadius(4)
      }
      .width('100%')
    }
    .margin({ bottom: 16 }) // 增加组间距
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
      // Apple Style: 复选框样式（使用Toggle替代Checkbox，或者美化Checkbox）
      // 这里暂时保留Checkbox但增加间距
      Checkbox({ name: label, group: 'group' })
        .select(isChecked)
        .onChange((val: boolean) => onCheckChange(val))
        .width(20) // 稍大一点
        .height(20)
        .margin({ right: 8 })
        .selectedColor(this.getCurrentTheme().primary) // 使用主题色
      
      Text(label)
        .fontSize(15) // 字体稍大
        .fontWeight(FontWeight.Regular)
        .fontColor(this.getCurrentTheme().textColor)
        .width(70)
        .margin({ right: 12 })
      
      if (value !== undefined) {
        // Apple Style: 输入框样式
        TextInput({ text: String(value) })
          .height(36) // 更高的高度
          .fontSize(14) // 更大的字体
          .padding({ left: 12, right: 12 })
          .backgroundColor('#F2F2F7') // Apple 风格浅灰背景
          .borderRadius(10) // 圆角
          .border({ width: 0 }) // 无边框
          .layoutWeight(1) // 改为自适应宽度，避免溢出
          .constraintSize({ minWidth: 100, maxWidth: 240 }) // 限制最大最小宽度
          .onChange((val) => {
             if (onValueChange) onValueChange(val)
          })
        
        if (unit) {
          Text(unit)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().subTextColor) // 辅助文字颜色
            .margin({ left: 8 })
        }
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 12 }) // 增加间距
  }

  @Builder
  SimpleInput(label: string, value: number | string, onValueChange: (val: string) => void, unit?: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ right: 12 })
        .width(70)
      
      TextInput({ text: String(value) })
        .height(36)
        .fontSize(14)
        .padding({ left: 12, right: 12 })
        .backgroundColor('#F2F2F7')
        .borderRadius(10)
        .border({ width: 0 })
        .layoutWeight(1) // 自适应宽度
        .constraintSize({ minWidth: 100, maxWidth: 240 })
        .onChange((val) => onValueChange(val))
      
      if (unit) {
        Text(unit)
          .fontSize(14)
          .fontColor(this.getCurrentTheme().subTextColor)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 12 })
  }

  @Builder
  LabeledSelectShort(label: string, value: string, options: SelectOption[], onSelect: (index: number, value: string) => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .width(70)
        .margin({ right: 12 })
      
      // Apple Style: Select 样式比较难完全自定义，尽量匹配
      Select(options)
        .selected(0)
        .value(value)
        .font({ size: 14 })
        .height(36)
        .layoutWeight(1) // 使用layoutWeight自动扩展宽度
        .onSelect(onSelect)
        // 注意：Select组件样式受限，尽量用外部容器美化
    }
    .margin({ bottom: 12 })
    .width('100%')
  }

  @Builder
  LabeledInputShort(label: string, value: number | string, onChange: (val: string) => void, inputWidth: number = 240) {
    Row() {
      Text(label)
        .fontSize(15)
        .width(70)
        .margin({ right: 12 })
      TextInput({ text: String(value) })
        .height(36)
        .fontSize(14)
        .layoutWeight(1) // 使用layoutWeight自动扩展宽度
        .backgroundColor('#F2F2F7')
        .borderRadius(10)
        .border({ width: 0 })
        .padding({ left: 12, right: 12 })
        .onChange(onChange)
    }
    .margin({ bottom: 12 })
    .width('100%')
  }

  @Builder
  LabeledInputWithUnitShort(label: string, value: number | string, unit: string, onChange: (val: string) => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .width(70)
        .margin({ right: 12 })
      TextInput({ text: String(value) })
        .height(36)
        .fontSize(14)
        .layoutWeight(1) // 使用layoutWeight自动扩展宽度
        .backgroundColor('#F2F2F7')
        .borderRadius(10)
        .border({ width: 0 })
        .padding({ left: 12, right: 12 })
        .onChange(onChange)
      Text(unit)
        .fontSize(14)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ left: 8 })
    }
    .margin({ bottom: 12 })
    .width('100%')
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 遮罩 (Apple Style: 毛玻璃遮罩)
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.2)') // 减淡遮罩颜色
          .backdropBlur(10) // 全局背景模糊
          .onClick(() => {
            if (this.onCancel) this.onCancel()
          })

        // 对话框主体 (Apple Style: 浮动面板)
        Column() {
          // 标题栏
          Row() {
            Text(`出口-${this.currentOutletIndex} 设置`)
              .fontSize(18) // 更大的标题
              .fontColor(this.getCurrentTheme().textColor) // 使用普通文字颜色，而不是反白
              .fontWeight(FontWeight.Bold)
            
            Blank()
            
            // 关闭按钮 (Apple Style: 圆形灰色按钮)
            Button() {
              Text('×')
                .fontSize(20)
                .fontColor(this.getCurrentTheme().subTextColor)
                .fontWeight(FontWeight.Regular)
            }
            .width(30)
            .height(30)
            .backgroundColor('#E5E5EA') // 浅灰背景
            .borderRadius(15)
            .onClick(() => {
              if (this.onCancel) this.onCancel()
            })
          }
          .width('100%')
          .height(50) // 更高的标题栏
          .backgroundColor('transparent') // 透明背景，通过父容器背景透出
          .padding({ left: 20, right: 20 })
          .alignItems(VerticalAlign.Center)
          .border({ width: { bottom: 0.5 }, color: 'rgba(0,0,0,0.1)' }) // 细分割线

          // 内容区域
          Row() {
            // 左侧列 (55%)
            Column() {
              // 左侧父容器卡片
              Scroll() {
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
                                .fontSize(15)
                                .margin({ right: 12 })
                              Select([
                                { value: '默认' }, 
                                { value: '包装台' }, 
                                { value: '自动装箱' }
                              ])
                                .selected(0)
                                .value(this.exportMode)
                                .font({ size: 14 })
                                .height(36)
                                .layoutWeight(1)
                                .onSelect((index: number, value: string) => {
                                  this.exportMode = value
                                })
                            }
                            .margin({ bottom: 12 })

                            if (this.exportMode === '包装台') {
                              // 包装台模式内容
                              Row() {
                                Text('流量模式')
                                  .fontSize(15)
                                  .margin({ right: 12 })
                                Select([
                                  { value: '' }, 
                                  { value: '模式1' }, 
                                  { value: '模式2' }
                                ])
                                  .selected(0)
                                  .value(this.flowMode)
                                  .font({ size: 14 })
                                  .height(36)
                                  .layoutWeight(1)
                                  .onSelect((index: number, value: string) => {
                                    this.flowMode = value
                                  })
                              }
                              .margin({ bottom: 12 })

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
                                    .width(20)
                                    .height(20)
                                    .margin({ right: 8 })
                                  
                                  Text('个数')
                                    .fontSize(15)
                                    .fontColor(this.getCurrentTheme().textColor)
                                    .margin({ right: 12 })
                                  
                                  TextInput({ text: String(this.countValue) })
                                    .height(36)
                                    .fontSize(14)
                                    .padding({ left: 12, right: 12 })
                                    .backgroundColor('#F2F2F7')
                                    .borderRadius(10)
                                    .border({ width: 0 })
                                    .width(240)
                                    .onChange((val) => this.countValue = Number(val))
                                }
                                .layoutWeight(1)
                                .margin({ right: 10 })

                                // 禁用次数
                                Column() {
                                  Text('禁用次数')
                                    .fontSize(13)
                                    .fontColor(this.getCurrentTheme().subTextColor)
                                    .margin({ bottom: 4 })
                                  
                                  TextInput({ text: String(this.disableCount) })
                                    .height(36)
                                    .fontSize(14)
                                    .padding({ left: 12, right: 12 })
                                    .backgroundColor('#F2F2F7')
                                    .borderRadius(10)
                                    .border({ width: 0 })
                                    .width('100%')
                                    .onChange((val) => this.disableCount = Number(val))
                                }
                                .width(80)
                              }
                              .width('100%')
                              .alignItems(VerticalAlign.Center)
                              .margin({ bottom: 12 })

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
                      .layoutWeight(7) // 装箱量70%
                      .margin({ right: 16 })

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
                      .layoutWeight(3) // 贴标30%
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)

                    // 电机
                    GroupContainer({ title: '电机' }) {
                      Column() {
                        Row() {
                          Text('使能模式')
                            .fontSize(15)
                            .margin({ right: 12 })
                          Select([{ value: '装箱量' }, { value: '时间' }])
                            .selected(0)
                            .value(this.motorEnableMode)
                            .font({ size: 14 })
                            .height(36)
                            .layoutWeight(1)
                            .onSelect((index, value) => this.motorEnableMode = value)
                        }
                        .margin({ bottom: 12 })

                        Row() {
                          Text('延时时间')
                            .fontSize(15)
                            .width(70)
                            .margin({ right: 12 })
                          TextInput({ text: String(this.delayTime) })
                            .height(36)
                            .fontSize(14)
                            .layoutWeight(1)
                            .backgroundColor('#F2F2F7')
                            .borderRadius(10)
                            .border({ width: 0 })
                            .onChange((v) => this.delayTime = Number(v))
                          Text('s')
                            .fontSize(14)
                            .fontColor(this.getCurrentTheme().subTextColor)
                            .margin({ left: 8, right: 16 })
                          
                          Text('持续时间')
                            .fontSize(15)
                            .width(70)
                            .margin({ right: 12 })
                          TextInput({ text: String(this.durationTime) })
                            .height(36)
                            .fontSize(14)
                            .layoutWeight(1)
                            .backgroundColor('#F2F2F7')
                            .borderRadius(10)
                            .border({ width: 0 })
                            .onChange((v) => this.durationTime = Number(v))
                          Text('s')
                            .fontSize(14)
                            .fontColor(this.getCurrentTheme().subTextColor)
                            .margin({ left: 8 })
                        }
                        .width('100%')
                      }
                    }

                    // 出口控制
                    GroupContainer({ title: '出口控制' }) {
                      Column() {
                        Row() {
                          Text('出口使能')
                            .fontSize(15)
                            .margin({ right: 12 })
                          Select([{ value: '' }, { value: '开启' }, { value: '关闭' }])
                            .selected(0)
                            .value(this.outletEnable)
                            .font({ size: 14 })
                            .height(36)
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
                          this.LabeledInputShort('尺寸', this.dimensions, (v) => this.dimensions = v, 300)
                        }
                        .layoutWeight(2) // 增加左侧权重，让输入框有更多空间
                        .margin({ right: 16 })

                        Column() {
                          Row()
                            .width('100%')
                            .height('100%')
                            .backgroundColor(this.getCurrentTheme().backgroundColor)
                            .borderRadius(10)
                            .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' })
                        }
                        .width('35%') // 从25%增加到35%，让占位符更大
                        .height(140) // 增加高度从110到140
                      }
                    }

                    // 名称
                    GroupContainer({ title: '名称' }) {
                      Column() {
                        // 自定义
                        Row() {
                          // 占位符，对齐复选框 (20 + 8 = 28)
                          Row().width(28)
                          
                          Text('自定义')
                            .fontSize(15)
                            .width(70)
                            .margin({ right: 12 })
                          
                          TextInput({ text: this.customName })
                            .height(36)
                            .fontSize(14)
                            .layoutWeight(1) // 充满剩余空间
                            .backgroundColor('#F2F2F7')
                            .borderRadius(10)
                            .border({ width: 0 })
                            .onChange((v) => this.customName = v)
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Center)
                        .margin({ bottom: 12 })

                        // 产品名称
                        Row() {
                          // 占位符，对齐复选框
                          Row().width(28)

                          Text('产品名称')
                            .fontSize(15)
                            .width(70)
                            .margin({ right: 12 })
                          
                          TextInput({ text: this.productName })
                            .height(36)
                            .fontSize(14)
                            .layoutWeight(1) // 充满剩余空间
                            .backgroundColor('#F2F2F7')
                            .borderRadius(10)
                            .border({ width: 0 })
                            .onChange((v) => this.productName = v)
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Center)
                        .margin({ bottom: 12 })

                        // 显示名称
                        Row() {
                          Checkbox({ name: 'display', group: 'display' })
                            .select(this.displayNameChecked)
                            .onChange((v) => this.displayNameChecked = v)
                            .width(20)
                            .height(20)
                            .margin({ right: 8 })
                          
                          Text('显示名称')
                            .fontSize(15)
                            .width(70)
                            .margin({ right: 12 })
                          
                          TextInput({ text: this.displayName })
                            .height(36)
                            .fontSize(14)
                            .layoutWeight(1) // 充满剩余空间
                            .backgroundColor('#F2F2F7')
                            .borderRadius(10)
                            .border({ width: 0 })
                            .onChange((v) => this.displayName = v)
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Center)
                      }
                    }
                  }
                }
              }
              .scrollable(ScrollDirection.Vertical)
              .scrollBar(BarState.Auto)
            }
            .width('53%') // 左侧列宽度53%
            .layoutWeight(1) // 使用 layoutWeight 自动填充可用高度
            .padding({ right: 8 })

          // 右侧表格 (45%)
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
                containerBg: this.getCurrentTheme().surfaceColor, // 背景色
                fontSize: 14,
                cellPadding: 4
              })
            }
            .width('100%')
            .layoutWeight(1) // 使用 layoutWeight 自动填充可用高度
            .backgroundColor('#FFFFFF') // 强制白色背景，消除黄色
            .borderRadius(16) // 更大的圆角
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.05)', offsetY: 4 }) // 柔和阴影
            // 移除显式边框
            .border({ width: 0.5, color: 'rgba(0,0,0,0.1)' })
            .padding(16) // 增加内边距
          }
          .width('52%')
          .layoutWeight(1) // 使用 layoutWeight 自动填充可用高度
          .padding({ left: 8 })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)


          }
          .layoutWeight(1) // 内容区域自动填充高度
          .width('100%')
          .padding(20) // 增加整体内边距
          .backgroundColor('#F2F2F7') // Apple 风格背景色（浅灰）

          // 底部按钮栏
          Row() {
            // 左侧：取消、确定
            Row() {
              Button('取消')
                .backgroundColor('#E5E5EA') // 浅灰背景
                .fontColor(this.getCurrentTheme().textColor)
                .fontSize(15)
                .height(36) // 更高
                .margin({ right: 12 })
                .borderRadius(18) // 圆角
                .onClick(() => {
                  if (this.onCancel) this.onCancel()
                })
              
              Button('确定')
                .backgroundColor(this.getCurrentTheme().primary)
                .fontColor(Color.White)
                .fontSize(15)
                .height(36)
                .borderRadius(18)
                .onClick(() => {
                  if (this.onConfirm) this.onConfirm()
                })
            }

            // 中间：上一个、下一个
            Row() {
              Button('上一个出口')
                .backgroundColor('#E5E5EA') // 浅灰背景 (原 Primary)
                .fontColor(this.getCurrentTheme().textColor) // 深色文字
                .fontSize(15)
                .height(36)
                .margin({ right: 20 })
                .borderRadius(18)
                .onClick(() => {
                  if (this.onPrevious) this.onPrevious()
                })

              Button('下一个出口')
                .backgroundColor('#E5E5EA') // 浅灰背景 (原 Primary)
                .fontColor(this.getCurrentTheme().textColor) // 深色文字
                .fontSize(15)
                .height(36)
                .borderRadius(18)
                .onClick(() => {
                  if (this.onNext) this.onNext()
                })
            }

            // 右侧：常规、缺箱
            Row() {
              // 常规 Toggle
              Row() {
                Text('常规').fontSize(15).fontColor(this.isGeneral ? this.getCurrentTheme().primary : this.getCurrentTheme().textColor)
                Toggle({ type: ToggleType.Switch, isOn: this.isGeneral })
                  .onChange((isOn) => this.isGeneral = isOn)
                  .selectedColor(this.getCurrentTheme().primary)
                  .switchPointColor(Color.White)
                  .height(24)
                  .margin({ left: 8 })
              }
              .margin({ right: 20 })

              Button('缺箱')
                .backgroundColor(this.isMissingBox ? '#FF9500' : '#E5E5EA') // Apple Orange
                .fontColor(this.isMissingBox ? Color.White : this.getCurrentTheme().textColor)
                .fontSize(15)
                .height(36)
                .borderRadius(18)
                .onClick(() => this.isMissingBox = !this.isMissingBox)
            }
          }
          .width('100%')
          .height(60) // 更高
          .backgroundColor('transparent') // 透明背景
          .padding({ left: 20, right: 20 })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)
          .border({ width: { top: 0.5 }, color: 'rgba(0,0,0,0.1)' })

        }
        .width('90%')
        .height('90%')
        .backgroundColor(this.getCurrentTheme().surfaceColor) // 面板背景
        .borderRadius(20) // Apple风格：大圆角
        .shadow({ radius: 30, color: 'rgba(0, 0, 0, 0.15)', offsetX: 0, offsetY: 8 }) // Apple风格：柔和阴影
        .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseOut })) // Apple风格：流畅动画
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(9999) // 确保最上层
    }
  }
}
