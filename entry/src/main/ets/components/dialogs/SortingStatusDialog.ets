/**
 * 分选状态选择对话框组件
 * 功能：选择正常分选或异常分选状态
 * 用途：在点击分选状态按钮时弹出
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

// 通道数据接口
interface ChannelData {
  channelName: string
  status: string
}

@Component
export struct SortingStatusDialog {
  @Prop isVisible: boolean = false
  @State private sortingStatus: boolean = true  // true=正常分选, false=异常分选
  
  // 对话框回调
  onConfirm?: (isNormal: boolean) => void
  onCancel?: () => void

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  // 确认按钮点击
  private handleConfirm() {
    if (this.onConfirm) {
      this.onConfirm(this.sortingStatus)
    }
  }

  // 取消按钮点击
  private handleCancel() {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  // 生成通道数据
  private buildChannelData(): ChannelData[] {
    const channels: ChannelData[] = []
    const statuses = [
      '基准整定中....',
      '正常运行',
      '设备故障',
      '维护中',
      '待机状态',
      '校准中',
      '连接中断',
      '数据异常'
    ]
    
    for (let i = 1; i <= 20; i++) {
      channels.push({
        channelName: `通道${i}`,
        status: statuses[(i - 1) % statuses.length]
      })
    }
    
    return channels
  }

  build() {
    if (this.isVisible) {
      // 悬浮弹窗内容 - 无遮罩层，直接显示
      Column() {
        // 标题栏
        Row() {
          Text('设备状态')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

        // 表格内容区域
        Column() {
          // 表头
          Row() {
            Text('')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .width('50%')
              .height(32)
              .backgroundColor(this.getCurrentTheme().primary)
              .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
              .padding(8)

            Text('子系统1')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .width('50%')
              .height(32)
              .backgroundColor(this.getCurrentTheme().primary)
              .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
              .padding(8)
          }
          .width('100%')

          // 表格数据区域 - 可滚动
          Scroll() {
            Column() {
              ForEach(this.buildChannelData(), (item: ChannelData, index: number) => {
                Row() {
                  Text(item.channelName)
                    .fontSize(12)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .width('50%')
                    .height(28)
                    .backgroundColor(this.getCurrentTheme().surfaceColor)
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .padding(4)

                  Text(item.status)
                    .fontSize(12)
                    .fontColor(this.getCurrentTheme().textColor)
                    .textAlign(TextAlign.Center)
                    .width('50%')
                    .height(28)
                    .backgroundColor(this.getCurrentTheme().surfaceColor)
                    .border({ width: 0.5, color: this.getCurrentTheme().borderColor })
                    .padding(4)
                }
                .width('100%')
              })
            }
            .width('100%')
          }
          .width('100%')
          .height(200) // 固定高度，超出可滚动
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .scrollBarColor(this.getCurrentTheme().borderColor)
          .scrollBarWidth(4)
        }
        .width('100%')
        .margin({ top: 16, bottom: 16 })
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(6)
      }
      .width(400)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .shadow({
        radius: 12,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 4
      })
      .zIndex(1000) // 确保在最上层
      .position({ x: 20, y: '100%' }) // 定位在底部控制栏上方
      .translate({ y: -200 }) // 向上偏移200px，显示在按钮上方
    }
  }
}

