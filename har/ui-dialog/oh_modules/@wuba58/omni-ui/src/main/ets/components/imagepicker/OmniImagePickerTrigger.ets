

@Component
export struct OmniImagePickerTrigger {

  @Prop triggerImageIcon: ResourceStr
  @Link selectUris: Array<ResourceStr>
  @Require goImagePicker?: () => void

  build() {
    Column() {
      Grid() {
        ForEach(this.selectUris, (url: ResourceStr, index: number) => {
          GridItem() {
            Image(url)
              .width('100%')
              .aspectRatio(1)
              .borderRadius(4)
              .onClick(() => {
                if (index == 0) {
                  this.goImagePicker?.()
                }
              })
          }
          .width('100%')
        })
      }
      .columnsTemplate("1fr 1fr 1fr 1fr")
      .columnsGap(5)
      .rowsGap(5)
      .margin({
        top: 10
      })
      .onAppear(() => {
        this.selectUris.push(this.triggerImageIcon ?? $r('app.media.image_trigger_add'))

      })
    }

  }

  aboutToAppear(): void {
  }
}