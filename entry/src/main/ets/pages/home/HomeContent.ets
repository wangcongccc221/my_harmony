 /**
 * 主页内容组件
 * 功能：显示主页相关的内容和功能
 * 用途：在Home页面中作为主页内容显示
 */

import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { IBestSwitch } from '@ibestservices/ibest-ui'
import { SwitchControl } from '../../components/ui/SwitchControl'
import { TableRow } from '../../components/layout/LevelTable'
import { DataTablesTabBar } from './DataTablesTabBar'
import { DragData } from '../../components/layout/DraggableGridTable'
import { TOP_PRODUCTION_TON_H, TOP_SUM_WEIGHT_TON, TOP_SUM_COUNTS, TOP_AVG_G, TOP_USER_NAME, TOP_STATUS_TEXT, TOP_ALERT_HIDE, HOME_SELECTED_FSM, HOME_SETTING1_ENABLED, HOME_SETTING2_ENABLED, HOME_SETTING3_ENABLED, HOME_SETTING4_ENABLED, HOME_SELECTED_BUTTON } from '../../constants/TopBarKeys'
// 导入新的组件
import { SortingInfoCard } from './SortingInfoCard'
import { LiquidCardsArea } from './LiquidCardsArea'
import { StorageKeys } from '../../utils/constants/StorageKeys'
import { getCurrentCellDragData, CELL_DRAG_ACTIVE_KEY } from '../../components/ui/SimpleDraggableCell'
import { OutletDialog } from './OutletDialog'
import { HomeDataManager } from './core/HomeDataManager'
import { HomeEventHandler } from './core/HomeEventHandler'
import { HomeStateManager } from './core/HomeStateManager'
import { HomeState, DEFAULT_HOME_STATE } from './core/HomeState'
import { DEFAULT_TOP_BAR_DATA, DEFAULT_SORTING_INFO, DEFAULT_SETTINGS, DEFAULT_SELECTED_BUTTON, DEFAULT_SELECTED_FSM } from './HomeConstants'

// 确保全局AppStorage键在组件构建前已存在（供 SortingInfoCard @StorageLink 使用）
// 模块加载时即初始化，避免首帧为空导致不联动
(() => {
  try {
    AppStorage.setOrCreate('START_TIME', '--:--:--')
    AppStorage.setOrCreate('PROGRAM_NAME', '未选择')
    AppStorage.setOrCreate('SORT_SPEED', '0 件/分钟')
    AppStorage.setOrCreate('REALTIME_OUTPUT', '0 件/分钟')
    AppStorage.setOrCreate('BATCH_COUNT', '0 件')
    AppStorage.setOrCreate('AVG_WEIGHT', '0.00 kg')
    AppStorage.setOrCreate('BATCH_WEIGHT', '0.00 kg')
    AppStorage.setOrCreate('EFFICIENCY', '0%')
    AppStorage.setOrCreate('INTERVAL_SPEED', '0 ms')
  } catch (e) {
    console.error('初始化全局分选信息键失败:', e)
  }
})()

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
  private dataManager = new HomeDataManager()
  // 事件处理器
  private eventHandler = new HomeEventHandler()
  // 状态管理器
  private stateManager = new HomeStateManager()
  // 状态管理（移除未使用的 HomeState 实例，改由 DEFAULT_HOME_STATE 作初始化来源）

  // ==================== 状态变量（用于UI绑定） ====================
  // 这些 @State 变量与状态管理器同步，确保UI能正确响应状态变化
  
  @StorageLink(HOME_SELECTED_FSM) private selectedFSM: 'FSM1' | 'FSM2' = DEFAULT_HOME_STATE.selectedFSM
  @StorageLink(HOME_SETTING1_ENABLED) private setting1Enabled: boolean = DEFAULT_HOME_STATE.setting1Enabled
  @StorageLink(HOME_SETTING2_ENABLED) private setting2Enabled: boolean = DEFAULT_HOME_STATE.setting2Enabled
  @StorageLink(HOME_SETTING3_ENABLED) private setting3Enabled: boolean = DEFAULT_HOME_STATE.setting3Enabled
  @StorageLink(HOME_SETTING4_ENABLED) private setting4Enabled: boolean = DEFAULT_HOME_STATE.setting4Enabled
  @StorageLink(HOME_SELECTED_BUTTON) private selectedButton: string = DEFAULT_HOME_STATE.selectedButton
  @State private showOutletDialog: boolean = DEFAULT_HOME_STATE.showOutletDialog
  @State private currentOutletIndex: number = DEFAULT_HOME_STATE.currentOutletIndex
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
  // 模拟实时数据定时器
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
    return this.dataManager.getTableData(tableName)
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

  // 切换FSM状态
  private switchFSM(fsm: 'FSM1' | 'FSM2'): void {
    this.selectedFSM = fsm
    this.stateManager.updateSelectedFSM(fsm)
    this.eventHandler.switchFSM(fsm)
    
    // 更新数据管理器的FSM状态
    this.dataManager.setFSM(fsm)
    
    // 更新顶部状态栏
    this.updateTopBarForFSM()
    
    console.log(`主页切换到${fsm}，数据已更新`)
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

  // 切换设置开关（互斥模式 - 同一时间只能有一个开启）
  private toggleSetting(setting: '设置1' | '设置2' | '设置3' | '设置4'): void {
    // 如果当前开关是开启状态，则关闭它
    if (this.settingMap[setting]()) {
      this.settingUpdateMap[setting](false)
    } else {
      // 如果当前开关是关闭状态，则先关闭所有开关，再开启当前开关
      this.setting1Enabled = false
      this.setting2Enabled = false
      this.setting3Enabled = false
      this.setting4Enabled = false
      this.stateManager.updateSetting1Enabled(false)
      this.stateManager.updateSetting2Enabled(false)
      this.stateManager.updateSetting3Enabled(false)
      this.stateManager.updateSetting4Enabled(false)

      // 开启当前选中的开关
      this.settingUpdateMap[setting](true)
    }

    // 调用事件处理器
    this.eventHandler.toggleSetting(setting)
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
    console.log(`🔄 开始处理等级统计更新: 等级=${levelName}, 出口=${exitNum}`)
    const tableName = '等级统计表'
    const rows: TableRow[] = this.dataManager.getTableData(tableName)
    console.log(`📊 当前等级统计表数据:`, rows)
    const idx: number = rows.findIndex((r: TableRow) => String(r && r[0]) === levelName)
    console.log(`🔍 查找等级行索引: ${idx}`)
    if (idx < 0) {
      console.warn(`❌ 未在${tableName}中找到等级行:`, levelName)
      return
    }
    const updatedRow: TableRow = [...rows[idx]]
    console.log(`📝 原始行数据:`, updatedRow)
    const exitColIndex = 2 // 等级出口
    const currentVal: string = String(updatedRow[exitColIndex] || '').trim()
    console.log(`📋 当前出口值: "${currentVal}"`)
    const entry = `出口${exitNum}`
    let nextVal: string
    if (!currentVal) {
      nextVal = entry
    } else if (currentVal.indexOf(entry) >= 0) {
      nextVal = currentVal
    } else {
      nextVal = `${currentVal}、${entry}`
    }
    console.log(`🆕 新出口值: "${nextVal}"`)
    updatedRow[exitColIndex] = nextVal

    const newRows: TableRow[] = [...rows]
    newRows[idx] = updatedRow
    console.log(`💾 更新后的完整数据:`, newRows)
    this.dataManager.clearTableData(tableName)
    this.dataManager.addTableData(tableName, newRows)
    this.statsVersion++
    console.log(`✅ 等级统计已更新: 等级=${levelName}, 新出口列=${nextVal}`)
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
    this.dataManager.clearTableData(tableName)
    this.dataManager.addTableData(tableName, newRows)
    this.statsVersion++
    console.log(`🗑️ 等级统计已移除: 等级=${levelName}, 移除出口=${exitNum}, 新出口列=${nextVal}`)
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



  // 将原来的build方法内容提取为单独的方法
  @Builder
  private buildMainContent() {
    Column() {
      // 设置开关区域（FSM切换已移至顶部状态栏）
      Row() {
        SwitchControl({ 
          label: '设置1', 
          isEnabled: $setting1Enabled, 
          isLastEnabled: this.isLastEnabledSetting(0),
          onToggle: () => { this.toggleSetting('设置1') } 
        })
        SwitchControl({ 
          label: '设置2', 
          isEnabled: $setting2Enabled, 
          isLastEnabled: this.isLastEnabledSetting(1),
          onToggle: () => { this.toggleSetting('设置2') } 
        })
        SwitchControl({ 
          label: '设置3', 
          isEnabled: $setting3Enabled, 
          isLastEnabled: this.isLastEnabledSetting(2),
          onToggle: () => { this.toggleSetting('设置3') } 
        })
        SwitchControl({ 
          label: '设置4', 
          isEnabled: $setting4Enabled, 
          isLastEnabled: this.isLastEnabledSetting(3),
          onToggle: () => { this.toggleSetting('设置4') } 
        })
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .padding({ top: 0, left: 0, right: 20, bottom: '1%' })
      // 主页信息卡片：分选速度 | 本批重量 | 本批个数 | 开始时间 | 分选程序 | 分选效率 | 平均重量 | 实时产量 | 间隔速度
      SortingInfoCard()
      .margin({ bottom: '1%' })

      // 液体卡片区域：单容器自动换行，固定显示两排高度，支持纵向滚动查看更多
      LiquidCardsArea()
      .margin({ bottom: '0.5%' })

      // 数据表格TabBar组件 - 替换原有的FunctionButtons和DataTablesCard
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
      .width('100%')
      .height('50%') // 表格区域占50%
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
      // 侦听等级统计更新事件（UI语法包裹，逻辑在回调内）
      if (this.levelStatUpdate && typeof this.levelStatUpdate['levelName'] === 'string' && typeof this.levelStatUpdate['exit'] !== 'undefined') {
        Blank()
          .onAppear(() => {
            console.log(`🎯 检测到等级统计更新事件:`, this.levelStatUpdate)
            const ln = String(this.levelStatUpdate!['levelName'])
            const ex = Number(this.levelStatUpdate!['exit'])
            console.log(`🎯 解析事件参数: 等级=${ln}, 出口=${ex}`)
            AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE, null)
            this.applyLevelStatUpdate(ln, ex)
            this.tablesRefreshKey++
          })
      }
      if (this.levelStatUpdateBatch && Array.isArray(this.levelStatUpdateBatch['levelNames']) && typeof this.levelStatUpdateBatch['exit'] !== 'undefined') {
        Blank()
          .onAppear(() => {
            const arrRaw = this.levelStatUpdateBatch!['levelNames']
            const arr: string[] = Array.isArray(arrRaw) ? (arrRaw as string[]) : []
            const ex = Number(this.levelStatUpdateBatch!['exit'])
            AppStorage.set(StorageKeys.LEVEL_STAT_UPDATE_BATCH, null)
            arr.forEach((ln) => {
              if (ln && ln.length > 0) {
                this.applyLevelStatUpdate(ln, ex)
              }
            })
            this.tablesRefreshKey++
          })
      }
      
      if (this.levelStatRemove && typeof this.levelStatRemove['levelName'] === 'string' && typeof this.levelStatRemove['exit'] !== 'undefined') {
        Blank()
          .onAppear(() => {
            const ln = String(this.levelStatRemove!['levelName'])
            const ex = Number(this.levelStatRemove!['exit'])
            AppStorage.set(StorageKeys.LEVEL_STAT_REMOVE, null)
            this.applyLevelStatRemove(ln, ex)
            this.tablesRefreshKey++
          })
      }
      
        // 出口设置对话框 - 放在Stack的最上层
        OutletDialog({
          isVisible: this.showOutletDialog,
          currentOutletIndex: this.currentOutletIndex,
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
      // 拖拽预览浮层（跟随指针）
      if (this.dragOverlayActive) {
        // 半透明标签，显示被拖拽的单元格内容
        Text(this.dragOverlayText || '')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .backgroundColor('#FFFFFFB0')
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .opacity(0.92)
          .position({ x: this.dragOverlayX - 20, y: this.dragOverlayY - 20 })
          .enabled(false)
          .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
    // 统一跟踪触摸坐标与拖拽激活状态
    .onTouch((event?: TouchEvent) => {
      if (!event) { return }
      const t = event.touches && event.touches.length > 0 ? event.touches[0] : undefined
      // 同步拖拽激活状态
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
    // 根据FSM状态初始化顶部状态栏四项指标
    this.updateTopBarForFSM()
    // 初始化用户与状态
    AppStorage.setOrCreate(TOP_USER_NAME, '管理员')
    AppStorage.setOrCreate(TOP_STATUS_TEXT, '')
    AppStorage.setOrCreate(TOP_ALERT_HIDE, false)

    // 初始化主页状态（新增的@StorageLink变量）
    AppStorage.setOrCreate(HOME_SELECTED_FSM, this.selectedFSM)
    AppStorage.setOrCreate(HOME_SETTING1_ENABLED, this.setting1Enabled)
    AppStorage.setOrCreate(HOME_SETTING2_ENABLED, this.setting2Enabled)
    AppStorage.setOrCreate(HOME_SETTING3_ENABLED, this.setting3Enabled)
    AppStorage.setOrCreate(HOME_SETTING4_ENABLED, this.setting4Enabled)
    AppStorage.setOrCreate(HOME_SELECTED_BUTTON, this.selectedButton)

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

    // 启动时间更新定时器（每秒更新一次）
    if (!this.timeUpdateTimerId) {
      console.log('[时间更新] 启动定时器')
      this.timeUpdateTimerId = setInterval(() => {
        // 更新开始时间（显示当前时间）
        const now = new Date()
        const hh = String(now.getHours()).padStart(2, '0')
        const mm = String(now.getMinutes()).padStart(2, '0')
        const ss = String(now.getSeconds()).padStart(2, '0')
        this.startTime = `${hh}:${mm}:${ss}`
        AppStorage.setOrCreate('START_TIME', this.startTime)
        console.log('[时间更新] 当前时间:', this.startTime)
      }, 1000) as number
    }

    // 启动模拟实时更新（每3秒刷新一次）
    if (!this.mockSortingInfoTimerId) {
      console.log('[模拟分选信息] 启动定时器')
      this.mockSortingInfoTimerId = setInterval(() => {
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
        // 调试日志：观察9项是否在变化
        console.log('[模拟分选信息] 速度=', this.sortSpeed,
          ' 重量=', this.batchWeight,
          ' 个数=', this.batchCount,
          ' 均重=', this.avgWeight,
          ' 产量=', this.realTimeOutput,
          ' 效率=', this.efficiency,
          ' 间隔=', this.intervalSpeed)
      }, 3000) as number
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
        console.log('[模拟分选信息][首刷] 速度=', this.sortSpeed,
          ' 重量=', this.batchWeight,
          ' 个数=', this.batchCount,
          ' 均重=', this.avgWeight,
          ' 产量=', this.realTimeOutput,
          ' 效率=', this.efficiency,
          ' 间隔=', this.intervalSpeed)
      }
    }
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
    console.log(`顶部状态栏已更新为${this.selectedFSM}数据`)
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

