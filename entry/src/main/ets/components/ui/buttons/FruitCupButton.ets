/**
 * 果杯按钮组件
 * 功能：统一的果杯按钮样式和交互
 * 用途：底部控制栏的果杯按钮
 */

import { StandardRoundButton } from './StandardRoundButton'

@Component
export struct FruitCupButton {
  @Prop cupNumber: number = 1  // 果杯编号
  onCupClick?: (cupNumber: number) => void  // 点击回调

  build() {
    StandardRoundButton({
      text: this.cupNumber.toString(),
      onClickAction: () => {
        console.log(`果杯按钮${this.cupNumber}被点击`)
        if (this.onCupClick) {
          this.onCupClick(this.cupNumber)
        }
      }
    })
    .margin({ right: 4 })
  }
}
