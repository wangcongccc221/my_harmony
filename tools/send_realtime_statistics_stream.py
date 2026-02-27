#!/usr/bin/env python3
"""
发送连续 FSM_CMD_STATISTICS 字节流到鸿蒙 TCP 服务（用于实时统计联调）

默认行为：
- 协议头沿用当前项目工具脚本格式：SYNC + <src,dst,cmd> + payload
- 每秒发送 1 次
- 默认发送 2 分钟
- 默认给子系统 1 和 2 都发（src=0x0100 / 0x0200）
"""

import argparse
import socket
import struct
import time
from typing import Dict, List, Tuple

SYNC = b"SYNC"
CMD_FSM_STATISTICS = 0x1001

MAX_QUALITY_GRADE_NUM = 16
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 64
MAX_CHANNEL_NUM = 12
MAX_NOTICE_LENGTH = 30

GRADE_N = MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM  # 256
EXPECTED_PAYLOAD_SIZE = 7764


class SubsysState:
    def __init__(self, subsys_id: int) -> None:
        self.subsys_id = subsys_id
        self.total_cup = 0
        self.total_weight_g = 0.0
        self.tick = 0


def build_statistics_payload(state: SubsysState, speed: int, profile: str) -> Tuple[bytes, Dict[str, int]]:
    state.tick += 1

    # 每次新增一批数据，保证曲线会动
    delta_yield = 20 + (state.tick % 8) * 3 + state.subsys_id
    delta_weight_g = float(delta_yield * (185 + (state.tick % 5) * 6))
    state.total_cup += delta_yield
    state.total_weight_g += delta_weight_g

    n_grade_count: List[int] = [0] * GRADE_N
    n_weight_grade_count: List[float] = [0.0] * GRADE_N
    n_box_grade_count: List[int] = [0] * GRADE_N
    n_box_grade_weight: List[float] = [0.0] * GRADE_N

    # 生成等级分布（可切换 profile）
    if profile == "feature":
        # 更偏向“特征分组”的分布：每 16 个 grade 为一个分组
        for q in range(16):
            group_base = 6 + ((q + state.subsys_id + state.tick) % 5)
            for s in range(16):
                idx = q * 16 + s
                c = group_base * (1 + (s % 3))
                w = float(c * (170 + q * 2 + s))
                n_grade_count[idx] = c
                n_weight_grade_count[idx] = w
                n_box_grade_count[idx] = max(0, c // 12)
                n_box_grade_weight[idx] = w
    else:
        # compact：仅前几个等级有值
        for i in range(8):
            c = int(delta_yield * (1 + (i % 3)))
            w = float(c * (180 + i * 5))
            n_grade_count[i] = c
            n_weight_grade_count[i] = w
            n_box_grade_count[i] = max(0, c // 12)
            n_box_grade_weight[i] = w

    n_exit_count: List[int] = [0] * MAX_EXIT_NUM
    n_exit_weight_count: List[float] = [0.0] * MAX_EXIT_NUM
    for i in range(6):
        c = int(delta_yield * (i + 1) / 6)
        w = float(c * (190 + i * 4))
        n_exit_count[i] = c
        n_exit_weight_count[i] = w

    n_channel_total_count: List[int] = [0] * MAX_CHANNEL_NUM
    n_channel_weight_count: List[float] = [0.0] * MAX_CHANNEL_NUM
    for i in range(2):
        n_channel_total_count[i] = state.total_cup // 2
        n_channel_weight_count[i] = state.total_weight_g / 2.0

    n_subsys_id = state.subsys_id
    n_total_cup_num = state.total_cup
    n_interval = 20
    n_interval_sum_per_minute = speed
    n_cup_state = 0x0003
    n_pulse_interval = 1450
    n_unpush_fruit_count = 0
    n_net_state = 0
    n_weight_setting = 1
    n_scm_state = 0
    n_iqs_net_state = 0
    n_lock_state = 0
    exit_box_num: List[int] = [0] * MAX_EXIT_NUM
    exit_weight: List[float] = [0.0] * MAX_EXIT_NUM
    for i in range(6):
        exit_box_num[i] = n_exit_count[i] // 12
        exit_weight[i] = n_exit_weight_count[i]

    notice = bytearray(MAX_NOTICE_LENGTH)
    text = f"RT{subsys_id_to_text(state.subsys_id)}#{state.tick}"
    raw = text.encode("ascii", errors="ignore")[:MAX_NOTICE_LENGTH]
    notice[: len(raw)] = raw

    buf = bytearray()
    buf += struct.pack("<" + "I" * GRADE_N, *n_grade_count)
    buf += struct.pack("<" + "d" * GRADE_N, *n_weight_grade_count)
    buf += struct.pack("<" + "I" * MAX_EXIT_NUM, *n_exit_count)
    buf += struct.pack("<" + "d" * MAX_EXIT_NUM, *n_exit_weight_count)
    buf += struct.pack("<" + "I" * MAX_CHANNEL_NUM, *n_channel_total_count)
    buf += struct.pack("<" + "d" * MAX_CHANNEL_NUM, *n_channel_weight_count)
    buf += struct.pack("<i", n_subsys_id)
    buf += struct.pack("<" + "i" * GRADE_N, *n_box_grade_count)
    buf += struct.pack("<" + "d" * GRADE_N, *n_box_grade_weight)
    buf += struct.pack("<iii", n_total_cup_num, n_interval, n_interval_sum_per_minute)
    buf += struct.pack("<HHH", n_cup_state, n_pulse_interval, n_unpush_fruit_count)
    buf += struct.pack("<HH", n_net_state, n_weight_setting)
    buf += struct.pack("<H", 0)  # pack(4) 对齐到 nSCMState
    buf += struct.pack("<i", n_scm_state)
    buf += struct.pack("<H", n_iqs_net_state)
    buf += struct.pack("<B", n_lock_state)
    buf += struct.pack("<B", 0)  # pack(2) 对齐到 ExitBoxNum
    buf += struct.pack("<" + "H" * MAX_EXIT_NUM, *exit_box_num)
    buf += struct.pack("<" + "d" * MAX_EXIT_NUM, *exit_weight)
    buf += bytes(notice)

    if len(buf) % 4 != 0:
        buf += b"\x00" * (4 - (len(buf) % 4))

    if len(buf) != EXPECTED_PAYLOAD_SIZE:
        raise RuntimeError(f"payload size mismatch: {len(buf)} != {EXPECTED_PAYLOAD_SIZE}")
    summary = {
        "grade0": int(n_grade_count[0]),
        "grade1": int(n_grade_count[1]),
        "grade16": int(n_grade_count[16]),
        "grade32": int(n_grade_count[32]),
        "exit0": int(n_exit_count[0]),
        "exit1": int(n_exit_count[1]),
    }
    return bytes(buf), summary


def build_packet(src: int, dst: int, cmd: int, payload: bytes) -> bytes:
    return SYNC + struct.pack("<iii", src, dst, cmd) + payload


def send_packet(host: str, port: int, packet: bytes, timeout: float) -> None:
    with socket.create_connection((host, port), timeout=timeout) as s:
        s.sendall(packet)


def subsys_id_to_text(subsys_id: int) -> str:
    return str(subsys_id)


def parse_subsystems(text: str) -> List[int]:
    out: List[int] = []
    for part in text.split(","):
        part = part.strip()
        if not part:
            continue
        v = int(part)
        if v < 1 or v > 4:
            raise ValueError("subsystem id must be 1..4")
        out.append(v)
    if not out:
        out = [1]
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description="连续发送实时统计字节流（FSM_CMD_STATISTICS）")
    parser.add_argument("--host", default="127.0.0.1", help="鸿蒙 TCP 服务地址")
    parser.add_argument("--port", type=int, default=1128, help="鸿蒙 TCP 服务端口")
    parser.add_argument("--dst", type=lambda x: int(x, 0), default=0x1000, help="目标ID (HC_ID)")
    parser.add_argument("--cmd", type=lambda x: int(x, 0), default=CMD_FSM_STATISTICS, help="命令ID")
    parser.add_argument("--subsystems", default="1,2", help="发送子系统列表，例如: 1 或 1,2")
    parser.add_argument("--interval", type=float, default=1.0, help="发送间隔秒")
    parser.add_argument("--duration", type=int, default=120, help="总时长秒")
    parser.add_argument("--speed", type=int, default=1200, help="nIntervalSumperminute 基准值")
    parser.add_argument("--profile", choices=["feature", "compact"], default="feature",
                        help="等级数据分布模式: feature(推荐,更接近接口联调) / compact(前8级)")
    parser.add_argument("--dry-run", action="store_true", help="只生成并打印，不发网络包")
    parser.add_argument("--timeout", type=float, default=3.0)
    args = parser.parse_args()

    subsystems = parse_subsystems(args.subsystems)
    states: Dict[int, SubsysState] = {sid: SubsysState(sid) for sid in subsystems}

    rounds = max(1, int(args.duration / args.interval))
    print(f"[START] host={args.host} port={args.port} subsystems={subsystems} rounds={rounds} interval={args.interval}s profile={args.profile}")

    for r in range(rounds):
        for sid in subsystems:
            src = (sid << 8)  # 0x0100 / 0x0200 ...
            state = states[sid]
            dynamic_speed = args.speed + (r % 15) * 20 + sid * 5
            payload, summary = build_statistics_payload(state, dynamic_speed, args.profile)
            packet = build_packet(src, args.dst, args.cmd, payload)
            if not args.dry_run:
                send_packet(args.host, args.port, packet, args.timeout)
            print(
                f"[SEND] round={r+1}/{rounds} sid={sid} src=0x{src:04X} "
                f"yield_total={state.total_cup} weight_total_g={int(state.total_weight_g)} "
                f"speed={dynamic_speed} payload={len(payload)} total={len(packet)} "
                f"g0={summary['grade0']} g1={summary['grade1']} g16={summary['grade16']} g32={summary['grade32']}"
            )
        time.sleep(args.interval)

    print("[DONE] realtime statistics stream finished.")


if __name__ == "__main__":
    main()
