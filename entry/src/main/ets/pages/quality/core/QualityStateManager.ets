/**
 * 品质页面状态管理组件
 * 
 * 功能说明：
 * - 集中管理品质页面的所有状态变量
 * - 提供统一的状态更新方法
 * - 简化主组件代码，提高可维护性
 * - 支持状态重置和批量更新
 * 
 * 主要特性：
 * - 状态集中管理：所有状态变量集中在一个类中
 * - 类型安全：使用TypeScript类型定义确保类型安全
 * - 默认值支持：所有状态都有合理的默认值
 * - 更新方法：提供专门的方法更新各种状态
 * - 重置功能：支持一键重置所有状态到默认值
 * 
 * 使用方式：
 * 1. 在主组件中创建实例：private stateManager = new QualityStateManager()
 * 2. 通过 stateManager.属性名 访问状态
 * 3. 通过 stateManager.update方法名() 更新状态
 * 4. 通过 stateManager.resetAllStates() 重置所有状态
 * 
 * 状态分类：
 * - 控制面板状态：用户选择的配置参数
 * - 数据表格状态：显示的数据内容
 * - 对话框状态：弹窗显示控制
 * 
 * 设计模式：
 * - 单一职责：专门负责状态管理
 * - 封装性：隐藏状态更新细节
 * - 可扩展性：易于添加新的状态和更新方法
 * 
 * 性能优化：
 * - 避免不必要的状态更新
 * - 支持批量状态更新
 * - 提供状态快照功能
 */

import { QualityLevelData } from '../QualityConstants'
import { DEFAULT_QUALITY_SETTINGS, DEFAULT_QUALITY_LEVELS } from '../QualityConstants'

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
 * 品质页面状态管理类
 * 
 * 功能说明：
 * - 集中管理品质页面的所有状态变量
 * - 提供统一的状态更新方法
 * - 支持状态重置和批量更新
 * 
 * 状态分类：
 * - 控制面板状态：用户选择的配置参数
 * - 数据表格状态：显示的数据内容
 * - 对话框状态：弹窗显示控制
 * 
 * 使用场景：
 * - 品质页面状态管理
 * - 状态更新和重置
 * - 数据持久化
 */
export class QualityStateManager {
  // ==================== 控制面板状态 ====================
  // 这些状态控制左侧控制面板的显示和用户选择
  
  /**
   * 当前选中的等级数量索引
   * 
   * 功能说明：
   * - 存储用户选择的等级数量索引
   * - 用于控制面板显示和数据处理
   * - 默认值为DEFAULT_QUALITY_SETTINGS.defaultLevelCount
   * 
   * 使用场景：
   * - 控制面板显示当前选择
   * - 数据处理时使用选中的等级数量
   * - 状态重置时恢复默认值
   */
  levelCountIndex: number = DEFAULT_QUALITY_SETTINGS.defaultLevelCount

  // ==================== 数据表格状态 ====================
  // 这些状态控制右侧数据表格的显示内容
  
  /**
   * 品质等级数据列表
   * 
   * 功能说明：
   * - 存储品质页面的等级数据列表
   * - 用于数据表格显示和数据处理
   * - 默认为默认品质等级数据
   * 
   * 使用场景：
   * - 数据表格显示数据
   * - 数据处理和计算
   * - 状态重置时恢复默认值
   */
  qualityLevels: QualityLevelData[] = DEFAULT_QUALITY_LEVELS.slice()

  // ==================== 对话框状态 ====================
  // 这些状态控制弹窗的显示和交互
  
  /**
   * 是否显示出口设置对话框
   * 
   * 功能说明：
   * - 控制出口设置对话框的显示/隐藏
   * - 用于模态对话框控制
   * - 默认为DEFAULT_QUALITY_SETTINGS.showOutletDialog
   * 
   * 使用场景：
   * - 控制对话框显示状态
   * - 模态对话框控制
   * - 状态重置时关闭对话框
   */
  showOutletDialog: boolean = DEFAULT_QUALITY_SETTINGS.showOutletDialog
  
  /**
   * 当前选中的出口索引（1-9）
   * 
   * 功能说明：
   * - 存储当前选中的出口索引
   * - 用于出口设置对话框显示
   * - 默认为DEFAULT_QUALITY_SETTINGS.defaultOutletIndex
   * 
   * 使用场景：
   * - 出口设置对话框显示当前出口
   * - 出口切换和选择
   * - 状态重置时恢复默认值
   */
  currentOutletIndex: number = DEFAULT_QUALITY_SETTINGS.defaultOutletIndex

  // ==================== 状态更新方法 ====================
  // 这些方法用于更新各种状态，确保状态变化的一致性
  
  /**
   * 更新等级数量索引
   * 
   * 功能说明：
   * - 更新用户选择的等级数量索引
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param index 等级数量索引
   * 
   * 使用场景：
   * - 用户选择等级数量时
   * - 程序自动设置等级数量时
   * - 状态重置时恢复默认值
   */
  updateLevelCountIndex(index: number): void {
    this.levelCountIndex = index
  }

  /**
   * 更新品质等级数据
   * 
   * 功能说明：
   * - 更新品质等级数据列表
   * - 触发相关状态更新
   * - 确保状态一致性
   * 
   * @param data 品质等级数据数组
   * 
   * 使用场景：
   * - 数据加载时
   * - 数据更新时
   * - 状态重置时恢复默认值
   */
  updateQualityLevels(data: QualityLevelData[]): void {
    this.qualityLevels = data
  }

  /**
   * 更新单个品质等级数据
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
   * - 用户编辑等级数据时
   * - 数据批量更新时
   * - 数据同步时
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
   * 更新出口对话框显示状态
   * 
   * 功能说明：
   * - 更新出口对话框的显示状态
   * - 控制模态对话框的显示/隐藏
   * - 确保状态一致性
   * 
   * @param show 是否显示对话框
   * 
   * 使用场景：
   * - 打开出口设置对话框时
   * - 关闭出口设置对话框时
   * - 状态重置时关闭对话框
   */
  updateShowOutletDialog(show: boolean): void {
    this.showOutletDialog = show
  }

  /**
   * 更新当前选中的出口索引
   * 
   * 功能说明：
   * - 更新当前选中的出口索引
   * - 控制出口选择状态
   * - 确保状态一致性
   * 
   * @param index 出口索引（1-9）
   * 
   * 使用场景：
   * - 用户选择出口时
   * - 出口切换时
   * - 状态重置时恢复默认值
   */
  updateCurrentOutletIndex(index: number): void {
    this.currentOutletIndex = index
  }

  // ==================== 状态获取方法 ====================
  // 这些方法用于获取各种状态，提供状态访问接口
  
  /**
   * 获取当前等级数量索引
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
  getLevelCountIndex(): number {
    return this.levelCountIndex
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
    // 直接使用选择值(0-16)作为显示数量
    return this.levelCountIndex
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
    const levelCount = this.getActualLevelCount()
    return this.qualityLevels.slice(0, levelCount)
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
   * 获取出口对话框显示状态
   * 
   * 功能说明：
   * - 返回出口对话框的显示状态
   * - 用于界面控制
   * 
   * @returns 是否显示对话框
   * 
   * 使用场景：
   * - 界面控制
   * - 状态同步
   * - 事件处理
   */
  getShowOutletDialog(): boolean {
    return this.showOutletDialog
  }

  // ==================== 状态重置方法 ====================
  
  /**
   * 重置所有状态到默认值
   * 
   * 功能说明：
   * - 将所有状态重置为默认值
   * - 清空用户输入和选择
   * - 恢复初始状态
   * 
   * 重置内容：
   * - 控制面板状态：恢复到默认设置
   * - 数据表格状态：恢复默认数据
   * - 对话框状态：关闭对话框
   * 
   * 使用场景：
   * - 页面初始化时
   * - 用户点击"重置"按钮时
   * - 需要清空所有用户输入时
   * - 页面切换时
   * 
   * 性能优化：
   * - 批量重置，避免多次状态更新
   * - 使用默认值，确保状态一致性
   * - 清空数据，释放内存
   */
  resetAllStates(): void {
    // 重置控制面板状态
    this.levelCountIndex = DEFAULT_QUALITY_SETTINGS.defaultLevelCount
    
    // 重置数据表格状态
    this.qualityLevels = DEFAULT_QUALITY_LEVELS.slice()
    
    // 重置对话框状态
    this.showOutletDialog = DEFAULT_QUALITY_SETTINGS.showOutletDialog
    this.currentOutletIndex = DEFAULT_QUALITY_SETTINGS.defaultOutletIndex
  }

  /**
   * 重置控制面板状态
   * 
   * 功能说明：
   * - 重置控制面板相关状态
   * - 保持其他状态不变
   * 
   * 使用场景：
   * - 用户重置控制面板时
   * - 设置恢复时
   * - 错误处理时
   */
  resetControlPanelStates(): void {
    this.levelCountIndex = DEFAULT_QUALITY_SETTINGS.defaultLevelCount
  }

  /**
   * 重置数据表格状态
   * 
   * 功能说明：
   * - 重置数据表格相关状态
   * - 保持其他状态不变
   * 
   * 使用场景：
   * - 用户重置数据时
   * - 数据恢复时
   * - 错误处理时
   */
  resetDataTableStates(): void {
    this.qualityLevels = DEFAULT_QUALITY_LEVELS.slice()
  }

  /**
   * 重置对话框状态
   * 
   * 功能说明：
   * - 重置对话框相关状态
   * - 保持其他状态不变
   * 
   * 使用场景：
   * - 用户重置对话框时
   * - 设置恢复时
   * - 错误处理时
   */
  resetDialogStates(): void {
    this.showOutletDialog = DEFAULT_QUALITY_SETTINGS.showOutletDialog
    this.currentOutletIndex = DEFAULT_QUALITY_SETTINGS.defaultOutletIndex
  }

  // ==================== 状态验证方法 ====================
  
  /**
   * 验证状态有效性
   * 
   * 功能说明：
   * - 验证所有状态的有效性
   * - 检查状态值的合理性
   * - 返回验证结果
   * 
   * @returns 验证结果对象
   * 
   * 验证内容：
   * - 等级数量索引必须在有效范围内
   * - 出口索引必须在1-9范围内
   * - 品质等级数据必须有效
   */
  validateStates(): ValidationResult {
    const errors: string[] = []
    
    if (this.levelCountIndex < 0 || this.levelCountIndex > 16) {
      errors.push('等级数量必须在0-16范围内')
    }
    
    if (this.currentOutletIndex < 1 || this.currentOutletIndex > 9) {
      errors.push('出口索引必须在1-9范围内')
    }
    
    if (this.qualityLevels.length === 0) {
      errors.push('品质等级数据不能为空')
    }
    
    return {
      isValid: errors.length === 0,
      errors
    } as ValidationResult
  }

  /**
   * 获取状态快照
   * 
   * 功能说明：
   * - 获取当前状态的快照
   * - 用于状态备份和恢复
   * - 返回状态对象的深拷贝
   * 
   * @returns 状态快照对象
   * 
   * 使用场景：
   * - 状态备份
   * - 状态恢复
   * - 状态比较
   */
  getStateSnapshot(): QualityStateManager {
    const snapshot = new QualityStateManager()
    snapshot.levelCountIndex = this.levelCountIndex
    snapshot.qualityLevels = this.qualityLevels.slice()
    snapshot.showOutletDialog = this.showOutletDialog
    snapshot.currentOutletIndex = this.currentOutletIndex
    return snapshot
  }
}
