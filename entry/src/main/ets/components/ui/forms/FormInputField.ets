/**
 * 表单输入字段组件
 * 功能：统一的表单输入框样式和行为
 * 用途：减少重复代码，统一输入框样式
 */

import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'
import { NumberUtils } from '../../../utils/helpers/NumberUtils'

// 输入字段配置接口
interface FormInputFieldConfig {
  label: string           // 标签文字
  value: number           // 当前值
  unit?: string           // 单位（可选）
  minValue?: number       // 最小值（可选）
  maxValue?: number       // 最大值（可选）
  labelWidth?: number     // 标签宽度（默认72）
  inputMinWidth?: number  // 输入框最小宽度（默认140）
  inputMaxWidth?: number  // 输入框最大宽度（默认180）
  inputHeight?: number    // 输入框高度（默认34）
  fontSize?: number       // 字体大小（默认18）
}

@Component
export struct FormInputField {
  // 配置参数
  @Prop config: FormInputFieldConfig
  // 值变化回调
  onValueChange?: (value: number) => void

  build() {
    Row() {
      // 标签
      Text(this.config.label)
        .fontSize(this.config.fontSize ?? 18)
        .fontColor(getCurrentTheme().textColor)
        .width(this.config.labelWidth ?? 72)
        .textAlign(TextAlign.End)
        .margin({ right: 8 })

      // 输入框
      TextInput({ text: NumberUtils.formatNumberForDisplay(this.config.value) })
        .type(InputType.Number)
        .fontSize(this.config.fontSize ?? 18)
        .fontColor(getCurrentTheme().textColor)
        .backgroundColor(getCurrentTheme().controlBg ?? getCurrentTheme().surfaceColor)
        .border({ width: 1, color: getCurrentTheme().borderColor })
        .borderRadius(8)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .constraintSize({ 
          minWidth: this.config.inputMinWidth ?? 140, 
          maxWidth: this.config.inputMaxWidth ?? 180 
        })
        .height(this.config.inputHeight ?? 34)
        .onChange((val: string) => {
          const newValue: number = NumberUtils.parseNumberWithBounds(
            val, 
            this.config.minValue, 
            this.config.maxValue
          )
          if (this.onValueChange) {
            this.onValueChange(newValue)
          }
        })

      // 单位（如果提供）
      if (this.config.unit) {
        Text(this.config.unit)
          .fontSize(this.config.fontSize ?? 18)
          .fontColor(getCurrentTheme().subTextColor)
          .margin({ left: 8 })
      }
    }
    .layoutWeight(1)
    .alignItems(VerticalAlign.Center)
  }
}

