/**
 * 全局键盘状态管理（简单单例）
 * 当前只关心：是否按下左 Ctrl 键
 */
export class KeyboardState {
  private static ctrlPressed: boolean = false;

  static setCtrlPressed(pressed: boolean): void {
    KeyboardState.ctrlPressed = pressed;
  }

  static isCtrlPressed(): boolean {
    return KeyboardState.ctrlPressed;
  }
}


