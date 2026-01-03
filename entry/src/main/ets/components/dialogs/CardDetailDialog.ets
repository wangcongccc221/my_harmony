import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { DialogButtons } from '../ui/dialogs/DialogButtons'
import { ThreeLayerCardData } from '../ThreeLayerCard/types'

@Component
export struct CardDetailDialog {

  @Prop isVisible: boolean = false
  

  @Prop cardNumber: number = 1

  @Prop cardData: ThreeLayerCardData | null = null
  

  onConfirm?: () => void
  

  onCancel?: () => void


  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }


  private getDataCount(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData) {
      return 0
    }
    return this.cardData.thirdLayer.chartData.length
  }

  private getDataSum(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData) {
      return 0
    }
    return this.cardData.thirdLayer.chartData.reduce((sum, val) => sum + val, 0)
  }


  private getDataAverage(): string {
    const count = this.getDataCount()
    if (count === 0) {
      return '0.00'
    }
    const avg = this.getDataSum() / count
    return avg.toFixed(2)
  }


  private getDataMax(): number {
    if (!this.cardData || !this.cardData.thirdLayer.chartData || this.cardData.thirdLayer.chartData.length === 0) {
      return 0
    }
    return Math.max(...this.cardData.thirdLayer.chartData)
  }

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
          .backgroundColor('rgba(0, 0, 0, 0.3)')
          .backgroundBlurStyle(BlurStyle.Regular)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })
          .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
        
        // 对话框内容 - Page Sheet 风格
        Column() {
          // 顶部导航栏
          Row() {
            Button('关闭')
              .fontSize(16)
              .fontColor(this.getCurrentTheme().primary)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                if (this.onCancel) this.onCancel()
              })
            
            Text(`${this.cardNumber}号卡片详情`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            
            // 占位，保持标题居中
            Button('关闭')
              .fontSize(16)
              .fontColor(Color.Transparent)
              .backgroundColor(Color.Transparent)
              .enabled(false)
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .border({ width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor })

          // 内容区域
          Scroll() {
            Column() {
              // 基本信息卡片
              this.buildBasicInfoCard()

              // 统计信息卡片
              this.buildStatisticsInfoCard()
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .scrollBarColor(this.getCurrentTheme().borderColor)
          .scrollBarWidth(4)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height('60%') // 半屏高度，类似 Page Sheet
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius({ topLeft: 16, topRight: 16 }) // 只有顶部圆角
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: -4 })
        .alignSelf(ItemAlign.End) // 底部对齐
        .transition(TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 350, curve: Curve.Friction }))
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Bottom) // 内容底部对齐
      .zIndex(5000)
    }
  }

  /**
   * 构建基本信息卡片
   */
  @Builder
  private buildBasicInfoCard() {
    Column() {
      Text('基本信息')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ bottom: 8, left: 4 })
      
      Column() {
        this.buildInfoRow('卡片编号', `${this.cardNumber}`, true)
        this.buildInfoRow('卡片ID', this.cardData?.id || '-', true)
        this.buildInfoRow('数据数量', `${this.getDataCount()}`, false)
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().backgroundColor)
      .borderRadius(10)
      .padding({ left: 16 }) // 左侧内边距，用于分割线
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  /**
   * 构建统计信息卡片
   */
  @Builder
  private buildStatisticsInfoCard() {
    Column() {
      Text('统计信息')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCurrentTheme().subTextColor)
        .margin({ bottom: 8, left: 4 })
      
      Column() {
        this.buildInfoRow('数据总和', `${this.getDataSum()}`, true)
        this.buildInfoRow('平均值', this.getDataAverage(), true)
        this.buildInfoRow('最大值', `${this.getDataMax()}`, true)
        this.buildInfoRow('最小值', `${this.getDataMin()}`, false)
      }
      .width('100%')
      .backgroundColor(this.getCurrentTheme().backgroundColor)
      .borderRadius(10)
      .padding({ left: 16 })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  /**
   * 构建信息行
   */
  @Builder
  private buildInfoRow(label: string, value: string, showDivider: boolean) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .layoutWeight(1)
      
      Text(value)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().subTextColor)
    }
    .width('100%')
    .height(44)
    .padding({ right: 16 })
    .alignItems(VerticalAlign.Center)
    .border(showDivider ? { width: { bottom: 0.5 }, color: this.getCurrentTheme().borderColor } : undefined)
  }

  /**
   * 构建数据列表卡片
   */

}
