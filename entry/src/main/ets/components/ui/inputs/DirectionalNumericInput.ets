/**
 * 带方向按钮的数值输入组件
 * 功能：包含一个数值输入框，周围有方向按钮
 * buttonMode: 'double' - 每个方向两个按钮（↑↓），'single' - 每个方向一个按钮（↑↓←→）
 */

import { NumericInput } from './NumericInput'
import { ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../../utils/theme/ThemeUtils'

@Component
export struct DirectionalNumericInput {
  @Link value: number
  @Prop min: number = 0
  @Prop max: number = 9999
  @Prop step: number = 1
  @Prop inputWidth: number = 120
  @Prop inputHeight: number = 30
  @Prop buttonMode: 'double' | 'single' = 'double'

  private resolveTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme()
  }

  build() {
    Column() {
      if (this.buttonMode === 'double') {
        // 双按钮模式：每个方向两个按钮（↑↓）
        // 顶部按钮（↑和↓）
        Row({ space: 1 }) {
          Button() {
            Text('↑')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value + this.step <= this.max) {
              this.value += this.step
            }
          })
          
          Button() {
            Text('↓')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value - this.step >= this.min) {
              this.value -= this.step
            }
          })
        }
        .margin({ bottom: 2 })
        .justifyContent(FlexAlign.Center)
        
        // 中间：左侧按钮 + 输入框 + 右侧按钮
        Row({ space: 2 }) {
          // 左侧按钮（↑和↓）
          Column({ space: 1 }) {
            Button() {
              Text('↑')
                .fontSize(9)
                .fontColor(this.resolveTheme().textColor)
            }
            .type(ButtonType.Normal)
            .width(16)
            .height(16)
            .padding(0)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(2)
            .onClick(() => {
              if (this.value + this.step <= this.max) {
                this.value += this.step
              }
            })
            
            Button() {
              Text('↓')
                .fontSize(9)
                .fontColor(this.resolveTheme().textColor)
            }
            .type(ButtonType.Normal)
            .width(16)
            .height(16)
            .padding(0)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(2)
            .onClick(() => {
              if (this.value - this.step >= this.min) {
                this.value -= this.step
              }
            })
          }
          
          // 输入框
          NumericInput({ value: $value, min: this.min, max: this.max, step: this.step })
            .width(this.inputWidth)
            .height(this.inputHeight)
          
          // 右侧按钮（↑和↓）
          Column({ space: 1 }) {
            Button() {
              Text('↑')
                .fontSize(9)
                .fontColor(this.resolveTheme().textColor)
            }
            .type(ButtonType.Normal)
            .width(16)
            .height(16)
            .padding(0)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(2)
            .onClick(() => {
              if (this.value + this.step <= this.max) {
                this.value += this.step
              }
            })
            
            Button() {
              Text('↓')
                .fontSize(9)
                .fontColor(this.resolveTheme().textColor)
            }
            .type(ButtonType.Normal)
            .width(16)
            .height(16)
            .padding(0)
            .backgroundColor('#F5F5F5')
            .border({ width: 1, color: '#CCCCCC' })
            .borderRadius(2)
            .onClick(() => {
              if (this.value - this.step >= this.min) {
                this.value -= this.step
              }
            })
          }
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        
        // 底部按钮（↑和↓）
        Row({ space: 1 }) {
          Button() {
            Text('↑')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value + this.step <= this.max) {
              this.value += this.step
            }
          })
          
          Button() {
            Text('↓')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value - this.step >= this.min) {
              this.value -= this.step
            }
          })
        }
        .margin({ top: 2 })
        .justifyContent(FlexAlign.Center)
      } else {
        // 单按钮模式：每个方向一个按钮（↑↓←→）
        // 顶部按钮（↑）
        Button() {
          Text('↑')
            .fontSize(9)
            .fontColor(this.resolveTheme().textColor)
        }
        .type(ButtonType.Normal)
        .width(16)
        .height(16)
        .padding(0)
        .backgroundColor('#F5F5F5')
        .border({ width: 1, color: '#CCCCCC' })
        .borderRadius(2)
        .margin({ bottom: 2 })
        .onClick(() => {
          if (this.value + this.step <= this.max) {
            this.value += this.step
          }
        })
        
        // 中间：左侧按钮 + 输入框 + 右侧按钮
        Row({ space: 2 }) {
          // 左侧按钮（←）
          Button() {
            Text('←')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value - this.step >= this.min) {
              this.value -= this.step
            }
          })
          
          // 输入框
          NumericInput({ value: $value, min: this.min, max: this.max, step: this.step })
            .width(this.inputWidth)
            .height(this.inputHeight)
          
          // 右侧按钮（→）
          Button() {
            Text('→')
              .fontSize(9)
              .fontColor(this.resolveTheme().textColor)
          }
          .type(ButtonType.Normal)
          .width(16)
          .height(16)
          .padding(0)
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#CCCCCC' })
          .borderRadius(2)
          .onClick(() => {
            if (this.value + this.step <= this.max) {
              this.value += this.step
            }
          })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        
        // 底部按钮（↓）
        Button() {
          Text('↓')
            .fontSize(9)
            .fontColor(this.resolveTheme().textColor)
        }
        .type(ButtonType.Normal)
        .width(16)
        .height(16)
        .padding(0)
        .backgroundColor('#F5F5F5')
        .border({ width: 1, color: '#CCCCCC' })
        .borderRadius(2)
        .margin({ top: 2 })
        .onClick(() => {
          if (this.value - this.step >= this.min) {
            this.value -= this.step
          }
        })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}

