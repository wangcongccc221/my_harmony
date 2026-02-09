export interface TopBarConfig {
  /** 产量（吨/小时）的AppStorage键名 */
  PRODUCTION_TON_H: string
  /** 总重量（吨）的AppStorage键名 */
  SUM_WEIGHT_TON: string
  /** 总计数的AppStorage键名 */
  SUM_COUNTS: string
  /** 平均重量（克）的AppStorage键名 */
  AVG_G: string
  /** 用户名的AppStorage键名 */
  USER_NAME: string
  /** 状态文本的AppStorage键名 */
  STATUS_TEXT: string
  /** 警告隐藏状态的AppStorage键名 */
  ALERT_HIDE: string
}

/**
 * 顶部状态栏配置常量
 * 
 * 定义顶部状态栏各个指标在AppStorage中的键名
 * 这些键名用于统一管理状态栏数据的存储和获取
 * 
 * 使用方式：
 * ```typescript
 * // 设置状态栏数据
 * AppStorage.Set(TOP_BAR_CONFIG.PRODUCTION_TON_H, '1.25')
 * 
 * // 获取状态栏数据
 * const production = AppStorage.Get(TOP_BAR_CONFIG.PRODUCTION_TON_H)
 * ```
 */
export const TOP_BAR_CONFIG: TopBarConfig = {
  /** 产量（吨/小时）的AppStorage键名 */
  PRODUCTION_TON_H: 'topProductionTonH',
  /** 总重量（吨）的AppStorage键名 */
  SUM_WEIGHT_TON: 'topSumWeightTon', 
  /** 总计数的AppStorage键名 */
  SUM_COUNTS: 'topSumCounts',
  /** 平均重量（克）的AppStorage键名 */
  AVG_G: 'topAvgG',
  /** 用户名的AppStorage键名 */
  USER_NAME: 'topUserName',
  /** 状态文本的AppStorage键名 */
  STATUS_TEXT: 'topStatusText',
  /** 警告隐藏状态的AppStorage键名 */
  ALERT_HIDE: 'topAlertHide'
}

/**
 * 默认顶部状态栏数据接口
 * 
 * 定义顶部状态栏各个指标的默认值
 * 这些默认值在应用初始化时使用
 * 
 * 属性说明：
 * - PRODUCTION_TON_H: 默认产量值
 * - SUM_WEIGHT_TON: 默认总重量值
 * - SUM_COUNTS: 默认总计数
 * - AVG_G: 默认平均重量值
 * - USER_NAME: 默认用户名
 * - STATUS_TEXT: 默认状态文本
 * - ALERT_HIDE: 默认警告隐藏状态
 */
export interface DefaultTopBarData {
  /** 默认产量值（吨/小时） */
  PRODUCTION_TON_H: string
  /** 默认总重量值（吨） */
  SUM_WEIGHT_TON: string
  /** 默认总计数 */
  SUM_COUNTS: string
  /** 默认平均重量值（克） */
  AVG_G: string
  /** 默认用户名 */
  USER_NAME: string
  /** 默认状态文本 */
  STATUS_TEXT: string
  /** 默认警告隐藏状态 */
  ALERT_HIDE: boolean
}

/**
 * 默认顶部状态栏数据常量
 * 
 * 定义顶部状态栏各个指标的初始默认值
 * 这些值在应用启动时设置到AppStorage中
 * 
 * 使用方式：
 * ```typescript
 * // 初始化状态栏数据
 * AppStorage.SetOrCreate(TOP_BAR_CONFIG.PRODUCTION_TON_H, DEFAULT_TOP_BAR_DATA.PRODUCTION_TON_H)
 * ```
 */
export const DEFAULT_TOP_BAR_DATA: DefaultTopBarData = {
  /** 默认产量值：0.00吨/小时 */
  PRODUCTION_TON_H: '0.00',
  /** 默认总重量值：0.00吨 */
  SUM_WEIGHT_TON: '0.00',
  /** 默认总计数：0 */
  SUM_COUNTS: '0',
  /** 默认平均重量值：0.00克 */
  AVG_G: '0.00',
  /** 默认用户名：管理员 */
  USER_NAME: '管理员',
  /** 默认状态文本：空字符串 */
  STATUS_TEXT: '',
  /** 默认警告隐藏状态：false（显示警告） */
  ALERT_HIDE: false
}

/**
 * FSM状态选项接口
 * 
 * 定义有限状态机（FSM）的选项配置
 * 用于FSM切换组件的选项管理
 * 
 * 属性说明：
 * - FSM1: FSM1状态的标识符
 * - FSM2: FSM2状态的标识符
 */
export interface FSMOptions {
  /** FSM1状态的标识符 */
  FSM1: string
  /** FSM2状态的标识符 */
  FSM2: string
}

/**
 * 设置选项接口
 * 
 * 定义设置开关的选项配置
 * 用于设置面板组件的选项管理
 * 
 * 属性说明：
 * - SETTING1: 设置1的标识符
 * - SETTING2: 设置2的标识符
 * - SETTING3: 设置3的标识符
 * - SETTING4: 设置4的标识符
 */
export interface SettingsOptions {
  /** 设置1的标识符 */
  SETTING1: string
  /** 设置2的标识符 */
  SETTING2: string
  /** 设置3的标识符 */
  SETTING3: string
  /** 设置4的标识符 */
  SETTING4: string
}
export const FSM_OPTIONS: FSMOptions = {

  FSM1: 'FSM1',

  FSM2: 'FSM2'
}

export const SETTINGS_OPTIONS: SettingsOptions = {
  /** 设置1的标识符 */
  SETTING1: '设置1',
  /** 设置2的标识符 */
  SETTING2: '设置2',
  /** 设置3的标识符 */
  SETTING3: '设置3',
  /** 设置4的标识符 */
  SETTING4: '设置4'
}

export const FUNCTION_BUTTONS: string[] = [
  '等级表',
  '等级统计表',
  '加工曲线',
  '加工柱状图',
  '动态装箱',

  '成品'
]

export interface SortingInfoField {
  /** 字段的数据键名 */
  key: string
  /** 字段的显示标签 */
  label: string
  /** 字段的宽度百分比 */
  width: number
}

export const SORTING_INFO_FIELDS: SortingInfoField[] = [
  /** 分选速度字段配置 */
  { key: 'sortSpeed', label: '分选速度', width: 11.11 },
  /** 本批重量字段配置 */
  { key: 'batchWeight', label: '本批重量', width: 11.11 },
  /** 本批个数字段配置 */
  { key: 'batchCount', label: '本批个数', width: 11.11 },
  /** 开始时间字段配置 */
  { key: 'startTime', label: '开始时间', width: 11.11 },
  /** 分选程序字段配置 */
  { key: 'programName', label: '分选程序', width: 11.11 },
  /** 分选效率字段配置 */
  { key: 'efficiency', label: '分选效率', width: 11.11 },
  /** 平均重量字段配置 */
  { key: 'avgWeight', label: '平均重量', width: 11.11 },
  /** 实时产量字段配置 */
  { key: 'realTimeOutput', label: '实时产量', width: 11.11 },
  /** 间隔速度字段配置 */
  { key: 'intervalSpeed', label: '间隔速度', width: 11.11 }
]

/**
 * 液体卡片配置接口
 * 
 * 定义液体卡片区域的配置参数
 * 用于液体卡片区域组件的布局配置
 * 
 * 属性说明：
 * - TOTAL_COUNT: 液体卡片的总数量
 * - CARD_WIDTH: 单个卡片的宽度
 * - CARD_HEIGHT: 单个卡片的高度
 * - MARGIN_RIGHT: 卡片右边距
 * - MARGIN_BOTTOM: 卡片下边距
 */
export interface LiquidCardsConfig {
  /** 液体卡片的总数量 */
  TOTAL_COUNT: number
  /** 单个卡片的宽度（像素） */
  CARD_WIDTH: number
  /** 单个卡片的高度（像素） */
  CARD_HEIGHT: number
  /** 卡片右边距（像素） */
  MARGIN_RIGHT: number
  /** 卡片下边距（像素） */
  MARGIN_BOTTOM: number
}

/**
 * 液体卡片配置常量
 * 
 * 定义液体卡片区域的具体配置参数
 * 用于液体卡片区域组件的布局配置
 * 
 * 配置说明：
 * - 总数量：40个液体卡片
 * - 卡片尺寸：80x96像素
 * - 间距：右边距6px，下边距6px
 * 
 * 使用方式：
 * ```typescript
 * // 获取卡片配置
 * const cardWidth = LIQUID_CARDS_CONFIG.CARD_WIDTH  // 80
 * const cardHeight = LIQUID_CARDS_CONFIG.CARD_HEIGHT  // 96
 * ```
 */
export const LIQUID_CARDS_CONFIG: LiquidCardsConfig = {
  /** 液体卡片总数量：40个 */
  TOTAL_COUNT: 40,
  /** 单个卡片宽度：80像素 */
  CARD_WIDTH: 80,
  /** 单个卡片高度：96像素 */
  CARD_HEIGHT: 96,
  /** 卡片右边距：6像素 */
  MARGIN_RIGHT: 6,
  /** 卡片下边距：6像素 */
  MARGIN_BOTTOM: 6
}

/**
 * 出口配置接口
 * 
 * 定义出口设置对话框的配置参数
 * 用于出口设置对话框组件的配置
 * 
 * 属性说明：
 * - MIN_INDEX: 出口的最小索引号
 * - MAX_INDEX: 出口的最大索引号
 * - DEFAULT_INDEX: 默认选中的出口索引号
 */
export interface OutletConfig {
  /** 出口的最小索引号 */
  MIN_INDEX: number
  /** 出口的最大索引号 */
  MAX_INDEX: number
  /** 默认选中的出口索引号 */
  DEFAULT_INDEX: number
}

/**
 * 出口配置常量
 * 
 * 定义出口设置对话框的具体配置参数
 * 用于出口设置对话框组件的配置
 * 
 * 配置说明：
 * - 出口范围：1-9号出口
 * - 默认选中：1号出口
 * 
 * 使用方式：
 * ```typescript
 * // 获取出口配置
 * const minIndex = OUTLET_CONFIG.MIN_INDEX  // 1
 * const maxIndex = OUTLET_CONFIG.MAX_INDEX  // 9
 * const defaultIndex = OUTLET_CONFIG.DEFAULT_INDEX  // 1
 * ```
 */
export const OUTLET_CONFIG: OutletConfig = {
  /** 出口最小索引号：1 */
  MIN_INDEX: 1,
  /** 出口最大索引号：9 */
  MAX_INDEX: 9,
  /** 默认选中出口索引号：1 */
  DEFAULT_INDEX: 1
}/**
 * 默认分选信息接口
 * 
 * 定义分选信息卡片中所有字段的默认值
 * 用于分选信息卡片组件的初始化
 * 
 * 属性说明：
 * - sortSpeed: 分选速度的默认值
 * - batchWeight: 本批重量的默认值
 * - batchCount: 本批个数的默认值
 * - startTime: 开始时间的默认值
 * - programName: 分选程序的默认值
 * - efficiency: 分选效率的默认值
 * - avgWeight: 平均重量的默认值
 * - realTimeOutput: 实时产量的默认值
 * - intervalSpeed: 间隔速度的默认值
 */
export interface DefaultSortingInfo {
  /** 分选速度的默认值 */
  sortSpeed: string
  /** 本批重量的默认值 */
  batchWeight: string
  /** 本批个数的默认值 */
  batchCount: string
  /** 开始时间的默认值 */
  startTime: string
  /** 分选程序的默认值 */
  programName: string
  /** 分选效率的默认值 */
  efficiency: string
  /** 平均重量的默认值 */
  avgWeight: string
  /** 实时产量的默认值 */
  realTimeOutput: string
  /** 间隔速度的默认值 */
  intervalSpeed: string
}

/**
 * 默认分选信息常量
 * 
 * 定义分选信息卡片中所有字段的初始默认值
 * 用于分选信息卡片组件的初始化
 * 
 * 默认值说明：
 * - 分选速度：0件/分钟
 * - 本批重量：0.00kg
 * - 本批个数：0件
 * - 开始时间：--:--:--（占位符）
 * - 分选程序：未选择
 * - 分选效率：0%
 * - 平均重量：0.00kg
 * - 实时产量：0件/分钟
 * - 间隔速度：0ms
 * 
 * 使用方式：
 * ```typescript
 * // 初始化分选信息
 * this.sortSpeed = DEFAULT_SORTING_INFO.sortSpeed
 * this.batchWeight = DEFAULT_SORTING_INFO.batchWeight
 * ```
 */
export const DEFAULT_SORTING_INFO: DefaultSortingInfo = {
  /** 默认分选速度：0件/分钟 */
  sortSpeed: '0 件/分钟',
  /** 默认本批重量：0.00kg */
  batchWeight: '0.00 kg',
  /** 默认本批个数：0件 */
  batchCount: '0 件',
  /** 默认开始时间：--:--:--（占位符） */
  startTime: '--:--:--',
  /** 默认分选程序：未选择 */
  programName: '未选择',
  /** 默认分选效率：0% */
  efficiency: '0%',
  /** 默认平均重量：0.00kg */
  avgWeight: '0.00 kg',
  /** 默认实时产量：0件/分钟 */
  realTimeOutput: '0 件/分钟',
  /** 默认间隔速度：0ms */
  intervalSpeed: '0 ms'
}

/**
 * 默认设置状态接口
 * 
 * 定义设置开关的默认状态
 * 用于设置面板组件的初始化
 * 
 * 属性说明：
 * - setting1Enabled: 设置1的默认启用状态
 * - setting2Enabled: 设置2的默认启用状态
 * - setting3Enabled: 设置3的默认启用状态
 * - setting4Enabled: 设置4的默认启用状态
 */
export interface DefaultSettings {
  /** 设置1的默认启用状态 */
  setting1Enabled: boolean
  /** 设置2的默认启用状态 */
  setting2Enabled: boolean
  /** 设置3的默认启用状态 */
  setting3Enabled: boolean
  /** 设置4的默认启用状态 */
  setting4Enabled: boolean
}

/**
 * 默认设置状态常量
 * 
 * 定义设置开关的初始默认状态
 * 用于设置面板组件的初始化
 * 
 * 默认状态说明：
 * - 设置1：默认启用（true）
 * - 设置2：默认禁用（false）
 * - 设置3：默认禁用（false）
 * - 设置4：默认禁用（false）
 * 
 * 注意：设置开关采用互斥模式，同一时间只能有一个开启
 * 
 * 使用方式：
 * ```typescript
 * // 初始化设置状态
 * this.setting1Enabled = DEFAULT_SETTINGS.setting1Enabled  // true
 * this.setting2Enabled = DEFAULT_SETTINGS.setting2Enabled  // false
 * ```
 */
export const DEFAULT_SETTINGS: DefaultSettings = {
  /** 设置1默认启用状态：true */
  setting1Enabled: true,
  /** 设置2默认启用状态：false */
  setting2Enabled: false,
  /** 设置3默认启用状态：false */
  setting3Enabled: false,
  /** 设置4默认启用状态：false */
  setting4Enabled: false
}

/**
 * 默认功能按钮常量
 * 
 * 定义功能按钮组件的默认选中按钮
 * 用于功能按钮组件的初始化
 * 
 * 默认值：'等级表'
 * 
 * 使用方式：
 * ```typescript
 * // 初始化功能按钮
 * this.selectedButton = DEFAULT_SELECTED_BUTTON  // '等级表'
 * ```
 */
export const DEFAULT_SELECTED_BUTTON = '等级表'

/**
 * 默认FSM状态常量
 * 
 * 定义FSM切换组件的默认选中状态
 * 用于FSM切换组件的初始化
 * 
 * 默认值：'FSM1'
 * 
 * 使用方式：
 * ```typescript
 * // 初始化FSM状态
 * this.selectedFSM = DEFAULT_SELECTED_FSM  // 'FSM1'
 * ```
 */
export const DEFAULT_SELECTED_FSM = 'FSM1'

/**
 * 表格配置项接口
 * 
 * 定义单个表格的配置参数
 * 用于数据表格卡片组件的配置
 * 
 * 属性说明：
 * - name: 表格的显示名称
 * - headers: 表格的表头数组
 * - width: 表格的宽度
 * - maxHeight: 表格的最大高度
 */
export interface TableConfigItem {
  /** 表格的显示名称 */
  name: string
  /** 表格的表头数组 */
  headers: string[]
  /** 表格的宽度 */
  width: string
  /** 表格的最大高度 */
  maxHeight: string
}

/**
 * 表格配置接口
 * 
 * 定义所有表格的配置参数
 * 用于数据表格卡片组件的统一配置
 * 
 * 属性说明：
 * - LEVEL_TABLE: 等级表的配置
 * - CONTAINER_TABLE: 容器表的配置
 * - STATISTICS_TABLE: 等级统计表的配置
 * - DYNAMIC_PACKING_TABLE: 动态装箱表的配置
 * - FINISHED_PRODUCTS_TABLE: 成品表的配置
 */
export interface TableConfig {
  /** 等级表的配置 */
  LEVEL_TABLE: TableConfigItem
  /** 容器表的配置 */
  CONTAINER_TABLE: TableConfigItem
  /** 等级统计表的配置 */
  STATISTICS_TABLE: TableConfigItem
  /** 动态装箱表的配置 */
  DYNAMIC_PACKING_TABLE: TableConfigItem
  /** 成品表的配置 */
  FINISHED_PRODUCTS_TABLE: TableConfigItem
}

/**
 * 表格配置常量
 * 
 * 定义所有表格的具体配置参数
 * 用于数据表格卡片组件的统一配置
 * 
 * 表格配置说明：
 * - 等级表：显示等级相关数据，表头为等级和数值
 * - 容器表：显示容器相关数据，表头为容器信息
 * - 等级统计表：显示统计相关数据，表头为统计信息
 * - 动态装箱：显示装箱相关数据，表头为装箱信息
 * - 成品：显示成品相关数据，表头为成品信息
 * 
 * 使用方式：
 * ```typescript
 * // 获取等级表配置
 * const levelTableConfig = TABLE_CONFIG.LEVEL_TABLE
 * console.log(levelTableConfig.name)  // '等级表'
 * console.log(levelTableConfig.headers)  // ['等级', '30', '20', '10', '0']
 * ```
 */
export const TABLE_CONFIG: TableConfig = {
  /** 等级表配置 */
  LEVEL_TABLE: {
    /** 等级表名称 */
    name: '等级表',
    /** 等级表表头：等级和数值列 */
    headers: ['等级', '30', '20', '10', '0'],
    /** 等级表宽度：100% */
    width: '100%',
    /** 等级表最大高度：11.11% */
    maxHeight: '11.11%'
  },
  /** 容器表配置 */
  CONTAINER_TABLE: {
    /** 容器表名称 */
    name: '容器表',
    /** 容器表表头：容器信息列 */
    headers: ['容器名称', '分选标准', '容器规格', '容器等级'],
    /** 容器表宽度：100% */
    width: '100%',
    /** 容器表最大高度：11.11% */
    maxHeight: '11.11%'
  },
  /** 等级统计表配置 */
  STATISTICS_TABLE: {
    /** 等级统计表名称 */
    name: '等级统计表',
    /** 等级统计表表头：统计信息列 */
    headers: ['等级名称', '重量/尺寸', '等级出口', '等级个数', '个数百分比', '等级重量', '重量百分比', '箱数', '箱数百分比', '装箱量(克/个)', '箱重', '贴标'],
    /** 等级统计表宽度：100% */
    width: '100%',
    /** 等级统计表最大高度：11.11% */
    maxHeight: '11.11%'
  },
  /** 动态装箱表配置 */
  DYNAMIC_PACKING_TABLE: {
    /** 动态装箱表名称 */
    name: '动态装箱',
    /** 动态装箱表表头：装箱信息列 */
    headers: ['出口', '流水码', '装箱规格', '等级', '箱数', '纸箱规格', '纸箱净重', '箱数/分'],
    /** 动态装箱表宽度：100% */
    width: '100%',
    /** 动态装箱表最大高度：11.11% */
    maxHeight: '11.11%'
  },
  /** 成品表配置 */
  FINISHED_PRODUCTS_TABLE: {
    /** 成品表名称 */
    name: '成品',
    /** 成品表表头：成品信息列 */
    headers: ['成品码', '出口', '流水码', '容器名称', '等级', '包装时间', '纸箱规格', '纸箱净重'],
    /** 成品表宽度：100% */
    width: '100%',
    /** 成品表最大高度：11.11% */
    maxHeight: '11.11%'
  }
}

