/**
 * 通用提示对话框组件
 * 功能：显示成功或失败的提示信息，支持自动关闭
 * 用途：用于查询成功、删除成功、查询失败等场景
 */

import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * 提示对话框组件结构体
 */
@Component
export struct ToastDialog {
  // ==================== 对话框状态 ====================
  /** 对话框显示状态 */
  @Prop isVisible: boolean = false
  /** 提示类型：success=成功, error=失败 */
  @Prop type: 'success' | 'error' = 'success'
  /** 提示消息 */
  @Prop message: string = ''

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  /**
   * 获取当前主题配置
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(this.consumedTheme)
  }

  /**
   * 获取图标颜色
   */
  private getIconColor(): Color {
    return this.type === 'success' ? Color.Green : Color.Red
  }

  /**
   * 获取图标文本
   */
  private getIconText(): string {
    return this.type === 'success' ? '✓' : '✗'
  }

  /**
   * 获取标题文本
   */
  private getTitleText(): string {
    return this.type === 'success' ? '操作成功' : '操作失败'
  }

  /**
   * 组件构建方法
   */
  build() {
    if (this.isVisible) {
      Stack() {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')

        // 对话框内容
        Column() {
          // 图标区域
          Stack() {
            Circle({ width: 80, height: 80 })
              .fill(this.getIconColor())
            
            Text(this.getIconText())
              .fontSize(40)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 20 })

          // 标题
          Text(this.getTitleText())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(getCurrentTheme(this.consumedTheme).textColor)
            .margin({ bottom: 8 })

          // 消息内容
          if (this.message) {
            Text(this.message)
              .fontSize(16)
              .fontColor(getCurrentTheme(this.consumedTheme).subTextColor)
              .textAlign(TextAlign.Center)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('85%')
        .constraintSize({ maxWidth: 400 })
        .padding({ top: 32, bottom: 32, left: 32, right: 32 })
        .backgroundColor(getCurrentTheme(this.consumedTheme).backgroundColor)
        .borderRadius(24)
        .shadow({ 
          radius: 32, 
          color: 'rgba(0, 0, 0, 0.2)', 
          offsetX: 0, 
          offsetY: 12 
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}

