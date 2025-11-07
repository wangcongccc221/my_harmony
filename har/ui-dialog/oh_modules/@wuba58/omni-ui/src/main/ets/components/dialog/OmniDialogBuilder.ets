import { OmniTheme, OmniThemeStyle } from '../../theme/OmniTheme';
import { OmniDialogController, OmniDialogManager } from './OmniDialog';
import { OmniDialogButtonArgs, OmniDialogParams, OmniDialogTextArgs, OmniDialogDividerOptions } from './OmniDialogConstant';

@Component
export struct OmniCustomDialog {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  controller?: OmniDialogController
  @BuilderParam titleBuilder: VoidCallback = this.buildTitle
  @BuilderParam contentBuilder: VoidCallback = this.buildContent
  @BuilderParam buttonBuilder: (controller?: OmniDialogController) => void = this.buildButtons
  @Prop titleArgs?: OmniDialogTextArgs = undefined
  @Prop contentArgs?: OmniDialogTextArgs = undefined
  @Prop leftButtonArgs?: OmniDialogButtonArgs = undefined
  @Prop rightButtonArgs?: OmniDialogButtonArgs = undefined
  @Prop dialogBorder: BorderOptions = { radius: 10 }
  @Prop dialogBgColor: ResourceColor = Color.White
  @Prop dialogDivider: OmniDialogDividerOptions = { strokeWidth: 0.5, color: 0x999999, margin: {} }
  onLeftButtonClick?: (event: ClickEvent) => void
  onRightButtonClick?: (event: ClickEvent) => void
  private buttonHeight: number = 0

  aboutToAppear(): void {
    let rightBtnHeight = px2vp(this.getUIContext()
      .getComponentUtils()
      .getRectangleById('right_button')
      .size
      .height)
    let leftBtnHeight = px2vp(this.getUIContext()
      .getComponentUtils()
      .getRectangleById('left_button')
      .size
      .height)
    this.buttonHeight = Math.max(rightBtnHeight, leftBtnHeight)
  }

  @Builder
  buildTitle() {
    if (this.titleArgs) {
      Text(this.titleArgs.value)
        .font(this.titleArgs.style?.font ?? {
          weight: FontWeight.Bold,
          size: this.baseStyle.fontSizeXl
        })
        .fontColor(this.titleArgs.style?.color ?? 0xFF333333)
        .padding(this.titleArgs.padding ?? 10)
    }
  }

  @Builder
  buildContent() {
    if (this.contentArgs) {
      Text(this.contentArgs.value)
        .font(this.contentArgs.style?.font ?? {
          weight: FontWeight.Normal,
          size: this.baseStyle.fontSizeMd
        })
        .fontColor(this.contentArgs.style?.color ?? 0xFF999999)
        .padding(this.contentArgs.padding ?? 10)
    }
  }

  @Builder
  buildButtons(controller?: OmniDialogController) {
    Divider()
      .vertical(false)
      .strokeWidth(this.dialogDivider?.strokeWidth)
      .color(this.dialogDivider?.color)
      .margin(this.dialogDivider?.margin)
    // 单行两个Button
    if (this.leftButtonArgs && this.rightButtonArgs) {
      Row() {
        Text(this.leftButtonArgs.value)
          .textAlign(TextAlign.Center)
          .font(this.leftButtonArgs.fontStyle?.font ?? {
            weight: FontWeight.Bold,
            size: this.baseStyle.fontSizeXl
          })
          .id('left_button')
          .fontColor(this.leftButtonArgs.fontStyle?.color ?? 0xFF999999)
          .padding(this.leftButtonArgs.padding ?? 10)
          .backgroundColor(this.leftButtonArgs.backgroundColor ?? Color.Transparent)
          .border(this.leftButtonArgs.border)
          .width('50%')
          .onClick((event: ClickEvent) => {
            controller?.dismiss()
            if (this.onLeftButtonClick) {
              this.onLeftButtonClick(event)
            }
          })
        Divider()
          .vertical(true)
          .strokeWidth(0.5)
          .color(0x99999999)
          .height(this.buttonHeight)
        Text(this.rightButtonArgs.value)
          .textAlign(TextAlign.Center)
          .font(this.rightButtonArgs.fontStyle?.font ?? {
            weight: FontWeight.Bold,
            size: this.baseStyle.fontSizeXl
          })
          .id('right_button')
          .fontColor(this.rightButtonArgs.fontStyle?.color ?? 0xFF999999)
          .padding(this.rightButtonArgs.padding ?? 10)
          .backgroundColor(this.rightButtonArgs.backgroundColor ?? Color.Transparent)
          .border(this.rightButtonArgs.border)
          .width('50%')
          .onClick((event: ClickEvent) => {
            controller?.dismiss()
            if (this.onRightButtonClick) {
              this.onRightButtonClick(event)
            }
          })
      }
    } else if (this.leftButtonArgs) {
      Text(this.leftButtonArgs.value)
        .textAlign(TextAlign.Center)
        .font(this.leftButtonArgs.fontStyle?.font ?? {
          weight: FontWeight.Bold,
          size: this.baseStyle.fontSizeXl
        })
        .fontColor(this.leftButtonArgs.fontStyle?.color ?? 0xFF999999)
        .padding(this.leftButtonArgs.padding ?? 10)
        .backgroundColor(this.leftButtonArgs.backgroundColor ?? Color.Transparent)
        .border(this.leftButtonArgs.border)
        .width('100%')
        .onClick((event: ClickEvent) => {
          controller?.dismiss()
          if (this.onLeftButtonClick) {
            this.onLeftButtonClick(event)
          }
        })
    } else if (this.rightButtonArgs) {
      Text(this.rightButtonArgs.value)
        .textAlign(TextAlign.Center)
        .font(this.rightButtonArgs.fontStyle?.font ?? {
          weight: FontWeight.Bold,
          size: this.baseStyle.fontSizeXl
        })
        .fontColor(this.rightButtonArgs.fontStyle?.color ?? 0xFF999999)
        .padding(this.rightButtonArgs.padding ?? 10)
        .backgroundColor(this.rightButtonArgs.backgroundColor ?? Color.Transparent)
        .border(this.rightButtonArgs.border)
        .width('100%')
        .onClick((event: ClickEvent) => {
          controller?.dismiss()
          if (this.onRightButtonClick) {
            this.onRightButtonClick(event)
          }
        })
    }
  }

  build() {
    Column() {
      this.titleBuilder()
      this.contentBuilder()
      this.buttonBuilder(this.controller)
    }
    .border(this.dialogBorder)
    .backgroundColor(this.dialogBgColor ?? Color.White)
    .width('80%')
  }
}

@Builder
export function buildDialog(params: OmniDialogParams) {
  OmniCustomDialog({
    controller: params.controller,
    titleBuilder: params.titleBuilder,
    contentBuilder: params.contentBuilder,
    buttonBuilder: params.buttonBuilder,
    titleArgs: params.titleArgs,
    contentArgs: params.contentArgs,
    leftButtonArgs: params.leftButtonArgs,
    rightButtonArgs: params.rightButtonArgs,
    dialogBorder: params.dialogBorder,
    dialogBgColor: params.dialogBgColor,
    dialogDivider: params.dialogDivider,
    onLeftButtonClick: params.onLeftButtonClick,
    onRightButtonClick: params.onRightButtonClick
  })
}
