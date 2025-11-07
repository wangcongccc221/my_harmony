
import { AnimatorOptions } from '@kit.ArkUI';

// 默认动画配置
const DEFAULT_ANIMATION_OPTIONS: AnimatorOptions = {
  duration: 250,
  easing: "fast-out-linear-in",
  delay: 0,
  fill: "forwards",
  direction: "normal",
  iterations: 1,
  begin: 0,
  end: 1
}

// 默认视图构建器
@Builder
export function _headerView() {
  Text("headerView:()=>{your @Builder View}")
}

@Builder
export function _ContentView() {
  Text("contentView:()=>{your @Builder View}")
}

@Builder
export function _loadMoreView() {
  Text("loadView:()=>{your @Builder View}")
}

@Builder
export function _noMoreView() {
  Text("noMoreView:()=>{your @Builder View}")
}

export class RefreshLayoutHelper {
  // 滚动相关属性
  public scrollerOffset: number = 0
  public preOffset: number = 0
  public totalOffset: number = 0
  public totalOffsetLoad: number = 0

  // 尺寸相关属性
  public headerSize: number = 0
  public footerSize: number = 0

  // 状态相关属性
  public isPressDown: boolean = false
  public notReleaseRefresh: boolean = false
  public notReleaseLoad: boolean = false

  // 手势配置
  public options: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Down | PanDirection.Up
  })

  // WebView偏移量
  public webViewXOffset: number = 0
  public webViewYOffset: number = 0

  // 动画配置
  public animOptions: AnimatorOptions = DEFAULT_ANIMATION_OPTIONS
  public animLoadOptions: AnimatorOptions = DEFAULT_ANIMATION_OPTIONS
}