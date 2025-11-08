/**
 * 表单文本域组件
 * 功能：统一的文本域样式和行为
 * 用途：减少重复代码，统一文本域样式
 */

import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

interface FormTextAreaConfig {
  label: string           // 标签文字
  value: string           // 当前值
  placeholder?: string    // 占位符（可选）
  fontSize?: number       // 字体大小（默认18）
  height?: number         // 文本域高度（默认80）
  borderRadius?: number   // 圆角（默认6）
}

@Component
export struct FormTextArea {
  @Prop config: FormTextAreaConfig
  onTextChange?: (value: string) => void

  build() {
    Column() {
      Text(this.config.label)
        .fontSize(this.config.fontSize ?? 18)
        .fontColor(getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ bottom: 8 })
      
      TextArea({ 
        text: this.config.value,
        placeholder: this.config.placeholder ?? `请输入${this.config.label}` 
      })
        .width('100%')
        .height(this.config.height ?? 80)
        .fontSize(this.config.fontSize ?? 18)
        .fontColor(getCurrentTheme().textColor)
        .backgroundColor(getCurrentTheme().backgroundColor)
        .border({ width: 1, color: getCurrentTheme().borderColor })
        .borderRadius(this.config.borderRadius ?? 6)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onChange((value: string) => {
          if (this.onTextChange) {
            this.onTextChange(value)
          }
        })
    }
    .width('100%')
    .margin({ bottom: 16 })
    .alignItems(HorizontalAlign.Start)
  }
}

