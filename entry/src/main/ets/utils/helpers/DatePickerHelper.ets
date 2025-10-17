/**
 * 日期选择器工具类
 * 功能：封装CalendarPickerDialog的调用，提供统一的日期选择接口
 * 用途：在需要日期选择的地方直接调用，避免重复代码
 */

export class DatePickerHelper {
  /**
   * 显示日期选择器
   * @param title 选择器标题（可选）
   * @param selectedDate 当前选中的日期（可选，默认为当前日期）
   * @param minDate 最小可选日期（可选）
   * @param maxDate 最大可选日期（可选）
   * @returns Promise<string> 返回格式化的日期字符串 "YYYY-MM-DD"
   */
  static async showDatePicker(title?: string, selectedDate?: Date, minDate?: Date, maxDate?: Date): Promise<string> {
    return new Promise((resolve) => {
      const currentDate = selectedDate || new Date()
      
      console.info("DatePickerHelper.showDatePicker - " + (title || "选择日期"))
      console.info("DatePickerHelper - minDate:", minDate ? DatePickerHelper.formatDate(minDate) : "无限制")
      console.info("DatePickerHelper - maxDate:", maxDate ? DatePickerHelper.formatDate(maxDate) : "无限制")
      console.info("DatePickerHelper - selectedDate:", DatePickerHelper.formatDate(currentDate))
      
      CalendarPickerDialog.show({
        start: minDate || new Date('2020-01-01'),
        end: maxDate || new Date('2030-12-31'),
        selected: currentDate,
        onAccept: (value) => {
          const formattedDate = DatePickerHelper.formatDate(value)
          console.info("DatePickerHelper onAccept:" + JSON.stringify(value))
          resolve(formattedDate)
        },
        onCancel: () => {
          console.info("DatePickerHelper onCancel")
          resolve('')
        }
      })
    })
  }

  /**
   * 格式化日期为字符串
   * @param date 要格式化的日期对象
   * @returns string 格式化的日期字符串 "YYYY-MM-DD"
   */
  static formatDate(date: Date): string {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * 解析日期字符串为Date对象
   * @param dateString 日期字符串 "YYYY-MM-DD"
   * @returns Date 解析后的日期对象
   */
  static parseDate(dateString: string): Date {
    if (!dateString) {
      return new Date()
    }
    const parts = dateString.split('-')
    if (parts.length === 3) {
      const year = parseInt(parts[0])
      const month = parseInt(parts[1]) - 1 // 月份从0开始
      const day = parseInt(parts[2])
      return new Date(year, month, day)
    }
    return new Date()
  }

  /**
   * 获取当前日期的格式化字符串
   * @returns string 当前日期的格式化字符串
   */
  static getCurrentDateString(): string {
    return DatePickerHelper.formatDate(new Date())
  }

  /**
   * 验证日期字符串格式
   * @param dateString 要验证的日期字符串
   * @returns boolean 是否为有效的日期格式
   */
  static isValidDateString(dateString: string): boolean {
    if (!dateString) return false
    const regex = /^\d{4}-\d{2}-\d{2}$/
    if (!regex.test(dateString)) return false
    
    const date = DatePickerHelper.parseDate(dateString)
    return date instanceof Date && !isNaN(date.getTime())
  }
}
