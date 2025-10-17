/**
 * 对话框按钮组件
 * 功能：统一的对话框底部按钮样式
 * 用途：可复用的对话框按钮控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

@Component
export struct DialogButtons {
  @Prop confirmText: string = '确认'  // 确认按钮文字
  @Prop cancelText: string = '取消'  // 取消按钮文字
  @Prop showCancel: boolean = true  // 是否显示取消按钮
  @Prop confirmDisabled: boolean = false  // 确认按钮是否禁用
  
  onConfirm?: () => void  // 确认回调
  onCancel?: () => void  // 取消回调

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      Blank().layoutWeight(1)
      
      Row() {
        if (this.showCancel) {
          Button(this.cancelText)
            .fontSize(18)  // 取消按钮字体调大到18px
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(8)
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .onClick(() => {
              if (this.onCancel) {
                this.onCancel()
              }
            })
        }

        Button(this.confirmText)
          .fontSize(18)  // 确认按钮字体调大到18px
          .fontColor(Color.White)
          .backgroundColor(this.confirmDisabled ? 
            this.getCurrentTheme().subTextColor : 
            this.getCurrentTheme().primary)
          .borderRadius(8)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .margin({ left: this.showCancel ? 10 : 0 })
          .enabled(!this.confirmDisabled)
          .onClick(() => {
            if (this.onConfirm && !this.confirmDisabled) {
              this.onConfirm()
            }
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 20, right: 20, top: 0, bottom: 20 })
  }
}
