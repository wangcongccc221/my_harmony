/**
 * 导出成功对话框组件
 * 
 * 功能说明：
 * - 显示导出成功的提示信息
 * - 显示导出文件路径和导出数量
 * - 提供确认按钮关闭对话框
 * 
 * 使用方式：
 * ```typescript
 * ExportSuccessDialog({
 *   isVisible: this.showSuccessDialog,
 *   filePath: this.exportFilePath,
 *   exportCount: this.exportCount,
 *   onConfirm: () => { this.closeSuccessDialog() }
 * })
 * ```
 */

import { BaseComponentHelper } from '../common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * 导出成功对话框组件结构体
 * 
 * 属性说明：
 * - isVisible: 对话框显示状态
 * - filePath: 导出文件路径
 * - exportCount: 导出数据条数
 * - onConfirm: 确认按钮点击回调函数
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建导出成功对话框的UI结构
 */
@Component
export struct ExportSuccessDialog {
  // ==================== 对话框状态 ====================
  /** 对话框显示状态 */
  @Prop isVisible: boolean = false
  /** 导出文件路径 */
  @Prop filePath: string = ''
  /** 导出数据条数 */
  @Prop exportCount: number = 0

  // ==================== 事件回调函数 ====================
  /** 确认按钮点击回调函数 */
  onConfirm?: () => void

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  /** 基础组件助手 */
  private baseComponentHelper = new BaseComponentHelper()

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从基础组件助手获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建导出成功对话框的UI结构
   * - 显示导出成功信息和文件路径
   * - 处理确认按钮点击事件
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 成功图标 + 标题 + 详细信息 + 确认按钮
   * - 居中显示，圆角设计
   * 
   * 样式说明：
   * - 对话框样式：白色背景，圆角设计，阴影效果
   * - 图标样式：绿色成功图标
   * - 文字样式：主题文字颜色，不同字体大小
   * - 按钮样式：主题背景色，白色文字，圆角设计
   */
  build() {
    if (this.isVisible) {
      Stack() {
        // 背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm()
            }
          })

        // 对话框内容
        Column() {
          // 成功图标区域 - 圆形背景 + 勾号
          Stack() {
            // 圆形背景
            Circle({ width: 80, height: 80 })
              .fill('#4CAF50')
            
            // 成功图标 - 居中显示
            Text('✓')
              .fontSize(40)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 20 })

          // 成功标题
          Text('导出成功！')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ bottom: 8 })

          // 导出信息
          Text(`已成功导出 ${this.exportCount} 条数据`)
            .fontSize(16)
            .fontColor(this.getCurrentTheme().subTextColor)
            .margin({ bottom: 20 })

          // 文件路径信息
          if (this.filePath) {
            Column() {
              Row() {
                Text('📁')
                  .fontSize(14)
                  .margin({ right: 6 })
                
                Text('文件保存位置：')
                  .fontSize(13)
                  .fontColor(this.getCurrentTheme().textColor)
                  .fontWeight(FontWeight.Medium)
              }
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 6 })

              Text(this.filePath)
                .fontSize(11)
                .fontColor(this.getCurrentTheme().subTextColor)
                .textAlign(TextAlign.Start)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
                .padding(8)
                .borderRadius(6)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .margin({ bottom: 20 })
          }

          // 按钮区域
          Row() {
            Button('确定')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.getCurrentTheme().primary)
              .borderRadius(16)
              .height(52)
              .layoutWeight(1)
              .onClick(() => {
                if (this.onConfirm) {
                  this.onConfirm()
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('90%')
        .constraintSize({ maxWidth: 480 })
        .padding({ top: 32, bottom: 32, left: 32, right: 32 })
        .backgroundColor(this.getCurrentTheme().backgroundColor)
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
