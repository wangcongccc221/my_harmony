@Observed
export default class ObservedMaskVisibleState {
  private globalShowGuideMask: boolean = false;

  /**
   * 设置引导页蒙版显示状态
   * @param show 是否显示引导页蒙版
   */
  setShowGuideMask(show: boolean): void {
    this.globalShowGuideMask = show;
  }

  /**
   * 获取引导页蒙版显示状态
   * @returns 蒙版是否正在显示
   */
  isShowGuideMask() {
    return this.globalShowGuideMask;
  }
}