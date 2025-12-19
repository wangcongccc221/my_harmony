/**
 * TCP波形数据解析器
 * 功能：将TCP接收的二进制字节流解析为StWaveInfo结构体
 * 
 * 数据格式说明：
 * - 下位机发送的是二进制字节流，不是JSON序列化
 * - 数据格式：[SYNC字符串(4字节)] + [命令头(12字节)] + [数据体(结构体二进制)]
 * - 命令头：源ID(4字节) + 目标ID(4字节) + 命令ID(4字节)，小端字节序
 * - 数据体：C++结构体的二进制内存布局，直接通过字节偏移读取
 * 
 * StWaveInfo结构体布局（总大小1032字节）：
 * - nChannelId: int (4字节)
 * - waveform0[256]: ushort[256] (512字节)
 * - waveform1[256]: ushort[256] (512字节)
 * - fruitweight: float (4字节)
 */

import { StWaveInfo, createDefaultStWaveInfo, WAVE_POINT_COUNT } from '../types/StWaveInfo';
import { CommandHead, TcpDataPacket } from '../types/StStatistics';
import { TcpStatisticsParser } from './TcpStatisticsParser';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * TCP波形数据包接口
 * 扩展TcpDataPacket，包含解析后的波形信息
 */
export interface TcpWaveDataPacket {
  commandHead: CommandHead;
  data: Uint8Array;
  waveInfo: StWaveInfo;
}

const DOMAIN = 0x0000;

// 常量定义
const SYNC_STRING = 'SYNC';
const COMMAND_HEAD_SIZE = 12; // 命令头大小：4+4+4=12字节
const SYNC_SIZE = 4;          // SYNC字符串大小
const FSM_CMD_WAVEINFO = 0x1004; // 波形信息命令ID

/**
 * TCP波形数据解析器类
 */
export class TcpWaveInfoParser {
  /**
   * 将字节数组转换为16位无符号整数（小端字节序）
   * @param bytes 字节数组（至少2字节）
   * @param offset 偏移量
   * @returns 16位无符号整数
   */
  private static bytesToUInt16(bytes: Uint8Array, offset: number): number {
    if (offset + 2 > bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + 2}字节`);
    }
    
    return (bytes[offset] & 0xFF) | ((bytes[offset + 1] & 0xFF) << 8);
  }

  /**
   * 将字节数组转换为32位整数（小端字节序）
   * @param bytes 字节数组（至少4字节）
   * @param offset 偏移量
   * @returns 32位整数
   */
  private static bytesToInt32(bytes: Uint8Array, offset: number): number {
    if (offset + 4 > bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + 4}字节`);
    }
    
    let value = 0;
    value |= (bytes[offset] & 0xFF);
    value |= ((bytes[offset + 1] & 0xFF) << 8);
    value |= ((bytes[offset + 2] & 0xFF) << 16);
    value |= ((bytes[offset + 3] & 0xFF) << 24);
    
    // 处理有符号整数（如果最高位为1，则为负数）
    if (value & 0x80000000) {
      value = value | 0xFFFFFFFF00000000;
    }
    
    return value;
  }

  /**
   * 将字节数组转换为浮点数（IEEE 754单精度）
   * @param bytes 字节数组（至少4字节）
   * @param offset 偏移量
   * @returns 浮点数
   */
  private static bytesToFloat(bytes: Uint8Array, offset: number): number {
    if (offset + 4 > bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + 4}字节`);
    }
    
    // 手动解析IEEE 754单精度浮点数（小端字节序）
    // 格式：符号位(1) + 指数位(8) + 尾数位(23)
    const b0 = bytes[offset] & 0xFF;
    const b1 = bytes[offset + 1] & 0xFF;
    const b2 = bytes[offset + 2] & 0xFF;
    const b3 = bytes[offset + 3] & 0xFF;
    
    // 组合为32位整数（小端）
    const bits = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    
    // 解析IEEE 754格式
    const sign = (bits >>> 31) === 0 ? 1 : -1;
    const exponent = ((bits >>> 23) & 0xFF) - 127;
    const mantissa = (bits & 0x7FFFFF) | 0x800000; // 添加隐含的1
    
    // 计算浮点数值
    if (exponent === -127) {
      // 非规格化数或零
      if (mantissa === 0x800000) {
        return sign === 1 ? 0.0 : -0.0;
      }
      return sign * (mantissa / 0x800000) * Math.pow(2, -126);
    } else if (exponent === 128) {
      // 无穷大或NaN
      if (mantissa === 0x800000) {
        return sign === 1 ? Infinity : -Infinity;
      }
      return NaN;
    }
    
    return sign * (mantissa / 0x800000) * Math.pow(2, exponent);
  }

  /**
   * 检查是否为SYNC字符串
   * @param bytes 字节数组（至少4字节）
   * @returns 是否为SYNC
   */
  static isSync(bytes: Uint8Array): boolean {
    return TcpStatisticsParser.isSync(bytes);
  }

  /**
   * 解析命令头
   * @param bytes 字节数组（至少12字节）
   * @param offset 偏移量（默认0）
   * @returns 命令头对象
   */
  static parseCommandHead(bytes: Uint8Array, offset: number = 0): CommandHead {
    return TcpStatisticsParser.parseCommandHead(bytes, offset);
  }

  /**
   * 解析StWaveInfo结构体
   * 结构体布局：
   * - offset 0: nChannelId (int, 4字节)
   * - offset 4: waveform0[256] (ushort[256], 512字节)
   * - offset 516: waveform1[256] (ushort[256], 512字节)
   * - offset 1028: fruitweight (float, 4字节)
   * 
   * @param bytes 数据体字节数组（至少1032字节）
   * @returns StWaveInfo对象
   */
  static parseStWaveInfo(bytes: Uint8Array): StWaveInfo {
    if (bytes.length < 1032) {
      throw new Error(`字节数组长度不足，需要至少1032字节，实际: ${bytes.length}`);
    }

    let offset = 0;

    // 1. nChannelId (int, 4字节)
    const nChannelId = TcpWaveInfoParser.bytesToInt32(bytes, offset);
    offset += 4;

    // 2. waveform0[256] (ushort[256], 512字节)
    const waveform0: number[] = [];
    for (let i = 0; i < WAVE_POINT_COUNT; i++) {
      waveform0.push(TcpWaveInfoParser.bytesToUInt16(bytes, offset));
      offset += 2;
    }

    // 3. waveform1[256] (ushort[256], 512字节)
    const waveform1: number[] = [];
    for (let i = 0; i < WAVE_POINT_COUNT; i++) {
      waveform1.push(TcpWaveInfoParser.bytesToUInt16(bytes, offset));
      offset += 2;
    }

    // 4. fruitweight (float, 4字节)
    const fruitweight = TcpWaveInfoParser.bytesToFloat(bytes, offset);
    offset += 4;

    const waveInfo: StWaveInfo = {
      nChannelId: nChannelId,
      waveform0: waveform0,
      waveform1: waveform1,
      fruitweight: fruitweight
    };

    hilog.info(DOMAIN, 'TcpWaveInfoParser', `解析StWaveInfo成功 - 通道ID: ${nChannelId}, 水果重量: ${fruitweight}g, waveform0[0]: ${waveform0[0]}, waveform1[0]: ${waveform1[0]}`);

    return waveInfo;
  }

  /**
   * 解析完整的TCP数据包（SYNC + 命令头 + 数据体）
   * @param bytes 完整的TCP数据包字节数组
   * @returns TcpWaveDataPacket对象，如果解析失败则返回null
   */
  static parseTcpPacket(bytes: Uint8Array): TcpWaveDataPacket | null {
    try {
      // 1. 检查SYNC
      if (!TcpWaveInfoParser.isSync(bytes)) {
        hilog.warn(DOMAIN, 'TcpWaveInfoParser', `数据包不是以SYNC开头`);
        return null;
      }

      // 2. 解析命令头（从offset 4开始）
      const commandHead = TcpWaveInfoParser.parseCommandHead(bytes, SYNC_SIZE);
      
      // 3. 检查命令ID是否为波形信息命令
      if (commandHead.nCmdId !== FSM_CMD_WAVEINFO) {
        hilog.warn(DOMAIN, 'TcpWaveInfoParser', `命令ID不匹配，期望: ${FSM_CMD_WAVEINFO}, 实际: ${commandHead.nCmdId}`);
        return null;
      }

      // 4. 提取数据体（从offset 16开始，即SYNC(4) + 命令头(12)）
      const dataBodyOffset = SYNC_SIZE + COMMAND_HEAD_SIZE;
      const dataBody = bytes.slice(dataBodyOffset);

      // 5. 解析StWaveInfo
      const waveInfo = TcpWaveInfoParser.parseStWaveInfo(dataBody);

      const packet: TcpWaveDataPacket = {
        commandHead: commandHead,
        data: dataBody,
        waveInfo: waveInfo
      };

      return packet;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      hilog.error(DOMAIN, 'TcpWaveInfoParser', `解析TCP数据包失败: ${errorMsg}`);
      return null;
    }
  }
}

