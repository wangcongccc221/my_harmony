/**
 * 统计数据处理器
 * 负责处理从下位机接收到的统计数据
 * 对应48项目的数据处理逻辑
 */

import { ProtocolParser, ParsedMessage, getProtocolParser } from './ProtocolParser'
import { GlobalDataInterface, getGlobalDataInterface } from './GlobalDataInterface'
import { FSM_HC_COMMAND_TYPE } from './CommandTypes'
import { MESSAGE_HEADER_SIZE, StStatistics, StWeightInfo, StGradeInfo, StFsmStatus } from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'

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
    this.updateDeviceOnlineStatus(deviceId, stats.subsysIndex)

    hilog.info(0x0001, TAG,
      `[统计] 子系统${stats.subsysIndex} 通道${stats.channelIndex}: ` +
      `产量=${stats.yield}个, 总重=${stats.totalWeight}g, ` +
      `合格=${stats.qualifiedCount}, 不合格=${stats.unqualifiedCount}`)

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
    const info = parsed.data as StGradeInfo
    if (!info) {
      hilog.warn(0x0001, TAG, '分级信息解析失败')
      return false
    }

    // 更新全局数据接口
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

    const status: StFsmStatus = existingStatus || {
      deviceId: deviceId,
      ipAddress: `192.168.0.${(subsysIndex + 1) * 16}`,
      online: true,
      version: '',
      connectTime: Date.now(),
      lastHeartbeat: Date.now(),
      subsysIndex: subsysIndex
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
        const stats: StStatistics = {
          yield: data.yield || 0,
          totalWeight: data.totalWeight || 0,
          qualifiedCount: data.qualified || 0,
          unqualifiedCount: data.unqualified || 0,
          bigCount: data.big || 0,
          smallCount: data.small || 0,
          emptyCount: data.empty || 0,
          gradeCount: data.gradeCount || [],
          exitCount: data.exitCount || [],
          exitWeight: data.exitWeight || [],
          channelIndex: data.channel || 0,
          subsysIndex: data.subsys || 0,
          timestamp: Date.now()
        }

        this.dataInterface.updateStatistics(stats)
        hilog.info(0x0001, TAG, `[JSON统计] 产量=${stats.yield}, 总重=${stats.totalWeight}g`)
        return true
      }

      if (data.type === 'weight' || data.cmd === 'weight') {
        const info: StWeightInfo = {
          weight: data.weight || 0,
          diameter: data.diameter || 0,
          volume: data.volume || 0,
          area: data.area || 0,
          weightGrade: data.weightGrade || 0,
          sizeGrade: data.sizeGrade || 0,
          qualityGrade: data.qualityGrade || 0,
          finalGrade: data.grade || 0,
          targetExit: data.exit || 0,
          fruitId: data.fruitId || 0,
          channelIndex: data.channel || 0,
          cupIndex: data.cup || 0,
          timestamp: Date.now()
        }

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
