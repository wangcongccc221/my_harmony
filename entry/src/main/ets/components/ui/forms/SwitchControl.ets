/**
 * 开关控制组件
 * 功能：统一的开关控件样式和交互
 * 用途：可复用的开关控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct SwitchControl {
  @Prop label: string = ''  // 标签文字
  @Link isEnabled: boolean  // 开关状态（双向绑定）
  @Prop switchSize: number = 20  // 开关大小（高度）
  @Prop activeColor: string = '#EA7A10'  // 激活颜色
  @Prop inactiveColor: string = '#E0E0E0'  // 非激活颜色
  @Prop isLastEnabled: boolean = false  // 是否为最后一个开启的设置（用于阻止关闭）
  
  onToggle?: () => void  // 切换回调

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      // 左侧标签文字
      Text(this.label)
        .fontSize(12)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ right: 8 })
        .flexShrink(0)

      // 自定义开关 UI
      Stack() {
        // 背景轨道
        Row()
          .width(this.switchSize * 2) // 宽度是高度的2倍
          .height(this.switchSize)
          .backgroundColor(this.isEnabled ? this.activeColor : this.inactiveColor)
          .borderRadius(this.switchSize / 2)
          .animation({ duration: 300, curve: Curve.LinearOutSlowIn }) // 背景色过渡动画

        // 操纵钮（圆形）
        Row()
          .width(this.switchSize - 4) // 上下各留2px间距
          .height(this.switchSize - 4)
          .backgroundColor(Color.White)
          .borderRadius((this.switchSize - 4) / 2)
          .shadow({ radius: 2, color: '#00000033', offsetX: 1, offsetY: 1 }) // 添加轻微阴影，增加立体感
          .margin({ left: 2 }) // 初始左边距
          .translate({ x: this.isEnabled ? this.switchSize : 0 }) // 开启时向右移动一个高度的距离
          .animation({ duration: 300, curve: Curve.LinearOutSlowIn }) // 移动动画
      }
      .width(this.switchSize * 2)
      .height(this.switchSize)
      .alignContent(Alignment.Start) // 内容左对齐，通过translate移动滑块
      .onClick(() => {
        // 核心交互逻辑
        // 1. 如果当前开启，且标记为"最后一个可用"，则阻止关闭
        if (this.isEnabled && this.isLastEnabled) {
          console.log(`[SwitchControl] 无法关闭 ${this.label}，必须保持至少一个设置开启`)
          return
        }

        // 2. 正常切换状态
        // 使用 animateTo 包裹状态改变，虽然组件属性已有animation，但显式调用更保险
        animateTo({ duration: 300, curve: Curve.LinearOutSlowIn }, () => {
          this.isEnabled = !this.isEnabled
        })

        // 3. 触发回调
        if (this.onToggle) {
          this.onToggle()
        }
      })
      .flexShrink(0)
    }
    .width('auto')
    .height('auto')
    .alignItems(VerticalAlign.Center)
    .margin({ right: 8 })
    .flexShrink(0)
  }
}
