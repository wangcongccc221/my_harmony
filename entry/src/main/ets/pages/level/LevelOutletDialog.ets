/**
 * 出口设置对话框组件
 * 
 * 功能说明：
 * - 提供出口选择和设置功能
 * - 支持出口切换（上一个/下一个）
 * - 提供确认和取消操作
 * - 支持主题切换和样式适配
 * 
 * 主要特性：
 * - 模态对话框：全屏遮罩，居中显示
 * - 出口切换：支持上一个/下一个出口选择
 * - 操作按钮：提供确认和取消按钮
 * - 主题适配：支持明暗主题切换
 * - 事件回调：支持切换、确认、取消事件
 * 
 * 使用场景：
 * - 等级页面需要设置出口时
 * - 用户需要选择特定出口时
 * - 需要确认出口设置时
 * 
 * 组件结构：
 * - 背景遮罩：半透明黑色背景
 * - 对话框内容：白色背景，圆角边框
 * - 标题区域：显示"出口设置"标题
 * - 出口选择：显示当前出口，提供切换按钮
 * - 操作按钮：确认和取消按钮
 * 
 * 事件处理：
 * - onOutletSwitch：处理出口切换事件
 * - onOutletConfirm：处理确认事件
 * - onOutletCancel：处理取消事件
 * 
 * 样式特性：
 * - 响应式设计：适配不同屏幕尺寸
 * - 主题适配：支持明暗主题
 * - 动画效果：支持淡入淡出动画
 * - 阴影效果：提供立体感
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'

/**
 * 出口设置对话框组件
 * 
 * 功能说明：
 * - 提供出口选择和设置功能
 * - 支持出口切换（上一个/下一个）
 * - 提供确认和取消操作
 * - 支持主题切换和样式适配
 * 
 * 属性说明：
 * - showDialog：控制对话框显示/隐藏
 * - currentOutletIndex：当前选中的出口编号
 * - onOutletSwitch：出口切换回调函数
 * - onOutletConfirm：确认回调函数
 * - onOutletCancel：取消回调函数
 * 
 * 主题支持：
 * - 支持明暗主题切换
 * - 自动适配主题颜色
 * - 响应主题变化
 */
@Component
export struct LevelOutletDialog {
  // ==================== 属性定义 ====================
  /**
   * 控制对话框显示/隐藏
   * 
   * 功能说明：
   * - 控制对话框的显示状态
   * - 为true时显示对话框，为false时隐藏
   * - 默认值为false
   * 
   * 使用场景：
   * - 用户点击出口设置按钮时设置为true
   * - 用户确认或取消时设置为false
   */
  @Prop showDialog: boolean = false

  /**
   * 当前选中的出口编号
   * 
   * 功能说明：
   * - 显示当前选中的出口编号
   * - 用于在对话框中显示当前出口
   * - 默认值为1
   * 
   * 使用场景：
   * - 显示当前选中的出口
   * - 用户切换出口时更新
   */
  @Prop currentOutletIndex: number = 1

  // ==================== 事件回调 ====================
  /**
   * 出口切换回调函数
   * 
   * 功能说明：
   * - 处理用户点击上一个/下一个按钮的事件
   * - 接收切换方向参数
   * - 可选的回调函数
   * 
   * @param direction 切换方向：'previous' | 'next'
   * 
   * 使用场景：
   * - 用户点击上一个按钮时
   * - 用户点击下一个按钮时
   */
  onOutletSwitch?: (direction: 'previous' | 'next') => void

  /**
   * 确认回调函数
   * 
   * 功能说明：
   * - 处理用户点击确认按钮的事件
   * - 确认当前出口设置
   * - 可选的回调函数
   * 
   * 使用场景：
   * - 用户点击确认按钮时
   * - 确认出口设置时
   */
  onOutletConfirm?: () => void

  /**
   * 取消回调函数
   * 
   * 功能说明：
   * - 处理用户点击取消按钮的事件
   * - 取消出口设置操作
   * - 可选的回调函数
   * 
   * 使用场景：
   * - 用户点击取消按钮时
   * - 用户点击背景遮罩时
   */
  onOutletCancel?: () => void

  // ==================== 主题相关 ====================
  /**
   * 当前主题样式
   * 
   * 功能说明：
   * - 存储当前应用的主题样式
   * - 用于组件样式适配
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()

  /**
   * 当前主题类型
   * 
   * 功能说明：
   * - 存储当前应用的主题类型
   * - 用于主题类型判断
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题类型判断时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()

  /**
   * 主题版本号
   * 
   * 功能说明：
   * - 存储当前主题的版本号
   * - 用于主题更新检测
   * - 自动响应主题变化
   * 
   * 使用场景：
   * - 主题更新检测时
   * - 主题切换时自动更新
   */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0

  /**
   * 基础组件助手
   * 
   * 功能说明：
   * - 提供基础组件的通用功能
   * - 用于主题获取和样式处理
   * - 私有属性，不对外暴露
   * 
   * 使用场景：
   * - 获取当前主题时
   * - 处理组件样式时
   */
  private baseComponentHelper = new BaseComponentHelper()

  // ==================== 方法定义 ====================
  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 获取当前应用的主题配置
   * - 返回主题样式对象
   * - 用于组件样式适配
   * 
   * @returns 当前主题样式对象
   * 
   * 使用场景：
   * - 组件渲染时获取主题样式
   * - 样式适配时调用
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  /**
   * 构建组件UI
   * 
   * 功能说明：
   * - 构建出口设置对话框的UI结构
   * - 包含背景遮罩、对话框内容、标题、出口选择、操作按钮
   * - 支持主题适配和事件处理
   * 
   * 组件结构：
   * - 条件渲染：根据showDialog属性决定是否显示
   * - 背景遮罩：半透明黑色背景，支持点击关闭
   * - 对话框内容：白色背景，圆角边框，阴影效果
   * - 标题区域：显示"出口设置"标题
   * - 出口选择：显示当前出口，提供切换按钮
   * - 操作按钮：确认和取消按钮
   * 
   * 样式特性：
   * - 响应式设计：适配不同屏幕尺寸
   * - 主题适配：支持明暗主题
   * - 动画效果：支持淡入淡出动画
   * - 阴影效果：提供立体感
   * 
   * 事件处理：
   * - 背景点击：触发取消事件
   * - 上一个按钮：触发切换事件（previous）
   * - 下一个按钮：触发切换事件（next）
   * - 取消按钮：触发取消事件
   * - 确认按钮：触发确认事件
   */
  build() {
    if (this.showDialog) {
      Column() {
        // 对话框背景遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            if (this.onOutletCancel) {
              this.onOutletCancel()
            }
          })

        // 对话框内容
        Column() {
          // 标题
          Text('出口设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ bottom: 20 })

          // 出口选择
          Row() {
            Button('上一个')
              .height(40)
              .fontSize(24)  // 按钮字体调大到24px
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .fontColor(this.getCurrentTheme().textColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .onClick(() => {
                if (this.onOutletSwitch) {
                  this.onOutletSwitch('previous')
                }
              })

            Text(`当前出口: ${this.currentOutletIndex}号`)
              .fontSize(26)  // 当前出口文字调大到26px
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ left: 20, right: 20 })

            Button('下一个')
              .height(40)
              .fontSize(24)  // 按钮字体调大到24px
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .fontColor(this.getCurrentTheme().textColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .onClick(() => {
                if (this.onOutletSwitch) {
                  this.onOutletSwitch('next')
                }
              })
          }
          .margin({ bottom: 30 })

          // 操作按钮
          Row() {
            Button('取消')
              .height(40)
              .fontSize(24)  // 按钮字体调大到24px
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .fontColor(this.getCurrentTheme().textColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .margin({ right: 10 })
              .onClick(() => {
                if (this.onOutletCancel) {
                  this.onOutletCancel()
                }
              })

            Button('确认')
              .height(40)
              .fontSize(24)  // 按钮字体调大到24px
              .backgroundColor(this.getCurrentTheme().primary)
              .fontColor('#ffffff')
              .borderRadius(6)
              .onClick(() => {
                if (this.onOutletConfirm) {
                  this.onOutletConfirm()
                }
              })
          }
        }
        .width(300)
        .padding(20)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 10 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }
}
