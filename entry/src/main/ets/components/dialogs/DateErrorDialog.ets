/**
 * 日期错误对话框组件
 * 功能：显示日期输入错误的提示对话框
 * 用途：当用户输入的结束时间早于开始时间时显示
 */

import { ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { DialogButtons } from '../ui/dialogs/DialogButtons'

@Component
export struct DateErrorDialog {
  @Prop isVisible: boolean = false
  
  // 对话框回调
  onConfirm?: () => void
  onCancel?: () => void

  build() {
    if (this.isVisible) {
      // 遮罩层
      Stack() {
        // 对话框内容
        Column() {
          // 错误图标和标题
          Column() {
            // 错误图标 (使用文字符号代替)
            Text('⚠️')
              .fontSize(48)
              .fontColor('#FF6B6B')
              .margin({ bottom: 16 })
            
            // 错误标题
            Text('输入日期有误')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(getCurrentTheme().textColor)
              .margin({ bottom: 8 })
            
            // 错误描述
            Text('结束时间不能早于开始时间，请重新选择日期')
              .fontSize(14)
              .fontColor(getCurrentTheme().subTextColor)
              .textAlign(TextAlign.Center)
              .lineHeight(20)
          }
          .padding({ left: 24, right: 24, top: 24, bottom: 24 })
          .alignItems(HorizontalAlign.Center)

          // 底部按钮
          DialogButtons({
            confirmText: '✓',
            cancelText: '✗',
            showCancel: true,
            confirmDisabled: false,
            onConfirm: this.onConfirm,
            onCancel: this.onCancel
          })
        }
        .width('400px')
        .backgroundColor(getCurrentTheme().surfaceColor)
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .alignContent(Alignment.Center)
      .onClick(() => {
        // 点击遮罩层关闭对话框
        if (this.onCancel) {
          this.onCancel()
        }
      })
    }
  }
}

