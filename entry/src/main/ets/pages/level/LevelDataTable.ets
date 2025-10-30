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
  @Prop @Watch('onExternalStatsChange') statisticsData: StatisticsData
  
  /**
   * 表格数量
   * 
   * 功能说明：
   * - 控制表格显示的行数
   * - 默认值为第一个选项
   * - 支持3-6行的表格数量配置
   */
  @Prop tableCount: string = TABLE_COUNT_OPTIONS[0].value
  /** 父组件传入的刷新驱动键（数值变化即触发刷新） */
  @Prop @Watch('onExternalStatsChange') refreshKey: number = 0
  /**
   * 统计表编辑回调：父组件接收单元格编辑并处理联动
   * row: 'bottom1' | 'bottom2'
   * field: 'count' | 'avg' | 'set'
   * colIndex: 0..7 对应8列
   * value: 新值（数字）
   */
  onEditStat?: (row: 'bottom1' | 'bottom2', field: 'count' | 'avg' | 'set', colIndex: number, value: number) => void

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

  /**
   * 最小重量输入数组（受控输入）
   */
  @State private minWeightInputs: string[] = []

  /**
   * 装箱量输入数组（受控输入）
   */
  @State private packingWeightInputs: string[] = []

  /**
   * 控制每行是否显示+/-按钮
   * 
   * 功能说明：
   * - 控制每行是否显示添加/删除按钮
   * - 当用户点击最小重量列时显示按钮
   * - 支持动态切换按钮显示状态
   */
  @State private showAddRemoveButtons: boolean[] = []

  /**
   * 当前选中的行索引
   * 
   * 功能说明：
   * - 记录当前用户选中的行索引
   * - 用于控制按钮的显示和隐藏
   * - 支持单选模式
   */
  @State private selectedRowIndex: number = -1
  @State private forceRefresh: number = 0 // 强制刷新UI

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
  @State private statsRefreshTick: number = 0
  // 输入缓冲，避免 onChange 直接触发父级重建导致焦点跳动
  @State private bufB1Counts: number[] = []
  @State private bufB1Avgs: number[] = []
  @State private bufB1Sets: number[] = []
  @State private bufB2Counts: number[] = []
  @State private bufB2Avgs: number[] = []
  @State private bufB2Sets: number[] = []


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
   * 组件更新时同步最新的统计数据到内表
   * - 当父组件传入的 statisticsData 发生变化时，重建 statisticsTableData
   */
  aboutToUpdate(): void {
    this.initializeStatisticsData()
    this.statsRefreshTick++
    console.log('【等级页面】表格更新：已重建统计数据', JSON.stringify(this.statisticsTableData))
  }

  /**
   * 外部统计数据或刷新键变化时的回调
   */
  private onExternalStatsChange(): void {
    this.initializeStatisticsData()
    this.statsRefreshTick++
    console.log('【等级页面】收到外部统计变化：已重建统计数据', JSON.stringify(this.statisticsTableData))
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
    this.minWeightInputs = []
    this.packingWeightInputs = []

    for (let i = 0; i < levelCount; i++) {
      // 若父组件未提供具体字段，这里先用占位生成名称（1..N），避免空白
      this.levelTableData.push({
        id: i + 1,
        levelName: `${i + 1}`,
        minWeight: 100 - i * 5,
        packingWeight: 500 + i * 50
      })
      this.levelNameInputs.push(`${i + 1}`)
      this.minWeightInputs.push(`${100 - i * 5}`)
      this.packingWeightInputs.push(`${500 + i * 50}`)
      this.showAddRemoveButtons.push(false) // 初始化按钮显示状态
    }
  }

  /**
   * 处理最小重量列点击事件
   * 
   * 功能说明：
   * - 当用户点击最小重量列时显示+/-按钮
   * - 隐藏其他行的按钮，只显示当前行的按钮
   * - 支持切换按钮显示状态
   * 
   * @param index 行索引
   */
  private handleMinWeightClick(index: number): void {
    // 如果点击的是当前选中的行，则不做任何操作（保持按钮显示）
    if (this.selectedRowIndex === index) {
      return // 点击同一行时保持按钮显示，不做任何操作
    } else {
      // 隐藏所有按钮，然后显示当前行的按钮
      this.showAddRemoveButtons = this.showAddRemoveButtons.map(() => false)
      this.showAddRemoveButtons[index] = true
      this.selectedRowIndex = index
    }
  }

  /**
   * 添加新行
   * 
   * 功能说明：
   * - 在指定位置后添加新的等级行
   * - 自动生成新的等级名称和默认值
   * - 更新所有相关的数组
   * - 插入后重新排序所有等级名称，确保连续性
   * 
   * @param index 插入位置（在指定行后插入）
   */
  private addNewRow(index: number): void {
    const newId = Math.max(...this.levelTableData.map(item => item.id)) + 1
    const newMinWeight = 100 - (this.levelTableData.length * 5)
    const newPackingWeight = 500 + (this.levelTableData.length * 50)
    
    // 在指定位置后插入新行
    const insertIndex = index + 1
    this.levelTableData.splice(insertIndex, 0, {
      id: newId,
      levelName: '0', // 临时名称，稍后会重新排序
      minWeight: newMinWeight,
      packingWeight: newPackingWeight
    })
    
    // 更新输入数组
    this.levelNameInputs.splice(insertIndex, 0, '0') // 临时名称
    this.minWeightInputs.splice(insertIndex, 0, `${newMinWeight}`)
    this.packingWeightInputs.splice(insertIndex, 0, `${newPackingWeight}`)
    this.showAddRemoveButtons.splice(insertIndex, 0, false)
    
    // 重新排序所有等级名称，确保连续性（1, 2, 3, 4...）
    for (let i = 0; i < this.levelTableData.length; i++) {
      const newLevelName = `${i + 1}`
      this.levelTableData[i].levelName = newLevelName
      this.levelNameInputs[i] = newLevelName
    }
    
    // 更新等级数量选择器 - 直接使用行数作为索引
    this.levelCountIndex = this.levelTableData.length
    
    // 强制刷新UI - 重新创建数组引用以触发UI更新
    // 先清空数组，再重新赋值，确保UI完全刷新
    const tempLevelTableData = [...this.levelTableData]
    const tempLevelNameInputs = [...this.levelNameInputs]
    const tempMinWeightInputs = [...this.minWeightInputs]
    const tempPackingWeightInputs = [...this.packingWeightInputs]
    const tempShowAddRemoveButtons = [...this.showAddRemoveButtons]
    
    // 清空原数组
    this.levelTableData = []
    this.levelNameInputs = []
    this.minWeightInputs = []
    this.packingWeightInputs = []
    this.showAddRemoveButtons = []
    
    // 重新赋值
    this.levelTableData = tempLevelTableData
    this.levelNameInputs = tempLevelNameInputs
    this.minWeightInputs = tempMinWeightInputs
    this.packingWeightInputs = tempPackingWeightInputs
    this.showAddRemoveButtons = tempShowAddRemoveButtons
    
    // 强制刷新UI
    this.forceRefresh++
    
    // 保持当前行的按钮显示状态，不隐藏按钮
    // 这样用户可以看到添加成功，并且可以继续操作
    
    console.log(`在位置${insertIndex}添加了新行，等级名称已重新排序:`, this.levelTableData.map(item => item.levelName))
  }

  /**
   * 删除指定行
   * 
   * 功能说明：
   * - 删除指定索引的等级行
   * - 更新所有相关的数组
   * - 确保至少保留一行数据
   * - 删除后重新排序所有等级名称，确保连续性
   * 
   * @param index 要删除的行索引
   */
  private removeRow(index: number): void {
    // 确保至少保留一行
    if (this.levelTableData.length <= 1) {
      console.log('至少需要保留一行数据')
      return
    }
    
    // 删除指定行
    this.levelTableData.splice(index, 1)
    this.levelNameInputs.splice(index, 1)
    this.minWeightInputs.splice(index, 1)
    this.packingWeightInputs.splice(index, 1)
    this.showAddRemoveButtons.splice(index, 1)
    
    // 重新排序所有等级名称，确保连续性（1, 2, 3, 4...）
    for (let i = 0; i < this.levelTableData.length; i++) {
      const newLevelName = `${i + 1}`
      this.levelTableData[i].levelName = newLevelName
      this.levelNameInputs[i] = newLevelName
    }
    
    // 更新等级数量选择器
    this.levelCountIndex = this.levelTableData.length
    
    // 保持按钮显示状态，让用户可以继续操作
    // 如果删除的是当前选中行，则清除选中状态
    if (this.selectedRowIndex === index) {
      this.selectedRowIndex = -1
      this.showAddRemoveButtons = this.showAddRemoveButtons.map(() => false)
    } else if (this.selectedRowIndex > index) {
      // 如果删除的行在当前选中行之前，需要调整选中索引
      this.selectedRowIndex = this.selectedRowIndex - 1
    }
    
    console.log(`删除了位置${index}的行，等级名称已重新排序:`, this.levelTableData.map(item => item.levelName))
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
        .width('20%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 4 })

      Divider().vertical(true).height(30).color(this.getCurrentTheme().borderColor)

      // 最小重量列
      Text('最小重量（克）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .width('40%')
        .textAlign(TextAlign.Center)
        .padding({ top: 4, bottom: 4 })

      Divider().vertical(true).height(30).color(this.getCurrentTheme().borderColor)

      // 装箱量列
      Text('装箱量（克）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCurrentTheme().textColor)
        .width('40%')
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
      // 等级名称列（只读显示）
      Text(`${this.levelNameInputs[index] || data.levelName}`)
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .width('20%')
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .id(`levelName_${data.id}_${index}_${this.forceRefresh}`) // 添加强制刷新ID

      Divider().vertical(true).height(80).color(this.getCurrentTheme().borderColor) //修改第一个分割线的高度

      // 最小重量列（可编辑，带+/-按钮）
      Row() {
        TextInput({ text: this.minWeightInputs[index] ?? `${data.minWeight}` })
          .fontSize(16)
          .fontColor(this.getCurrentTheme().textColor)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ left: 4, right: 4, top: 6, bottom: 6 })
          .border({ width: 0 })
          .type(InputType.Number)
          .onChange((value: string) => {
            const numericStr = value.replace(/[^0-9.\-]/g, '')
            this.minWeightInputs[index] = numericStr
            const parsed = Number(numericStr)
            if (!isNaN(parsed)) {
              this.levelTableData[index].minWeight = parsed
            }
          })
          .onClick(() => {
            this.handleMinWeightClick(index)
          })
          .onBlur(() => {
            // 失去焦点时隐藏按钮
            this.showAddRemoveButtons = this.showAddRemoveButtons.map(() => false)
            this.selectedRowIndex = -1
          })

        // +/- 按钮区域
        if (this.showAddRemoveButtons[index]) {
          Row() {
            // + 按钮
            Button() {
              Text('+')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().textColor)
            }
            .width(24)
            .height(24)
            .backgroundColor(this.getCurrentTheme().primary)
            .borderRadius(12)
            .onClick(() => {
              this.addNewRow(index)
            })

            // - 按钮
            Button() {
              Text('-')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().textColor)
            }
            .width(24)
            .height(24)
            .backgroundColor('#FF5722')
            .borderRadius(12)
            .margin({ left: 4 })
            .onClick(() => {
              this.removeRow(index)
            })
          }
          .margin({ left: 8 })
        }
      }
      .width('40%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Divider().vertical(true).height(80).color(this.getCurrentTheme().borderColor) //修改第二个分割线的高度

      // 装箱量列（可编辑）
      TextInput({ text: this.packingWeightInputs[index] ?? `${data.packingWeight}` })
        .fontSize(16)
        .fontColor(this.getCurrentTheme().textColor)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .width('40%')
        .textAlign(TextAlign.Center)
        .padding({ left: 4, right: 4, top: 6, bottom: 6 })
        .border({ width: 0 })
        .type(InputType.Number)
        .onChange((value: string) => {
          const numericStr = value.replace(/[^0-9.\-]/g, '')
          this.packingWeightInputs[index] = numericStr
          const parsed = Number(numericStr)
          if (!isNaN(parsed)) {
            this.levelTableData[index].packingWeight = parsed
          }
        })
    }
    .width('100%')
    .height(50)  //修改表格每一行的行高
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
    const b1Counts = this.statisticsData.bottom1Counts || []
    const b1Sets = this.statisticsData.bottom1Sets || []
    const b1AvgsComputed = b1Counts.map((cnt, i) => {
      const setVal = b1Sets[i] ?? 0
      return cnt > 0 ? Math.round(setVal / cnt) : (this.statisticsData.bottom1Avgs?.[i] ?? 0)
    })

    const b2Counts = this.statisticsData.bottom2Counts || []
    const b2Sets = this.statisticsData.bottom2Sets || []
    const b2AvgsComputed = b2Counts.map((cnt, i) => {
      const setVal = b2Sets[i] ?? 0
      return cnt > 0 ? Math.round(setVal / cnt) : (this.statisticsData.bottom2Avgs?.[i] ?? 0)
    })

    this.statisticsTableData = [
      { id: 1, itemName: '装箱数量', values: b1Counts },
      { id: 2, itemName: '平均重量', values: b1AvgsComputed },
      { id: 3, itemName: '设置重量', values: b1Sets },
      { id: 4, itemName: '装箱数量', values: b2Counts },
      { id: 5, itemName: '平均重量', values: b2AvgsComputed },
      { id: 6, itemName: '设置重量', values: b2Sets }
    ]

    // 同步缓冲
    this.bufB1Counts = b1Counts.slice()
    this.bufB1Avgs = b1AvgsComputed.slice()
    this.bufB1Sets = b1Sets.slice()
    this.bufB2Counts = b2Counts.slice()
    this.bufB2Avgs = b2AvgsComputed.slice()
    this.bufB2Sets = b2Sets.slice()
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
      this.getCurrentTheme().surfaceColor)
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
        // 数据单元格（第0列为项目名只读，其余列可编辑数值）
        if (index === 0) {
          Text(item.itemName)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .textAlign(TextAlign.Center)
        } else {
          TextInput({ text: ((index - 1) < item.values.length ? `${item.values[index - 1]}` : '') })
            .type(InputType.Number)
            .fontSize(14)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().surfaceColor)
            .textAlign(TextAlign.Center)
            .border({ width: 0 })
            // 输入过程中仅更新缓冲，避免父组件重建导致焦点跳动
            .onChange((raw: string) => {
              const numeric = raw.replace(/[^0-9.\-]/g, '')
              const parsed = Number(numeric)
              if (isNaN(parsed)) { return }
              const vi = index - 1
              switch (item.id) {
                case 1: this.bufB1Counts[vi] = Math.max(0, Math.floor(parsed)); break
                case 2: this.bufB1Avgs[vi] = Math.max(0, Math.round(parsed)); break
                case 3: this.bufB1Sets[vi] = Math.max(0, Math.floor(parsed)); break
                case 4: this.bufB2Counts[vi] = Math.max(0, Math.floor(parsed)); break
                case 5: this.bufB2Avgs[vi] = Math.max(0, Math.round(parsed)); break
                case 6: this.bufB2Sets[vi] = Math.max(0, Math.floor(parsed)); break
              }
            })
            // 仅在回车提交时把缓冲写回父组件
            .onSubmit((enterKey: EnterKeyType) => {
              const vi = index - 1
              let row: 'bottom1' | 'bottom2' = 'bottom1'
              let field: 'count' | 'avg' | 'set' = 'count'
              let value = 0
              switch (item.id) {
                case 1: row = 'bottom1'; field = 'count'; value = this.bufB1Counts[vi] || 0; break
                case 2: row = 'bottom1'; field = 'avg'; value = this.bufB1Avgs[vi] || 0; break
                case 3: row = 'bottom1'; field = 'set'; value = this.bufB1Sets[vi] || 0; break
                case 4: row = 'bottom2'; field = 'count'; value = this.bufB2Counts[vi] || 0; break
                case 5: row = 'bottom2'; field = 'avg'; value = this.bufB2Avgs[vi] || 0; break
                case 6: row = 'bottom2'; field = 'set'; value = this.bufB2Sets[vi] || 0; break
              }
              if (this.onEditStat) { this.onEditStat(row, field, vi, value) }
            })
        }
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
              .selected(this.levelCountIndex)
              .value(this.levelCountIndex.toString())
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
              .onAxisEvent((event?: AxisEvent) => {
                if (event) {
                  const verticalValue = event.getVerticalAxisValue()
                  const horizontalValue = event.getHorizontalAxisValue()
                  
                  console.log('🎡 等级页面滚轮事件触发 - 垂直值:', verticalValue, '水平值:', horizontalValue)
                  
                  // 处理垂直滚轮事件
                  if (Math.abs(verticalValue) > Math.abs(horizontalValue)) {
                    console.log('✅ 进入等级页面垂直滚轮处理逻辑')
                    
                    // 基于当前等级数量进行增减
                    const currentCount = this.levelCountIndex
                    let newCount = currentCount
                    
                    if (verticalValue > 0) {
                      // 向上滚动，等级数量 +1（增加）
                      newCount = Math.min(currentCount + 1, 10)
                      console.log(`⬆️ 等级页面向上滚动，从 ${currentCount} 到 ${newCount}`)
                    } else if (verticalValue < 0) {
                      // 向下滚动，等级数量 -1（减少）
                      newCount = Math.max(currentCount - 1, 0)
                      console.log(`⬇️ 等级页面向下滚动，从 ${currentCount} 到 ${newCount}`)
                    }
                    
                    if (newCount !== currentCount) {
                      this.levelCountIndex = newCount
                      this.initializeLevelData()
                      console.log(`✅ 等级页面等级数量已更新为: ${newCount}`)
                    }
                  }
                }
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
        .onClick(() => {
          // 点击表格外部区域时隐藏所有+/-按钮
          this.showAddRemoveButtons = this.showAddRemoveButtons.map(() => false)
          this.selectedRowIndex = -1
        })
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
