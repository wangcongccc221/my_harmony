@Component
export struct ThreeDButton {
  @Prop text: string
  @Prop isSelected: boolean
  onClickCallback?: () => void

  @State isHovered: boolean = false
  @State isPressed: boolean = false

  build() {
    Button() {
      Text(this.text)
        .fontSize(17)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
    }
    .width(140) // px-6 ~ 24px * 2 + text width. Let's set a fixed width or auto
    .height(48) // py-2 ~ 8px * 2 + text height
    .type(ButtonType.Normal)
    .borderRadius(8) // rounded-lg
    .backgroundColor('#3b82f6') // bg-blue-500
    // Border bottom logic:
    // Normal: border-b-[4px] border-blue-600 (#2563eb)
    // Hover: border-b-[6px]
    // Active: border-b-[2px]
    .border({
      width: { 
        bottom: this.isPressed ? 2 : (this.isHovered ? 6 : 4),
        top: 0, left: 0, right: 0
      },
      color: '#2563eb', // border-blue-600
      style: BorderStyle.Solid
    })
    // Translate Y logic:
    // Hover: -1px
    // Active: 2px
    .translate({ 
      y: this.isPressed ? 2 : (this.isHovered ? -1 : 0) 
    })
    // Brightness logic (simulated with opacity or color change, here using color change since brightness filter is not standard on all components)
    // Hover: brightness-110 (lighter)
    // Active: brightness-90 (darker)
    .backgroundColor(
      this.isPressed ? '#1d4ed8' : // darker blue for active
      (this.isHovered ? '#60a5fa' : '#3b82f6') // lighter blue for hover, normal blue
    )
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
    // Add visual indicator for selection if needed (the user didn't specify, but usually tabs need one)
    // The prompt is "Button", so maybe just the button style itself is enough.
    // However, for a TabBar, we usually need to distinguish the selected one.
    // Let's assume the "Selected" state matches the "Active" or specific style, or just keep it simple as requested.
    // If selected, maybe keep it pressed or different color? 
    // The user just gave a button template. I'll stick to the template. 
    // But since it's replacing tabs, I should probably highlight the selected tab.
    // Let's make the selected tab look "Active" (pressed down) permanently? Or just different color.
    // I'll make the selected tab have a different background color to distinguish it.
    .backgroundColor(
      this.isSelected ? '#2563eb' : // Selected: keep it slightly darker/border color
      (this.isPressed ? '#1d4ed8' : 
      (this.isHovered ? '#60a5fa' : '#3b82f6'))
    )
    // If selected, maybe reduce the border bottom to simulate being "pressed in" or active?
    // Let's try: Selected = border-b-[2px] + translate y 2px (permanently pressed)
    .border({
      width: { 
        bottom: (this.isPressed || this.isSelected) ? 2 : (this.isHovered ? 6 : 4),
        top: 0, left: 0, right: 0
      },
      color: '#2563eb',
      style: BorderStyle.Solid
    })
    .translate({ 
      y: (this.isPressed || this.isSelected) ? 2 : (this.isHovered ? -1 : 0) 
    })
  }
}
