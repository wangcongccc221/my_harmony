/**
 * 悬浮窗组件
 * 
 * 功能说明：
 * - 在页面右侧显示悬浮窗
 * - 支持自定义内容
 * - 支持显示/隐藏动画
 * - 支持点击外部关闭
 * - 集成主题配置
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

// 位置接口定义
interface Position {
  x: number
  y: number
}

@Component
export struct FloatingWindow {
  @Prop isVisible: boolean = false  // 是否显示
  @Prop title: string = ''  // 标题
  @Prop windowWidth: string = '300px'  // 宽度
  @Prop windowHeight: string = '400px'  // 高度
  @Prop windowPosition: Position = { x: 0, y: 0 }  // 位置
  
  // 内容插槽
  @BuilderParam content?: () => void
  
  // 关闭回调
  onClose?: () => void
  
  // 主题变化监听
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0

  // 获取当前主题配置
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('FloatingWindow: 主题已变化，重新渲染')
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 悬浮窗内容
        Column() {
          // 标题栏
          if (this.title) {
            Row() {
              Text(this.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getCurrentTheme().textColor)
                .layoutWeight(1)
              
              // 关闭按钮
              Button() {
                Text('×')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getCurrentTheme().textColor)
              }
              .width(32)
              .height(32)
              .backgroundColor(Color.Transparent)
              .borderRadius(16)
              .onClick(() => {
                if (this.onClose) {
                  this.onClose()
                }
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
          }

          // 内容区域
          if (this.content) {
            this.content()
          }
        }
        .onClick(() => {
          // 点击悬浮窗内容时不关闭悬浮窗
          // 在HarmonyOS中，事件不会自动冒泡到父组件
        })
        .width(this.windowWidth)
        .height(this.windowHeight)
        .backgroundColor(this.getCurrentTheme().surfaceColor) // 使用不透明的主题色
        .borderRadius(12)
        .shadow({ 
          radius: 20, 
          color: 'rgba(0, 0, 0, 0.15)', 
          offsetX: 0, 
          offsetY: 8 
        })
        .position({ 
          x: this.windowPosition.x, 
          y: this.windowPosition.y 
        })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000) // 确保在最上层
      .onClick(() => {
        // 点击外部区域关闭悬浮窗
        if (this.onClose) {
          this.onClose()
        }
      })
    }
  }
}
