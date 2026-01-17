import socket
import struct
import time
import random

# 配置参数
SERVER_IP = '127.0.0.1'
SERVER_PORT = 9090

# 协议常量
SYNC_FLAG = 0x434E5953  # "SYNC" in little endian
HC_ID = 0x1000          # 上位机 ID
FSM_ID = 0x0100         # 模拟 FSM 设备 ID

# 命令 ID
FSM_CMD_STATISTICS = 0x1001 # 统计信息
FSM_CMD_WEIGHTINFO = 0x1003 # 重量信息

# 数组大小常量
MAX_QUALITY_GRADE_NUM = 16
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 48
MAX_CHANNEL_NUM = 12
MAX_NOTICE_LENGTH = 30

def create_header(cmd_id, data_len=0):
    """
    创建消息头 (16 bytes)
    """
    header = struct.pack('<4I', 
        SYNC_FLAG,
        FSM_ID,
        HC_ID,
        cmd_id
    )
    return header

def create_statistics(
    n_total_cup_num=500,
    n_total_weight=75000,
    n_qualified_count=480,
    n_unqualified_count=20,
    n_interval_sum_per_minute=300,
    exit_counts=None
):
    """
    创建模拟的 StStatistics 数据
    :param n_total_cup_num: 总杯数 (产量)
    :param n_total_weight: 总重 (g)
    :param n_qualified_count: 合格数
    :param n_unqualified_count: 不合格数
    :param n_interval_sum_per_minute: 每分钟间隔总和 (模拟速度)
    :param exit_counts: 出口计数数组 (可选，如果不传则全0)
    """
    # 模拟核心数据
    n_grade_count = [0] * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM)
    n_weight_grade_count = [0] * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM)
    
    # 随机填充一些等级计数
    if n_qualified_count > 0:
        n_grade_count[0] = int(n_qualified_count * 0.6) # 特级果
        n_grade_count[1] = n_qualified_count - n_grade_count[0] # 一级果

    # 填充对应的重量 (假设平均果重 150g)
    n_weight_grade_count[0] = n_grade_count[0] * 150
    n_weight_grade_count[1] = n_grade_count[1] * 140
    
    # 填充出口数据
    if exit_counts:
        n_exit_count = list(exit_counts)
        # 确保长度不超过 MAX_EXIT_NUM
        if len(n_exit_count) < MAX_EXIT_NUM:
            n_exit_count.extend([0] * (MAX_EXIT_NUM - len(n_exit_count)))
        else:
            n_exit_count = n_exit_count[:MAX_EXIT_NUM]
    else:
        n_exit_count = [0] * MAX_EXIT_NUM
            
    n_exit_weight_count = [x * 150 for x in n_exit_count] # 估算重量
    
    n_channel_total_count = [0] * MAX_CHANNEL_NUM
    n_channel_total_count[0] = n_total_cup_num
    
    n_channel_weight_count = [0] * MAX_CHANNEL_NUM
    n_channel_weight_count[0] = n_total_weight
    
    n_subsys_id = 0
    
    n_box_grade_count = [0] * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM)
    n_box_grade_weight = [0] * (MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM)

    # 填充箱数 (假设一箱 50 个果)
    n_box_grade_count[0] = int(n_grade_count[0] / 50)
    n_box_grade_count[1] = int(n_grade_count[1] / 50)
    
    # n_total_cup_num 在协议中对应 nYield
    n_interval = 100 # 假设 100ms
    # n_interval_sum_per_minute = 300 (传入参数)
    n_cup_state = 0
    n_pulse_interval = 10
    n_unpush_fruit_count = 5
    
    n_net_state = 1
    n_weight_setting = 1
    n_scm_state = 1
    n_iqs_net_state = 1
    n_lock_state = 0
    # 注意：这里需要 Padding 1 byte 因为 nLockState 是第5个单字节
    
    exit_box_num = [0] * MAX_EXIT_NUM
    exit_weight = [0] * MAX_EXIT_NUM
    notice = [0] * MAX_NOTICE_LENGTH
    
    # 开始打包
    # ulong arrays (4 bytes each)
    body = b''
    body += struct.pack(f'<{len(n_grade_count)}I', *n_grade_count)
    body += struct.pack(f'<{len(n_weight_grade_count)}I', *n_weight_grade_count)
    body += struct.pack(f'<{len(n_exit_count)}I', *n_exit_count)
    body += struct.pack(f'<{len(n_exit_weight_count)}I', *n_exit_weight_count)
    body += struct.pack(f'<{len(n_channel_total_count)}I', *n_channel_total_count)
    body += struct.pack(f'<{len(n_channel_weight_count)}I', *n_channel_weight_count)
    
    body += struct.pack('<i', n_subsys_id)
    
    # int arrays (4 bytes each)
    body += struct.pack(f'<{len(n_box_grade_count)}i', *n_box_grade_count)
    body += struct.pack(f'<{len(n_box_grade_weight)}i', *n_box_grade_weight)
    
    body += struct.pack('<iii', n_total_cup_num, n_interval, n_interval_sum_per_minute)
    
    # ushort (2 bytes)
    body += struct.pack('<HHH', n_cup_state, n_pulse_interval, n_unpush_fruit_count)
    
    # quint8 (1 byte)
    body += struct.pack('<BBBBB', n_net_state, n_weight_setting, n_scm_state, n_iqs_net_state, n_lock_state)
    
    # PADDING! (Important)
    body += b'\x00'
    
    # ExitBoxNum (quint16 - 2 bytes)
    body += struct.pack(f'<{len(exit_box_num)}H', *exit_box_num)
    
    # ExitWeight (quint32 - 4 bytes)
    body += struct.pack(f'<{len(exit_weight)}I', *exit_weight)
    
    # Notice (quint8 - 1 byte)
    body += struct.pack(f'<{len(notice)}B', *notice)
    
    # 确保长度对齐到 4 (可选，看 C++ 编译器行为，Structures.ets 里有处理)
    if len(body) % 4 != 0:
        body += b'\x00' * (4 - (len(body) % 4))
        
    return body

def create_weight_info(current_weight=150, current_exit=3):
    """
    创建模拟的 StWeightInfo 数据 (24 bytes payload + padding to match C++ StWeightResult 44 bytes)
    """
    weight = current_weight        # g
    diameter = 85       # 85mm
    volume = 200
    area = 100
    weight_grade = 1
    size_grade = 2
    quality_grade = 1
    final_grade = 1
    target_exit = current_exit     # 出口
    fruit_id = random.randint(10000, 99999)
    cup_index = 5
    
    # 24 bytes data
    payload = struct.pack('<IHIIBBBBBIB',
        weight,
        diameter,
        volume,
        area,
        weight_grade,
        size_grade,
        quality_grade,
        final_grade,
        target_exit,
        fruit_id,
        cup_index
    )
    
    # C++ server expects sizeof(StWeightResult) which is 44 bytes
    # We pad the remaining 20 bytes with zeros
    padding_size = 44 - len(payload)
    if padding_size > 0:
        payload += b'\x00' * padding_size
        
    return payload

def send_once(header, body, name="Data"):
    """
    建立短连接发送一次数据
    """
    try:
        # 建立 TCP 连接
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.settimeout(5)
        # print(f"Connecting to {SERVER_IP}:{SERVER_PORT}...")
        client.connect((SERVER_IP, SERVER_PORT))
        # print("Connected!")
        
        client.send(header)
        client.send(body)
        print(f"Sent {name}: {len(body)} bytes")
        
        client.close()
        # print("Connection closed.")
        return True
        
    except ConnectionRefusedError:
        print(f"Error: Could not connect to {SERVER_IP}:{SERVER_PORT}. Is the server running?")
        return False
    except Exception as e:
        print(f"Error sending {name}: {e}")
        return False

def run_simulation():
    """
    持续运行模拟，不断发送更新的数据
    """
    print("Starting FSM Simulation...")
    print("Press Ctrl+C to stop.")
    
    # 初始状态 - 从0开始
    current_yield = 0
    current_total_weight = 0
    exit_counts = [0] * MAX_EXIT_NUM # 维护持久的出口计数状态
    start_time = time.time()
    
    try:
        while True:
            # 1. 模拟数据增长
            increment = random.randint(1, 5) # 每次增加 1-5 个
            current_yield += increment
            
            # 将增量分配给随机出口
            for _ in range(increment):
                # 加权随机选择出口
                rand_val = random.random()
                if rand_val < 0.6: # 60% 概率落在前10个出口 (0-9)
                    exit_idx = random.randint(0, 9)
                elif rand_val < 0.9: # 30% 概率落在中间10个出口 (10-19)
                    exit_idx = random.randint(10, 19)
                else: # 10% 概率落在其他出口
                    exit_idx = random.randint(20, MAX_EXIT_NUM - 1)
                
                if exit_idx < MAX_EXIT_NUM:
                    exit_counts[exit_idx] += 1
            
            weight_increment = increment * random.randint(120, 180) # 每个果 120-180g
            current_total_weight += weight_increment
            
            # 计算合格/不合格 (95% 合格率)
            qualified = int(current_yield * 0.95)
            unqualified = current_yield - qualified
            
            # 模拟速度波动 (300-600 个/分钟)
            speed = random.randint(300, 600)
            
            # --- 2. 发送统计数据 ---
            print(f"\n[Statistics] Yield: {current_yield}, Weight: {current_total_weight/1000:.2f}kg, Speed: {speed}/min")
            stats_header = create_header(FSM_CMD_STATISTICS)
            stats_body = create_statistics(
                n_total_cup_num=current_yield,
                n_total_weight=current_total_weight,
                n_qualified_count=qualified,
                n_unqualified_count=unqualified,
                n_interval_sum_per_minute=speed,
                exit_counts=exit_counts  # 传入持久化的出口计数
            )
            send_once(stats_header, stats_body, "Statistics")
            
            time.sleep(0.5) 
            
            # --- 3. 发送重量数据 (模拟单个果实) ---
            # 随机发送 1-3 个单果数据
            for _ in range(random.randint(1, 3)):
                single_weight = random.randint(100, 250)
                exit_id = random.randint(1, 10)
                print(f"[WeightInfo] Weight: {single_weight}g, Exit: {exit_id}")
                
                weight_header = create_header(FSM_CMD_WEIGHTINFO)
                weight_body = create_weight_info(current_weight=single_weight, current_exit=exit_id)
                send_once(weight_header, weight_body, "WeightInfo")
                time.sleep(0.1)
            
            # 等待下一轮
            time.sleep(1)

    except KeyboardInterrupt:
        print("\nSimulation stopped by user.")

if __name__ == "__main__":
    run_simulation()
