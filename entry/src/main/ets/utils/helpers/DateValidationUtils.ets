/**
 * 日期验证工具类
 * 功能：提供日期格式验证和时间比较
 * 用途：统一日期处理逻辑，避免重复代码
 */

/**
 * 日期范围验证结果接口
 */
interface DateRangeValidationResult {
  isValid: boolean;
  error?: string;
}

/**
 * 日期验证工具类
 * 提供统一的日期验证方法
 */
export class DateValidationUtils {
  /**
   * 验证日期字符串格式（YYYY-MM-DD）
   * @param dateString 日期字符串
   * @returns 是否为有效格式
   */
  static isValidDateFormat(dateString: string): boolean {
    if (!dateString || dateString.trim().length === 0) {
      return false;
    }
    // 提取日期部分（兼容带时间的格式）
    const datePart = dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    const regex = /^\d{4}-\d{2}-\d{2}$/;
    if (!regex.test(datePart)) {
      return false;
    }
    // 验证日期是否有效
    const date = new Date(datePart);
    return date instanceof Date && !isNaN(date.getTime());
  }

  /**
   * 提取日期部分（从可能包含时间的字符串中）
   * @param dateTimeString 日期时间字符串
   * @returns 日期部分（YYYY-MM-DD）
   */
  static extractDatePart(dateTimeString: string): string {
    if (!dateTimeString) {
      return '';
    }
    const trimmed = dateTimeString.trim();
    return trimmed.length > 10 ? trimmed.substring(0, 10) : trimmed;
  }

  /**
   * 比较两个日期字符串
   * @param startDate 开始日期字符串
   * @param endDate 结束日期字符串
   * @returns 如果开始日期晚于结束日期返回true，否则返回false
   */
  static isStartAfterEnd(startDate: string, endDate: string): boolean {
    try {
      const startNum = Date.parse(startDate);
      const endNum = Date.parse(endDate);
      if (isNaN(startNum) || isNaN(endNum)) {
        return false;
      }
      return startNum > endNum;
    } catch (_) {
      return false;
    }
  }

  /**
   * 验证日期范围
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @returns 验证结果对象
   */
  static validateDateRange(startDate: string, endDate: string): DateRangeValidationResult {
    if (!startDate || !endDate) {
      const result: DateRangeValidationResult = { isValid: false, error: '日期不能为空' };
      return result;
    }

    if (!DateValidationUtils.isValidDateFormat(startDate)) {
      const result: DateRangeValidationResult = { isValid: false, error: '开始日期格式无效' };
      return result;
    }

    if (!DateValidationUtils.isValidDateFormat(endDate)) {
      const result: DateRangeValidationResult = { isValid: false, error: '结束日期格式无效' };
      return result;
    }

    if (DateValidationUtils.isStartAfterEnd(startDate, endDate)) {
      const result: DateRangeValidationResult = { isValid: false, error: '开始时间不能晚于结束时间' };
      return result;
    }

    const result: DateRangeValidationResult = { isValid: true };
    return result;
  }
}

