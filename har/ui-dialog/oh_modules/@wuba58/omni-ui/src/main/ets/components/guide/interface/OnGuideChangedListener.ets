import { Controller } from '../core/Controller';

export interface OnGuideChangedListener {

  /**
   * 当前引导页组件显示时回调
   * @param controller 引导页组件控制器
   */
  onShowed: (controller: Controller) => void;

  /**
   * 当前引导页组件消失时回调
   * @param controller 引导页组件控制器
   */
  onRemoved: (controller: Controller) => void;
}