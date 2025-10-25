/**
 * 紧凑型FSM切换组件 - 专为顶部状态栏设计
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'

@Component
export struct CompactFsmToggle {
  @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      // FSM1按钮
      Button('FSM1')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedFSM === 'FSM1' ? '#FFFFFF' : this.getCurrentTheme().textColor)
        .backgroundColor(this.selectedFSM === 'FSM1' ? '#EA7A10' : Color.Transparent)
        .border({ 
          width: 1, 
          color: this.selectedFSM === 'FSM1' ? '#EA7A10' : this.getCurrentTheme().borderColor 
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
        .fontColor(this.selectedFSM === 'FSM2' ? '#FFFFFF' : this.getCurrentTheme().textColor)
        .backgroundColor(this.selectedFSM === 'FSM2' ? '#D4A574' : Color.Transparent)
        .border({ 
          width: 1, 
          color: this.selectedFSM === 'FSM2' ? '#D4A574' : this.getCurrentTheme().borderColor 
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
    .backgroundColor(this.getCurrentTheme().surfaceColor)
    .borderRadius(4)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
    .alignItems(VerticalAlign.Center)
    .alignSelf(ItemAlign.Start)
    .width('auto')
    .height('auto')
  }
}
