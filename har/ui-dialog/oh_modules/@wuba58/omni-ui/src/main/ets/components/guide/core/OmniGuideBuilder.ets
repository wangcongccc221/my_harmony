import { GuidePage } from '../model/GuidePage';
import { OnGuideChangedListener } from '../interface/OnGuideChangedListener';
import { OnPageChangedListener } from '../interface/OnPageChangedListener';

export class OmniGuideBuilder {
  // 标签名称
  label: string = '';
  // 是否总显示引导页
  alwaysShowGuide: boolean = false;
  // 设置引导页显示次数
  showCounts: number = 1;
  // 引导页页面集合
  guidePages: GuidePage[] = new Array();
  // 页面显示状态变化监听
  visibleStateChangeListener: OnGuideChangedListener | null = null;
  // 页面页数切换监听
  pageChangedListener: OnPageChangedListener | null = null;

  /**
   * 设置引导页名称，必须设置，用于存储引导页显示次数
   * @param label 引导页标签名称
   * @returns 引导页组件的配置项
   */
  public setLabel(label: string): OmniGuideBuilder {
    this.label = label;
    return this;
  }

  /**
   * 设置引导页的显示次数
   * @param count 显示次数
   * @returns 引导页组件的配置项
   */
  public setShowCounts(count: number): OmniGuideBuilder {
    this.showCounts = count;
    return this;
  }

  /**
   * 是否总是显示引导页，即是否无限次的显示
   * 默认为false，如果设置为true，{@Link HighLightGuideBuilder#setShowCounts}将失效
   * @param isAlways 永久显示
   * @returns 引导页组件的配置项
   */
  public alwaysShow(isAlways: boolean): OmniGuideBuilder {
    this.alwaysShowGuide = isAlways;
    return this;
  }

  /**
   * 添加引导页
   * @param page 引导页对象
   * @returns 引导页组件的配置项
   */
  public addGuidePage(page: GuidePage): OmniGuideBuilder {
    this.guidePages.push(page);
    return this;
  }

  /**
   * 添加引导页组件的可见状态监听
   * @param listener 状态监听器
   * @returns 引导页组件的配置项
   */
  public setOnGuideChangedListener(listener: OnGuideChangedListener | null): OmniGuideBuilder {
    this.visibleStateChangeListener = listener;
    return this;
  }

  /**
   * 添加页面切换监听器
   * @param listener 页面切换监听器
   * @returns 引导页组件的配置项
   */
  public setOnPageChangedListener(listener: OnPageChangedListener | null): OmniGuideBuilder {
    this.pageChangedListener = listener;
    return this;
  }
}