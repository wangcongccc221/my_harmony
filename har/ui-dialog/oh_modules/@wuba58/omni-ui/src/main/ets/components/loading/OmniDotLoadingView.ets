@Preview
@Component
export struct OmniDotLoadingView {
  @Prop noDataText: string = '到底啦~'
  @Link loading: boolean
  private WIDTH = 8
  private DURATION = 200
  private colorArray = [0xFFFF552E, 0xFF3E80F8, 0xFF53E7AE, 0xFFFFCE5A]
  private scalesArray = [
    [1.0, 0.8, 0.6, 0.4, 0.6, 0.8, 1.0],
    [0.8, 1.0, 0.8, 0.6, 0.4, 0.6, 0.8],
    [0.6, 0.8, 1.0, 0.8, 0.6, 0.4, 0.6],
    [0.4, 0.6, 0.8, 1.0, 0.8, 0.6, 0.4],
  ]
  private currentIndex: number = 0
  @State private scales: number[] = [1.0, 0.8, 0.6, 0.4]

  aboutToAppear() {
    this._animateTo()
  }

  _animateTo() {
    this.getUIContext().animateTo({
      curve: Curve.Linear,
      duration: this.DURATION,
      onFinish: () => {
        this._animateTo()
      }
    }, () => {
      this.currentIndex = (this.currentIndex + 1) % this.scalesArray[0].length
      this.scales = this.scalesArray.map(scaleGroup => scaleGroup[this.currentIndex])
    })
  }

  build() {
    if (this.loading) {
      Row({ space: 4 }) {
        ForEach(this.colorArray, (color: number, i) => {
          Circle({ width: this.WIDTH, height: this.WIDTH })
            .foregroundColor(color)
            .opacity(this.scales[i])
            .scale({ x: this.scales[i], y: this.scales[i] })
        })
      }
    } else {
      Text(this.noDataText)
    }
  }
}