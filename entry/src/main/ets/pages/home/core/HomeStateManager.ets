/**
 * 主页状态管理组件
 * 
 * 功能说明：
 * - 集中管理主页面的所有状态变量
 * - 提供统一的状态更新方法
 * - 简化主组件代码，提高可维护性
 * 
 * 使用方式：
 * 1. 在主组件中创建实例：private stateManager = new HomeStateManager()
 * 2. 通过 stateManager.属性名 访问状态
 * 3. 通过 stateManager.update方法名() 更新状态
 * 
 * 状态分类：
 * - FSM状态：有限状态机选择
 * - 设置状态：各种开关设置
 * - 按钮状态：功能按钮选中状态
 * - 对话框状态：弹窗显示控制
 * - 顶部指标状态：概览数据显示
 * - 分拣信息状态：分拣相关数据
 */

import { DEFAULT_TOP_BAR_DATA, DEFAULT_SORTING_INFO, DEFAULT_SETTINGS, DEFAULT_SELECTED_BUTTON, DEFAULT_SELECTED_FSM } from '../HomeConstants'

export class HomeStateManager {
  // ==================== FSM状态 ====================
  // 这些状态控制有限状态机的选择
  
  /** 选中的FSM状态 */
  selectedFSM: 'FSM1' | 'FSM2' = 'FSM1'

  // ==================== 设置状态 ====================
  // 这些状态控制各种设置开关（互斥模式 - 同一时间只能有一个开启）
  
  /** 设置1开关状态 */
  setting1Enabled: boolean = true
  
  /** 设置2开关状态 */
  setting2Enabled: boolean = false
  
  /** 设置3开关状态 */
  setting3Enabled: boolean = false
  
  /** 设置4开关状态 */
  setting4Enabled: boolean = false

  // ==================== 按钮状态 ====================
  // 这些状态控制功能按钮的选中状态
  
  /** 选中的功能按钮 */
  selectedButton: string = '等级表'

  // ==================== 对话框状态 ====================
  // 这些状态控制弹窗的显示和交互
  
  /** 是否显示出口设置对话框 */
  showOutletDialog: boolean = false
  
  /** 当前选中的出口索引（1-9） */
  currentOutletIndex: number = 1

  // ==================== 顶部指标状态 ====================
  // 这些状态控制顶部概览指标的显示
  
  /** 产量指标 */
  topProduction: string = '0.00'
  
  /** 总重量（吨） */
  topSumWeightTon: string = '0.00'
  
  /** 总计数 */
  topSumCounts: string = '0'
  
  /** 平均重量（克） */
  topAvgG: string = '0.00'

  // ==================== 分拣信息状态 ====================
  // 这些状态控制分拣相关信息的显示
  
  /** 分拣速度 */
  sortSpeed: string = '0 件/分钟'
  
  /** 批次重量 */
  batchWeight: string = '0.00 kg'
  
  /** 批次计数 */
  batchCount: string = '0 件'
  
  /** 开始时间 */
  startTime: string = '--:--:--'
  
  /** 程序名称 */
  programName: string = '未选择'
  
  /** 效率 */
  efficiency: string = '0%'
  
  /** 平均重量 */
  avgWeight: string = '0.00 kg'
  
  /** 实时产量 */
  realTimeOutput: string = '0 件/分钟'
  
  /** 间隔速度 */
  intervalSpeed: string = '0 ms'

  // ==================== 状态更新方法 ====================
  // 这些方法用于更新各种状态，确保状态变化的一致性
  
  /**
   * 更新选中的FSM状态
   * @param fsm FSM状态
   */
  updateSelectedFSM(fsm: 'FSM1' | 'FSM2'): void {
    this.selectedFSM = fsm
  }

  /**
   * 更新设置1开关状态
   * @param enabled 是否启用
   */
  updateSetting1Enabled(enabled: boolean): void {
    this.setting1Enabled = enabled
  }

  /**
   * 更新设置2开关状态
   * @param enabled 是否启用
   */
  updateSetting2Enabled(enabled: boolean): void {
    this.setting2Enabled = enabled
  }

  /**
   * 更新设置3开关状态
   * @param enabled 是否启用
   */
  updateSetting3Enabled(enabled: boolean): void {
    this.setting3Enabled = enabled
  }

  /**
   * 更新设置4开关状态
   * @param enabled 是否启用
   */
  updateSetting4Enabled(enabled: boolean): void {
    this.setting4Enabled = enabled
  }

  /**
   * 更新选中的功能按钮
   * @param button 按钮名称
   */
  updateSelectedButton(button: string): void {
    this.selectedButton = button
  }

  /**
   * 更新出口对话框显示状态
   * @param show 是否显示对话框
   */
  updateShowOutletDialog(show: boolean): void {
    this.showOutletDialog = show
  }

  /**
   * 更新当前选中的出口索引
   * @param index 出口索引（1-9）
   */
  updateCurrentOutletIndex(index: number): void {
    this.currentOutletIndex = index
  }

  /**
   * 更新顶部产量指标
   * @param production 产量值
   */
  updateTopProduction(production: string): void {
    this.topProduction = production
  }

  /**
   * 更新顶部总重量
   * @param weight 重量值
   */
  updateTopSumWeightTon(weight: string): void {
    this.topSumWeightTon = weight
  }

  /**
   * 更新顶部总计数
   * @param counts 计数值
   */
  updateTopSumCounts(counts: string): void {
    this.topSumCounts = counts
  }

  /**
   * 更新顶部平均重量
   * @param avgG 平均重量值
   */
  updateTopAvgG(avgG: string): void {
    this.topAvgG = avgG
  }

  /**
   * 更新分拣速度
   * @param speed 速度值
   */
  updateSortSpeed(speed: string): void {
    this.sortSpeed = speed
  }

  /**
   * 更新批次重量
   * @param weight 重量值
   */
  updateBatchWeight(weight: string): void {
    this.batchWeight = weight
  }

  /**
   * 更新批次计数
   * @param count 计数值
   */
  updateBatchCount(count: string): void {
    this.batchCount = count
  }

  /**
   * 更新开始时间
   * @param time 时间值
   */
  updateStartTime(time: string): void {
    this.startTime = time
  }

  /**
   * 更新程序名称
   * @param name 程序名称
   */
  updateProgramName(name: string): void {
    this.programName = name
  }

  /**
   * 更新效率
   * @param efficiency 效率值
   */
  updateEfficiency(efficiency: string): void {
    this.efficiency = efficiency
  }

  /**
   * 更新平均重量
   * @param weight 重量值
   */
  updateAvgWeight(weight: string): void {
    this.avgWeight = weight
  }

  /**
   * 更新实时产量
   * @param output 产量值
   */
  updateRealTimeOutput(output: string): void {
    this.realTimeOutput = output
  }

  /**
   * 更新间隔速度
   * @param speed 速度值
   */
  updateIntervalSpeed(speed: string): void {
    this.intervalSpeed = speed
  }

  // ==================== 状态重置方法 ====================
  
  /**
   * 重置所有状态到默认值
   * 
   * 使用场景：
   * - 页面初始化时
   * - 用户点击"重置"按钮时
   * - 需要清空所有用户输入时
   * 
   * 重置内容：
   * - FSM状态：恢复到默认选择
   * - 设置状态：恢复到默认设置
   * - 按钮状态：恢复到默认选择
   * - 对话框状态：关闭对话框
   * - 顶部指标状态：恢复到默认值
   * - 分拣信息状态：恢复到默认值
   */
  resetAllStates(): void {
    // 重置FSM状态
    this.selectedFSM = DEFAULT_SELECTED_FSM
    
    // 重置设置状态
    this.setting1Enabled = DEFAULT_SETTINGS.setting1Enabled
    this.setting2Enabled = DEFAULT_SETTINGS.setting2Enabled
    this.setting3Enabled = DEFAULT_SETTINGS.setting3Enabled
    this.setting4Enabled = DEFAULT_SETTINGS.setting4Enabled
    
    // 重置按钮状态
    this.selectedButton = DEFAULT_SELECTED_BUTTON
    
    // 重置对话框状态
    this.showOutletDialog = false
    this.currentOutletIndex = 1
    
    // 重置顶部指标状态
    this.topProduction = DEFAULT_TOP_BAR_DATA.PRODUCTION_TON_H
    this.topSumWeightTon = DEFAULT_TOP_BAR_DATA.SUM_WEIGHT_TON
    this.topSumCounts = DEFAULT_TOP_BAR_DATA.SUM_COUNTS
    this.topAvgG = DEFAULT_TOP_BAR_DATA.AVG_G
    
    // 重置分拣信息状态
    this.sortSpeed = DEFAULT_SORTING_INFO.sortSpeed
    this.batchWeight = DEFAULT_SORTING_INFO.batchWeight
    this.batchCount = DEFAULT_SORTING_INFO.batchCount
    this.startTime = DEFAULT_SORTING_INFO.startTime
    this.programName = DEFAULT_SORTING_INFO.programName
    this.efficiency = DEFAULT_SORTING_INFO.efficiency
    this.avgWeight = DEFAULT_SORTING_INFO.avgWeight
    this.realTimeOutput = DEFAULT_SORTING_INFO.realTimeOutput
    this.intervalSpeed = DEFAULT_SORTING_INFO.intervalSpeed
  }

}
