/**
 * 配置发送器
 * 负责向下位机发送配置命令
 * 对应48项目的命令发送逻辑
 */

import { ConstPreDefine } from './ConstPreDefine'
import { HC_FSM_COMMAND_TYPE } from './CommandTypes'
import { MESSAGE_HEADER_SIZE, StSizeGradeSetting, StQualityGradeSetting, StExitSetting, StGradeInfo, StMotorInfo } from './Structures'
import { getProtocolParser, ProtocolParser } from './ProtocolParser'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { util } from '@kit.ArkTS'

const TAG = 'ConfigSender'

/**
 * TCP发送接口
 * 由外部实现，用于发送数据到指定设备
 */
export interface ITcpSender {
  sendToDevice(deviceId: number, data: ArrayBuffer): Promise<boolean>
  sendToAllDevices(data: ArrayBuffer): Promise<void>
  isDeviceConnected(deviceId: number): boolean
}

/**
 * 配置发送器类
 * 构建并发送各种配置命令到下位机
 */
export class ConfigSender {
  private static instance: ConfigSender | null = null

  private parser: ProtocolParser
  private tcpSender: ITcpSender | null = null
  private enableConsoleDump: boolean = true

  private toHex(bytes: Uint8Array): string {
    let out = ''
    for (let i = 0; i < bytes.length; i++) {
      const hex = bytes[i].toString(16).padStart(2, '0')
      out += (i === 0 ? hex : ` ${hex}`)
    }
    return out
  }

  private dumpPacket(data: ArrayBuffer, headBytes: number = 128, tailBytes: number = 64): string {
    const u8 = new Uint8Array(data)
    const total = u8.length
    const headLen = Math.min(headBytes, total)
    const tailLen = Math.min(tailBytes, Math.max(0, total - headLen))
    const head = this.toHex(u8.slice(0, headLen))
    if (tailLen <= 0) {
      return `len=${total} hex=${head}`
    }
    const tail = this.toHex(u8.slice(total - tailLen))
    return `len=${total} head(${headLen})=${head} ... tail(${tailLen})=${tail}`
  }

  private parseHeader(data: ArrayBuffer): string {
    if (data.byteLength < 10) {
      return `rawLen=${data.byteLength}`
    }
    const view = new DataView(data)
    const totalLen = view.getUint32(0, true)
    const hcId = view.getUint16(4, true)
    const fsmId = view.getUint16(6, true)
    const cmdId = view.getUint16(8, true)
    return `totalLen=${totalLen} hcId=0x${hcId.toString(16)} fsmId=0x${fsmId.toString(16)} cmdId=0x${cmdId.toString(16)}`
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ConfigSender {
    if (!ConfigSender.instance) {
      ConfigSender.instance = new ConfigSender()
    }
    return ConfigSender.instance
  }

  private constructor() {
    this.parser = getProtocolParser()
    hilog.info(0x0001, TAG, '配置发送器初始化')
  }

  /**
   * 设置TCP发送器
   * @param sender TCP发送器实现
   */
  setTcpSender(sender: ITcpSender): void {
    this.tcpSender = sender
    hilog.info(0x0001, TAG, 'TCP发送器已设置')
  }

  // ==================== 连接控制命令 ====================
  /**
   * 发送连接命令 (HC_CMD_DISPLAY_ON)
   * @param fsmId FSM设备ID
   */
  async sendConnect(fsmId: number): Promise<boolean> {
    const data = this.parser.buildConnectCommand(fsmId)
    return this.sendCommand(fsmId, data, 'DISPLAY_ON')
  }

  /**
   * 发送断开连接命令 (HC_CMD_DISPLAY_OFF)
   * @param fsmId FSM设备ID
   */
  async sendDisconnect(fsmId: number): Promise<boolean> {
    const data = this.parser.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_DISPLAY_OFF, fsmId)
    return this.sendCommand(fsmId, data, 'DISPLAY_OFF')
  }

  // ==================== 数据控制命令 ====================
  /**
   * 发送数据清零命令 (HC_CMD_CLEAR_DATA)
   * @param fsmId FSM设备ID，不传则发送给所有设备
   */
  async sendClearData(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildClearDataCommand(fsmId)
      return this.sendCommand(fsmId, data, 'CLEAR_DATA')
    } else {
      // 发送给所有已连接的FSM
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_CLEAR_DATA, 'CLEAR_DATA')
    }
  }

  /**
   * 发送保存数据命令 (HC_CMD_SAVE_CURRENT_DATA)
   * @param fsmId FSM设备ID
   */
  async sendSaveData(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildSaveDataCommand(fsmId)
      return this.sendCommand(fsmId, data, 'SAVE_DATA')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_SAVE_CURRENT_DATA, 'SAVE_DATA')
    }
  }

  // ==================== 信息获取命令 ====================
  /**
   * 发送获取版本命令 (HC_CMD_GETVERSION)
   * @param fsmId FSM设备ID
   */
  async sendGetVersion(fsmId: number): Promise<boolean> {
    const data = this.parser.buildGetVersionCommand(fsmId)
    return this.sendCommand(fsmId, data, 'GETVERSION')
  }

  // ==================== 上报控制命令 ====================
  /**
   * 开启重量信息上报 (HC_CMD_WEIGHTINFO_ON)
   * @param fsmId FSM设备ID
   */
  async sendWeightInfoOn(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildWeightInfoOnCommand(fsmId)
      return this.sendCommand(fsmId, data, 'WEIGHTINFO_ON')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTINFO_ON, 'WEIGHTINFO_ON')
    }
  }

  /**
   * 关闭重量信息上报 (HC_CMD_WEIGHTINFO_OFF)
   * @param fsmId FSM设备ID
   */
  async sendWeightInfoOff(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildWeightInfoOffCommand(fsmId)
      return this.sendCommand(fsmId, data, 'WEIGHTINFO_OFF')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTINFO_OFF, 'WEIGHTINFO_OFF')
    }
  }

  /**
   * 开启分级信息上报 (HC_CMD_GRADEINFO_ON)
   * @param fsmId FSM设备ID
   */
  async sendGradeInfoOn(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildGradeInfoOnCommand(fsmId)
      return this.sendCommand(fsmId, data, 'GRADEINFO_ON')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_GRADEINFO_ON, 'GRADEINFO_ON')
    }
  }

  /**
   * 关闭分级信息上报 (HC_CMD_GRADEINFO_OFF)
   * @param fsmId FSM设备ID
   */
  async sendGradeInfoOff(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildGradeInfoOffCommand(fsmId)
      return this.sendCommand(fsmId, data, 'GRADEINFO_OFF')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_GRADEINFO_OFF, 'GRADEINFO_OFF')
    }
  }

  // ==================== 配置发送命令 ====================
  /**
   * 发送尺寸等级配置 (HC_CMD_GRADE_INFO)
   * @param fsmId FSM设备ID
   * @param grades 尺寸等级设置数组
   */
  async sendSizeGradeConfig(fsmId: number, grades: StSizeGradeSetting[]): Promise<boolean> {
    const dataLength = grades.length * 16 // 每个等级16字节
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)

    // 写入消息头
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_GRADE_INFO, true)

    // 写入等级数据
    let offset: number = MESSAGE_HEADER_SIZE
    for (const grade of grades) {
      view.setUint8(offset, grade.gradeIndex)
      view.setUint8(offset + 1, grade.enabled ? 1 : 0)
      view.setUint16(offset + 2, grade.weightMin, true)
      view.setUint16(offset + 4, grade.weightMax, true)
      view.setUint16(offset + 6, grade.diameterMin, true)
      view.setUint16(offset + 8, grade.diameterMax, true)
      // 预留6字节
      offset += 16
    }

    return this.sendCommand(fsmId, buffer, 'GRADE_INFO')
  }

  /**
   * 发送出口配置 (HC_CMD_EXIT_INFO)
   * @param fsmId FSM设备ID
   * @param exits 出口设置数组
   */
  async sendExitConfig(fsmId: number, exits: StExitSetting[]): Promise<boolean> {
    const dataLength = exits.length * 32 // 每个出口32字节
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)

    // 写入消息头
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_EXIT_INFO, true)

    // 写入出口数据
    let offset: number = MESSAGE_HEADER_SIZE
    for (const exit of exits) {
      view.setUint8(offset, exit.exitIndex)
      view.setUint8(offset + 1, exit.enabled ? 1 : 0)
      view.setUint8(offset + 2, exit.targetSizeGrade)
      view.setUint8(offset + 3, exit.targetQualityGrade)
      view.setUint16(offset + 4, exit.boxCapacity, true)
      // 出口名称（最多20字节）
      const encoder = new util.TextEncoder()
      const nameBytes: Uint8Array = encoder.encodeInto(exit.exitName.substring(0, 20))
      for (let i = 0; i < nameBytes.length && i < 20; i++) {
        view.setUint8(offset + 6 + i, nameBytes[i])
      }
      offset += 32
    }

    return this.sendCommand(fsmId, buffer, 'EXIT_INFO')
  }

  async sendFullGradeInfo(fsmId: number, gradeInfo: StGradeInfo): Promise<boolean> {
    const dataLength = StGradeInfo.getSize()
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_GRADE_INFO, true)
    gradeInfo.writeToDataView(view, MESSAGE_HEADER_SIZE)
    return this.sendCommand(fsmId, buffer, 'GRADE_INFO_FULL')
  }

  async sendMotorInfo(fsmId: number, motorInfo: StMotorInfo): Promise<boolean> {
    const dataLength = StMotorInfo.getSize()
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_MOTOR_INFO, true)
    motorInfo.writeToDataView(view, MESSAGE_HEADER_SIZE)
    return this.sendCommand(fsmId, buffer, 'MOTOR_INFO')
  }

  async sendMotorEnable(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_MOTOR_ENABLE, fsmId)
      return this.sendCommand(fsmId, data, 'MOTOR_ENABLE')
    }
    return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_MOTOR_ENABLE, 'MOTOR_ENABLE')
  }

  // ==================== 测试命令 ====================
  /**
   * 发送电磁阀测试命令 (HC_CMD_TEST_VOLVE)
   * @param fsmId FSM设备ID
   * @param channelIndex 通道索引
   * @param exitIndex 出口索引
   */
  async sendTestValve(fsmId: number, channelIndex: number, exitIndex: number): Promise<boolean> {
    const dataLength = 4
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)

    // 写入消息头
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_TEST_VOLVE, true)

    // 写入测试参数
    view.setUint16(MESSAGE_HEADER_SIZE, channelIndex, true)
    view.setUint16(MESSAGE_HEADER_SIZE + 2, exitIndex, true)

    return this.sendCommand(fsmId, buffer, 'TEST_VOLVE')
  }

  async sendTestAllLaneValve(fsmId: number, channelIndex: number, exitIndex: number): Promise<boolean> {
    const dataLength = 4
    const totalLength = MESSAGE_HEADER_SIZE + dataLength
    const buffer = new ArrayBuffer(totalLength)
    const view = new DataView(buffer)
    view.setUint32(0, totalLength, true)
    view.setUint16(4, ConstPreDefine.HC_ID, true)
    view.setUint16(6, fsmId, true)
    view.setUint16(8, HC_FSM_COMMAND_TYPE.HC_CMD_TEST_ALL_LANE_VOLVE, true)
    view.setUint16(MESSAGE_HEADER_SIZE, channelIndex, true)
    view.setUint16(MESSAGE_HEADER_SIZE + 2, exitIndex, true)
    return this.sendCommand(fsmId, buffer, 'TEST_ALL_LANE_VOLVE')
  }

  /**
   * 发送网络测试命令 (HC_CMD_TEST_NET)
   * @param fsmId FSM设备ID
   */
  async sendTestNetwork(fsmId: number): Promise<boolean> {
    const data = this.parser.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_TEST_NET, fsmId)
    return this.sendCommand(fsmId, data, 'TEST_NET')
  }

  // ==================== 系统控制命令 ====================
  /**
   * 发送称重重置命令 (HC_CMD_WEIGHTRESET)
   * @param fsmId FSM设备ID
   */
  async sendWeightReset(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTRESET, fsmId)
      return this.sendCommand(fsmId, data, 'WEIGHTRESET')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_WEIGHTRESET, 'WEIGHTRESET')
    }
  }

  /**
   * 发送网络关机命令 (HC_CMD_SHUT_DOWN)
   * @param fsmId FSM设备ID
   */
  async sendShutdown(fsmId?: number): Promise<boolean> {
    if (fsmId !== undefined) {
      const data = this.parser.buildSimpleCommand(HC_FSM_COMMAND_TYPE.HC_CMD_SHUT_DOWN, fsmId)
      return this.sendCommand(fsmId, data, 'SHUT_DOWN')
    } else {
      return this.broadcastCommand(HC_FSM_COMMAND_TYPE.HC_CMD_SHUT_DOWN, 'SHUT_DOWN')
    }
  }

  // ==================== 辅助方法 ====================
  /**
   * 发送命令到指定设备
   */
  private async sendCommand(deviceId: number, data: ArrayBuffer, cmdName: string): Promise<boolean> {
    if (!this.tcpSender) {
      hilog.warn(0x0001, TAG, `发送${cmdName}失败: TCP发送器未设置`)
      return false
    }

    try {
      if (this.enableConsoleDump) {
        console.log(`[SEND ${cmdName}] device=0x${deviceId.toString(16)} ${this.parseHeader(data)}`)
        console.log(`[SEND ${cmdName}] ${this.dumpPacket(data)}`)
      }
      const success = await this.tcpSender.sendToDevice(deviceId, data)
      if (success) {
        hilog.info(0x0001, TAG, `发送${cmdName}到0x${deviceId.toString(16)}成功`)
      } else {
        hilog.warn(0x0001, TAG, `发送${cmdName}到0x${deviceId.toString(16)}失败`)
      }
      return success
    } catch (e) {
      hilog.error(0x0001, TAG, `发送${cmdName}异常: ${e}`)
      return false
    }
  }

  /**
   * 广播命令到所有已连接设备
   */
  private async broadcastCommand(cmdId: number, cmdName: string): Promise<boolean> {
    if (!this.tcpSender) {
      hilog.warn(0x0001, TAG, `广播${cmdName}失败: TCP发送器未设置`)
      return false
    }

    // 构建针对不同设备的命令并发送
    let successCount = 0
    const maxSubsys = ConstPreDefine.MAX_SUBSYS_NUM

    for (let i = 0; i < maxSubsys; i++) {
      const fsmId = ConstPreDefine.getFsmId(i)
      if (this.tcpSender.isDeviceConnected(fsmId)) {
        const data = this.parser.buildSimpleCommand(cmdId, fsmId)
        try {
          if (this.enableConsoleDump) {
            console.log(`[SEND ${cmdName}] device=0x${fsmId.toString(16)} ${this.parseHeader(data)}`)
            console.log(`[SEND ${cmdName}] ${this.dumpPacket(data)}`)
          }
          const success = await this.tcpSender.sendToDevice(fsmId, data)
          if (success) successCount++
        } catch (e) {
          hilog.warn(0x0001, TAG, `广播${cmdName}到FSM${i}失败: ${e}`)
        }
      }
    }

    hilog.info(0x0001, TAG, `广播${cmdName}完成: 成功${successCount}个设备`)
    return successCount > 0
  }

  /**
   * 获取FSM ID
   * @param subsysIndex 子系统索引（0-based）
   */
  getFsmId(subsysIndex: number): number {
    return ConstPreDefine.getFsmId(subsysIndex)
  }
}

// 导出单例获取方法
export function getConfigSender(): ConfigSender {
  return ConfigSender.getInstance()
}
