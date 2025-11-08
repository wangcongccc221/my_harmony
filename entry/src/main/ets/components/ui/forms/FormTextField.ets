/**
 * 表单文本输入框组件
 * 功能：统一的文本输入框样式和行为
 * 用途：减少重复代码，统一文本输入框样式
 */

import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

interface FormTextFieldConfig {
  label: string           // 标签文字
  value: string           // 当前值
  placeholder?: string    // 占位符（可选）
  required?: boolean      // 是否必填（默认false）
  fontSize?: number       // 字体大小（默认18）
  height?: number         // 输入框高度（默认40）
  borderRadius?: number   // 圆角（默认6）
}

@Component
export struct FormTextField {
  @Prop config: FormTextFieldConfig
  onTextChange?: (value: string) => void

  build() {
    Column() {
      Row() {
        Text(this.config.label)
          .fontSize(this.config.fontSize ?? 18)
          .fontColor(getCurrentTheme().textColor)
          .fontWeight(FontWeight.Medium)
        if (this.config.required) {
          Text('*')
            .fontSize(this.config.fontSize ?? 18)
            .fontColor('#FF4444')
            .margin({ left: 2 })
        }
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      TextInput({ 
        text: this.config.value,
        placeholder: this.config.placeholder ?? `请输入${this.config.label}` 
      })
        .width('100%')
        .height(this.config.height ?? 40)
        .fontSize(this.config.fontSize ?? 18)
        .fontColor(getCurrentTheme().textColor)
        .backgroundColor(getCurrentTheme().backgroundColor)
        .border({ width: 1, color: getCurrentTheme().borderColor })
        .borderRadius(this.config.borderRadius ?? 6)
        .padding({ left: 12, right: 12 })
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

