/**
 * 主页状态管理文件
 * 
 * 这个文件包含主页所有的 @State 状态变量
 * 用于UI绑定和触发重新渲染
 * 
 * 架构说明：
 * - 这些是 @State 变量，用于UI响应和自动重新渲染
 * - 与 HomeStateManager 配合使用，实现双重状态管理
 * - HomeStateManager：负责数据管理和业务逻辑
 * - HomeState：负责状态定义和默认值管理
 * - HomeContent：负责UI渲染和用户交互
 * 
 * 使用方式：
 * 1. 在 HomeContent 中导入 DEFAULT_HOME_STATE
 * 2. 使用 @State 变量绑定到UI组件
 * 3. 状态变化时自动触发UI重新渲染
 * 
 * 注意：
 * - 所有状态变量都有明确的类型定义
 * - 默认值统一管理，便于维护
 * - 提供状态重置和快照功能
 */

/**
 * 主页状态接口
 * 
 * 定义所有状态变量的类型，确保类型安全
 * 这个接口定义了主页所有可能的状态变量
 * 
 * 状态分类：
 * - FSM状态：有限状态机选择
 * - 设置状态：各种设置开关（互斥模式）
 * - 按钮状态：功能按钮选中状态
 * - 对话框状态：弹窗显示和交互
 * - 顶部指标：概览数据展示
 * - 分拣信息：分拣相关数据
 */
export interface HomeStateInterface {
  // ==================== FSM状态 ====================
  /** 选中的FSM状态（有限状态机） */
  selectedFSM: 'FSM1' | 'FSM2'
  
  // ==================== 设置开关状态 ====================
  /** 设置1开关状态（互斥模式 - 同一时间只能有一个开启） */
  setting1Enabled: boolean
  /** 设置2开关状态 */
  setting2Enabled: boolean
  /** 设置3开关状态 */
  setting3Enabled: boolean
  /** 设置4开关状态 */
  setting4Enabled: boolean
  
  // ==================== 按钮状态 ====================
  /** 选中的功能按钮名称 */
  selectedButton: string
  
  // ==================== 对话框状态 ====================
  /** 是否显示出口设置对话框 */
  showOutletDialog: boolean
  /** 当前选中的出口索引（1-9） */
  currentOutletIndex: number
  
  // ==================== 顶部指标状态 ====================
  /** 产量指标（吨/小时） */
  topProduction: string
  /** 总重量（吨） */
  topSumWeightTon: string
  /** 总计数 */
  topSumCounts: string
  /** 平均重量（克） */
  topAvgG: string
  
  // ==================== 分拣信息状态 ====================
  /** 分拣速度（件/分钟） */
  sortSpeed: string
  /** 批次重量（kg） */
  batchWeight: string
  /** 批次计数（件） */
  batchCount: string
  /** 开始时间（HH:MM:SS） */
  startTime: string
  /** 程序名称 */
  programName: string
  /** 分拣效率（%） */
  efficiency: string
  /** 平均重量（kg） */
  avgWeight: string
  /** 实时产量（件/分钟） */
  realTimeOutput: string
  /** 间隔速度（ms） */
  intervalSpeed: string
}

/**
 * 默认状态值
 * 
 * 定义所有状态变量的默认值
 * 这些值会在组件初始化时使用
 * 
 * 重要说明：
 * - 设置1默认开启（setting1Enabled: true）
 * - 其他设置默认关闭（互斥模式）
 * - 所有数值类型的状态都有合理的默认值
 * - 时间格式使用占位符 '--:--:--'
 * - 未选择状态使用 '未选择' 标识
 */
export const DEFAULT_HOME_STATE: HomeStateInterface = {
  // ==================== FSM状态 ====================
  /** 默认选中FSM1 */
  selectedFSM: 'FSM1',
  
  // ==================== 设置开关状态 ====================
  /** 设置1默认开启 */
  setting1Enabled: true,
  /** 设置2默认关闭 */
  setting2Enabled: false,
  /** 设置3默认关闭 */
  setting3Enabled: false,
  /** 设置4默认关闭 */
  setting4Enabled: false,
  
  // ==================== 按钮状态 ====================
  /** 默认选中等级表按钮 */
  selectedButton: '等级表',
  
  // ==================== 对话框状态 ====================
  /** 默认不显示出口对话框 */
  showOutletDialog: false,
  /** 默认选中出口1 */
  currentOutletIndex: 1,
  
  // ==================== 顶部指标状态 ====================
  /** 默认产量为0.00 */
  topProduction: '0.00',
  /** 默认总重量为0.00 */
  topSumWeightTon: '0.00',
  /** 默认总计数为0 */
  topSumCounts: '0',
  /** 默认平均重量为0.00 */
  topAvgG: '0.00',
  
  // ==================== 分拣信息状态 ====================
  /** 默认分拣速度为0件/分钟 */
  sortSpeed: '0 件/分钟',
  /** 默认批次重量为0.00kg */
  batchWeight: '0.00 kg',
  /** 默认批次计数为0件 */
  batchCount: '0 件',
  /** 默认开始时间为占位符 */
  startTime: '--:--:--',
  /** 默认程序名称为未选择 */
  programName: '未选择',
  /** 默认效率为0% */
  efficiency: '0%',
  /** 默认平均重量为0.00kg */
  avgWeight: '0.00 kg',
  /** 默认实时产量为0件/分钟 */
  realTimeOutput: '0 件/分钟',
  /** 默认间隔速度为0ms */
  intervalSpeed: '0 ms'
}

/**
 * 状态管理类
 * 
 * 这个类提供状态初始化和更新方法
 * 用于管理主页的所有状态变量
 * 
 * 功能说明：
 * - 初始化所有状态变量为默认值
 * - 提供状态重置功能
 * - 提供状态快照功能
 * - 与 HomeContent 中的 @State 变量配合使用
 * 
 * 使用场景：
 * - 组件初始化时设置默认状态
 * - 需要重置状态时调用 resetToDefault()
 * - 需要获取当前状态快照时调用 getStateSnapshot()
 */
export class HomeState {
  // ==================== FSM状态 ====================
  /** 选中的FSM状态（有限状态机） */
  selectedFSM: 'FSM1' | 'FSM2' = DEFAULT_HOME_STATE.selectedFSM
  
  // ==================== 设置状态 ====================
  /** 设置1开关状态（互斥模式 - 同一时间只能有一个开启） */
  setting1Enabled: boolean = DEFAULT_HOME_STATE.setting1Enabled
  /** 设置2开关状态 */
  setting2Enabled: boolean = DEFAULT_HOME_STATE.setting2Enabled
  /** 设置3开关状态 */
  setting3Enabled: boolean = DEFAULT_HOME_STATE.setting3Enabled
  /** 设置4开关状态 */
  setting4Enabled: boolean = DEFAULT_HOME_STATE.setting4Enabled
  
  // ==================== 按钮状态 ====================
  /** 选中的功能按钮名称 */
  selectedButton: string = DEFAULT_HOME_STATE.selectedButton
  
  // ==================== 对话框状态 ====================
  /** 是否显示出口设置对话框 */
  showOutletDialog: boolean = DEFAULT_HOME_STATE.showOutletDialog
  /** 当前选中的出口索引（1-9） */
  currentOutletIndex: number = DEFAULT_HOME_STATE.currentOutletIndex
  
  // ==================== 顶部指标状态 ====================
  /** 产量指标（吨/小时） */
  topProduction: string = DEFAULT_HOME_STATE.topProduction
  /** 总重量（吨） */
  topSumWeightTon: string = DEFAULT_HOME_STATE.topSumWeightTon
  /** 总计数 */
  topSumCounts: string = DEFAULT_HOME_STATE.topSumCounts
  /** 平均重量（克） */
  topAvgG: string = DEFAULT_HOME_STATE.topAvgG
  
  // ==================== 分拣信息状态 ====================
  /** 分拣速度（件/分钟） */
  sortSpeed: string = DEFAULT_HOME_STATE.sortSpeed
  /** 批次重量（kg） */
  batchWeight: string = DEFAULT_HOME_STATE.batchWeight
  /** 批次计数（件） */
  batchCount: string = DEFAULT_HOME_STATE.batchCount
  /** 开始时间（HH:MM:SS） */
  startTime: string = DEFAULT_HOME_STATE.startTime
  /** 程序名称 */
  programName: string = DEFAULT_HOME_STATE.programName
  /** 分拣效率（%） */
  efficiency: string = DEFAULT_HOME_STATE.efficiency
  /** 平均重量（kg） */
  avgWeight: string = DEFAULT_HOME_STATE.avgWeight
  /** 实时产量（件/分钟） */
  realTimeOutput: string = DEFAULT_HOME_STATE.realTimeOutput
  /** 间隔速度（ms） */
  intervalSpeed: string = DEFAULT_HOME_STATE.intervalSpeed
  
  /**
   * 重置所有状态到默认值
   * 
   * 这个方法会将所有状态变量重置为 DEFAULT_HOME_STATE 中定义的值
   * 
   * 使用场景：
   * - 用户点击"重置"按钮时
   * - 页面重新初始化时
   * - 需要清除所有用户操作时
   * 
   * 注意：
   * - 设置1会重置为开启状态（true）
   * - 其他设置会重置为关闭状态（false）
   * - 所有数值会重置为初始值
   */
  resetToDefault(): void {
    // FSM状态重置
    this.selectedFSM = DEFAULT_HOME_STATE.selectedFSM
    
    // 设置开关状态重置
    this.setting1Enabled = DEFAULT_HOME_STATE.setting1Enabled
    this.setting2Enabled = DEFAULT_HOME_STATE.setting2Enabled
    this.setting3Enabled = DEFAULT_HOME_STATE.setting3Enabled
    this.setting4Enabled = DEFAULT_HOME_STATE.setting4Enabled
    
    // 按钮状态重置
    this.selectedButton = DEFAULT_HOME_STATE.selectedButton
    
    // 对话框状态重置
    this.showOutletDialog = DEFAULT_HOME_STATE.showOutletDialog
    this.currentOutletIndex = DEFAULT_HOME_STATE.currentOutletIndex
    
    // 顶部指标状态重置
    this.topProduction = DEFAULT_HOME_STATE.topProduction
    this.topSumWeightTon = DEFAULT_HOME_STATE.topSumWeightTon
    this.topSumCounts = DEFAULT_HOME_STATE.topSumCounts
    this.topAvgG = DEFAULT_HOME_STATE.topAvgG
    
    // 分拣信息状态重置
    this.sortSpeed = DEFAULT_HOME_STATE.sortSpeed
    this.batchWeight = DEFAULT_HOME_STATE.batchWeight
    this.batchCount = DEFAULT_HOME_STATE.batchCount
    this.startTime = DEFAULT_HOME_STATE.startTime
    this.programName = DEFAULT_HOME_STATE.programName
    this.efficiency = DEFAULT_HOME_STATE.efficiency
    this.avgWeight = DEFAULT_HOME_STATE.avgWeight
    this.realTimeOutput = DEFAULT_HOME_STATE.realTimeOutput
    this.intervalSpeed = DEFAULT_HOME_STATE.intervalSpeed
  }
  
  /**
   * 获取当前状态的副本
   * 
   * 这个方法会返回当前所有状态变量的一个副本
   * 返回的对象实现了 HomeStateInterface 接口
   * 
   * 使用场景：
   * - 需要保存当前状态时
   * - 需要将状态传递给其他组件时
   * - 需要备份状态时
   * - 调试时查看当前状态
   * 
   * 返回值：
   * - 返回一个包含所有状态变量的对象
   * - 对象类型为 HomeStateInterface
   * - 返回的是副本，修改不会影响原状态
   * 
   * 示例用法：
   * ```typescript
   * const currentState = homeState.getStateSnapshot()
   * console.log('当前状态:', currentState)
   * ```
   */
  getStateSnapshot(): HomeStateInterface {
    return {
      // FSM状态
      selectedFSM: this.selectedFSM,
      
      // 设置开关状态
      setting1Enabled: this.setting1Enabled,
      setting2Enabled: this.setting2Enabled,
      setting3Enabled: this.setting3Enabled,
      setting4Enabled: this.setting4Enabled,
      
      // 按钮状态
      selectedButton: this.selectedButton,
      
      // 对话框状态
      showOutletDialog: this.showOutletDialog,
      currentOutletIndex: this.currentOutletIndex,
      
      // 顶部指标状态
      topProduction: this.topProduction,
      topSumWeightTon: this.topSumWeightTon,
      topSumCounts: this.topSumCounts,
      topAvgG: this.topAvgG,
      
      // 分拣信息状态
      sortSpeed: this.sortSpeed,
      batchWeight: this.batchWeight,
      batchCount: this.batchCount,
      startTime: this.startTime,
      programName: this.programName,
      efficiency: this.efficiency,
      avgWeight: this.avgWeight,
      realTimeOutput: this.realTimeOutput,
      intervalSpeed: this.intervalSpeed
    }
  }
}
