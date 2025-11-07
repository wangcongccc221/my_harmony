import { RectF } from '../model/RectF';

export interface OnHighLightDrewListener {

  /**
   * 自定义高亮区域的显示图形
   * @param canvasContext2d 画布控制上下文
   * @param rectF 高亮区域
   */
  onHighLightDrew: (canvasContext2d: CanvasRenderingContext2D, rectF: RectF) => void;
}