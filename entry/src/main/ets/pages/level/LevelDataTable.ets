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
 * 统计表格数据项接口
 * 
 * 功能说明：
 * - 定义统计表格中每个单元格的数据结构
 * - 用于Grid组件的表格显示
 * - 支持9列数据（1列项目名称 + 8列数值）
 */
interface StatisticsTableItem {
  /** 数据项的唯一标识 */
  id: number
  /** 项目名称 */
  itemName: string
  /** 8列数据值 */
  values: number[]
}

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
 * Grid表格数据项接口
 * 
 * 功能说明：
 * - 定义Grid表格中每个数据项的结构
 * - 包含等级、重量、状态等信息
 * - 用于Grid表格的数据展示
 * 
 * 属性说明：
 * - id: 数据项的唯一标识
 * - level: 等级编号
 * - weight: 重量信息
 * - status: 状态信息
 */
interface GridTableItem {
  /** 数据项的唯一标识 */
  id: number
  /** 等级编号 */
  level: string
  /** 重量信息 */
  weight: string
  /** 状态信息 */
  status: string
}

/**
 * 等级表格数据项接口
 * 
 * 功能说明：
 * - 定义等级表格中每个数据项的结构
 * - 包含等级名称、最小重量、装箱量等信息
 * - 用于List+ListItem表格的数据展示
 * 
 * 属性说明：
 * - id: 数据项的唯一标识
 * - levelName: 等级名称（可编辑）
 * - minWeight: 最小重量（克）
 * - packingWeight: 装箱量（克）
 */
interface LevelTableData {
  /** 数据项的唯一标识 */
  id: number
  /** 等级名称（可编辑） */
  levelName: string
  /** 最小重量（克） */
  minWeight: number
  /** 装箱量（克） */
  packingWeight: number
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

  /**
   * 等级数量索引
   * 
   * 功能说明：
   * - 控制品质表格显示的等级数量
   * - 默认值为0（不显示）
   * - 支持0-16个等级的选择
   */

  // ==================== 等级表格相关 ====================
  
  /**
   * 等级数量索引
   * 
   * 功能说明：
   * - 控制等级表格显示的等级数量
   * - 默认值为0（2个等级）
   * - 支持2-7个等级的选择
   */
  @State private levelCountIndex: number = 0

  /**
   * 等级表格数据
   * 
   * 功能说明：
   * - 存储等级表格要显示的数据
   * - 包含等级名称、最小重量、装箱量等信息
   * - 支持动态更新和编辑
   */
  @State private levelTableData: LevelTableData[] = []

  /**
   * 等级名称输入数组
   * 
   * 功能说明：
   * - 存储等级名称的输入值
   * - 用于TextInput的受控组件
   * - 支持实时编辑和验证
   */
  @State private levelNameInputs: string[] = []

  // ==================== Grid表格相关 ====================
  
  /**
   * Grid表格数据
   * 
   * 功能说明：
   * - 存储Grid表格要显示的数据
   * - 包含等级、重量、状态等信息
   * - 支持动态更新
   */
  @State private gridTableData: GridTableItem[] = [
    { id: 1, level: '1', weight: '100g', status: '正常' },
    { id: 2, level: '2', weight: '95g', status: '正常' },
    { id: 3, level: '3', weight: '90g', status: '正常' },
    { id: 4, level: '4', weight: '85g', status: '正常' },
    { id: 5, level: '5', weight: '80g', status: '正常' },
    { id: 6, level: '6', weight: '75g', status: '正常' },
    { id: 7, level: '7', weight: '70g', status: '正常' },
    { id: 8, level: '8', weight: '65g', status: '正常' },
    { id: 9, level: '9', weight: '60g', status: '正常' },
    { id: 10, level: '10', weight: '55g', status: '正常' },
    { id: 11, level: '11', weight: '50g', status: '正常' },
    { id: 12, level: '12', weight: '45g', status: '正常' },
    { id: 13, level: '13', weight: '40g', status: '正常' },
    { id: 14, level: '14', weight: '35g', status: '正常' },
    { id: 15, level: '15', weight: '30g', status: '正常' },
    { id: 16, level: '16', weight: '25g', status: '正常' }
  ]

  /**
   * 统计表格数据
   * 
   * 功能说明：
   * - 存储统计表格要显示的数据
   * - 包含6行数据：装箱数量、平均重量、设置重量（底部1和底部2各3行）
   * - 支持动态更新
   */
  @State private statisticsTableData: StatisticsTableItem[] = []


  // ==================== 生命周期方法 ====================
  /**
   * 组件即将出现时的生命周期方法
   * 
   * 功能说明：
   * - 初始化统计表格数据
   * - 将statisticsData转换为Grid表格格式
   */
  aboutToAppear(): void {
    this.initializeStatisticsData()
    this.initializeLevelData()
  }

  /**
   * 初始化等级表格数据
   * 
   * 功能说明：
   * - 根据等级数量创建等级表格数据
   * - 初始化等级名称输入数组
   * - 设置默认的等级名称、最小重量、装箱量
   */
  private initializeLevelData(): void {
    // 优先使用父组件传入数据长度；若父组件未传入，则使用本卡片选择的数量（索引即数量：0-10）
    const propCount = Array.isArray(this.levelData) ? this.levelData.length : 0
    const levelCount = propCount > 0 ? propCount : this.levelCountIndex

    if (levelCount <= 0) {
      this.levelTableData = []
      this.levelNameInputs = []
      return
    }

    this.levelTableData = []
    this.levelNameInputs = []

    for (let i = 0; i < levelCount; i++) {
      // 若父组件未提供具体字段，这里先用占位生成名称（1..N），避免空白
      this.levelTableData.push({
        id: i + 1,
        levelName: `${i + 1}`,
        minWeight: 100 - i * 5,
        packingWeight: 500 + i * 50
      })
      this.levelNameInputs.push(`${i + 1}`)
    }
  }

  /**
   * 构建等级表格表头
   * 
   * 功能说明：
   * - 构建固定表头：等级名称|最小重量（克）|装箱量（克）
   * - 表头固定不滚动
   */
  @Builder
  buildLevelTableHeader() {
    Row() {
      // 等级名称列
      Text('等级名称')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 4 })

      Divider().vertical(true).height(30).color(this.getCurrentTheme().borderColor)

      // 最小重量列
      Text('最小重量（克）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 4 })

      Divider().vertical(true).height(30).color(this.getCurrentTheme().borderColor)

      // 装箱量列
      Text('装箱量（克）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 4 })
    }
    .width('100%')
    .height(40)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
    .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
  }

  /**
   * 构建等级表格数据行
   * 
   * 功能说明：
   * - 构建数据行：等级名称（可编辑）|最小重量|装箱量
   * - 支持等级名称的实时编辑
   */
  @Builder
  buildLevelListItem(data: LevelTableData, index: number) {
    Row() {
      // 等级名称列（可编辑）
      TextInput({ text: this.levelNameInputs[index] || '' })
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .border({ width: 0 })
        .type(InputType.Number)
        .onChange((value: string) => {
          const numericValue = value.replace(/\D+/g, '')
          this.levelNameInputs[index] = numericValue
          this.levelTableData[index].levelName = numericValue
        })

      Divider().vertical(true).height(40).color(this.getCurrentTheme().borderColor)

      // 最小重量列
      Text(`${data.minWeight}`)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })

      Divider().vertical(true).height(40).color(this.getCurrentTheme().borderColor)

      // 装箱量列
      Text(`${data.packingWeight}`)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .width('33.33%')
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    }
    .width('100%')
    .height(60)
    .padding(0)
    .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })
  }

  /**
   * 初始化统计表格数据
   * 
   * 功能说明：
   * - 将statisticsData转换为StatisticsTableItem格式
   * - 创建6行数据：底部1和底部2的各3行数据
   */
  private initializeStatisticsData(): void {
    this.statisticsTableData = [
      {
        id: 1,
        itemName: '装箱数量',
        values: this.statisticsData.bottom1Counts
      },
      {
        id: 2,
        itemName: '平均重量',
        values: this.statisticsData.bottom1Avgs
      },
      {
        id: 3,
        itemName: '设置重量',
        values: this.statisticsData.bottom1Sets
      },
      {
        id: 4,
        itemName: '装箱数量',
        values: this.statisticsData.bottom2Counts
      },
      {
        id: 5,
        itemName: '平均重量',
        values: this.statisticsData.bottom2Avgs
      },
      {
        id: 6,
        itemName: '设置重量',
        values: this.statisticsData.bottom2Sets
      }
    ]
  }

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

  /**
   * 构建Grid表格单元格
   * 
   * 功能说明：
   * - 构建Grid表格中的单个单元格
   * - 根据位置显示不同的内容（表头或数据）
   * - 支持主题适配和样式配置
   * 
   * @param item 数据项
   * @param index 索引位置
   * @param isHeader 是否为表头
   * @returns Grid单元格组件
   */
  @Builder
  private buildGridCell(item: GridTableItem | null, index: number, isHeader: boolean = false) {
    Column() {
      if (isHeader) {
        // 表头单元格
        Text(this.getHeaderText(index))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
      } else if (item) {
        // 数据单元格
        Text(this.getCellText(item, index))
          .fontSize(14)
          .fontColor(this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .height(40)
    .backgroundColor(isHeader ? 
      (this.getCurrentTheme().primary + '20') : 
      (index % 2 === 0 ? this.getCurrentTheme().backgroundColor : this.getCurrentTheme().surfaceColor))
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 获取表头文本
   * 
   * @param index 列索引
   * @returns 表头文本
   */
  private getHeaderText(index: number): string {
    const headers = ['等级', '重量', '状态']
    return headers[index] || ''
  }

  /**
   * 获取单元格文本
   * 
   * @param item 数据项
   * @param index 列索引
   * @returns 单元格文本
   */
  private getCellText(item: GridTableItem, index: number): string {
    switch (index) {
      case 0: return item.level
      case 1: return item.weight
      case 2: return item.status
      default: return ''
    }
  }

  /**
   * 构建统计表格单元格
   * 
   * 功能说明：
   * - 创建统计表格的单元格内容
   * - 支持表头和数据单元格
   * - 9列布局：1列项目名称 + 8列数据
   * 
   * @param item 统计表格数据项
   * @param index 列索引
   * @param isHeader 是否为表头
   */
  @Builder
  private buildStatisticsCell(item: StatisticsTableItem | null, index: number, isHeader: boolean = false) {
    Column() {
      if (isHeader) {
        // 表头单元格
        Text(this.getStatisticsHeaderText(index))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
      } else if (item) {
        // 数据单元格
        Text(this.getStatisticsCellText(item, index))
          .fontSize(14)
          .fontColor(this.getCurrentTheme().textColor)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .height(40)
    .backgroundColor(isHeader ?
      (this.getCurrentTheme().primary + '20') :
      (index % 2 === 0 ? this.getCurrentTheme().backgroundColor : this.getCurrentTheme().surfaceColor))
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 获取统计表格表头文本
   * 
   * 功能说明：
   * - 返回指定列索引的表头文本
   * - 第0列显示"项"，第1-8列显示数字索引
   * 
   * @param index 列索引
   * @returns 表头文本
   */
  private getStatisticsHeaderText(index: number): string {
    if (index === 0) {
      return '项'
    } else {
      return `${index - 1}`
    }
  }

  /**
   * 获取统计表格单元格文本
   * 
   * 功能说明：
   * - 返回指定数据项和列索引的单元格文本
   * - 第0列显示项目名称，第1-8列显示对应的数值
   * 
   * @param item 统计表格数据项
   * @param index 列索引
   * @returns 单元格文本
   */
  private getStatisticsCellText(item: StatisticsTableItem, index: number): string {
    if (index === 0) {
      return item.itemName
    } else {
      const valueIndex = index - 1
      return valueIndex < item.values.length ? `${item.values[valueIndex]}` : ''
    }
  }





  build() {
    Column() {

      // 右侧上方卡片：占比55%
      Column() {
        // 控制面板：等级数量选择
        Column() {
          Row() {
            // 等级数量标签
            Text('等级数量:')
              .fontSize(24)
              .fontColor(this.getCurrentTheme().textColor)
              .margin({ right: 8 })

            // 等级数量选择器
            Select([
              { value: '0' }, { value: '1' }, { value: '2' }, { value: '3' }, { value: '4' },
              { value: '5' }, { value: '6' }, { value: '7' }, { value: '8' }, { value: '9' }, { value: '10' }
            ])
              .selected(0)
              .font({ size: 22 })
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
              .border({ width: 1, color: this.getCurrentTheme().borderColor })
              .borderRadius(6)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .width('40%')
              .onSelect((index: number) => {
                this.levelCountIndex = index
                this.initializeLevelData()
                console.log('等级数量选择:', index)
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(12)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.15)', offsetY: 2 })
        .margin({ bottom: 16 })
        
        // 等级表格：使用List+ListItem实现
        Column() {
          // 固定表头
          this.buildLevelTableHeader()

          // 可滚动数据区域 - 使用List组件
          List() {
            ForEach(this.levelTableData, (data: LevelTableData, index: number) => {
              ListItem() {
                this.buildLevelListItem(data, index)
              }
            }, (data: LevelTableData, index: number) => `${index}`)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .friction(100)
          .divider({
            strokeWidth: 1,
            color: this.getCurrentTheme().borderColor,
            startMargin: 0,
            endMargin: 0
          })
        }
        .width('100%')
        .layoutWeight(1)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(8)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
      }
      .width('100%')
      .height('70%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(10)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: 2 })
      .margin({ bottom: 16 })

      // 统计表格卡片：使用Grid组件实现的表格
      Column() {

        // 表格容器：表头固定 + 数据滚动
        Column() {
          // 固定表头
          Grid() {
            ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (colIndex: number) => {
              GridItem() {
                this.buildStatisticsCell(null, colIndex, true)
              }
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr') // 9列等宽
          .columnsGap(1)
          .rowsGap(1)
          .width('100%')
          .height(40) // 表头固定高度
          .border({ width: { bottom: 1 }, color: this.getCurrentTheme().borderColor })

          // 可滚动的数据区域
          Scroll() {
            Grid() {
              // 数据行
              ForEach(this.statisticsTableData, (item: StatisticsTableItem) => {
                ForEach([0, 1, 2, 3, 4, 5, 6, 7, 8], (colIndex: number) => {
                  GridItem() {
                    this.buildStatisticsCell(item, colIndex, false)
                  }
                })
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr') // 9列等宽
            .columnsGap(1)
            .rowsGap(1)
            .width('100%')
            .height(this.statisticsTableData.length * 40) // 数据区域高度：数据行数 × 每行高度
          }
          .width('100%')
          .height(240) // 数据区域固定高度：总高度280 - 表头40 = 240
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
        }
        .width('100%')
        .height(280) // 总容器高度
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(8)
      }
      .width('100%')
      .height('30%')
      .padding(16)
      .backgroundColor(this.getCurrentTheme().controlBg ?? this.getCurrentTheme().surfaceColor)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .borderRadius(10)
      .shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: 2 })
      .margin({ bottom: 16 })

      .padding({ top: 8 })
      .backgroundColor('rgba(0,0,0,0)')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }



}
