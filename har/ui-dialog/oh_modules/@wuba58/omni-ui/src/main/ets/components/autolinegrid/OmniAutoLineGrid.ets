import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme"
import { AutoLineWrapLayout } from "./AutoLineWrapLayout"
import { LineWrapLayout } from "./LineWrapLayout"

@Component
export struct OmniAutoLineGrid {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Prop items: PairItemInfo[]
  @Prop titleStyle: TextStyle = { fontSize: this.baseStyle.fontSizeLg, fontColor: '#979B9E' }
  @Prop contentStyle: TextStyle = { fontSize: this.baseStyle.fontSizeLg, fontColor: '#0B0F12' }
  @Prop rightTextStyle: TextStyle = { fontSize: this.baseStyle.fontSizeLg, fontColor: '#517a99' }
  @BuilderParam rightPartBuilder?: VoidCallback | undefined | null
  onRightAreaClick?: (event: ClickEvent) => void

  build() {
    Stack({ alignContent: Alignment.Top }) {
      //内容布局
      Column() {
        AutoLineWrapLayout({ lineGap: 10, lineMaxNum: 2 }) {
          ForEach(this.items, (item: PairItemInfo) => {
            LineWrapLayout({ gap: 10, singleLine: item.singleLine, hasRightPart: item.hasRightPart ?? false }) {
              // left part
              Text(item.title)
                .fontSize(this.titleStyle.fontSize)
                .fontColor(this.titleStyle.fontColor)
              Text(item.content)
                .fontSize(this.contentStyle.fontSize)
                .fontColor(this.contentStyle.fontColor)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              // right part
              if (item.singleLine && (item.hasRightPart ?? false)) {
                if (this.rightPartBuilder) {
                  this.rightPartBuilder()
                } else {
                  Row() {
                    Text(item.rightText)
                      .fontSize(this.rightTextStyle.fontSize)
                      .fontColor(this.rightTextStyle.fontColor)

                    if (item.rightIcon) {
                      Image(item.rightIcon)
                        .size(item.rightIconSize ?? { width: 12, height: 12 })
                    }
                  }.onClick((event) => {
                    if (this.onRightAreaClick) {
                      this.onRightAreaClick(event)
                    }
                  })
                }
              }
            }
          })
        }
      }.width('100%')
    }
  }
}

export interface PairItemInfo {
  title: string
  content: string
  rightText?: string
  rightIcon?: PixelMap | ResourceStr | DrawableDescriptor
  rightIconSize?: SizeOptions
  singleLine: boolean
  hasRightPart?: boolean
}

export interface TextStyle {
  fontSize?: string | number | Resource
  fontColor?: ResourceColor
}