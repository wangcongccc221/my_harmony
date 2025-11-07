export interface OnPageChangedListener {

  /**
   * 当前显示的引导页页面的index
   * @param pageIndex 页面索引
   */
  onPageChanged: (pageIndex: number) => void;
}