/**
 * 等级信息解析器
 * 功能：解析TCP接收的StGradeInfo二进制数据（从FSM_CMD_CONFIG命令的StGlobal.grade字段）
 */

import { StGradeInfo, StGradeItemInfo, createDefaultStGradeInfo } from '../types/StGradeInfo';
import { util } from '@kit.ArkTS';

// 常量定义
const MAX_QUALITY_GRADE_NUM = 8;
const MAX_SIZE_GRADE_NUM = 16;
const MAX_TEXT_LENGTH = 64;

/**
 * 解析StGradeInfo结构体
 * 注意：StGradeInfo是StGlobal的一部分，需要从StGlobal的grade字段中解析
 * 
 * @param data 二进制数据（StGlobal结构体的完整数据）
 * @param gradeOffset StGradeInfo在StGlobal中的偏移量（字节）
 * @returns StGradeInfo对象
 */
export class TcpGradeInfoParser {
  /**
   * 从StGlobal数据中解析StGradeInfo
   * 注意：这是一个简化版本，实际需要根据StGlobal的完整结构来计算偏移量
   * 为了简化，我们假设可以直接从数据中解析grade部分
   * 
   * @param data StGlobal的完整二进制数据
   * @param offset grade字段在StGlobal中的偏移量（字节）
   * @returns StGradeInfo对象
   */
  static parseStGradeInfo(data: Uint8Array, offset: number = 0): StGradeInfo {
    const gradeInfo = createDefaultStGradeInfo();
    const view = new DataView(data.buffer, data.byteOffset + offset);
    let pos = 0;
    
    try {
      // 注意：StGradeInfo结构体很大，包含很多字段
      // 这里我们只解析关键的字段：等级名称
      // 实际解析需要根据StGlobal的完整结构来计算偏移量
      
      // 由于StGlobal结构体非常复杂，我们采用简化的方式：
      // 假设等级名称在数据中的某个位置，或者从其他方式获取
      // 这里提供一个基础的解析框架
      
      // 解析尺寸等级名称
      // strSizeGradeName: quint8[MAX_SIZE_GRADE_NUM * MAX_TEXT_LENGTH]
      // 每个等级名称是MAX_TEXT_LENGTH字节的GBK编码字符串
      const sizeGradeNames: string[] = [];
      for (let i = 0; i < MAX_SIZE_GRADE_NUM; i++) {
        const nameBytes = new Uint8Array(data.buffer, data.byteOffset + offset + pos, MAX_TEXT_LENGTH);
        pos += MAX_TEXT_LENGTH;
        
        // 找到字符串结束位置（第一个0字节）
        let endPos = 0;
        for (let j = 0; j < MAX_TEXT_LENGTH; j++) {
          if (nameBytes[j] === 0) {
            endPos = j;
            break;
          }
        }
        
        if (endPos > 0) {
          // 提取有效字节并转换为字符串（假设是GBK编码，实际可能需要转换）
          const validBytes = nameBytes.slice(0, endPos);
          // 注意：这里简化处理，实际应该使用GBK到UTF-8的转换
          // 暂时使用TextDecoder，但可能需要指定GBK编码
          try {
            const decoder = new util.TextDecoder('utf-8', { fatal: false });
            const name = decoder.decodeWithStream(validBytes, { stream: false });
            sizeGradeNames.push(name || `尺寸${i + 1}`);
          } catch {
            // 如果解码失败，使用默认名称
            sizeGradeNames.push(`尺寸${i + 1}`);
          }
        } else {
          sizeGradeNames.push(`尺寸${i + 1}`);
        }
      }
      
      // 解析品质等级名称
      // strQualityGradeName: quint8[MAX_QUALITY_GRADE_NUM * MAX_TEXT_LENGTH]
      const qualityGradeNames: string[] = [];
      for (let i = 0; i < MAX_QUALITY_GRADE_NUM; i++) {
        const nameBytes = new Uint8Array(data.buffer, data.byteOffset + offset + pos, MAX_TEXT_LENGTH);
        pos += MAX_TEXT_LENGTH;
        
        let endPos = 0;
        for (let j = 0; j < MAX_TEXT_LENGTH; j++) {
          if (nameBytes[j] === 0) {
            endPos = j;
            break;
          }
        }
        
        if (endPos > 0) {
          const validBytes = nameBytes.slice(0, endPos);
          try {
            const decoder = new util.TextDecoder('utf-8', { fatal: false });
            const name = decoder.decodeWithStream(validBytes, { stream: false });
            qualityGradeNames.push(name || `品质${i + 1}`);
          } catch {
            qualityGradeNames.push(`品质${i + 1}`);
          }
        } else {
          qualityGradeNames.push(`品质${i + 1}`);
        }
      }
      
      gradeInfo.strSizeGradeName = sizeGradeNames;
      gradeInfo.strQualityGradeName = qualityGradeNames;
      
      // 解析其他字段（需要根据实际偏移量）
      // nSizeGradeNum, nQualityGradeNum, nClassifyType等
      // 这里简化处理，使用默认值或从数据中读取
      
      console.log(`[TcpGradeInfoParser] 解析StGradeInfo成功 - 尺寸等级数: ${sizeGradeNames.length}, 品质等级数: ${qualityGradeNames.length}`);
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[TcpGradeInfoParser] 解析StGradeInfo失败: ${errorMsg}`);
      throw new Error(`解析StGradeInfo失败: ${errorMsg}`);
    }
    
    return gradeInfo;
  }
  
  /**
   * 从StGlobal数据中提取grade字段的偏移量
   * 注意：这是一个简化版本，实际需要根据StGlobal的完整结构来计算
   * StGlobal结构体包含：sys, grade, gexit, gweight, analogdensity, exit[], paras[], weights[], motor[], cFSMInfo[], cIPMInfo[], nSubsysId, nVersion, nNetState, nFsmRestart, nFsmModule
   * 
   * @returns grade字段的偏移量（字节）
   */
  static getGradeOffset(): number {
    // 这是一个估算值，实际需要根据StGlobal的完整结构来计算
    // StSysConfig的大小 + 其他字段的大小
    // 为了简化，我们假设grade字段在某个固定位置
    // 实际项目中应该根据StGlobal的完整定义来计算
    
    // 简化处理：假设grade字段在StGlobal中的偏移量
    // 实际需要根据StGlobal的完整结构定义来计算
    return 0; // 这里需要根据实际情况计算
  }
}

