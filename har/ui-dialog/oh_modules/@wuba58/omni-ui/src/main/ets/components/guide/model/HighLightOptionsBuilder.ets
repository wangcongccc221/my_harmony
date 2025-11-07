import { OnClickListener } from '../interface/OnClickListener';
import { OnHighLightDrewListener } from '../interface/OnHighLightDrewListener';
import { HighLightOptions } from './HighLightOptions';

export class HighLightOptionsBuilder {
  private options: HighLightOptions;

  constructor() {
    this.options = new HighLightOptions();
  }

  /**
   * 高亮点击事件
   * @param listener 点击事件回调
   * @returns 额外配置构建类
   */
  public setOnClickListener(listener: OnClickListener | null): HighLightOptionsBuilder {
    this.options.onClickListener = listener;
    return this;
  }

  /**
   * 为高亮区域添加重绘监听
   * @param listener 重绘高亮区域图形的监听
   * @returns 额外配置构建类
   */
  public setOnHighLightDrewListener(listener: OnHighLightDrewListener | null): HighLightOptionsBuilder {
    this.options.onHighLightDrewListener = listener;
    return this;
  }

  /**
   * 是否每次显示引导页都重新获取组件坐标
   * @param isFetchLocation 是否每次显示引导页都重新获取组件坐标
   * @returns 额外配置构建类
   */
  public isFetchLocationEveryTime(isFetchLocation: boolean): HighLightOptionsBuilder {
    this.options.fetchLocationEveryTime = isFetchLocation;
    return this;
  }

  /**
   * 获取高亮区域的额外配置项
   * @returns
   */
  public build(): HighLightOptions {
    return this.options;
  }
}