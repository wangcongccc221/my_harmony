import { OmniFilterItemBean } from "./bean/OmniFilterItemBean";

//确认动作
export declare type OnConfirmAction = () => void
//关闭动作
export declare type OnCloseAction = () => void

export class OmniFilterComponentRegistry {
  // 下拉类型组件池
  private dropSlideTypeBuilderPool: Map<string, WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]>> = new Map();

  // 右滑类型组件池
  private rightSlideTypeBuilderPool: Map<string, WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]>> = new Map();

  // 初始化方法，用于注册默认的组件
  constructor() {
  }

  // 注册下拉类型的组件
  registerDropSlideComponent(type: string, builder: WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]>) {
    this.dropSlideTypeBuilderPool.set(type, builder);
  }

  // 注册右滑类型的组件
  registerRightSlideComponent(type: string, builder: WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]>) {
    this.rightSlideTypeBuilderPool.set(type, builder);
  }

  // 获取下拉类型的组件构建器
  getDropSlideComponentBuilder(type: string): WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]> | undefined {
    return this.dropSlideTypeBuilderPool.get(type);
  }

  // 获取右滑类型的组件构建器
  getRightSlideComponentBuilder(type: string): WrappedBuilder<[OmniFilterItemBean, OnConfirmAction, OnCloseAction]> | undefined {
    return this.rightSlideTypeBuilderPool.get(type);
  }

  // 检查是否存在某个下拉类型的组件
  hasDropSlideType(type: string): boolean {
    return this.dropSlideTypeBuilderPool.has(type);
  }

  // 检查是否存在某个右滑类型的组件
  hasRightSlideType(type: string): boolean {
    return this.rightSlideTypeBuilderPool.has(type);
  }
}