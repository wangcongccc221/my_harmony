import { TextUtils } from '../../utils/TextUtils'

let leftEdge: number = 0
let rightEdge: number = 0

function getTextStartX(context: UIContext, id: string): number {
  let comUtils = context.getComponentUtils()
  let info = comUtils.getRectangleById(id)
  const offsetX = px2vp(info.screenOffset.x)
  const width = px2vp(info.size.width)
  return offsetX + width / 2 - leftEdge
}
@Component
struct OmniTabs {
  private unid?: string

  @Require
  @Prop
  tabConfig: OmniTabConfig
  @Provide({allowOverride: "tabs"}) @Watch("tabsChange") tabs: OmniTabItemConfig[] = []
  onTabClick?: (index: number) => void

  tabController: OmniTabController = new OmniTabController()

  @State
  private selectedIndex: number = 0 // 当前选中的index
  @State
  private indicatorX: number = -1 // 指示器的位置x

  private scrollX: number = 0 // 滚动模式下的滚动距离
  private scroller: Scroller = new Scroller()

  private changeIndex: (index: number) => void = (index) => {
    if (index < 0 || index >= this.tabs.length || (this.tabConfig.mode === OmniTabMode.Fix && index > 4)) {
      return
    }
    this.selectedIndex = index
    animateTo({
      duration: 200,
      curve: Curve.Linear,
      playMode: PlayMode.Normal,
      iterations: 1,
      onFinish: () => {
        // 将选中tab滑动到组件中心
        if (this.tabConfig.mode === OmniTabMode.Scrollable) {
          const rootCenterX = (leftEdge + rightEdge) / 2
          const xOffset = this.indicatorX - rootCenterX
          const scrollX = this.scrollX
          this.scroller.scrollTo({
            xOffset: scrollX + xOffset,
            yOffset: 0,
            animation: {
              duration: 200,
              curve: Curve.Linear,
              canOverScroll: false,

            }
          })
        }
      }
    }, () => {
      const currentX = getTextStartX(this.getUIContext(), `omni_tab_text_builder_${this.unid}_${index}`)
      if (currentX === this.indicatorX) {
        this.indicatorX = currentX + 0.01
      } else {
        this.indicatorX = currentX
      }
    })
  }

  tabsChange() {

  }

  build() {
    Column() {
      if (this.tabConfig.mode === OmniTabMode.Fix) {
        Row() {
          ForEach(this.tabs.length > 5 ? this.tabs.slice(0, 5): this.tabs, (item: OmniTabItemConfig, index) => {
            OmniTabIemComponent({
              tabConfig: this.tabConfig,
              indicatorX: this.indicatorX,
              selectedIndex: this.selectedIndex,
              index: index,
              tabItem: item,
              unid: this.unid,
              onTabClick: this.onTabClick,
              changeIndex: this.changeIndex,

            })
          }, (it: OmniTabItemConfig, index) => {
            return `${it.text}-${it.badgeText}-${index}`
          })
          this.buildIndicator()

        }
        .padding({
          left: 20,
          right: 20
        })
        .width('100%')
        .height('100%')

      } else {
        Scroll(this.scroller) {
          Row() {
            ForEach(this.tabs, (tabItem: OmniTabItemConfig, index) => {
              OmniTabIemComponent({
                tabConfig: this.tabConfig,
                indicatorX: this.indicatorX,
                selectedIndex: this.selectedIndex,
                index: index,
                tabItem: tabItem,
                unid: this.unid,
                onTabClick: this.onTabClick,
                changeIndex: this.changeIndex,
              })
            }, (it: OmniTabItemConfig, index) => {
              return `${it.text}-${it.badgeText}-${index}`
            })
            this.buildIndicator()
          }
          .padding({
            right: 20
          })

        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .onDidScroll((x, _) => {
          this.scrollX += x
          if (this.scrollX < 0) {
            this.scrollX = 0
          }
        })
        .id(`omni_tab_root_${this.unid}`)
        .onAppear(() => {
          this.getRootPositionInfo()
        })
        .width('100%')
        .height('100%')
      }

    }
    .height(this.tabConfig.tabHeight ?? 56)
    .width(this.tabConfig.tabWidth ?? '100%')
    .alignItems(HorizontalAlign.Start)

  }


  @Builder
  buildIndicator() {
    if (this.indicatorX > 0) {
      Blank()
        .width(this.tabConfig.indicatorWidth ?? 30)
        .height(this.tabConfig.indicatorHeight ?? 5)
        .position({
          x: 0,
          y: 40
        })
        .translate({
          x: this.indicatorX + this.scrollX - (this.tabConfig.indicatorWidth ?? 30) / 2 - (this.tabConfig.mode === OmniTabMode.Fix ? 20: 0),
        })
        .color(this.tabConfig.indicatorColor ?? '#0090ff')
        .margin({
          bottom: 5
        })
        .id("omni_tab_indicator")
    }
  }

  aboutToAppear(): void {
    this.unid = this.getUniqueId().toString()
    this.tabController.changeIndex = (index: number): void => this.changeIndex(index)
  }



  getRootPositionInfo() {
    let comUtils = this.getUIContext().getComponentUtils()
    let info = comUtils.getRectangleById(`omni_tab_root_${this.unid}`)
    const left = px2vp(info.screenOffset.x)
    const right = left + px2vp(info.size.width)
    leftEdge = left
    rightEdge = right
  }
}

@Component
struct OmniTabIemComponent {
  private unid?: string
  @Prop index: number

  @ObjectLink tabItem: OmniTabItemConfig
  @Prop
  tabConfig: OmniTabConfig
  @Consume tabs: OmniTabItemConfig[]
  onTabClick?: (index: number) => void

  changeIndex?: (index: number) => void
  @Link
  selectedIndex: number // 当前选中的index
  @Link
  indicatorX: number // 指示器的位置x


  build() {
    RelativeContainer(){
      if (this.tabConfig.mode === OmniTabMode.Scrollable) {
        Row() {
          if (this.tabItem.leftIcon) {
            Image(this.tabItem.leftIcon)
              .width(20)
              .aspectRatio(1)
              .objectFit(ImageFit.Auto)
          }
          Text(`${this.tabItem.text}`)
            .fontSize(this.tabConfig.labelTextStyle?.size ?? 22)
            .fontWeight(this.tabConfig.labelTextStyle?.weight ?? FontWeight.Normal)
            .fontColor(this.selectedIndex == this.index ? this.tabConfig.labelColor : '#999')
            .onAppear(() => {
              if (this.selectedIndex == this.index) {
                this.indicatorX = getTextStartX(this.getUIContext(), `omni_tab_text_builder_${this.unid}_${this.index}`)
              }
            })
            .width('auto')
            .id(`omni_tab_text_builder_${this.unid}_${this.index}`)
          if (this.tabItem.rightIcon) {
            Image(this.tabItem.rightIcon)
              .width(20)
              .aspectRatio(1)
              .objectFit(ImageFit.Auto)
          }
        }
        .margin({
          left: 7,
          right: TextUtils.isNotBlank(this.tabItem.badgeText) ? 20 + 5 : 7
        })
        .id(`omni_tab_item_content_${this.unid}_${this.index}`)

      } else {
        Row() {
          if (this.tabItem.leftIcon) {
            Image(this.tabItem.leftIcon)
              .width(20)
              .aspectRatio(1)
              .objectFit(ImageFit.Auto)
          }
          Text(`${this.tabItem.text}`)
            .fontSize(this.tabConfig.labelTextStyle?.size ?? 22)
            .fontWeight(this.tabConfig.labelTextStyle?.weight ?? FontWeight.Normal)
            .fontColor(this.selectedIndex == this.index ? this.tabConfig.labelColor : '#999')
            .onAppear(() => {
              if (this.selectedIndex == this.index) {
                this.indicatorX = getTextStartX(this.getUIContext(), `omni_tab_text_builder_${this.unid}_${this.index}`)
              }
            })
            .width('auto')
            .id(`omni_tab_text_builder_${this.unid}_${this.index}`)
          if (this.tabItem.rightIcon) {
            Image(this.tabItem.rightIcon)
              .width(20)
              .aspectRatio(1)
              .objectFit(ImageFit.Auto)
          }
        }
        .alignRules({
          middle: {
            anchor: "__container__",
            align: HorizontalAlign.Center
          }
        })
        .id(`omni_tab_item_content_${this.unid}_${this.index}`)
      }

      if (TextUtils.isNotBlank(this.tabItem.badgeText)) {
        Text(`${this.tabItem.badgeText}`)
          .height(15)
          .fontColor(this.tabConfig.badgeTextColor ?? Color.White)
          .fontSize(10)
          .backgroundColor(this.tabConfig.badgeBackgroundColor ?? Color.Red)
          .borderRadius(7.5)
          .maxLines(1)
          .padding({
            left: 5,
            right: 5
          })
          .constraintSize({
            maxWidth: 40
          })
          .textAlign(TextAlign.Center)
          .alignRules({
            middle: {
              anchor: `omni_tab_item_content_${this.unid}_${this.index}`,
              align: HorizontalAlign.End
            },
            center: {
              anchor: `omni_tab_item_content_${this.unid}_${this.index}`,
              align: VerticalAlign.Top
            }
          })
      }
      if (this.tabItem.showRedDot) {
        Text("")
          .width(10)
          .height(10)
          .backgroundColor(this.tabConfig.badgeBackgroundColor ?? Color.Red)
          .alignRules({
            middle: {
              anchor: `omni_tab_item_content_${this.unid}_${this.index}`,
              align: HorizontalAlign.End
            },
            center: {
              anchor: `omni_tab_item_content_${this.unid}_${this.index}`,
              align: VerticalAlign.Top
            }
          })
          .borderRadius(5)
          .id(`omni_tab_item_dot_${this.unid}_${this.index}`)
      }

    }
    .width(this.tabConfig.mode === OmniTabMode.Scrollable ? 'auto': `calc(100% / ${Math.min(this.tabs.length, 5)})`)
    .height('100%')
    .padding({
      top: 8
    })
    .onClick(() => {
      this.changeIndex?.(this.index)
      this.onTabClick?.(this.index)

    })
  }
}


@Observed
class OmniTabItemConfig {
  text?: string
  badgeText?: string
  leftIcon?: ResourceStr
  rightIcon?: ResourceStr
  showRedDot?: boolean = false

  constructor(text?: string, badgeText?: string,
    leftIcon?: ResourceStr, rightIcon?: ResourceStr, showRedDot?: boolean) {
    this.text = text
    this.badgeText = badgeText
    this.leftIcon = leftIcon
    this.rightIcon = rightIcon
    this.showRedDot = showRedDot
  }


}

interface OmniTabConfig {
  mode?: OmniTabMode
  tabWidth?: number,
  tabHeight?: number,
  indicatorColor?: ResourceColor,
  indicatorWidth?: number,
  indicatorHeight?: number,
  labelColor?: ResourceColor,
  labelTextStyle?: Font,
  hasDivider?: boolean,
  tabSpacing?: number, // tab间距，scrollable模式下生效
  badgeBackgroundColor?: ResourceColor,
  badgeTextColor?: ResourceColor,

}

class OmniTabController {
  changeIndex: (index: number) => void = () => {}
}

enum OmniTabMode {
  Fix, Scrollable
}

export {
  OmniTabs,
  OmniTabItemConfig,
  OmniTabConfig,
  OmniTabMode,
  OmniTabController
}

