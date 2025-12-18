#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TCP测试客户端
用于模拟下位机向Harmony应用发送StStatistics统计数据
"""

import socket
import struct
import time
import random

# 常量定义
MAX_QUALITY_GRADE_NUM = 8
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 20
MAX_CHANNEL_NUM = 12

# TCP服务器配置
TCP_HOST = '127.0.0.1'
TCP_PORT = 8081

# 命令ID
FSM_CMD_STATISTICS = 0x0001

# SYNC字符串
SYNC_STRING = b'SYNC'


def int32_to_bytes(value):
    """将int32转换为小端字节序的4字节"""
    return struct.pack('<i', value)


def uint32_to_bytes(value):
    """将uint32转换为小端字节序的4字节"""
    return struct.pack('<I', value)


def int64_to_bytes(value):
    """将int64转换为小端字节序的8字节"""
    return struct.pack('<q', value)


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


def create_statistics_data(subsys_id=0, total_count=1000, total_weight=500000, 
                          sort_speed=60, pulse_interval=1000):
    """
    创建StStatistics结构体的二进制数据
    
    Args:
        subsys_id: 子系统ID (0=FSM1, 1=FSM2)
        total_count: 总个数
        total_weight: 总重量（克）
        sort_speed: 分选速度（个/分钟）
        pulse_interval: 脉冲间隔（ms）
    
    Returns:
        bytes: StStatistics结构体的二进制数据
    """
    data = b''
    
    # 计算平均果重（克）
    avg_fruit_weight = total_weight / total_count if total_count > 0 else 150
    
    # 1. nGradeCount[128] - ulong数组，每个8字节
    # 生成更真实的等级分布数据，用于饼图显示
    # 前4个品质等级（每个品质等级有16个尺寸等级）
    # 品质0（优质）: 占比约35%
    # 品质1（良好）: 占比约30%
    # 品质2（一般）: 占比约25%
    # 品质3（较差）: 占比约10%
    grade_counts = []
    quality_distribution = [0.35, 0.30, 0.25, 0.10]  # 4个品质等级的占比
    
    for quality in range(MAX_QUALITY_GRADE_NUM):
        for size in range(MAX_SIZE_GRADE_NUM):
            if quality < 4:
                # 前4个品质等级有数据，按占比分配
                base_count = int(total_count * quality_distribution[quality] / MAX_SIZE_GRADE_NUM)
                # 添加一些随机变化
                count = max(0, base_count + random.randint(-base_count//10, base_count//10))
            else:
                count = 0
            grade_counts.append(count)
            data += uint64_to_bytes(count)
    
    # 2. nWeightGradeCount[128] - ulong数组，每个8字节
    # 根据等级个数和平均重量计算
    for i in range(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM):
        weight = int(grade_counts[i] * avg_fruit_weight) if i < len(grade_counts) else 0
        data += uint64_to_bytes(weight)
    
    # 3. nExitCount[20] - ulong数组，每个8字节
    # 生成更真实的出口分布数据（前8个出口有数据，用于柱状图显示）
    exit_counts = []
    remaining_count = total_count
    
    for i in range(MAX_EXIT_NUM):
        if i < 8:
            # 前8个出口有数据，按递减分布
            if i < 7:
                # 前7个出口按比例分配
                ratio = (8 - i) / 36.0  # 8+7+6+5+4+3+2 = 36
                count = int(total_count * ratio * random.uniform(0.8, 1.2))
                count = min(count, remaining_count)
                remaining_count -= count
            else:
                # 最后一个出口分配剩余
                count = remaining_count
        else:
            count = 0
        exit_counts.append(count)
        data += uint64_to_bytes(count)
    
    # 4. nExitWeightCount[20] - ulong数组，每个8字节
    # 根据出口个数和平均重量计算
    for i in range(MAX_EXIT_NUM):
        weight = int(exit_counts[i] * avg_fruit_weight) if i < len(exit_counts) else 0
        data += uint64_to_bytes(weight)
    
    # 5. nTotalCount - ulong，8字节
    data += uint64_to_bytes(total_count)
    
    # 6. nWeightCount - ulong，8字节
    data += uint64_to_bytes(total_weight)
    
    # 7. nSubsysId - int，4字节
    data += int32_to_bytes(subsys_id)
    
    # 8. nBoxGradeCount[128] - int数组，每个4字节
    for i in range(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM):
        box_count = random.randint(0, 10) if i < 4 else 0
        data += int32_to_bytes(box_count)
    
    # 9. nBoxGradeWeight[128] - int数组，每个4字节
    for i in range(MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM):
        box_weight = random.randint(0, 20000) if i < 4 else 0  # 每箱重量（克）
        data += int32_to_bytes(box_weight)
    
    # 10. nTotalCupNum - int，4字节
    # 果杯数应该略大于总数（因为可能有遗漏的）
    # 为了计算效率，果杯数应该比总数多5-10%
    cup_overflow = int(total_count * 0.05) + random.randint(0, 10)
    total_cup_num = total_count + cup_overflow
    data += int32_to_bytes(total_cup_num)
    
    # 11. nInterval - int，4字节
    data += int32_to_bytes(0)
    
    # 12. nIntervalSumperminute - int，4字节（分选速度）
    data += int32_to_bytes(sort_speed)
    
    # 13. nCupState - ushort，2字节
    data += uint16_to_bytes(0)  # 0=正常
    
    # 14. nPulseInterval - ushort，2字节
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
    for i in range(MAX_EXIT_NUM):
        box_num = random.randint(0, 5) if i < 5 else 0
        data += int32_to_bytes(box_num)
    
    # 22. fSelectBasisRange[16] - StRange数组，每个StRange包含2个float（8字节）
    for i in range(MAX_SIZE_GRADE_NUM):
        n_min = float(i * 10.0)  # 最小值
        n_max = float((i + 1) * 10.0)  # 最大值
        data += float32_to_bytes(n_min)
        data += float32_to_bytes(n_max)
    
    return data


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
    else:
        # 如果没有提供数据，创建默认数据
        packet += create_statistics_data(subsys_id)
    
    return packet


def send_test_data(host=TCP_HOST, port=TCP_PORT, subsys_id=0, 
                   total_count=1000, total_weight=500000, 
                   sort_speed=60, pulse_interval=1000):
    """
    发送测试数据到TCP服务器
    
    Args:
        host: 服务器地址
        port: 服务器端口
        subsys_id: 子系统ID
        total_count: 总个数
        total_weight: 总重量（克）
        sort_speed: 分选速度（个/分钟）
        pulse_interval: 脉冲间隔（ms）
    """
    try:
        # 创建TCP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        
        print(f"正在连接到 {host}:{port}...")
        sock.connect((host, port))
        print(f"连接成功！")
        
        # 创建统计数据
        statistics_data = create_statistics_data(
            subsys_id=subsys_id,
            total_count=total_count,
            total_weight=total_weight,
            sort_speed=sort_speed,
            pulse_interval=pulse_interval
        )
        
        # 计算果杯数（用于显示）
        cup_overflow = int(total_count * 0.05) + random.randint(0, 10)
        total_cup_num = total_count + cup_overflow
        
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
        
        print(f"数据包大小: {len(packet)} 字节")
        print(f"  - SYNC: 4 字节")
        print(f"  - 命令头: 12 字节")
        print(f"  - 数据体: {len(statistics_data)} 字节 (期望: {expected_body_size} 字节)")
        
        if len(statistics_data) != expected_body_size:
            print(f"⚠️  警告: 数据体大小不匹配！实际: {len(statistics_data)}, 期望: {expected_body_size}")
        
        # 发送数据
        print(f"\n正在发送数据...")
        sock.sendall(packet)
        print(f"数据发送成功！")
        
        print(f"\n发送的数据摘要:")
        print(f"  - 子系统ID: {subsys_id}")
        print(f"  - 总个数: {total_count}")
        print(f"  - 总重量: {total_weight} 克 ({total_weight/1000.0:.2f} kg)")
        print(f"  - 平均果重: {total_weight/total_count:.2f} 克" if total_count > 0 else "  - 平均果重: 0 克")
        print(f"  - 分选速度: {sort_speed} 个/分钟")
        print(f"  - 脉冲间隔: {pulse_interval} ms")
        
        # 计算果杯数（用于显示）
        cup_overflow = int(total_count * 0.05) + random.randint(0, 10)
        total_cup_num = total_count + cup_overflow
        print(f"  - 果杯数: {total_cup_num} (略大于总个数)")
        
        # 计算预期的实时产量（用于验证）
        # 注意：应用使用增量计算，第一次发送时previous=0，会导致计算错误
        # 这里显示的是基于分选速度的理论产量
        if total_count > 0:
            avg_weight_kg = (total_weight / total_count) / 1000.0  # 平均果重（kg）
            # 实时产量 = 分选速度（个/分钟） * 平均果重（kg） * 60（分钟/小时） / 1000（kg/吨）
            estimated_output = (sort_speed * avg_weight_kg * 60) / 1000.0
            print(f"  - 理论实时产量（基于速度）: {estimated_output:.2f} 吨/小时")
            print(f"  - ⚠️  注意：应用使用增量计算，第一次发送时previous=0，会计算出错误值")
            print(f"  - 💡 建议：使用 'continuous' 模式持续发送，让数据正确累加")
        
        # 显示等级分布摘要（前4个品质等级）
        if statistics_data:
            print(f"\n等级分布摘要（前4个品质等级）:")
            for quality in range(4):
                quality_total = 0
                for size in range(MAX_SIZE_GRADE_NUM):
                    idx = quality * MAX_SIZE_GRADE_NUM + size
                    # 从二进制数据中读取（每个ulong 8字节）
                    offset = idx * 8
                    if offset + 8 <= len(statistics_data):
                        count = struct.unpack('<Q', statistics_data[offset:offset+8])[0]
                        quality_total += count
                percentage = (quality_total / total_count * 100) if total_count > 0 else 0
                quality_names = ['优质', '良好', '一般', '较差']
                print(f"  - {quality_names[quality]}: {quality_total} 个 ({percentage:.1f}%)")
        
        # 显示出口分布摘要（前8个出口）
        if statistics_data:
            print(f"\n出口分布摘要（前8个出口）:")
            exit_offset = (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM) * 8 * 2  # 跳过nGradeCount和nWeightGradeCount
            for i in range(8):
                offset = exit_offset + i * 8
                if offset + 8 <= len(statistics_data):
                    count = struct.unpack('<Q', statistics_data[offset:offset+8])[0]
                    weight_offset = exit_offset + MAX_EXIT_NUM * 8 + i * 8
                    weight = struct.unpack('<Q', statistics_data[weight_offset:weight_offset+8])[0] if weight_offset + 8 <= len(statistics_data) else 0
                    print(f"  - 出口{i+1}: {count} 个, {weight/1000.0:.2f} kg")
        
        # 关闭连接
        sock.close()
        print(f"\n连接已关闭")
        
    except socket.timeout:
        print(f"错误: 连接超时，请确保服务器正在运行")
    except ConnectionRefusedError:
        print(f"错误: 连接被拒绝，请确保服务器正在监听 {host}:{port}")
    except Exception as e:
        print(f"错误: {e}")


def send_continuous_data(host=TCP_HOST, port=TCP_PORT, subsys_id=0, 
                        interval=3, count=10):
    """
    持续发送测试数据（模拟实时数据更新）
    
    Args:
        host: 服务器地址
        port: 服务器端口
        subsys_id: 子系统ID
        interval: 发送间隔（秒）
        count: 发送次数
    """
    print(f"开始持续发送数据，间隔 {interval} 秒，共 {count} 次\n")
    
    # 初始基础值
    base_count = 1000
    base_weight = 500000
    base_speed = 60
    base_pulse = 1000
    
    # 每次递增的值（模拟interval秒内的增量）
    # 注意：realTimeOutput的计算依赖于增量，所以每次发送的数据应该是累加的
    # 假设分选速度是60个/分钟，那么每3秒大约处理3个
    count_increment = max(1, int(base_speed * interval / 60))  # 每interval秒处理的个数
    weight_increment = count_increment * 500  # 假设每个水果平均500克
    
    # 当前累计值（用于累加）
    current_count = base_count
    current_weight = base_weight
    
    print(f"数据递增配置:")
    print(f"  - 每次增加个数: {count_increment} 个")
    print(f"  - 每次增加重量: {weight_increment} 克 ({weight_increment/1000.0:.2f} kg)")
    # 计算预期实时产量：每次增量的重量（吨） * 每小时发送次数
    expected_output = (weight_increment / 1000000.0) * (3600.0 / interval)
    print(f"  - 预期实时产量: {expected_output:.2f} 吨/小时")
    print(f"  - 计算方式: ({weight_increment/1000.0:.2f} kg / {interval}秒) * 3600秒/小时 / 1000 = {expected_output:.2f} 吨/小时\n")
    
    for i in range(count):
        print(f"\n--- 第 {i+1}/{count} 次发送 ---")
        
        # 累加数据（模拟实时数据更新，数据应该是累加的）
        current_count += count_increment
        current_weight += weight_increment
        
        # 模拟速度变化（有轻微波动）
        sort_speed = base_speed + random.randint(-5, 5)
        pulse_interval = max(500, base_pulse + random.randint(-100, 100))
        
        print(f"📊 累计数据: 总个数={current_count}, 总重量={current_weight/1000.0:.2f}kg")
        print(f"📈 本次增量: +{count_increment}个, +{weight_increment/1000.0:.2f}kg")
        
        send_test_data(
            host=host,
            port=port,
            subsys_id=subsys_id,
            total_count=current_count,
            total_weight=current_weight,
            sort_speed=sort_speed,
            pulse_interval=pulse_interval
        )
        
        if i < count - 1:
            print(f"\n等待 {interval} 秒后发送下一次...")
            time.sleep(interval)


if __name__ == '__main__':
    import sys
    
    print("=" * 60)
    print("TCP测试客户端 - Harmony应用统计数据模拟器")
    print("=" * 60)
    print(f"目标服务器: {TCP_HOST}:{TCP_PORT}\n")
    
    if len(sys.argv) > 1:
        mode = sys.argv[1]
        
        if mode == 'continuous':
            # 持续发送模式
            interval = int(sys.argv[2]) if len(sys.argv) > 2 else 3
            count = int(sys.argv[3]) if len(sys.argv) > 3 else 10
            subsys_id = int(sys.argv[4]) if len(sys.argv) > 4 else 0
            
            send_continuous_data(
                host=TCP_HOST,
                port=TCP_PORT,
                subsys_id=subsys_id,
                interval=interval,
                count=count
            )
        else:
            # 单次发送模式
            subsys_id = int(sys.argv[1]) if sys.argv[1].isdigit() else 0
            total_count = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 1000
            total_weight = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3].isdigit() else 500000
            sort_speed = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4].isdigit() else 60
            
            send_test_data(
                host=TCP_HOST,
                port=TCP_PORT,
                subsys_id=subsys_id,
                total_count=total_count,
                total_weight=total_weight,
                sort_speed=sort_speed
            )
    else:
        # 默认：发送一次测试数据
        print("使用说明:")
        print("  单次发送: python tcp_test_client.py [subsys_id] [total_count] [total_weight] [sort_speed]")
        print("  持续发送: python tcp_test_client.py continuous [interval] [count] [subsys_id]")
        print("\n示例:")
        print("  python tcp_test_client.py                    # 发送默认测试数据（⚠️ 第一次发送时实时产量计算会错误）")
        print("  python tcp_test_client.py 0 2000 1000000 80  # 发送指定数据")
        print("  python tcp_test_client.py continuous 3 10 0  # 每3秒发送一次，共10次（✅ 推荐）")
        print("\n⚠️  重要提示:")
        print("  - 单次发送时，应用第一次接收数据时previous=0，会导致实时产量计算错误")
        print("  - 建议使用 'continuous' 模式持续发送，让数据正确累加，实时产量才能正确计算")
        print("  - 例如: python tcp_test_client.py continuous 3 10 0")
        print("\n开始发送默认测试数据...\n")
        
        send_test_data(
            host=TCP_HOST,
            port=TCP_PORT,
            subsys_id=0,
            total_count=1000,
            total_weight=500000,
            sort_speed=60,
            pulse_interval=1000
        )

