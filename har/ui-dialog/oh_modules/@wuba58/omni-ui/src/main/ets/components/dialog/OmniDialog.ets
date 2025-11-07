import { ComponentContent, PromptAction } from "@kit.ArkUI"
import { buildDialog } from "./OmniDialogBuilder"
import { OmniDialogArgs, OmniDialogParams } from "./OmniDialogConstant"

export function generateId() {
  return Math.random().toString(36)
}

export class OmniDialogManager {
  private static dialogMap: Map<string, OmniDialog> = new Map();

  private constructor() {
  }

  public static put(dialog: OmniDialog): string {
    const key = generateId()
    OmniDialogManager.dialogMap.set(key, dialog);
    return key
  }

  public static dismiss(key: string) {
    OmniDialogManager.dialogMap.get(key)?.dismiss();
  }
}

export class OmniDialogController {
  private key: string

  constructor(key: string) {
    this.key = key;
  }

  public dismiss() {
    OmniDialogManager.dismiss(this.key)
  }
}

export class OmniDialog {
  private uiContext: UIContext
  private promptAction: PromptAction
  private compContent?: ComponentContent<OmniDialogParams>

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
    this.promptAction = uiContext.getPromptAction()
  }

  public dismiss() {
    this.promptAction.closeCustomDialog(this.compContent).then(() => {
      this.compContent?.dispose()
    })
  }

  public show(args: OmniDialogArgs) {
    let params = new OmniDialogParams(new OmniDialogController(OmniDialogManager.put(this)), args)
    this.compContent = new ComponentContent(this.uiContext, wrapBuilder(buildDialog), params)

    this.promptAction.openCustomDialog(this.compContent, {
      showInSubWindow: args.showInSubWindow ?? false,
      autoCancel: args.autoCancel ?? true,
      alignment: args.alignment ?? DialogAlignment.Center,
      isModal: args.isModal ?? true,
      offset: args.offset ?? { dx: 0, dy: 0 },
      transition: args.transition,
      maskColor: args.maskColor,
      onDidAppear: args.onDidAppear,
      onDidDisappear: args.onDidDisappear
    })
  }
}