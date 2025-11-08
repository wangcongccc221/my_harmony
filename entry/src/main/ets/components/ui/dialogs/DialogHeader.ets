/**
 * 对话框标题栏组件
 * 功能：统一的对话框标题栏样式和行为
 * 用途：减少重复代码，统一对话框标题栏样式
 */

import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

// Padding 接口定义
export interface Padding {
  left?: number
  right?: number
  top?: number
  bottom?: number
}

@Component
export struct DialogHeader {
  // 标题文字
  @Prop title: string = ''
  // 标题字体大小（默认24）
  @Prop titleFontSize?: number
  // 关闭按钮点击回调
  onClose?: () => void
  // 是否显示关闭按钮（默认true）
  @Prop showCloseButton: boolean = true
  // 自定义padding（可选）
  @Prop customPadding?: Padding

  build() {
    Row() {
      Text(this.title)
        .fontSize(this.titleFontSize ?? 24)
        .fontWeight(FontWeight.Bold)
        .fontColor(getCurrentTheme().textColor)
        .layoutWeight(1)
      
      if (this.showCloseButton) {
        // 关闭按钮
        Button() {
          Text('×')
            .fontSize(this.titleFontSize ?? 24)
            .fontColor(getCurrentTheme().textColor)
        }
        .width(30)
        .height(30)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.onClose) {
            this.onClose()
          }
        })
      }
    }
    .width('100%')
    .padding(this.customPadding ?? { left: 12, right: 12, top: 10, bottom: 10 })
    .border({ width: { bottom: 1 }, color: getCurrentTheme().borderColor })
  }
}

