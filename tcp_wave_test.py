#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TCP波形数据测试客户端
持续发送FSM_CMD_WAVEINFO数据
用于测试HarmonyOS应用的波形数据接收和显示功能
"""

import socket
import struct
import time
import random
import sys
import math

# 常量定义
WAVE_POINT_COUNT = 256
MAX_CHANNEL_NUM = 12

# TCP服务器配置
TCP_HOST = '127.0.0.1'
TCP_PORT = 8081

# 命令ID
FSM_CMD_WAVEINFO = 0x1004

# SYNC字符串
SYNC_STRING = b'SYNC'

# 子系统ID和客户端ID
FSM_ID = 0x0001  # 下位机ID
HC_ID = 0x0000   # 上位机ID


def int32_to_bytes(value):
    """将int32转换为小端字节序的4字节"""
    return struct.pack('<i', value)


def uint16_to_bytes(value):
    """将uint16转换为小端字节序的2字节"""
    return struct.pack('<H', value)


def float_to_bytes(value):
    """将float转换为小端字节序的4字节"""
    return struct.pack('<f', value)


def create_waveform_data(channel_id=0, base_freq=1.0, amplitude=1000):
    """创建模拟波形数据（正弦波）"""
    waveform = []
    for i in range(WAVE_POINT_COUNT):
        # 生成正弦波，添加一些随机噪声
        value = int(amplitude * (1 + math.sin(2 * math.pi * base_freq * i / WAVE_POINT_COUNT)) / 2)
        value += random.randint(-50, 50)  # 添加噪声
        value = max(0, min(65535, value))  # 限制在ushort范围内
        waveform.append(value)
    return waveform


def create_wave_packet(channel_id=0, fruit_weight=150.5):
    """创建FSM_CMD_WAVEINFO数据包"""
    data = bytearray()
    
    # 1. nChannelId (int, 4字节)
    data.extend(int32_to_bytes(channel_id))
    
    # 2. waveform0[256] (ushort[256], 512字节) - AD0通道
    waveform0 = create_waveform_data(channel_id, base_freq=2.0, amplitude=3000)
    for value in waveform0:
        data.extend(uint16_to_bytes(value))
    
    # 3. waveform1[256] (ushort[256], 512字节) - AD1通道
    waveform1 = create_waveform_data(channel_id, base_freq=1.5, amplitude=2500)
    for value in waveform1:
        data.extend(uint16_to_bytes(value))
    
    # 4. fruitweight (float, 4字节)
    data.extend(float_to_bytes(fruit_weight))
    
    # 构造完整的数据包
    sync = SYNC_STRING
    command_head = int32_to_bytes(FSM_ID) + int32_to_bytes(HC_ID) + int32_to_bytes(FSM_CMD_WAVEINFO)
    
    # 数据包格式：SYNC + CommandHead + 数据体
    packet = sync + command_head + bytes(data)
    
    return packet


def send_wave_packet(sock, channel_id=0, fruit_weight=150.5):
    """发送波形数据包"""
    try:
        packet = create_wave_packet(channel_id, fruit_weight)
        sock.sendall(packet)
        print(f"[发送] 波形数据 - 通道ID: {channel_id}, 水果重量: {fruit_weight}g, 数据长度: {len(packet)} 字节")
        return True
    except Exception as e:
        print(f"[错误] 发送波形数据失败: {e}")
        return False


def main():
    """主函数"""
    # 解析命令行参数（先解析，再使用）
    host = TCP_HOST
    port = TCP_PORT
    if len(sys.argv) > 1:
        host = sys.argv[1]
    if len(sys.argv) > 2:
        port = int(sys.argv[2])
    
    print("=" * 60)
    print("TCP波形数据测试客户端".center(50))
    print("=" * 60)
    print(f"服务器地址: {host}:{port}")
    print(f"命令类型: FSM_CMD_WAVEINFO (0x{FSM_CMD_WAVEINFO:04X})")
    print("=" * 60)
    
    # 创建TCP连接
    sock = None
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))
        print(f"[成功] 已连接到服务器 {host}:{port}")
        
        print("\n[运行] 开始持续发送波形数据...")
        print("[提示] 按 Ctrl+C 停止\n")
        
        packet_count = 0
        channel_id = 0
        base_weight = 150.0
        
        # 持续发送波形数据
        while True:
            try:
                # 随机变化通道ID和水果重量
                if packet_count % 10 == 0:
                    channel_id = (channel_id + 1) % MAX_CHANNEL_NUM
                
                fruit_weight = base_weight + random.uniform(-20.0, 20.0)
                
                if send_wave_packet(sock, channel_id, fruit_weight):
                    packet_count += 1
                
                # 每0.5秒发送一次
                time.sleep(0.5)
                
            except KeyboardInterrupt:
                print("\n[停止] 收到停止信号，正在关闭连接...")
                break
            except Exception as e:
                print(f"[错误] 发送失败: {e}")
                time.sleep(1)
                
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

