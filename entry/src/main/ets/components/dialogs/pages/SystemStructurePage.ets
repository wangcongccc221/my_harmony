/**
 * 系统结构设置页面组件
 * 功能：显示系统结构相关的设置内容
 * 用途：在工程设置对话框的"系统结构设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'
import { FSMActionButtons } from '../../ui/dialogs/FSMActionButtons'
import { NumericInput } from '../../ui/inputs/NumericInput'
import { OutletCountStorage } from '../../../utils/storage/OutletCountStorage'

@Component
export struct SystemStructurePage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0
  
  // 状态变量
  @State subsystemCount: number = 1
  @State dataPacket: number = 1500
  @State cameraWidth: number = 1280
  @State cameraHeight: number = 300
  @State pixelSelection: string = '130w'
  @StorageLink('OutletCount_FSM1') outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') outletCountFSM2: number = 20
  @State tempExitCount: number = 20
  @State sampleExit: number = 0

  aboutToAppear() {
    // 根据当前选择的子系统编号(subsystemCount)加载对应的出口数量
    if (this.subsystemCount === 1) {
      this.tempExitCount = this.outletCountFSM1
    } else {
      this.tempExitCount = this.outletCountFSM2
    }
  }

  private getExitCountOptions(): SelectOption[] {
    const options: SelectOption[] = []
    for (let i = 1; i <= 20; i++) {
      options.push({ value: i.toString() })
    }
    return options
  }

  private getWorkbenchColumns(): number[] {
    const columns: number[] = []
    for (let i = 1; i <= this.tempExitCount; i++) {
      columns.push(i)
    }
    return columns
  }

  // 硬件设置状态
  @State hw_cir: boolean = false
  @State hw_color: boolean = false
  @State hw_shape: boolean = false
  @State hw_defect: boolean = false
  @State hw_volume: boolean = false
  @State hw_area: boolean = false
  @State hw_uv: boolean = false
  @State hw_scratch: boolean = false
  @State hw_rot: boolean = false
  @State hw_weight: boolean = true
  @State hw_density: boolean = false
  @State hw_internal: boolean = false
  @State hw_sugar: boolean = false
  @State hw_acid: boolean = false
  @State hw_mold: boolean = false
  @State hw_dry: boolean = false
  @State hw_flesh: boolean = false
  @State hw_maturity: boolean = false
  @State hw_ultrasonic: boolean = false
  @State hw_hardness: boolean = false
  @State hw_water: boolean = false
  @State hw_wifi: boolean = false
  @State hw_freq: boolean = false

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

  // 标题样式
  @Builder buildSectionTitle(title: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor('#333333')
      .position({ x: 10, y: -10 }) // 模拟 Fieldset 标题效果，但这在 ArkTS 比较难完美实现，暂时放在左上角
      .backgroundColor(Color.White)
      .padding({ left: 4, right: 4 })
      .zIndex(1)
  }
  
  // 更好的标题实现方式：放在容器内部顶部
  @Builder buildGroupTitle(title: string) {
     Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor('#333333')
      .margin({ bottom: 8 })
  }

  build() {
    Column() {
      // 可滚动内容区域
      Scroll() {
        Column({ space: 10 }) {
          // ==================== 第一部分：顶部区域 ====================
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
            
            // ----- 左侧：系统类型 & 相机延时 -----
            Column({ space: 10 }) {
              // 1. 系统类型
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  // 第一行 L
                  this.buildSystemFlowRow(['L NIR2', 'L NIR1', 'L COLOR'])
                  // 第二行 M
                  this.buildSystemFlowRow(['M NIR2', 'M NIR1', 'M COLOR'])
                  // 第三行 R
                  this.buildSystemFlowRow(['R NIR2', 'R NIR1', 'R COLOR'])
                }
                .sectionStyle()
                .margin({ top: 8 })
                .padding({ top: 16, bottom: 8 })
  
                this.buildGroupTitle('系统类型')
              }
  
              // 2. 相机延时
              Stack({ alignContent: Alignment.TopStart }) {
                Column() {
                  this.buildCameraDelayTable()
                }
                .sectionStyle()
                .margin({ top: 8 })
                .padding({ top: 20 })
  
                this.buildGroupTitle('相机延时')
              }
            }
            .layoutWeight(3)
            .margin({ right: 10 })
  
            // ----- 中间：相机选择 -----
            Stack({ alignContent: Alignment.TopStart }) {
              Column({ space: 15 }) {
                Row() {
                  Text('数据包:').fontSize(14).width(60)
                  NumericInput({ value: $dataPacket, min: 0, max: 10000 }).width(100).height(30)
                }.width('100%')
  
                Row() {
                  Text('宽度:').fontSize(14).width(40)
                  NumericInput({ value: $cameraWidth, min: 0, max: 4096 }).width(80).height(30)
                  Text('高度:').fontSize(14).width(40).margin({ left: 10 })
                  NumericInput({ value: $cameraHeight, min: 0, max: 4096 }).width(80).height(30)
                }.width('100%')
  
                Row() {
                  Text('像素选择:').fontSize(14).width(70)
                  Select([{ value: '130w' }, { value: '500w' }])
                    .selected(0)
                    .value(this.pixelSelection)
                    .font({ size: 14 })
                    .height(30)
                    .onSelect((index, value) => this.pixelSelection = value)
                }.width('100%')
              }
              .sectionStyle()
              .height('100%')
              .margin({ top: 8 })
              .padding({ top: 20, left: 10, right: 10 })
  
              this.buildGroupTitle('相机选择')
            }
            .layoutWeight(2)
            .margin({ right: 10 })
  
            // ----- 右侧：硬件设置 -----
            Stack({ alignContent: Alignment.TopStart }) {
              Column({ space: 8 }) {
                // 视觉 (Row 1)
                Row() {
                  this.buildCheckbox('CIR视觉', this.hw_cir, (v) => this.hw_cir = v)
                  this.buildCheckbox('颜色', this.hw_color, (v) => this.hw_color = v)
                  this.buildCheckbox('形状', this.hw_shape, (v) => this.hw_shape = v)
                  this.buildCheckbox('瑕疵', this.hw_defect, (v) => this.hw_defect = v)
                  this.buildCheckbox('体积', this.hw_volume, (v) => this.hw_volume = v)
                  this.buildCheckbox('投影面积', this.hw_area, (v) => this.hw_area = v)
                }
                
                // Row 2
                Row() {
                  this.buildCheckbox('UV视觉', this.hw_uv, (v) => this.hw_uv = v)
                  this.buildCheckbox('擦伤', this.hw_scratch, (v) => this.hw_scratch = v)
                  this.buildCheckbox('腐烂', this.hw_rot, (v) => this.hw_rot = v)
                }
  
                // Row 3 (1 重量 密度)
                Row() {
                  Text('1').fontWeight(FontWeight.Bold).fontSize(14).margin({ right: 10 })
                  this.buildCheckbox('重量系统', this.hw_weight, (v) => this.hw_weight = v)
                  this.buildCheckbox('密度', this.hw_density, (v) => this.hw_density = v)
                }
  
                // Row 4 (Internal Quality)
                Row() {
                  this.buildCheckbox('内部品质', this.hw_internal, (v) => this.hw_internal = v)
                  this.buildCheckbox('糖度', this.hw_sugar, (v) => this.hw_sugar = v)
                  this.buildCheckbox('酸度', this.hw_acid, (v) => this.hw_acid = v)
                  this.buildCheckbox('霉芯', this.hw_mold, (v) => this.hw_mold = v)
                  this.buildCheckbox('枯水', this.hw_dry, (v) => this.hw_dry = v)
                  this.buildCheckbox('果肉色', this.hw_flesh, (v) => this.hw_flesh = v)
                  this.buildCheckbox('成熟度', this.hw_maturity, (v) => this.hw_maturity = v)
                }
  
                // Row 5
                Row() {
                  this.buildCheckbox('超声波', this.hw_ultrasonic, (v) => this.hw_ultrasonic = v)
                  this.buildCheckbox('硬度', this.hw_hardness, (v) => this.hw_hardness = v)
                  this.buildCheckbox('含水率', this.hw_water, (v) => this.hw_water = v)
                }
  
                // Row 6
                Row() {
                   this.buildCheckbox('Wifi功能', this.hw_wifi, (v) => this.hw_wifi = v)
                   this.buildCheckbox('倍频功能', this.hw_freq, (v) => this.hw_freq = v)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .sectionStyle()
              .height('100%')
              .margin({ top: 8 })
              .padding({ top: 20, left: 10, right: 10 })
  
              this.buildGroupTitle('硬件设置')
            }
            .layoutWeight(4)
          }
          .height(280) // 限制高度
  
          // ==================== 第二部分：子系统设置 ====================
          Column({ space: 20 }) {
            Row() {
              Text('子系统个数').fontSize(14).margin({ right: 10 })
              Select([{ value: '1' }, { value: '2' }])
                .selected(0)
                .value('1')
                .height(30)
                .onSelect((index, value) => {
                  const newVal = parseInt(value)
                  this.subsystemCount = newVal
                  // 切换子系统时，重新加载对应的出口数量到临时变量
                  if (newVal === 1) {
                    this.tempExitCount = this.outletCountFSM1
                  } else {
                    this.tempExitCount = this.outletCountFSM2
                  }
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
  
            // 子系统表格
            Row() {
               this.buildSubsystemTable()
            }
            .width('100%')
          }
          .sectionStyle()
          .width('100%')
  
          // ==================== 第三部分：工作台设置 ====================
          Stack({ alignContent: Alignment.TopStart }) {
            Row() {
              // 左侧表格
              Column() {
                this.buildWorkbenchTable()
              }
              .layoutWeight(1)
              .margin({ right: 20 })
  
              // 右侧设置
              Column({ space: 15 }) {
                Row() {
                  Text('出口数量').fontSize(14).margin({ right: 10 })
                  Select(this.getExitCountOptions())
                    .selected(this.tempExitCount - 1)
                    .value(this.tempExitCount.toString())
                    .height(30)
                    .onSelect((index, value) => {
                      this.tempExitCount = parseInt(value)
                    })
                }
                
                Row() {
                  Text('抽检出口').fontSize(14).margin({ right: 10 })
                  Select([{ value: '0' }, { value: '1' }])
                    .selected(0)
                    .value(this.sampleExit.toString())
                    .height(30)
                }
  
                Button('立即生效')
                  .backgroundColor('#228B22') // ForestGreen
                  .fontColor(Color.White)
                  .fontSize(14)
                  .height(35)
                  .onClick(async () => {
                    const storage = OutletCountStorage.getInstance()
                    
                    if (this.subsystemCount === 1) {
                      this.outletCountFSM1 = this.tempExitCount
                      // 保存到持久化存储
                      await storage.saveFSM1OutletCount(this.tempExitCount)
                    } else {
                      this.outletCountFSM2 = this.tempExitCount
                      // 保存到持久化存储
                      await storage.saveFSM2OutletCount(this.tempExitCount)
                    }
                    // 也可以加个提示 ToastUtils.show('已生效')
                  })
              }
              .width(150)
              .alignItems(HorizontalAlign.End)
            }
            .sectionStyle()
            .margin({ top: 8 })
            .padding({ top: 20, left: 5, right: 5 })
  
            this.buildGroupTitle('工作台设置')
          }
        }
        .padding(10)
      }
      .width('100%')
      .layoutWeight(1) // 占用剩余空间
      .align(Alignment.TopStart)

    }
    .width('100%')
    .height('100%')
  }

  // 构建流程图的一行
  @Builder buildSystemFlowRow(nodes: string[]) {
    Row() {
      ForEach(nodes, (node: string, index: number) => {
        // 节点
        Text(node)
          .fontSize(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .border({ width: 1, color: '#999' })
          .borderRadius(15)
          .backgroundColor(Color.White)
        
        // 箭头 (最后一个节点后不加)
        if (index < nodes.length - 1) {
          Text('-->')
            .fontSize(12)
            .margin({ left: 5, right: 5 })
        } else {
          Text('-->') // 截图显示最后也有箭头？看图似乎是 L NIR2 -> ... -> L COLOR -> (无) 或者 (有)
          // 仔细看截图： L NIR2 -> L NIR1 -> L COLOR -> 
          // 好像最后也有一个虚箭头或者占位。
          // 让我们按截图： L NIR2 -> 箭头 -> L NIR1 -> 箭头 -> L COLOR -> 箭头
           .fontSize(12)
           .margin({ left: 5 })
        }
      })
      // 红色圆点 (模拟状态灯)
      Row() {
         Circle({ width: 10, height: 10 }).fill(Color.Red).margin({ left: 5 })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 5 })
  }

  // 构建相机延时表格
  @Builder buildCameraDelayTable() {
    // 简单的 Grid 模拟
    Column() {
      // 表头
      Row() {
        this.buildCell('参数类型', 60, true)
        this.buildCell('参数类型', 60, true)
        this.buildCell('L COLOR', 50, true)
        this.buildCell('L COLOR', 50, true)
        this.buildCell('M NIR1', 50, true)
        this.buildCell('L NIR1', 50, true)
        this.buildCell('R NIR1', 50, true)
      }
      .backgroundColor('#F0F0F0')

      // 数据行 1
      Row() {
        this.buildCell('Packet...', 60)
        this.buildCell('1000', 60)
        this.buildCell('1000', 50)
        this.buildCell('1000', 50)
        this.buildCell('1000', 50)
        this.buildCell('1000', 50)
        this.buildCell('1000', 50)
      }

      // 数据行 2
      Row() {
        this.buildCell('TransD...', 60)
        this.buildCell('0', 60)
        this.buildCell('0', 50)
        this.buildCell('0', 50)
        this.buildCell('0', 50)
        this.buildCell('0', 50)
        this.buildCell('0', 50)
      }
    }
  }

  // 构建子系统表格
  @Builder buildSubsystemTable() {
    Column() {
      // 表头
      Row() {
        this.buildCell('子系统编号', '15%', true)
        this.buildCell('通道数', '15%', true)
        this.buildCell('图像和紫外数据匹配', '15%', true)
        this.buildCell('图像和重量数据匹配', '15%', true)
        this.buildCell('图像和含糖显数据配准', '15%', true)
        this.buildCell('图像和超声波数据匹配', '15%', true)
        this.buildCell('内部品质通道启用匹配', '10%', true)
      }
      .width('100%')
      .backgroundColor('#FFFACD') // 浅黄色背景

      // 数据行
      Row() {
        this.buildCell('1', '15%')
        this.buildCell('6', '15%')
        this.buildCell('3', '15%')
        this.buildCell('17', '15%')
        this.buildCell('36', '15%')
        this.buildCell('36', '15%')
        this.buildCell('0', '10%')
      }
      .width('100%')
    }
    .width('100%')
  }

  // 构建工作台表格
  @Builder buildWorkbenchTable() {
    Scroll() {
      Column() {
        // 表头 (1-N)
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Text(i.toString())
               .width(60)
               .height(30)
               .fontSize(14)
               .fontWeight(FontWeight.Bold)
               .textAlign(TextAlign.Center)
               .backgroundColor('#696969') // 深灰色背景
               .fontColor(Color.White)
               .border({ width: 0.5, color: '#FFF' })
          })
        }

        // 行1: 绿色方块 0
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
               Checkbox().width(14).height(14).shape(CheckBoxShape.ROUNDED_SQUARE)
               Text('0').fontSize(14).margin({left: 8})
             }
             .width(60)
             .height(30)
             .justifyContent(FlexAlign.Center)
             .backgroundColor('#90EE90') // 浅绿
             .border({ width: 0.5, color: '#999' })
          })
        }
        
        
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
               Checkbox().width(14).height(14).shape(CheckBoxShape.ROUNDED_SQUARE)
               Text('0').fontSize(14).margin({left: 8})
             }
             .width(60)
             .height(30)
             .justifyContent(FlexAlign.Center)
             .backgroundColor('#FFFFE0') // 浅黄
             .border({ width: 0.5, color: '#999' })
          })
        }

        // 空行 1
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
             }
             .width(60)
             .height(30)
             .backgroundColor(Color.White)
             .border({ width: 0.5, color: '#999' })
          })
        }
        
        // 行3: 复选框 + 编号
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
               Checkbox({ name: i.toString() }).select(true).width(16).height(16).shape(CheckBoxShape.ROUNDED_SQUARE)
               Text(i.toString()).fontSize(14).margin({left: 8})
             }
             .width(60)
             .height(35)
             .justifyContent(FlexAlign.Center)
             .backgroundColor('#FFFACD')
             .border({ width: 0.5, color: '#999' })
          })
        }

         // 行4: 绿色方块 0
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
               Checkbox().width(14).height(14).shape(CheckBoxShape.ROUNDED_SQUARE)
               Text('0').fontSize(14).margin({left: 8})
             }
             .width(60)
             .height(30)
             .justifyContent(FlexAlign.Center)
             .backgroundColor('#90EE90')
             .border({ width: 0.5, color: '#999' })
          })
        }

        // 空行 2
        Row() {
          ForEach(this.getWorkbenchColumns(), (i: number) => {
             Row() {
             }
             .width(60)
             .height(30)
             .backgroundColor(Color.White)
             .border({ width: 0.5, color: '#999' })
          })
        }
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.On)
    .width('100%')
  }

  // 单元格构建器
  @Builder buildCell(text: string, width: number | string, isHeader: boolean = false) {
    Text(text)
      .width(width)
      .height(36) // 增加高度
      .fontSize(13) // 稍微调大字体
      .fontWeight(isHeader ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(2) // 允许两行
      .border({ width: 0.5, color: '#999' })
      .backgroundColor(isHeader ? Color.Transparent : Color.White)
      .padding({ left: 2, right: 2 }) // 增加内边距
  }

  // 复选框构建器
  @Builder buildCheckbox(label: string, checked: boolean, onChange: (val: boolean) => void) {
    Row() {
      Checkbox({ name: label, group: 'hardware' })
        .select(checked)
        .onChange((value: boolean) => onChange(value))
        .width(16)
        .height(16)
      Text(label)
        .fontSize(13)
        .margin({ left: 4, right: 10 })
    }
    .margin({ bottom: 4 })
  }
}

