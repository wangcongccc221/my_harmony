/**
 * 协议解析器
 * 负责解析和构建TCP通信协议数据包
 * 对应48项目的二进制协议解析逻辑
 */

import { ConstPreDefine } from './ConstPreDefine'
import { FSM_HC_COMMAND_TYPE, HC_FSM_COMMAND_TYPE, WAM_HC_COMMAND_TYPE, SIM_HMI_COMMAND_TYPE, getCommandName } from './CommandTypes'
import {
  MessageHeader,
  MESSAGE_HEADER_SIZE,
  StStatistics,
  StWeightInfo,
  StWeightResult,
  StWaveInfo,
  StWeightGlobal,
  StGradeInfo,
  StFruitGradeInfo,
  StFruitParam,
  StSysConfig,
  StGlobal,
  createDefaultStatistics,
  createDefaultGradeInfo
} from './Structures'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { util } from '@kit.ArkTS'

const TAG = 'ProtocolParser'

/**
 * 协议解析器类
 * 支持二进制和JSON两种协议格式
 */
export class ProtocolParser {
  private static instance: ProtocolParser | null = null

  /**
   * 获取单例实例
   */
  static getInstance(): ProtocolParser {
    if (!ProtocolParser.instance) {
      ProtocolParser.instance = new ProtocolParser()
    }
    return ProtocolParser.instance
  }

  private constructor() {}

  // ==================== 消息头解析 ====================
  /**
   * 解析消息头
   * @param buffer 数据缓冲区
   * @returns 消息头结构，解析失败返回null
   */
  parseHeader(buffer: ArrayBuffer): MessageHeader | null {
    if (buffer.byteLength < MESSAGE_HEADER_SIZE) {
      hilog.warn(0x0001, TAG, `数据长度不足: ${buffer.byteLength} < ${MESSAGE_HEADER_SIZE}`)
      return null
    }

    const view = new DataView(buffer)

    try {
      const header: MessageHeader = {
        length: view.getUint32(0, true), // 小端序
        srcId: view.getUint16(4, true),
        destId: view.getUint16(6, true),
        cmdId: view.getUint16(8, true)
      }

      // 验证消息长度
      if (header.length > buffer.byteLength || header.length < MESSAGE_HEADER_SIZE) {
        hilog.warn(0x0001, TAG, `消息长度异常: header.length=${header.length}, buffer.length=${buffer.byteLength}`)
        return null
      }

      return header
    } catch (e) {
      hilog.error(0x0001, TAG, `解析消息头失败: ${e}`)
      return null
    }
  }

  /**
   * 构建消息头
   * @param srcId 源ID
   * @param destId 目标ID
   * @param cmdId 命令ID
   * @param dataLength 数据长度（不含头部）
   * @returns 消息头的ArrayBuffer
   */
  buildHeader(srcId: number, destId: number, cmdId: number, dataLength: number): ArrayBuffer {
    const buffer = new ArrayBuffer(MESSAGE_HEADER_SIZE)
    const view = new DataView(buffer)

    view.setUint32(0, MESSAGE_HEADER_SIZE + dataLength, true) // 总长度
    view.setUint16(4, srcId, true)
    view.setUint16(6, destId, true)
    view.setUint16(8, cmdId, true)

    return buffer
  }

  // ==================== 统计数据解析 ====================
  /**
   * 解析统计数据 (FSM_CMD_STATISTICS)
   * @param buffer 数据缓冲区（包含消息头）
   * @returns 统计数据结构
   */
  parseStatistics(buffer: ArrayBuffer): StStatistics | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null

    if (header.cmdId !== FSM_HC_COMMAND_TYPE.FSM_CMD_STATISTICS) {
      hilog.warn(0x0001, TAG, `命令ID不匹配: ${header.cmdId} != ${FSM_HC_COMMAND_TYPE.FSM_CMD_STATISTICS}`)
      return null
    }

    const view = new DataView(buffer)
    const offset: number = MESSAGE_HEADER_SIZE

    try {
      const stats = createDefaultStatistics()

      // 使用 Structure 自身定义的解析逻辑 (符合 C++ 内存布局)
      stats.readFromDataView(view, offset)

      // 从源ID解析通道和子系统信息 (补充覆盖)
      // 注意: nSubsysId 在二进制流中也有，这里可以校验或覆盖
      const headerSubsysId = ConstPreDefine.getSubsysIndex(header.srcId)
      if (stats.nSubsysId !== headerSubsysId) {
         // 以 Header 为准，或者保留 Packet 内部的
         // stats.nSubsysId = headerSubsysId; 
      }
      stats.nChannelIndex = (header.srcId >> 4) & 0x0F
      
      // 重新计算时间戳 (readFromDataView 中已赋值，这里可再次确认)
      stats.nTimestamp = Date.now()

      hilog.info(0x0001, TAG,
        `解析统计数据成功: 产量=${stats.nYield}, 总重=${stats.nTotalWeight}g, 合格=${stats.nQualifiedCount}`)

      return stats

      hilog.info(0x0001, TAG,
        `解析统计数据成功: 产量=${stats.nYield}, 总重=${stats.nTotalWeight}g, 合格=${stats.nQualifiedCount}`)

      return stats
    } catch (e) {
      hilog.error(0x0001, TAG, `解析统计数据失败: ${e}`)
      return null
    }
  }

  // ==================== 重量信息解析 ====================
  /**
   * 解析重量信息 (FSM_CMD_WEIGHTINFO)
   * @param buffer 数据缓冲区（包含消息头）
   * @returns 重量信息结构
   */
  parseWeightInfo(buffer: ArrayBuffer): StWeightInfo | StWeightResult | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null

    if (header.cmdId !== FSM_HC_COMMAND_TYPE.FSM_CMD_WEIGHTINFO &&
      header.cmdId !== WAM_HC_COMMAND_TYPE.WAM_CMD_WEIGHTINFO) {
      hilog.warn(0x0001, TAG, `命令ID不匹配: ${header.cmdId}`)
      return null
    }

    const view = new DataView(buffer)
    let offset: number = MESSAGE_HEADER_SIZE

    try {
      const result = new StWeightResult()
      offset = result.readFromDataView(view, offset)

      if (this.isDebugEnabled()) {
        console.log(`[PROTO_DEBUG] weightinfo size=${buffer.byteLength}, expected=${MESSAGE_HEADER_SIZE + StWeightResult.getSize()}, channel=${result.nChannelId}, fruitWeight=${result.data.fFruitWeight}, vehicleWeight=${result.data.fVehicleWeight}, state=${result.state}`)
      }

      return result
    } catch (e) {
      hilog.error(0x0001, TAG, `解析重量信息失败: ${e}`)
      return null
    }
  }

  parseWaveInfo(buffer: ArrayBuffer): StWaveInfo | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null
    if (header.cmdId !== FSM_HC_COMMAND_TYPE.FSM_CMD_WAVEINFO &&
      header.cmdId !== WAM_HC_COMMAND_TYPE.WAM_CMD_WAVEINFO) {
      return null
    }
    try {
      const wave = new StWaveInfo()
      const view = new DataView(buffer)
      wave.readFromDataView(view, MESSAGE_HEADER_SIZE)
      return wave
    } catch (e) {
      hilog.error(0x0001, TAG, `解析波形信息失败: ${e}`)
      return null
    }
  }

  parseWeightGlobal(buffer: ArrayBuffer): StWeightGlobal | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null
    if (header.cmdId !== WAM_HC_COMMAND_TYPE.WAM__CMD_WEIGHT_INFO) {
      return null
    }
    try {
      const data = new StWeightGlobal()
      const view = new DataView(buffer)
      data.readFromDataView(view, MESSAGE_HEADER_SIZE)
      return data
    } catch (e) {
      hilog.error(0x0001, TAG, `解析WAM全局重量失败: ${e}`)
      return null
    }
  }

  private parseInt32Payload(buffer: ArrayBuffer): number | null {
    if (buffer.byteLength < MESSAGE_HEADER_SIZE + 4) return null
    const view = new DataView(buffer)
    return view.getInt32(MESSAGE_HEADER_SIZE, true)
  }

  // ==================== 分级信息解析 ====================
  /**
   * 解析分级信息 (FSM_CMD_GRADEINFO)
   * @param buffer 数据缓冲区（包含消息头）
   * @returns 分级信息结构
   */
  parseGradeInfo(buffer: ArrayBuffer): StGradeInfo | StFruitGradeInfo | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null

    if (header.cmdId !== FSM_HC_COMMAND_TYPE.FSM_CMD_GRADEINFO &&
      header.cmdId !== HC_FSM_COMMAND_TYPE.HC_CMD_GRADE_INFO &&
      header.cmdId !== SIM_HMI_COMMAND_TYPE.SIM_HMI_INSPECTION_ON) {
      return null
    }

    const view = new DataView(buffer)
    const offset: number = MESSAGE_HEADER_SIZE

    try {
      const dataLen = header.length - MESSAGE_HEADER_SIZE
      if (header.cmdId === HC_FSM_COMMAND_TYPE.HC_CMD_GRADE_INFO ||
        header.cmdId === SIM_HMI_COMMAND_TYPE.SIM_HMI_INSPECTION_ON) {
        const info = createDefaultGradeInfo()
        info.readFromDataView(view, offset)
        return info
      }
      if (dataLen === StFruitGradeInfo.getSize()) {
        const info = new StFruitGradeInfo()
        info.readFromDataView(view, offset)
        return info
      }

      if (dataLen === StFruitParam.getSize()) {
        const wrap = new StFruitGradeInfo()
        wrap.params[0].readFromDataView(view, offset)
        wrap.nRouteId = 0
        return wrap
      }

      const legacy = createDefaultGradeInfo()

      legacy.fruitId = view.getUint32(offset, true)
      legacy.weight = view.getUint32(offset + 4, true)
      legacy.diameter = view.getUint16(offset + 8, true)
      legacy.colorGrade = view.getUint8(offset + 10)
      legacy.shapeGrade = view.getUint8(offset + 11)
      legacy.flawGrade = view.getUint8(offset + 12)
      legacy.sugarGrade = view.getUint8(offset + 13)
      legacy.acidityGrade = view.getUint8(offset + 14)
      legacy.densityGrade = view.getUint8(offset + 15)
      legacy.rigidityGrade = view.getUint8(offset + 16)
      legacy.qualityGrade = view.getUint8(offset + 17)
      legacy.sizeGrade = view.getUint8(offset + 18)
      legacy.finalGrade = view.getUint8(offset + 19)
      legacy.targetExit = view.getUint8(offset + 20)
      legacy.cupIndex = view.getUint8(offset + 21)
      legacy.colorR = view.getUint8(offset + 22)
      legacy.colorG = view.getUint8(offset + 23)
      legacy.colorB = view.getUint8(offset + 24)

      legacy.channelIndex = (header.srcId >> 4) & 0x0F
      legacy.timestamp = Date.now()

      return legacy
    } catch (e) {
      hilog.error(0x0001, TAG, `解析分级信息失败: ${e}`)
      return null
    }
  }

  // ==================== 通用消息解析 ====================
  /**
   * 解析任意消息
   * 根据命令ID自动选择解析方法
   * @param buffer 数据缓冲区
   * @returns 解析结果对象
   */
  parseMessage(buffer: ArrayBuffer): ParsedMessage | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null

    const cmdName: string = getCommandName(header.cmdId)
    if (this.isDebugEnabled()) {
      const prefix = this.bufferToHex(buffer.slice(0, Math.min(32, buffer.byteLength)))
      console.log(`[PROTO_DEBUG] cmd=${cmdName} (0x${header.cmdId.toString(16)}), src=0x${header.srcId.toString(16)}, len=${buffer.byteLength}, header.len=${header.length}, hex32=${prefix}`)
    }
    hilog.info(0x0001, TAG, `收到命令: ${cmdName} (0x${header.cmdId.toString(16)}) from 0x${header.srcId.toString(16)}`)

    const result: ParsedMessage = {
      header: header,
      cmdName: cmdName,
      data: null
    }

    switch (header.cmdId) {
      case FSM_HC_COMMAND_TYPE.FSM_CMD_STATISTICS:
        result.data = this.parseStatistics(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_WEIGHTINFO:
        result.data = this.parseWeightInfo(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_GRADEINFO:
        result.data = this.parseGradeInfo(buffer)
        break
      case HC_FSM_COMMAND_TYPE.HC_CMD_GRADE_INFO:
      case SIM_HMI_COMMAND_TYPE.SIM_HMI_INSPECTION_ON:
        result.data = this.parseGradeInfo(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_CONFIG:
        result.data = this.parseGlobal(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_GETVERSION:
        // 版本信息回复
        result.data = this.parseVersionInfo(buffer)
        break

      case WAM_HC_COMMAND_TYPE.WAM_CMD_REP_WAM_INFO:
        result.data = this.parseVersionInfo(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_WAVEINFO:
      case WAM_HC_COMMAND_TYPE.WAM_CMD_WAVEINFO:
        result.data = this.parseWaveInfo(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_VERSIONERROR:
      case FSM_HC_COMMAND_TYPE.FSM_CMD_BURN_FLASH_PROGRESS:
        result.data = this.parseInt32Payload(buffer)
        break

      case FSM_HC_COMMAND_TYPE.FSM_CMD_BOOT_FLASH_PROGRESS:
        result.data = this.parseVersionInfo(buffer)
        break
      case SIM_HMI_COMMAND_TYPE.SIM_HMI_DISPLAY_ON:
      case SIM_HMI_COMMAND_TYPE.SIM_HMI_INSPECTION_OFF:
        result.data = null
        break

      case WAM_HC_COMMAND_TYPE.WAM_CMD_WEIGHTINFO:
        result.data = this.parseWeightInfo(buffer)
        break

      case WAM_HC_COMMAND_TYPE.WAM__CMD_WEIGHT_INFO:
        result.data = this.parseWeightGlobal(buffer)
        break

      default:
        hilog.warn(0x0001, TAG, `未处理的命令类型: ${cmdName}`)
    }

    return result
  }

  private parseGlobal(buffer: ArrayBuffer): StGlobal | null {
    const header: MessageHeader | null = this.parseHeader(buffer)
    if (!header) return null
    if (header.cmdId !== FSM_HC_COMMAND_TYPE.FSM_CMD_CONFIG) return null

    try {
      const view = new DataView(buffer)
      const offset = MESSAGE_HEADER_SIZE
      const global = new StGlobal()
      global.readFromDataView(view, offset)
      return global
    } catch (e) {
      hilog.error(0x0001, TAG, `解析全局结构失败: ${e}`)
      return null
    }
  }

  /**
   * 解析版本信息
   */
  private parseVersionInfo(buffer: ArrayBuffer): string | null {
    try {
      const offset = MESSAGE_HEADER_SIZE
      if (buffer.byteLength <= offset) return ''
      const available = buffer.byteLength - offset
      const readLen = Math.min(ConstPreDefine.BYTE_NUM_FSM_VERSION, available)
      const versionBytes = new Uint8Array(buffer, offset, readLen)

      // 找到null终止符
      let endIndex = versionBytes.indexOf(0)
      if (endIndex === -1) endIndex = readLen

      const decoder = new util.TextDecoder('utf-8')
      const version: string = decoder.decode(versionBytes.slice(0, endIndex))
      hilog.info(0x0001, TAG, `FSM版本: ${version}`)
      return version
    } catch (e) {
      hilog.error(0x0001, TAG, `解析版本信息失败: ${e}`)
      return null
    }
  }

  // ==================== 命令构建 ====================
  /**
   * 构建无参数命令
   * @param cmdId 命令ID
   * @param destId 目标设备ID
   * @returns 完整的命令数据包
   */
  buildSimpleCommand(cmdId: number, destId: number): ArrayBuffer {
    return this.buildHeader(ConstPreDefine.HC_ID, destId, cmdId, 0)
  }

  /**
   * 构建带版本号的连接命令 (HC_CMD_DISPLAY_ON)
   * @param destId 目标设备ID
   * @returns 完整的命令数据包
   */
  buildConnectCommand(destId: number): ArrayBuffer {
    const dataLength = 4 // 版本号4字节
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)

    // 写入消息头
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, destId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_DISPLAY_ON, true)

    // 写入版本号
    view.setUint32(MESSAGE_HEADER_SIZE, ConstPreDefine.VERSION, true)

    return buffer
  }

  /**
   * 构建数据清零命令 (HC_CMD_CLEAR_DATA)
   */
  buildClearDataCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_CLEAR_DATA, destId)
  }

  /**
   * 构建保存数据命令 (HC_CMD_SAVE_CURRENT_DATA)
   */
  buildSaveDataCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_SAVE_CURRENT_DATA, destId)
  }

  /**
   * 构建获取版本命令 (HC_CMD_GETVERSION)
   */
  buildGetVersionCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_GETVERSION, destId)
  }

  /**
   * 构建开启统计信息上报命令 (HC_CMD_WEIGHTINFO_ON)
   */
  buildWeightInfoOnCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTINFO_ON, destId)
  }

  /**
   * 构建关闭统计信息上报命令 (HC_CMD_WEIGHTINFO_OFF)
   */
  buildWeightInfoOffCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTINFO_OFF, destId)
  }

  /**
   * 构建开启分级信息上报命令 (HC_CMD_GRADEINFO_ON)
   */
  buildGradeInfoOnCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_GRADEINFO_ON, destId)
  }

  /**
   * 构建关闭分级信息上报命令 (HC_CMD_GRADEINFO_OFF)
   */
  buildGradeInfoOffCommand(destId: number): ArrayBuffer {
    return this.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_GRADEINFO_OFF, destId)
  }

  // ==================== 辅助方法 ====================
  /**
   * ArrayBuffer转16进制字符串（调试用）
   */
  bufferToHex(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer)
    return Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join(' ')
  }

  private isDebugEnabled(): boolean {
    try {
      const flag = AppStorage.get('PROTO_DEBUG_ENABLED') as boolean | number | string | undefined
      return flag === true || flag === 1 || flag === '1' || flag === 'true'
    } catch (_) {
      return false
    }
  }

  /**
   * 检查是否为二进制协议消息
   * 根据消息头特征判断
   */
  isBinaryProtocol(buffer: ArrayBuffer): boolean {
    if (buffer.byteLength < MESSAGE_HEADER_SIZE) {
      return false
    }

    const view = new DataView(buffer)
    const length = view.getUint32(0, true)

    // 检查长度是否合理
    if (length < MESSAGE_HEADER_SIZE || length > buffer.byteLength) {
      return false
    }

    // 检查命令ID是否在有效范围
    const cmdId = view.getUint16(8, true)
    if (cmdId < 0x1000 && cmdId > 0x00FF) {
      return false
    }
    if (cmdId >= 0x1000 && cmdId < 0x5000) {
      return true
    }

    return length === buffer.byteLength
  }
}

/**
 * 解析后的消息结构
 */
export interface ParsedMessage {
  /** 消息头 */
  header: MessageHeader
  /** 命令名称 */
  cmdName: string
  /** 解析后的数据 */
  data: StStatistics | StWeightInfo | StWeightResult | StWaveInfo | StWeightGlobal | StGradeInfo | StFruitGradeInfo | StSysConfig | StGlobal | string | number | null
}

// 导出单例获取方法
export function getProtocolParser(): ProtocolParser {
  return ProtocolParser.getInstance()
}
