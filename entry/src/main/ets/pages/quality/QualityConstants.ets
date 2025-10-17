/**
 * 品质页面常量定义
 * 
 * 功能说明：
 * - 定义品质页面相关的所有常量
 * - 包含等级数量选项、颜色等级、糖度等级等
 * - 提供默认数据和配置选项
 * 
 * 主要常量：
 * - 等级数量选项：0-16个等级
 * - 颜色等级：优秀、良好、一般、较差、差、极差、零价值
 * - 糖度等级：高糖度、中糖度、低糖度、极低糖度、无糖度、负糖度、零价值
 * - 默认设置：默认等级数量、默认出口设置等
 * 
 * 使用场景：
 * - 品质页面组件初始化
 * - 数据表格显示
 * - 出口设置配置
 * - 状态管理默认值
 * 
 * TODO - 品质页面颜色等级自定义组件功能：
 * 1. 扩展QualityLevelData数据结构：将colorLevel从字符串改为支持组件配置的对象
 * 2. 定义组件类型枚举：按钮、开关、输入框、下拉选择等
 * 3. 在QualityDataTable中实现动态组件渲染策略，使用条件渲染
 * 4. 实现自定义组件的事件回调和数据同步到状态管理器
 */

/**
 * 等级数量选项接口
 * 
 * 功能说明：
 * - 定义等级数量选择器的选项结构
 * - 包含显示值和实际值
 * 
 * 属性说明：
 * - value: 等级数量值（字符串）
 * - label: 显示标签（可选）
 */
export interface LevelCountOption {
  value: string
  label?: string
}

/**
 * 品质等级数据接口
 * 
 * 功能说明：
 * - 定义品质等级的数据结构
 * - 包含等级名称、颜色等级、糖度等级
 * 
 * 属性说明：
 * - levelName: 等级名称
 * - colorLevel: 颜色等级描述
 * - sugarLevel: 糖度等级描述
 */
export interface QualityLevelData {
  levelName: string
  colorLevel: string
  sugarLevel: string
}

/**
 * 品质页面默认设置接口
 * 
 * 功能说明：
 * - 定义品质页面的默认设置
 * - 包含默认等级数量、默认出口设置等
 * 
 * 属性说明：
 * - defaultLevelCount: 默认等级数量索引
 * - defaultOutletIndex: 默认出口索引
 * - showOutletDialog: 默认对话框显示状态
 */
export interface QualityDefaultSettings {
  defaultLevelCount: number
  defaultOutletIndex: number
  showOutletDialog: boolean
}

/**
 * 出口设置配置接口
 * 
 * 功能说明：
 * - 定义出口设置的配置选项
 * - 包含出口数量、默认选择等
 * 
 * 属性说明：
 * - outletCount: 出口总数量
 * - minOutletIndex: 最小出口索引
 * - maxOutletIndex: 最大出口索引
 */
export interface OutletConfig {
  outletCount: number
  minOutletIndex: number
  maxOutletIndex: number
}

// ==================== 等级数量选项 ====================

/**
 * 等级数量选项数组
 * 
 * 功能说明：
 * - 提供0-16个等级的选择选项
 * - 用于等级数量下拉选择器
 * 
 * 选项说明：
 * - 0个等级：不显示
 * - 1-16个等级：显示对应条数
 */
export const LEVEL_COUNT_OPTIONS: LevelCountOption[] = [
  { value: '0', label: '0个等级' },
  { value: '1', label: '1个等级' },
  { value: '2', label: '2个等级' },
  { value: '3', label: '3个等级' },
  { value: '4', label: '4个等级' },
  { value: '5', label: '5个等级' },
  { value: '6', label: '6个等级' },
  { value: '7', label: '7个等级' },
  { value: '8', label: '8个等级' },
  { value: '9', label: '9个等级' },
  { value: '10', label: '10个等级' },
  { value: '11', label: '11个等级' },
  { value: '12', label: '12个等级' },
  { value: '13', label: '13个等级' },
  { value: '14', label: '14个等级' },
  { value: '15', label: '15个等级' },
  { value: '16', label: '16个等级' }
]

// ==================== 颜色等级定义 ====================

/**
 * 颜色等级描述数组
 * 
 * 功能说明：
 * - 定义不同等级的颜色描述
 * - 从优秀到零价值的完整分级
 * 
 * 等级说明：
 * - 优秀：最高品质
 * - 良好：高品质
 * - 一般：中等品质
 * - 较差：低品质
 * - 差：很低品质
 * - 极差：极低品质
 * - 零价值：无价值
 */
export const COLOR_LEVELS: string[] = [
  '优秀',
  '良好', 
  '一般',
  '较差',
  '差',
  '极差',
  '零价值'
]

// ==================== 糖度等级定义 ====================

/**
 * 糖度等级描述数组
 * 
 * 功能说明：
 * - 定义不同等级的糖度描述
 * - 从高糖度到零价值的完整分级
 * 
 * 等级说明：
 * - 高糖度：最高糖度
 * - 中糖度：中等糖度
 * - 低糖度：低糖度
 * - 极低糖度：极低糖度
 * - 无糖度：无糖度
 * - 负糖度：负糖度
 * - 零价值：无价值
 */
export const SUGAR_LEVELS: string[] = [
  '高糖度',
  '中糖度',
  '低糖度', 
  '极低糖度',
  '无糖度',
  '负糖度',
  '零价值'
]

// ==================== 默认品质等级数据 ====================

/**
 * 默认品质等级数据
 * 
 * 功能说明：
 * - 提供默认的品质等级数据
 * - 包含7个等级的完整数据
 * - 用于数据表格显示和初始化
 * 
 * 数据结构：
 * - 每个等级包含等级名称、颜色等级、糖度等级
 * - 按照从高到低的品质顺序排列
 */
export const DEFAULT_QUALITY_LEVELS: QualityLevelData[] = [
  { levelName: '1', colorLevel: '优秀', sugarLevel: '高糖度' },
  { levelName: '2', colorLevel: '良好', sugarLevel: '中糖度' },
  { levelName: '3', colorLevel: '一般', sugarLevel: '低糖度' },
  { levelName: '4', colorLevel: '较差', sugarLevel: '极低糖度' },
  { levelName: '5', colorLevel: '差', sugarLevel: '无糖度' },
  { levelName: '6', colorLevel: '极差', sugarLevel: '负糖度' },
  { levelName: '7', colorLevel: '零价值', sugarLevel: '零价值' },
  { levelName: '8', colorLevel: '特优', sugarLevel: '超高糖度' },
  { levelName: '9', colorLevel: '精品', sugarLevel: '优质糖度' },
  { levelName: '10', colorLevel: '标准', sugarLevel: '标准糖度' },
  { levelName: '11', colorLevel: '次品', sugarLevel: '低质糖度' },
  { levelName: '12', colorLevel: '废品', sugarLevel: '无价值' },
  { levelName: '13', colorLevel: '超优', sugarLevel: '顶级糖度' },
  { levelName: '14', colorLevel: '良品', sugarLevel: '良好糖度' },
  { levelName: '15', colorLevel: '合格', sugarLevel: '合格糖度' },
  { levelName: '16', colorLevel: '顶级', sugarLevel: '特级糖度' },
  { levelName: '17', colorLevel: '优质', sugarLevel: '精品糖度' },
  { levelName: '18', colorLevel: '普通', sugarLevel: '普通糖度' },
  { levelName: '19', colorLevel: '低质', sugarLevel: '劣质糖度' },
  { levelName: '20', colorLevel: '劣质', sugarLevel: '废品糖度' },
  { levelName: '21', colorLevel: '极品', sugarLevel: '极品糖度' },
  { levelName: '22', colorLevel: '上品', sugarLevel: '上品糖度' },
  { levelName: '23', colorLevel: '中品', sugarLevel: '中品糖度' },
  { levelName: '24', colorLevel: '下品', sugarLevel: '下品糖度' },
  { levelName: '25', colorLevel: '垃圾', sugarLevel: '垃圾糖度' }
]

// ==================== 默认设置 ====================

/**
 * 品质页面默认设置
 * 
 * 功能说明：
 * - 定义品质页面的默认配置
 * - 包含默认等级数量、出口设置等
 * 
 * 默认值说明：
 * - defaultLevelCount: 默认选择3个等级（索引1）
 * - defaultOutletIndex: 默认选择1号出口
 * - showOutletDialog: 默认不显示对话框
 */
export const DEFAULT_QUALITY_SETTINGS: QualityDefaultSettings = {
  defaultLevelCount: 0, // 默认不显示（0个等级）
  defaultOutletIndex: 1,
  showOutletDialog: false
}

// ==================== 出口配置 ====================

/**
 * 出口设置配置
 * 
 * 功能说明：
 * - 定义出口设置的配置参数
 * - 包含出口数量、索引范围等
 * 
 * 配置说明：
 * - outletCount: 总共9个出口
 * - minOutletIndex: 最小出口索引为1
 * - maxOutletIndex: 最大出口索引为9
 */
export const OUTLET_CONFIG: OutletConfig = {
  outletCount: 9,
  minOutletIndex: 1,
  maxOutletIndex: 9
}

// ==================== 布局配置 ====================

/**
 * 布局配置接口
 * 
 * 功能说明：
 * - 定义品质页面的布局配置
 * - 包含卡片高度、间距等参数
 * 
 * 属性说明：
 * - controlPanelHeight: 控制面板高度百分比
 * - dataTableHeight: 数据表格高度百分比
 * - cardMargin: 卡片间距
 * - cardPadding: 卡片内边距
 */
export interface LayoutConfig {
  controlPanelHeight: string
  dataTableHeight: string
  cardMargin: number
  cardPadding: number
}

/**
 * 品质页面布局配置
 * 
 * 功能说明：
 * - 定义品质页面的布局参数
 * - 确保页面布局的一致性和美观性
 * 
 * 配置说明：
 * - controlPanelHeight: 控制面板占10%高度
 * - dataTableHeight: 数据表格占75%高度
 * - cardMargin: 卡片间距16px
 * - cardPadding: 卡片内边距16px
 */
export const QUALITY_LAYOUT_CONFIG: LayoutConfig = {
  controlPanelHeight: '10%',
  dataTableHeight: '75%',
  cardMargin: 16,
  cardPadding: 16
}
