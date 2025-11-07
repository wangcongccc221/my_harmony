import { PopupConfig } from './PopupConfig'
import { promptAction } from '@kit.ArkUI'
import { PopupInfo } from './entity/PopupInfo'

export class Config {
  /**
   * 弹窗基础配置参数
   */
  static dialogOptions: promptAction.BaseDialogOptions = {}
  /**
   * 弹窗设置
   */
  static popupConfig: PopupConfig = new PopupConfig()
  /**
   * 侧滑关闭
   */
  static dismissOnBackPressed: boolean = true
  /**
   * 自定义组件时，是否NodeContainer包裹，wrap=true:参数可统一设置，比如弹窗圆角、内边距等;wrap=false:所有内容都需要自己在使用地方配置，比如圆角，内边距等
   */
  static wrap: boolean = true
  /**
   * 全局设置
   */
  static popupOptions: PopupInfo = {}

  /**
   * 获取弹窗系统设置
   * @returns
   */
  static getDialogOptions(): promptAction.BaseDialogOptions {
    return JSON.parse(JSON.stringify(Config.dialogOptions))
  }

  /**
   * 获取窗口设置
   * @returns
   */
  static getPopupConfig(): PopupConfig {
    return JSON.parse(JSON.stringify(Config.popupConfig))
  }

  /**
   * 获取弹窗内默认设置
   * @returns
   */
  static getPopupOptions(): PopupInfo {
    return JSON.parse(JSON.stringify(Config.popupOptions))
  }
}