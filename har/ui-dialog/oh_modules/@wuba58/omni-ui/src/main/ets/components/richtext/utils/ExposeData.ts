
export interface ExposeData {
  // 字段别名
  name?: string
  // 原始字段名
  propertyName?: string
  // 转换执行回调函数
  transform?: Function
}