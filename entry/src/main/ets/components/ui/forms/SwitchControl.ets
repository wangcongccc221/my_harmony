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
        .fontSize(16) // 加大字体到16，与整体风格匹配
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isEnabled ? this.activeColor : '#606266') // 开启时标签也高亮，关闭时用高级灰
        .margin({ right: 12 }) // 增加间距
        .flexShrink(0)
        .animation({ duration: 300 }) // 颜色过渡动画

      // 自定义开关 UI
      Stack() {
        // 背景轨道
        Row()
          .width(50) // 固定宽度 50
          .height(28) // 固定高度 28
          .backgroundColor(this.isEnabled ? this.activeColor : '#E4E7ED') // 关闭时用更柔和的灰色
          .borderRadius(14)
          .animation({ duration: 300, curve: Curve.EaseInOut }) // 优化动画曲线

        // 操纵钮（圆形）
        Row()
          .width(24) 
          .height(24)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 }) // 更精致的阴影
          .margin({ left: 2 }) 
          .translate({ x: this.isEnabled ? 22 : 0 }) // 精确计算位移
          .animation({ duration: 300, curve: Curve.FastOutSlowIn }) // 使用标准减速动画
      }
      .width(50)
      .height(28)
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
