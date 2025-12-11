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

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../../utils/theme/useOmniTheme'
import { I18N_VERSION_KEY } from '../../../utils/i18n/I18nManager'
import { AppleDesignStyle } from '../../../utils/theme/AppleDesignStyle'

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
  @StorageLink(I18N_VERSION_KEY) i18nVersion: number = 0  // 监听语言变化，触发 UI 更新

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
                .fontSize(17) // Apple风格：合理字体
                .fontWeight(FontWeight.Medium) // Apple风格：Medium而非Bold
                .fontColor(this.getCurrentTheme().textColor)
                .layoutWeight(1)
                .opacity(this.i18nVersion >= 0 ? 1 : 1)  // 引用 i18nVersion 确保语言变化时重新渲染
              
              // 关闭按钮
              Button() {
                Text('×')
                  .fontSize(22) // Apple风格：合理字体
                  .fontWeight(FontWeight.Normal) // Apple风格：Normal
                  .fontColor(this.getCurrentTheme().subTextColor) // Apple风格：使用次要文字颜色
              }
              .width(28) // Apple风格：合理按钮大小
              .height(28)
              .backgroundColor(Color.Transparent)
              .borderRadius(AppleDesignStyle.BORDER_RADIUS_SMALL) // Apple风格：小圆角
              .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
              .onClick(() => {
                if (this.onClose) {
                  this.onClose()
                }
              })
            }
            .width('100%')
            .padding({ left: AppleDesignStyle.SPACING_LARGE, right: AppleDesignStyle.SPACING_LARGE, top: AppleDesignStyle.SPACING_MEDIUM, bottom: AppleDesignStyle.SPACING_MEDIUM }) // Apple风格：统一间距
            .border({ width: { bottom: AppleDesignStyle.BORDER_WIDTH_THIN }, color: this.getCurrentTheme().borderColor }) // Apple风格：细边框
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
        .hitTestBehavior(HitTestMode.Default)  // 确保可以接收点击事件
        .width(this.windowWidth)
        .height(this.windowHeight)
        .backgroundColor(this.getCurrentTheme().surfaceColor) // 使用不透明的主题色
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_LARGE) // Apple风格：大圆角(16px)
        .shadow(AppleDesignStyle.getShadowLarge()) // Apple风格：柔和阴影
        .position({ 
          x: this.windowPosition.x, 
          y: this.windowPosition.y 
        })
        .transition(AppleDesignStyle.getTransitionNormal()) // Apple风格：流畅过渡动画
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
