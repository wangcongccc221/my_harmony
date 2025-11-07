import { TabsModifier } from '@kit.ArkUI'
import { OmniTheme, OmniThemeStyle } from '../../theme/OmniTheme'
import { isVideoFormat } from '../../utils/Utils'
import { VideoView, VideoAspectRatio } from './OmniVideoView'

@Component
export struct OmniGallery {
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Prop tabBarModifier?: OmniGalleryTabBarModifier = new OmniGalleryTabBarModifier()
  @Require @Prop config: OmniGalleyConfig
  //tab切换时回调
  onTabChange?: (index: number) => void
  //tab点击回调
  onTabBarClick?: (index: number) => void
  //是否展开，默认不展开
  @State private isExpanded: boolean = false
  @State private selectedIndex: number = 0
  @BuilderParam tabBarItemBuilder?: ((title: string, length: number, index: number) => void) | undefined | null
  //视频播放控制器
  private videoController?: VideoController
  @State visible: Visibility = Visibility.None;
  @State scaleValue: number = 1;
  @State pinchValue: number = 1;
  @State pinchX: number = 0;
  @State pinchY: number = 0;
  @State count: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;
  private mPreviewImageUrl: string = ''
  private mHasVideo: boolean = false

  aboutToAppear(): void {
    this.selectedIndex = this.config.selectedIndex ?? 0
    this.mHasVideo =
      this.config.tabConfig.findIndex((e) => e.tabContentData.imageUrls.findIndex((image) => isVideoFormat(image) ??
        -1)) > 0
    if (this.mHasVideo) {
      this.videoController = new VideoController()
    }

  }

  build() {

    Stack() {
      Tabs({ barPosition: BarPosition.Start }) {
        ForEach(this.config.tabConfig, (tab: OmniGalleryTabConfig, tabIndex: number) => {
          TabContent() {
            RelativeContainer() {
              Swiper() {
                ForEach(tab.tabContentData.imageUrls, (imgUrl: string) => {
                  Column() {
                    //如果是视频则用video view其他用image
                    if (isVideoFormat(imgUrl)) {
                      VideoView({
                        videoController: this.videoController,
                        config: {
                          videoUrl: imgUrl,
                          aspectRatio: VideoAspectRatio.RATIO_4_3,
                        }
                      })
                    } else {
                      Image(imgUrl)
                        .width('100%')
                        .onClick(() => {
                          this.mPreviewImageUrl = imgUrl
                          if (this.visible === Visibility.Visible) {
                            this.visible = Visibility.None;
                          } else {
                            this.visible = Visibility.Visible;
                          }
                        })
                    }
                  }.height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(Color.Black)
                }, (imageUrl: string, index: number) => imageUrl + index)
              }
              .onChange((index: number) => {
                if (this.mHasVideo && index === 0 && this.videoController) {
                  this.videoController?.start()
                } else {
                  this.videoController?.pause()
                }
              })
              .autoPlay(false)
              .indicator(false)
              .loop(false)
              .disableSwipe(false)
              .nestedScroll(SwiperNestedScrollMode.SELF_FIRST)
              .id('swiper')
              .alignRules({
                top: {
                  anchor: "__container__",
                  align: VerticalAlign.Top
                },
                bottom: {
                  anchor: "__container__",
                  align: VerticalAlign.Bottom
                },
                left: {
                  anchor: "__container__",
                  align: HorizontalAlign.Start
                },
                right: {
                  anchor: "__container__",
                  align: HorizontalAlign.End
                },
              })

              //desc
              if (tab.tabContentData.name) {
                Column() {
                  Flex({ alignContent: FlexAlign.SpaceBetween }) {
                    Text(tab.tabContentData.name)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .fontSize(18)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .ellipsisMode(EllipsisMode.END)
                      .layoutWeight(9)
                      .padding({
                        right: 8
                      })

                    Text(this.isExpanded ? "收起" : "展开")
                      .fontColor(Color.White)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(5)
                      .ellipsisMode(EllipsisMode.END)
                      .onClick(() => {
                        this.isExpanded = !this.isExpanded
                      })
                  }
                  .width('100%')
                  .padding({
                    left: 15,
                    right: 15
                  })

                  if (tab.tabContentData.desc) {
                    Text(`${tab.tabContentData.desc}`)
                      .fontColor(Color.White)
                      .margin({
                        top: 15
                      })
                      .padding({
                        left: 15,
                        right: 15
                      })
                      .visibility(this.isExpanded ? Visibility.Visible : Visibility.None)
                  }
                }.id('cl_desc')
                .alignItems(HorizontalAlign.Start)
                .margin({
                  bottom: 15
                })
                .alignRules({
                  bottom: {
                    anchor: "__container__",
                    align: VerticalAlign.Bottom
                  },
                  left: {
                    anchor: "__container__",
                    align: HorizontalAlign.Start
                  },
                  right: {
                    anchor: "__container__",
                    align: HorizontalAlign.End
                  },
                })
              }
            }
          }
          .tabBar((this.tabBarItemBuilder != null && this.tabBarItemBuilder != undefined) ?
            this.tabBarItemBuilder?.(tab.tabBarTitle, tab.tabContentData.imageUrls.length, tabIndex) :
            `${tab.tabBarTitle}(${tab.tabContentData.imageUrls.length})`)
        }, (tab: OmniGalleryTabConfig) => tab.tabBarTitle)
      }
      .onChange((index) => {
        this.selectedIndex = index
        this.onTabChange?.(index)
      })
      .onTabBarClick((index) => {
        this.selectedIndex = index
        this.onTabBarClick?.(index)
      })
      .tabIndex(this.selectedIndex)
      .attributeModifier(this.tabBarModifier)
      .visibility(this.visible == Visibility.Visible ? Visibility.None : Visibility.Visible)


      //黑色遮罩
      Text('')
        .onClick(() => {
          if (this.visible == Visibility.Visible) {
            this.visible = Visibility.None;
          } else {
            this.visible = Visibility.Visible;
          }
        })
        .width('100%')
        .height('100%')
        .backgroundColor(0x000000)
        .visibility(this.visible)
        .id('tv_cover')
        .alignRules({
          left: {
            anchor: "__container__",
            align: HorizontalAlign.Start
          },
          right: {
            anchor: "__container__",
            align: HorizontalAlign.End
          },
          top: {
            anchor: "__container__",
            align: VerticalAlign.Top
          },
          bottom: {
            anchor: "__container__",
            align: VerticalAlign.Bottom
          },
        })

      //大图预览
      Column() {
        Image(this.mPreviewImageUrl)
          .width('100%')
          .draggable(false)
          .syncLoad(true)
          .visibility(this.visible)
          .scale({ x: this.scaleValue, y: this.scaleValue, z: 1 })
          .translate({ x: this.offsetX, y: this.offsetY, z: 0 })
          .gesture(
            GestureGroup(GestureMode.Exclusive, //只会响应一个手势
              PinchGesture({ fingers: 2 })//捏合手势
                .onActionUpdate((event?: GestureEvent) => {
                  //模拟器无法触发捏合手势回调
                  if (event) {
                    this.scaleValue = this.pinchValue * event.scale;
                    this.pinchX = event.pinchCenterX;
                    this.pinchY = event.pinchCenterY;
                  }
                })
                .onActionEnd(() => {
                  this.scaleValue = 1;
                  this.pinchValue = 1;
                  this.pinchX = 0;
                  this.pinchY = 0;
                  this.count = 0;
                  this.offsetX = 0;
                  this.offsetY = 0;
                  this.positionX = 0;
                  this.positionY = 0;
                }),
              PanGesture()//拖动手势
                .onActionUpdate((event?: GestureEvent) => {
                  if (event) {
                    this.offsetX = this.positionX + event.offsetX;
                    this.offsetY = this.positionY + event.offsetY;
                  }
                })
                .onActionEnd(() => {
                  this.scaleValue = 1;
                  this.pinchValue = 1;
                  this.pinchX = 0;
                  this.pinchY = 0;
                  this.count = 0;
                  this.offsetX = 0;
                  this.offsetY = 0;
                  this.positionX = 0;
                  this.positionY = 0;
                }),
              TapGesture()//点击手势
                .onAction((event: GestureEvent) => {
                  if (event) {
                    if (this.visible == Visibility.Visible) {
                      this.visible = Visibility.None;
                    } else {
                      this.visible = Visibility.Visible;
                    }
                  }
                })
            )
          )
      }.justifyContent(FlexAlign.Center)
    }

  }
}

export interface OmniGalleyConfig {
  selectedIndex: number | undefined
  tabConfig: OmniGalleryTabConfig[]
}

export interface OmniGalleryTabConfig {
  tabBarTitle: string
  tabContentData: OmniGalleryTabContentConfig
}

export interface OmniGalleryTabContentConfig {
  imageUrls: string[]
  name?: string
  desc?: string
}

export class OmniGalleryTabBarModifier implements AttributeModifier<TabsModifier> {
  private barMode: BarMode = BarMode.Scrollable
  private barHeight: Length = 40
  private barWidth: Length = '100%'
  private scrollable: boolean = true
  private barPosition: BarPosition = BarPosition.Start
  private divider?: DividerStyle | null = null
  private barBackgroundColor: ResourceColor = '#ffffff'

  withBarMode(value: BarMode) {
    this.barMode = value
    return this
  }

  withBarHeight(value: Length) {
    this.barHeight = value
    return this
  }

  withBarWidth(value: Length) {
    this.barWidth = value
    return this
  }

  withScrollable(value: boolean) {
    this.scrollable = value
    return this
  }

  withBarPosition(value: BarPosition) {
    this.barPosition = value
    return this
  }

  withDivider(value: DividerStyle | null) {
    this.divider = value
    return this
  }

  withVarBackgroundColor(value: ResourceColor) {
    this.barBackgroundColor = value
    return this
  }

  applyNormalAttribute(instance: TabsAttribute): void {
    instance.barMode(this.barMode)
    instance.barHeight(this.barHeight)
    instance.barWidth(this.barWidth)
    instance.scrollable(this.scrollable)
    instance.barPosition(this.barPosition)
    instance.divider(this.divider)
    instance.barBackgroundColor(this.barBackgroundColor)
  }
}