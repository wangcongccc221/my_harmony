#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TCP完整测试客户端 - 综合版
持续发送FSM_CMD_CONFIG和FSM_CMD_STATISTICS数据
用于测试HarmonyOS应用的TCP数据接收和处理功能
"""

import socket
import struct
import time
import random
import sys
import threading

# 常量定义
MAX_QUALITY_GRADE_NUM = 8
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 20
MAX_CHANNEL_NUM = 12
MAX_TEXT_LENGTH = 64

# TCP服务器配置
TCP_HOST = '127.0.0.1'
TCP_PORT = 8081

# 命令ID
FSM_CMD_CONFIG = 0x0000
FSM_CMD_STATISTICS = 0x0001

# SYNC字符串
SYNC_STRING = b'SYNC'

# 子系统ID和客户端ID
FSM_ID = 0x0001  # 下位机ID
HC_ID = 0x0000   # 上位机ID

# 等级名称
QUALITY_GRADE_NAMES = ['A级', 'B级', 'C级', 'D级', 'E级', 'F级', 'G级', 'H级']
SIZE_GRADE_NAMES = ['大', '中', '小', '特小']


def int32_to_bytes(value):
    """将int32转换为小端字节序的4字节"""
    return struct.pack('<i', value)


def uint32_to_bytes(value):
    """将uint32转换为小端字节序的4字节"""
    return struct.pack('<I', value)


def uint64_to_bytes(value):
    """将uint64转换为小端字节序的8字节"""
    return struct.pack('<Q', value)


def uint16_to_bytes(value):
    """将uint16转换为小端字节序的2字节"""
    return struct.pack('<H', value)


def uint8_to_bytes(value):
    """将uint8转换为1字节"""
    return struct.pack('<B', value)


def float_to_bytes(value):
    """将float转换为小端字节序的4字节"""
    return struct.pack('<f', value)


def string_to_bytes(text, max_length, encoding='utf-8'):
    """将字符串转换为指定编码的字节数组，并填充到指定长度（以0结尾）"""
    if isinstance(text, str):
        text_bytes = text.encode(encoding)
    else:
        text_bytes = text
    
    # 截断或填充
    if len(text_bytes) >= max_length:
        text_bytes = text_bytes[:max_length-1]
    
    # 填充0
    result = bytearray(max_length)
    result[:len(text_bytes)] = text_bytes
    return bytes(result)


def create_config_packet(subsys_id=0):
    """创建FSM_CMD_CONFIG数据包"""
    # 注意：这里只创建StGradeInfo部分，实际StGlobal结构体很大
    # 为了简化，我们创建一个最小化的配置数据包
    
    # StGradeInfo的基本结构（简化版）
    # 这里只包含等级名称等关键信息
    data = bytearray()
    
    # strSizeGradeName: MAX_SIZE_GRADE_NUM * MAX_TEXT_LENGTH
    for i in range(MAX_SIZE_GRADE_NUM):
        name = SIZE_GRADE_NAMES[i % len(SIZE_GRADE_NAMES)] if i < len(SIZE_GRADE_NAMES) else f'尺寸{i+1}'
        data.extend(string_to_bytes(name, MAX_TEXT_LENGTH))
    
    # strQualityGradeName: MAX_QUALITY_GRADE_NUM * MAX_TEXT_LENGTH
    for i in range(MAX_QUALITY_GRADE_NUM):
        name = QUALITY_GRADE_NAMES[i % len(QUALITY_GRADE_NAMES)] if i < len(QUALITY_GRADE_NAMES) else f'等级{i+1}'
        data.extend(string_to_bytes(name, MAX_TEXT_LENGTH))
    
    # nSizeGradeNum, nQualityGradeNum (使用uint8，1字节)
    data.extend(uint8_to_bytes(4))  # 4个尺寸等级
    data.extend(uint8_to_bytes(4))  # 4个品质等级
    
    # nClassifyType (1字节)
    data.extend(uint8_to_bytes(1))  # 1=重量(克)
    
    # 其他字段（简化处理，填充0）
    # 实际StGradeInfo结构体很大，这里只做示例
    # 为了测试，我们创建一个最小化的数据包
    # grades数组等字段暂时填充0
    grade_item_size = 80  # 估算值
    data.extend(b'\x00' * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM * grade_item_size))
    
    # 构造完整的数据包
    sync = SYNC_STRING
    command_head = int32_to_bytes(FSM_ID) + int32_to_bytes(HC_ID) + int32_to_bytes(FSM_CMD_CONFIG)
    
    # 注意：数据包格式是 SYNC + CommandHead + 数据体（不需要额外的data_length字段）
    packet = sync + command_head + bytes(data)
    
    return packet


def create_statistics_packet(subsys_id=0):
    """创建FSM_CMD_STATISTICS数据包"""
    data = bytearray()
    
    # 模拟等级数据
    grade_data = {
        'A级': {'count': random.randint(300, 500), 'weight': random.randint(150000, 250000), 'box_count': random.randint(8, 12), 'box_weight': random.randint(18000, 22000)},
        'B级': {'count': random.randint(200, 400), 'weight': random.randint(100000, 200000), 'box_count': random.randint(5, 10), 'box_weight': random.randint(18000, 22000)},
        'C级': {'count': random.randint(100, 300), 'weight': random.randint(50000, 150000), 'box_count': random.randint(3, 8), 'box_weight': random.randint(18000, 22000)},
        'D级': {'count': random.randint(50, 200), 'weight': random.randint(25000, 100000), 'box_count': random.randint(1, 5), 'box_weight': random.randint(18000, 22000)}
    }
    
    # 1. nGradeCount[128] - ulong数组，每个8字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(QUALITY_GRADE_NAMES) and size == 0:
                grade_name = QUALITY_GRADE_NAMES[quality]
                count = grade_data.get(grade_name, {}).get('count', 0) if grade_name in grade_data else 0
            else:
                count = 0
            data.extend(uint64_to_bytes(count))
    
    # 2. nWeightGradeCount[128] - ulong数组，每个8字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(QUALITY_GRADE_NAMES) and size == 0:
                grade_name = QUALITY_GRADE_NAMES[quality]
                weight = grade_data.get(grade_name, {}).get('weight', 0) if grade_name in grade_data else 0
            else:
                weight = 0
            data.extend(uint64_to_bytes(weight))
    
    # 3. nExitCount[20] - ulong数组，每个8字节
    exit_counts = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(QUALITY_GRADE_NAMES[:4]):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_counts[i] = grade_data[grade_name]['count']
    for count in exit_counts:
        data.extend(uint64_to_bytes(count))
    
    # 4. nExitWeightCount[20] - ulong数组，每个8字节
    exit_weights = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(QUALITY_GRADE_NAMES[:4]):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_weights[i] = grade_data[grade_name]['weight']
    for weight in exit_weights:
        data.extend(uint64_to_bytes(weight))
    
    # 5. nTotalCount - ulong，8字节
    total_count = sum(g['count'] for g in grade_data.values())
    data.extend(uint64_to_bytes(total_count))
    
    # 6. nWeightCount - ulong，8字节
    total_weight = sum(g['weight'] for g in grade_data.values())
    data.extend(uint64_to_bytes(total_weight))
    
    # 7. nSubsysId - int，4字节
    data.extend(int32_to_bytes(subsys_id))
    
    # 8. nBoxGradeCount[128] - int数组，每个4字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(QUALITY_GRADE_NAMES) and size == 0:
                grade_name = QUALITY_GRADE_NAMES[quality]
                box_count = grade_data.get(grade_name, {}).get('box_count', 0) if grade_name in grade_data else 0
            else:
                box_count = 0
            data.extend(int32_to_bytes(box_count))
    
    # 9. nBoxGradeWeight[128] - int数组，每个4字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(QUALITY_GRADE_NAMES) and size == 0:
                grade_name = QUALITY_GRADE_NAMES[quality]
                box_weight = grade_data.get(grade_name, {}).get('box_weight', 0) if grade_name in grade_data else 0
            else:
                box_weight = 0
            data.extend(int32_to_bytes(box_weight))
    
    # 10. nTotalCupNum - int，4字节
    total_cup_num = total_count + random.randint(0, 10)
    data.extend(int32_to_bytes(total_cup_num))
    
    # 11. nInterval - int，4字节
    data.extend(int32_to_bytes(0))
    
    # 12. nIntervalSumperminute - int，4字节（分选速度）
    sort_speed = random.randint(50, 100)  # 随机分选速度，模拟真实数据
    data.extend(int32_to_bytes(sort_speed))
    
    # 13. nCupState - ushort，2字节
    data.extend(uint16_to_bytes(0))  # 0=正常
    
    # 14. nPulseInterval - ushort，2字节
    pulse_interval = 800 + random.randint(0, 400)  # 随机脉冲间隔
    data.extend(uint16_to_bytes(pulse_interval))
    
    # 15. nUnpushFruitCount - ushort，2字节
    data.extend(uint16_to_bytes(0))
    
    # 16. nNetState - quint8，1字节
    data.extend(uint8_to_bytes(0))  # 0=正常
    
    # 17. nWeightSetting - quint8，1字节
    data.extend(uint8_to_bytes(1))  # 1=整定完毕
    
    # 18. nSCMState - quint8，1字节
    data.extend(uint8_to_bytes(0))  # 0=正常
    
    # 19. nIQSNetState - quint8，1字节
    data.extend(uint8_to_bytes(0))  # 0=正常
    
    # 20. nLockState - quint8，1字节
    data.extend(uint8_to_bytes(0))
    
    # 21. ExitBoxNum[20] - int数组，每个4字节
    exit_box_nums = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(QUALITY_GRADE_NAMES[:4]):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_box_nums[i] = grade_data[grade_name]['box_count']
    for box_num in exit_box_nums:
        data.extend(int32_to_bytes(box_num))
    
    # 22. fSelectBasisRange[16] - StRange数组，每个StRange包含2个float（8字节）
    for i in range(MAX_SIZE_GRADE_NUM):
        n_min = float(i * 10.0)
        n_max = float((i + 1) * 10.0)
        data.extend(float_to_bytes(n_min))
        data.extend(float_to_bytes(n_max))
    
    # 构造完整的数据包
    sync = SYNC_STRING
    command_head = int32_to_bytes(FSM_ID) + int32_to_bytes(HC_ID) + int32_to_bytes(FSM_CMD_STATISTICS)
    
    # 注意：数据包格式是 SYNC + CommandHead + 数据体（不需要额外的data_length字段）
    packet = sync + command_head + bytes(data)
    
    return packet


def send_packet(sock, packet, packet_type):
    """发送数据包"""
    try:
        sock.sendall(packet)
        print(f"[发送] {packet_type} - 数据长度: {len(packet)} 字节")
        return True
    except Exception as e:
        print(f"[错误] 发送{packet_type}失败: {e}")
        return False


def send_config_loop(sock, interval=5.0):
    """持续发送CONFIG数据"""
    print(f"[CONFIG] 开始发送配置数据，间隔: {interval}秒")
    packet_count = 0
    
    while True:
        try:
            packet = create_config_packet()
            if send_packet(sock, packet, f"CONFIG #{packet_count}"):
                packet_count += 1
            time.sleep(interval)
        except Exception as e:
            print(f"[CONFIG] 发送失败: {e}")
            time.sleep(interval)


def send_statistics_loop(sock, interval=1.0):
    """持续发送STATISTICS数据"""
    print(f"[STATISTICS] 开始发送统计数据，间隔: {interval}秒")
    packet_count = 0
    
    while True:
        try:
            packet = create_statistics_packet()
            if send_packet(sock, packet, f"STATISTICS #{packet_count}"):
                packet_count += 1
            time.sleep(interval)
        except Exception as e:
            print(f"[STATISTICS] 发送失败: {e}")
            time.sleep(interval)


def main():
    """主函数"""
    global TCP_HOST, TCP_PORT
    
    # 解析命令行参数
    host = TCP_HOST
    port = TCP_PORT
    if len(sys.argv) > 1:
        host = sys.argv[1]
    if len(sys.argv) > 2:
        port = int(sys.argv[2])
    
    print("=" * 60)
    print("TCP完整测试客户端 - 综合版".center(50))
    print("=" * 60)
    print(f"服务器地址: {host}:{port}")
    print(f"命令类型: FSM_CMD_CONFIG (0x{FSM_CMD_CONFIG:04X}) 和 FSM_CMD_STATISTICS (0x{FSM_CMD_STATISTICS:04X})")
    print("=" * 60)
    
    # 创建TCP连接
    sock = None
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))
        print(f"[成功] 已连接到服务器 {host}:{port}")
        
        # 启动两个线程分别发送CONFIG和STATISTICS数据
        config_thread = threading.Thread(target=send_config_loop, args=(sock, 5.0), daemon=True)
        statistics_thread = threading.Thread(target=send_statistics_loop, args=(sock, 1.0), daemon=True)
        
        config_thread.start()
        statistics_thread.start()
        
        print("\n[运行] 开始持续发送数据...")
        print("[提示] 按 Ctrl+C 停止\n")
        
        # 主线程保持运行
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n[停止] 收到停止信号，正在关闭连接...")
        
    except ConnectionRefusedError:
        print(f"[错误] 连接被拒绝。请确保HarmonyOS应用已启动TCP服务器并监听 {host}:{port}")
    except Exception as e:
        print(f"[错误] 连接失败: {e}")
    finally:
        if sock:
            sock.close()
            print("[关闭] TCP连接已关闭")


if __name__ == "__main__":
    main()

