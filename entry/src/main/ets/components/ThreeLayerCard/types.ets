/**
 * ThreeLayerCard 组件的类型定义
 * 集中管理所有接口和类型
 */

// 系统包装接口
export interface SystemWrapper {
  extraInfo: string
}

// 外层大卡片 onDrop 解析接口
export interface OuterDropParsed {
  value?: string | number
  values?: string[]
}

// 第三层条目到其他卡片的拖拽负载
export interface ThirdLayerDragPayload {
  value: string
  sourceTable: string
  rowIndex: number
  colIndex: number
  sourceCardId: string
  sourceValue: number
  itemIndex: number
}

// 第一层数据接口
export interface FirstLayerData {
  iconText?: string
  iconRes?: number | Resource | null
  title?: string
  status?: string
}

// 第二层数据接口
export interface SecondLayerData {
  serialNumber: number
  percent: number
  value: string
  unit?: string
}

// 第三层数据接口（波形图预留）
export interface ThirdLayerData {
  chartType?: string
  chartData?: number[]
  chartDataStrings?: string[] // 保存原始格式字符串（如 "28.5%"）
  chartConfig?: Record<string, string | number>
}

// 完整的三层卡片数据
export interface ThreeLayerCardData {
  id?: string
  firstLayer: FirstLayerData
  secondLayer: SecondLayerData
  thirdLayer: ThirdLayerData
}

// 拖拽数据接口
export interface DragData {
  rowData: string[]
  sourceTable: string
  rowIndex: number
}

// 移除源数据接口
export interface RemoveSourceData {
  sourceCardId: string
  sourceValue: number
}

// 拖拽配置接口
export interface DragConfig {
  sourceTable: string
  rowIndex: number
}

// 第一层数据接口（用于更新）
export interface FirstLayerDataInterface {
  iconText?: string
  title?: string
  status?: string
}

// 第二层数据接口（用于更新）
export interface SecondLayerDataInterface {
  serialNumber: number
  percent: number
  value: string
  unit?: string
}

// 第三层数据接口（用于更新）
export interface ThirdLayerDataInterface {
  chartType?: string
  chartData?: number[]
  chartDataStrings?: string[] // 保存原始格式字符串（如 "28.5%"）
  chartConfig?: Record<string, string | number>
}

// 拖拽外层载荷（部分系统会在extraParams外包一层{ extraInfo: string }）
export interface DragOuterPayload {
  extraInfo?: string
}

// 宽松负载类型（多选/单选/简化/整列/整行 都可覆盖），避免使用 unknown/any
export interface LoosePayload {
  type?: string
  count?: number
  cells?: MultiSelectCell[]
  values?: string[]
  levelNames?: string[]
  levelName?: string // 添加等级名称字段（用于整行拖拽）
  value?: string
  sourceTable?: string
  rowIndex?: number
  colIndex?: number
  sourceCardId?: string
  sourceValue?: number
  extraInfo?: string
  // 整列拖拽数据字段
  columnIndex?: number
  columnHeader?: string
  columnData?: string[]
  fullColumnData?: string // 完整列数据（JSON字符串格式）
  // 整行拖拽数据字段
  rowData?: string[]
  fullRowData?: string // 完整行数据（JSON字符串格式）
  outletInfo?: string // 出口信息（用于等级统计表）
}

// 批量出口追加负载（多选仅添加）
export interface LevelStatBatchPayload {
  levelNames: string[]
  exit: number
}

// 多选单元格接口（从 SimpleDraggableCell 导入的类型）
export interface MultiSelectCell {
  rowIndex: number
  colIndex: number
  value: string
  sourceTable: string
  cellId: string
}

// 多选状态接口
export interface MultiSelectState {
  cells: MultiSelectCell[]
  isActive: boolean
}
