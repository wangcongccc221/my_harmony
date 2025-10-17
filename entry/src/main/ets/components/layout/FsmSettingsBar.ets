/**
 * 顶部FSM + 设置开关 合并组件（独立文件，位于 components/layout）
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { SwitchControl } from '../ui/SwitchControl'

@Component
export default struct FsmSettingsBar {
  @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void

  @Link setting1Enabled: boolean
  @Link setting2Enabled: boolean
  @Link setting3Enabled: boolean
  @Link setting4Enabled: boolean
  onSetting1Change?: () => void
  onSetting2Change?: () => void
  onSetting3Change?: () => void
  onSetting4Change?: () => void

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Row() {
      // FSM切换按钮卡片
      Row() {
        Button('FSM1')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM1' ? '#FFFFFF' : '#666666')
          .backgroundColor(this.selectedFSM === 'FSM1' ? '#EA7A10' : '#E0E0E0')
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .margin({ right: 8 })
          .onClick(() => { if (this.onFSMChange) { this.onFSMChange('FSM1') } })

        Button('FSM2')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM2' ? '#FFFFFF' : '#666666')
          .backgroundColor(this.selectedFSM === 'FSM2' ? '#D4A574' : '#E0E0E0')
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => { if (this.onFSMChange) { this.onFSMChange('FSM2') } })
      }
       .backgroundColor(this.getCurrentTheme().surfaceColor)
       .borderRadius(16)
       .padding({ left: 8, right: 8, top: 4, bottom: 4 })
       .border({ width: 1, color: this.getCurrentTheme().borderColor })
       .shadow({ radius: 2, color: 'rgba(0,0,0,0.08)', offsetY: 1 })
       .alignItems(VerticalAlign.Center)
       .alignSelf(ItemAlign.Start)
       .width('10%')
       .height('12%')

      Row() {
        SwitchControl({ label: '设置1', isEnabled: $setting1Enabled, onToggle: () => { if (this.onSetting1Change) { this.onSetting1Change() } } })
        SwitchControl({ label: '设置2', isEnabled: $setting2Enabled, onToggle: () => { if (this.onSetting2Change) { this.onSetting2Change() } } })
        SwitchControl({ label: '设置3', isEnabled: $setting3Enabled, onToggle: () => { if (this.onSetting3Change) { this.onSetting3Change() } } })
        SwitchControl({ label: '设置4', isEnabled: $setting4Enabled, onToggle: () => { if (this.onSetting4Change) { this.onSetting4Change() } } })
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
  }
}


