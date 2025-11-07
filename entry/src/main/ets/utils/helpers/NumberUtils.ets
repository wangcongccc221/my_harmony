/**
 * 数字工具类
 * 功能：提供数字格式化和计算工具函数
 * 用途：统一数字处理逻辑，避免重复代码
 */

/**
 * 数字工具类
 * 提供统一的数字格式化方法
 */
export class NumberUtils {
  /**
   * 四舍五入到指定小数位
   * @param value 要格式化的数字
   * @param decimals 小数位数（默认1位）
   * @returns 格式化后的数字
   */
  static roundToDecimal(value: number, decimals: number = 1): number {
    const multiplier = Math.pow(10, decimals);
    return Math.round(value * multiplier) / multiplier;
  }

  /**
   * 格式化重量（四舍五入到一位小数）
   * @param weightKg 重量（公斤）
   * @param count 数量
   * @returns 总重量（吨，四舍五入到一位小数）
   */
  static calculateTotalWeight(weightKg: number, count: number): number {
    if (weightKg <= 0 || count <= 0) {
      return 0;
    }
    const totalWeightTon = (weightKg * count) / 1000; // 转换为吨
    return NumberUtils.roundToDecimal(totalWeightTon, 1);
  }

  /**
   * 安全转换为数字
   * @param value 要转换的值
   * @param defaultValue 默认值（转换失败时返回）
   * @returns 转换后的数字
   */
  static safeParseNumber(value: string | number | boolean | object | null | undefined, defaultValue: number = 0): number {
    if (typeof value === 'number' && !isNaN(value)) {
      return value;
    }
    if (typeof value === 'string') {
      const parsed = Number(value);
      return isNaN(parsed) ? defaultValue : parsed;
    }
    return defaultValue;
  }

  /**
   * 限制数字在指定范围内
   * @param value 要限制的数字
   * @param min 最小值
   * @param max 最大值
   * @returns 限制后的数字
   */
  static clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }
}

