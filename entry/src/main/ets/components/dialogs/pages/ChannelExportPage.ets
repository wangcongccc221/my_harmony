/**
 * 通道出口设置页面组件
 * 功能：显示通道出口相关的设置内容
 * 用途：在工程设置对话框的"通道出口设置"Tab中使用
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { t, I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'
import { NumericInput } from '../../ui/inputs/NumericInput'

@Component
export struct ChannelExportPage {
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0
  
  // 状态变量
  @State subsystem: string = '子系统1'
  @State valveWidth: number = 10
  @State labelWidth: number = 12
  @State channelSelection: string = '通道 1'
  
  // 监听出口数量变化
  @StorageLink('OutletCount_FSM1') outletCountFSM1: number = 20
  @StorageLink('OutletCount_FSM2') outletCountFSM2: number = 20

  // 回调函数
  onCancel?: () => void
  onSave?: () => void

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  // 通用样式：区域边框
  @Styles sectionStyle() {
    .padding(10)
    .borderRadius(8)
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
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .border({ width: 0.5, color: '#DCDCDC' })
      .backgroundColor(isHeader ? '#F5F5F5' : '#E6E6FA') // 表头灰色，内容浅蓝
  }

  /**
   * 获取当前选择子系统对应的出口数量
   */
  private getCurrentOutletCount(): number {
    if (this.subsystem === '子系统1') {
      return this.outletCountFSM1
    } else {
      return this.outletCountFSM2
    }
  }

  /**
   * 生成出口编号数组
   */
  private getOutletNumbers(): number[] {
    const count = this.getCurrentOutletCount()
    const numbers: number[] = []
    for (let i = 1; i <= count; i++) {
      numbers.push(i)
    }
    return numbers
  }

  build() {
    Column({ space: 10 }) {
      // ==================== 上半部分：子系统设置 ====================
      Column() {
        // 第一行：设置栏
        Row() {
          Row() {
            Text('子系统选择:').fontSize(14).margin({ right: 10 })
            Select([{ value: '子系统1' }, { value: '子系统2' }])
              .selected(this.subsystem === '子系统1' ? 0 : 1)
              .value(this.subsystem)
              .font({ size: 14 })
              .height(30)
              .onSelect((index, value) => {
                this.subsystem = value
                // 子系统切换时，表格会自动根据新的出口数量更新
              })
          }.margin({ right: 20 })

          Row() {
            Text('电磁阀脉宽').fontSize(14).margin({ right: 10 })
            NumericInput({ value: $valveWidth, min: 1, max: 100 })
              .width(80)
              .height(30)
          }.margin({ right: 20 })

          Row() {
            Text('贴标脉宽').fontSize(14).margin({ right: 10 })
            NumericInput({ value: $labelWidth, min: 1, max: 100 })
              .width(80)
              .height(30)
          }

          Blank()

          Button('立即生效')
            .backgroundColor('#228B22') // ForestGreen
            .fontColor(Color.White)
            .fontSize(14)
            .height(30)
        }
        .width('100%')
        .padding({ bottom: 10 })

        // 第二行：表格
        Column() {
          // 表头
          Row() {
            this.buildCell('名称', '15%', true)
            this.buildCell('驱动器', '15%', true)
            this.buildCell('接口', '15%', true)
            this.buildCell('引脚', '15%', true)
            this.buildCell('延长时间', '15%', true)
            this.buildCell('持续时间', '25%', true)
          }
          .width('100%')

          // 表格内容 (可滚动)
          List() {
            ForEach(this.getOutletNumbers(), (i: number) => {
              ListItem() {
                Row() {
                  this.buildCell(`出口 ${i}`, '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '25%')
                }
                .width('100%')
              }
            }, (item: number) => item.toString())
          }
          .width('100%')
          .height(200) // 固定高度
          .scrollBar(BarState.Auto)
        }
        .width('100%')
      }
      .sectionStyle()
      .width('100%')
      .layoutWeight(1)

      // ==================== 下半部分：通道设置 ====================
      Column() {
        // 第一行：设置栏
        Row() {
          Row() {
            Text('通道选择:').fontSize(14).margin({ right: 10 })
            Select([{ value: '通道 1' }, { value: '通道 2' }])
              .selected(0)
              .value(this.channelSelection)
              .font({ size: 14 })
              .height(30)
              .onSelect((index, value) => this.channelSelection = value)
          }

          Blank()

          Button('立即生效')
            .backgroundColor('#228B22') // ForestGreen
            .fontColor(Color.White)
            .fontSize(14)
            .height(30)
        }
        .width('100%')
        .padding({ bottom: 10 })

        // 第二行：表格
        Column() {
          // 表头
          Row() {
            this.buildCell('名称', '15%', true)
            this.buildCell('距离', '15%', true)
            this.buildCell('偏移', '15%', true)
            this.buildCell('驱动器', '15%', true)
            this.buildCell('接口', '15%', true)
            this.buildCell('引脚', '25%', true)
          }
          .width('100%')

          // 表格内容 (可滚动)
          List() {
            // 贴标部分
            ForEach([1, 2, 3, 4], (i: number) => {
              ListItem() {
                Row() {
                  this.buildCell(`贴标 ${i}`, '15%')
                  this.buildCell((26 + i).toString(), '15%')
                  this.buildCell('', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '25%')
                }
                .width('100%')
              }
            })
            // 出口部分
            ForEach([1, 2, 3, 4, 5, 6, 7, 8], (i: number) => {
              ListItem() {
                Row() {
                  this.buildCell(`出口 ${i}`, '15%')
                  this.buildCell((31 + i).toString(), '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '15%')
                  this.buildCell('0', '25%')
                }
                .width('100%')
              }
            })
          }
          .width('100%')
          .height(200) // 固定高度
          .scrollBar(BarState.Auto)
        }
        .width('100%')
      }
      .sectionStyle()
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor('#F5F5F5') // 整体背景灰白
  }
}

