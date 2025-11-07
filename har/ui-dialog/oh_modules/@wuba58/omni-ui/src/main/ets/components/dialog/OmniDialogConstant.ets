import { OmniDialogController } from "./OmniDialog"

export interface OmniDialogTextArgs {
  value: string
  style?: OmniDialogFontStyle
  padding?: Padding | Length | LocalizedPadding
}

export interface OmniDialogFontStyle {
  font?: Font
  color?: ResourceColor
}

export interface OmniDialogButtonArgs {
  value: string
  fontStyle?: OmniDialogFontStyle
  padding?: Padding | Length | LocalizedPadding
  backgroundColor?: ResourceColor
  border?: BorderOptions
}

export interface OmniDialogArgs {
  titleBuilder?: () => void
  contentBuilder?: () => void
  buttonBuilder?: (controller?: OmniDialogController) => void
  titleArgs?: OmniDialogTextArgs
  contentArgs?: OmniDialogTextArgs
  leftButtonArgs?: OmniDialogButtonArgs
  rightButtonArgs?: OmniDialogButtonArgs
  dialogBorder?: BorderOptions
  dialogBgColor?: ResourceColor
  dialogDivider?: OmniDialogDividerOptions
  isModal?: boolean
  showInSubWindow?: boolean
  autoCancel?: boolean
  alignment?: DialogAlignment
  offset?: Offset
  transition?: TransitionEffect
  maskColor?: ResourceColor
  onDidAppear?: VoidCallback
  onDidDisappear?: VoidCallback
  onLeftButtonClick?: (event: ClickEvent) => void
  onRightButtonClick?: (event: ClickEvent) => void
}

export class OmniDialogParams {
  controller: OmniDialogController
  titleBuilder?: () => void
  contentBuilder?: () => void
  buttonBuilder?: (controller?: OmniDialogController) => void
  titleArgs?: OmniDialogTextArgs
  contentArgs?: OmniDialogTextArgs
  leftButtonArgs?: OmniDialogButtonArgs
  rightButtonArgs?: OmniDialogButtonArgs
  dialogBorder?: BorderOptions
  dialogBgColor?: ResourceColor
  dialogDivider?: OmniDialogDividerOptions
  onLeftButtonClick?: (event: ClickEvent) => void
  onRightButtonClick?: (event: ClickEvent) => void

  constructor(controller: OmniDialogController, args: OmniDialogArgs) {
    this.controller = controller;
    this.titleBuilder = args.titleBuilder
    this.contentBuilder = args.contentBuilder
    this.buttonBuilder = args.buttonBuilder
    this.titleArgs = args.titleArgs
    this.contentArgs = args.contentArgs
    this.leftButtonArgs = args.leftButtonArgs
    this.rightButtonArgs = args.rightButtonArgs
    this.dialogBorder = args.dialogBorder
    this.dialogBgColor = args.dialogBgColor
    this.dialogDivider = args.dialogDivider
    this.onLeftButtonClick = args.onLeftButtonClick
    this.onRightButtonClick = args.onRightButtonClick
  }
}

export interface OmniDialogDividerOptions {
  strokeWidth?: number | string
  color?: ResourceColor
  margin?: Margin | Length | LocalizedMargin
}