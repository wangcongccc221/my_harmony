/**
 * 统计数据处理器
 * 负责处理从下位机接收到的统计数据
 * 对应48项目的数据处理逻辑
 */

import { ProtocolParser, ParsedMessage, getProtocolParser } from './ProtocolParser'
import { GlobalDataInterface, getGlobalDataInterface } from './GlobalDataInterface'
import { FSM_HC_COMMAND_TYPE, getCommandName } from './CommandTypes'
import { MESSAGE_HEADER_SIZE, StStatistics, StWeightInfo, StGradeInfo, StFruitGradeInfo, StFsmStatus, StSysConfig, createDefaultStatistics, createDefaultWeightInfo } from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ConstPreDefine } from './ConstPreDefine'

const TAG = 'StatisticsHandler'

/**
 * 统计数据处理器类
 * 处理二进制协议数据并更新全局状态
 */
export class StatisticsHandler {
  private static instance: StatisticsHandler | null = null

  private parser: ProtocolParser
  private dataInterface: GlobalDataInterface

  /**
   * 获取单例实例
   */
  static getInstance(): StatisticsHandler {
    if (!StatisticsHandler.instance) {
      StatisticsHandler.instance = new StatisticsHandler()
    }
    return StatisticsHandler.instance
  }

  private constructor() {
    this.parser = getProtocolParser()
    this.dataInterface = getGlobalDataInterface()
    hilog.info(0x0001, TAG, '统计数据处理器初始化')
  }

  /**
   * 处理原始二进制数据
   * @param buffer 接收到的原始数据
   * @returns 是否处理成功
   */
  handleRawData(buffer: ArrayBuffer): boolean {
    try {
      // 首先检查是否为二进制协议
      if (!this.parser.isBinaryProtocol(buffer)) {
        hilog.debug(0x0001, TAG, '非二进制协议数据，跳过处理')
        return false
      }

      // 解析消息
      const parsed = this.parser.parseMessage(buffer)
      if (!parsed) {
        hilog.warn(0x0001, TAG, '消息解析失败')
        return false
      }

      // 根据命令类型处理
      return this.handleParsedMessage(parsed)

    } catch (e) {
      hilog.error(0x0001, TAG, `处理原始数据失败: ${e}`)
      return false
    }
  }

  /**
   * 处理已经拆分的消息（Head + Data）
   * 适用于 NAPI 回调直接返回了解析后的头部和数据体
   * @param cmdId 命令ID
   * @param srcId 源ID
   * @param data 数据体
   */
  handleSplitMessage(cmdId: number, srcId: number, data: Uint8Array): boolean {
    try {
      // 构造一个临时的 ParsedMessage
      const parsed: ParsedMessage = {
        header: {
          length: data.byteLength + MESSAGE_HEADER_SIZE, // 估算总长，虽然不重要
          srcId: srcId,
          destId: ConstPreDefine.HC_ID, // 假定发给我
          cmdId: cmdId
        },
        cmdName: getCommandName(cmdId),
        data: null
      }

      // 根据命令类型解析数据体
      // 注意：这里的 parseXxx 方法原本期望包含 Header 的 Buffer
      // 我们需要重构解析方法，或者在这里做适配
      // 鉴于 parseXxx 内部都是从 MESSAGE_HEADER_SIZE 开始读
      // 我们可以构造一个伪造的完整 Buffer
      
      const fullBuffer = new ArrayBuffer(MESSAGE_HEADER_SIZE + data.byteLength)
      const view = new DataView(fullBuffer)
      const dataView = new DataView(data.buffer, data.byteOffset, data.byteLength)
      
      // 填充Header
      view.setUint32(0, fullBuffer.byteLength, true)
      view.setUint16(4, srcId, true)
      view.setUint16(6, ConstPreDefine.HC_ID, true)
      view.setUint16(8, cmdId, true)
      
      // 填充Body
      const bodyArray = new Uint8Array(fullBuffer, MESSAGE_HEADER_SIZE)
      bodyArray.set(data)
      
      // 现在可以调用 parseMessage 了
      // 但为了性能，最好是重构 parser 支持 offset，或者直接在这里 switch
      // 为了最小化改动，我们复用 handleRawData 的逻辑
      
      return this.handleRawData(fullBuffer)
      
    } catch (e) {
      hilog.error(0x0001, TAG, `处理拆分消息失败: ${e}`)
      return false
    }
  }

  /**
   * 处理解析后的消息
   */
  private handleParsedMessage(parsed: ParsedMessage): boolean {
    const cmdId = parsed.header.cmdId

    switch (cmdId) {
      case FSM_HC_COMMAND_TYPE.FSM_CMD_STATISTICS:
        return this.handleStatistics(parsed)

      case FSM_HC_COMMAND_TYPE.FSM_CMD_WEIGHTINFO:
        return this.handleWeightInfo(parsed)

      case FSM_HC_COMMAND_TYPE.FSM_CMD_GRADEINFO:
        return this.handleGradeInfo(parsed)

      case FSM_HC_COMMAND_TYPE.FSM_CMD_CONFIG:
        return this.handleConfig(parsed)

      case FSM_HC_COMMAND_TYPE.FSM_CMD_GETVERSION:
        return this.handleVersion(parsed)

      default:
        hilog.info(0x0001, TAG, `收到未处理的命令: ${parsed.cmdName}`)
        return true
    }
  }

  /**
   * 处理统计数据 (FSM_CMD_STATISTICS)
   * 这是核心功能：产量、总重等
   */
  private handleStatistics(parsed: ParsedMessage): boolean {
    const stats = parsed.data as StStatistics
    if (!stats) {
      hilog.warn(0x0001, TAG, '统计数据解析失败')
      return false
    }

    // 更新全局数据接口
    this.dataInterface.updateStatistics(stats)

    // 更新设备状态（表明设备在线）
    const deviceId = parsed.header.srcId
    this.updateDeviceOnlineStatus(deviceId, stats.nSubsysId)

    hilog.info(0x0001, TAG,
      `[统计] 子系统${stats.nSubsysId} 通道${stats.nChannelIndex}: ` +
      `产量=${stats.nYield}个, 总重=${stats.nTotalWeight}g, ` +
      `合格=${stats.nQualifiedCount}, 不合格=${stats.nUnqualifiedCount}`)

    return true
  }

  /**
   * 处理重量信息 (FSM_CMD_WEIGHTINFO)
   */
  private handleWeightInfo(parsed: ParsedMessage): boolean {
    const info = parsed.data as StWeightInfo
    if (!info) {
      hilog.warn(0x0001, TAG, '重量信息解析失败')
      return false
    }

    // 更新全局数据接口
    this.dataInterface.updateWeightInfo(info)

    hilog.debug(0x0001, TAG,
      `[重量] 通道${info.channelIndex}: 重量=${info.weight}g, ` +
      `直径=${info.diameter}mm, 等级=${info.finalGrade}, 出口=${info.targetExit}`)

    return true
  }

  /**
   * 处理分级信息 (FSM_CMD_GRADEINFO)
   */
  private handleGradeInfo(parsed: ParsedMessage): boolean {
    const data = parsed.data
    if (!data) {
      hilog.warn(0x0001, TAG, '分级信息解析失败')
      return false
    }

    if (data instanceof StFruitGradeInfo) {
      this.dataInterface.updateFruitGradeInfo(parsed.header.srcId, data)
      return true
    }

    const info = data as StGradeInfo
    this.dataInterface.updateGradeInfo(info)

    hilog.debug(0x0001, TAG,
      `[分级] ID=${info.fruitId}: 重量=${info.weight}g, ` +
      `颜色等级=${info.colorGrade}, 品质=${info.qualityGrade}, 出口=${info.targetExit}`)

    return true
  }

  /**
   * 处理配置回复 (FSM_CMD_CONFIG)
   */
  private handleConfig(parsed: ParsedMessage): boolean {
    hilog.info(0x0001, TAG, `收到配置回复: 来自 0x${parsed.header.srcId.toString(16)}`)
    const sys = parsed.data
    if (sys instanceof StSysConfig) {
      this.dataInterface.updateSysConfig(sys)
    }
    return true
  }

  /**
   * 处理版本信息 (FSM_CMD_GETVERSION)
   */
  private handleVersion(parsed: ParsedMessage): boolean {
    const version = parsed.data as string
    if (version) {
      hilog.info(0x0001, TAG, `设备版本: ${version}`)

      // 更新设备版本信息
      const deviceId = parsed.header.srcId
      const existingStatus = this.dataInterface.getDeviceStatus(deviceId)
      if (existingStatus) {
        existingStatus.version = version
        this.dataInterface.updateDeviceStatus(deviceId, existingStatus)
      }
    }
    return true
  }

  /**
   * 更新设备在线状态
   */
  private updateDeviceOnlineStatus(deviceId: number, subsysIndex: number): void {
    const existingStatus = this.dataInterface.getDeviceStatus(deviceId)

    let status: StFsmStatus;
    if (existingStatus) {
      status = existingStatus;
    } else {
      status = new StFsmStatus();
      status.deviceId = deviceId;
      status.ipAddress = `192.168.0.${(subsysIndex + 1) * 16}`;
      status.version = '';
      status.connectTime = Date.now();
      status.subsysIndex = subsysIndex;
    }

    status.online = true
    status.lastHeartbeat = Date.now()

    this.dataInterface.updateDeviceStatus(deviceId, status)
  }

  // ==================== JSON协议兼容 ====================
  /**
   * 处理JSON格式的统计数据
   * 用于兼容简化的测试协议
   */
  handleJsonStatistics(json: string): boolean {
    try {
      const data = JSON.parse(json) as JsonStatisticsData

      if (data.type === 'statistics' || data.cmd === 'statistics') {
        const stats = createDefaultStatistics();
        stats.nYield = data.yield || 0;
        stats.nTotalWeight = data.totalWeight || 0;
        stats.nQualifiedCount = data.qualified || 0;
        stats.nUnqualifiedCount = data.unqualified || 0;
        stats.nBigCount = data.big || 0;
        stats.nSmallCount = data.small || 0;
        stats.nEmptyCount = data.empty || 0;
        if (data.gradeCount) stats.nGradeCount.set(data.gradeCount);
        if (data.exitCount) stats.nExitCount.set(data.exitCount);
        if (data.exitWeight) stats.nExitWeightCount.set(data.exitWeight);
        stats.nChannelIndex = data.channel || 0;
        stats.nSubsysId = data.subsys || 0;
        stats.nTimestamp = Date.now();

        this.dataInterface.updateStatistics(stats)
        hilog.info(0x0001, TAG, `[JSON统计] 产量=${stats.nYield}, 总重=${stats.nTotalWeight}g`)
        return true
      }

      if (data.type === 'weight' || data.cmd === 'weight') {
        const info = createDefaultWeightInfo();
        info.weight = data.weight || 0;
        info.diameter = data.diameter || 0;
        info.volume = data.volume || 0;
        info.area = data.area || 0;
        info.weightGrade = data.weightGrade || 0;
        info.sizeGrade = data.sizeGrade || 0;
        info.qualityGrade = data.qualityGrade || 0;
        info.finalGrade = data.grade || 0;
        info.targetExit = data.exit || 0;
        info.fruitId = data.fruitId || 0;
        info.channelIndex = data.channel || 0;
        info.cupIndex = data.cup || 0;
        info.timestamp = Date.now();

        this.dataInterface.updateWeightInfo(info)
        return true
      }

      return false
    } catch (e) {
      hilog.debug(0x0001, TAG, `非JSON格式数据: ${e}`)
      return false
    }
  }
}

/**
 * JSON格式统计数据接口（用于测试和兼容）
 */
interface JsonStatisticsData {
  type?: string
  cmd?: string
  yield?: number
  totalWeight?: number
  qualified?: number
  unqualified?: number
  big?: number
  small?: number
  empty?: number
  gradeCount?: number[]
  exitCount?: number[]
  exitWeight?: number[]
  channel?: number
  subsys?: number
  weight?: number
  diameter?: number
  volume?: number
  area?: number
  weightGrade?: number
  sizeGrade?: number
  qualityGrade?: number
  grade?: number
  exit?: number
  fruitId?: number
  cup?: number
}

// 导出单例获取方法
export function getStatisticsHandler(): StatisticsHandler {
  return StatisticsHandler.getInstance()
}
