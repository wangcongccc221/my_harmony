import socket
import struct
import time
import random
import argparse
import logging
import sys
from typing import Dict, List, Optional, Tuple

# 配置参数
SERVER_IP = '127.0.0.1'
SERVER_PORT = 9090
CONTROL_PORT = 8080
CMD_SERVER_PORT = 1279
SHOW_SEND_LOGS = True
LOG_LEVEL = "INFO"
LOG_FILE: Optional[str] = None
LOG_TO_CONSOLE = True
LOG_BODY_PREVIEW_LEN = 96

# 协议常量
SYNC_FLAG = 0x434E5953  # "SYNC" in little endian
HC_ID = 0x1000          # 上位机 ID
FSM_ID = 0x0100         # 模拟 FSM 设备 ID

# 命令 ID
FSM_CMD_STATISTICS = 0x1001 # 统计信息
FSM_CMD_GRADEINFO = 0x1002 # 水果实时分级信息
FSM_CMD_WEIGHTINFO = 0x1003 # 重量信息
HC_CMD_GRADE_INFO = 0x0051 # 等级设置信息 (UI表头)

# 数组大小常量
MAX_QUALITY_GRADE_NUM = 16
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 48
MAX_CHANNEL_NUM = 12
MAX_NOTICE_LENGTH = 30
MAX_TEXT_LENGTH = 12
MAX_FRUIT_NAME_LENGTH = 50
MAX_DENSITY_GRADE_NUM = 6
MAX_COLOR_GRADE_NUM = 16
MAX_SHAPE_GRADE_NUM = 6


def expected_statistics_size() -> int:
    grade_len = MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM
    size = 0
    size += grade_len * 4  # nGradeCount
    size += grade_len * 4  # nWeightGradeCount
    size += MAX_EXIT_NUM * 4  # nExitCount
    size += MAX_EXIT_NUM * 4  # nExitWeightCount
    size += MAX_CHANNEL_NUM * 4  # nChannelTotalCount
    size += MAX_CHANNEL_NUM * 4  # nChannelWeightCount
    size += 4  # nSubsysId
    size += grade_len * 4  # nBoxGradeCount
    size += grade_len * 4  # nBoxGradeWeight
    size += 4  # nTotalCupNum
    size += 4  # nInterval
    size += 4  # nIntervalSumperminute
    size += 2  # nCupState
    size += 2  # nPulseInterval
    size += 2  # nUnpushFruitCount
    size += 1  # nNetState
    size += 1  # nWeightSetting
    size += 1  # nSCMState
    size += 1  # nIQSNetState
    size += 1  # nLockState
    size += MAX_EXIT_NUM * 2  # ExitBoxNum
    size += MAX_EXIT_NUM * 4  # ExitWeight
    size += MAX_NOTICE_LENGTH  # Notice
    if size % 4 != 0:
        size += (4 - (size % 4))
    return size

def expected_grade_info_size() -> int:
    return 120 * 2 + 4

def expected_weight_result_size() -> int:
    return 44

def setup_logging(log_file: Optional[str], log_level: str, log_to_console: bool) -> logging.Logger:
    logger = logging.getLogger("mock_device")
    logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))
    logger.handlers = []
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")
    if log_to_console:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
    if log_file:
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    return logger

LOGGER = logging.getLogger("mock_device")

def log_info(message: str) -> None:
    LOGGER.info(message)

def log_error(message: str) -> None:
    LOGGER.error(message)

def format_hex(data: bytes, max_len: int) -> str:
    if not data:
        return ""
    prefix = data[:max_len]
    hex_str = prefix.hex()
    if len(data) > max_len:
        return f"{hex_str}..."
    return hex_str

def parse_header_info(header: bytes) -> Tuple[Optional[int], Optional[int], Optional[int], Optional[int]]:
    if not header or len(header) < 16:
        return None, None, None, None
    try:
        sync, src_id, dst_id, cmd_id = struct.unpack("<4I", header[:16])
        return sync, src_id, dst_id, cmd_id
    except Exception:
        return None, None, None, None

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


def make_src_id(subsys_index: int = 0, ipm_index: Optional[int] = None, channel_index: Optional[int] = None) -> int:
    """
    生成与 Harmony ConstPreDefine 相同布局的 srcId（int32）：
      - subsys nibble: (subsys_index+1) << 8
      - ipm nibble: (ipm_index+1) << 4
      - channel nibble: channel_index << 4 （用于统计/重量包里模拟通道来源）
    约定：优先使用 ipm_index；否则使用 channel_index；都不传则返回 FSM_ID。
    """
    if ipm_index is not None:
        return (((subsys_index + 1) & 0x0F) << 8) | (((ipm_index + 1) & 0x0F) << 4)
    if channel_index is not None:
        return (((subsys_index + 1) & 0x0F) << 8) | ((channel_index & 0x0F) << 4)
    return FSM_ID


def create_st_grade_info():
    """
    创建 HC_CMD_GRADE_INFO (0x0051) 的 StGradeInfo 数据包
    用于驱动 GradeStatisticsTable UI
    """
    # 1. Intervals (3 * 4 = 12 bytes)
    intervals = b'\x00' * 12
    
    # 2. Percent (16 * 3 * 2 = 96 bytes)
    percent = b'\x00' * 96
    
    # 3. Grades (16 * 16 * 36 = 9216 bytes)
    grades = b''
    # Create dummy grades: 3 Quality x 4 Size
    n_qual = 3
    n_size = 4
    
    for q in range(MAX_QUALITY_GRADE_NUM):
        for s in range(MAX_SIZE_GRADE_NUM):
            if q < n_qual and s < n_size:
                min_size = 60.0 + s * 10.0
                max_size = min_size + 10.0
            else:
                min_size = 0.0
                max_size = 0.0
            
            # exitLow(4), exitHigh(4), nMinSize(4), nMaxSize(4), nFruitNum(4)
            item = struct.pack('<IIffi', 0, 0, float(min_size), float(max_size), 0)
            # nColorGrade(1) + 14 sb fields(1) + padding(1) = 16 bytes
            item += b'\x00' * 16
            grades += item
            
    # 4. Int32 Arrays (ExitEnabled 2, ColorIntervals 2, nExitSwitchNum 48) -> 52 ints
    int32_arrays = b'\x00' * (52 * 4)
    
    # 5. TagInfo (6 bytes)
    tag_info = b'\x00' * 6
    
    # 6. FruitType (4 bytes)
    fruit_type = b'\x00' * 4
    
    # 7. FruitName (50 bytes)
    fruit_name = b"Apple".ljust(MAX_FRUIT_NAME_LENGTH, b'\x00')
    
    # 8. Factors Uint32 (6*2 + 6*2 + 6*2 = 36 ints) -> 144 bytes
    factors_u32 = b'\x00' * 144
    
    # 9. Factors Float32 (10 arrays * 6 elements = 60 floats) -> 240 bytes
    factors_f32 = b'\x00' * 240
    
    # 10. String Arrays
    def pack_names(names, count):
        buf = b''
        for i in range(count):
            name = names[i] if i < len(names) else ""
            # Max text length 12
            encoded = name.encode('utf-8')[:MAX_TEXT_LENGTH-1]
            buf += encoded.ljust(MAX_TEXT_LENGTH, b'\x00')
        return buf
        
    size_names = ["S", "M", "L", "XL"]
    qual_names = ["Excellent", "Good", "Normal"]
    
    str_size = pack_names(size_names, MAX_SIZE_GRADE_NUM)
    str_qual = pack_names(qual_names, MAX_QUALITY_GRADE_NUM)
    str_dens = b'\x00' * (MAX_DENSITY_GRADE_NUM * MAX_TEXT_LENGTH)
    str_colr = b'\x00' * (MAX_COLOR_GRADE_NUM * MAX_TEXT_LENGTH)
    str_shap = b'\x00' * (MAX_SHAPE_GRADE_NUM * MAX_TEXT_LENGTH)
    
    # 11 other string arrays of length 6
    str_others = b'\x00' * (11 * 6 * MAX_TEXT_LENGTH)
    
    strings = str_size + str_qual + str_dens + str_colr + str_shap + str_others
    
    # 11. Tail
    # ColorType(1), nLabelType(1)
    tail_part1 = struct.pack('<BB', 0, 0)
    # nLabelbyExit(48), nSwitchLabel(48)
    tail_part2 = b'\x00' * (48 + 48)
    # nSizeGradeNum(1), nQualityGradeNum(1), nClassifyType(1)
    tail_part3 = struct.pack('<BBB', n_size, n_qual, 0)
    # nCheckNum(2), ForceChannel(2)
    tail_part4 = struct.pack('<hh', 0, 0)
    
    tail = tail_part1 + tail_part2 + tail_part3 + tail_part4
    
    total = intervals + percent + grades + int32_arrays + tag_info + fruit_type + fruit_name + \
            factors_u32 + factors_f32 + strings + tail
            
    # Padding alignment to 4 bytes
    if len(total) % 4 != 0:
        total += b'\x00' * (4 - (len(total) % 4))
        
    return total

def create_header_with_ids(cmd_id: int, src_id: int, dest_id: int = HC_ID) -> bytes:

    """
    Native TcpServer 协议头：SYNC + SrcId + DestId + CmdId (4 * int32 = 16 bytes)
    """
    return struct.pack('<4I', SYNC_FLAG, int(src_id) & 0xFFFFFFFF, int(dest_id) & 0xFFFFFFFF, int(cmd_id) & 0xFFFFFFFF)

def create_statistics(
    n_total_cup_num=500,
    n_total_weight=75000,
    n_qualified_count=480,
    n_unqualified_count=20,
    n_interval_sum_per_minute=300,
    exit_counts=None,
    exit_weight_counts=None
):
    """
    创建模拟的 StStatistics 数据
    :param n_total_cup_num: 总杯数 (产量)
    :param n_total_weight: 总重 (g)
    :param n_qualified_count: 合格数
    :param n_unqualified_count: 不合格数
    :param n_interval_sum_per_minute: 每分钟间隔总和 (模拟速度)
    :param exit_counts: 出口计数数组 (可选，如果不传则全0)
    :param exit_weight_counts: 出口重量数组(g) (可选；用于更真实地测试按重量占比)
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
            
    if exit_weight_counts:
        n_exit_weight_count = list(exit_weight_counts)
        if len(n_exit_weight_count) < MAX_EXIT_NUM:
            n_exit_weight_count.extend([0] * (MAX_EXIT_NUM - len(n_exit_weight_count)))
        else:
            n_exit_weight_count = n_exit_weight_count[:MAX_EXIT_NUM]
    else:
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

    exp = expected_statistics_size()
    if len(body) != exp:
        raise ValueError(f"StStatistics size mismatch: got {len(body)} bytes, expected {exp} bytes")

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
    padding_size = expected_weight_result_size() - len(payload)
    if padding_size > 0:
        payload += b'\x00' * padding_size

    exp = expected_weight_result_size()
    if len(payload) != exp:
        raise ValueError(f"StWeightResult size mismatch: got {len(payload)} bytes, expected {exp} bytes")
        
    return payload

def create_fruit_vision_param(
    color_rate0=60,
    color_rate1=30,
    color_rate2=10,
    area=12000,
    flaw_area=0,
    volume=180000,
    flaw_num=0,
    max_r=45.0,
    min_r=40.0,
    select_basis=82.5,
    diameter_ratio=1.05,
    min_d_ratio=1.00
):
    """
    48项目结构: StFruitVisionParam (little endian)
    uint*7 + float*5 = 48 bytes
    """
    return struct.pack(
        '<7I5f',
        int(color_rate0),
        int(color_rate1),
        int(color_rate2),
        int(area),
        int(flaw_area),
        int(volume),
        int(flaw_num),
        float(max_r),
        float(min_r),
        float(select_basis),
        float(diameter_ratio),
        float(min_d_ratio)
    )

def create_fruit_uv_param(
    bruise_area=0,
    bruise_num=0,
    rot_area=0,
    rot_num=0,
    rigidity=0,
    water=0,
    time_tag=0
):
    """
    48项目结构: StFruitUVParam
    uint*6 + quint32 = 28 bytes
    """
    return struct.pack(
        '<7I',
        int(bruise_area),
        int(bruise_num),
        int(rot_area),
        int(rot_num),
        int(rigidity),
        int(water),
        int(time_tag)
    )

def create_nir_param(
    sugar=12.3,
    acidity=0.35,
    hollow=0.0,
    skin=0.0,
    brown=0.0,
    tangxin=0.0,
    time_tag=0
):
    """
    48项目结构: StNIRParam
    float*6 + quint32 = 28 bytes
    """
    return struct.pack(
        '<6fI',
        float(sugar),
        float(acidity),
        float(hollow),
        float(skin),
        float(brown),
        float(tangxin),
        int(time_tag)
    )

def encode_ungrade(size_grade_index: int, quality_grade_index: int) -> int:
    """
    48项目 FruitInfoForm 解析规则:
      SizeGradeIndex = unGrade & 0x0F
      QualfGradeIndex = (unGrade & 0xF0) >> 4
    """
    size_nibble = int(size_grade_index) & 0x0F
    quality_nibble = int(quality_grade_index) & 0x0F
    return (quality_nibble << 4) | size_nibble

def create_fruit_param(
    diameter_mm=82.5,
    weight_g=180.0,
    density=1.02,
    size_grade_index=1,
    quality_grade_index=1,
    which_exit=0
):
    """
    48项目结构: StFruitParam
      visionParam(48) + uvParam(28) + nirParam(28) + fWeight(4) + fDensity(4) + unGrade(4) + unWhichExit(1) + padding(3)
    total: 120 bytes (对齐到4)
    """
    r = max(1.0, float(diameter_mm) / 2.0)
    area = int(round(3.1415926 * r * r))
    volume = int(round((4.0 / 3.0) * 3.1415926 * r * r * r))
    flaw_area = random.randint(0, max(1, int(area * 0.08)))
    flaw_num = random.randint(0, 6)
    vision = create_fruit_vision_param(
        color_rate0=random.randint(10, 90),
        color_rate1=random.randint(0, 70),
        color_rate2=random.randint(0, 40),
        area=area,
        flaw_area=flaw_area,
        volume=volume,
        flaw_num=flaw_num,
        max_r=float(r),
        min_r=float(r * random.uniform(0.92, 0.99)),
        select_basis=float(diameter_mm),
        diameter_ratio=round(random.uniform(0.85, 1.20), 3),
        min_d_ratio=round(random.uniform(0.80, 1.10), 3)
    )
    uv = create_fruit_uv_param(
        bruise_area=random.randint(0, 50),
        bruise_num=random.randint(0, 3),
        rot_area=random.randint(0, 30),
        rot_num=random.randint(0, 2),
        rigidity=random.randint(0, 100),
        water=random.randint(0, 100),
        time_tag=int(time.time() * 1000) & 0xFFFFFFFF
    )
    nir = create_nir_param(
        sugar=round(random.uniform(10.0, 16.0), 2),
        acidity=round(random.uniform(0.20, 0.80), 2),
        hollow=round(random.uniform(0.0, 1.0), 2),
        skin=round(random.uniform(0.0, 1.0), 2),
        brown=round(random.uniform(0.0, 1.0), 2),
        tangxin=round(random.uniform(0.0, 1.0), 2),
        time_tag=int(time.time() * 1000) & 0xFFFFFFFF
    )

    un_grade = encode_ungrade(size_grade_index, quality_grade_index)
    base = vision + uv + nir + struct.pack('<ffI', float(weight_g), float(density), int(un_grade))
    base += struct.pack('<B', int(which_exit) & 0xFF)
    base += b'\x00' * 3
    return base

def create_grade_info(
    channel0_exit=0,
    channel1_exit=1,
    route_id=0
):
    """
    48项目结构: StFruitGradeInfo
      StFruitParam param[2] + int nRouteId
    total: 120*2 + 4 = 244 bytes
    """
    param0 = create_fruit_param(
        diameter_mm=round(random.uniform(70.0, 95.0), 1),
        weight_g=round(random.uniform(120.0, 260.0), 1),
        density=round(random.uniform(0.90, 1.20), 3),
        size_grade_index=random.randint(0, 15),
        quality_grade_index=random.randint(0, 15),
        which_exit=channel0_exit
    )
    param1 = create_fruit_param(
        diameter_mm=round(random.uniform(70.0, 95.0), 1),
        weight_g=round(random.uniform(120.0, 260.0), 1),
        density=round(random.uniform(0.90, 1.20), 3),
        size_grade_index=random.randint(0, 15),
        quality_grade_index=random.randint(0, 15),
        which_exit=channel1_exit
    )
    body = param0 + param1 + struct.pack('<i', int(route_id))
    exp = expected_grade_info_size()
    if len(body) != exp:
        raise ValueError(f"StFruitGradeInfo size mismatch: got {len(body)} bytes, expected {exp} bytes")
    return body

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
        if SHOW_SEND_LOGS:
            sync, src_id, dst_id, cmd_id = parse_header_info(header)
            header_hex = format_hex(header, 32)
            body_hex = format_hex(body, LOG_BODY_PREVIEW_LEN)
            if cmd_id is not None:
                log_info(
                    f"Sent {name} cmd=0x{cmd_id:04X} src=0x{(src_id or 0):04X} dst=0x{(dst_id or 0):04X} "
                    f"bodyLen={len(body)} headerHex={header_hex} bodyHex={body_hex}"
                )
            else:
                log_info(f"Sent {name} bodyLen={len(body)} headerHex={header_hex} bodyHex={body_hex}")
        
        client.close()
        # print("Connection closed.")
        return True
        
    except ConnectionRefusedError:
        log_error(f"Error: Could not connect to {SERVER_IP}:{SERVER_PORT}. Is the server running?")
        return False
    except Exception as e:
        log_error(f"Error sending {name}: {e}")
        return False


def send_control(cmd: str, host: str, port: int) -> bool:
    try:
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.settimeout(3)
        client.connect((host, port))
        payload = cmd.encode("utf-8")
        client.send(payload)
        client.close()
        if SHOW_SEND_LOGS:
            payload_hex = format_hex(payload, LOG_BODY_PREVIEW_LEN)
            log_info(f"Sent Control cmd={cmd} bodyLen={len(payload)} bodyHex={payload_hex}")
        return True
    except Exception as e:
        log_error(f"Error sending Control '{cmd}': {e}")
        return False


def seed_completed_batches(args: argparse.Namespace) -> None:
    n = int(args.seed_completed or 0)
    if n <= 0:
        return
    if SHOW_SEND_LOGS:
        log_info(f"[SeedCompleted] Start seeding {n} completed batches...")
    for i in range(n):
        current_yield = 0
        current_total_weight = 0
        exit_counts = [0] * MAX_EXIT_NUM
        exit_weight_counts = [0] * MAX_EXIT_NUM
        dist = parse_distribution(args.dist)

        for _ in range(max(1, int(args.seed_completed_cycles))):
            increment = random.randint(args.min_inc, args.max_inc)
            current_yield += increment
            for _ in range(increment):
                exit_idx = choose_exit_index(dist)
                exit_counts[exit_idx] += 1
                w = random.randint(args.min_weight_g, args.max_weight_g)
                exit_weight_counts[exit_idx] += w
                current_total_weight += w

            qualified = int(current_yield * 0.95)
            unqualified = current_yield - qualified
            speed = random.randint(300, 600)
            stats_src_id = make_src_id(subsys_index=args.subsys, channel_index=args.stats_channel)
            stats_header = create_header_with_ids(FSM_CMD_STATISTICS, stats_src_id, HC_ID)
            stats_body = create_statistics(
                n_total_cup_num=current_yield,
                n_total_weight=current_total_weight,
                n_qualified_count=qualified,
                n_unqualified_count=unqualified,
                n_interval_sum_per_minute=speed,
                exit_counts=exit_counts,
                exit_weight_counts=exit_weight_counts
            )
            if not args.dry_run:
                send_once(stats_header, stats_body, f"SeedStatistics[{i+1}]")
            time.sleep(float(args.seed_completed_interval_s))

        mode = (args.end_mode or "clear").lower()
        if mode == "alternate":
            cmd = "END_CLEAR" if (i % 2 == 0) else "END_SAVE"
        else:
            cmd = "END_SAVE" if mode == "save" else "END_CLEAR"
        if not args.dry_run:
            send_control(cmd, SERVER_IP, int(args.control_port))
        time.sleep(float(args.seed_completed_interval_s))

    if SHOW_SEND_LOGS:
        log_info("[SeedCompleted] Done.")

def _recv_exact(conn: socket.socket, n: int) -> bytes:
    buf = b""
    while len(buf) < n:
        chunk = conn.recv(n - len(buf))
        if not chunk:
            break
        buf += chunk
    return buf


def run_cmd_server(args: argparse.Namespace) -> None:
    host = args.cmd_server_host
    port = int(args.cmd_port)
    log_info(f"[CmdServer] Listening on {host}:{port} ...")
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((host, port))
    srv.listen(5)

    try:
        while True:
            conn, addr = srv.accept()
            conn.settimeout(2)
            try:
                header = _recv_exact(conn, 12)
                if len(header) < 12:
                    conn.close()
                    continue
                total_len, src_id, dst_id, cmd_u16 = struct.unpack("<IHHH", header)
                remaining = max(0, total_len - 12)
                body = _recv_exact(conn, remaining) if remaining > 0 else b""

                cmd = cmd_u16
                if cmd in (0x0055, 0x0056) and len(body) >= 4:
                    ch, ex = struct.unpack("<HH", body[:4])
                    mode = "TEST_ALL_LANE_VOLVE" if cmd == 0x0056 else "TEST_VOLVE"
                    log_info(f"[CmdServer] {addr[0]}:{addr[1]} cmd=0x{cmd:04X}({mode}) src=0x{src_id:04X} dst=0x{dst_id:04X} ch={ch} exit={ex}")
                else:
                    log_info(f"[CmdServer] {addr[0]}:{addr[1]} cmd=0x{cmd:04X} src=0x{src_id:04X} dst=0x{dst_id:04X} bodyLen={len(body)}")

            except Exception as e:
                log_error(f"[CmdServer] Error: {e}")
            finally:
                try:
                    conn.close()
                except Exception:
                    pass
    except KeyboardInterrupt:
        log_info("[CmdServer] stopped.")
    finally:
        try:
            srv.close()
        except Exception:
            pass

def parse_distribution(spec: str) -> List[Tuple[int, float]]:
    """
    解析出口分布，例如: "1:60,2:30,3:10"（出口号从1开始）
    返回: [(exit_idx0, weight), ...]，exit_idx0 为 0-based
    """
    items: List[Tuple[int, float]] = []
    if not spec:
        return items
    parts = [p.strip() for p in spec.split(',') if p.strip()]
    for part in parts:
        if ':' not in part:
            continue
        k, v = part.split(':', 1)
        exit_no = int(k.strip())
        w = float(v.strip())
        if exit_no < 1 or exit_no > MAX_EXIT_NUM:
            continue
        if w <= 0:
            continue
        items.append((exit_no - 1, w))
    return items


def choose_exit_index(dist: List[Tuple[int, float]]) -> int:
    if not dist:
        return random.randint(0, MAX_EXIT_NUM - 1)
    total = sum(w for _, w in dist)
    r = random.uniform(0, total)
    acc = 0.0
    for idx, w in dist:
        acc += w
        if r <= acc:
            return idx
    return dist[-1][0]


def calc_exit_percent(exit_counts: List[int], exit_weight_counts: List[int]) -> Tuple[bool, List[float]]:
    total_weight = sum(exit_weight_counts)
    total_count = sum(exit_counts)
    use_weight = total_weight > 0
    base = total_weight if use_weight else total_count
    if base <= 0:
        return use_weight, [0.0] * MAX_EXIT_NUM
    percents: List[float] = []
    for i in range(MAX_EXIT_NUM):
        v = exit_weight_counts[i] if use_weight else exit_counts[i]
        percents.append(round(v * 100.0 / base, 2))
    return use_weight, percents


def print_top_exits(exit_counts: List[int], exit_weight_counts: List[int], top_n: int = 6) -> None:
    use_weight, percents = calc_exit_percent(exit_counts, exit_weight_counts)
    pairs = []
    for i, p in enumerate(percents):
        if p <= 0:
            continue
        pairs.append((p, i))
    pairs.sort(reverse=True)
    mode = "重量" if use_weight else "数量"
    show = pairs[:top_n]
    if not show:
        return
    s = ", ".join([f"E{idx+1}:{p:.2f}%" for p, idx in show])
    if SHOW_SEND_LOGS:
        log_info(f"[ExitPercent] 基于{mode}占比 Top{len(show)} => {s}")


def run_simulation(args: argparse.Namespace):
    """
    持续运行模拟，不断发送更新的数据
    """
    if SHOW_SEND_LOGS:
        log_info("Starting FSM Simulation...")
        log_info("Press Ctrl+C to stop.")
    
    # 初始状态 - 从0开始
    current_yield = 0
    current_total_weight = 0
    exit_counts = [0] * MAX_EXIT_NUM # 维护持久的出口计数状态
    exit_weight_counts = [0] * MAX_EXIT_NUM # 维护持久的出口重量(g)状态
    dist_a = parse_distribution(args.dist)
    dist_b = parse_distribution(args.dist2) if args.dist2 else []
    start_time = time.time()
    cycles_done = 0
    
    try:
        seed_completed_batches(args)
        if args.stop_after_seed:
            return
        while True:
            if args.cycles is not None and cycles_done >= args.cycles:
                if SHOW_SEND_LOGS:
                    log_info("Simulation finished.")
                return

            # 1. 模拟数据增长
            increment = random.randint(args.min_inc, args.max_inc) # 每次增加 N 个
            current_yield += increment
            
            # 将增量分配给随机出口
            for _ in range(increment):
                dist = dist_a
                if args.alternate and dist_b:
                    dist = dist_b if (cycles_done % 2 == 1) else dist_a
                exit_idx = choose_exit_index(dist)

                if 0 <= exit_idx < MAX_EXIT_NUM:
                    exit_counts[exit_idx] += 1
                    w = random.randint(args.min_weight_g, args.max_weight_g)
                    exit_weight_counts[exit_idx] += w
                    current_total_weight += w
            
            if args.force_total_weight_from_exits:
                current_total_weight = sum(exit_weight_counts)
            
            # 计算合格/不合格 (95% 合格率)
            qualified = int(current_yield * 0.95)
            unqualified = current_yield - qualified
            
            # 模拟速度波动 (300-600 个/分钟)
            speed = random.randint(300, 600)
            
            # --- 2. 发送统计数据 ---
            if SHOW_SEND_LOGS:
                log_info(f"[Statistics] Yield: {current_yield}, Weight: {current_total_weight/1000:.2f}kg, Speed: {speed}/min")
            if args.print_percent:
                print_top_exits(exit_counts, exit_weight_counts, top_n=args.topn)
            stats_src_id = make_src_id(subsys_index=args.subsys, channel_index=args.stats_channel)
            stats_header = create_header_with_ids(FSM_CMD_STATISTICS, stats_src_id, HC_ID)
            stats_body = create_statistics(
                n_total_cup_num=current_yield,
                n_total_weight=current_total_weight,
                n_qualified_count=qualified,
                n_unqualified_count=unqualified,
                n_interval_sum_per_minute=speed,
                exit_counts=exit_counts,  # 传入持久化的出口计数
                exit_weight_counts=exit_weight_counts  # 传入持久化的出口重量(g)
            )
            if not args.dry_run:
                send_once(stats_header, stats_body, "Statistics")
            else:
                if SHOW_SEND_LOGS:
                    log_info(f"[DryRun] Statistics bytes: {len(stats_body)}")
            
            time.sleep(args.stats_interval_s)

            # --- 2.5 发送分级数据 (模拟两个通道的实时分级信息) ---
            # 48项目: FSM_CMD_GRADEINFO (StFruitGradeInfo)
            if not args.no_grade:
                for _ in range(random.randint(1, 2)):
                    ipm_index = args.grade_ipm
                    if ipm_index < 0:
                        ipm_index = random.randint(0, max(0, args.max_ipm - 1))
                    grade_src_id = make_src_id(subsys_index=args.subsys, ipm_index=ipm_index)
                    grade_header = create_header_with_ids(FSM_CMD_GRADEINFO, grade_src_id, HC_ID)
                    grade_body = create_grade_info(
                        channel0_exit=random.randint(0, 9),
                        channel1_exit=random.randint(0, 9),
                        route_id=0
                    )
                    if not args.dry_run:
                        send_once(grade_header, grade_body, "GradeInfo")
                    else:
                        if SHOW_SEND_LOGS:
                            log_info(f"[DryRun] GradeInfo bytes: {len(grade_body)}")
                    time.sleep(0.2)
            
            # --- 3. 发送重量数据 (模拟单个果实) ---
            # 随机发送 1-3 个单果数据
            if not args.no_weight:
                for _ in range(random.randint(1, 3)):
                    single_weight = random.randint(100, 250)
                    exit_id = random.randint(0, 9)
                    if SHOW_SEND_LOGS:
                        log_info(f"[WeightInfo] Weight: {single_weight}g, ExitIndex0: {exit_id}")
                    
                    weight_src_id = make_src_id(subsys_index=args.subsys, channel_index=args.weight_channel)
                    weight_header = create_header_with_ids(FSM_CMD_WEIGHTINFO, weight_src_id, HC_ID)
                    weight_body = create_weight_info(current_weight=single_weight, current_exit=exit_id)
                    if not args.dry_run:
                        send_once(weight_header, weight_body, "WeightInfo")
                    else:
                        if SHOW_SEND_LOGS:
                            log_info(f"[DryRun] WeightInfo bytes: {len(weight_body)}")
                    time.sleep(0.3)
            
            # --- 4. 发送等级设置信息 (UI表头) ---
            # 48项目: HC_CMD_GRADE_INFO (StGradeInfo)
            if not args.no_st_grade and (cycles_done % 5 == 0):
                st_grade_header = create_header_with_ids(HC_CMD_GRADE_INFO, FSM_ID, HC_ID)
                st_grade_body = create_st_grade_info()
                if not args.dry_run:
                    send_once(st_grade_header, st_grade_body, "StGradeInfo")
                else:
                    if SHOW_SEND_LOGS:
                        log_info(f"[DryRun] StGradeInfo bytes: {len(st_grade_body)}")
                time.sleep(0.2)

            # 等待下一轮
            cycles_done += 1
            time.sleep(args.loop_interval_s)

    except KeyboardInterrupt:
        if SHOW_SEND_LOGS:
            log_info("Simulation stopped by user.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Mock FSM device for HarmonyOS host")
    parser.add_argument("--ip", default=SERVER_IP, help="鸿蒙设备/模拟器IP（运行App的一侧）")
    parser.add_argument("--host", dest="ip", help="同 --ip 的别名")
    parser.add_argument("--port", type=int, default=SERVER_PORT)
    parser.add_argument("--control-port", type=int, default=CONTROL_PORT, help="PLC/控制端口（用于触发结束批次）")
    parser.add_argument("--cmd-server", action="store_true", help="启动命令接收服务（用于接收鸿蒙下发的测试/配置命令）")
    parser.add_argument("--cmd-server-only", action="store_true", help="仅启动命令接收服务，不发送统计数据")
    parser.add_argument("--no-cmd-server", action="store_true", help="不启动命令接收服务（仅作为客户端发送统计数据）")
    parser.add_argument("--cmd-port", type=int, default=CMD_SERVER_PORT, help="命令接收服务端口")
    parser.add_argument("--cmd-server-host", default="0.0.0.0", help="命令接收服务绑定IP")
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--seed-completed", type=int, default=0, help="预先生成N条已完成批次（需App支持END_CLEAR/END_SAVE）")
    parser.add_argument("--seed-completed-cycles", type=int, default=2, help="每条已完成批次发送统计包次数")
    parser.add_argument("--seed-completed-interval-s", type=float, default=0.6, help="预置批次发送间隔")
    parser.add_argument("--end-mode", default="clear", choices=["clear", "save", "alternate"], help="预置批次结束模式")
    parser.add_argument("--stop-after-seed", action="store_true", help="仅生成已完成批次后退出")

    parser.add_argument("--dist", default="1:60,2:30,3:10", help="出口分布，例: 1:60,2:30,3:10（出口号从1开始）")
    parser.add_argument("--dist2", default="", help="第二套出口分布（配合 --alternate 使用）")
    parser.add_argument("--alternate", action="store_true", help="每轮循环在 dist/dist2 之间交替，方便观察波浪快速变化")

    parser.add_argument("--min-inc", type=int, default=1)
    parser.add_argument("--max-inc", type=int, default=5)
    parser.add_argument("--min-weight-g", type=int, default=120)
    parser.add_argument("--max-weight-g", type=int, default=180)

    parser.add_argument("--stats-interval-s", type=float, default=1.0)
    parser.add_argument("--loop-interval-s", type=float, default=2.0)
    parser.add_argument("--cycles", type=int, default=None, help="循环次数（不填则无限循环）")

    parser.add_argument("--no-grade", action="store_true", help="不发送 FSM_CMD_GRADEINFO")
    parser.add_argument("--no-st-grade", action="store_true", help="不发送 HC_CMD_GRADE_INFO (StGradeInfo)")
    parser.add_argument("--no-weight", action="store_true", help="不发送 FSM_CMD_WEIGHTINFO")
    parser.add_argument("--dry-run", action="store_true", help="仅打印，不发TCP数据")
    parser.add_argument("--show-send-logs", action="store_true", help="显示客户端发送日志（默认只显示服务器收到的数据）")
    parser.add_argument("--log-file", default="", help="日志文件路径（为空则不写文件）")
    parser.add_argument("--log-level", default=LOG_LEVEL, help="日志级别：DEBUG/INFO/WARNING/ERROR")
    parser.add_argument("--no-log-console", action="store_true", help="不输出到控制台，仅写文件")

    parser.add_argument("--subsys", type=int, default=0, help="子系统索引(0-based)，影响 srcId 生成")
    parser.add_argument("--max-ipm", type=int, default=4, help="随机发送分级时的 IPM 个数(0-based count)")
    parser.add_argument("--grade-ipm", type=int, default=-1, help="固定分级包来源 IPM 索引(0-based)，-1 表示随机")
    parser.add_argument("--stats-channel", type=int, default=0, help="统计包来源通道索引(0-11)")
    parser.add_argument("--weight-channel", type=int, default=0, help="重量包来源通道索引(0-11)")

    parser.add_argument("--print-percent", action="store_true", help="打印出口占比TopN（与鸿蒙 EXIT_PERCENT 逻辑一致）")
    parser.add_argument("--topn", type=int, default=6)
    parser.add_argument("--force-total-weight-from-exits", action="store_true", help="让 totalWeight 始终等于各出口重量之和")

    args = parser.parse_args()

    SERVER_IP = args.ip
    SERVER_PORT = args.port
    SHOW_SEND_LOGS = bool(args.show_send_logs)
    LOG_FILE = args.log_file or None
    LOG_TO_CONSOLE = not args.no_log_console
    LOGGER = setup_logging(LOG_FILE, args.log_level, LOG_TO_CONSOLE)
    if args.seed is not None:
        random.seed(args.seed)

    if args.cmd_server_only:
        run_cmd_server(args)
    else:
        if not args.no_cmd_server:
            import threading
            t = threading.Thread(target=run_cmd_server, args=(args,), daemon=True)
            t.start()
        run_simulation(args)
