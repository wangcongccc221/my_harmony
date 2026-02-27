#!/usr/bin/env python3
import argparse
import socket
import struct
from pathlib import Path

SYNC = b"SYNC"  # 0x434E5953 little-endian
CMD_FSM_STATISTICS = 0x1001

MAX_QUALITY_GRADE_NUM = 16
MAX_SIZE_GRADE_NUM = 16
MAX_EXIT_NUM = 64
MAX_CHANNEL_NUM = 12
MAX_NOTICE_LENGTH = 30


def build_statistics_payload() -> bytes:
    grade_n = MAX_QUALITY_GRADE_NUM * MAX_SIZE_GRADE_NUM  # 256

    nGradeCount = [1000 + i for i in range(grade_n)]
    nWeightGradeCount = [float(5000 + i * 3) / 10.0 for i in range(grade_n)]
    nExitCount = [200 + i for i in range(MAX_EXIT_NUM)]
    nExitWeightCount = [float(10000 + i * 7) / 10.0 for i in range(MAX_EXIT_NUM)]
    nChannelTotalCount = [3000 + i * 11 for i in range(MAX_CHANNEL_NUM)]
    nChannelWeightCount = [float(8000 + i * 13) / 10.0 for i in range(MAX_CHANNEL_NUM)]
    nSubsysId = 1
    nBoxGradeCount = [10 + (i % 8) for i in range(grade_n)]
    nBoxGradeWeight = [float(1200 + i * 2) / 10.0 for i in range(grade_n)]
    nTotalCupNum = 54321
    nInterval = 20
    nIntervalSumperminute = 1234
    nCupState = 0x0003
    nPulseInterval = 1450
    nUnpushFruitCount = 2
    nNetState = 0x0000
    nWeightSetting = 1
    nSCMState = 0
    nIQSNetState = 0
    nLockState = 0
    ExitBoxNum = [i % 50 for i in range(MAX_EXIT_NUM)]
    ExitWeight = [float(2000 + i * 5) / 10.0 for i in range(MAX_EXIT_NUM)]
    notice_text = "MOCK_STATS_OK"
    Notice = bytearray(MAX_NOTICE_LENGTH)
    raw = notice_text.encode("ascii", errors="ignore")[:MAX_NOTICE_LENGTH]
    Notice[:len(raw)] = raw

    buf = bytearray()
    buf += struct.pack('<' + 'I' * grade_n, *nGradeCount)
    buf += struct.pack('<' + 'd' * grade_n, *nWeightGradeCount)
    buf += struct.pack('<' + 'I' * MAX_EXIT_NUM, *nExitCount)
    buf += struct.pack('<' + 'd' * MAX_EXIT_NUM, *nExitWeightCount)
    buf += struct.pack('<' + 'I' * MAX_CHANNEL_NUM, *nChannelTotalCount)
    buf += struct.pack('<' + 'd' * MAX_CHANNEL_NUM, *nChannelWeightCount)
    buf += struct.pack('<i', nSubsysId)
    buf += struct.pack('<' + 'i' * grade_n, *nBoxGradeCount)
    buf += struct.pack('<' + 'd' * grade_n, *nBoxGradeWeight)
    buf += struct.pack('<iii', nTotalCupNum, nInterval, nIntervalSumperminute)
    buf += struct.pack('<HHH', nCupState, nPulseInterval, nUnpushFruitCount)
    buf += struct.pack('<HH', nNetState, nWeightSetting)
    buf += struct.pack('<H', 0)  # pack(4) padding before nSCMState
    buf += struct.pack('<i', nSCMState)
    buf += struct.pack('<H', nIQSNetState)
    buf += struct.pack('<B', nLockState)
    buf += struct.pack('<B', 0)  # pack(2) padding before ExitBoxNum
    buf += struct.pack('<' + 'H' * MAX_EXIT_NUM, *ExitBoxNum)
    buf += struct.pack('<' + 'd' * MAX_EXIT_NUM, *ExitWeight)
    buf += bytes(Notice)

    # tail padding to align struct size to 4
    if len(buf) % 4 != 0:
        buf += b'\x00' * (4 - (len(buf) % 4))

    expected = 7764
    if len(buf) != expected:
        raise RuntimeError(f"StStatistics payload size mismatch: {len(buf)} != {expected}")
    return bytes(buf)


def build_packet(src: int, dst: int, cmd: int, payload: bytes) -> bytes:
    return SYNC + struct.pack('<iii', src, dst, cmd) + payload


def send_packet(host: str, port: int, packet: bytes, timeout: float) -> None:
    with socket.create_connection((host, port), timeout=timeout) as s:
        s.sendall(packet)


def main() -> None:
    parser = argparse.ArgumentParser(description='Send one realistic mock StStatistics packet to Harmony TCP server.')
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=1128)
    parser.add_argument('--src', type=lambda x: int(x, 0), default=0x0100)
    parser.add_argument('--dst', type=lambda x: int(x, 0), default=0x1000)
    parser.add_argument('--cmd', type=lambda x: int(x, 0), default=CMD_FSM_STATISTICS)
    parser.add_argument('--timeout', type=float, default=5.0)
    parser.add_argument('--dump', default='', help='optional output file path for raw packet')
    args = parser.parse_args()

    payload = build_statistics_payload()
    packet = build_packet(args.src, args.dst, args.cmd, payload)

    if args.dump:
        Path(args.dump).write_bytes(packet)

    send_packet(args.host, args.port, packet, args.timeout)

    print('send ok')
    print(f'host={args.host} port={args.port}')
    print(f'src=0x{args.src:04X} dst=0x{args.dst:04X} cmd=0x{args.cmd:04X}')
    print(f'payload={len(payload)} total={len(packet)}')
    print('sample: nGradeCount[0]=1000 nWeightGradeCount[0]=500.0 ExitWeight[0]=200.0')


if __name__ == '__main__':
    main()
