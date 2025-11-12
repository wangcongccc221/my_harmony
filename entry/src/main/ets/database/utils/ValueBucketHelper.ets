/**
 * ValuesBucket 辅助工具
 * 处理空字符串和 undefined 的情况
 */

import { relationalStore } from '@kit.ArkData'

/**
 * 设置 ValuesBucket 的值（自动处理空字符串）
 * 如果值是空字符串，则不设置该字段（让数据库使用默认值或 NULL）
 * 如果值是 undefined，则不设置该字段
 * 只有值不为空时才设置
 * 
 * @param valueBucket ValuesBucket 对象
 * @param key 字段名
 * @param value 字段值
 */
export function setValueIfNotEmpty(
  valueBucket: relationalStore.ValuesBucket,
  key: string,
  value: string | number | undefined | null
): void {
  // 如果是 undefined 或 null，不设置
  if (value === undefined || value === null) {
    return
  }
  
  // 如果是字符串且为空，不设置（让数据库使用默认值或 NULL）
  if (typeof value === 'string' && value.trim() === '') {
    return
  }
  
  // 其他情况正常设置
  valueBucket[key] = value
}

/**
 * 设置 ValuesBucket 的值（允许空字符串）
 * 即使值是空字符串也会设置
 * 
 * @param valueBucket ValuesBucket 对象
 * @param key 字段名
 * @param value 字段值
 * @param defaultValue 如果值为 undefined 时使用的默认值
 */
export function setValueWithDefault(
  valueBucket: relationalStore.ValuesBucket,
  key: string,
  value: string | number | undefined | null,
  defaultValue?: string | number
): void {
  if (value !== undefined && value !== null) {
    valueBucket[key] = value
  } else if (defaultValue !== undefined) {
    valueBucket[key] = defaultValue
  }
  // 如果 value 和 defaultValue 都是 undefined，则不设置
}

/**
 * 清理 ValuesBucket 中的空字符串值
 * 将空字符串字段移除，让数据库使用默认值或 NULL
 * 返回一个新的 ValuesBucket，不包含空字符串字段
 * 
 * @param valueBucket ValuesBucket 对象
 * @returns 清理后的 ValuesBucket 对象
 */
export function cleanEmptyStrings(valueBucket: relationalStore.ValuesBucket): relationalStore.ValuesBucket {
  const cleaned: relationalStore.ValuesBucket = {}
  const keys = Object.keys(valueBucket)
  
  for (const key of keys) {
    const value = valueBucket[key]
    // 如果不是空字符串，则添加到新对象中
    if (typeof value !== 'string' || value.trim() !== '') {
      cleaned[key] = value
    }
  }
  
  return cleaned
}

