/**
 * 统计数据处理器
 * 功能：处理从TCP接收的StStatistics二进制数据
 */

import { TcpStatisticsParser } from '../parsers/TcpStatisticsParser';
import { RealtimeDataManager } from '../../../managers/RealtimeDataManager';
import { StStatistics, CommandHead } from '../types/StStatistics';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const FSM_CMD_STATISTICS = 0x0001; // 统计信息命令ID

/**
 * 处理TCP接收的统计数据
 * @param data TCP接收的原始字节数组
 */
export async function handleStatisticsData(data: Uint8Array): Promise<void> {
  try {
    console.log(`[StatisticsDataHandler] 收到数据，长度: ${data.length} 字节`);
    
    // 检查是否为SYNC开头
    if (!TcpStatisticsParser.isSync(data)) {
      console.warn(`[StatisticsDataHandler] 接收的数据不是以SYNC开头，前4字节: ${data[0]}, ${data[1]}, ${data[2]}, ${data[3]}`);
      return;
    }
    
    console.log(`[StatisticsDataHandler] 数据包以SYNC开头，开始解析...`);
    
    // 解析TCP数据包
    const packet = TcpStatisticsParser.parseTcpPacket(data);
    if (!packet) {
      console.warn(`[StatisticsDataHandler] 解析TCP数据包失败`);
      return;
    }
    
    console.log(`[StatisticsDataHandler] TCP数据包解析成功 - 源ID: ${packet.commandHead.nSrcId}, 目标ID: ${packet.commandHead.nDstId}, 命令ID: ${packet.commandHead.nCmdId}, 数据体长度: ${packet.data.length}`);
    
    // 检查命令ID是否为统计信息命令
    if (packet.commandHead.nCmdId !== FSM_CMD_STATISTICS) {
      console.warn(`[StatisticsDataHandler] 收到非统计信息命令，命令ID: ${packet.commandHead.nCmdId}，期望: ${FSM_CMD_STATISTICS}`);
      return;
    }
    
    console.log(`[StatisticsDataHandler] 开始解析StStatistics结构体...`);
    
    // 解析StStatistics结构体
    const statistics = TcpStatisticsParser.parseStStatistics(packet.data);
    
    // 获取子系统ID（从命令头的源ID获取，或者从统计数据中获取）
    const subsysId = statistics.nSubsysId >= 0 ? statistics.nSubsysId : packet.commandHead.nSrcId;
    
    console.log(`[StatisticsDataHandler] StStatistics解析成功 - 子系统ID: ${subsysId}, 总个数: ${statistics.nTotalCount}, 总重量: ${statistics.nWeightCount}克, 分选速度: ${statistics.nIntervalSumperminute}`);
    
    // 更新实时数据管理器
    const dataManager = RealtimeDataManager.getInstance();
    dataManager.updateStatistics(subsysId, statistics);
    
    console.log(`[StatisticsDataHandler] 统计数据已更新到RealtimeDataManager - 子系统ID: ${subsysId}`);
    
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[StatisticsDataHandler] 处理统计数据失败: ${errorMsg}`);
      if (error instanceof Error && error.stack) {
        console.error(`[StatisticsDataHandler] 错误堆栈: ${error.stack}`);
      }
    }
}

