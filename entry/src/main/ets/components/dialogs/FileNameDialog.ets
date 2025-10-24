/**
 * 文件命名对话框组件
 * 
 * 功能说明：
 * - 让用户输入自定义的文件名
 * - 提供默认文件名建议
 * - 支持文件名验证
 * - 提供确认和取消按钮
 * 
 * 使用方式：
 * ```typescript
 * FileNameDialog({
 *   isVisible: this.showFileNameDialog,
 *   defaultFileName: this.defaultFileName,
 *   onConfirm: (fileName: string) => { this.handleFileNameConfirm(fileName) },
 *   onCancel: () => { this.closeFileNameDialog() }
 * })
 * ```
 */

import { BaseComponentHelper } from '../common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * 文件命名对话框组件结构体
 * 
 * 属性说明：
 * - isVisible: 对话框显示状态
 * - defaultFileName: 默认文件名
 * - onConfirm: 确认按钮点击回调函数
 * - onCancel: 取消按钮点击回调函数
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建文件命名对话框的UI结构
 */
@Component
export struct FileNameDialog {
  // ==================== 对话框状态 ====================
  /** 对话框显示状态 */
  @Prop isVisible: boolean = false
  /** 默认文件名 */
  @Prop defaultFileName: string = ''

  // ==================== 事件回调函数 ====================
  /** 确认按钮点击回调函数 */
  onConfirm?: (fileName: string, format: 'csv' | 'xlsx') => void
  /** 取消按钮点击回调函数 */
  onCancel?: () => void

  // ==================== 主题相关属性 ====================
  /** 当前主题样式 */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  /** 当前主题类型 */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  /** 主题版本号 */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  /** 基础组件助手 */
  private baseComponentHelper = new BaseComponentHelper()

  // ==================== 本地状态 ====================
  /** 用户输入的文件名 */
  @State private inputFileName: string = ''
  /** 选择的导出格式 */
  @State private selectedFormat: 'csv' | 'xlsx' = 'csv'

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
   * 处理确认按钮点击
   */
  private handleConfirm(): void {
    const fileName = this.inputFileName.trim()
    if (fileName && this.onConfirm) {
      // 传递文件名和格式信息
      this.onConfirm(fileName, this.selectedFormat)
    }
  }

  /**
   * 处理取消按钮点击
   */
  private handleCancel(): void {
    if (this.onCancel) {
      this.onCancel()
    }
  }

  /**
   * 组件构建方法
   * 
   * 功能：
   * - 构建文件命名对话框的UI结构
   * - 提供文件名输入功能
   * - 处理确认和取消操作
   * 
   * 布局说明：
   * - 使用Column布局垂直排列
   * - 标题 + 输入框 + 按钮区域
   * - 居中显示，圆角设计
   * 
   * 样式说明：
   * - 对话框样式：白色背景，圆角设计，阴影效果
   * - 输入框样式：主题背景色，边框，圆角
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
            this.handleCancel()
          })

        // 对话框内容
        Column() {
          // 标题
          Text('请输入文件名')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ bottom: 16 })

          // 输入框
          TextInput({ 
            text: this.inputFileName, 
            placeholder: '请输入文件名（不含扩展名）' 
          })
            .fontSize(16)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(8)
            .padding(12)
            .width('100%')
            .margin({ bottom: 16 })
            .onChange((value: string) => {
              this.inputFileName = value
            })

          // 格式选择区域
          Column() {
            Text('选择导出格式：')
              .fontSize(16)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start)

            Row() {
              // CSV格式选择
              Row() {
                Radio({ value: 'csv', group: 'exportFormat' })
                  .checked(this.selectedFormat === 'csv')
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.selectedFormat = 'csv'
                    }
                  })
                Text('CSV格式')
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ left: 8 })
              }
              .margin({ right: 24 })

              // Excel格式选择
              Row() {
                Radio({ value: 'xlsx', group: 'exportFormat' })
                  .checked(this.selectedFormat === 'xlsx')
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.selectedFormat = 'xlsx'
                    }
                  })
                Text('Excel格式')
                  .fontSize(16)
                  .fontColor(this.getCurrentTheme().textColor)
                  .margin({ left: 8 })
              }
            }
            .justifyContent(FlexAlign.Start)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 提示信息
          Text('文件将保存为：' + (this.inputFileName || this.defaultFileName) + '.' + this.selectedFormat)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().subTextColor)
            .margin({ bottom: 24 })

          // 按钮区域
          Row() {
            Button('取消')
              .fontSize(16)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(8)
              .width(80)
              .height(40)
              .onClick(() => {
                this.handleCancel()
              })

            Button('确定')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor(this.getCurrentTheme().primary)
              .borderRadius(8)
              .width(80)
              .height(40)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleConfirm()
              })
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('60%')
        .padding(24)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ 
          radius: 16, 
          color: 'rgba(0,0,0,0.3)', 
          offsetY: 6 
        })
        .border({ 
          width: 1, 
          color: this.getCurrentTheme().borderColor 
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}
