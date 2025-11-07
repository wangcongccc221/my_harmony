import { CommonModifier, TextInputModifier, TextModifier } from "@kit.ArkUI";
import { image } from "@kit.ImageKit";
import { inputMethod } from "@kit.IMEKit"
import { CommonConstants } from "../../constants/CommonConstants";
import { OmniTheme, OmniThemeStyle } from "../../theme/OmniTheme";

@Component
@Preview
export struct OmniSearchV2 {
  @State private text: string = ''
  @State private cancelVisible: boolean = true

  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  private controller: TextInputController = new TextInputController()
  /**
   * 提交回调
   */
  submitCallback?: (result: string) => void
  //取消回调
  onCancel?: () => void
  //获取焦点
  onFocusCallback?: () => void
  //文本变化回调
  onTextChange?: (text: string) => void
  /**
   * 搜索按钮的Modifier
   */
  @Prop searchButtonModifier?: SearchButtonModifier = new SearchButtonModifier()
    .withLinearGradient({
      direction: GradientDirection.LeftTop,
      colors: [[this.baseStyle.primary, 0], [this.baseStyle.primary, 0.5], [this.baseStyle.primary, 1]],
      angle: 180
    })
  /**
   * 搜索框Modifier
   */
  @Prop textInputModifier?: SearchTextInputModifier = new SearchTextInputModifier()

  /**
   * 搜索栏前景Modifier
   */
  @Prop foregroundContainerModifier?: SearchContainerModifier = new SearchContainerModifier()
    .withHeight(44)
    .withBackgroundColor(0xe6e6e6)
    .withBorderRadius(6)
    .withMargin({
      left: '5%',
      right: '5%',
      top: 10,
      bottom: 10
    })
  /**
   * 搜索栏背景Modifier
   */
  @Prop backgroundContainerModifier?: SearchContainerModifier = new SearchContainerModifier()
    .withWidth('100%')
    .withPadding({
      right: 10
    })
    .withBackgroundColor(0xffffff)
  /**
   * 搜索bar的入参
   */
  @Prop private config?: OmniSearchConfigV2 = new DefaultOmniSearchConfigV2()

  aboutToAppear(): void {
    //支持设置关键字
    this.text = this.config?.defaultText ?? ''
  }

  build() {
    Flex({
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center
    }) {
      RelativeContainer() {

        //搜索icon
        Image(this.config?.searchIcon != undefined ? this.config.searchIcon : $r('app.media.ic_search'))
          .width(24)
          .height(24)
          .margin({
            left: 8
          })
          .id('ic_search')
          .alignRules({
            left: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: HorizontalAlign.Start
            },
            top: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Top
            },
            bottom: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Bottom
            }
          })

        //输入框
        TextInput({
          text: $$this.text,
          placeholder: this.config?.placeHolderText ?? "",
          controller: this.controller,
        })
          .padding({
            left: -5
          })
          .onChange((value: string) => {
            this.onTextChange?.(value)

            if (this.text) {
              this.cancelVisible = true
            }
          })
          .onFocus(async () => {
            this.onFocusCallback?.()
          })
          .onSubmit(() => {
            this.submitCallback?.(this.text)
          })
          .attributeModifier(this.textInputModifier)
          .onClick(() => {
            this.cancelVisible = true
          })
          .id('text_input')
          .alignRules({
            left: {
              anchor: 'ic_search',
              align: HorizontalAlign.End
            },
            top: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Top
            },
            bottom: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Bottom
            },
            right: {
              anchor: 'text_cancel',
              align: HorizontalAlign.Start
            },
          })

        //清除icon
        Image(this.config?.clearIcon != undefined ? this.config.clearIcon : $r('app.media.ic_clear'))
          .width(16)
          .height(16)
          .margin({
            right: 10
          })
          .visibility((this.config?.hasClearBtn && this.text != '') ? Visibility.Visible : Visibility.Hidden)
          .onClick(() => {
            this.text = ''
          })
          .id('text_cancel')
          .alignRules({
            top: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Top
            },
            bottom: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Bottom
            },
            right: {
              anchor: 'btn_search',
              align: HorizontalAlign.Start
            },
          })

        //搜索按钮
        Text('搜索')
          .visibility(this.config?.hasSearchBtn && this.cancelVisible ? Visibility.Visible : Visibility.None)
          .id('btn_search')
          .margin({
            top: 3,
            bottom: 3,
            right: 3
          })
          .padding({
            left: 10,
            right: 10
          })
          .onClick(() => {
            //提交文本
            this.submitCallback?.(this.text)
            // 退出文本编辑状态
            inputMethod.getController().stopInputSession();
            this.controller.stopEditing()
          })
          .alignRules({
            top: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Top
            },
            bottom: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: VerticalAlign.Bottom
            },
            right: {
              anchor: CommonConstants.RELATIVE_CONTAINER_ID,
              align: HorizontalAlign.End
            },
          })
          .attributeModifier(this.searchButtonModifier)
      }
      .attributeModifier(this.foregroundContainerModifier)
      .layoutWeight(9)

      Text('取消')
        .visibility(this.config?.hasCancelBtn && this.cancelVisible ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.controller.stopEditing()
          this.cancelVisible = false
          this.onCancel?.()
        })
        .layoutWeight(1)
    }
    .attributeModifier(this.backgroundContainerModifier)
  }
}

interface OmniSearchConfigV2 {
  defaultText?: string | undefined //默认输入框文本，如携带关键字
  searchIcon?: image.PixelMap | ResourceStr | DrawableDescriptor | undefined //搜索icon
  clearIcon?: image.PixelMap | ResourceStr | DrawableDescriptor | undefined //清除icon
  placeHolderText?: string //占位提示信息
  hasCancelBtn?: boolean //取消按钮
  hasClearBtn?: boolean //清空按钮
  hasSearchBtn?: boolean //搜索按钮
}

export class DefaultOmniSearchConfigV2 implements OmniSearchConfigV2 {
  defaultText: string = ''
  clearIcon: image.PixelMap | ResourceStr | DrawableDescriptor | undefined
  searchIcon: PixelMap | ResourceStr | DrawableDescriptor | undefined
  placeHolderText: string = '请输入内容'
  hasCancelBtn: boolean = true
  hasClearBtn?: boolean = true
  hasSearchBtn?: boolean = true
}

export class SearchTextInputModifier implements AttributeModifier<TextInputModifier> {
  private pFont: Font = {
    size: 14,
    style: FontStyle.Normal
  }
  private pColor: ResourceColor = Color.Gray
  private bgColor: ResourceColor = 0xe6e6e6
  private textColor: ResourceColor = 0x333333
  private isFocusOnTouch: boolean = true
  private padding: Padding | Length | LocalizedPadding = { left: -5 }
  private type: InputType = InputType.Normal
  private textOverflow: TextOverflow = TextOverflow.Ellipsis
  private style: TextInputStyle | TextContentStyle = TextInputStyle.Default
  private borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
  private borderWidth: Length | EdgeWidths | LocalizedEdgeWidths = 0
  private borderColor: ResourceColor | EdgeColors | LocalizedEdgeColors = 0xffffff
  private caretColor: ResourceColor = Color.Red
  private caretStyle: CaretStyle = {
    width: 1,
    color: Color.Red
  }

  withPlaceholderFont(value: Font) {
    this.pFont = value
    return this
  }

  withPlaceholderColor(color: ResourceColor) {
    this.pColor = color
    return this
  }

  withBackgroundColor(color: ResourceColor) {
    this.bgColor = color
    return this
  }

  withFontColor(color: ResourceColor) {
    this.textColor = color
    return this
  }

  withFocusOnTouch(isFocusOnTouch: boolean) {
    this.isFocusOnTouch = isFocusOnTouch
    return this
  }

  withPadding(value: Padding | Length | LocalizedPadding) {
    this.padding = value
    return this
  }

  withType(value: InputType) {
    this.type = value
    return this
  }

  withTextOverFlow(value: TextOverflow) {
    this.textOverflow = value
    return this
  }

  withTextInputStyle(value: TextInputStyle | TextContentStyle) {
    this.style = value
    return this
  }

  withBorderRadius(value: Length | BorderRadiuses | LocalizedBorderRadiuses) {
    this.borderRadius = value
    return this
  }

  withBorderWidth(value: Length | EdgeWidths | LocalizedEdgeWidths) {
    this.borderWidth = value
    return this
  }

  withBorderColor(value: ResourceColor | EdgeColors | LocalizedEdgeColors) {
    this.borderColor = value
    return this
  }

  withCaretColor(value: ResourceColor) {
    this.caretColor = value
    return this
  }

  withCaretStyle(value: CaretStyle) {
    this.caretStyle = value
    return this
  }

  applyNormalAttribute(instance: TextInputModifier): void {
    instance.placeholderFont(this.pFont)
    instance.placeholderColor(this.pColor)
    instance.backgroundColor(this.bgColor)
    instance.fontColor(this.textColor)
    instance.focusOnTouch(this.isFocusOnTouch)
    instance.padding(this.padding)
    instance.type(this.type)
    instance.textOverflow(this.textOverflow)
    instance.style(this.style)
    instance.borderRadius(this.borderRadius)
    instance.borderWidth(this.borderWidth)
    instance.borderColor(this.borderColor)
    instance.caretColor(this.caretColor)
    instance.caretStyle(this.caretStyle)
  }
}

export class SearchContainerModifier implements AttributeModifier<CommonModifier> {
  private backgroundColor: ResourceColor = 0xffffff
  private borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 6
  private height: Length = 44
  private width: Length = '100%'
  private padding: Padding | Length | LocalizedPadding = {}
  private margin: Margin | Length | LocalizedMargin = {}
  private borderWidth: Length | EdgeWidths | LocalizedEdgeWidths = 0
  private borderColor: ResourceColor | EdgeColors | LocalizedEdgeColors = 0xffffff
  private shadow: ShadowOptions | ShadowStyle = {
    radius: 0,
  }

  withBackgroundColor(value: ResourceColor) {
    this.backgroundColor = value
    return this
  }

  withBorderRadius(value: Length | BorderRadiuses | LocalizedBorderRadiuses) {
    this.borderRadius = value
    return this
  }

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withWidth(value: Length) {
    this.width = value
    return this
  }

  withPadding(value: Padding | Length | LocalizedPadding) {
    this.padding = value
    return this
  }

  withMargin(value: Margin | Length | LocalizedMargin) {
    this.margin = value
    return this
  }

  withBorderWidth(value: Length | EdgeWidths | LocalizedEdgeWidths) {
    this.borderWidth = value
    return this
  }

  withBorderColor(value: ResourceColor | EdgeColors | LocalizedEdgeColors) {
    this.borderColor = value
    return this
  }

  withShadow(value: ShadowOptions | ShadowStyle) {
    this.shadow = value
    return this
  }

  applyNormalAttribute(instance: CommonModifier): void {
    instance.backgroundColor(this.backgroundColor)
    instance.borderRadius(this.borderRadius)
    instance.height(this.height)
    instance.width(this.width)
    instance.padding(this.padding)
    instance.margin(this.margin)
    instance.borderWidth(this.borderWidth)
    instance.borderColor(this.borderColor)
    instance.shadow(this.shadow)
  }
}

interface LinearGradient {
  angle?: number | string;
  direction?: GradientDirection;
  colors: Array<[
    ResourceColor,
    number
  ]>;
  repeating?: boolean;
}

export class SearchButtonModifier implements AttributeModifier<TextModifier> {
  private fontColor: ResourceColor = '#ffffff'
  private fontSize: number | string | Resource = 14
  private fontWeight: number | FontWeight | string = FontWeight.Medium
  private borderRadius: number = 4
  private linearGradient: LinearGradient = {
    direction: GradientDirection.LeftTop,
    colors: [['#FF552E', 0], ['#FF552E', 0.5], ['#FF7A2E', 1]],
    angle: 180
  }

  withFontColor(value: ResourceColor) {
    this.fontColor = value
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

  withBorderRadius(value: number) {
    this.borderRadius = value
    return this
  }

  withLinearGradient(value: LinearGradient) {
    this.linearGradient = value
    return this
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance.fontColor(this.fontColor)
    instance.fontSize(this.fontSize)
    instance.fontWeight(this.fontWeight)
    instance.borderRadius(this.borderRadius)
    instance.linearGradient(this.linearGradient)
  }
}