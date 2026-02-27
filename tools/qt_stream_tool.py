#!/usr/bin/env python3
import argparse
import socket
import struct
from pathlib import Path

SYNC = b"SYNC"  # little-endian int 0x434E5953 in your C++


def parse_header(pkt: bytes):
    if len(pkt) < 16:
        return None
    if pkt[:4] != SYNC:
        return None
    src, dst, cmd = struct.unpack('<iii', pkt[4:16])
    return src, dst, cmd


def split_by_sync(data: bytes):
    idxs = []
    i = 0
    while True:
        j = data.find(SYNC, i)
        if j < 0:
            break
        idxs.append(j)
        i = j + 1
    packets = []
    for k, start in enumerate(idxs):
        end = idxs[k + 1] if k + 1 < len(idxs) else len(data)
        pkt = data[start:end]
        if len(pkt) >= 16:
            packets.append(pkt)
    return packets


def cmd_list(args):
    data = Path(args.input).read_bytes()
    packets = split_by_sync(data)
    print(f"found packets: {len(packets)}")
    for i, pkt in enumerate(packets):
        h = parse_header(pkt)
        if not h:
            continue
        src, dst, cmd = h
        payload_len = len(pkt) - 16
        print(f"#{i:03d} src=0x{src:04X} dst=0x{dst:04X} cmd=0x{cmd:04X} payload={payload_len} total={len(pkt)}")


def cmd_export(args):
    data = Path(args.input).read_bytes()
    packets = split_by_sync(data)
    if args.index < 0 or args.index >= len(packets):
        raise SystemExit(f"index out of range: {args.index}, total={len(packets)}")
    pkt = packets[args.index]
    out = Path(args.output)
    out.write_bytes(pkt)
    payload_out = out.with_suffix(out.suffix + '.payload.bin')
    payload_out.write_bytes(pkt[16:])
    src, dst, cmd = parse_header(pkt)
    print(f"exported packet #{args.index} -> {out}")
    print(f"header: src=0x{src:04X} dst=0x{dst:04X} cmd=0x{cmd:04X}")
    print(f"payload bytes: {len(pkt)-16}")
    print(f"payload file: {payload_out}")


def cmd_send(args):
    pkt = Path(args.packet).read_bytes()
    h = parse_header(pkt)
    if not h:
        raise SystemExit('invalid packet: need raw [SYNC(4)+src(4)+dst(4)+cmd(4)+payload]')
    src, dst, cmd = h
    with socket.create_connection((args.host, args.port), timeout=args.timeout) as s:
        s.sendall(pkt)
    print(f"sent: {len(pkt)} bytes to {args.host}:{args.port}")
    print(f"header: src=0x{src:04X} dst=0x{dst:04X} cmd=0x{cmd:04X}")


def cmd_build(args):
    payload = Path(args.payload).read_bytes() if args.payload else b''
    pkt = SYNC + struct.pack('<iii', args.src, args.dst, args.cmd) + payload
    Path(args.output).write_bytes(pkt)
    print(f"built packet: {args.output}")
    print(f"header: src=0x{args.src:04X} dst=0x{args.dst:04X} cmd=0x{args.cmd:04X}")
    print(f"payload bytes: {len(payload)}")


def main():
    p = argparse.ArgumentParser(description='Qt/Harmony TCP raw packet helper')
    sub = p.add_subparsers(dest='sub', required=True)

    p_list = sub.add_parser('list', help='list packets from a raw byte stream file')
    p_list.add_argument('-i', '--input', required=True, help='raw stream file')
    p_list.set_defaults(func=cmd_list)

    p_exp = sub.add_parser('export', help='export one packet by index')
    p_exp.add_argument('-i', '--input', required=True)
    p_exp.add_argument('-n', '--index', required=True, type=int)
    p_exp.add_argument('-o', '--output', required=True)
    p_exp.set_defaults(func=cmd_export)

    p_send = sub.add_parser('send', help='send one raw packet to server')
    p_send.add_argument('-p', '--packet', required=True)
    p_send.add_argument('--host', required=True)
    p_send.add_argument('--port', required=True, type=int)
    p_send.add_argument('--timeout', type=float, default=5.0)
    p_send.set_defaults(func=cmd_send)

    p_build = sub.add_parser('build', help='build one raw packet from payload file')
    p_build.add_argument('-o', '--output', required=True)
    p_build.add_argument('--src', required=True, type=lambda x: int(x, 0))
    p_build.add_argument('--dst', required=True, type=lambda x: int(x, 0))
    p_build.add_argument('--cmd', required=True, type=lambda x: int(x, 0))
    p_build.add_argument('--payload', help='payload bin file')
    p_build.set_defaults(func=cmd_build)

    args = p.parse_args()
    args.func(args)


if __name__ == '__main__':
    main()
