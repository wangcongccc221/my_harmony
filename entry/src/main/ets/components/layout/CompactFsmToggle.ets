/**
 * 紧凑型FSM切换组件 - 专为顶部状态栏设计
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

@Component
export struct CompactFsmToggle {
  @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void
  
  // 主题变化监听
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('CompactFsmToggle: 主题已变化，重新渲染')
  }

  build() {
    Row() {
      // FSM1按钮
      Button('FSM1')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedFSM === 'FSM1' ? 
          (this.getCurrentTheme().fsmToggleButtonActiveTextColor || '#FFFFFF') : 
          (this.getCurrentTheme().fsmToggleButtonInactiveTextColor || this.getCurrentTheme().textColor))
        .backgroundColor(this.selectedFSM === 'FSM1' ? 
          (this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary) : 
          (this.getCurrentTheme().fsmToggleButtonInactiveBg === 'transparent' ? Color.Transparent : 
           (this.getCurrentTheme().fsmToggleButtonInactiveBg || Color.Transparent)))
        .border({ 
          width: 1, 
          color: this.selectedFSM === 'FSM1' ? 
            (this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary) : 
            (this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor)
        })
        .borderRadius(0)
        .borderRadius({ topLeft: 4, bottomLeft: 4, topRight: 0, bottomRight: 0 })
        .padding({ left: 24, right: 24, top: 4, bottom: 4 })
        .onClick(() => { 
          if (this.onFSMChange) { 
            this.onFSMChange('FSM1') 
          } 
        })

      // FSM2按钮
      Button('FSM2')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedFSM === 'FSM2' ? 
          (this.getCurrentTheme().fsmToggleButtonActiveTextColor || '#FFFFFF') : 
          (this.getCurrentTheme().fsmToggleButtonInactiveTextColor || this.getCurrentTheme().textColor))
        .backgroundColor(this.selectedFSM === 'FSM2' ? 
          (this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary) : 
          (this.getCurrentTheme().fsmToggleButtonInactiveBg === 'transparent' ? Color.Transparent : 
           (this.getCurrentTheme().fsmToggleButtonInactiveBg || Color.Transparent)))
        .border({ 
          width: 1, 
          color: this.selectedFSM === 'FSM2' ? 
            (this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary) : 
            (this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor)
        })
        .borderRadius(0)
        .borderRadius({ topLeft: 0, bottomLeft: 0, topRight: 4, bottomRight: 4 })
        .padding({ left: 24, right: 24, top: 4, bottom: 4 })
        .onClick(() => { 
          if (this.onFSMChange) { 
            this.onFSMChange('FSM2') 
          } 
        })
    }
    .backgroundColor(this.getCurrentTheme().fsmToggleContainerBg || this.getCurrentTheme().backgroundColor)
    .borderRadius(4)
    .border({ width: 1, color: this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor })
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
    .alignItems(VerticalAlign.Center)
    .alignSelf(ItemAlign.Start)
    .width('auto')
    .height('auto')
  }
}
