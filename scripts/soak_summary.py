#!/usr/bin/env python3
"""
Summarize soak_report.json produced by http_db_soak_test.py.
"""
from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path
from typing import Dict, Iterable, Tuple


def _aggregate(records: Iterable[dict], key_func) -> Dict[Tuple[str, ...], Dict[str, float]]:
    stats = defaultdict(lambda: {"total": 0, "success": 0, "fail": 0, "elapsed": 0.0})
    for rec in records:
        key = key_func(rec)
        bucket = stats[key]
        bucket["total"] += 1
        if rec.get("success"):
            bucket["success"] += 1
        else:
            bucket["fail"] += 1
        bucket["elapsed"] += float(rec.get("elapsed", 0.0))
    return stats


def format_stats(name: str, stats: Dict[str, float]) -> str:
    total = stats["total"]
    avg_ms = (stats["elapsed"] / total * 1000) if total else 0.0
    success = stats["success"]
    fail = stats["fail"]
    succ_rate = success / total * 100 if total else 0.0
    return (
        f"{name:<18s} | total={total:6d} | success={success:6d} "
        f"| fail={fail:4d} | succ%={succ_rate:6.2f} | avg={avg_ms:8.1f} ms"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Summarize soak_report.json results")
    parser.add_argument(
        "--report",
        default="soak_report.json",
        help="Path to JSON report file (default: soak_report.json)",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=10,
        help="Number of phase+op combinations to show (default: 10)",
    )
    args = parser.parse_args()

    report_path = Path(args.report)
    if not report_path.exists():
        raise SystemExit(f"Report file not found: {report_path}")

    with report_path.open("r", encoding="utf-8") as fp:
        data = json.load(fp)

    by_phase = _aggregate(data, lambda rec: (rec["phase"].split("-")[0],))
    by_op = _aggregate(data, lambda rec: (rec["op"],))
    by_phase_op = _aggregate(data, lambda rec: (rec["phase"], rec["op"]))

    print("\n=== Stats by phase ===")
    for key in sorted(by_phase.keys()):
        print(format_stats(key[0], by_phase[key]))

    print("\n=== Stats by operation ===")
    for key in sorted(by_op.keys()):
        print(format_stats(key[0], by_op[key]))

    print(f"\n=== Top {args.top} phase/op combos ===")
    for (phase, op), stats in sorted(by_phase_op.items(), key=lambda kv: -kv[1]["total"])[: args.top]:
        name = f"{phase} | {op}"
        print(format_stats(name, stats))


if __name__ == "__main__":
    main()


