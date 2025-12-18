/**
 * 配置数据处理器
 * 功能：处理从TCP接收的FSM_CMD_CONFIG命令（StGlobal结构体）
 * 对应48项目中的FSM_CMD_CONFIG命令处理
 */

import { TcpStatisticsParser } from '../parsers/TcpStatisticsParser';
import { GradeInfoManager } from '../../../managers/GradeInfoManager';
import { TcpGradeInfoParser } from '../parsers/TcpGradeInfoParser';
import { StGradeInfo } from '../types/StGradeInfo';
import { CommandHead } from '../types/StStatistics';

const DOMAIN = 0x0000;
const FSM_CMD_CONFIG = 0x0000; // 配置信息命令ID（需要确认实际值）

/**
 * 处理TCP接收的配置数据（FSM_CMD_CONFIG命令）
 * @param data TCP接收的原始字节数组
 */
export async function handleConfigData(data: Uint8Array): Promise<void> {
  try {
    console.log(`[ConfigDataHandler] 收到配置数据，长度: ${data.length} 字节`);
    
    // 检查是否为SYNC开头
    if (!TcpStatisticsParser.isSync(data)) {
      console.warn(`[ConfigDataHandler] 接收的数据不是以SYNC开头`);
      return;
    }
    
    console.log(`[ConfigDataHandler] 数据包以SYNC开头，开始解析...`);
    
    // 解析TCP数据包（命令头）
    const packet = TcpStatisticsParser.parseTcpPacket(data);
    if (!packet) {
      console.warn(`[ConfigDataHandler] 解析TCP数据包失败`);
      return;
    }
    
    console.log(`[ConfigDataHandler] TCP数据包解析成功 - 源ID: ${packet.commandHead.nSrcId}, 目标ID: ${packet.commandHead.nDstId}, 命令ID: ${packet.commandHead.nCmdId}, 数据体长度: ${packet.data.length}`);
    
    // 检查命令ID是否为配置信息命令
    // 注意：FSM_CMD_CONFIG的实际值需要根据48项目的定义确认
    // 这里暂时使用0x0000，实际应该从48项目的定义中获取
    if (packet.commandHead.nCmdId !== FSM_CMD_CONFIG) {
      console.warn(`[ConfigDataHandler] 收到非配置信息命令，命令ID: ${packet.commandHead.nCmdId}，期望: ${FSM_CMD_CONFIG}`);
      return;
    }
    
    // 获取子系统ID
    const subsysId = packet.commandHead.nSrcId;
    
    console.log(`[ConfigDataHandler] 开始解析StGlobal结构体（子系统ID: ${subsysId}）...`);
    
    // 解析StGlobal结构体中的grade字段
    // 注意：StGlobal结构体很大，包含sys, grade, gexit, gweight等多个字段
    // 这里我们只解析grade字段，需要知道grade在StGlobal中的偏移量
    // 为了简化，我们假设可以直接从数据中解析grade部分
    // 实际项目中需要根据StGlobal的完整结构定义来计算偏移量
    
    // 简化处理：假设grade字段在数据中的某个位置
    // 实际需要根据StGlobal的完整结构来计算偏移量
    const gradeOffset = TcpGradeInfoParser.getGradeOffset();
    const gradeInfo = TcpGradeInfoParser.parseStGradeInfo(packet.data, gradeOffset);
    
    console.log(`[ConfigDataHandler] StGradeInfo解析成功 - 子系统ID: ${subsysId}, 尺寸等级数: ${gradeInfo.nSizeGradeNum}, 品质等级数: ${gradeInfo.nQualityGradeNum}`);
    
    // 更新等级信息管理器
    const gradeInfoManager = GradeInfoManager.getInstance();
    gradeInfoManager.updateGradeInfo(subsysId, gradeInfo);
    
    console.log(`[ConfigDataHandler] 配置数据已更新到GradeInfoManager - 子系统ID: ${subsysId}`);
    
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error(`[ConfigDataHandler] 处理配置数据失败: ${errorMsg}`);
    if (error instanceof Error && error.stack) {
      console.error(`[ConfigDataHandler] 错误堆栈: ${error.stack}`);
    }
  }
}

