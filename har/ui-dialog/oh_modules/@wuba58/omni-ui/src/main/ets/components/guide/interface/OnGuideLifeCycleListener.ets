export default interface OnGuideLifeCycleListener {

  /**
   * 组件蒙版即将加载到页面上，对应onAppear回调（在创建自定义组件的新实例后，在执行build()函数之前执行）
   */
  _onGuideAppear: () => void;

  /**
   * 组件蒙版即将从页面上移除，对应onDisAppear回调（在自定义组件析构销毁之前执行）
   */
  _onGuideDisAppear: () => void;

  /**
   * 指示组件的动画是否正在运行
   * @param isAnimationRunning 是否有动画正在运行
   */
  _onAnimationRunning: (isAnimationRunning: boolean) => void;
}