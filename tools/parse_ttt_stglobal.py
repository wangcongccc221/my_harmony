#!/usr/bin/env python3
import argparse
import struct
from pathlib import Path

STGLOBAL_SIZE = 29328
CFSM_OFFSET = 29292
CIPM_OFFSET = 29304


def decode_escaped_text(path: Path) -> bytes:
    s = path.read_text(encoding='utf-8', errors='ignore')
    # ttt.txt is escaped text like: \x00\x7F\n ...
    return s.encode('utf-8').decode('unicode_escape').encode('latin1', 'ignore')


def u16(buf: bytes, off: int, le: bool) -> int:
    return struct.unpack('<H' if le else '>H', buf[off:off+2])[0]


def i32(buf: bytes, off: int, le: bool) -> int:
    return struct.unpack('<i' if le else '>i', buf[off:off+4])[0]


def locate_candidates(raw: bytes):
    # Heuristic: cFSMInfo often contains compile date like "Dec 10 2025"
    keys = [b'Dec ', b'Jan ', b'Feb ', b'Mar ', b'Apr ', b'May ', b'Jun ', b'Jul ', b'Aug ', b'Sep ', b'Oct ', b'Nov ']
    pos = []
    for k in keys:
        i = 0
        while True:
            j = raw.find(k, i)
            if j < 0:
                break
            pos.append(j)
            i = j + 1
    pos = sorted(set(pos))

    starts = []
    for p in pos:
        st = p - CFSM_OFFSET
        if st >= 0 and st + STGLOBAL_SIZE <= len(raw):
            starts.append(st)
    return sorted(set(starts))


def dump_one(raw: bytes, start: int):
    g = raw[start:start+STGLOBAL_SIZE]
    c_fsm = g[CFSM_OFFSET:CFSM_OFFSET+12]
    c_ipm = g[CIPM_OFFSET:CIPM_OFFSET+12]

    print(f'candidate_start={start}, size={len(g)}')
    print(f'cFSMInfo={c_fsm!r}')
    print(f'cIPMInfo={c_ipm!r}')

    for le in (True, False):
        tag = 'LE' if le else 'BE'
        nSubsysId = i32(g, 29316, le)
        nVersion = i32(g, 29320, le)
        nNetState = u16(g, 29324, le)
        nFsmRestart = g[29326]
        nFsmModule = g[29327]
        print(f'[{tag}] nSubsysId={nSubsysId}, nVersion={nVersion}, nNetState={nNetState}, nFsmRestart={nFsmRestart}, nFsmModule={nFsmModule}')


def main():
    ap = argparse.ArgumentParser(description='Decode ttt.txt escaped bytes and try parse Qt StGlobal (MAX64 layout).')
    ap.add_argument('-i', '--input', default='E:/NEW/MY_HARMONY/ttt.txt')
    ap.add_argument('-o', '--output', default='E:/NEW/MY_HARMONY/ttt_decoded.bin', help='save decoded raw bytes')
    args = ap.parse_args()

    inp = Path(args.input)
    raw = decode_escaped_text(inp)
    Path(args.output).write_bytes(raw)

    print(f'decoded_bytes={len(raw)} -> {args.output}')
    cands = locate_candidates(raw)
    print(f'stglobal_candidates={len(cands)}: {cands[:10]}')

    if not cands:
        print('No candidate found by date-signature; you can inspect raw manually.')
        return

    for st in cands[:5]:
        dump_one(raw, st)


if __name__ == '__main__':
    main()
