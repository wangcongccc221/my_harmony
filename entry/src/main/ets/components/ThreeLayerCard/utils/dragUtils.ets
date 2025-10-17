/**
 * 拖拽工具（骨架）
 */

export class DragUtils {
  static parsePercentString(value: string): { num: number, raw: string } {
    const num = Number.parseFloat(String(value).replace('%', '')) || 0
    return { num, raw: String(value) }
  }
}


