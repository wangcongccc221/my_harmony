import { t } from '../../../utils/i18n/I18nManager'

@Component
export struct FSMActionButtons {
  onCancel?: () => void
  onFSMProgram?: () => void
  onLoad?: () => void
  onSaveAs?: () => void

  build() {
    Row() {
      Button('FSM烧写')
        .backgroundColor('#228B22')
        .fontSize(14)
        .height(35)
        .onClick(() => {
          if (this.onFSMProgram) this.onFSMProgram()
        })
      
      Blank()

      Button('加载')
        .backgroundColor('#228B22')
        .fontSize(14)
        .height(35)
        .margin({ right: 10 })
        .onClick(() => {
          if (this.onLoad) this.onLoad()
        })

      Button('另存')
        .backgroundColor('#228B22')
        .fontSize(14)
        .height(35)
        .margin({ right: 10 })
        .onClick(() => {
          if (this.onSaveAs) this.onSaveAs()
        })
        
      Button('取消')
        .backgroundColor('#228B22')
        .fontSize(14)
        .height(35)
        .onClick(() => {
          if (this.onCancel) {
            this.onCancel()
          }
        })
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    .backgroundColor(Color.White) // 确保有背景色
    .border({ width: { top: 1 }, color: '#EEEEEE' }) // 顶部加个分割线
  }
}
