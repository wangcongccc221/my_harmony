/**
 * 紧凑型FSM切换组件 - 专为顶部状态栏设计
 * 采用长椭圆形卡片容器，内部椭圆形选项按钮，带滑动指示器
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

  // 滑块位置状态
  @State private sliderOffset: number = 0
  private readonly itemWidth: number = 96 // 每个选项的宽度（根据220px总宽度计算：(220-20-8)/2=96，其中20是左右padding各10px）
  private readonly itemSpacing: number = 8 // 选项之间的间距
  private readonly containerPadding: number = 10 // 容器内边距

  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.consumedTheme
  }

  // 监听主题变化
  onThemeChange(): void {
    console.log('CompactFsmToggle: 主题已变化，重新渲染')
  }

  // 计算滑块位置
  private calculateSliderOffset(): number {
    if (this.selectedFSM === 'FSM1') {
      return this.containerPadding
    } else {
      return this.containerPadding + this.itemWidth + this.itemSpacing
    }
  }

  // 处理切换
  private handleToggle(fsm: 'FSM1' | 'FSM2'): void {
    console.log('handleToggle called with fsm:', fsm, 'current selectedFSM:', this.selectedFSM)
    // 如果点击的是当前已选中的，直接返回
    if (fsm === this.selectedFSM) {
      console.log('Already selected, ignoring')
      return
    }
    if (this.onFSMChange) {
      console.log('Calling onFSMChange with:', fsm)
      this.onFSMChange(fsm)
    }
    // 根据目标FSM直接计算滑块位置（不依赖this.selectedFSM，因为它是@Prop可能还没更新）
    const targetOffset = fsm === 'FSM1' ? this.containerPadding : (this.containerPadding + this.itemWidth + this.itemSpacing)
    console.log('Target offset:', targetOffset)
    // 更新滑块位置（动画）
    animateTo({
      duration: 300,
      curve: Curve.EaseInOut
    }, () => {
      this.sliderOffset = targetOffset
    })
  }

  aboutToAppear(): void {
    // 初始化滑块位置
    this.sliderOffset = this.calculateSliderOffset()
  }

  aboutToUpdate(): void {
    // 当selectedFSM变化时更新滑块位置（使用动画）
    const newOffset = this.calculateSliderOffset()
    if (this.sliderOffset !== newOffset) {
      animateTo({
        duration: 300,
        curve: Curve.EaseInOut
      }, () => {
        this.sliderOffset = newOffset
      })
    }
  }

  build() {
    Stack() {
      // 底层：选项按钮容器
      Row() {
        // FSM1选项
        Button('FSM1')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM1' ? 
            (this.getCurrentTheme().fsmToggleButtonActiveTextColor || '#FFFFFF') : 
            (this.getCurrentTheme().fsmToggleButtonInactiveTextColor || this.getCurrentTheme().textColor))
          .backgroundColor(Color.Transparent)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor
          })
          .borderRadius(60)
          .width(this.itemWidth)
          .height(50)
          .zIndex(10) // 确保按钮在滑块之上
          .onClick(() => {
            console.log('FSM1 clicked, current selectedFSM:', this.selectedFSM)
            this.handleToggle('FSM1')
          })

        // 选项间距
        Blank()
          .width(this.itemSpacing)

        // FSM2选项
        Button('FSM2')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedFSM === 'FSM2' ? 
            (this.getCurrentTheme().fsmToggleButtonActiveTextColor || '#FFFFFF') : 
            (this.getCurrentTheme().fsmToggleButtonInactiveTextColor || this.getCurrentTheme().textColor))
          .backgroundColor(Color.Transparent)
          .border({ 
            width: 1, 
            color: this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor
          })
          .borderRadius(60)
          .width(this.itemWidth)
          .height(50)
          .zIndex(10) // 确保按钮在滑块之上
          .onClick(() => {
            console.log('FSM2 clicked, current selectedFSM:', this.selectedFSM)
            this.handleToggle('FSM2')
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(this.containerPadding)

      // 顶层：滑动指示器（不拦截点击事件）
      Row() {
        Blank()
          .width(this.sliderOffset)
          .hitTestBehavior(HitTestMode.None)
        
        // 滑块指示器
        Row() {
          Text(this.selectedFSM)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().fsmToggleButtonActiveTextColor || '#FFFFFF')
        }
        .width(this.itemWidth)
        .height(50)
        .borderRadius(60)
        .border({
          width: 1,
          color: this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary
        })
        .linearGradient({
          angle: 90,
          colors: [
            [this.getCurrentTheme().fsmToggleButtonActiveBg || this.getCurrentTheme().primary, 0.0],
            [this.getCurrentTheme().primary || '#007AFF', 1.0]
          ]
        })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .zIndex(1) // 滑块在按钮下方
        .hitTestBehavior(HitTestMode.None) // 滑块指示器也不拦截点击
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .hitTestBehavior(HitTestMode.None) // 不拦截点击事件，让底层按钮可以点击
    }
    .width(220)
    .height(70)
    .backgroundColor(this.getCurrentTheme().fsmToggleContainerBg || this.getCurrentTheme().backgroundColor)
    .borderRadius(60)
    .border({ 
      width: 1, 
      color: this.getCurrentTheme().fsmToggleButtonBorderColor || this.getCurrentTheme().borderColor 
    })
    .shadow({ radius: 2, color: 'rgba(0,0,0,0.1)', offsetY: 1 })
    .alignSelf(ItemAlign.Start)
  }
}
