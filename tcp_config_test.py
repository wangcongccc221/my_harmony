#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TCP配置测试客户端
用于模拟下位机向Harmony应用发送FSM_CMD_CONFIG配置数据（StGlobal结构体中的StGradeInfo）
用于测试动态等级表头功能
"""

import socket
import struct
import time

# 常量定义
MAX_QUALITY_GRADE_NUM = 8
MAX_SIZE_GRADE_NUM = 16
MAX_TEXT_LENGTH = 64  # 等级名称最大长度

# TCP服务器配置
TCP_HOST = '127.0.0.1'
TCP_PORT = 8081

# 命令ID
FSM_CMD_CONFIG = 0x0000  # 配置信息命令ID

# SYNC字符串
SYNC_STRING = b'SYNC'

# 子系统ID（FSM1=0, FSM2=1）
SUBSYS_ID = 0  # 默认使用FSM1


def int32_to_bytes(value):
    """将int32转换为小端字节序的4字节"""
    return struct.pack('<i', value)


def uint32_to_bytes(value):
    """将uint32转换为小端字节序的4字节"""
    return struct.pack('<I', value)


def uint8_to_bytes(value):
    """将uint8转换为1字节"""
    return struct.pack('<B', value)


def string_to_bytes(text, max_length, encoding='utf-8'):
    """
    将字符串转换为指定编码的字节数组，并填充到指定长度（以0结尾）
    @param text: 要转换的字符串
    @param max_length: 最大长度（字节数）
    @param encoding: 编码方式（默认utf-8，也可以使用gbk）
    @return: 字节数组
    """
    # 将字符串编码为指定编码
    try:
        encoded_bytes = text.encode(encoding)
    except UnicodeEncodeError:
        # 如果编码失败，使用UTF-8
        encoded_bytes = text.encode('utf-8')
    
    # 截断或填充到指定长度
    if len(encoded_bytes) >= max_length:
        result = encoded_bytes[:max_length-1] + b'\x00'  # 确保以0结尾
    else:
        result = encoded_bytes + b'\x00' * (max_length - len(encoded_bytes))
    
    return result


def create_st_grade_info_data(quality_grade_names=None, size_grade_names=None):
    """
    创建StGradeInfo结构体的二进制数据
    注意：这是一个简化版本，只包含等级名称部分
    实际StGradeInfo还包含grades数组等其他字段
    
    @param quality_grade_names: 品质等级名称列表（最多8个）
    @param size_grade_names: 尺寸等级名称列表（最多16个）
    @return: StGradeInfo的二进制数据
    """
    data = b''
    
    # 默认等级名称
    if quality_grade_names is None:
        quality_grade_names = ['特级', 'A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级']
    
    if size_grade_names is None:
        size_grade_names = ['特大', '大', '中', '小', '特小', '', '', '', '', '', '', '', '', '', '', '']
    
    # 1. strSizeGradeName: quint8[MAX_SIZE_GRADE_NUM * MAX_TEXT_LENGTH]
    # 16个尺寸等级名称，每个64字节
    for i in range(MAX_SIZE_GRADE_NUM):
        if i < len(size_grade_names):
            name = size_grade_names[i]
        else:
            name = ''
        data += string_to_bytes(name, MAX_TEXT_LENGTH, 'utf-8')
    
    # 2. strQualityGradeName: quint8[MAX_QUALITY_GRADE_NUM * MAX_TEXT_LENGTH]
    # 8个品质等级名称，每个64字节
    for i in range(MAX_QUALITY_GRADE_NUM):
        if i < len(quality_grade_names):
            name = quality_grade_names[i]
        else:
            name = ''
        data += string_to_bytes(name, MAX_TEXT_LENGTH, 'utf-8')
    
    # 3. nSizeGradeNum: quint8 (1字节)
    n_size_grade_num = len([n for n in size_grade_names if n.strip()])
    data += uint8_to_bytes(n_size_grade_num)
    
    # 4. nQualityGradeNum: quint8 (1字节)
    n_quality_grade_num = len([n for n in quality_grade_names if n.strip()])
    data += uint8_to_bytes(n_quality_grade_num)
    
    # 5. nClassifyType: quint8 (1字节)
    # 分选标准: 1=重量(克), 2=重量(个), 4=大小(直径), 8=大小(面积), 16=大小(体积)
    n_classify_type = 1  # 默认使用重量(克)
    data += uint8_to_bytes(n_classify_type)
    
    # 6. grades: StGradeItemInfo[MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM]
    # 128个等级项信息，每个包含多个字段
    # 为了简化，这里填充0（实际应该包含完整的等级配置信息）
    # 每个StGradeItemInfo大约包含多个字段，这里估算为约100字节
    # 实际大小需要根据StGradeItemInfo的完整定义来计算
    # 简化处理：假设每个StGradeItemInfo为80字节（需要根据实际结构调整）
    grade_item_size = 80  # 估算值，需要根据实际StGradeItemInfo结构调整
    data += b'\x00' * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM * grade_item_size)
    
    return data


def create_st_global_data(quality_grade_names=None, size_grade_names=None, subsys_id=0):
    """
    创建StGlobal结构体的二进制数据
    注意：这是一个简化版本，只包含grade字段部分
    实际StGlobal还包含sys, gexit, gweight等其他字段
    
    由于TcpGradeInfoParser.getGradeOffset()返回0，我们假设grade字段在数据体的开始位置
    为了简化测试，我们直接发送StGradeInfo的数据
    
    @param quality_grade_names: 品质等级名称列表
    @param size_grade_names: 尺寸等级名称列表
    @param subsys_id: 子系统ID
    @return: StGlobal的二进制数据（简化版，只包含grade部分）
    """
    # 直接返回StGradeInfo的数据
    # 实际项目中，StGlobal可能包含其他字段在grade之前
    return create_st_grade_info_data(quality_grade_names, size_grade_names)


def create_config_packet(quality_grade_names=None, size_grade_names=None, subsys_id=0, dst_id=1):
    """
    创建完整的配置数据包
    格式：SYNC(4字节) + CommandHead(12字节) + StGlobal数据体
    
    @param quality_grade_names: 品质等级名称列表
    @param size_grade_names: 尺寸等级名称列表
    @param subsys_id: 源子系统ID（FSM1=0, FSM2=1）
    @param dst_id: 目标ID（HC=1）
    @return: 完整的数据包
    """
    # 1. SYNC字符串（4字节）
    packet = SYNC_STRING
    
    # 2. CommandHead（12字节）
    # 源ID（4字节，小端）
    packet += int32_to_bytes(subsys_id)
    # 目标ID（4字节，小端）
    packet += int32_to_bytes(dst_id)
    # 命令ID（4字节，小端）
    packet += int32_to_bytes(FSM_CMD_CONFIG)
    
    # 3. StGlobal数据体
    st_global_data = create_st_global_data(quality_grade_names, size_grade_names, subsys_id)
    packet += st_global_data
    
    return packet


def send_config_data(quality_grade_names=None, size_grade_names=None, subsys_id=0):
    """
    发送配置数据到Harmony应用
    
    @param quality_grade_names: 品质等级名称列表
    @param size_grade_names: 尺寸等级名称列表
    @param subsys_id: 子系统ID
    """
    try:
        # 创建TCP连接
        print(f'正在连接到 {TCP_HOST}:{TCP_PORT}...')
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect((TCP_HOST, TCP_PORT))
        print('连接成功！')
        
        # 创建配置数据包
        packet = create_config_packet(quality_grade_names, size_grade_names, subsys_id)
        
        print(f'\n数据包大小: {len(packet)} 字节')
        print(f'  - SYNC: 4 字节')
        print(f'  - 命令头: 12 字节')
        print(f'  - 数据体: {len(packet) - 16} 字节')
        
        # 发送数据
        print('\n正在发送配置数据...')
        sock.sendall(packet)
        print('配置数据发送成功！')
        
        # 显示发送的等级名称
        print('\n发送的等级配置:')
        if quality_grade_names:
            print('  品质等级名称:')
            for i, name in enumerate(quality_grade_names):
                if name.strip():
                    print(f'    [{i}] {name}')
        
        if size_grade_names:
            print('  尺寸等级名称:')
            for i, name in enumerate(size_grade_names):
                if name.strip():
                    print(f'    [{i}] {name}')
        
        # 关闭连接
        sock.close()
        print('\n连接已关闭')
        
    except socket.error as e:
        print(f'❌ 连接错误: {e}')
    except Exception as e:
        print(f'❌ 发送数据失败: {e}')
        import traceback
        traceback.print_exc()


def main():
    """主函数"""
    print('=' * 60)
    print('TCP配置测试客户端 - 动态等级表头测试')
    print('=' * 60)
    print()
    
    # 测试1: 发送默认等级名称
    print('【测试1】发送默认等级配置...')
    send_config_data(
        quality_grade_names=['特级', 'A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级'],
        size_grade_names=['特大', '大', '中', '小', '特小'],
        subsys_id=0
    )
    
    time.sleep(2)
    
    # 测试2: 发送自定义等级名称
    print('\n' + '=' * 60)
    print('【测试2】发送自定义等级配置...')
    send_config_data(
        quality_grade_names=['优等', '一等', '二等', '三等', '等外'],
        size_grade_names=['超大', '大果', '中果', '小果'],
        subsys_id=0
    )
    
    time.sleep(2)
    
    # 测试3: 发送英文等级名称
    print('\n' + '=' * 60)
    print('【测试3】发送英文等级配置...')
    send_config_data(
        quality_grade_names=['Premium', 'Grade A', 'Grade B', 'Grade C', 'Grade D'],
        size_grade_names=['Extra Large', 'Large', 'Medium', 'Small'],
        subsys_id=0
    )
    
    print('\n' + '=' * 60)
    print('所有测试完成！')
    print('=' * 60)


if __name__ == '__main__':
    main()

