import { OmniPullStatus } from './interface'
import { OmniRefreshLayoutConfig } from './OmniRefreshLayoutConfig'

// 视图状态枚举
export enum ViewState {
  success = 0,    // 成功状态
  loading,        // 加载中
  empty,          // 空数据
  error,          // 错误
  noNetwork       // 无网络
}

export class OmniPullableController {
  private viewState: ViewState = ViewState.success  // 当前视图状态

  // 刷新相关方法
  refreshSuccess: (ignoreViewTips?: boolean) => void = () => {}      // 刷新成功
  refreshError: () => void = () => {}                                // 刷新失败
  refreshComplete: (isSuccess: boolean, ignoreViewTips?: boolean) => void = () => {}  // 刷新完成
  refreshCancel: () => void = () => {}                              // 取消刷新

  // 加载相关方法
  loadSuccess: (hasMore?: boolean) => void = () => {}               // 加载成功
  loadError: () => void = () => {}                                  // 加载失败
  loadComplete: (isSuccess: boolean, hasMore?: boolean) => void = () => {}  // 加载完成
  loadCancel: () => void = () => {}                                // 取消加载

  // 视图状态控制方法
  viewLoading: () => void = () => { this.viewState = ViewState.loading }    // 显示加载中
  viewEmpty: () => void = () => { this.viewState = ViewState.empty }        // 显示空布局
  viewError: () => void = () => { this.viewState = ViewState.error }        // 显示错误布局
  viewNoNetwork: () => void = () => { this.viewState = ViewState.noNetwork }// 显示无网络布局

  // 状态查询与控制方法
  getStatus: () => OmniPullStatus = () => OmniPullStatus.DEF                // 获取当前状态
  hasMore: (hasMore: boolean) => void = () => {}                    // 设置是否还有更多数据
  refresh: () => void = () => {}                                    // 手动触发下拉刷新
  load: () => void = () => {}                                       // 手动触发上拉加载

  // 开关状态查询
  refreshIsEnable: () => boolean = () => true                       // 下拉刷新是否启用
  loadIsEnable: () => boolean = () => false                         // 上拉加载是否启用

  // 配置相关方法
  setConfig: (config: OmniRefreshLayoutConfig) => void = () => {}       // 设置配置
  getConfig: () => OmniRefreshLayoutConfig = () => new OmniRefreshLayoutConfig()  // 获取配置

  // WebView 相关方法
  onWebviewScroll: (xOffset: number, yOffset: number) => void = () => {}  // WebView 滚动处理

  // 获取当前视图状态
  public getViewState(): ViewState {
    return this.viewState
  }
}