#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TCP等级表和等级统计表测试客户端
专门用于测试等级表和等级统计表的数据更新
"""

import socket
import struct
import time
import random

# 常量定义
MAX_QUALITY_GRADE_NUM = 8
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 20

# TCP服务器配置
TCP_HOST = '127.0.0.1'
TCP_PORT = 8081

# 命令ID
FSM_CMD_STATISTICS = 0x0001

# SYNC字符串
SYNC_STRING = b'SYNC'

# 等级名称（对应前4个品质等级）
GRADE_NAMES = ['A级', 'B级', 'C级', 'D级']


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
    return struct.pack('B', value)


def float32_to_bytes(value):
    """将float32转换为小端字节序的4字节"""
    return struct.pack('<f', value)


def create_grade_statistics_data(subsys_id=0, grade_data=None):
    """
    创建StStatistics结构体的二进制数据，专门用于测试等级表和等级统计表
    
    Args:
        subsys_id: 子系统ID (0=FSM1, 1=FSM2)
        grade_data: 等级数据字典，格式: {
            'A级': {'count': 400, 'weight': 200000, 'box_count': 10, 'box_weight': 20000},
            'B级': {'count': 300, 'weight': 150000, 'box_count': 8, 'box_weight': 18750},
            ...
        }
        如果不提供，将使用默认数据
    
    Returns:
        bytes: StStatistics结构体的二进制数据
    """
    data = b''
    
    # 默认等级数据（如果未提供）
    if grade_data is None:
        grade_data = {
            'A级': {'count': 400, 'weight': 200000, 'box_count': 10, 'box_weight': 20000},
            'B级': {'count': 300, 'weight': 150000, 'box_count': 8, 'box_weight': 18750},
            'C级': {'count': 200, 'weight': 100000, 'box_count': 5, 'box_weight': 20000},
            'D级': {'count': 100, 'weight': 50000, 'box_count': 2, 'box_weight': 25000}
        }
    
    # 计算总个数和总重量
    total_count = sum(g['count'] for g in grade_data.values())
    total_weight = sum(g['weight'] for g in grade_data.values())
    
    # 1. nGradeCount[128] - ulong数组，每个8字节
    # 假设每个品质等级有4个尺寸等级，我们只使用第一个尺寸等级的数据
    grade_counts = []
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(GRADE_NAMES) and size == 0:
                # 前4个品质等级的第一个尺寸等级有数据
                grade_name = GRADE_NAMES[quality]
                if grade_name in grade_data:
                    count = grade_data[grade_name]['count']
                else:
                    count = 0
            else:
                count = 0
            grade_counts.append(count)
            data += uint64_to_bytes(count)
    
    # 2. nWeightGradeCount[128] - ulong数组，每个8字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(GRADE_NAMES) and size == 0:
                # 前4个品质等级的第一个尺寸等级有数据
                grade_name = GRADE_NAMES[quality]
                if grade_name in grade_data:
                    weight = grade_data[grade_name]['weight']
                else:
                    weight = 0
            else:
                weight = 0
            data += uint64_to_bytes(weight)
    
    # 3. nExitCount[20] - ulong数组，每个8字节
    # 将等级数据分配到不同出口（前4个出口对应前4个等级）
    exit_counts = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(GRADE_NAMES):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_counts[i] = grade_data[grade_name]['count']
    for count in exit_counts:
        data += uint64_to_bytes(count)
    
    # 4. nExitWeightCount[20] - ulong数组，每个8字节
    exit_weights = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(GRADE_NAMES):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_weights[i] = grade_data[grade_name]['weight']
    for weight in exit_weights:
        data += uint64_to_bytes(weight)
    
    # 5. nTotalCount - ulong，8字节
    data += uint64_to_bytes(total_count)
    
    # 6. nWeightCount - ulong，8字节
    data += uint64_to_bytes(total_weight)
    
    # 7. nSubsysId - int，4字节
    data += int32_to_bytes(subsys_id)
    
    # 8. nBoxGradeCount[128] - int数组，每个4字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(GRADE_NAMES) and size == 0:
                grade_name = GRADE_NAMES[quality]
                if grade_name in grade_data:
                    box_count = grade_data[grade_name]['box_count']
                else:
                    box_count = 0
            else:
                box_count = 0
            data += int32_to_bytes(box_count)
    
    # 9. nBoxGradeWeight[128] - int数组，每个4字节
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < len(GRADE_NAMES) and size == 0:
                grade_name = GRADE_NAMES[quality]
                if grade_name in grade_data:
                    box_weight = grade_data[grade_name]['box_weight']
                else:
                    box_weight = 0
            else:
                box_weight = 0
            data += int32_to_bytes(box_weight)
    
    # 10. nTotalCupNum - int，4字节
    total_cup_num = total_count + random.randint(0, 10)  # 果杯数略大于总数
    data += int32_to_bytes(total_cup_num)
    
    # 11. nInterval - int，4字节
    data += int32_to_bytes(0)
    
    # 12. nIntervalSumperminute - int，4字节（分选速度）
    # 根据总个数估算分选速度（假设每分钟60个）
    sort_speed = 60
    data += int32_to_bytes(sort_speed)
    
    # 13. nCupState - ushort，2字节
    data += uint16_to_bytes(0)  # 0=正常
    
    # 14. nPulseInterval - ushort，2字节
    pulse_interval = 1000
    data += uint16_to_bytes(pulse_interval)
    
    # 15. nUnpushFruitCount - ushort，2字节
    data += uint16_to_bytes(0)
    
    # 16. nNetState - quint8，1字节
    data += uint8_to_bytes(0)  # 0=正常
    
    # 17. nWeightSetting - quint8，1字节
    data += uint8_to_bytes(1)  # 1=整定完毕
    
    # 18. nSCMState - quint8，1字节
    data += uint8_to_bytes(0)  # 0=正常
    
    # 19. nIQSNetState - quint8，1字节
    data += uint8_to_bytes(0)  # 0=正常
    
    # 20. nLockState - quint8，1字节
    data += uint8_to_bytes(0)
    
    # 21. ExitBoxNum[20] - int数组，每个4字节
    exit_box_nums = [0] * MAX_EXIT_NUM
    for i, grade_name in enumerate(GRADE_NAMES):
        if i < MAX_EXIT_NUM and grade_name in grade_data:
            exit_box_nums[i] = grade_data[grade_name]['box_count']
    for box_num in exit_box_nums:
        data += int32_to_bytes(box_num)
    
    # 22. fSelectBasisRange[16] - StRange数组，每个StRange包含2个float（8字节）
    for i in range(MAX_SIZE_GRADE_NUM):
        n_min = float(i * 10.0)  # 最小值
        n_max = float((i + 1) * 10.0)  # 最大值
        data += float32_to_bytes(n_min)
        data += float32_to_bytes(n_max)
    
    return data, grade_data, total_count, total_weight


def create_tcp_packet(subsys_id=0, dst_id=1, cmd_id=FSM_CMD_STATISTICS, statistics_data=None):
    """
    创建完整的TCP数据包
    
    Args:
        subsys_id: 源ID（子系统ID）
        dst_id: 目标ID（上位机ID，通常为1）
        cmd_id: 命令ID
        statistics_data: StStatistics结构体的二进制数据
    
    Returns:
        bytes: 完整的TCP数据包
    """
    # SYNC字符串（4字节）
    packet = SYNC_STRING
    
    # 命令头（12字节）
    # 源ID（4字节，小端）
    packet += int32_to_bytes(subsys_id)
    # 目标ID（4字节，小端）
    packet += int32_to_bytes(dst_id)
    # 命令ID（4字节，小端）
    packet += int32_to_bytes(cmd_id)
    
    # 数据体
    if statistics_data:
        packet += statistics_data
    
    return packet


def send_grade_test_data(host=TCP_HOST, port=TCP_PORT, subsys_id=0, grade_data=None):
    """
    发送等级测试数据到TCP服务器
    
    Args:
        host: 服务器地址
        port: 服务器端口
        subsys_id: 子系统ID
        grade_data: 等级数据字典
    """
    try:
        # 创建TCP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        
        print(f"正在连接到 {host}:{port}...")
        sock.connect((host, port))
        print(f"连接成功！")
        
        # 创建统计数据
        statistics_data, actual_grade_data, total_count, total_weight = create_grade_statistics_data(
            subsys_id=subsys_id,
            grade_data=grade_data
        )
        
        # 创建TCP数据包
        packet = create_tcp_packet(
            subsys_id=subsys_id,
            dst_id=1,
            cmd_id=FSM_CMD_STATISTICS,
            statistics_data=statistics_data
        )
        
        expected_body_size = (
            8 * 128 +  # nGradeCount[128]
            8 * 128 +  # nWeightGradeCount[128]
            8 * 20 +   # nExitCount[20]
            8 * 20 +   # nExitWeightCount[20]
            8 +        # nTotalCount
            8 +        # nWeightCount
            4 +        # nSubsysId
            4 * 128 +  # nBoxGradeCount[128]
            4 * 128 +  # nBoxGradeWeight[128]
            4 +        # nTotalCupNum
            4 +        # nInterval
            4 +        # nIntervalSumperminute
            2 +        # nCupState
            2 +        # nPulseInterval
            2 +        # nUnpushFruitCount
            1 +        # nNetState
            1 +        # nWeightSetting
            1 +        # nSCMState
            1 +        # nIQSNetState
            1 +        # nLockState
            4 * 20 +   # ExitBoxNum[20]
            8 * 16     # fSelectBasisRange[16]
        )
        
        print(f"\n数据包大小: {len(packet)} 字节")
        print(f"  - SYNC: 4 字节")
        print(f"  - 命令头: 12 字节")
        print(f"  - 数据体: {len(statistics_data)} 字节 (期望: {expected_body_size} 字节)")
        
        if len(statistics_data) != expected_body_size:
            print(f"⚠️  警告: 数据体大小不匹配！实际: {len(statistics_data)}, 期望: {expected_body_size}")
        
        # 发送数据
        print(f"\n正在发送数据...")
        sock.sendall(packet)
        print(f"数据发送成功！")
        
        # 显示等级数据摘要
        print(f"\n{'='*60}")
        print(f"📊 等级表和等级统计表数据摘要")
        print(f"{'='*60}")
        print(f"\n总体数据:")
        print(f"  - 子系统ID: {subsys_id}")
        print(f"  - 总个数: {total_count}")
        print(f"  - 总重量: {total_weight} 克 ({total_weight/1000.0:.2f} kg)")
        print(f"  - 平均果重: {total_weight/total_count:.2f} 克" if total_count > 0 else "  - 平均果重: 0 克")
        
        print(f"\n等级表数据（格式: [等级名称, 重量(kg), 重量百分比, 个数, 个数百分比]）:")
        for grade_name in GRADE_NAMES:
            if grade_name in actual_grade_data:
                g = actual_grade_data[grade_name]
                count = g['count']
                weight = g['weight']
                count_percent = (count / total_count * 100) if total_count > 0 else 0
                weight_percent = (weight / total_weight * 100) if total_weight > 0 else 0
                print(f"  - {grade_name}:")
                print(f"     重量: {weight/1000.0:.2f} kg ({weight_percent:.2f}%)")
                print(f"     个数: {count} 个 ({count_percent:.2f}%)")
        
        print(f"\n等级统计表数据（格式: [等级名称, 重量(kg), 出口, 个数, 个数百分比, 重量(kg), 重量百分比, 箱数, 箱数百分比, 每箱重(kg), 平均重量(kg)]）:")
        for i, grade_name in enumerate(GRADE_NAMES):
            if grade_name in actual_grade_data:
                g = actual_grade_data[grade_name]
                count = g['count']
                weight = g['weight']
                box_count = g['box_count']
                box_weight = g['box_weight']
                count_percent = (count / total_count * 100) if total_count > 0 else 0
                weight_percent = (weight / total_weight * 100) if total_weight > 0 else 0
                box_percent = (box_count / sum(gg['box_count'] for gg in actual_grade_data.values()) * 100) if sum(gg['box_count'] for gg in actual_grade_data.values()) > 0 else 0
                avg_weight = (weight / count / 1000.0) if count > 0 else 0
                print(f"  - {grade_name}:")
                print(f"     重量: {weight/1000.0:.2f} kg ({weight_percent:.2f}%)")
                print(f"     出口: 出口{i+1}")
                print(f"     个数: {count} 个 ({count_percent:.2f}%)")
                print(f"     箱数: {box_count} 箱 ({box_percent:.2f}%)")
                print(f"     每箱重: {box_weight/1000.0:.2f} kg")
                print(f"     平均重量: {avg_weight:.2f} kg")
        
        # 关闭连接
        sock.close()
        print(f"\n连接已关闭")
        
    except socket.timeout:
        print(f"错误: 连接超时，请确保服务器正在运行")
    except ConnectionRefusedError:
        print(f"错误: 连接被拒绝，请确保服务器正在监听 {host}:{port}")
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()


def send_continuous_grade_data(host=TCP_HOST, port=TCP_PORT, subsys_id=0, 
                               interval=3, count=10):
    """
    持续发送等级测试数据（模拟实时数据更新）
    
    Args:
        host: 服务器地址
        port: 服务器端口
        subsys_id: 子系统ID
        interval: 发送间隔（秒）
        count: 发送次数
    """
    print(f"开始持续发送等级测试数据，间隔 {interval} 秒，共 {count} 次\n")
    
    # 初始等级数据
    base_grade_data = {
        'A级': {'count': 400, 'weight': 200000, 'box_count': 10, 'box_weight': 20000},
        'B级': {'count': 300, 'weight': 150000, 'box_count': 8, 'box_weight': 18750},
        'C级': {'count': 200, 'weight': 100000, 'box_count': 5, 'box_weight': 20000},
        'D级': {'count': 100, 'weight': 50000, 'box_count': 2, 'box_weight': 25000}
    }
    
    # 每次递增的值（模拟interval秒内的增量）
    # 假设分选速度是60个/分钟，那么每3秒大约处理3个
    count_increment_per_grade = max(1, int(60 * interval / 60 / 4))  # 平均分配到4个等级
    weight_increment_per_grade = count_increment_per_grade * 500  # 假设每个水果平均500克
    
    # 当前累计值（用于累加）
    current_grade_data = {}
    for grade_name, data in base_grade_data.items():
        current_grade_data[grade_name] = {
            'count': data['count'],
            'weight': data['weight'],
            'box_count': data['box_count'],
            'box_weight': data['box_weight']
        }
    
    print(f"数据递增配置:")
    print(f"  - 每个等级每次增加个数: {count_increment_per_grade} 个")
    print(f"  - 每个等级每次增加重量: {weight_increment_per_grade} 克 ({weight_increment_per_grade/1000.0:.2f} kg)")
    print(f"  - 总增量: {count_increment_per_grade * 4} 个/次, {weight_increment_per_grade * 4} 克/次\n")
    
    for i in range(count):
        print(f"\n{'='*60}")
        print(f"--- 第 {i+1}/{count} 次发送 ---")
        print(f"{'='*60}")
        
        # 累加数据（模拟实时数据更新，数据应该是累加的）
        for grade_name in current_grade_data:
            current_grade_data[grade_name]['count'] += count_increment_per_grade
            current_grade_data[grade_name]['weight'] += weight_increment_per_grade
            # 箱数也相应增加（每20个水果一箱）
            if current_grade_data[grade_name]['count'] % 20 == 0:
                current_grade_data[grade_name]['box_count'] += 1
        
        # 计算总数据
        total_count = sum(g['count'] for g in current_grade_data.values())
        total_weight = sum(g['weight'] for g in current_grade_data.values())
        
        print(f"📊 累计数据: 总个数={total_count}, 总重量={total_weight/1000.0:.2f}kg")
        print(f"📈 本次增量: +{count_increment_per_grade * 4}个, +{weight_increment_per_grade * 4/1000.0:.2f}kg")
        
        send_grade_test_data(
            host=host,
            port=port,
            subsys_id=subsys_id,
            grade_data=current_grade_data.copy()  # 使用副本，避免修改原数据
        )
        
        if i < count - 1:
            print(f"\n等待 {interval} 秒后发送下一次...")
            time.sleep(interval)


if __name__ == '__main__':
    import sys
    
    print("=" * 60)
    print("TCP等级表和等级统计表测试客户端")
    print("=" * 60)
    print(f"目标服务器: {TCP_HOST}:{TCP_PORT}\n")
    
    if len(sys.argv) > 1:
        mode = sys.argv[1]
        
        if mode == 'continuous':
            # 持续发送模式
            interval = int(sys.argv[2]) if len(sys.argv) > 2 else 3
            count = int(sys.argv[3]) if len(sys.argv) > 3 else 10
            subsys_id = int(sys.argv[4]) if len(sys.argv) > 4 else 0
            
            send_continuous_grade_data(
                host=TCP_HOST,
                port=TCP_PORT,
                subsys_id=subsys_id,
                interval=interval,
                count=count
            )
        elif mode == 'custom':
            # 自定义等级数据模式
            # 格式: python tcp_grade_test.py custom A级:400:200000:10:20000 B级:300:150000:8:18750 ...
            subsys_id = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 0
            grade_data = {}
            
            for arg in sys.argv[3:]:
                # 解析格式: 等级名称:个数:重量:箱数:每箱重
                parts = arg.split(':')
                if len(parts) == 5:
                    grade_name = parts[0]
                    grade_data[grade_name] = {
                        'count': int(parts[1]),
                        'weight': int(parts[2]),
                        'box_count': int(parts[3]),
                        'box_weight': int(parts[4])
                    }
            
            if grade_data:
                send_grade_test_data(
                    host=TCP_HOST,
                    port=TCP_PORT,
                    subsys_id=subsys_id,
                    grade_data=grade_data
                )
            else:
                print("错误: 未提供有效的等级数据")
                print("格式: 等级名称:个数:重量:箱数:每箱重")
                print("示例: A级:400:200000:10:20000")
        else:
            # 单次发送模式（使用默认数据）
            subsys_id = int(sys.argv[1]) if sys.argv[1].isdigit() else 0
            send_grade_test_data(
                host=TCP_HOST,
                port=TCP_PORT,
                subsys_id=subsys_id
            )
    else:
        # 默认：发送一次测试数据
        print("使用说明:")
        print("  单次发送（默认数据）: python tcp_grade_test.py [subsys_id]")
        print("  持续发送: python tcp_grade_test.py continuous [interval] [count] [subsys_id]")
        print("  自定义数据: python tcp_grade_test.py custom [subsys_id] 等级名称:个数:重量:箱数:每箱重 ...")
        print("\n示例:")
        print("  python tcp_grade_test.py                    # 发送默认等级测试数据")
        print("  python tcp_grade_test.py 0                  # 发送子系统0的默认数据")
        print("  python tcp_grade_test.py continuous 3 10 0  # 每3秒发送一次，共10次")
        print("  python tcp_grade_test.py custom 0 A级:500:250000:12:20833 B级:400:200000:10:20000")
        print("\n默认等级数据:")
        print("  - A级: 400个, 200kg, 10箱, 20kg/箱")
        print("  - B级: 300个, 150kg, 8箱, 18.75kg/箱")
        print("  - C级: 200个, 100kg, 5箱, 20kg/箱")
        print("  - D级: 100个, 50kg, 2箱, 25kg/箱")
        print("\n开始发送默认等级测试数据...\n")
        
        send_grade_test_data(
            host=TCP_HOST,
            port=TCP_PORT,
            subsys_id=0
        )

