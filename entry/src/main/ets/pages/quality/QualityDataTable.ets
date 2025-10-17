/**
 * 品质页面数据表格组件
 * 
 * 功能说明：
 * - 显示品质等级数据表格
 * - 包含等级名称、颜色等级、糖度等级等列
 * - 支持滚动显示和主题适配
 * 
 * 主要特性：
 * - 表格显示：显示品质等级数据
 * - 表头固定：表头不滚动，内容可滚动
 * - 主题适配：支持明暗主题切换
 * - 响应式设计：适配不同屏幕尺寸
 * - 数据绑定：支持动态数据更新
 * 
 * 使用场景：
 * - 品质页面数据表格显示
 * - 品质等级数据展示
 * - 数据对比和分析
 * 
 * 组件结构：
 * - 表头区域：显示列标题（等级名称、颜色等级、糖度等级）
 * - 数据区域：显示具体的品质等级数据
 * - 滚动区域：支持垂直滚动查看更多数据
 * 
 * 数据格式：
 * - 等级名称：1-7等级编号
 * - 颜色等级：优秀、良好、一般、较差、差、极差、零价值
 * - 糖度等级：高糖度、中糖度、低糖度、极低糖度、无糖度、负糖度、零价值
 * 
 * 样式特性：
 * - 响应式设计：适配不同屏幕尺寸
 * - 主题适配：支持明暗主题
 * - 表格样式：统一的表格设计
 * - 滚动优化：流畅的滚动体验
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY } from '../../utils/theme/useOmniTheme'
import { QualityLevelData } from './QualityConstants'

/**
 * 品质页面数据表格组件
 * 
 * 功能说明：
 * - 显示品质等级数据表格
 * - 包含等级名称、颜色等级、糖度等级等列
 * - 支持滚动显示和主题适配
 * 
 * 属性说明：
 * - qualityLevels：品质等级数据数组
 * - onDataUpdate：数据更新回调函数
 * - onDataClick：数据点击回调函数
 * 
 * 主题支持：
 * - 支持明暗主题切换
 * - 自动适配主题颜色
 * - 响应主题变化
 */
@Component
export struct QualityDataTable {
  // ==================== 属性定义 ====================
  
  /**
   * 品质等级数据数组
   * 
   * 功能说明：
   * - 存储要显示的品质等级数据
   * - 用于数据表格显示
   * - 支持动态更新
   * 
   * 数据结构：
   * - 每个元素包含等级名称、颜色等级、糖度等级
   * - 按照等级顺序排列
   * - 支持2-6个等级的动态显示
   * 
   * 使用场景：
   * - 数据表格显示数据
   * - 数据更新和同步
   * - 状态管理
   */
  @Prop qualityLevels: QualityLevelData[] = []

  // ==================== 事件回调 ====================
  
  /**
   * 数据更新回调函数
   * 
   * 功能说明：
   * - 处理数据更新的事件
   * - 接收更新的数据和索引
   * - 可选的回调函数
   * 
   * @param data 更新的数据
   * @param index 数据索引
   * 
   * 使用场景：
   * - 用户编辑数据时
   * - 程序自动更新数据时
   */
  onDataUpdate?: (data: QualityLevelData, index: number) => void

  /**
   * 数据点击回调函数
   * 
   * 功能说明：
   * - 处理用户点击数据行的事件
   * - 接收点击的数据和索引
   * - 可选的回调函数
   * 
   * @param data 点击的数据
   * @param index 数据索引
   * 
   * 使用场景：
   * - 用户选择数据行时
   * - 程序需要处理数据点击时
   */
  onDataClick?: (data: QualityLevelData, index: number) => void

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

  // 内部滚动控制：自动从顶部开始
  private scroller: Scroller = new Scroller()
  private lastCount: number = 0
  // 受控输入：按行存储“等级名称”的输入值，确保仅数字与不跳动
  @State private levelNameInputs: string[] = []

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
   * 构建数据行
   * 
   * 功能说明：
   * - 构建单个数据行的UI
   * - 包含等级名称、颜色等级、糖度等级
   * - 支持点击事件和样式适配
   * 
   * @param data 数据对象
   * @param index 数据索引
   * @returns 数据行组件
   * 
   * 使用场景：
   * - 数据表格行渲染
   * - 数据点击处理
   * - 样式适配
   */
  @Builder
  private buildDataRow(data: QualityLevelData, index: number) {
    Row() {
      // 等级名称列
      TextInput({ text: this.levelNameInputs[index] ?? data.levelName })
        .type(InputType.Number)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(Color.Transparent)
        .textAlign(TextAlign.Center)
        .layoutWeight(1)
        .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .enterKeyType(EnterKeyType.Done)
        .onChange((value: string) => {
          // 仅保留数字（允许空串）
          const numeric = value.replace(/\D+/g, '')
          this.levelNameInputs[index] = numeric
        })
        .onSubmit((enterKey: EnterKeyType) => {
          // 使用当前受控值作为提交内容
          const current = this.levelNameInputs[index] ?? ''
          const numeric = current.replace(/\D+/g, '')
          this.levelNameInputs[index] = numeric
          if (this.onDataUpdate) {
            this.onDataUpdate({
              levelName: numeric,
              colorLevel: data.colorLevel,
              sugarLevel: data.sugarLevel
            }, index)
          }
        })
        .onBlur(() => {
          const current = this.levelNameInputs[index] ?? ''
          const numeric = current.replace(/\D+/g, '')
          this.levelNameInputs[index] = numeric
          if (this.onDataUpdate) {
            this.onDataUpdate({
              levelName: numeric,
              colorLevel: data.colorLevel,
              sugarLevel: data.sugarLevel
            }, index)
          }
        })

      // 颜色等级列
      Text(data.colorLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

      // 糖度等级列
      Text(data.sugarLevel)
        .fontSize(24)
        .fontColor(this.getCurrentTheme().textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    }
    .width('100%')
    .padding(0)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .onClick(() => {
      if (this.onDataClick) {
        this.onDataClick(data, index)
      }
    })
  }

  /**
   * 构建组件UI
   * 
   * 功能说明：
   * - 构建品质页面数据表格的UI结构
   * - 包含表头和数据行
   * - 支持滚动显示和主题适配
   * 
   * 组件结构：
   * - 表头区域：显示列标题（等级名称、颜色等级、糖度等级）
   * - 数据区域：显示具体的品质等级数据
   * - 滚动区域：支持垂直滚动查看更多数据
   * 
   * 样式特性：
   * - 响应式设计：适配不同屏幕尺寸
   * - 主题适配：支持明暗主题
   * - 表格样式：统一的表格设计
   * - 滚动优化：流畅的滚动体验
   * 
   * 事件处理：
   * - 数据行点击：触发onDataClick事件
   * - 数据更新：触发onDataUpdate事件
   */
  build() {
    Column() {
      // 表头（固定不滚动）
      Row() {
        Text('等级名称')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().primary)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })

        Text('颜色等级')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().primary)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .border({ width: { right: 1 }, color: this.getCurrentTheme().borderColor })
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })

        Text('糖度等级')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getCurrentTheme().tableHeaderTextColor ?? this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().tableHeaderBg ?? this.getCurrentTheme().primary)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })
      }
      .width('100%')
      .padding(0)
      .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

      // 数据行（可滚动）
      Scroll(this.scroller) {
        Column() {
          ForEach(this.qualityLevels, (data: QualityLevelData, index: number) => {
            this.buildDataRow(data, index)
          }, (data: QualityLevelData, index: number) => `${index}`)
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height('90%') // 设置更高的固定高度以启用滚动
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .layoutWeight(1)
  }

  aboutToAppear(): void {
    // 初次进入强制回到顶部
    this.lastCount = this.qualityLevels ? this.qualityLevels.length : 0
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
    // 初始化受控输入数组
    this.levelNameInputs = (this.qualityLevels || []).map(item => (item.levelName ?? '').replace(/\D+/g, ''))
  }

  aboutToRender(): void {
    const current = this.qualityLevels ? this.qualityLevels.length : 0
    if (current !== this.lastCount) {
      // 数据条数变化后强制回到顶部
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
      this.lastCount = current
    }
    // 同步受控输入数组长度与值，避免因为数据刷新导致跳动
    const source = this.qualityLevels || []
    if (!this.levelNameInputs || this.levelNameInputs.length !== source.length) {
      this.levelNameInputs = source.map(item => (item.levelName ?? '').replace(/\D+/g, ''))
    } else {
      // 对齐内容（当外部数据变化时）
      for (let i = 0; i < source.length; i++) {
        const normalized = (source[i].levelName ?? '').replace(/\D+/g, '')
        if (this.levelNameInputs[i] === undefined) {
          this.levelNameInputs[i] = normalized
        }
      }
    }
  }
}
