import promptAction from '@ohos.promptAction'
import { display } from '@kit.ArkUI'

@Preview
@Component
export struct VideoView {
  @Prop config: VideoConfig
  videoController?: VideoController = new VideoController()
  @State private isPlaying: boolean = true
  @State private isMute: boolean = true
  @State private videoWidth: Length = 0
  @State private videoHeight: Length = 0

  aboutToAppear(): void {
    this.isPlaying = this.config.autoPlay ?? true
    this.isMute = this.config.isMute ?? true
    this.videoController?.start()

    if ((this.config.aspectRatio ?? -1) > 0) {
      this.videoWidth = px2vp(display.getDefaultDisplaySync().width)
      this.videoHeight = (this.videoWidth / (this.config.aspectRatio ?? 1))
    }
  }

  aboutToDisappear(): void {
    this.videoController?.pause()
  }

  build() {
    Stack({
      alignContent: Alignment.BottomEnd
    }) {
      Stack() {
        Video({
          src: this.config.videoUrl,
          previewUri: this.config.previewUrl ?? '',
          controller: this.videoController,
        })
          .autoPlay(this.config.autoPlay ?? true)
          .controls(this.config.showControls ?? false)
          .loop(this.config.loop ?? true)
          .muted(this.isMute ?? true)
          .onError(() => {
            promptAction.showToast({
              message: '视频加载失败，请稍后重试~'
            })
          })
          .onClick(() => {
            if (this.isPlaying) {
              this.videoController?.pause()
            } else {
              this.videoController?.start()
            }
            this.isPlaying = !this.isPlaying
          })
          .onStart(()=>{
            this.isPlaying = true
          })
          .onPause(()=>{
            this.isPlaying = false
          })

        //播放按钮
        Image($r('app.media.playIcon'))
          .width(40)
          .height(40)
          .visibility(this.isPlaying ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.videoController?.start()
            this.isPlaying = true
          })
      }.width('100%')
      .height('100%')

      //音量按钮
      Image(this.isMute ? $r('app.media.voice_off') : $r('app.media.voice_on'))
        .width(15)
        .height(15)
        .onClick(() => {
          this.isMute = !this.isMute
        })
        .margin({
          right: 10,
          bottom: 10
        })
    }.width(this.videoWidth)
    .height(this.videoHeight)
  }
}

interface VideoConfig {
  videoUrl: string
  autoPlay?: boolean
  isMute?: boolean
  previewUrl?: string | PixelMap | Resource
  showControls?: boolean
  loop?: boolean //循环播放视频
  aspectRatio: number | VideoAspectRatio // 视频宽高比，支持常用的视频宽高比枚举值和自定义宽高比
}

export enum VideoAspectRatio {
  RATIO_16_9 = 16 / 9, //横屏
  RATIO_4_3 = 4 / 3, //横屏
  RATIO_9_16 = 9 / 16, //竖屏
}