/**
 * 紧凑型FSM切换组件 - 专为顶部状态栏设计
 * 采用长椭圆形卡片容器，内部椭圆形选项按钮，带滑动指示器
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

@Component
export struct CompactFsmToggle {
  // @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1' // 移除旧的 Prop 定义，因为下面重新定义了带 @Watch 的
  onFSMChange?: (fsm: 'FSM1' | 'FSM2') => void
  
  // 主题变化监听
  @StorageLink(OMNI_THEME_KEY) @Watch('onThemeChange') consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  @StorageLink(OMNI_THEME_VERSION_KEY) @Watch('onThemeChange') themeVersion: number = 0

  // 滑块位置状态
  @State private sliderOffset: number = 4 // 初始位置修正为 4 (内边距)
  
  // 尺寸常量定义 (适配 180x44 的设计)
  private readonly containerWidth: number = 180
  private readonly containerHeight: number = 44
  private readonly sliderWidth: number = 86 // (180 - 4*2) / 2 = 86
  private readonly sliderHeight: number = 36 // 44 - 4*2 = 36
  private readonly containerPadding: number = 4

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
      // 右侧位置 = 总宽度 - 内边距 - 滑块宽度
      // 或者 = 左内边距 + 滑块宽度 + 间距(0)
      // 这里设计是紧挨着的两块区域，所以 offset = 180 - 4 - 86 = 90
      return this.containerWidth - this.containerPadding - this.sliderWidth
    }
  }

  // 处理切换
  private handleToggle(fsm: 'FSM1' | 'FSM2'): void {
    if (fsm === this.selectedFSM) return

    // 1. 立即触发回调（让父组件更新状态）
    if (this.onFSMChange) {
      this.onFSMChange(fsm)
    }

    // 2. 立即计算并启动动画（不等待父组件的 props 更新）
    // 这样可以消除“等待状态回传”造成的视觉延迟
    const targetOffset = fsm === 'FSM1' ? 
      this.containerPadding : 
      (this.containerWidth - this.containerPadding - this.sliderWidth)

    animateTo({
      duration: 300,
      curve: Curve.Friction, // 改用 Friction 曲线，这通常比 EaseOut 更有“跟手”的物理感
    }, () => {
      this.sliderOffset = targetOffset
    })
  }
  
  aboutToAppear(): void {
    // 初始化滑块位置
    this.sliderOffset = this.calculateSliderOffset()
  }

  // 监听 selectedFSM 变化，用于外部（非点击）触发的状态变更同步
  @Watch('onSelectedFSMChange') @Prop selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'

  onSelectedFSMChange() {
    // 只有当内部状态和外部状态不一致时才执行动画（防止点击触发的动画被覆盖）
    const targetOffset = this.calculateSliderOffset()
    if (Math.abs(this.sliderOffset - targetOffset) > 1) { 
      animateTo({
        duration: 300,
        curve: Curve.Friction
      }, () => {
        this.sliderOffset = targetOffset
      })
    }
  }

  build() {
    Stack() {
      // 1. 容器背景（白色卡片 + 阴影）
      Row()
        .width(this.containerWidth)
        .height(this.containerHeight)
        .backgroundColor('#FFFFFF') // 固定白色背景
        .borderRadius(this.containerHeight / 2)
        .shadow({ 
          radius: 12, 
          color: 'rgba(0, 0, 0, 0.1)', 
          offsetX: 0, 
          offsetY: 4 
        })

      // 2. 滑动渐变背景（滑块）
      Row()
        .width(this.sliderWidth)
        .height(this.sliderHeight)
        .borderRadius(this.sliderHeight / 2)
        .linearGradient({ 
          angle: 90, 
          colors: [
            ['#3B82F6', 0], // 蓝色起始
            ['#22D3EE', 1]  // 青色结束
          ] 
        })
        .position({ 
          x: this.sliderOffset, 
          y: this.containerPadding 
        })

      // 3. 按钮文字层（透明点击区域）
      Row() {
        // FSM1 按钮
        Text('FSM1')
          .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedFSM === 'FSM1' ? '#FFFFFF' : (this.getCurrentTheme().subTextColor ?? '#6B7280')) // 选中白字，未选中主题次要色
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .onClick(() => this.handleToggle('FSM1'))

        // FSM2 按钮
        Text('FSM2')
          .fontSize(this.getCurrentTheme().fontLevel4 ?? 18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedFSM === 'FSM2' ? '#FFFFFF' : (this.getCurrentTheme().subTextColor ?? '#6B7280'))
          .width('50%')
          .height('100%')
          .textAlign(TextAlign.Center)
          .onClick(() => this.handleToggle('FSM2'))
      }
      .width(this.containerWidth)
      .height(this.containerHeight)
    }
    .width(this.containerWidth)
    .height(this.containerHeight)
  }
}
