import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'

@Component
export struct ThreeDButton {
  @Prop text: string
  @Prop isSelected: boolean
  @Prop buttonWidth: number | string = 140 // 支持自定义宽度
  @Prop buttonHeight: number = 48 // 支持自定义高度
  @Prop fontSize: number = 18 // 支持自定义字体大小 (默认为 Level 4 - 18px)
  onClickCallback?: () => void

  @State isHovered: boolean = false
  @State isPressed: boolean = false

  // 获取当前主题
  private getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  build() {
    Button() {
      Text(this.text)
        // 严格遵循用户设计规范：选中用 Level 3 (24px)，未选中用 Level 4 (18px)
        .fontSize(this.isSelected ? (this.getCurrentTheme().fontLevel3 ?? 24) : this.fontSize)
        .fontColor(this.isSelected ? Color.White : this.getCurrentTheme().textColor)
        .fontWeight(this.isSelected ? (this.getCurrentTheme().fontWeightBold ?? FontWeight.Bold) : (this.getCurrentTheme().fontWeightMedium ?? FontWeight.Medium))
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.None }) // 支持换行
        .maxLines(2)
    }
    // 保持固定尺寸，使用scale缩放实现更自然的变大效果
    .width(typeof this.buttonWidth === 'string' ? this.buttonWidth : this.buttonWidth)
    .height(this.buttonHeight)
    // 选中状态：使用scale缩放（1.15倍），增强层次感，更明显
    .scale({ 
      x: this.isSelected ? 1.15 : 1.0, 
      y: this.isSelected ? 1.15 : 1.0
    })
    .type(ButtonType.Normal)
    .borderRadius(12)
    // 只有选中状态才使用渐变色+毛玻璃效果（参考"当前分选信息"标题的实现）
    .linearGradient(this.isSelected ? {
      angle: 135,
      colors: [
        [this.getCurrentTheme().primary, 0],
        [this.getCurrentTheme().primary, 0.5],
        [this.getCurrentTheme().primary + '88', 1]      // 增强渐变对比
      ]
    } : undefined)
    .backgroundColor(this.isSelected ? Color.Transparent : (this.getCurrentTheme().surfaceColor ?? '#FFFFFF'))
    // 毛玻璃效果（只有选中状态才有）
    .backdropBlur(this.isSelected ? 20 : 0)                                    // 背景模糊（毛玻璃效果）
    .blur(this.isSelected ? 3 : 0)                                             // 内容模糊（增强毛玻璃质感）
    // Border logic:
    // 选中状态：底部边框（白色半透明）
    // 未选中状态：全边框（主题边框色）
    .border(this.isSelected ? {
      width: { 
        bottom: (this.isPressed || this.isSelected) ? 2 : (this.isHovered ? 6 : 4),
        top: 0, left: 0, right: 0
      },
      color: 'rgba(255, 255, 255, 0.3)',
      style: BorderStyle.Solid
    } : {
      width: 1,
      color: this.getCurrentTheme().borderColor,
      style: BorderStyle.Solid
    })
    // Translate Y logic:
    // Hover: -1px
    // Active: 2px
    .translate({ 
      y: (this.isPressed || this.isSelected) ? 2 : (this.isHovered ? -1 : 0) 
    })
    // 添加阴影效果，增强立体感（只有选中状态才有阴影，多层阴影更明显）
    .shadow(this.isSelected ? {
      radius: 20,
      color: 'rgba(0, 0, 0, 0.25)',
      offsetX: 0,
      offsetY: 6
    } : undefined)
    .shadow(this.isSelected ? {
      radius: 10,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 3
    } : undefined)
    .animation({
      duration: 250, // transition-all duration approx
      curve: Curve.EaseInOut
    })
    .onClick(() => {
      if (this.onClickCallback) {
        this.onClickCallback()
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onHover((isHover: boolean) => {
      this.isHovered = isHover
    })
  }
}
