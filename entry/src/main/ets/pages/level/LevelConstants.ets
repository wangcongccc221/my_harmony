/**
 * 等级页面常量配置文件
 * 
 * 功能说明：
 * - 存储等级页面相关的所有常量、配置数据和接口定义
 * - 统一管理等级页面的配置信息，提高代码的可维护性
 * - 提供类型安全的接口定义，确保数据的一致性
 * 
 * 包含内容：
 * - 水果类型配置：支持的水果种类选项
 * - 分选标准配置：分选过程中使用的标准选项
 * - 计算单位配置：重量和数量的计算单位
 * - 表格数量配置：数据表格的行数配置
 * - 默认数据配置：等级数据、统计数据、设置状态的默认值
 * - 布局配置：页面布局的尺寸配置
 * - 数据接口：等级数据和统计数据的类型定义
 * 
 * 使用方式：
 * ```typescript
 * import { FRUIT_TYPES, DEFAULT_LEVEL_DATA, LevelData } from './LevelConstants'
 * 
 * // 使用水果类型选项
 * const fruits = FRUIT_TYPES
 * 
 * // 使用默认等级数据
 * const defaultData = DEFAULT_LEVEL_DATA
 * 
 * // 使用类型接口
 * const levelData: LevelData = { levelName: 'A级', minWeight: 120, packingWeight: 5000 }
 * ```
 * 
 * 维护说明：
 * - 新增水果类型时，在 FRUIT_TYPES 中添加
 * - 修改分选标准时，在 SORTING_STANDARDS 中更新
 * - 调整默认数据时，在对应的 DEFAULT_* 常量中修改
 * - 新增配置项时，先定义接口，再添加常量
 */

/**
 * 水果类型配置接口
 * 
 * 功能说明：
 * - 定义水果类型的数据结构
 * - 用于水果选择下拉框的选项配置
 * - 支持扩展新的水果类型
 * 
 * 属性说明：
 * - value: 水果类型的值，用于内部逻辑处理
 * - label: 水果类型的显示标签，用于UI展示
 */
export interface FruitType {
  /** 水果类型的值（用于内部逻辑） */
  value: string
  /** 水果类型的显示标签（用于UI展示） */
  label: string
}

/**
 * 水果类型选项常量
 * 
 * 功能说明：
 * - 提供等级页面支持的水果类型选项
 * - 用于水果选择下拉框的数据源
 * - 支持苹果、香蕉、橙子、葡萄四种水果类型
 * 
 * 使用场景：
 * - 用户选择水果类型时
 * - 初始化水果选择器时
 * - 验证水果类型时
 * 
 * 扩展方式：
 * - 在数组中添加新的水果类型对象
 * - 确保 value 和 label 的值一致
 */
export const FRUIT_TYPES: FruitType[] = [
  { value: '苹果', label: '苹果' },
  { value: '香蕉', label: '香蕉' },
  { value: '橙子', label: '橙子' },
  { value: '葡萄', label: '葡萄' }
]

/**
 * 分选标准配置接口
 * 
 * 功能说明：
 * - 定义分选标准的数据结构
 * - 用于分选标准选择器的选项配置
 * - 支持按组分类的分选标准
 * 
 * 属性说明：
 * - key: 分选标准的唯一标识，用于内部逻辑处理
 * - label: 分选标准的显示标签，用于UI展示
 * - group: 分选标准的分组，用于分类管理
 */
export interface SortingStandard {
  /** 分选标准的唯一标识（用于内部逻辑） */
  key: string
  /** 分选标准的显示标签（用于UI展示） */
  label: string
  /** 分选标准的分组（用于分类管理） */
  group: string
}

/**
 * 分选标准选项常量
 * 
 * 功能说明：
 * - 提供等级页面支持的分选标准选项
 * - 用于分选标准选择器的数据源
 * - 支持尺寸、重量、直径、面积、体积五种分选标准
 * 
 * 分组说明：
 * - size: 尺寸相关标准
 * - weight: 重量相关标准
 * - diameter: 直径相关标准
 * - area: 面积相关标准
 * - volume: 体积相关标准
 * 
 * 使用场景：
 * - 用户选择分选标准时
 * - 初始化分选标准选择器时
 * - 验证分选标准时
 */
export const SORTING_STANDARDS: SortingStandard[] = [
  { key: 'size', label: '尺寸', group: 'size' },
  { key: 'weight', label: '重量', group: 'weight' },
  { key: 'diameter', label: '直径', group: 'diameter' },
  { key: 'area', label: '面积', group: 'area' },
  { key: 'volume', label: '体积', group: 'volume' }
]

/**
 * 计算单位配置接口
 * 
 * 功能说明：
 * - 定义计算单位的数据结构
 * - 用于单位选择下拉框的选项配置
 * - 支持重量和数量两种计算单位
 * 
 * 属性说明：
 * - value: 单位的内部值，用于计算逻辑
 * - label: 单位的显示标签，用于UI展示
 */
export interface UnitOption {
  /** 单位的内部值（用于计算逻辑） */
  value: string
  /** 单位的显示标签（用于UI展示） */
  label: string
}

/**
 * 计算单位选项常量
 * 
 * 功能说明：
 * - 提供等级页面支持的计算单位选项
 * - 用于单位选择下拉框的数据源
 * - 支持克（重量单位）和个（数量单位）两种单位
 * 
 * 使用场景：
 * - 用户选择计算单位时
 * - 初始化单位选择器时
 * - 数据计算和显示时
 */
export const UNIT_OPTIONS: UnitOption[] = [
  { value: 'gram', label: '克' },
  { value: 'piece', label: '个' }
]

/**
 * 表格数量配置接口
 * 
 * 功能说明：
 * - 定义表格数量的数据结构
 * - 用于表格数量选择器的选项配置
 * - 支持3-6行的表格数量配置
 * 
 * 属性说明：
 * - value: 表格数量的值，用于内部逻辑处理
 * - label: 表格数量的显示标签，用于UI展示
 */
export interface TableCountOption {
  /** 表格数量的值（用于内部逻辑） */
  value: string
  /** 表格数量的显示标签（用于UI展示） */
  label: string
}

/**
 * 表格数量选项常量
 * 
 * 功能说明：
 * - 提供等级页面支持的表格数量选项
 * - 用于表格数量选择器的数据源
 * - 支持3、4、5、6四种表格数量配置
 * 
 * 使用场景：
 * - 用户选择表格数量时
 * - 初始化表格数量选择器时
 * - 动态调整表格行数时
 */
export const TABLE_COUNT_OPTIONS: TableCountOption[] = [
  { value: '3', label: '3' },
  { value: '4', label: '4' },
  { value: '5', label: '5' },
  { value: '6', label: '6' },
  { value: '8', label: '8' },
  { value: '10', label: '10' },
  { value: '12', label: '12' },
  { value: '15', label: '15' },
  { value: '18', label: '18' },
  { value: '20', label: '20' }
]

/**
 * 默认等级数据接口
 * 
 * 功能说明：
 * - 定义等级数据的结构
 * - 用于存储等级的基本信息
 * - 包含等级名称、最小重量、包装重量等属性
 * 
 * 属性说明：
 * - levelName: 等级名称，如'A级'、'B级'等
 * - minWeight: 最小重量，用于等级判断
 * - packingWeight: 包装重量，用于包装计算
 */
export interface DefaultLevelData {
  /** 等级名称（如'A级'、'B级'等） */
  levelName: string
  /** 最小重量（用于等级判断） */
  minWeight: number
  /** 包装重量（用于包装计算） */
  packingWeight: number
}

/**
 * 默认等级数据常量
 * 
 * 功能说明：
 * - 提供等级页面的默认等级数据
 * - 用于初始化等级表格的数据源
 * - 包含A级、B级、C级三个等级的默认配置
 * 
 * 数据说明：
 * - A级：最小重量120g，包装重量5000g
 * - B级：最小重量100g，包装重量4500g
 * - C级：最小重量80g，包装重量4000g
 * 
 * 使用场景：
 * - 页面初始化时
 * - 重置等级数据时
 * - 创建新等级时
 */
export const DEFAULT_LEVEL_DATA: DefaultLevelData[] = [
  { levelName: 'A级', minWeight: 120, packingWeight: 5000 },
  { levelName: 'B级', minWeight: 100, packingWeight: 4500 },
  { levelName: 'C级', minWeight: 80, packingWeight: 4000 },
  { levelName: 'D级', minWeight: 70, packingWeight: 3500 },
  { levelName: 'E级', minWeight: 60, packingWeight: 3000 },
  { levelName: 'F级', minWeight: 50, packingWeight: 2500 },
  { levelName: 'G级', minWeight: 45, packingWeight: 2200 },
  { levelName: 'H级', minWeight: 40, packingWeight: 2000 },
  { levelName: 'I级', minWeight: 35, packingWeight: 1800 },
  { levelName: 'J级', minWeight: 30, packingWeight: 1600 },
  { levelName: 'K级', minWeight: 25, packingWeight: 1400 },
  { levelName: 'L级', minWeight: 20, packingWeight: 1200 },
  { levelName: 'M级', minWeight: 18, packingWeight: 1000 },
  { levelName: 'N级', minWeight: 15, packingWeight: 800 },
  { levelName: 'O级', minWeight: 12, packingWeight: 600 },
  { levelName: 'P级', minWeight: 10, packingWeight: 500 },
  { levelName: 'Q级', minWeight: 8, packingWeight: 400 },
  { levelName: 'R级', minWeight: 6, packingWeight: 300 },
  { levelName: 'S级', minWeight: 4, packingWeight: 200 },
  { levelName: 'T级', minWeight: 2, packingWeight: 100 }
]

/**
 * 默认统计数据接口
 * 
 * 功能说明：
 * - 定义统计数据的结构
 * - 用于存储分选过程中的统计数据
 * - 包含底部1和底部2的计数、平均值、设定值等数据
 * 
 * 属性说明：
 * - bottom1Counts: 底部1的计数数据数组
 * - bottom1Avgs: 底部1的平均值数据数组
 * - bottom1Sets: 底部1的设定值数据数组
 * - bottom2Counts: 底部2的计数数据数组
 * - bottom2Avgs: 底部2的平均值数据数组
 * - bottom2Sets: 底部2的设定值数据数组
 */
export interface DefaultStatisticsData {
  /** 底部1的计数数据数组 */
  bottom1Counts: number[]
  /** 底部1的平均值数据数组 */
  bottom1Avgs: number[]
  /** 底部1的设定值数据数组 */
  bottom1Sets: number[]
  /** 底部2的计数数据数组 */
  bottom2Counts: number[]
  /** 底部2的平均值数据数组 */
  bottom2Avgs: number[]
  /** 底部2的设定值数据数组 */
  bottom2Sets: number[]
}

/**
 * 默认统计数据常量
 * 
 * 功能说明：
 * - 提供等级页面的默认统计数据
 * - 用于初始化统计表格的数据源
 * - 包含底部1和底部2的模拟统计数据
 * 
 * 数据说明：
 * - 底部1：计数48-54，平均值123-130，设定值120
 * - 底部2：计数46-55，平均值124-131，设定值118
 * 
 * 使用场景：
 * - 页面初始化时
 * - 重置统计数据时
 * - 创建新统计数据时
 */
export const DEFAULT_STATISTICS_DATA: DefaultStatisticsData = {
  bottom1Counts: [48, 52, 47, 50, 51, 49, 53, 54],
  bottom1Avgs: [125, 128, 123, 130, 127, 129, 124, 126],
  bottom1Sets: [120, 120, 120, 120, 120, 120, 120, 120],
  bottom2Counts: [46, 55, 50, 52, 48, 51, 49, 47],
  bottom2Avgs: [126, 129, 124, 131, 128, 127, 125, 130],
  bottom2Sets: [118, 118, 118, 118, 118, 118, 118, 118]
}

/**
 * 默认设置状态接口
 * 
 * 功能说明：
 * - 定义等级页面设置状态的结构
 * - 用于存储用户的各种设置选项
 * - 包含水果类型、出口阈值、分选标准等设置
 * 
 * 属性说明：
 * - selectedFruit: 选中的水果类型
 * - outletThreshold: 出口阈值设置
 * - selectedStandards: 选中的分选标准数组
 * - selectedUnit: 选中的计算单位
 * - packingWeight1: 包装重量1设置
 * - packingWeight2: 包装重量2设置
 * - tableCount: 表格数量设置
 */
export interface DefaultLevelSettings {
  /** 选中的水果类型 */
  selectedFruit: string
  /** 出口阈值设置 */
  outletThreshold: number
  /** 选中的分选标准数组 */
  selectedStandards: string[]
  /** 选中的计算单位 */
  selectedUnit: string
  /** 包装重量1设置 */
  packingWeight1: number
  /** 包装重量2设置 */
  packingWeight2: number
  /** 表格数量设置 */
  tableCount: string
}

/**
 * 默认设置状态常量
 * 
 * 功能说明：
 * - 提供等级页面的默认设置状态
 * - 用于初始化页面的各种设置选项
 * - 包含所有设置项的默认值
 * 
 * 默认值说明：
 * - selectedFruit: '苹果'（默认选择苹果）
 * - outletThreshold: 0（默认出口阈值为0）
 * - selectedStandards: []（默认未选择分选标准）
 * - selectedUnit: 'gram'（默认选择克作为单位）
 * - packingWeight1: 0（默认包装重量1为0）
 * - packingWeight2: 0（默认包装重量2为0）
 * - tableCount: '3'（默认表格数量为3）
 * 
 * 使用场景：
 * - 页面初始化时
 * - 重置设置时
 * - 创建新设置时
 */
export const DEFAULT_LEVEL_SETTINGS: DefaultLevelSettings = {
  selectedFruit: '苹果',
  outletThreshold: 0,
  selectedStandards: [],
  selectedUnit: 'gram',
  packingWeight1: 0,
  packingWeight2: 0,
  tableCount: '3'
}

/**
 * 布局配置接口
 * 
 * 功能说明：
 * - 定义页面布局的配置结构
 * - 用于控制页面左右面板的宽度比例
 * - 支持响应式布局的配置
 * 
 * 属性说明：
 * - LEFT_PANEL_WIDTH: 左侧面板的宽度比例
 * - RIGHT_PANEL_WIDTH: 右侧面板的宽度比例
 */
export interface LayoutConfig {
  /** 左侧面板的宽度比例 */
  LEFT_PANEL_WIDTH: string
  /** 右侧面板的宽度比例 */
  RIGHT_PANEL_WIDTH: string
}

/**
 * 布局配置常量
 * 
 * 功能说明：
 * - 提供等级页面的布局配置
 * - 用于控制页面左右面板的宽度比例
 * - 左侧面板占20%，右侧面板占75%
 * 
 * 布局说明：
 * - 左侧面板：20%宽度，用于控制面板
 * - 右侧面板：75%宽度，用于数据表格
 * - 剩余5%用于面板间距
 * 
 * 使用场景：
 * - 页面布局初始化时
 * - 响应式布局调整时
 * - 面板宽度计算时
 */
export const LAYOUT_CONFIG: LayoutConfig = {
  LEFT_PANEL_WIDTH: '20%',
  RIGHT_PANEL_WIDTH: '80%'
}

/**
 * 等级数据接口
 * 
 * 功能说明：
 * - 定义等级数据的结构
 * - 用于存储和管理等级信息
 * - 与DefaultLevelData接口结构相同
 * 
 * 属性说明：
 * - levelName: 等级名称
 * - minWeight: 最小重量
 * - packingWeight: 包装重量
 * 
 * 使用场景：
 * - 等级数据的类型定义
 * - 数据验证和类型检查
 * - API接口的数据结构
 */
export interface LevelData {
  /** 等级名称 */
  levelName: string
  /** 最小重量 */
  minWeight: number
  /** 包装重量 */
  packingWeight: number
}

/**
 * 统计数据接口
 * 
 * 功能说明：
 * - 定义统计数据的结构
 * - 用于存储和管理统计数据
 * - 与DefaultStatisticsData接口结构相同
 * 
 * 属性说明：
 * - bottom1Counts: 底部1的计数数据数组
 * - bottom1Avgs: 底部1的平均值数据数组
 * - bottom1Sets: 底部1的设定值数据数组
 * - bottom2Counts: 底部2的计数数据数组
 * - bottom2Avgs: 底部2的平均值数据数组
 * - bottom2Sets: 底部2的设定值数据数组
 * 
 * 使用场景：
 * - 统计数据的类型定义
 * - 数据验证和类型检查
 * - API接口的数据结构
 */
export interface StatisticsData {
  /** 底部1的计数数据数组 */
  bottom1Counts: number[]
  /** 底部1的平均值数据数组 */
  bottom1Avgs: number[]
  /** 底部1的设定值数据数组 */
  bottom1Sets: number[]
  /** 底部2的计数数据数组 */
  bottom2Counts: number[]
  /** 底部2的平均值数据数组 */
  bottom2Avgs: number[]
  /** 底部2的设定值数据数组 */
  bottom2Sets: number[]
}
