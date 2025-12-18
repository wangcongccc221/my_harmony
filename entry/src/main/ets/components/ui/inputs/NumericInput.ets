import { OmniThemeManager } from '../../../utils/theme/OmniThemeManager'

@Component
export struct NumericInput {
  @Link value: number
  @Prop min: number = 0
  @Prop max: number = 999
  @Prop step: number = 1

  build() {
    Row() {
      // 输入框
      TextInput({ text: this.value.toString() })
        .type(InputType.Number)
        .height('100%')
        .layoutWeight(1)
        .borderRadius({ topLeft: 4, bottomLeft: 4, topRight: 0, bottomRight: 0 })
        .border({ width: 1, color: '#D1D5DB' }) // Gray-300
        .padding({ left: 8, right: 8, top: 0, bottom: 0 })
        .fontSize(14)
        .onChange((val) => {
          let num = parseInt(val)
          if (isNaN(num)) return
          // 限制范围
          if (num < this.min) num = this.min
          if (num > this.max) num = this.max
          this.value = num
        })

      // 上下按钮区域
      Column() {
        // 上按钮
        Button() {
          Text('▲').fontSize(8).fontColor('#6B7280') // Gray-500
        }
        .type(ButtonType.Normal)
        .backgroundColor('#F3F4F6') // Gray-100
        .width(20)
        .height('50%')
        .border({ width: { top: 1, right: 1, bottom: 0, left: 0 }, color: '#D1D5DB' })
        .borderRadius({ topRight: 4 })
        .onClick(() => {
          if (this.value + this.step <= this.max) {
            this.value += this.step
          }
        })

        // 下按钮
        Button() {
          Text('▼').fontSize(8).fontColor('#6B7280') // Gray-500
        }
        .type(ButtonType.Normal)
        .backgroundColor('#F3F4F6') // Gray-100
        .width(20)
        .height('50%')
        .border({ width: { top: 1, right: 1, bottom: 1, left: 0 }, color: '#D1D5DB' })
        .borderRadius({ bottomRight: 4 })
        .onClick(() => {
          if (this.value - this.step >= this.min) {
            this.value -= this.step
          }
        })
      }
      .width(20)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
