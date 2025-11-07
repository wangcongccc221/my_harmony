import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme"

@Component
export struct OmniSummary {
  /**
   * 组件入参，必填参数
   */
  @Prop @Require config: OmniSummaryConfig
  /**
   * item的点击事件，如查看大图
   */
  onItemClick?: (index: number, items: OmniSummaryItem[]) => void
  @State private columnsTemplate: string = ''

  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()

  aboutToAppear(): void {
    for (let i = 0; i < this.config.countPerRow; i++) {
      this.columnsTemplate += '1fr '
    }
    this.columnsTemplate.trimEnd()
  }

  @Builder
  buildSummaryItem(item: OmniSummaryItem, pIndex: number) {
    Column() {
      Text(`${item.title}(${item.images.length})`)
        .fontSize(20)
        .fontColor('#1F2326')
        .margin({ bottom: 20 })
        .fontWeight(FontWeight.Bold)

      Grid() {
        ForEach(item.images, (image: string) => {
          GridItem() {
            Image(image)
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .draggable(false)
              .animation({ curve: Curve.Sharp, duration: 300 })
              .onClick(() => {
                this.onItemClick?.(pIndex, this.config.items)
              })
          }
        }, (item: string, index: number) => item + index)
      }
      .width('100%')
      .editMode(false)
      .columnsGap(12)
      .rowsGap(12)
      .scrollBar(BarState.Off)
      .supportAnimation(true)
      .enableScrollInteraction(true)
      .columnsTemplate(this.columnsTemplate)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 20 })
  }

  build() {
    Scroll() {
      List() {
        ForEach(this.config.items, (item: OmniSummaryItem, index: number) => {
          ListItem() {
            this.buildSummaryItem(item, index)
          }
        })
      }.divider({
        strokeWidth: 15,
        color: '#ffffffff'
      })
    }.nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
  }
}

interface OmniSummaryConfig {
  items: OmniSummaryItem[],
  countPerRow: number
}

export interface OmniSummaryItem {
  title: string
  images: string[]
}