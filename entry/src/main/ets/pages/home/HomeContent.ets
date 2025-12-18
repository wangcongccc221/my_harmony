 /**
 * 主页内容组件
 * 功能：显示主页相关的内容和功能
 * 用途：在Home页面中作为主页内容显示
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { KeyCode } from '@kit.InputKit';
import { IBestSwitch } from '@ibestservices/ibest-ui'
import { SwitchControl } from '../../components/ui/forms/SwitchControl'
import { TableRow } from '../../components/layout/LevelTable'
import { DataTablesTabBar } from './DataTablesTabBar'
import { DragData } from '../../components/layout/DraggableGridTable'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_USER_NAME, TOP_STATUS_TEXT, TOP_ALERT_HIDE, HOME_SELECTED_FSM, HOME_SETTING1_ENABLED, HOME_SETTING2_ENABLED, HOME_SETTING3_ENABLED, HOME_SETTING4_ENABLED, HOME_SELECTED_BUTTON } from '../../constants/TopBarKeys'
// 导入新的组件
import { SortingInfoCard } from './SortingInfoCard'
import { LiquidCardsArea } from './LiquidCardsArea'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { getCurrentCellDragData, CELL_DRAG_ACTIVE_KEY } from '../../components/ui/tables/SimpleDraggableCell'
import { OutletDialog } from './OutletDialog'
import { HomeDataManager } from './core/HomeDataManager'
import { HomeEventHandler } from './core/HomeEventHandler'
import { HomeStateManager } from './core/HomeStateManager'
import { HomeState, DEFAULT_HOME_STATE } from './core/HomeState'
import { DEFAULT_TOP_BAR_DATA, DEFAULT_SORTING_INFO, DEFAULT_SETTINGS, DEFAULT_SELECTED_BUTTON, DEFAULT_SELECTED_FSM } from './HomeConstants'
import { CardDetailDialog } from '../../components/dialogs/CardDetailDialog'
import { ThreeLayerCardData } from '../../components/ThreeLayerCard/types'
import { RealtimeDataManager, RealtimeCalculatedData } from '../../utils/managers/RealtimeDataManager'
import { StStatistics } from '../../utils/network/tcp/types/StStatistics'

// 日志总开关（减少频繁日志导致的内存与卡顿）
const LOG_TIME_ENABLED: boolean = false
const LOG_SORT_ENABLED: boolean = false

// 全局键盘状态：主页是否按下左 Ctrl（供等级表等组件使用）
const HOME_CTRL_PRESSED = 'HOME_CTRL_PRESSED'

// FSM设置状态接口
interface FSMSettings {
  setting1: boolean
  setting2: boolean
  setting3: boolean
  setting4: boolean
}

// 相关全局键的初始化已前移到 aboutToAppear，避免模块级 IIFE 造成不必要的开销

// [TODO 提醒 - 重要]
// SwitchWrapper 与 IBestSwitch 的双向绑定注意：
// 当前 SwitchWrapper 使用 @Prop isEnabled，并在 IBestSwitch.value 上传入 $isEnabled。
// 在 ArkTS 中，$ 语法要求引用的是 @State/@Link；@Prop 为只读，可能导致绑定无效或产生不可预期行为。
// 后续修复可选方案：
// A) 将 SwitchWrapper 的 isEnabled 改为 @Link；父组件传入 $settingXEnabled；内部继续使用 value: $isEnabled；
// B) 在 SwitchWrapper 内使用 @State localEnabled 自管理，并在 onBeforeChange 同步与回调 onToggle 通知父层；
// 暂仅记录提醒，待稍后按确定方案统一修改。
// IBestSwitch 包装，解决 value 为 @Link 的绑定需求
@Component
struct SwitchWrapper {
  @Prop isEnabled: boolean = false
  onToggle: () => void = () => {}

  build() {
    IBestSwitch({
      value: $isEnabled, // 双向绑定到本地 isEnabled
      switchSize: 24,
      activeColor: '#EA7A10',
      inactiveColor: '#E0E0E0',
      onBeforeChange: (_next: boolean) => {
        // 直接执行切换，减少Promise开销
        this.onToggle()
        return Promise.resolve(true)
      }
    })
  }
}

@Component
export struct HomeContent {
  // 数据管理器
  private dataManager = HomeDataManager.getInstance()
  // 事件处理器
  private eventHandler = new HomeEventHandler()
  // 状态管理器
  private stateManager = new HomeStateManager()
  // 状态管理（移除未使用的 HomeState 实例，改由 DEFAULT_HOME_STATE 作初始化来源）

  // ==================== 状态变量（用于UI绑定） ====================
  // 这些 @State 变量与状态管理器同步，确保UI能正确响应状态变化
  
  @StorageLink(HOME_SELECTED_FSM) @Watch('onFSMChange') private selectedFSM: 'FSM1' | 'FSM2' = DEFAULT_HOME_STATE.selectedFSM
  @StorageLink(HOME_SETTING1_ENABLED) private setting1Enabled: boolean = DEFAULT_HOME_STATE.setting1Enabled
  @StorageLink(HOME_SETTING2_ENABLED) private setting2Enabled: boolean = DEFAULT_HOME_STATE.setting2Enabled
  @StorageLink(HOME_SETTING3_ENABLED) private setting3Enabled: boolean = DEFAULT_HOME_STATE.setting3Enabled
  @StorageLink(HOME_SETTING4_ENABLED) private setting4Enabled: boolean = DEFAULT_HOME_STATE.setting4Enabled
  @StorageLink(HOME_SELECTED_BUTTON) private selectedButton: string = DEFAULT_HOME_STATE.selectedButton
  @State private showOutletDialog: boolean = DEFAULT_HOME_STATE.showOutletDialog
  @State private currentOutletIndex: number = DEFAULT_HOME_STATE.currentOutletIndex
  // 卡片详情对话框状态
  @State private showCardDialog: boolean = false
  @State private selectedCardIndex: number = -1
  @State private selectedCardData: ThreeLayerCardData | null = null
  @State private topProduction: string = DEFAULT_HOME_STATE.topProduction
  @State private topSumWeightTon: string = DEFAULT_HOME_STATE.topSumWeightTon
  @State private topSumCounts: string = DEFAULT_HOME_STATE.topSumCounts
  @State private topAvgG: string = DEFAULT_HOME_STATE.topAvgG
  @State private sortSpeed: string = DEFAULT_HOME_STATE.sortSpeed
  @State private batchWeight: string = DEFAULT_HOME_STATE.batchWeight
  @State private batchCount: string = DEFAULT_HOME_STATE.batchCount
  @State private startTime: string = DEFAULT_HOME_STATE.startTime
  @State private programName: string = DEFAULT_HOME_STATE.programName
  @State private efficiency: string = DEFAULT_HOME_STATE.efficiency
  @State private avgWeight: string = DEFAULT_HOME_STATE.avgWeight
  @State private realTimeOutput: string = DEFAULT_HOME_STATE.realTimeOutput
  @State private intervalSpeed: string = DEFAULT_HOME_STATE.intervalSpeed
  // 实时数据管理器
  private realtimeDataManager: RealtimeDataManager = RealtimeDataManager.getInstance()
  // TCP数据更新监听（使用AppStorage，现在可以在UI线程中使用）
  @StorageLink('TCP_STATISTICS_GLOBAL_UPDATE') @Watch('onTcpDataUpdate') private tcpDataUpdate: number = 0
  // 上次检查的数据版本号（作为备用检测机制）
  private lastCheckVersion: number = 0
  // TCP数据更新定时器（定期检查数据是否有更新，作为备用机制）
  private tcpDataCheckTimerId?: number
  // 模拟实时数据定时器（已禁用，改用TCP真实数据）
  private mockSortingInfoTimerId?: number
  
  // 时间更新定时器
  private timeUpdateTimerId?: number
  // ==================== 拖拽浮层预览状态 ====================
  @State private dragOverlayActive: boolean = false
  @State private dragOverlayX: number = 0
  @State private dragOverlayY: number = 0
  @State private dragOverlayText: string = ''
  // 等级统计更新事件监听（简化负载）
  @StorageLink(StorageKeys.LEVEL_STAT_UPDATE) private levelStatUpdate: Record<string, number | string> | null = null
  // 批量追加（多选仅添加）
  @StorageLink(StorageKeys.LEVEL_STAT_UPDATE_BATCH) private levelStatUpdateBatch: Record<string, number | string | string[]> | null = null
  @StorageLink(StorageKeys.LEVEL_STAT_REMOVE) private levelStatRemove: Record<string, number | string> | null = null
  @State private statsVersion: number = 0
  @State private tablesRefreshKey: number = 0
  @State private settingsRenderKey: number = 0
  
  // FSM设置状态存储（每个FSM独立保存设置状态）
  @State private fsm1Settings: FSMSettings = {
    setting1: false,
    setting2: false,
    setting3: false,
    setting4: false
  }
  @State private fsm2Settings: FSMSettings = {
    setting1: false,
    setting2: false,
    setting3: false,
    setting4: false
  }
  // 记录上一个FSM状态，用于保存设置状态
  private previousFSM: 'FSM1' | 'FSM2' = 'FSM1'

  // 生成从 start 开始、长度为 count 的数字序列（类型安全）
  private buildNumberRange(start: number, count: number): number[] {
    const result: number[] = []
    for (let i = 0; i < count; i++) {
      result.push(start + i)
    }
    return result
  }

  

  /**
   * 获取指定表格的数据
   * @param tableName 表格名字
   * @returns 表格数据
   */
  private getTableData(tableName: string): TableRow[] {
    const data = this.dataManager.getTableData(tableName)
    console.log(`HomeContent 获取表格数据 ${tableName}:`, data, `当前FSM: ${this.dataManager.getCurrentFSM()}`)
    return data
  }

  /**
   * 触发等级统计表刷新
   */
  public refreshStatisticsTable(): void {
    this.statsVersion++
    this.tablesRefreshKey++
    console.log('HomeContent: 等级统计表刷新已触发')
  }


  // 分选信息（占位数据）
  // 后续接入真实数据建议：
  // 1) 数据来源：
  //    - 设备/服务层（本地ServiceAbility/分选机SDK）、
  //    - 后端接口（HTTP/WebSocket/MQTT）、
  //    - 本地缓存（首屏占位）。
  // 2) 订阅时机：
  //    - aboutToAppear() 中发起订阅/轮询/连接；
  //    - aboutToDisappear() 中取消订阅/关闭连接，避免内存泄漏。
  // 3) 更新方式：
  //    - 收到新数据后直接赋值到以下 @State 字段，UI会自动刷新；
  //    - 注意在UI线程更新；如有耗时计算，请在后台完成后再set。
  // 4) 格式化：
  //    - 速度: 将原始数值格式化为 `${value} 件/分钟`；
  //    - 重量: 使用固定小数位，如 `${kg.toFixed(2)} kg`；
  //    - 个数: `${count} 件`；
  //    - 时间: 将时间戳格式化为 `HH:mm:ss`；
  //    - 程序: 取当前正在运行的程序名；
  //    - 效率: 百分比 `${(ratio*100).toFixed(0)}%`。

  // 获取当前主题配置的方法
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return OmniThemeManager.getInstance().getCurrentTheme()
  }

  /**
   * 检查是否为最后一个开启的设置
   * @param currentIndex 当前设置的索引
   * @returns 是否为最后一个开启的设置
   */
  private isLastEnabledSetting(currentIndex: number): boolean {
    const settings = [this.setting1Enabled, this.setting2Enabled, this.setting3Enabled, this.setting4Enabled]
    const enabledCount = settings.filter(enabled => enabled).length
    
    // 如果只有一个设置开启，且当前设置是开启的，则不能关闭
    return enabledCount === 1 && settings[currentIndex]
  }

  /**
   * 监听TCP数据更新（通过AppStorage，主要方式）
   */
  onTcpDataUpdate(): void {
    console.log(`[HomeContent] 收到TCP数据更新通知，立即更新UI`)
    this.updateFromTcpData()
  }
  
  /**
   * 检查TCP数据是否有更新（通过轮询全局版本号，备用机制）
   */
  private checkTcpDataUpdate(): void {
    try {
      const subsysId: number = this.selectedFSM === 'FSM1' ? 0 : 1
      const currentVersion: number = this.realtimeDataManager.getUpdateVersion(subsysId)
      
      // 如果版本号变化，说明数据有更新，则更新UI（备用机制）
      if (currentVersion !== this.lastCheckVersion) {
        console.log(`[HomeContent] 检测到数据更新（备用机制）！版本号从 ${this.lastCheckVersion} 变为 ${currentVersion}`)
        this.lastCheckVersion = currentVersion
        this.updateFromTcpData()
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[HomeContent] 检查TCP数据更新失败: ${errorMsg}`)
    }
  }

  /**
   * 从TCP数据更新UI
   */
  private updateFromTcpData(): void {
    try {
      console.log(`[HomeContent] 开始更新UI数据...`)
      // 根据当前FSM获取子系统ID（FSM1=0, FSM2=1）
      const subsysId: number = this.selectedFSM === 'FSM1' ? 0 : 1
      
      // 获取统计数据
      const statistics: StStatistics = this.realtimeDataManager.getStatistics(subsysId)
      console.log(`[HomeContent] 获取统计数据 - 总个数: ${statistics.nTotalCount}, 总重量: ${statistics.nWeightCount}`)
      
      // 获取计算后的实时数据
      const calculated: RealtimeCalculatedData | null = this.realtimeDataManager.getCalculatedData(subsysId)
      
      // 如果没有计算数据，使用所有子系统的平均值
      const finalCalculated: RealtimeCalculatedData = calculated || this.realtimeDataManager.getAllCalculatedData()
      console.log(`[HomeContent] 计算数据 - 分选速度: ${finalCalculated.sortSpeed}, 实时产量: ${finalCalculated.realTimeOutput}`)
      
      // 更新分选速度
      this.sortSpeed = `${Math.round(finalCalculated.sortSpeed)} 件/分钟`
      AppStorage.setOrCreate('SORT_SPEED', this.sortSpeed)
      
      // 更新实时产量（转换为件/分钟显示，实际是吨/小时）
      // 注意：这里可能需要根据实际需求调整显示格式
      this.realTimeOutput = `${finalCalculated.realTimeOutput.toFixed(2)} 吨/小时`
      AppStorage.setOrCreate('REALTIME_OUTPUT', this.realTimeOutput)
      
      // 更新本批个数
      this.batchCount = `${statistics.nTotalCount} 件`
      AppStorage.setOrCreate('BATCH_COUNT', this.batchCount)
      
      // 更新本批重量（转换为kg）
      const weightKg = statistics.nWeightCount / 1000.0 // 克转千克
      this.batchWeight = `${weightKg.toFixed(2)} kg`
      AppStorage.setOrCreate('BATCH_WEIGHT', this.batchWeight)
      
      // 更新平均重量（转换为kg）
      const avgKg = finalCalculated.avgWeight / 1000.0 // 克转千克
      this.avgWeight = `${avgKg.toFixed(2)} kg`
      AppStorage.setOrCreate('AVG_WEIGHT', this.avgWeight)
      
      // 更新分选效率
      this.efficiency = `${finalCalculated.separationEfficiency.toFixed(1)}%`
      AppStorage.setOrCreate('EFFICIENCY', this.efficiency)
      
      // 更新间隔速度
      this.intervalSpeed = `${Math.round(finalCalculated.intervalSpeed)} ms`
      AppStorage.setOrCreate('INTERVAL_SPEED', this.intervalSpeed)
      
      // 更新开始时间（如果总个数大于0且开始时间为空）
      if (statistics.nTotalCount > 0 && (this.startTime === '--:--:--' || this.startTime === '')) {
        const now = new Date()
        const hh = String(now.getHours()).padStart(2, '0')
        const mm = String(now.getMinutes()).padStart(2, '0')
        const ss = String(now.getSeconds()).padStart(2, '0')
        this.startTime = `${hh}:${mm}:${ss}`
        AppStorage.setOrCreate('START_TIME', this.startTime)
      }
      
      // 更新顶部状态栏数据（使用所有子系统的累加数据）
      const allStatistics: StStatistics = this.realtimeDataManager.getAllStatistics()
      const allCalculated: RealtimeCalculatedData = this.realtimeDataManager.getAllCalculatedData()
      
      console.log(`[HomeContent] 顶部状态栏数据 - 总个数: ${allStatistics.nTotalCount}, 总重量: ${allStatistics.nWeightCount}克`)
      console.log(`[HomeContent] 顶部状态栏计算数据 - 实时产量: ${allCalculated.realTimeOutput}吨/小时, 平均果重: ${allCalculated.avgWeight}克`)
      
      // 实时产量（吨/小时）
      const newProduction = allCalculated.realTimeOutput.toFixed(2)
      this.topProduction = newProduction
      // 使用 setOrCreate 确保更新，即使值相同也会触发
      AppStorage.setOrCreate(TOP_PRODUCTION_TON_H, newProduction)
      console.log(`[HomeContent] 更新顶部实时产量: ${this.topProduction}`)
      
      // 总重量（吨）
      const totalWeightTon = allStatistics.nWeightCount / 1000000.0
      const newSumWeightTon = totalWeightTon.toFixed(2)
      this.topSumWeightTon = newSumWeightTon
      AppStorage.setOrCreate(TOP_SUM_WEIGHT_TON, newSumWeightTon)
      console.log(`[HomeContent] 更新顶部总重量: ${this.topSumWeightTon}吨`)
      
      // 总个数
      const newSumCounts = String(allStatistics.nTotalCount)
      this.topSumCounts = newSumCounts
      AppStorage.setOrCreate(TOP_SUM_COUNTS, newSumCounts)
      console.log(`[HomeContent] 更新顶部总个数: ${this.topSumCounts}`)
      
      // 平均果重（克）
      const newAvgG = allCalculated.avgWeight.toFixed(2)
      this.topAvgG = newAvgG
      AppStorage.setOrCreate(TOP_AVG_G, newAvgG)
      console.log(`[HomeContent] 更新顶部平均果重: ${this.topAvgG}克`)
      
      // 更新等级表和等级统计表数据（从TCP数据更新）
      this.dataManager.setFSM(this.selectedFSM)
      this.dataManager.updateLevelTableFromTcp() // 更新等级表
      this.dataManager.updateStatisticsTableFromTcp() // 更新等级统计表
      
      console.log(`[HomeContent] UI数据更新完成 - 分选速度: ${this.sortSpeed}, 本批个数: ${this.batchCount}, 本批重量: ${this.batchWeight}`)
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error('[HomeContent] 更新TCP数据失败:', errorMsg)
    }
  }

  /**
   * 监听FSM状态变化
   */
  onFSMChange(): void {
    console.log(`HomeContent: FSM状态变化: ${this.previousFSM} -> ${this.selectedFSM}`)
    
    // 保存上一个FSM的设置状态（在恢复新FSM之前）
    const currentSettings: FSMSettings = {
      setting1: this.setting1Enabled,
      setting2: this.setting2Enabled,
      setting3: this.setting3Enabled,
      setting4: this.setting4Enabled
    }
    
    // 保存上一个FSM的设置状态
    if (this.previousFSM === 'FSM1') {
      this.fsm1Settings = currentSettings
      console.log(`💾 保存FSM1的设置状态:`, currentSettings)
    } else {
      this.fsm2Settings = currentSettings
      console.log(`💾 保存FSM2的设置状态:`, currentSettings)
    }
    
    // 恢复目标FSM的设置状态
    let targetSettings = this.selectedFSM === 'FSM1' ? this.fsm1Settings : this.fsm2Settings
    console.log(`🔍 恢复${this.selectedFSM}的设置状态:`, targetSettings)
    
    // 检查目标FSM是否已经初始化过（如果所有设置都是false，说明未初始化）
    const isUninitialized = !targetSettings.setting1 && !targetSettings.setting2 && 
                           !targetSettings.setting3 && !targetSettings.setting4
    
    // 如果未初始化，根据FSM设置默认值：FSM1默认"设置1"，FSM2默认"设置3"
    if (isUninitialized) {
      if (this.selectedFSM === 'FSM1') {
        targetSettings = {
          setting1: true,
          setting2: false,
          setting3: false,
          setting4: false
        }
        this.fsm1Settings = targetSettings
        console.log(`🎯 ${this.selectedFSM}未初始化，默认开启设置1`)
      } else {
        targetSettings = {
          setting1: false,
          setting2: false,
          setting3: true,
          setting4: false
        }
        this.fsm2Settings = targetSettings
        console.log(`🎯 ${this.selectedFSM}未初始化，默认开启设置3`)
      }
    }
    
    // 应用目标FSM的设置状态
    this.setting1Enabled = targetSettings.setting1
    this.setting2Enabled = targetSettings.setting2
    this.setting3Enabled = targetSettings.setting3
    this.setting4Enabled = targetSettings.setting4
    
    // 同步到状态管理器
    this.stateManager.updateSetting1Enabled(targetSettings.setting1)
    this.stateManager.updateSetting2Enabled(targetSettings.setting2)
    this.stateManager.updateSetting3Enabled(targetSettings.setting3)
    this.stateManager.updateSetting4Enabled(targetSettings.setting4)
    
    // 更新previousFSM为当前FSM，为下次切换做准备
    this.previousFSM = this.selectedFSM
    
    // 更新数据管理器的FSM状态
    this.dataManager.setFSM(this.selectedFSM)
    // 更新顶部状态栏
    this.updateTopBarForFSM()
    // 刷新表格数据
    this.tablesRefreshKey++
  }

  // 切换FSM状态
  private switchFSM(fsm: 'FSM1' | 'FSM2'): void {
    this.selectedFSM = fsm
    this.stateManager.updateSelectedFSM(fsm)
    this.eventHandler.switchFSM(fsm)
    
    // 更新数据管理器的FSM状态
    this.dataManager.setFSM(fsm)
    
    // 更新顶部状态栏
    this.updateTopBarForFSM()
    
    // 刷新表格数据
    this.tablesRefreshKey++
  }

  // 设置开关映射表
  private settingMap: Record<string, () => boolean> = {
    '设置1': () => this.setting1Enabled,
    '设置2': () => this.setting2Enabled,
    '设置3': () => this.setting3Enabled,
    '设置4': () => this.setting4Enabled
  }

  // 设置状态更新映射表
  private settingUpdateMap: Record<string, (value: boolean) => void> = {
    '设置1': (value: boolean) => { 
      this.setting1Enabled = value
      this.stateManager.updateSetting1Enabled(value)
    },
    '设置2': (value: boolean) => { 
      this.setting2Enabled = value
      this.stateManager.updateSetting2Enabled(value)
    },
    '设置3': (value: boolean) => { 
      this.setting3Enabled = value
      this.stateManager.updateSetting3Enabled(value)
    },
    '设置4': (value: boolean) => { 
      this.setting4Enabled = value
      this.stateManager.updateSetting4Enabled(value)
    }
  }

  // 处理设置状态变更（互斥逻辑：当某个开启时，关闭其他所有）
  private handleSettingChange(activeSetting: '设置1' | '设置2' | '设置3' | '设置4'): void {
    // 检查当前这个设置是否刚刚变成了"开启"状态
    // 注意：由于是 @Link 双向绑定，SwitchControl 内部已经修改了 settingXEnabled 的值
    if (this.settingMap[activeSetting]()) {
      // 如果它现在是开启的，那么我们需要把其他所有的都关掉
      const allSettings: ('设置1' | '设置2' | '设置3' | '设置4')[] = ['设置1', '设置2', '设置3', '设置4']
      allSettings.forEach(setting => {
        if (setting !== activeSetting) {
          // 关闭其他设置
          this.settingUpdateMap[setting](false)
        }
      })
      
      // 调用事件处理器通知业务层
      this.eventHandler.toggleSetting(activeSetting)
    }
    // 如果是变成了"关闭"状态，我们不需要做任何事，
    // 因为 SwitchControl 内部的 isLastEnabled 逻辑已经保证了"最后一个不能关闭"。
    // 只有当有 >=2 个开启时才能关闭其中一个，这时候也无需联动其他。
  }

  // 选择功能按钮
  private selectButton(buttonName: string): void {
    this.selectedButton = buttonName
    this.stateManager.updateSelectedButton(buttonName)
    this.eventHandler.selectButton(buttonName)
  }

  // 添加数据到表格的封装函数
  private addDataToTables(): void {
    // 使用数据管理器初始化数据
    this.dataManager.initializeAllTableData()  //初始化数据
  }

  // 处理等级统计更新：为指定等级追加出口编号（去重）
  private applyLevelStatUpdate(levelName: string, exitNum: number): void {
    const tableName = '等级统计表'
    const rows: TableRow[] = this.dataManager.getTableData(tableName)
    const idx: number = rows.findIndex((r: TableRow) => String(r && r[0]) === levelName)
    if (idx < 0) {
      console.warn(`未在${tableName}中找到等级行:`, levelName)
      return
    }
    const updatedRow: TableRow = [...rows[idx]]
    const exitColIndex = 2 // 等级出口
    const currentVal: string = String(updatedRow[exitColIndex] || '').trim()
    const entry = `出口${exitNum}`
    let nextVal: string
    if (!currentVal) {
      nextVal = entry
    } else if (currentVal.indexOf(entry) >= 0) {
      nextVal = currentVal
    } else {
      nextVal = `${currentVal}、${entry}`
    }
    updatedRow[exitColIndex] = nextVal

    const newRows: TableRow[] = [...rows]
    newRows[idx] = updatedRow
    
    // 使用FSM特定的键名更新数据
    this.dataManager.updateFSMTableData(tableName, newRows)
    this.statsVersion++
  }

  // 处理等级统计移除：为指定等级移除某个出口编号
  private applyLevelStatRemove(levelName: string, exitNum: number): void {
    const tableName = '等级统计表'
    const rows: TableRow[] = this.dataManager.getTableData(tableName)
    const idx: number = rows.findIndex((r: TableRow) => String(r && r[0]) === levelName)
    if (idx < 0) {
      console.warn(`未在${tableName}中找到等级行:`, levelName)
      return
    }
    const updatedRow: TableRow = [...rows[idx]]
    const exitColIndex = 2 // 等级出口
    const currentVal: string = String(updatedRow[exitColIndex] || '').trim()
    const entry = `出口${exitNum}`
    if (!currentVal) { return }
    const items = currentVal.split('、').map(s => s.trim()).filter(Boolean)
    const nextItems = items.filter(s => s !== entry)
    const nextVal = nextItems.join('、')
    updatedRow[exitColIndex] = nextVal

    const newRows: TableRow[] = [...rows]
    newRows[idx] = updatedRow
    
    // 使用FSM特定的键名更新数据
    this.dataManager.updateFSMTableData(tableName, newRows)
    this.statsVersion++
  }


  // 处理出口按钮点击
  private handleOutletClick(outletNumber: number): void {
    this.currentOutletIndex = outletNumber
    this.showOutletDialog = true
    this.stateManager.updateCurrentOutletIndex(outletNumber)
    this.stateManager.updateShowOutletDialog(true)
    this.eventHandler.handleOutletClick(outletNumber)
  }

  // 切换到上一个出口
  private switchToPreviousOutlet(): void {
    const newIndex = this.currentOutletIndex > 1 ? this.currentOutletIndex - 1 : 9
    this.currentOutletIndex = newIndex
    this.stateManager.updateCurrentOutletIndex(newIndex)
    this.eventHandler.handleOutletPrevious()
  }

  // 切换到下一个出口
  private switchToNextOutlet(): void {
    const newIndex = this.currentOutletIndex < 9 ? this.currentOutletIndex + 1 : 1
    this.currentOutletIndex = newIndex
    this.stateManager.updateCurrentOutletIndex(newIndex)
    this.eventHandler.handleOutletNext()
  }

  // 确认出口设置
  private confirmOutletSetting(): void {
    this.showOutletDialog = false
    this.stateManager.updateShowOutletDialog(false)
    this.eventHandler.handleOutletConfirm()
  }

  // 取消出口设置
  private cancelOutletSetting(): void {
    this.showOutletDialog = false
    this.stateManager.updateShowOutletDialog(false)
    this.eventHandler.handleOutletCancel()
  }

  // 处理卡片点击
  private handleCardClick(cardIndex: number, cardData: ThreeLayerCardData): void {
    console.log(`卡片被点击: index=${cardIndex}`)
    this.currentOutletIndex = cardIndex + 1
    this.stateManager.updateCurrentOutletIndex(this.currentOutletIndex)
    this.showOutletDialog = true
    this.stateManager.updateShowOutletDialog(true)
    
    // 也可以保留选中数据供后续使用
    this.selectedCardIndex = cardIndex
    this.selectedCardData = cardData
  }

  // 关闭卡片详情对话框
  private closeCardDialog(): void {
    this.showCardDialog = false
    this.selectedCardIndex = -1
    this.selectedCardData = null
  }



  // 将原来的build方法内容提取为单独的方法
  @Builder
  private buildMainContent() {
    Column() {
      // 设置开关区域（FSM切换已移至顶部状态栏）
      Row() {
        SwitchControl({ 
          label: '设置1', 
          isEnabled: $setting1Enabled, 
          switchSize: 26,
          isLastEnabled: this.isLastEnabledSetting(0),
          onToggle: () => { this.handleSettingChange('设置1') } 
        })
        SwitchControl({ 
          label: '设置2', 
          isEnabled: $setting2Enabled, 
          switchSize: 26,
          isLastEnabled: this.isLastEnabledSetting(1),
          onToggle: () => { this.handleSettingChange('设置2') } 
        })
        SwitchControl({ 
          label: '设置3', 
          isEnabled: $setting3Enabled, 
          switchSize: 26,
          isLastEnabled: this.isLastEnabledSetting(2),
          onToggle: () => { this.handleSettingChange('设置3') } 
        })
        SwitchControl({ 
          label: '设置4', 
          isEnabled: $setting4Enabled, 
          switchSize: 26,
          isLastEnabled: this.isLastEnabledSetting(3),
          onToggle: () => { this.handleSettingChange('设置4') } 
        })
      }
      .key(`settings-${this.settingsRenderKey}`)
      .width('100%')
      .height('auto')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ top: '1%', left: '0.93%', right: '0.93%', bottom: '1%' })
      .onAppear(() => {
        // 使用多次延迟刷新确保布局完成
        setTimeout(() => {
          this.settingsRenderKey++
          console.log('[HomeContent] 设置区域已显示，第一次刷新')
        }, 50)
        setTimeout(() => {
          this.settingsRenderKey++
          console.log('[HomeContent] 设置区域已显示，第二次刷新')
        }, 300)
        setTimeout(() => {
          this.settingsRenderKey++
          console.log('[HomeContent] 设置区域已显示，第三次刷新')
        }, 600)
      })
      // 主页信息卡片：分选速度 | 本批重量 | 本批个数 | 开始时间 | 分选程序 | 分选效率 | 平均重量 | 实时产量 | 间隔速度
      Row() {
        Blank().width('1.5%')  // 左边间隙
        SortingInfoCard()
          .layoutWeight(1)  // 自适应宽度，填充剩余空间
        Blank().width('1.5%')  // 右边间隙
      }
      .width('100%')
      .margin({ bottom: '1%' })

      // 液体卡片区域：单容器自动换行，固定显示两排高度，支持纵向滚动查看更多
      Row() {
        Blank().width('1.5%')  // 左边间隙
        LiquidCardsArea({
          onCardClick: (cardIndex: number, cardData: ThreeLayerCardData) => {
            this.handleCardClick(cardIndex, cardData)
          }
        })
          .layoutWeight(1)  // 自适应宽度，填充剩余空间
        Blank().width('1.5%')  // 右边间隙
      }
      .width('100%')
      .height('32%')  // 液体卡片区域占主页的32%（折中方案）
      .margin({ bottom: '0.5%' })

      // 数据表格TabBar组件 - 替换原有的FunctionButtons和DataTablesCard
      Row() {
        Blank().width('1.5%')  // 左边间隙
        DataTablesTabBar({
          levelTableData: this.getTableData('等级表'),
        containerTableData: this.getTableData('容器表'),
        statisticsTableData: this.getTableData('等级统计表'),
        dynamicPackingTableData: this.getTableData('动态装箱'),
        finishedProductsTableData: this.getTableData('成品'),
        levelTableDragData: [],
        containerTableDragData: [],
        statisticsTableDragData: [],
        dynamicPackingTableDragData: [],
        finishedProductsTableDragData: [],
        refreshKey: this.tablesRefreshKey,
        onRowDragStart: (dragData: DragData) => {
          console.log('主页接收到拖拽开始:', dragData)
        },
        onRowDragEnd: () => {
          console.log('主页接收到拖拽结束')
        }
      })
          .layoutWeight(1)  // 自适应宽度，填充剩余空间
          .height('53%') // 表格区域占53%
        Blank().width('1.5%')  // 右边间隙
      }
      .width('100%')
      .margin({ bottom: 0 })



      
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }

  build() {
    Stack() {
      // 主要内容
      this.buildMainContent()
      
      // 侦听FSM切换事件（优化：减少重复监听，使用防抖机制避免循环触发）
      if (this.selectedFSM) {
        Blank()
          .key(`fsm-${this.selectedFSM}`) // 使用key避免重复触发
          .onAppear(() => {
            // 使用异步延迟，避免在渲染过程中同步更新导致循环
            Promise.resolve().then(() => {
              this.dataManager.setFSM(this.selectedFSM)
              this.updateTopBarForFSM()
              this.tablesRefreshKey++
            })
          })
      }
      
      // 侦听等级统计更新事件（UI语法包裹，逻辑在回调内，添加防重复触发机制）
      if (this.levelStatUpdate && typeof this.levelStatUpdate['levelName'] === 'string' && typeof this.levelStatUpdate['exit'] !== 'undefined') {
        Blank()
          .key(`stat-update-${this.levelStatUpdate['levelName']}-${this.levelStatUpdate['exit']}`) // 使用key避免重复触发
          .onAppear(() => {
            // 先清除AppStorage，避免重复触发
            const ln = String(this.levelStatUpdate!['levelName'])
            const ex = Number(this.levelStatUpdate!['exit'])
            AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE, null)
            // 使用异步延迟，避免在渲染过程中同步更新导致循环
            Promise.resolve().then(() => {
              console.log(`🎯 检测到等级统计更新事件:`, { levelName: ln, exit: ex })
              this.applyLevelStatUpdate(ln, ex)
              this.tablesRefreshKey++
            })
          })
      }
      if (this.levelStatUpdateBatch && Array.isArray(this.levelStatUpdateBatch['levelNames']) && typeof this.levelStatUpdateBatch['exit'] !== 'undefined') {
        Blank()
          .key(`stat-batch-${JSON.stringify(this.levelStatUpdateBatch['levelNames'])}-${this.levelStatUpdateBatch['exit']}`) // 使用key避免重复触发
          .onAppear(() => {
            // 先清除AppStorage，避免重复触发
            const arrRaw = this.levelStatUpdateBatch!['levelNames']
            const arr: string[] = Array.isArray(arrRaw) ? (arrRaw as string[]) : []
            const ex = Number(this.levelStatUpdateBatch!['exit'])
            AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE_BATCH, null)
            // 使用异步延迟，避免在渲染过程中同步更新导致循环
            Promise.resolve().then(() => {
              arr.forEach((ln) => {
                if (ln && ln.length > 0) {
                  this.applyLevelStatUpdate(ln, ex)
                }
              })
              this.tablesRefreshKey++
            })
          })
      }
      
      if (this.levelStatRemove && typeof this.levelStatRemove['levelName'] === 'string' && typeof this.levelStatRemove['exit'] !== 'undefined') {
        Blank()
          .key(`stat-remove-${this.levelStatRemove['levelName']}-${this.levelStatRemove['exit']}`) // 使用key避免重复触发
          .onAppear(() => {
            // 先清除AppStorage，避免重复触发
            const ln = String(this.levelStatRemove!['levelName'])
            const ex = Number(this.levelStatRemove!['exit'])
            AppStorage.set(StorageKeys.LEVEL_STAT_REMOVE, null)
            // 使用异步延迟，避免在渲染过程中同步更新导致循环
            Promise.resolve().then(() => {
              this.applyLevelStatRemove(ln, ex)
              this.tablesRefreshKey++
            })
          })
      }
      
        // 出口设置对话框 - 放在Stack的最上层
        OutletDialog({
          isVisible: this.showOutletDialog,
          currentOutletIndex: this.currentOutletIndex,
          levelTableData: this.getTableData('等级表'),
          onPrevious: () => {
            this.switchToPreviousOutlet()
          },
          onNext: () => {
            this.switchToNextOutlet()
          },
          onConfirm: () => {
            this.confirmOutletSetting()
          },
          onCancel: () => {
            this.cancelOutletSetting()
          }
        })
        
        // 卡片详情对话框 - 放在Stack的最上层，显示在整个页面中间
        if (this.showCardDialog && this.selectedCardIndex >= 0 && this.selectedCardData) {
          CardDetailDialog({
            isVisible: this.showCardDialog,
            cardNumber: this.selectedCardIndex + 1,
            cardData: this.selectedCardData,
            onConfirm: () => {
              this.closeCardDialog()
            },
            onCancel: () => {
              this.closeCardDialog()
            }
          })
        }
      // 拖拽预览浮层（跟随指针）
      if (this.dragOverlayActive) {
        // 半透明标签，显示被拖拽的单元格内容
        Text(this.dragOverlayText || '')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .backgroundColor('#FFFFFFB0')
          .borderRadius(8)
          .padding({ left: '0.37%', right: '0.37%', top: '0.28%', bottom: '0.28%' })
          .opacity(0.92)
          .position({ x: this.dragOverlayX - 20, y: this.dragOverlayY - 20 })
          .enabled(false)
          .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getCurrentTheme().backgroundColor)  // 主页背景颜色（卡片之外的区域）
    .focusable(true)
    .defaultFocus(true) // 让主页整体默认获得键盘焦点
    .onAppear(() => {
      // Stack 出现时触发设置区域刷新，确保布局正确计算
      Promise.resolve().then(() => {
        setTimeout(() => {
          this.settingsRenderKey++
          console.log('[HomeContent] Stack已显示，刷新设置区域')
        }, 100)
        setTimeout(() => {
          this.settingsRenderKey++
          console.log('[HomeContent] Stack已显示，再次刷新设置区域')
        }, 500)
      })
    })
    .onKeyEvent((event) => {
      // 主页监听左 Ctrl，写入全局多选状态
      if (event.keyCode === KeyCode.KEYCODE_CTRL_LEFT) {
        if (event.type === KeyType.Down) {
          AppStorage.setOrCreate('HOME_CTRL_PRESSED', true);

        } else if (event.type === KeyType.Up) {
          AppStorage.setOrCreate('HOME_CTRL_PRESSED', false);

        }
      }
      return false;
    })
    // 统一跟踪触摸坐标与拖拽激活状态
    .onTouch((event?: TouchEvent) => {
      if (!event) { return }
      const t = event.touches && event.touches.length > 0 ? event.touches[0] : undefined
      
      // 优化：减少 AppStorage 读取频率，使用缓存或延迟读取
      // 只在必要时读取 AppStorage，避免每次触摸都读取（长时间运行后可能累积性能问题）
      if (event.type === TouchType.Down || event.type === TouchType.Move) {
        // 使用异步延迟读取，避免阻塞触摸事件处理
        Promise.resolve().then(() => {
          const active = (AppStorage.get(CELL_DRAG_ACTIVE_KEY) as boolean) === true
          if (!active) {
            // 未处于拖拽激活，强制隐藏并清空浮层文本，避免残留
            if (this.dragOverlayActive || this.dragOverlayText) {
              this.dragOverlayActive = false
              this.dragOverlayText = ''
            }
          } else {
            // 激活时首次显示时同步当前拖拽文本
            if (!this.dragOverlayActive) {
              const d = getCurrentCellDragData()
              this.dragOverlayText = d ? String(d.value ?? '') : ''
            }
            this.dragOverlayActive = true
          }
        })
      }
      
      // 坐标跟踪（使用屏幕坐标，适配 Stack 顶层）
      if (t) {
        // 使用相对于当前 Stack 的本地坐标，避免屏幕坐标导致的偏移
        this.dragOverlayX = t.x
        this.dragOverlayY = t.y
      }
      // 抬手时若未被目标接收，也隐藏浮层
      if (event.type === TouchType.Up) {
        this.dragOverlayActive = false
        this.dragOverlayText = ''
      }
    })
  }

  aboutToAppear() {
    // 初始化previousFSM为当前FSM
    this.previousFSM = this.selectedFSM
    
    // 检查当前FSM是否已经初始化，如果没有则默认开启"设置1"
    const currentFSMSettings = this.selectedFSM === 'FSM1' ? this.fsm1Settings : this.fsm2Settings
    const isUninitialized = !currentFSMSettings.setting1 && !currentFSMSettings.setting2 && 
                           !currentFSMSettings.setting3 && !currentFSMSettings.setting4
    
    if (isUninitialized) {
      let defaultSettings: FSMSettings
      if (this.selectedFSM === 'FSM1') {
        // FSM1默认开启"设置1"
        defaultSettings = {
          setting1: true,
          setting2: false,
          setting3: false,
          setting4: false
        }
        this.fsm1Settings = defaultSettings
        console.log(`🎯 首次加载${this.selectedFSM}，默认开启设置1`)
      } else {
        // FSM2默认开启"设置3"
        defaultSettings = {
          setting1: false,
          setting2: false,
          setting3: true,
          setting4: false
        }
        this.fsm2Settings = defaultSettings
        console.log(`🎯 首次加载${this.selectedFSM}，默认开启设置3`)
      }
      // 应用默认设置
      this.setting1Enabled = defaultSettings.setting1
      this.setting2Enabled = defaultSettings.setting2
      this.setting3Enabled = defaultSettings.setting3
      this.setting4Enabled = defaultSettings.setting4
      // 同步到状态管理器
      this.stateManager.updateSetting1Enabled(defaultSettings.setting1)
      this.stateManager.updateSetting2Enabled(defaultSettings.setting2)
      this.stateManager.updateSetting3Enabled(defaultSettings.setting3)
      this.stateManager.updateSetting4Enabled(defaultSettings.setting4)
    }
    
    // 初始化用户与状态
    AppStorage.setOrCreate(TOP_USER_NAME, '管理员')
    AppStorage.setOrCreate(TOP_STATUS_TEXT, '')
    AppStorage.setOrCreate(TOP_ALERT_HIDE, false)
    
    // 初始化顶部状态栏数据键，使用默认值（不要重置为'--'，会覆盖真实数据）
    // 先尝试从TCP数据获取真实值，如果没有则使用默认值
    const allStatistics: StStatistics = this.realtimeDataManager.getAllStatistics()
    const allCalculated: RealtimeCalculatedData = this.realtimeDataManager.getAllCalculatedData()
    
    if (allStatistics.nTotalCount > 0 || allCalculated.realTimeOutput > 0) {
      // 有真实数据，使用真实数据初始化
      const newProduction = allCalculated.realTimeOutput.toFixed(2)
      const totalWeightTon = allStatistics.nWeightCount / 1000000.0
      const newSumWeightTon = totalWeightTon.toFixed(2)
      const newSumCounts = String(allStatistics.nTotalCount)
      const newAvgG = allCalculated.avgWeight.toFixed(2)
      
      AppStorage.setOrCreate(TOP_PRODUCTION_TON_H, newProduction)
      AppStorage.setOrCreate(TOP_SUM_WEIGHT_TON, newSumWeightTon)
      AppStorage.setOrCreate(TOP_SUM_COUNTS, newSumCounts)
      AppStorage.setOrCreate(TOP_AVG_G, newAvgG)
    } else {
      // 没有真实数据，使用默认值
      AppStorage.setOrCreate(TOP_PRODUCTION_TON_H, '0.00')
      AppStorage.setOrCreate(TOP_SUM_WEIGHT_TON, '0.00')
      AppStorage.setOrCreate(TOP_SUM_COUNTS, '0')
      AppStorage.setOrCreate(TOP_AVG_G, '0.00')
    }
    
    // 根据FSM状态更新顶部状态栏（仅在切换FSM时调用，不在初始化时调用，避免覆盖真实数据）
    // this.updateTopBarForFSM() // 注释掉，避免用硬编码数据覆盖真实数据
    AppStorage.setOrCreate('TOP_BAR_UPDATE_VERSION', 0)

    // 初始化主页状态（新增的@StorageLink变量）
    AppStorage.setOrCreate(HOME_SELECTED_FSM, this.selectedFSM)
    // 确保设置状态正确同步到 AppStorage（在初始化之后立即同步）
    AppStorage.setOrCreate(HOME_SETTING1_ENABLED, this.setting1Enabled)
    AppStorage.setOrCreate(HOME_SETTING2_ENABLED, this.setting2Enabled)
    AppStorage.setOrCreate(HOME_SETTING3_ENABLED, this.setting3Enabled)
    AppStorage.setOrCreate(HOME_SETTING4_ENABLED, this.setting4Enabled)
    AppStorage.setOrCreate(HOME_SELECTED_BUTTON, this.selectedButton)
    
    // 注册HomeDataManager到AppStorage，供其他组件使用
    AppStorage.setOrCreate('HOME_DATA_MANAGER', this.dataManager)
    // 注册HomeContent实例到AppStorage，供其他组件使用
    AppStorage.setOrCreate('HOME_CONTENT_REF', this)
    
    // 使用异步延迟确保首次渲染时布局正确计算
    Promise.resolve().then(() => {
      // 强制同步设置状态，确保首次渲染时能够正确显示
      AppStorage.set(HOME_SETTING1_ENABLED, this.setting1Enabled)
      AppStorage.set(HOME_SETTING2_ENABLED, this.setting2Enabled)
      AppStorage.set(HOME_SETTING3_ENABLED, this.setting3Enabled)
      AppStorage.set(HOME_SETTING4_ENABLED, this.setting4Enabled)
      // 延迟刷新设置区域布局，确保首次渲染时完整显示
      setTimeout(() => {
        this.settingsRenderKey++
        console.log('[HomeContent] aboutToAppear: 第一次刷新设置区域')
      }, 100)
      setTimeout(() => {
        this.settingsRenderKey++
        console.log('[HomeContent] aboutToAppear: 第二次刷新设置区域')
      }, 400)
      setTimeout(() => {
        this.settingsRenderKey++
        console.log('[HomeContent] aboutToAppear: 第三次刷新设置区域')
      }, 800)
    })

    // 初始化表格数据
    this.addDataToTables()

    // 设置开始时间为当前时间（仅首次进入时）
    const now = new Date()
    const hh = String(now.getHours()).padStart(2, '0')
    const mm = String(now.getMinutes()).padStart(2, '0')
    const ss = String(now.getSeconds()).padStart(2, '0')
    this.startTime = `${hh}:${mm}:${ss}`
    AppStorage.setOrCreate('START_TIME', this.startTime)
    AppStorage.setOrCreate('PROGRAM_NAME', this.programName)
    AppStorage.setOrCreate('SORT_SPEED', this.sortSpeed)
    AppStorage.setOrCreate('REALTIME_OUTPUT', this.realTimeOutput)
    AppStorage.setOrCreate('BATCH_COUNT', this.batchCount)
    AppStorage.setOrCreate('AVG_WEIGHT', this.avgWeight)
    AppStorage.setOrCreate('BATCH_WEIGHT', this.batchWeight)
    AppStorage.setOrCreate('EFFICIENCY', this.efficiency)
    AppStorage.setOrCreate('INTERVAL_SPEED', this.intervalSpeed)

    // 客户信息展示（顶部状态栏使用）
    // 若无有效网络图片链接，置空以显示默认占位图
    AppStorage.setOrCreate('CUSTOMER_LOGO_URL', '')
    AppStorage.setOrCreate('FARM_NAME', '一号农场')
    AppStorage.setOrCreate('FRUIT_TYPE', '赣南脐橙')

    // 启动时间更新定时器（每5秒更新一次，减少AppStorage更新频率，避免触发大量监听器）
    if (!this.timeUpdateTimerId) {
      if (LOG_TIME_ENABLED) { console.log('[时间更新] 启动定时器 (5s间隔)') }
      this.timeUpdateTimerId = setInterval(() => {
        // 异步更新，避免阻塞主线程
        Promise.resolve().then(() => {
          // 更新开始时间（显示当前时间）
          const now = new Date()
          const hh = String(now.getHours()).padStart(2, '0')
          const mm = String(now.getMinutes()).padStart(2, '0')
          const ss = String(now.getSeconds()).padStart(2, '0')
          const newTime = `${hh}:${mm}:${ss}`
          // 只在时间真正变化时才更新AppStorage（减少不必要的更新）
          if (this.startTime !== newTime) {
            this.startTime = newTime
            AppStorage.setOrCreate('START_TIME', this.startTime)
            if (LOG_TIME_ENABLED) { console.log('[时间更新] 当前时间:', this.startTime) }
          }
        }).catch(() => {
          // 静默处理错误
        })
      }, 5000) as number // 改为5秒更新一次，减少频率
    }

    // 初始化时更新一次UI（显示默认值或已有数据）
    this.updateFromTcpData()
    
    // 初始化版本号（作为备用检测机制）
    const subsysId: number = this.selectedFSM === 'FSM1' ? 0 : 1
    this.lastCheckVersion = this.realtimeDataManager.getUpdateVersion(subsysId)
    console.log(`[HomeContent] aboutToAppear - 初始化版本号: ${this.lastCheckVersion}, 子系统: ${subsysId}`)
    
    // 启动TCP数据更新检查定时器（每2秒检查一次，作为备用机制，主要依靠AppStorage通知）
    if (!this.tcpDataCheckTimerId) {
      console.log(`[HomeContent] 启动TCP数据检查定时器（2秒间隔，备用机制）`)
      this.tcpDataCheckTimerId = setInterval(() => {
        this.checkTcpDataUpdate()
      }, 2000) as number
    }
    
    // 以下代码已禁用，改用TCP真实数据
    // 启动模拟实时更新（每60秒刷新一次）
    /* if (!this.mockSortingInfoTimerId) {
      if (LOG_SORT_ENABLED) { console.log('[模拟分选信息] 启动定时器 (60s)') }
      this.mockSortingInfoTimerId = setInterval(() => {
        // 异步批量更新，避免阻塞主线程
        Promise.resolve().then(() => {
          // 速度（件/分钟）- 变化幅度减小
          const speed = Math.max(0, Math.round(70 + Math.random() * 20))
          this.sortSpeed = `${speed} 件/分钟`
          AppStorage.setOrCreate('SORT_SPEED', this.sortSpeed)

          // 实时产量（件/分钟）- 变化幅度减小
          const rto = Math.max(0, Math.round(60 + Math.random() * 20))
          this.realTimeOutput = `${rto} 件/分钟`
          AppStorage.setOrCreate('REALTIME_OUTPUT', this.realTimeOutput)

          // 本批个数（累加）- 变化幅度减小
          const currentCountNum = Number((this.batchCount || '0').toString().replace(/[^0-9]/g, ''))
          const nextCount = currentCountNum + Math.max(1, Math.round(Math.random() * 2))
          this.batchCount = `${nextCount} 件`
          AppStorage.setOrCreate('BATCH_COUNT', this.batchCount)

          // 平均重量（g）- 变化幅度减小
          const avg = (120 + Math.random() * 20) // g
          this.avgWeight = `${(avg / 1000).toFixed(2)} kg`
          AppStorage.setOrCreate('AVG_WEIGHT', this.avgWeight)

          // 本批重量（kg，按件数与均重估算）
          const avgKg = Number(((avg) / 1000).toFixed(2))
          const kg = nextCount * avgKg
          this.batchWeight = `${kg.toFixed(2)} kg`
          AppStorage.setOrCreate('BATCH_WEIGHT', this.batchWeight)

          // 效率（%）- 变化幅度减小
          const eff = 85 + Math.random() * 10
          this.efficiency = `${eff.toFixed(0)}%`
          AppStorage.setOrCreate('EFFICIENCY', this.efficiency)

          // 间隔速度（ms）- 变化幅度减小
          const intervalMs = 800 + Math.random() * 400
          this.intervalSpeed = `${Math.round(intervalMs)} ms`
          AppStorage.setOrCreate('INTERVAL_SPEED', this.intervalSpeed)
          // 调试日志（可关闭）
          if (LOG_SORT_ENABLED) {
            console.log('[模拟分选信息] 速度=', this.sortSpeed,
              ' 重量=', this.batchWeight,
              ' 个数=', this.batchCount,
              ' 均重=', this.avgWeight,
              ' 产量=', this.realTimeOutput,
              ' 效率=', this.efficiency,
              ' 间隔=', this.intervalSpeed)
          }
        }).catch(() => {
          // 静默处理错误，避免影响定时器
        })
      }, 60000) as number
      // 立即刷新一次，避免首秒空窗
      {
        const speed = Math.max(0, Math.round(50 + Math.random() * 60))
        this.sortSpeed = `${speed} 件/分钟`
        AppStorage.setOrCreate('SORT_SPEED', this.sortSpeed)
        const rto = Math.max(0, Math.round(40 + Math.random() * 50))
        this.realTimeOutput = `${rto} 件/分钟`
        AppStorage.setOrCreate('REALTIME_OUTPUT', this.realTimeOutput)
        const currentCountNum = Number((this.batchCount || '0').toString().replace(/[^0-9]/g, ''))
        const nextCount = currentCountNum + Math.max(1, Math.round(Math.random() * 5))
        this.batchCount = `${nextCount} 件`
        AppStorage.setOrCreate('BATCH_COUNT', this.batchCount)
        const avg = (100 + Math.random() * 50)
        this.avgWeight = `${(avg / 1000).toFixed(2)} kg`
        AppStorage.setOrCreate('AVG_WEIGHT', this.avgWeight)
        const avgKg = Number(((avg) / 1000).toFixed(2))
        const kg = nextCount * avgKg
        this.batchWeight = `${kg.toFixed(2)} kg`
        AppStorage.setOrCreate('BATCH_WEIGHT', this.batchWeight)
        const eff = 80 + Math.random() * 18
        this.efficiency = `${eff.toFixed(0)}%`
        AppStorage.setOrCreate('EFFICIENCY', this.efficiency)
        const intervalMs = 500 + Math.random() * 1200
        this.intervalSpeed = `${Math.round(intervalMs)} ms`
        AppStorage.setOrCreate('INTERVAL_SPEED', this.intervalSpeed)
        if (LOG_SORT_ENABLED) {
          console.log('[模拟分选信息][首刷] 速度=', this.sortSpeed,
            ' 重量=', this.batchWeight,
            ' 个数=', this.batchCount,
            ' 均重=', this.avgWeight,
            ' 产量=', this.realTimeOutput,
            ' 效率=', this.efficiency,
            ' 间隔=', this.intervalSpeed)
        }
      }
    } */
  }

  aboutToDisappear() {
    // 清理定时器，避免页面离开后继续触发导致内存泄漏
    if (this.timeUpdateTimerId) {
      clearInterval(this.timeUpdateTimerId)
      this.timeUpdateTimerId = undefined
    }
    if (this.mockSortingInfoTimerId) {
      clearInterval(this.mockSortingInfoTimerId)
      this.mockSortingInfoTimerId = undefined
    }
    // 释放通过AppStorage保存的页面实例引用，避免阻止GC
    AppStorage.setOrCreate('HOME_CONTENT_REF', null)
  }

  // 根据FSM状态更新顶部状态栏
  private updateTopBarForFSM(): void {
    let productionTonH: string, sumWeightTon: string, sumCounts: string, avgG: string
    
    if (this.selectedFSM === 'FSM1') {
      // FSM1的顶部状态栏数据（去掉单位）
      productionTonH = '2.5'
      sumWeightTon = '1250.5'
      sumCounts = '156'
      avgG = '8.0'
    } else {
      // FSM2的顶部状态栏数据（去掉单位）
      productionTonH = '3.8'
      sumWeightTon = '1580.3'
      sumCounts = '189'
      avgG = '8.4'
    }
    
    this.updateTopBar(productionTonH, sumWeightTon, sumCounts, avgG)
  }

  // 示例：当你更新本地状态时，同步写回全局，顶部栏会自动刷新
  private updateTopBar(productionTonH: string, sumWeightTon: string, sumCounts: string, avgG: string) {
    this.topProduction = productionTonH
    this.topSumWeightTon = sumWeightTon
    this.topSumCounts = sumCounts
    this.topAvgG = avgG
    this.stateManager.updateTopProduction(productionTonH)
    this.stateManager.updateTopSumWeightTon(sumWeightTon)
    this.stateManager.updateTopSumCounts(sumCounts)
    this.stateManager.updateTopAvgG(avgG)

    AppStorage.set(TOP_PRODUCTION_TON_H, productionTonH)
    AppStorage.set(TOP_SUM_WEIGHT_TON, sumWeightTon)
    AppStorage.set(TOP_SUM_COUNTS, sumCounts)
    AppStorage.set(TOP_AVG_G, avgG)
  }
}

