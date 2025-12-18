/**
 * TCP统计数据解析器
 * 功能：将TCP接收的二进制字节流解析为StStatistics结构体
 * 
 * 数据格式说明：
 * - 下位机发送的是二进制字节流，不是JSON序列化
 * - 数据格式：[SYNC字符串(4字节)] + [命令头(12字节)] + [数据体(结构体二进制)]
 * - 命令头：源ID(4字节) + 目标ID(4字节) + 命令ID(4字节)，小端字节序
 * - 数据体：C++结构体的二进制内存布局，直接通过字节偏移读取
 */

import { StStatistics, CommandHead, TcpDataPacket, createDefaultStStatistics, StRange } from '../types/StStatistics';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';

const DOMAIN = 0x0000;

// 常量定义
const MAX_QUALITY_GRADE_NUM = 8;
const MAX_SIZE_GRADE_NUM = 16;
const MAX_EXIT_NUM = 20;
const SYNC_STRING = 'SYNC';
const COMMAND_HEAD_SIZE = 12; // 命令头大小：4+4+4=12字节
const SYNC_SIZE = 4;          // SYNC字符串大小

/**
 * TCP统计数据解析器类
 */
export class TcpStatisticsParser {
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
   * 将字节数组转换为64位无符号整数（小端字节序）
   * @param bytes 字节数组（至少8字节）
   * @param offset 偏移量
   * @returns 64位无符号整数（在TypeScript中返回number，但值可能超过Number.MAX_SAFE_INTEGER）
   */
  private static bytesToUInt64(bytes: Uint8Array, offset: number): number {
    if (offset + 8 > bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + 8}字节`);
    }
    
    // 低32位
    const low = TcpStatisticsParser.bytesToInt32(bytes, offset);
    // 高32位
    const high = TcpStatisticsParser.bytesToInt32(bytes, offset + 4);
    
    // 组合为64位（注意：JavaScript的Number只能安全表示到2^53-1）
    // 如果值超过安全范围，只返回低32位（实际项目中可能需要使用BigInt）
    if (high === 0) {
      return low >>> 0; // 转换为无符号32位
    }
    
    // 如果高32位不为0，计算完整值（可能超出安全范围）
    return (high * 0x100000000) + (low >>> 0);
  }

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
   * 将字节数组转换为8位无符号整数
   * @param bytes 字节数组（至少1字节）
   * @param offset 偏移量
   * @returns 8位无符号整数
   */
  private static bytesToUInt8(bytes: Uint8Array, offset: number): number {
    if (offset >= bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + 1}字节`);
    }
    
    return bytes[offset] & 0xFF;
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
   * 解析命令头
   * @param bytes 字节数组（至少12字节）
   * @param offset 偏移量（默认0）
   * @returns 命令头对象
   */
  static parseCommandHead(bytes: Uint8Array, offset: number = 0): CommandHead {
    if (offset + COMMAND_HEAD_SIZE > bytes.length) {
      throw new Error(`字节数组长度不足，需要至少${offset + COMMAND_HEAD_SIZE}字节`);
    }
    
    const nSrcId = TcpStatisticsParser.bytesToInt32(bytes, offset);
    const nDstId = TcpStatisticsParser.bytesToInt32(bytes, offset + 4);
    const nCmdId = TcpStatisticsParser.bytesToInt32(bytes, offset + 8);
    
    return {
      nCmdId: nCmdId,
      nSrcId: nSrcId,
      nDstId: nDstId,
      nLength: 0 // 长度在后续解析数据体时确定
    };
  }

  /**
   * 检查是否为SYNC字符串
   * @param bytes 字节数组（至少4字节）
   * @returns 是否为SYNC
   */
  static isSync(bytes: Uint8Array): boolean {
    if (bytes.length < SYNC_SIZE) {
      return false;
    }
    
    const decoder = new util.TextDecoder('utf-8');
    const syncStr = decoder.decode(bytes.slice(0, SYNC_SIZE));
    return syncStr === SYNC_STRING;
  }

  /**
   * 解析StStatistics结构体
   * 注意：这个函数需要根据实际的C++结构体内存布局来解析
   * 由于不同编译器的内存对齐可能不同，这里假设是紧凑布局（无对齐）
   * 
   * @param bytes 数据体字节数组
   * @returns StStatistics对象
   */
  static parseStStatistics(bytes: Uint8Array): StStatistics {
    const stats = createDefaultStStatistics();
    let offset = 0;
    
    // 期望的数据体大小
    const EXPECTED_SIZE = (
      8 * 128 +  // nGradeCount[128]
      8 * 128 +  // nWeightGradeCount[128]
      8 * 20 +   // nExitCount[20]
      8 * 20 +   // nExitWeightCount[20]
      8 +        // nTotalCount
      8 +        // nWeightCount
      4 +        // nSubsysId
      4 * 128 +  // nBoxGradeCount[128]
      4 * 128 +  // nBoxGradeWeight[128]
      4 +        // nTotalCupNum
      4 +        // nInterval
      4 +        // nIntervalSumperminute
      2 +        // nCupState
      2 +        // nPulseInterval
      2 +        // nUnpushFruitCount
      1 +        // nNetState
      1 +        // nWeightSetting
      1 +        // nSCMState
      1 +        // nIQSNetState
      1 +        // nLockState
      4 * 20 +   // ExitBoxNum[20]
      8 * 16     // fSelectBasisRange[16]
    ); // = 3620字节
    
    if (bytes.length < EXPECTED_SIZE) {
      console.error(`[TcpStatisticsParser] 数据体长度不足: 实际 ${bytes.length} 字节, 期望 ${EXPECTED_SIZE} 字节`);
      throw new Error(`数据体长度不足: 实际 ${bytes.length} 字节, 期望 ${EXPECTED_SIZE} 字节`);
    }
    
    if (bytes.length > EXPECTED_SIZE) {
      console.warn(`[TcpStatisticsParser] 数据体长度超出: 实际 ${bytes.length} 字节, 期望 ${EXPECTED_SIZE} 字节，将只解析前 ${EXPECTED_SIZE} 字节`);
    }
    
    try {
      // 解析数组数据（需要根据实际结构体布局调整偏移量）
      // 注意：这里假设数组是连续存储的，每个元素占4字节（int/ulong）或8字节（ulong）
      
      // nGradeCount数组：ulong数组，每个元素8字节
      for (let i = 0; i < MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM; i++) {
        stats.nGradeCount[i] = TcpStatisticsParser.bytesToUInt64(bytes, offset);
        offset += 8;
      }
      
      // nWeightGradeCount数组：ulong数组，每个元素8字节
      for (let i = 0; i < MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM; i++) {
        stats.nWeightGradeCount[i] = TcpStatisticsParser.bytesToUInt64(bytes, offset);
        offset += 8;
      }
      
      // nExitCount数组：ulong数组，每个元素8字节
      for (let i = 0; i < MAX_EXIT_NUM; i++) {
        stats.nExitCount[i] = TcpStatisticsParser.bytesToUInt64(bytes, offset);
        offset += 8;
      }
      
      // nExitWeightCount数组：ulong数组，每个元素8字节
      for (let i = 0; i < MAX_EXIT_NUM; i++) {
        stats.nExitWeightCount[i] = TcpStatisticsParser.bytesToUInt64(bytes, offset);
        offset += 8;
      }
      
      // nTotalCount：ulong，8字节
      stats.nTotalCount = TcpStatisticsParser.bytesToUInt64(bytes, offset);
      offset += 8;
      
      // nWeightCount：ulong，8字节
      stats.nWeightCount = TcpStatisticsParser.bytesToUInt64(bytes, offset);
      offset += 8;
      
      // nSubsysId：int，4字节
      stats.nSubsysId = TcpStatisticsParser.bytesToInt32(bytes, offset);
      offset += 4;
      
      // nBoxGradeCount数组：int数组，每个元素4字节
      for (let i = 0; i < MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM; i++) {
        stats.nBoxGradeCount[i] = TcpStatisticsParser.bytesToInt32(bytes, offset);
        offset += 4;
      }
      
      // nBoxGradeWeight数组：int数组，每个元素4字节
      for (let i = 0; i < MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM; i++) {
        stats.nBoxGradeWeight[i] = TcpStatisticsParser.bytesToInt32(bytes, offset);
        offset += 4;
      }
      
      // nTotalCupNum：int，4字节
      stats.nTotalCupNum = TcpStatisticsParser.bytesToInt32(bytes, offset);
      offset += 4;
      
      // nInterval：int，4字节
      stats.nInterval = TcpStatisticsParser.bytesToInt32(bytes, offset);
      offset += 4;
      
      // nIntervalSumperminute：int，4字节
      stats.nIntervalSumperminute = TcpStatisticsParser.bytesToInt32(bytes, offset);
      offset += 4;
      
      // nCupState：ushort，2字节
      stats.nCupState = TcpStatisticsParser.bytesToUInt16(bytes, offset);
      offset += 2;
      
      // nPulseInterval：ushort，2字节
      stats.nPulseInterval = TcpStatisticsParser.bytesToUInt16(bytes, offset);
      offset += 2;
      
      // nUnpushFruitCount：ushort，2字节
      stats.nUnpushFruitCount = TcpStatisticsParser.bytesToUInt16(bytes, offset);
      offset += 2;
      
      // nNetState：quint8，1字节（根据编译选项可能是ushort，2字节）
      // 这里先尝试1字节，如果不对可以改为2字节
      stats.nNetState = TcpStatisticsParser.bytesToUInt8(bytes, offset);
      offset += 1;
      
      // nWeightSetting：quint8，1字节（根据编译选项可能是ushort，2字节）
      stats.nWeightSetting = TcpStatisticsParser.bytesToUInt8(bytes, offset);
      offset += 1;
      
      // nSCMState：根据编译选项可能是quint8(1字节)或int(4字节)
      // 这里先尝试1字节
      stats.nSCMState = TcpStatisticsParser.bytesToUInt8(bytes, offset);
      offset += 1;
      
      // nIQSNetState：根据编译选项可能是quint8(1字节)或ushort(2字节)
      stats.nIQSNetState = TcpStatisticsParser.bytesToUInt8(bytes, offset);
      offset += 1;
      
      // nLockState：quint8，1字节
      stats.nLockState = TcpStatisticsParser.bytesToUInt8(bytes, offset);
      offset += 1;
      
      // ExitBoxNum数组：quint32数组，每个元素4字节
      for (let i = 0; i < MAX_EXIT_NUM; i++) {
        stats.ExitBoxNum[i] = TcpStatisticsParser.bytesToInt32(bytes, offset);
        offset += 4;
      }
      
      // fSelectBasisRange数组：StRange数组，每个StRange包含2个float（8字节）
      for (let i = 0; i < MAX_SIZE_GRADE_NUM; i++) {
        const range: StRange = {
          nMin: TcpStatisticsParser.bytesToFloat(bytes, offset),
          nMax: TcpStatisticsParser.bytesToFloat(bytes, offset + 4)
        };
        stats.fSelectBasisRange[i] = range;
        offset += 8;
      }
      
      console.log(`[TcpStatisticsParser] 解析StStatistics成功，总个数: ${stats.nTotalCount}, 总重量: ${stats.nWeightCount}`);
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TcpStatisticsParser] 解析StStatistics失败: ${errorMsg}`);
      throw new Error(errorMsg);
    }
    
    return stats;
  }

  /**
   * 解析完整的TCP数据包
   * @param bytes 完整的TCP数据包字节数组
   * @returns TcpDataPacket对象
   */
  static parseTcpPacket(bytes: Uint8Array): TcpDataPacket | null {
    try {
      // 检查SYNC
      if (!TcpStatisticsParser.isSync(bytes)) {
        console.warn(`[TcpStatisticsParser] 数据包不是以SYNC开头`);
        return null;
      }
      
      // 解析命令头
      const commandHead = TcpStatisticsParser.parseCommandHead(bytes, SYNC_SIZE);
      
      // 提取数据体
      const dataOffset = SYNC_SIZE + COMMAND_HEAD_SIZE;
      const data = bytes.slice(dataOffset);
      
      console.log(`[TcpStatisticsParser] 解析TCP数据包成功，数据体长度: ${data.length} 字节`);
      
      return {
        sync: SYNC_STRING,
        commandHead: commandHead,
        data: data
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TcpStatisticsParser] 解析TCP数据包失败: ${errorMsg}`);
      return null;
    }
  }
}

