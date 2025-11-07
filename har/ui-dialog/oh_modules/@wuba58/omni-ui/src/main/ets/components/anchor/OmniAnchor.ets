import { CommonModifier, RowModifier, TextModifier } from "@kit.ArkUI"
import { CommonConstants } from "../../constants/CommonConstants"
import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme"

export interface ListDataModel {
  anchorTag: string
  title: string
  listData?: object | undefined
}

@Preview
@Component
export struct OmniAnchor {
  //锚点模式，固定/滚动
  @Prop mode: OmniAnchorMode = OmniAnchorMode.Fixed
  //控制列表滚动
  private listScroller: Scroller = new Scroller()
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  //控制锚点bar的滚动
  private anchorBarScroller?: Scroller
  private anchors: string[] = []
  private anchorItemPostionX: Map<number, Area> = new Map
  @State private selectedAnchor: string = ''
  @Prop indicatorModifier?: AnchorIndicatorModifier = new AnchorIndicatorModifier()
    .withBackgroundColor(this.baseStyle.primary)
  /**
   * 锚点选中样式
   */
  @Prop selectedAnchorTextModifier?: AnchorTextModifier = new AnchorTextModifier()
    .withFontWeight(FontWeight.Bold)
    .withFontColor(this.baseStyle.primary)
    .withFontSize(18)
  /**
   * 锚点取消选中样式
   */
  @Prop unSelectedAnchorTextModifier?: AnchorTextModifier = new AnchorTextModifier()
  /**
   * 锚点栏样式
   */
  @Prop anchorBarModifier?: AnchorBarModifier = new AnchorBarModifier().withJustifyContent(FlexAlign.SpaceAround)
  /**
   * 带锚点数据的列表数据
   */
  @Require @Prop listDataWithAnchor: ListDataModel[] = []
  /**
   * 列表构造器
   */
  @BuilderParam
  listBuilder: ($$: ListDataModel[]) => void = this.itemBuilder

  @Builder
  itemBuilder($$: ListDataModel[]) {
  }

  aboutToAppear(): void {
    if (this.listDataWithAnchor.length) {
      this.anchors =
        this.listDataWithAnchor.filter((e) => e.anchorTag != '' && (e.anchorTag != undefined)).map((e) => e.anchorTag)
      this.selectedAnchor = this.anchors[0]
    }
    if (this.mode == OmniAnchorMode.Scrollable) {
      this.anchorBarScroller = new Scroller()
    }
  }

  //获取OmniAnchorMode映射的ScrollOption
  _getScrollOption(): ScrollDirection {
    if (this.mode == OmniAnchorMode.Scrollable) {
      return ScrollDirection.Horizontal
    } else {
      return ScrollDirection.None
    }
  }

  build() {
    Column() {
      RelativeContainer() {

        Column() {
          List({ scroller: this.listScroller }) {
            this.listBuilder(this.listDataWithAnchor)
          }
          .width('100%')
          .height('100%')
          .onScrollIndex((start: number) => {
            let currentAnchor = this.listDataWithAnchor[start]
            if (this.anchors.indexOf(currentAnchor.anchorTag) >= 0) {
              this.selectedAnchor = currentAnchor.anchorTag

              let area: Area = this.anchorItemPostionX[this.anchors.indexOf(currentAnchor.anchorTag)]
              if (area) {
                this.anchorBarScroller?.scrollTo({
                  xOffset: (area.position.x as number - 120),
                  yOffset: 0,
                  animation: { duration: 300, curve: Curve.Linear }
                })
              }
            }
          })
          .nestedScroll({
            scrollForward: NestedScrollMode.PARALLEL,
            scrollBackward: NestedScrollMode.PARALLEL
          })
          .scrollBar(BarState.Off)
        }
        .id('main-flow')
        .alignRules({
          top: {
            anchor: CommonConstants.RELATIVE_CONTAINER_ID,
            align: VerticalAlign.Top
          },
          bottom: {
            anchor: CommonConstants.RELATIVE_CONTAINER_ID,
            align: VerticalAlign.Bottom
          },
          left: {
            anchor: CommonConstants.RELATIVE_CONTAINER_ID,
            align: HorizontalAlign.Start
          },
          right: {
            anchor: CommonConstants.RELATIVE_CONTAINER_ID,
            align: HorizontalAlign.End
          }
        })

        Scroll(this.anchorBarScroller) {
          Row() {

            ForEach(this.anchors, (anchor: string, index: number) => {
              Column() {
                Text(anchor)
                  .attributeModifier(anchor == this.selectedAnchor ? this.selectedAnchorTextModifier
                  ?.withWidth(this._getScrollOption() === ScrollDirection.None ? 'auto' : '20%') :
                  this.unSelectedAnchorTextModifier?.withWidth(this._getScrollOption() === ScrollDirection.None ?
                    'auto' : '20%'))
                  .onClick(() => {
                    this.selectedAnchor = anchor
                    let pos = this.listDataWithAnchor.findIndex((listItem) => listItem.anchorTag === anchor)
                    this.listScroller.scrollToIndex(pos, false)
                  })

                //文本底部indicator
                Text('')
                  .attributeModifier(this.indicatorModifier)
                  .visibility(anchor === this.selectedAnchor ? Visibility.Visible : Visibility.None)
              }.justifyContent(FlexAlign.Center)
              .onAreaChange((o: Area, newArea: Area) => {
                this.anchorItemPostionX[index] = newArea
              })
            })
          }
          .attributeModifier(this.anchorBarModifier?.withWidth(this._getScrollOption() === ScrollDirection.None ?
            '100%' : 'auto'))
          .id('float-anchor')
          .alignRules({
            top: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Top
            },
            left: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: HorizontalAlign.Start
            },
            right: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: HorizontalAlign.End
            }
          })
        }
        .scrollBar(BarState.Off)
        .scrollable(this._getScrollOption())
      }
    }
  }
}

export class AnchorIndicatorModifier implements AttributeModifier<CommonModifier> {
  private width: Length = 20
  private height: Length = 3
  private borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 3
  private backgroundColor: ResourceColor = '#FF552E'

  withWidth(value: Length) {
    this.width = value
    return this
  }

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withBorderRadius(value: Length | BorderRadiuses | LocalizedBorderRadiuses) {
    this.borderRadius = value
    return this
  }

  withBackgroundColor(value: ResourceColor) {
    this.backgroundColor = value
    return this
  }

  applyNormalAttribute(instance: CommonModifier): void {
    instance.width(this.width)
    instance.height(this.height)
    instance.borderRadius(this.borderRadius)
    instance.backgroundColor(this.backgroundColor)
  }
}

export class AnchorTextModifier implements AttributeModifier<TextModifier> {
  private width: Length = '20%'
  private fontSize: number | string | Resource = 15
  private fontWeight: number | FontWeight | string = FontWeight.Normal
  private fontColor: ResourceColor = '#000000'
  private backgroundColor: ResourceColor = Color.White
  private textAlign: TextAlign = TextAlign.Center

  withWidth(value: Length) {
    this.width = value
    return this
  }

  withFontSize(value: number | string | Resource) {
    this.fontSize = value
    return this
  }

  withFontWeight(value: number | FontWeight | string) {
    this.fontWeight = value
    return this
  }

  withFontColor(value: ResourceColor) {
    this.fontColor = value
    return this
  }

  withBackgroundColor(value: ResourceColor) {
    this.backgroundColor = value
    return this
  }

  withTextAlign(value: TextAlign) {
    this.textAlign = value
    return this
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance.width(this.width)
    instance.fontSize(this.fontSize)
    instance.fontWeight(this.fontWeight)
    instance.fontColor(this.fontColor)
    instance.backgroundColor(this.backgroundColor)
    instance.textAlign(this.textAlign)
  }
}

export class AnchorBarModifier implements AttributeModifier<RowModifier> {
  height: Length = 40
  private width: Length = '100%'
  private backgroundColor: ResourceColor = '#ffffff'
  private justifyContent: FlexAlign = FlexAlign.SpaceEvenly
  private alignItems: VerticalAlign = VerticalAlign.Center
  private shadow: ShadowOptions | ShadowStyle = ShadowStyle.OUTER_DEFAULT_XS

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withWidth(value: Length) {
    this.width = value
    return this
  }

  withBackgroundColor(value: ResourceColor) {
    this.backgroundColor = value
    return this
  }

  withJustifyContent(value: FlexAlign) {
    this.justifyContent = value
    return this
  }

  withAlignItems(value: VerticalAlign) {
    this.alignItems = value
    return this
  }

  withShadow(value: ShadowOptions | ShadowStyle) {
    this.shadow = value
    return this
  }

  applyNormalAttribute(instance: RowModifier): void {
    instance.height(this.height)
    instance.width(this.width)
    instance.backgroundColor(this.backgroundColor)
    instance.justifyContent(this.justifyContent)
    instance.alignItems(this.alignItems)
    instance.shadow(this.shadow)
  }
}

export enum OmniAnchorMode {
  Scrollable,
  Fixed
}