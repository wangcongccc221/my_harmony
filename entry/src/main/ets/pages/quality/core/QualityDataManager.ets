/**
 * 品质页面数据管理器
 * 
 * 功能说明：
 * - 管理品质页面的所有数据操作
 * - 提供数据的增删改查功能
 * - 支持数据的初始化和重置
 * 
 * 主要功能：
 * - 品质等级数据管理
 * - 出口设置数据管理
 * - 数据验证和格式化
 * - 数据持久化支持
 * 
 * 使用场景：
 * - 品质页面数据初始化
 * - 数据表格数据更新
 * - 出口设置数据管理
 * - 数据状态同步
 */

import { QualityLevelData } from '../QualityConstants'
import { DEFAULT_QUALITY_LEVELS } from '../QualityConstants'

// 明确定义可选更新类型，避免在签名中使用对象字面量类型
interface QualityLevelUpdate {
  levelName?: string
  colorLevel?: string
  sugarLevel?: string
}

/**
 * 验证结果接口
 * 
 * 功能说明：
 * - 定义数据验证的结果结构
 * - 包含验证状态和错误信息
 * 
 * 属性说明：
 * - isValid: 验证是否通过
 * - errors: 错误信息数组
 */
interface ValidationResult {
  isValid: boolean
  errors: string[]
}

/**
 * 品质数据管理器类
 * 
 * 功能说明：
 * - 集中管理品质页面的所有数据
 * - 提供数据操作的标准接口
 * - 支持数据的验证和格式化
 * 
 * 数据管理：
 * - 品质等级数据：管理等级名称、颜色等级、糖度等级
 * - 出口设置数据：管理出口选择和配置
 * - 用户设置数据：管理用户的选择和配置
 * 
 * 使用场景：
 * - 数据初始化和管理
 * - 数据更新和同步
 * - 数据验证和格式化
 */
export class QualityDataManager {
  // ==================== 数据存储 ====================
  
  /**
   * 品质等级数据列表
   * 
   * 功能说明：
   * - 存储当前显示的品质等级数据
   * - 支持动态更新和修改
   * - 用于数据表格显示
   * 
   * 数据结构：
   * - 每个元素包含等级名称、颜色等级、糖度等级
   * - 按照等级顺序排列
   * - 支持2-6个等级的动态显示
   */
  private qualityLevels: QualityLevelData[] = []

  /**
   * 当前选中的等级数量
   * 
   * 功能说明：
   * - 存储用户选择的等级数量
   * - 用于控制显示多少个等级
   * - 影响数据表格的行数
   * 
   * 取值范围：
   * - 2-6个等级
   * - 对应LEVEL_COUNT_OPTIONS的索引
   */
  private currentLevelCount: number = 0

  /**
   * 当前选中的出口索引
   * 
   * 功能说明：
   * - 存储当前选中的出口编号
   * - 用于出口设置和显示
   * - 支持1-9号出口选择
   * 
   * 取值范围：
   * - 1-9号出口
   * - 默认值为1号出口
   */
  private currentOutletIndex: number = 1

  // ==================== 数据初始化 ====================
  
  /**
   * 初始化品质数据
   * 
   * 功能说明：
   * - 初始化品质等级数据
   * - 设置默认的等级数量
   * - 加载默认数据
   * 
   * 初始化内容：
   * - 加载默认品质等级数据
   * - 设置默认等级数量
   * - 初始化出口设置
   * 
   * 使用场景：
   * - 页面初始化时
   * - 数据重置时
   * - 应用启动时
   */
  initializeQualityData(): void {
    this.qualityLevels = DEFAULT_QUALITY_LEVELS.slice()
    this.currentLevelCount = 0
    this.currentOutletIndex = 1
  }

  /**
   * 获取品质等级数据
   * 
   * 功能说明：
   * - 返回当前显示品质等级数据
   * - 根据等级数量截取数据
   * - 确保数据的一致性
   * 
   * @returns 品质等级数据数组
   * 
   * 使用场景：
   * - 数据表格显示
   * - 数据导出
   * - 数据验证
   */
  getQualityLevels(): QualityLevelData[] {
    return this.qualityLevels.slice(0, this.currentLevelCount)
  }

  /**
   * 更新品质等级数据
   * 
   * 功能说明：
   * - 更新指定索引的品质等级数据
   * - 支持部分字段更新
   * - 确保数据的有效性
   * 
   * @param index 等级索引
   * @param data 新的等级数据
   * 
   * 使用场景：
   * - 用户编辑等级数据
   * - 数据批量更新
   * - 数据同步
   */
  updateQualityLevel(index: number, data: QualityLevelUpdate): void {
    if (index >= 0 && index < this.qualityLevels.length) {
      // 手动合并对象属性
      const currentData = this.qualityLevels[index]
      this.qualityLevels[index] = {
        levelName: data.levelName !== undefined ? data.levelName : currentData.levelName,
        colorLevel: data.colorLevel !== undefined ? data.colorLevel : currentData.colorLevel,
        sugarLevel: data.sugarLevel !== undefined ? data.sugarLevel : currentData.sugarLevel
      }
    }
  }

  /**
   * 设置等级数量
   * 
   * 功能说明：
   * - 设置当前显示的等级数量
   * - 更新数据表格显示
   * - 确保数据的一致性
   * 
   * @param count 等级数量索引（0-4对应2-6个等级）
   * 
   * 使用场景：
   * - 用户选择等级数量
   * - 数据表格更新
   * - 界面刷新
   */
  setLevelCount(count: number): void {
    if (count >= 0 && count <= 16) {
      this.currentLevelCount = count
    }
  }

  /**
   * 获取当前等级数量
   * 
   * 功能说明：
   * - 返回当前设置的等级数量索引
   * - 用于界面显示和数据处理
   * 
   * @returns 等级数量索引
   * 
   * 使用场景：
   * - 界面状态显示
   * - 数据处理
   * - 状态同步
   */
  getCurrentLevelCount(): number {
    return this.currentLevelCount
  }

  /**
   * 获取实际等级数量
   * 
   * 功能说明：
   * - 返回实际的等级数量（2-6）
   * - 用于数据处理和显示
   * 
   * @returns 实际等级数量
   * 
   * 使用场景：
   * - 数据表格行数计算
   * - 数据处理
   * - 界面布局
   */
  getActualLevelCount(): number {
    return this.currentLevelCount
  }

  // ==================== 出口设置管理 ====================
  
  /**
   * 设置当前出口索引
   * 
   * 功能说明：
   * - 设置当前选中的出口编号
   * - 更新出口设置状态
   * - 确保索引的有效性
   * 
   * @param index 出口索引（1-9）
   * 
   * 使用场景：
   * - 用户选择出口
   * - 出口设置更新
   * - 状态同步
   */
  setCurrentOutletIndex(index: number): void {
    if (index >= 1 && index <= 9) {
      this.currentOutletIndex = index
    }
  }

  /**
   * 获取当前出口索引
   * 
   * 功能说明：
   * - 返回当前选中的出口编号
   * - 用于界面显示和数据处理
   * 
   * @returns 当前出口索引
   * 
   * 使用场景：
   * - 界面显示
   * - 数据处理
   * - 状态同步
   */
  getCurrentOutletIndex(): number {
    return this.currentOutletIndex
  }

  /**
   * 切换到上一个出口
   * 
   * 功能说明：
   * - 将当前出口切换到上一个
   * - 支持循环切换（9->1）
   * - 更新出口设置状态
   * 
   * 使用场景：
   * - 用户点击上一个按钮
   * - 出口循环切换
   * - 状态更新
   */
  switchToPreviousOutlet(): void {
    this.currentOutletIndex = this.currentOutletIndex > 1 ? this.currentOutletIndex - 1 : 9
  }

  /**
   * 切换到下一个出口
   * 
   * 功能说明：
   * - 将当前出口切换到下一个
   * - 支持循环切换（1->9）
   * - 更新出口设置状态
   * 
   * 使用场景：
   * - 用户点击下一个按钮
   * - 出口循环切换
   * - 状态更新
   */
  switchToNextOutlet(): void {
    this.currentOutletIndex = this.currentOutletIndex < 9 ? this.currentOutletIndex + 1 : 1
  }

  // ==================== 数据验证 ====================
  
  /**
   * 验证品质等级数据
   * 
   * 功能说明：
   * - 验证品质等级数据的有效性
   * - 检查必填字段
   * - 返回验证结果
   * 
   * @param data 要验证的数据
   * @returns 验证结果对象
   * 
   * 验证内容：
   * - 等级名称不能为空
   * - 颜色等级必须在有效范围内
   * - 糖度等级必须在有效范围内
   */
  validateQualityLevel(data: QualityLevelData): ValidationResult {
    const errors: string[] = []
    
    if (!data.levelName || data.levelName.trim() === '') {
      errors.push('等级名称不能为空')
    }
    
    if (!data.colorLevel || data.colorLevel.trim() === '') {
      errors.push('颜色等级不能为空')
    }
    
    if (!data.sugarLevel || data.sugarLevel.trim() === '') {
      errors.push('糖度等级不能为空')
    }
    
    return {
      isValid: errors.length === 0,
      errors
    }
  }

  /**
   * 验证出口索引
   * 
   * 功能说明：
   * - 验证出口索引的有效性
   * - 检查索引范围
   * - 返回验证结果
   * 
   * @param index 要验证的出口索引
   * @returns 验证结果
   * 
   * 验证内容：
   * - 索引必须在1-9范围内
   * - 索引必须是整数
   */
  validateOutletIndex(index: number): boolean {
    return Number.isInteger(index) && index >= 1 && index <= 9
  }

  // ==================== 数据重置 ====================
  
  /**
   * 重置所有数据
   * 
   * 功能说明：
   * - 重置所有数据到默认状态
   * - 清空用户设置
   * - 恢复初始配置
   * 
   * 重置内容：
   * - 品质等级数据：恢复到默认数据
   * - 等级数量：恢复到默认设置
   * - 出口设置：恢复到默认状态
   * 
   * 使用场景：
   * - 用户点击重置按钮
   * - 数据初始化
   * - 错误恢复
   */
  resetAllData(): void {
    this.qualityLevels = DEFAULT_QUALITY_LEVELS.slice()
    this.currentLevelCount = 0
    this.currentOutletIndex = 1
  }

  /**
   * 重置品质等级数据
   * 
   * 功能说明：
   * - 重置品质等级数据到默认状态
   * - 保持其他设置不变
   * 
   * 使用场景：
   * - 用户重置等级数据
   * - 数据恢复
   * - 错误处理
   */
  resetQualityLevels(): void {
    this.qualityLevels = DEFAULT_QUALITY_LEVELS.slice()
  }

  /**
   * 重置出口设置
   * 
   * 功能说明：
   * - 重置出口设置到默认状态
   * - 保持其他数据不变
   * 
   * 使用场景：
   * - 用户重置出口设置
   * - 设置恢复
   * - 错误处理
   */
  resetOutletSettings(): void {
    this.currentOutletIndex = 1
  }
}
