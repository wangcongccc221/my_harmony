import { PopupBean } from './entity/PopupBean'
import { CustomBubbleComponent } from './CustomBubbleComponent'

/**
 * 气泡弹窗
 * @param data
 */
@Builder
export function bubblePopupBuilder(data: PopupBean<ESObject>) {
  CustomBubbleComponent({ data: data })
}