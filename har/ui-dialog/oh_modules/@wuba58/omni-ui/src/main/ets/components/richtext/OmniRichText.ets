import { parseHtml } from "./utils/HtmlParseUtil";
import {
  aTagStyleString,
  brTagStyleString,
  bTagStyleString,
  divTagStyleString,
  emTagStyleString,
  h1TagStyledString,
  h2TagStyledString,
  h3TagStyledString,
  h4TagStyledString,
  h5TagStyledString,
  h6TagStyledString,
  imgTagStyleString,
  iTagStyleString,
  pTagStyleString,
  uTagStyleString
} from "./utils/StyleStringUtil";
import { BuilderNode, FrameNode, NodeController } from "@ohos.arkui.node";
import { UIContext } from "@ohos.arkui.UIContext";


/**
 *  1.div标签一般会有style，需要对style做映射，目前实现了基础的字体样式支持，需要扩展（已实现）
 * 2. 图片加载回来比渲染满，需要加载完图片后刷新页面（已实现）
 */
@Component
export struct OmniRichText {
  @Prop htmlStr: string = ''
  onHyperLinkClickListener?: (url: string) => void
  @State private richTexts: RichTextWrapper[] = []
  private textController: TextController = new TextController()
  private style: MutableStyledString = new MutableStyledString('');
  private richTextNodeController: OmniRichTextNodeController =
    new OmniRichTextNodeController(this.textController)

  refreshRichText() {
    this.richTexts.forEach(async (wrapper: RichTextWrapper, index: number) => {
      if (wrapper.tag === 'p') {
        this.style.appendStyledString(pTagStyleString(wrapper.content, wrapper.content.length))
      } else if (wrapper.tag === 'u') {
        this.style.appendStyledString(uTagStyleString(wrapper.content, wrapper.content.length))
      } else if (wrapper.tag === 'br') {
        this.style.appendStyledString(brTagStyleString())
      } else if (wrapper.tag === 'em') {
        this.style.appendStyledString(emTagStyleString(wrapper.content, wrapper.content.length))
      } else if (wrapper.tag === 'b') {
        this.style.appendStyledString(bTagStyleString(wrapper.content, wrapper.content.length))
      } else if (wrapper.tag === 'div') {
        this.style.appendStyledString(divTagStyleString(wrapper.content, wrapper.content.length, wrapper.attributes))
      } else if (wrapper.tag === 'i') {
        this.style.appendStyledString(iTagStyleString(wrapper.content, wrapper.content.length))
      } else if (wrapper.tag === 'a') {
        this.style.appendStyledString(aTagStyleString(wrapper.content, wrapper.content.length, wrapper.attributes,
          this.onHyperLinkClickListener))
      } else if (wrapper.tag === 'img') {
        // 图片这里有点问题，需要触发刷新之后才会展示出来，需要异步
        const styledString = imgTagStyleString(wrapper.content, wrapper.attributes, (image: ImageAttachment) => {

          //计算img要插入的下标
          let insertIndex = 0
          for (let i = 0; i < index; i++) {
            if (this.richTexts[i].textLength) {
              insertIndex += this.richTexts[i].textLength ?? 0
            }
          }

          this.style.insertStyledString(insertIndex, new StyledString(image))
          this.textController.setStyledString(this.style)

          //刷新
          this.richTextNodeController.rebuild()
        })
        this.style.appendStyledString(styledString)
      } else if (wrapper.tag === 'h1') {
        this.style.appendStyledString(h1TagStyledString(wrapper.content, wrapper.attributes))
      } else if (wrapper.tag === 'h2') {
        this.style.appendStyledString(h2TagStyledString(wrapper.content, wrapper.attributes))
      } else if (wrapper.tag === 'h3') {
        this.style.appendStyledString(h3TagStyledString(wrapper.content, wrapper.attributes))
      } else if (wrapper.tag === 'h4') {
        this.style.appendStyledString(h4TagStyledString(wrapper.content, wrapper.attributes))
      } else if (wrapper.tag === 'h5') {
        this.style.appendStyledString(h5TagStyledString(wrapper.content, wrapper.attributes))
      } else if (wrapper.tag === 'h6') {
        this.style.appendStyledString(h6TagStyledString(wrapper.content, wrapper.attributes))
      } else {
        this.style.appendStyledString(new StyledString(wrapper.content))
      }
    })
    this.textController.setStyledString(this.style)
  }

  aboutToAppear(): void {
    const htmlMap = parseHtml(this.htmlStr)
    this.richTexts = JSON.parse(htmlMap) as RichTextWrapper[]
    this.richTexts = this.richTexts.map(item => {
      const wrapper = new RichTextWrapper()
      wrapper.tag = item.tag
      wrapper.position = item.position
      wrapper.content = item.content
      wrapper.textLength = item.textLength
      wrapper.attributes = item.attributes
      return wrapper
    })
  }

  build() {
    Column() {
      NodeContainer(this.richTextNodeController)
        .onAppear(() => {
          this.refreshRichText()
        })
    }
  }
}

export class RichTextWrapper {
  position: number = -1 //标签的position
  content: string = "" //标签包含的文本
  tag: string = "" //标签名
  attributes?: object //标签的样式属性
  textLength?: number //标签内的text长度
}

@Builder
function richTextBuilder(textController: TextController) {
  Text(undefined, { controller: textController })
}

class OmniRichTextNodeController extends NodeController {
  private textController: TextController

  constructor(textController: TextController) {
    super();
    this.textController = textController
  }

  private richTextMode: BuilderNode<[TextController]> | null = null
  private wrapBuilder: WrappedBuilder<[TextController]> = wrapBuilder(richTextBuilder);

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.richTextMode == null) {
      this.richTextMode = new BuilderNode(uiContext)
      this.richTextMode.build(this.wrapBuilder, this.textController)
    }
    return this.richTextMode!.getFrameNode()
  }
}