import { ButtonOptions } from './ButtonOptions'
export interface PopupInfo {
  /**
   * Loading提示
   */
  hint?: string | Resource
  /**
   * Loading提示大小
   */
  hintFontSize?: number | string | Resource
  /**
   * Loading提示颜色
   */
  hintFontColor?: ResourceColor
  /**
   * Loading提示Weight
   */
  hintFontWeight?: number | FontWeight | string
  /**
   * 进度加载框大小
   */
  loadingProgressSize?: Length
  /**
   * Loading颜色
   */
  loadingProgressColor?: ResourceColor
  /**
   * 标题
   */
  title?: string | Resource
  /**
   * 标题大小
   */
  titleFontSize?: number | string | Resource
  /**
   * 标题颜色
   */
  titleFontColor?: ResourceColor
  /**
   * 标题Weight
   */
  titleFontWeight?: number | FontWeight | string
  /**
   * 内容
   */
  text?: string | Resource
  /**
   * 内容大小
   */
  textFontSize?: number | string | Resource
  /**
   * 内容颜色
   */
  textFontColor?: ResourceColor
  /**
   * 内容Weight
   */
  textFontWeight?: number | FontWeight | string
  /**
   * 文本对齐方式
   */
  textTextAlign?: TextAlign
  /**
   * 输入框提醒
   */
  placeholder?: string | Resource
  /**
   * 输入框提醒样式
   */
  placeholderFont?: Font
  /**
   * 输入框提醒颜色
   */
  placeholderFontColor?: ResourceColor
  /**
   * 按钮间间距
   */
  buttonSpace?: string | number | undefined
  /**
   * 按钮
   */
  buttons?: ButtonOptions[]
  /**
   * 数据
   */
  values?: string[]
  /**
   * 列表选择回调
   * @param value
   * @param index
   */
  onSelect?: (value: string, index: number) => void
}