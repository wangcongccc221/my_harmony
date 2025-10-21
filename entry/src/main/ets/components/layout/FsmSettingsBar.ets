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

  /**
   * 检查是否为最后一个开启的设置
   * @param currentIndex 当前设置的索引
   * @returns 是否为最后一个开启的设置
   */
  private isLastEnabledSetting(currentIndex: number): boolean {
    const settings = [this.setting1Enabled, this.setting2Enabled, this.setting3Enabled, this.setting4Enabled]
    const enabledCount = settings.filter(enabled => enabled).length
    
    // 如果只有一个设置开启，且当前设置是开启的，则不能关闭
    return enabledCount === 1 && settings[currentIndex]
  }

  build() {
    Row() {
      // FSM切换按钮组（联动感设计）
      Row() {
        Button('FSM1')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM1' ? '#FFFFFF' : '#666666')
          .backgroundColor(this.selectedFSM === 'FSM1' ? '#EA7A10' : Color.Transparent)
          .border({ 
            width: 1, 
            color: this.selectedFSM === 'FSM1' ? '#EA7A10' : this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .borderRadius({ topLeft: 8, bottomLeft: 8, topRight: 0, bottomRight: 0 })
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => { if (this.onFSMChange) { this.onFSMChange('FSM1') } })

        Button('FSM2')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM2' ? '#FFFFFF' : '#666666')
          .backgroundColor(this.selectedFSM === 'FSM2' ? '#D4A574' : Color.Transparent)
          .border({ 
            width: 1, 
            color: this.selectedFSM === 'FSM2' ? '#D4A574' : this.getCurrentTheme().borderColor 
          })
          .borderRadius(0)
          .borderRadius({ topLeft: 0, bottomLeft: 0, topRight: 8, bottomRight: 8 })
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => { if (this.onFSMChange) { this.onFSMChange('FSM2') } })
      }
       .backgroundColor(this.getCurrentTheme().surfaceColor)
       .borderRadius(8)
       .border({ width: 1, color: this.getCurrentTheme().borderColor })
       .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
       .alignItems(VerticalAlign.Center)
       .alignSelf(ItemAlign.Start)
       .width('auto')
       .height('auto')

      Row() {
        SwitchControl({ 
          label: '设置1', 
          isEnabled: $setting1Enabled, 
          isLastEnabled: this.isLastEnabledSetting(0),
          onToggle: () => { if (this.onSetting1Change) { this.onSetting1Change() } } 
        })
        SwitchControl({ 
          label: '设置2', 
          isEnabled: $setting2Enabled, 
          isLastEnabled: this.isLastEnabledSetting(1),
          onToggle: () => { if (this.onSetting2Change) { this.onSetting2Change() } } 
        })
        SwitchControl({ 
          label: '设置3', 
          isEnabled: $setting3Enabled, 
          isLastEnabled: this.isLastEnabledSetting(2),
          onToggle: () => { if (this.onSetting3Change) { this.onSetting3Change() } } 
        })
        SwitchControl({ 
          label: '设置4', 
          isEnabled: $setting4Enabled, 
          isLastEnabled: this.isLastEnabledSetting(3),
          onToggle: () => { if (this.onSetting4Change) { this.onSetting4Change() } } 
        })
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
  }
}


