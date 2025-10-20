/**
 * 等级页面右侧数据表格组件
 * 
 * 功能说明：
 * - 显示等级表格和数据统计表格
 * - 在Level页面中作为右侧数据展示区域显示
 * - 提供表格数据的展示和管理功能
 * - 支持表格数量的动态调整
 * 
 * 包含内容：
 * - 等级表格：显示等级名称、最小重量、包装重量等信息
 * - 统计表格：显示底部1和底部2的计数、平均值、设定值等数据
 * - 表格数量选择：支持3-6行的表格数量配置
 * - 数据操作：生成随机数据、清空数据等功能
 * 
 * 组件特点：
 * - 响应式设计：支持主题切换和样式更新
 * - 数据驱动：根据传入的数据动态显示表格内容
 * - 交互友好：提供直观的数据操作界面
 * - 类型安全：使用TypeScript接口确保类型安全
 * 
 * 使用方式：
 * ```typescript
 * LevelDataTable({
 *   levelData: this.levelData,
 *   statisticsData: this.statisticsData,
 *   tableCount: this.tableCount,
 *   onTableCountChange: (count: string) => { this.handleTableCountChange(count) },
 *   onGenerateRandomData: () => { this.handleGenerateRandomData() },
 *   onClearData: () => { this.handleClearData() }
 * })
 * ```
 * 
 * 布局说明：
 * - 使用Column布局垂直排列各个表格
 * - 每个表格使用独立的卡片容器
 * - 支持滚动显示，适应不同屏幕尺寸
 * - 右侧面板宽度：75%
 */

import { BaseComponentHelper } from '../../components/common/BaseComponent'
import { OmniThemeManager, OmniThemeType, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { OMNI_THEME_KEY, OMNI_THEME_TYPE_KEY, OMNI_THEME_VERSION_KEY, useOmniTheme } from '../../utils/theme/useOmniTheme'
import { LevelData, StatisticsData, TABLE_COUNT_OPTIONS, DEFAULT_LEVEL_DATA } from './LevelConstants'

/**
 * Select选项接口
 * 
 * 功能说明：
 * - 定义Select组件的选项数据结构
 * - 用于下拉选择框的选项配置
 * - 确保选项数据的类型安全
 * 
 * 属性说明：
 * - value: 选项的值，用于内部逻辑处理
 */
interface SelectOption {
  /** 选项的值（用于内部逻辑） */
  value: string
}

/**
 * 等级页面右侧数据表格组件结构体
 * 
 * 属性说明：
 * - levelData: 等级数据数组，默认空数组
 * - statisticsData: 统计数据对象
 * - tableCount: 表格数量，默认第一个选项
 * - onTableCountChange: 表格数量变化回调函数
 * - onGenerateRandomData: 生成随机数据回调函数
 * - onClearData: 清空数据回调函数
 * - consumedTheme: 当前主题样式
 * - consumedThemeType: 当前主题类型
 * - themeVersion: 主题版本号
 * - baseComponentHelper: 基础组件助手
 * - headerIndices: 表头索引数组
 * 
 * 方法说明：
 * - getCurrentTheme(): 获取当前主题配置
 * - build(): 构建数据表格的UI结构
 */
@Component
export struct LevelDataTable {
  // ==================== 数据属性 ====================
  /**
   * 等级数据数组
   * 
   * 功能说明：
   * - 存储等级表格的数据
   * - 默认值为空数组
   * - 从父组件传入，支持动态更新
   */
  @Prop levelData: LevelData[] = []
  
  /**
   * 统计数据对象
   * 
   * 功能说明：
   * - 存储统计表格的数据
   * - 包含底部1和底部2的各种数据
   * - 从父组件传入，支持动态更新
   */
  @Prop statisticsData: StatisticsData
  
  /**
   * 表格数量
   * 
   * 功能说明：
   * - 控制表格显示的行数
   * - 默认值为第一个选项
   * - 支持3-6行的表格数量配置
   */
  @Prop tableCount: string = TABLE_COUNT_OPTIONS[0].value

  // ==================== 事件回调函数 ====================
  /**
   * 表格数量变化回调函数
   * 
   * 功能说明：
   * - 当用户选择表格数量时触发
   * - 传递选中的表格数量给父组件
   * - 用于处理表格数量变化逻辑
   */
  onTableCountChange?: (count: string) => void
  
  /**
   * 生成随机数据回调函数
   * 
   * 功能说明：
   * - 当用户点击生成随机数据按钮时触发
   * - 用于处理生成随机数据逻辑
   */
  onGenerateRandomData?: () => void
  
  /**
   * 清空数据回调函数
   * 
   * 功能说明：
   * - 当用户点击清空数据按钮时触发
   * - 用于处理清空数据逻辑
   */
  onClearData?: () => void

  // ==================== 主题相关属性 ====================
  /**
   * 当前主题样式
   * 
   * 功能说明：
   * - 存储当前主题的样式配置
   * - 使用@StorageLink实现主题响应式更新
   * - 默认值为当前主题管理器的主题
   */
  @StorageLink(OMNI_THEME_KEY) consumedTheme: ExtendedOmniThemeStyle = OmniThemeManager.getInstance().getCurrentTheme()
  
  /**
   * 当前主题类型
   * 
   * 功能说明：
   * - 存储当前主题的类型
   * - 使用@StorageLink实现主题响应式更新
   * - 默认值为当前主题管理器的主题类型
   */
  @StorageLink(OMNI_THEME_TYPE_KEY) consumedThemeType: OmniThemeType = OmniThemeManager.getInstance().getCurrentThemeType()
  
  /**
   * 主题版本号
   * 
   * 功能说明：
   * - 存储主题的版本号
   * - 用于主题更新时的版本控制
   * - 默认值为0
   */
  @StorageLink(OMNI_THEME_VERSION_KEY) themeVersion: number = 0
  
  /**
   * 基础组件助手
   * 
   * 功能说明：
   * - 提供基础组件的通用功能
   * - 用于主题管理和样式配置
   * - 实例化BaseComponentHelper
   */
  private baseComponentHelper = new BaseComponentHelper()
  
  /**
   * 表头索引数组
   * 
   * 功能说明：
   * - 定义表格表头的索引
   * - 用于表格数据的显示和排序
   * - 包含0-7的索引值
   */
  private readonly headerIndices: number[] = [0, 1, 2, 3, 4, 5, 6, 7]

  // 右上卡片：根据"表格数量"联动的行（优先使用父级传入的 levelData，否则用默认数据占位）
  @State private topRightCount: number = 0
  private scroller: Scroller = new Scroller(); // 滚动控制器
  private lastTopRightCount: number = 0; // 记录上次的行数，用于检测变化

  private getTopRightRows(): LevelData[] {
    // 初始进入不展示任何数据；只有当用户在下拉框选择过后再联动
    const n = this.topRightActivated ? this.topRightCount : 0
    const source: LevelData[] = (Array.isArray(this.levelData) && this.levelData.length > 0)
      ? this.levelData
      : DEFAULT_LEVEL_DATA.map(item => ({
          levelName: item.levelName,
          minWeight: item.minWeight,
          packingWeight: item.packingWeight
        } as LevelData))
    return source.slice(0, n)
  }

  // 渲染单行的复用构建器
  @Builder
  private renderLevelRow(row: LevelData) {
    Row() {
      Text(row.levelName)
        .fontSize(20)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .layoutWeight(1)

      Text(`${row.minWeight}`)
        .fontSize(20)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .layoutWeight(1)

      Text(`${row.packingWeight}`)
        .fontSize(20)
        .fontColor(this.getCurrentTheme().textColor)
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .layoutWeight(1)
    }
    .width('100%')
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
  }

  /**
   * 获取当前主题配置
   * 
   * 功能说明：
   * - 从基础组件助手获取当前主题样式
   * - 用于组件样式配置
   * - 支持主题切换时的样式更新
   * 
   * @returns 当前主题的扩展样式对象
   */
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme(this.consumedTheme)
  }

  // 无需本地状态，直接由 props 衍生渲染
  @State private topRightActivated: boolean = false

  build() {
    Column() {
      // 卡片：承载等级数量与等级表
      Column() {
        // 内部卡片：清空内容（保留卡片样式与布局）
        Column() {
          // 顶部行：表格数量 + 下拉框（紧凑）
          Row() {
            Text('表格数量:')
              .fontSize(24)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ right: 6 })

            Select(TABLE_COUNT_OPTIONS.map(count => ({ value: count.value } as SelectOption)))
              .selected(TABLE_COUNT_OPTIONS.findIndex(count => count.value === this.tableCount))
              .font({ size: 16 })
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(4)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .constraintSize({ minWidth: 60, maxWidth: 120 })
              .height(26)
              .onSelect((index: number, value: string) => {
                if (this.onTableCountChange) {
                  this.onTableCountChange(value)
                }
                this.topRightActivated = true
                const n = Number(value)
                this.topRightCount = Number.isFinite(n) && n >= 0 ? Math.floor(n) : 0
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 10 })

          // 表格：表头 + 联动数据行
          Column() {
            // 表头
            Row() {
              Text('等级名称')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .layoutWeight(1)

              Text('最小重量(克)')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .layoutWeight(1)

              Text('装箱量（克）')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .layoutWeight(1)
            }
            .width('100%')
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
            .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

            // 数据行（从顶部开始依次向下，整体可滚动）
            Scroll(this.scroller) {
              Column() {
                ForEach(this.getTopRightRows(), (row: LevelData, idx: number) => {
                  this.renderLevelRow(row)
                })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')
            .layoutWeight(0.8)
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Auto)
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(8)
            .margin({ top: 8 })
          }
          .width('100%')
        }
        .width('100%')
        .height('90%')
        .padding(12)
        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(8)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
      }
      .width('100%')
      .height('52%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(10)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: 2 })

      // 右侧下方卡片：占比40%，显示第二个表格
      Column() {
        // 表格外层容器（含边框与圆角）
        Column() {
          // 表头（九列对齐：最左一列为"项"）
          Row() {
            Text('项')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.headerIndices, (idx: number) => {
              Text(`${idx}`)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')
          .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)

          // 六行数据（每个单元格都有边框，形成方块网格）
          Row() {
            Text('装箱数量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom1Counts, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')

          Row() {
            Text('平均重量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom1Avgs, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')

          Row() {
            Text('设置重量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom1Sets, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')

          Row() {
            Text('装箱数量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom2Counts, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')

          Row() {
            Text('平均重量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom2Avgs, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')

          Row() {
            Text('设置重量')
              .fontSize(18)
              .fontColor(this.getCurrentTheme().textColor)
              .textAlign(TextAlign.Center)
              .padding({ left: 2, right: 2, top: 2, bottom: 2 })
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .layoutWeight(1)
            ForEach(this.statisticsData.bottom2Sets, (val: number) => {
              Text(`${val}`)
                .fontSize(18)
                .fontColor(this.getCurrentTheme().textColor)
                .textAlign(TextAlign.Center)
                .padding({ left: 2, right: 2, top: 2, bottom: 2 })
                .border({ width: 1, color: this.getCurrentTheme().borderColor })
                .layoutWeight(1)
            })
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.getCurrentTheme().backgroundColor)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(8)
      }
      .width('100%')
      .height('40%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(10)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: 2 })

      // 右侧两个卡片下方的透明卡片：放置取消/确认按钮
      Column() {
        Row() {
          Blank().layoutWeight(1)
          Button('取消')
            .height(34)
            .fontSize(19)
            .fontColor('#000000')
            .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().backgroundColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(6)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              if (this.onClearData) {
                this.onClearData()
              }
            })
          Button('确认')
            .height(34)
            .fontSize(19)
            .margin({ left: 8 })
            .backgroundColor(this.getCurrentTheme().primary)
            .fontColor('#ffffff')
            .borderRadius(6)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .onClick(() => {
              if (this.onGenerateRandomData) {
                this.onGenerateRandomData()
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({ top: 8 })
      .backgroundColor('rgba(0,0,0,0)')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear(): void {
    // 初始化滚动位置到顶部
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.lastTopRightCount = this.topRightCount
  }

  aboutToRender(): void {
    // 当表格数量变化时，自动滚动到顶部
    if (this.topRightCount !== this.lastTopRightCount) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
      this.lastTopRightCount = this.topRightCount
    }
  }
}
