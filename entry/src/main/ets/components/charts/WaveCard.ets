@Component
export struct WaveCard {
  @Prop amplitude: number = 15
  @Prop frequency: number = 0.02
  @Prop speed: number = 0.02
  @Prop waveHeightPercent: number = 70  // 波浪图高度百分比（默认70%）
  @Prop baselinePercent: number = 50    // 波浪基准位置百分比（默认50%，即中间位置）
  @Prop gradientLeft: string = 'rgba(52, 152, 219, 0.7)'
  @Prop gradientMid: string = 'rgba(41, 128, 185, 0.8)'
  @Prop gradientRight: string = 'rgba(52, 152, 219, 0.7)'
  @Prop cardBackground: string | Color = Color.Transparent

  @State private phase: number = 0
  @State private canvasWidth: number = 0
  @State private canvasHeight: number = 0

  private animationId: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  aboutToAppear() {
    this.startAnimation()
  }

  aboutToDisappear() {
    if (this.animationId) {
      clearInterval(this.animationId)
      this.animationId = 0
    }
  }

  private startAnimation() {
    if (this.animationId) {
      clearInterval(this.animationId)
    }
    this.animationId = setInterval(() => {
      this.phase += this.speed
      this.drawWave()
    }, 16)
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor(this.cardBackground as Color)
      .onReady(() => this.drawWave())
      .onAreaChange((oldRect, newRect) => {
        const w: number = Number.parseFloat(String(newRect.width))
        const h: number = Number.parseFloat(String(newRect.height))
        const cw: number = Number.isFinite(w) && w > 0 ? Math.floor(w) : 0
        const ch: number = Number.isFinite(h) && h > 0 ? Math.floor(h) : 0
        if (cw !== this.canvasWidth || ch !== this.canvasHeight) {
          this.canvasWidth = cw
          this.canvasHeight = ch
          this.drawWave()
        }
      })
  }

  private drawWave() {
    const width = this.canvasWidth || 1
    const height = this.canvasHeight || 1
    
    // 计算波浪图从底部开始的实际高度
    const waveHeight = height * (this.waveHeightPercent / 100)
    
    // 计算波浪基准位置：从底部开始，在波浪图内部的位置
    const centerY = height - waveHeight + (waveHeight * (this.baselinePercent / 100))

    this.context.clearRect(0, 0, width, height)

    const gradient = this.context.createLinearGradient(0, 0, width, 0)
    gradient.addColorStop(0, this.gradientLeft)
    gradient.addColorStop(0.5, this.gradientMid)
    gradient.addColorStop(1, this.gradientRight)

    this.context.fillStyle = gradient
    this.context.beginPath()
    this.context.moveTo(0, centerY)

    for (let x = 0; x <= width; x += 1) {
      const y = centerY + Math.sin(x * this.frequency + this.phase) * this.amplitude
      this.context.lineTo(x, y)
    }

    this.context.lineTo(width, height)
    this.context.lineTo(0, height)
    this.context.closePath()
    this.context.fill()
  }
}