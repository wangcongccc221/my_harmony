#!/usr/bin/env python3
import argparse
import socket
import struct
from pathlib import Path

SYNC = b"SYNC"
STGLOBAL_SIZE = 29328


def decode_ttt_text(path: Path) -> bytes:
    s = path.read_text(encoding='utf-8', errors='ignore')
    return s.encode('utf-8').decode('unicode_escape').encode('latin1', 'ignore')


def locate_stglobal_start(raw: bytes) -> int:
    key = b'Dec '
    p = raw.find(key)
    if p < 0:
        raise RuntimeError("cannot find date signature 'Dec ' in decoded data")
    # cFSMInfo offset in StGlobal(MAX64)
    start = p - 29292
    if start < 0 or start + STGLOBAL_SIZE > len(raw):
        raise RuntimeError(f"calculated StGlobal range invalid: start={start}")
    return start


def build_packet(src: int, dst: int, cmd: int, payload: bytes) -> bytes:
    return SYNC + struct.pack('<iii', src, dst, cmd) + payload


def send_packet(host: str, port: int, packet: bytes, timeout: float) -> None:
    with socket.create_connection((host, port), timeout=timeout) as s:
        s.sendall(packet)


def main():
    ap = argparse.ArgumentParser(description='Extract StGlobal from ttt.txt and send to Harmony TCP server.')
    ap.add_argument('--ttt', default='E:/NEW/MY_HARMONY/ttt.txt', help='input escaped ttt.txt')
    ap.add_argument('--host', default='127.0.0.1')
    ap.add_argument('--port', type=int, default=1128)
    ap.add_argument('--src', type=lambda x: int(x, 0), default=0x0100)
    ap.add_argument('--dst', type=lambda x: int(x, 0), default=0x1000)
    ap.add_argument('--cmd', type=lambda x: int(x, 0), default=0x1000, help='FSM_CMD_CONFIG default 0x1000')
    ap.add_argument('--start', type=int, default=-1, help='manual payload start offset in decoded bytes')
    ap.add_argument('--timeout', type=float, default=5.0)
    ap.add_argument('--dump', default='E:/NEW/MY_HARMONY/ttt_global_packet.bin', help='dump packet path')
    args = ap.parse_args()

    ttt_path = Path(args.ttt)
    raw = decode_ttt_text(ttt_path)

    if args.start >= 0:
        start = args.start
    else:
        start = locate_stglobal_start(raw)

    payload = raw[start:start + STGLOBAL_SIZE]
    if len(payload) != STGLOBAL_SIZE:
        raise RuntimeError(f'payload size invalid: {len(payload)} != {STGLOBAL_SIZE}')

    packet = build_packet(args.src, args.dst, args.cmd, payload)

    Path(args.dump).write_bytes(packet)
    send_packet(args.host, args.port, packet, args.timeout)

    print('send ok')
    print(f'ttt={ttt_path}')
    print(f'decoded_bytes={len(raw)} start={start} payload={len(payload)}')
    print(f'host={args.host} port={args.port}')
    print(f'src=0x{args.src:04X} dst=0x{args.dst:04X} cmd=0x{args.cmd:04X}')
    print(f'packet_dump={args.dump} total={len(packet)}')


if __name__ == '__main__':
    main()
