/**
 * 出口设置对话框组件
 * 
 * 功能说明：
 * - 提供出口设置的对话框界面
 * - 支持出口编号的选择和切换
 * - 提供确认和取消操作
 * - 支持上一个/下一个出口的快速切换
 * 
 * 组件特点：
 * - 模态对话框：覆盖整个屏幕
 * - 出口选择：支持1-9号出口的选择
 * - 导航控制：支持上一个/下一个出口切换
 * - 操作确认：提供确认和取消按钮
 * - 主题支持：使用主题管理器的样式配置
 * 
 * 交互功能：
 * - 出口切换：点击上一个/下一个按钮
 * - 出口选择：点击数字按钮直接选择
 * - 确认操作：点击确认按钮保存设置
 * - 取消操作：点击取消按钮关闭对话框
 * 
 * 使用方式：
 * ```typescript
 * OutletDialog({
 *   isVisible: this.showOutletDialog,
 *   currentOutletIndex: this.currentOutletIndex,
 *   onPrevious: () => { this.switchToPreviousOutlet() },
 *   onNext: () => { this.switchToNextOutlet() },
 *   onConfirm: () => { this.confirmOutletSetting() },
 *   onCancel: () => { this.cancelOutletSetting() }
 * })
 * ```
 * 
 * 样式说明：
 * - 背景：半透明黑色遮罩
 * - 对话框：白色背景，圆角设计
 * - 按钮：主题色背景，白色文字
 * - 布局：居中显示，响应式设计
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { DialogButtons } from '../../components/ui/dialogs/DialogButtons'

@Component
export struct OutletDialog {
  /**
   * 对话框显示状态
   * 
   * 功能说明：
   * - 控制出口设置对话框的显示和隐藏
   * - 默认值为false（隐藏状态）
   * - 当为true时显示对话框
   */
  @Prop isVisible: boolean = false
  
  /**
   * 当前选中的出口索引
   * 
   * 功能说明：
   * - 标识当前选中的出口编号（1-9）
   * - 默认值为1（1号出口）
   * - 用于显示当前选中的出口
   */
  @Prop currentOutletIndex: number = 1
  
  /**
   * 上一个出口回调函数
   * 
   * 功能说明：
   * - 当用户点击"上一个"按钮时触发
   * - 用于切换到上一个出口
   * - 支持循环切换（9号出口的上一个是1号出口）
   */
  onPrevious?: () => void
  
  /**
   * 下一个出口回调函数
   * 
   * 功能说明：
   * - 当用户点击"下一个"按钮时触发
   * - 用于切换到下一个出口
   * - 支持循环切换（1号出口的下一个是2号出口）
   */
  onNext?: () => void
  
  /**
   * 确认回调函数
   * 
   * 功能说明：
   * - 当用户点击"确认"按钮时触发
   * - 用于保存出口设置并关闭对话框
   * - 处理出口设置的确认逻辑
   */
  onConfirm?: () => void
  
  /**
   * 取消回调函数
   * 
   * 功能说明：
   * - 当用户点击"取消"按钮时触发
   * - 用于取消出口设置并关闭对话框
   * - 处理出口设置的取消逻辑
   */
  onCancel?: () => void

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从主题管理器获取当前主题样式
   * - 用于对话框的颜色配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 组件构建方法
   * 
   * 功能说明：
   * - 构建出口设置对话框的UI结构
   * - 使用Stack布局实现模态对话框效果
   * - 配置对话框的显示、隐藏和交互
   * 
   * 布局说明：
   * - 使用Stack布局实现模态对话框
   * - 使用Column布局垂直排列内容
   * - 使用Row布局水平排列按钮
   * - 支持出口编号显示和切换
   * 
   * 交互功能：
   * - 上一个/下一个按钮：切换出口
   * - 数字按钮：直接选择出口
   * - 确认/取消按钮：保存或取消设置
   */
  build() {
    if (this.isVisible) {
      Stack() {
        Column() {
          // 标题栏：左上角显示出口编号，右上角显示上一个/下一个按钮
          Row() {
            // 左上角：出口编号
            Text(`${this.currentOutletIndex}号出口`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getCurrentTheme().textColor)
              .layoutWeight(1)
            
            // 右上角：上一个/下一个按钮
            Row() {
              Button('上一个')
                .fontSize(12)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(6)
                .padding({ left: '0.56%', right: '0.56%', top: '0.42%', bottom: '0.42%' })
                .onClick(() => {
                  if (this.onPrevious) {
                    this.onPrevious()
                  }
                })

              Button('下一个')
                .fontSize(12)
                .fontColor(this.getCurrentTheme().textColor)
                .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .borderRadius(6)
                .padding({ left: '0.56%', right: '0.56%', top: '0.42%', bottom: '0.42%' })
                .margin({ left: '0.37%' })
                .onClick(() => {
                  if (this.onNext) {
                    this.onNext()
                  }
                })
            }
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding({ left: '0.93%', right: '0.93%', top: '1.04%', bottom: '1.04%' })
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

          // 内容区域
          Column() {
            Text('出口设置内容')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .margin({ top: '2.08%', bottom: '2.08%' })
            
            // 出口信息卡片
            Column() {
              Text('出口信息')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .margin({ bottom: 15 })
              
              Row() {
                Text('出口编号：')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().subTextColor)
                  .width('3.70%')
                Text(this.currentOutletIndex.toString())
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: '0.69%' })
              
              Row() {
                Text('状态：')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().subTextColor)
                  .width('3.70%')
                Text('正常')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#4CAF50')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: '0.69%' })
              
              Row() {
                Text('位置：')
                  .fontSize(14)
                  .fontColor(this.getCurrentTheme().subTextColor)
                  .width('3.70%')
                Text('第' + this.currentOutletIndex + '个出口')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)
                  .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: '0.93%', right: '0.93%', top: '1.39%', bottom: '1.39%' })
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
            .borderRadius(8)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .margin({ bottom: '2.08%' })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          // 底部按钮栏（使用DialogButtons组件）
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
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
        .alignSelf(ItemAlign.Center)
        .margin({ top: '5.56%' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .alignContent(Alignment.Center)
      .onClick(() => {
        if (this.onCancel) {
          this.onCancel()
        }
      })
    }
  }
}
