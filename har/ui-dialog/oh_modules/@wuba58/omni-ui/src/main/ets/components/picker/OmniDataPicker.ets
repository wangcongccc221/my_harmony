import { ComponentContent, PromptAction } from '@kit.ArkUI'
import { OmniTheme, OmniToast } from '../../../../../Index'
import { OmniThemeStyle } from '../../theme/OmniTheme'

export class OmniDataPicker {
  private static instance: OmniDataPicker
  private selectedValue?: string | string[]
  private selectedIndex?: number | number[]
  private uiContext: UIContext
  private promptAction: PromptAction

  private constructor(uiContext: UIContext) {
    this.uiContext = uiContext
    this.promptAction = uiContext.getPromptAction()
  }

  public static getInstance(uiContext: UIContext): OmniDataPicker {
    if (!OmniDataPicker.instance) {
      OmniDataPicker.instance = new OmniDataPicker(uiContext)
    }
    return OmniDataPicker.instance
  }

  private maxDepth(root?: TextCascadePickerRangeContentWrapper): number {
    if (!root) {
      return 0
    }
    let max = 1
    if (!root.children) {
      return 1
    }
    for (let index = 0; index < root.children.length; index++) {
      max = Math.max(max, this.maxDepth(root.children[index]) + 1)
    }
    return max
  }

  public show(options: PickerOptions) {

    // 检查输入数据
    if (!Array.isArray(options.range)) {
      OmniToast.showText({
        msg: "Expected range to be array"
      })
      return
    }

    if (options.range.length === 0) {
      OmniToast.showText({
        msg: "Expected range to be not empty"
      })
      return
    }

    if (options.range[0] instanceof TextCascadePickerRangeContentWrapper) {
      // 级联
      let data = options.range as TextCascadePickerRangeContentWrapper[]
      this.selectedValue = []
      this.selectedIndex = new Array(this.maxDepth(data[0])).fill(0)
      if (options.selected) {
        if (Array.isArray(options.selected)) {
          for (let index = 0; index < options.selected.length; index++) {
            this.selectedIndex[index] = options.selected[index];
          }
        } else {
          this.selectedIndex[0] = options.selected as number
        }
      }
      let i = 0
      let cur = data[this.selectedIndex[i]]
      while (cur.children) {
        this.selectedValue[i++] = cur.text
        cur = cur.children[this.selectedIndex[i]]
      }
      this.selectedValue[i++] = cur.text
    } else if (Array.isArray(options.range[0])) {
      // 多列不级联
      let data = options.range as string[][]
      this.selectedValue = []
      const len = options.range.length
      this.selectedIndex = new Array(len).fill(0)
      if (options.selected) {
        if (Array.isArray(options.selected)) {
          for (let index = 0; index < options.selected.length; index++) {
            this.selectedIndex[index] = options.selected[index];
          }
        } else {
          this.selectedIndex[0] = options.selected as number
        }
      }
      for (let index = 0; index < len; index++) {
        let element = data[index];
        this.selectedValue[index] = element[this.selectedIndex[index]]
      }
    } else {
      // 单列
      let data = options.range as string[]
      this.selectedIndex = options.selected ? options.selected : 0
      this.selectedValue = data[this.selectedIndex as number]
    }

    let pickerArgs: PickerArgs = {
      ops: options,
      isClose: false,
      onCancelClicked: () => {
        compContent.update({
          ops: options,
          onCancelClicked: () => {
          },
          onConfirmClicked: () => {
          },
          onChange: () => {
          },
          isClose: true
        })
        setTimeout(() => {
          this.promptAction.closeCustomDialog(compContent).then(() => {
            compContent!.dispose()
          })
          if (options.onCancel) {
            options.onCancel(this.selectedValue!, this.selectedIndex!)
          }
        }, 200)
      },
      onConfirmClicked: () => {
        compContent.update({
          ops: options,
          onCancelClicked: () => {
          },
          onConfirmClicked: () => {
          },
          onChange: () => {
          },
          isClose: true
        })
        setTimeout(() => {
          this.promptAction.closeCustomDialog(compContent).then(() => {
            compContent!.dispose()
          })
          if (options.onConfirm) {
            options.onConfirm(this.selectedValue!, this.selectedIndex!)
          }
        }, 200)
      },
      onChange: (v: string | string[], i: number | number[]) => {
        this.selectedValue = v
        this.selectedIndex = i
      }
    }

    let compContent =
      new ComponentContent(this.uiContext, wrapBuilder(buildDataPicker), pickerArgs)

    // 显示 dialog
    this.promptAction.openCustomDialog(compContent, {
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        compContent.update({
          ops: options,
          onCancelClicked: () => {
          },
          onConfirmClicked: () => {
          },
          onChange: () => {
          },
          isClose: true
        })
        setTimeout(() => {
          dismissDialogAction.dismiss()
          compContent.dispose()
        }, 200)
      },
    })
  }
}

@Component
export struct DataPicker {
  @StorageLink(OmniTheme.KEY)
  private baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @Prop args: PickerArgs

  build() {
    Column() {
      Row() {
        Text(this.args.ops.cancelText ?? '取消')
          .fontSize(this.args.ops.theme?.cancelBtnStyle?.fontSize ?? this.baseStyle.fontSizeMd)
          .fontColor(this.args.ops.theme?.cancelBtnStyle?.fontColor ?? 0x222222)
          .fontWeight(this.args.ops.theme?.cancelBtnStyle?.fontWeight ?? FontWeight.Normal)
          .onClick(() => {
            this.args.onCancelClicked()
          })
        Text(this.args.ops.title ?? '')
          .fontSize(this.args.ops.theme?.titleTextStyle?.fontSize ?? this.baseStyle.fontSizeMd)
          .fontColor(this.args.ops.theme?.titleTextStyle?.fontColor ?? 0x222222)
          .fontWeight(this.args.ops.theme?.titleTextStyle?.fontWeight ?? FontWeight.Bold)
        Text(this.args.ops.confirmText ?? '确定')
          .fontSize(this.args.ops.theme?.cancelBtnStyle?.fontSize ?? this.baseStyle.fontSizeMd)
          .fontColor(this.args.ops.theme?.cancelBtnStyle?.fontColor ?? this.baseStyle.primary)
          .fontWeight(this.args.ops.theme?.cancelBtnStyle?.fontWeight ?? FontWeight.Normal)
          .onClick(() => {
            this.args.onConfirmClicked()
          })
      }.justifyContent(FlexAlign.SpaceBetween).padding({ left: 20, right: 20 }).width("100%")
      .height("15%")

      TextPicker({ range: this.args.ops.range, selected: this.args.ops.selected })
        .canLoop(this.args.ops.canLoop ?? false)
        .padding({ top: 50, bottom: 50 })
        .width('80%')
        .height("85%")
        .textStyle(this.args.ops.theme?.textStyle ?? { color: 0x999999, font: { size: this.baseStyle.fontSizeMd, weight: FontWeight.Normal } })
        .selectedTextStyle(this.args.ops.theme?.selectedTextStyle ??
          { color: this.baseStyle.primary, font: { size: this.baseStyle.fontSizeMd, weight: FontWeight.Bold } })
        .divider(this.args.ops.theme?.divider ?? { strokeWidth: 1, color: 0xf2f2f2 })
        .onChange((value: string | string[], index: number | number[]) => {
          this.args.onChange(value, index)
        })
    }
    .width('100%')
    .height("45%")
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 10, topRight: 10 })
    .padding({ bottom: 20 })
    .clip(true)
    .visibility(this.args.isClose ? Visibility.Hidden : Visibility.Visible)
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 200 }),
      TransitionEffect.move(TransitionEdge.BOTTOM).animation({ duration: 200 })
    ))
  }
}

@Builder
function buildDataPicker(args: PickerArgs) {
  DataPicker({ args: args })
}

interface PickerArgs {
  ops: PickerOptions
  onCancelClicked: VoidCallback
  onConfirmClicked: VoidCallback
  onChange: (v: string | string[], i: number | number[]) => void
  isClose: boolean // isClose控制dialog的弹出动画
}

export class TextCascadePickerRangeContentWrapper implements TextCascadePickerRangeContent {
  text: string = ''
  children?: TextCascadePickerRangeContentWrapper[] | undefined

  constructor(text: string, children?: TextCascadePickerRangeContentWrapper[]) {
    this.text = text
    this.children = children
  }
}

export interface PickerOptions {
  range: string[] | string[][] | TextCascadePickerRangeContentWrapper[]
  selected?: number | number[]
  theme?: PickerTheme
  canLoop?: boolean
  confirmText?: string | Resource
  cancelText?: string | Resource
  title?: string | Resource
  onConfirm?: (v: string | string[], i: number | number[]) => void
  onCancel?: (v: string | string[], i: number | number[]) => void
}

export interface PickerTheme {
  divider?: DividerOptions
  textStyle?: PickerTextStyle
  selectedTextStyle?: PickerTextStyle
  confirmBtnStyle?: TextStyle
  cancelBtnStyle?: TextStyle
  titleTextStyle?: TextStyle
}