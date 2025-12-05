/**
 * 卡片详情对话框组件
 * 
 * 功能说明：
 * - 显示液体卡片的详细信息
 * - 可复用的对话框组件
 * - 支持主题配置和样式定制
 * 
 * 使用方式：
 * ```typescript
 * CardDetailDialog({
 *   isVisible: this.showCardDialog,
 *   cardNumber: this.selectedCardNumber,
 *   cardData: this.selectedCardData,
 *   onConfirm: () => { this.handleConfirm() },
 *   onCancel: () => { this.handleCancel() }
 * })
 * ```
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { ThreeLayerCardData } from '../ThreeLayerCard/types'

@Component
export struct CardDetailDialog {
  /**
   * 对话框显示状态
   */
  @Prop isVisible: boolean = false
  
  /**
   * 卡片编号（1-40）
   */
  @Prop cardNumber: number = 1
  
  /**
   * 卡片数据
   */
  @Prop cardData: ThreeLayerCardData | null = null
  
  /**
   * 确认回调函数
   */
  onConfirm?: () => void
  
  /**
   * 取消回调函数
   */
  onCancel?: () => void

  /**
   * 获取当前主题配置
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 获取卡片数据数量
   */
  private getDataCount(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData) {
      return 0
    }
    return this.cardData.thirdLayer.chartData.length
  }

  /**
   * 获取卡片数据总和
   */
  private getDataSum(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData) {
      return 0
    }
    return this.cardData.thirdLayer.chartData.reduce((sum, val) => sum + val, 0)
  }

  /**
   * 获取卡片数据平均值
   */
  private getDataAverage(): string {
    const count = this.getDataCount()
    if (count === 0) {
      return '0.00'
    }
    const avg = this.getDataSum() / count
    return avg.toFixed(2)
  }

  /**
   * 获取卡片数据最大值
   */
  private getDataMax(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData || this.cardData.thirdLayer.chartData.length === 0) {
      return 0
    }
    return Math.max(...this.cardData.thirdLayer.chartData)
  }

  /**
   * 获取卡片数据最小值
   */
  private getDataMin(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData || this.cardData.thirdLayer.chartData.length === 0) {
      return 0
    }
    return Math.min(...this.cardData.thirdLayer.chartData)
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })
        
        // 对话框内容
        Column() {
          // 标题栏
          Row() {
            Text(`${this.cardNumber}号卡片详情`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: '0.93%', right: '0.93%', top: '1.04%', bottom: '1.04%' })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

          // 内容区域
          Scroll() {
            Column() {
              // 基本信息卡片
              this.buildBasicInfoCard()

              // 统计信息卡片
              this.buildStatisticsInfoCard()

              // 数据列表卡片
              if (this.getDataCount() > 0) {
                this.buildDataListCard()
              }
            }
            .width('100%')
            .padding({ left: '0.93%', right: '0.93%', top: '1.39%', bottom: '1.39%' })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .scrollBarColor(this.getCurrentTheme().borderColor)
          .scrollBarWidth(6)
          .edgeEffect(EdgeEffect.Spring)

          // 底部按钮栏
          DialogButtons({
            confirmText: '确认',
            cancelText: '取消',
            showCancel: true,
            confirmDisabled: false,
            onConfirm: () => {
              if (this.onConfirm) {
                this.onConfirm()
              }
            },
            onCancel: () => {
              if (this.onCancel) {
                this.onCancel()
              }
            }
          })
          .width('100%')
          .padding({ left: '0.93%', right: '0.93%', top: '0%', bottom: '1.39%' })
        }
        .width('85%')
        .constraintSize({ maxHeight: '80%' })
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }

  /**
   * 构建基本信息卡片
   */
  @Builder
  private buildBasicInfoCard() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: '1.04%' })
      
      Column() {
        this.buildInfoRow('卡片编号', `${this.cardNumber}`)
        this.buildInfoRow('卡片ID', this.cardData?.id || '-')
        this.buildInfoRow('数据数量', `${this.getDataCount()}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: '0.93%', right: '0.93%', top: '1.39%', bottom: '1.39%' })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(8)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .margin({ bottom: '1.39%' })
  }

  /**
   * 构建统计信息卡片
   */
  @Builder
  private buildStatisticsInfoCard() {
    Column() {
      Text('统计信息')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: '1.04%' })
      
      Column() {
        this.buildInfoRow('数据总和', `${this.getDataSum()}`)
        this.buildInfoRow('平均值', this.getDataAverage())
        this.buildInfoRow('最大值', `${this.getDataMax()}`)
        this.buildInfoRow('最小值', `${this.getDataMin()}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: '0.93%', right: '0.93%', top: '1.39%', bottom: '1.39%' })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(8)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .margin({ bottom: '1.39%' })
  }

  /**
   * 构建信息行
   */
  @Builder
  private buildInfoRow(label: string, value: string) {
    Row() {
      Text(`${label}：`)
        .fontSize(14)
        .fontColor(this.getCurrentTheme().subTextColor)
        .width('5.56%')
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: '0.69%' })
  }

  /**
   * 构建数据列表卡片
   */
  @Builder
  private buildDataListCard() {
    Column() {
      Text('数据列表')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ bottom: '1.04%' })
      
      Column() {
        if (this.cardData && this.cardData.thirdLayer.chartData) {
          ForEach(this.cardData.thirdLayer.chartData, (value: number, index: number) => {
            Row() {
              Text(`${index + 1}.`)
                .fontSize(14)
                .fontColor(this.getCurrentTheme().subTextColor)
                .width('2.78%')
              Text(`${value}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: '0.56%', right: '0.56%', top: '0.42%', bottom: '0.42%' })
            .backgroundColor(index % 2 === 0 ? this.getCurrentTheme().backgroundColor : this.getCurrentTheme().controlBg)
            .borderRadius(4)
            .margin({ bottom: '0.35%' })
          })
        }
      }
      .width('100%')
      .constraintSize({ maxHeight: '13.89%' })
    }
    .width('100%')
    .padding({ left: '0.93%', right: '0.93%', top: '1.39%', bottom: '1.39%' })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(8)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .margin({ bottom: '1.39%' })
  }
}
