export interface OmniPullDown {
  isPullDown: boolean // 是否处于下拉状态
  isPullUp: boolean // 是否处于上拉状态
  isTouch: boolean // 是否正在触摸
  distance: number // 下拉距离
  distanceLoad: number // 上拉距离
  headerViewSize: number // 头部视图高度
  footerViewSize: number // 底部视图高度
  status: OmniPullStatus // 当前状态
}

export enum OmniPullStatus {
  DEF, // 默认状态（无下拉）
  PullDown, // 正在下拉
  PreRefresh, // 达到可刷新状态
  Refresh, // 刷新中
  RefreshSuccess, // 刷新成功
  RefreshError, // 刷新失败
  PullUp, // 正在上拉
  PreLoad, // 达到可加载状态
  Load, // 加载中
  LoadSuccess, // 加载成功
  LoadError // 加载失败
}