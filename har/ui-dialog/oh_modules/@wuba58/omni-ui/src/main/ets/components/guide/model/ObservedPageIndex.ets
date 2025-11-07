@Observed
export default class ObservedPageIndex {
  private globalCurrentPageIndex: number = -1;

  /**
   * 设置引导页index
   * @param index 引导页索引
   */
  setCurrentPageIndex(index: number): void {
    this.globalCurrentPageIndex = index;
  }

  /**
   * 获取引导页的索引
   * @returns 引导页索引
   */
  getCurrentPageIndex() {
    return this.globalCurrentPageIndex;
  }
}