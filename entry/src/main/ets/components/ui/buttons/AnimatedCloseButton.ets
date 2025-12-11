@Component
export struct AnimatedCloseButton {
  @State isHovered: boolean = false
  onClickHandler: () => void = () => {}

  build() {
    Button() {
      Stack() {
        // 4个绿色方块 (Spans)
        // Span 1: bottom-12 -> bottom-9 (moves up)
        // Vue: top-12 -> top-9. Since button is h-12, top-12 is fully below. top-9 is partial.
        // Let's use Position
        
        // Span 1: Initial top: 48, left: 0. Hover top: 36.
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor('#22c55e') // green-500
          .rotate({ angle: 45 })
          .position({ x: 0, y: this.isHovered ? 36 : 48 })
          .animation({ duration: 500, curve: Curve.EaseInOut })

        // Span 2: Initial top: 0, left: 48. Hover left: 36.
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor('#22c55e') // green-500
          .rotate({ angle: 45 })
          .position({ x: this.isHovered ? 36 : 48, y: 0 })
          .animation({ duration: 500, curve: Curve.EaseInOut })

        // Span 3: Initial top: 0, right: 48. Hover right: 36.
        // In ArkTS position is x/y relative to top-left.
        // If width is 48. right: 48 means x = -48. right: 36 means x = -36.
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor('#22c55e') // green-500
          .rotate({ angle: 45 })
          .position({ x: this.isHovered ? -36 : -48, y: 0 })
          .animation({ duration: 500, curve: Curve.EaseInOut })

        // Span 4: Initial bottom: 48, right: 0. Hover bottom: 36.
        // bottom: 48 means y = -48. bottom: 36 means y = -36.
        Stack()
          .width('100%')
          .height('100%')
          .backgroundColor('#22c55e') // green-500
          .rotate({ angle: 45 })
          .position({ x: 0, y: this.isHovered ? -36 : -48 })
          .animation({ duration: 500, curve: Curve.EaseInOut })

        // Text "×"
        Text('×')
          .fontSize(30) // text-3xl approx 30px
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Regular) // font-Manrope usually regular or medium
          .scale({ x: this.isHovered ? 0 : 1, y: this.isHovered ? 0 : 1 })
          .animation({ duration: 500, curve: Curve.EaseInOut })
          .zIndex(10)
      }
      .width('100%')
      .height('100%')
    }
    .width(48) // w-12
    .height(48) // h-12
    .backgroundColor(Color.Transparent)
    .borderWidth(2)
    .borderColor(this.isHovered ? '#22c55e' : Color.Black)
    .animation({ duration: 500, curve: Curve.EaseInOut }) // Border color animation
    .clip(true) // overflow-hidden
    .type(ButtonType.Normal) // Reset default button style
    .borderRadius(0) // Vue code has no border-radius mentioned for the button itself? 
    // Wait, Vue code says `class="... border-2 border-black ..."` no rounded class.
    // But the original ArkTS code had a rounded button. The user asked to "replace this X... convert Vue to Harmony".
    // I should follow the Vue style (square-ish) but maybe keep it nice. The Vue code has no `rounded` class.
    .onClick(() => {
      this.onClickHandler()
    })
    .onHover((isHover: boolean) => {
      // animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
        this.isHovered = isHover
      // })
    })
  }
}
