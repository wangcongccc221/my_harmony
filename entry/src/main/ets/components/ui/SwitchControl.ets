/**
 * 开关控制组件
 * 功能：统一的开关控件样式和交互
 * 用途：可复用的开关控件
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { IBestSwitch } from '@ibestservices/ibest-ui'

@Component
export struct SwitchControl {
  @Prop label: string = ''  // 标签文字
  @Link isEnabled: boolean  // 开关状态（双向绑定）
  @Prop switchSize: number = 24  // 开关大小
  @Prop activeColor: string = '#EA7A10'  // 激活颜色
  @Prop inactiveColor: string = '#E0E0E0'  // 非激活颜色
  @Prop isLastEnabled: boolean = false  // 是否为最后一个开启的设置（用于阻止关闭）
  
  onToggle?: () => void  // 切换回调

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      Text(this.label)
        .fontSize(12)
        .fontColor(this.getCurrentTheme().textColor)
        .margin({ right: 8 })

      IBestSwitch({
        value: $isEnabled,
        switchSize: this.switchSize,
        activeColor: this.activeColor,
        inactiveColor: this.inactiveColor,
        onBeforeChange: (next: boolean) => {
          // 如果尝试关闭最后一个开启的设置，阻止操作
          if (!next && this.isLastEnabled) {
            console.log(`[SwitchControl] 无法关闭 ${this.label}，必须保持至少一个设置开启`)
            return Promise.resolve(false) // 阻止关闭
          }
          
          if (this.onToggle) {
            this.onToggle()
          }
          return Promise.resolve(true)
        }
      })
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: 12 })
  }
}
