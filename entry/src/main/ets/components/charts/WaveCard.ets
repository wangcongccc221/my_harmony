@Component
export struct WaveCard {
  @Prop amplitude: number = 10
  @Prop frequency: number = 0.01
  @Prop speed: number = 0.02
  @Prop waveHeightPercent: number = 70  // 波浪图高度百分比（默认70%）
  @Prop baselinePercent: number = 50    // 波浪基准位置百分比（默认50%，即中间位置）
  @Prop gradientLeft: string = 'rgba(52, 152, 219, 0.7)'
  @Prop gradientMid: string = 'rgba(41, 128, 185, 0.8)'
  @Prop gradientRight: string = 'rgba(52, 152, 219, 0.7)'
  @Prop cardBackground: string | Color = Color.Transparent

  @State private phase: number = 0  // 原来的实现：使用 @State，会触发UI重建
  @State private canvasWidth: number = 0
  @State private canvasHeight: number = 0

  private animationId: number = 0
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  // 优化版本（已注释）：
  // private phase: number = 0  // 不使用 @State，避免触发UI重建

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
    // 原来的实现：60fps（16ms间隔）
    this.animationId = setInterval(() => {
      this.phase += this.speed
      this.drawWave()
    }, 16)  // 原来的实现：60fps
    
    // 优化版本（已注释）：
    // // 优化：降低更新频率从16ms（60fps）到33ms（30fps），减少CPU占用
    // // 30fps对于波浪动画已经足够流畅，同时能显著减少卡顿
    // this.animationId = setInterval(() => {
    //   this.phase += this.speed
    //   this.drawWave()
    // }, 33)  // 从16ms改为33ms，降低到30fps
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
    
    // 计算波浪基准位置：让最高点刚好到达目标高度
    // 基准位置 = 目标高度 - 振幅，这样最高点就是目标高度
    const centerY = height - waveHeight + this.amplitude

    this.context.clearRect(0, 0, width, height)

    const gradient = this.context.createLinearGradient(0, 0, width, 0)
    gradient.addColorStop(0, this.gradientLeft)
    gradient.addColorStop(0.5, this.gradientMid)
    gradient.addColorStop(1, this.gradientRight)

    this.context.fillStyle = gradient
    this.context.beginPath()
    this.context.moveTo(0, centerY)

    // 原来的实现：每像素画一次（性能较低）
    for (let x = 0; x <= width; x += 1) {
      const y = centerY + Math.sin(x * this.frequency + this.phase) * this.amplitude
      this.context.lineTo(x, y)
    }

    this.context.lineTo(width, height)
    this.context.lineTo(0, height)
    this.context.closePath()
    this.context.fill()
    
    // 优化版本（已注释）：
    // // 如果画布尺寸无效，不绘制
    // if (width <= 0 || height <= 0) {
    //   return
    // }
    // 
    // // 性能优化：减少绘制点数量
    // // 原来每像素画一次，现在每2-3像素画一次，减少计算量
    // // 对于120px宽的卡片，从120次计算减少到40-60次，性能提升约50%
    // const step = width > 200 ? 3 : (width > 100 ? 2 : 1)  // 大卡片步长更大
    // 
    // for (let x = 0; x <= width; x += step) {
    //   const y = centerY + Math.sin(x * this.frequency + this.phase) * this.amplitude
    //   this.context.lineTo(x, y)
    // }
    //
    // // 确保最后一点连接到右边界
    // if (width % step !== 0) {
    //   const y = centerY + Math.sin(width * this.frequency + this.phase) * this.amplitude
    //   this.context.lineTo(width, y)
    // }
  }
}