interface InterfaceObj {
  [key: string]: any,
}

type SeriesItemType = string | number | InterfaceObj
type ChartType = 'pie' | 'radar' | 'line' | 'verticalBar' | 'horizonBar'
type OverflowType = 'none' | 'break' | 'breakAll'

type GradientColor = {
  direction: number[],
  colors: string[]
}

type Padding = {
  top?: number
  bottom?: number
  left?: number
  right?: number
}

interface Point {
  x: number,
  y: number
};
// 坐标轴的特征接口
interface AxisInterface {
  type?: string,
  name?: string,
  nameTextStyle?: TextStyle,
  nameGap?: number,
  boundaryGap?: boolean,
  axisLine?: LineStyle,
  axisTick?: AxisTickStyle,
  axisLabel?: AxisLabelStyle,
  data?: Array<string | number>,
  splitLine?: LineStyle,
  formatter?: Function | null
}


// 图例的特征接口
interface LegendInterface {
  show?: boolean,
  left?: string,
  top?: string,
  orient?: string,
  itemGap?: number,
  itemTextGap?: number,
  itemWidth?: number,
  itemHeight?: number,
  textStyle?: TextStyle
}

// 提示层的特征接口
interface TooltipInterface {
  show?: boolean,
  type?: string,
  axisPointer?: InterfaceObj,
  backgroundColor?: string,
  borderColor?: string,
  borderWidth?: number,
  padding?: number,
  textStyle?: TextStyle
}

// 数据层的特征接口
interface SeriesInterface<T> {
  name?: string, // 本组数据的名称
  color?: string, // 本组数据的整体颜色
  lineStyle?: LineStyle, // 线条样式
  barStyle?: BarStyle, // 柱形的样式,柱状图需要
  label?: LabelStyle, // 本组数据的标签样式
  itemStyle?: InterfaceObj,
  areaStyle?: AreaStyle, // 填充样式
  labelLine?: InterfaceObj,
  emphasis?: InterfaceObj,
  stack?: string,
  symbolSize?: Number | Function,
  padAngle?: number
  radius?: string[], // 半径占比，环状图需要，如['70%', '40%']
  center?: string[], // 图表中心位置 ['50%', '50%']指位于父组件中心
  smooth?: boolean,
  hide?: boolean,
  data?: T[], // 本组数据的具体数据
}


// 雷达图的特征接口
interface RadarInterface {
  indicator?: InterfaceObj[],
  center?: Array<string | number>,
  radius?: number | string,
  startAngle?: number,
  nameGap ?: number,
  splitNumber ?: number,
  axisLineStyle?: LineStyle,
  axisName?: TextStyle,
  splitLineStyle?: LineStyle,
  splitArea?: AreaStyle[]
}

interface OptionInterface<T> {
  padding?: Padding,
  color?: Array<string>,
  title?: InterfaceObj,
  legend?: LegendInterface,
  tooltip?: TooltipInterface,
  radar?: RadarInterface,
  xAxis?: AxisInterface,
  yAxis?: AxisInterface,
  series?: Array<SeriesInterface<T>>
}


interface TextStyle {
  show?: boolean,
  color?: string | number,
  fontFamily?: string,
  fontSize?: number,
  fontWeight?: string,
  position?: string,
  width?: number,
  overflowType?: OverflowType
}

interface LineStyle {
  show?: boolean,
  color?: string | number,
  width?: number,
  type?: string
}

interface AreaStyle {
  show?: boolean,
  color?: string | GradientColor
}

interface BarStyle {
  color?: string,
  width?: number,
  gap?: number,
  radius?: number
}

interface LabelStyle {
  show?: boolean,
  color?: string | number,
  fontWeight?: string,
  fontFamily?: string,
  position?: string,
  fontSize?: number,
  distanceToLabelLine?: number,
  formatter?: Function
}

interface LabelLineStyle extends LineStyle {
  show?: boolean,
  length?: number,
  length2?: number,
  minTurnAngle?: number
}

interface AxisTickStyle {
  show: boolean,
  interval: number, // 与文本的间隔
  length: number, // 刻度的长度
  lineStyle: LineStyle
}

interface HighlightStyle {
  scale?: boolean,
  scaleSize?: number,
  shadowColor?: string,
  shadowBlur?: number,
  shadowOffsetX?: number,
  shadowOffsetY?: number
}

interface AxisLabelStyle extends TextStyle {
  interval?: string,
  margin?: number, // 刻度标签与轴线之间的距离。
  overflow?: string // x轴的文本长度超出的处理， none（无）， truncate（截断），breakAll（换行）
}

export {
  AxisInterface,
  InterfaceObj,
  LegendInterface,
  TooltipInterface,
  SeriesInterface,
  OptionInterface,
  RadarInterface,
  TextStyle,
  LineStyle,
  BarStyle,
  LabelStyle,
  HighlightStyle,
  LabelLineStyle,
  SeriesItemType,
  ChartType,
  AxisLabelStyle,
  Padding,
  AreaStyle,
  GradientColor,
  AxisTickStyle,
  Point
}