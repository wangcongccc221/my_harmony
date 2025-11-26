#!/usr/bin/env python3
"""
HTTP + Database Soak/Stress Test
--------------------------------

Runs a one-hour (by default) mixed workload against the Harmony HTTP API that
drives the database. The workload cycles through three phases repeatedly:

1. Normal phase  : light concurrency, mostly paged queries.
2. Pressure phase: higher concurrency, frequent full-table scans + inserts.
3. Recovery phase: lower concurrency, only lightweight paged queries.

Usage:
    python http_db_soak_test.py --base-url http://127.0.0.1:8080 \
        --total-duration 3600 --normal-duration 120 --pressure-duration 60 \
        --recovery-duration 60
"""

from __future__ import annotations

import argparse
import collections
import json
import random
import string
import threading
import time
from dataclasses import dataclass
from typing import Dict, List, Sequence, Tuple

import requests


OperationResult = collections.namedtuple(
    "OperationResult", ["phase", "op", "success", "status", "elapsed", "error"]
)


@dataclass
class PhaseConfig:
    name: str
    duration: float
    concurrency: int
    delay_range: Tuple[float, float]
    op_weights: Sequence[Tuple[str, float]]


def random_string(length: int = 8) -> str:
    letters = string.ascii_letters
    return "".join(random.choice(letters) for _ in range(length))


def perform_operation(session: requests.Session, base_url: str, op: str) -> Tuple[bool, int, str]:
    """
    Execute a single HTTP operation and return (success, status_code, error_msg).
    """
    try:
        if op == "list_page":
            page = random.randint(1, 5)
            size = random.choice([20, 50, 100])
            resp = session.get(
                f"{base_url}/api/processing",
                params={"page": page, "size": size},
                timeout=15,
            )
        elif op == "list_full":
            resp = session.get(
                f"{base_url}/api/processing",
                params={"action": "listJsonLite"},
                timeout=45,
            )
        elif op == "insert_dummy":
            payload = {
                "customerName": f"测试客户-{random_string(4)}",
                "farmName": f"农场-{random.randint(1, 50)}",
                "fruitName": random.choice(["苹果", "梨子", "草莓", "蓝莓"]),
                "status": random.choice(["已完成", "进行中", "待开始"]),
                "startTime": time.strftime("%Y-%m-%d %H:%M:%S"),
                "endTime": time.strftime("%Y-%m-%d %H:%M:%S"),
                "weight": round(random.uniform(10, 500), 2),
                "quantity": random.randint(1, 100),
            }
            resp = session.post(
                f"{base_url}/api/processing",
                json=payload,
                timeout=15,
            )
        else:
            raise ValueError(f"未知的操作: {op}")

        ok = resp.status_code == 200
        err = "" if ok else f"HTTP {resp.status_code} {resp.text[:120]}"
        return ok, resp.status_code, err
    except Exception as exc:  # noqa: BLE001 - we need broad catch for soak testing
        return False, -1, str(exc)


def weighted_choice(weights: Sequence[Tuple[str, float]]) -> str:
    ops, probs = zip(*weights)
    total = sum(probs)
    pick = random.uniform(0, total)
    cumulative = 0.0
    for op, weight in zip(ops, probs):
        cumulative += weight
        if pick <= cumulative:
            return op
    return ops[-1]


def run_phase(
    base_url: str,
    phase: PhaseConfig,
    metrics: List[OperationResult],
    metrics_lock: threading.Lock,
) -> None:
    """
    Spin up `phase.concurrency` worker threads that continuously issue requests
    until phase.duration seconds elapsed.
    """
    stop_time = time.time() + phase.duration
    stop_event = threading.Event()
    delay_min, delay_max = phase.delay_range

    def worker(worker_id: int) -> None:
        session = requests.Session()
        while not stop_event.is_set():
            now = time.time()
            if now >= stop_time:
                break
            op = weighted_choice(phase.op_weights)
            start = time.perf_counter()
            success, status, err = perform_operation(session, base_url, op)
            elapsed = time.perf_counter() - start
            with metrics_lock:
                metrics.append(
                    OperationResult(
                        phase=phase.name,
                        op=op,
                        success=success,
                        status=status,
                        elapsed=elapsed,
                        error=err,
                    )
                )
            sleep_interval = random.uniform(delay_min, delay_max)
            time.sleep(sleep_interval)

    threads = [
        threading.Thread(target=worker, name=f"{phase.name}-worker-{i}", args=(i,))
        for i in range(phase.concurrency)
    ]
    for t in threads:
        t.daemon = True
        t.start()
    for t in threads:
        t.join(max(0, stop_time - time.time()))
    stop_event.set()


def summarize_metrics(metrics: List[OperationResult]) -> str:
    summary: Dict[Tuple[str, str], Dict[str, float]] = {}
    for rec in metrics:
        key = (rec.phase, rec.op)
        bucket = summary.setdefault(
            key, {"total": 0, "success": 0, "fail": 0, "elapsed_sum": 0.0}
        )
        bucket["total"] += 1
        if rec.success:
            bucket["success"] += 1
        else:
            bucket["fail"] += 1
        bucket["elapsed_sum"] += rec.elapsed

    lines = [
        "Phase/Op                           Total   Success   Fail   Avg Latency (ms)",
        "---------------------------------------------------------------------------",
    ]
    for (phase, op), stats in sorted(summary.items()):
        avg_ms = (stats["elapsed_sum"] / stats["total"]) * 1000.0 if stats["total"] else 0.0
        lines.append(
            f"{phase:12s} | {op:12s} |"
            f" {stats['total']:6d} | {stats['success']:7d} | {stats['fail']:5d}"
            f" | {avg_ms:9.1f}"
        )
    return "\n".join(lines)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="HTTP + DB Soak Test Runner")
    parser.add_argument("--base-url", default="http://127.0.0.1:8080", help="HTTP 服务基础地址")
    parser.add_argument("--total-duration", type=int, default=3600, help="总运行秒数 (默认 1 小时)")
    parser.add_argument("--normal-duration", type=int, default=120, help="普通阶段时长 (秒)")
    parser.add_argument("--pressure-duration", type=int, default=60, help="压力阶段时长 (秒)")
    parser.add_argument("--recovery-duration", type=int, default=60, help="恢复阶段时长 (秒)")
    parser.add_argument("--normal-concurrency", type=int, default=5, help="普通阶段并发数")
    parser.add_argument("--pressure-concurrency", type=int, default=12, help="压力阶段并发数")
    parser.add_argument("--recovery-concurrency", type=int, default=3, help="恢复阶段并发数")
    parser.add_argument("--normal-delay-min", type=float, default=0.8, help="普通阶段单次请求最小间隔 (秒)")
    parser.add_argument("--normal-delay-max", type=float, default=1.6, help="普通阶段单次请求最大间隔 (秒)")
    parser.add_argument("--pressure-delay-min", type=float, default=0.05, help="压力阶段单次请求最小间隔 (秒)")
    parser.add_argument("--pressure-delay-max", type=float, default=0.15, help="压力阶段单次请求最大间隔 (秒)")
    parser.add_argument("--recovery-delay-min", type=float, default=1.5, help="恢复阶段单次请求最小间隔 (秒)")
    parser.add_argument("--recovery-delay-max", type=float, default=3.0, help="恢复阶段单次请求最大间隔 (秒)")
    parser.add_argument("--seed", type=int, default=None, help="随机种子（可选）")
    parser.add_argument("--report-json", default=None, help="保存详细结果到 JSON 文件")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.seed is not None:
        random.seed(args.seed)

    phases = [
        PhaseConfig(
            name="normal",
            duration=float(args.normal_duration),
            concurrency=args.normal_concurrency,
            delay_range=(args.normal_delay_min, args.normal_delay_max),
            op_weights=[("list_page", 0.8), ("list_full", 0.15), ("insert_dummy", 0.05)],
        ),
        PhaseConfig(
            name="pressure",
            duration=float(args.pressure_duration),
            concurrency=args.pressure_concurrency,
            delay_range=(args.pressure_delay_min, args.pressure_delay_max),
            op_weights=[("list_page", 0.4), ("list_full", 0.4), ("insert_dummy", 0.2)],
        ),
        PhaseConfig(
            name="recovery",
            duration=float(args.recovery_duration),
            concurrency=args.recovery_concurrency,
            delay_range=(args.recovery_delay_min, args.recovery_delay_max),
            op_weights=[("list_page", 1.0)],
        ),
    ]

    metrics: List[OperationResult] = []
    metrics_lock = threading.Lock()

    end_time = time.time() + args.total_duration
    cycle = 0
    while time.time() < end_time:
        cycle += 1
        for phase in phases:
            remaining = end_time - time.time()
            if remaining <= 0:
                break
            duration = min(phase.duration, remaining)
            phase_config = PhaseConfig(
                name=f"{phase.name}-c{cycle}",
                duration=duration,
                concurrency=phase.concurrency,
                delay_range=phase.delay_range,
                op_weights=phase.op_weights,
            )
            print(f"[Cycle {cycle}] Phase {phase_config.name} 开始，目标时长 {duration:.1f}s")
            run_phase(args.base_url, phase_config, metrics, metrics_lock)
            print(f"[Cycle {cycle}] Phase {phase_config.name} 结束")

    print("\n=== 汇总结果 ===")
    print(summarize_metrics(metrics))

    if args.report_json:
        data = [rec._asdict() for rec in metrics]
        with open(args.report_json, "w", encoding="utf-8") as fp:
            json.dump(data, fp, ensure_ascii=False, indent=2)
        print(f"\n详细结果已写入: {args.report_json}")


if __name__ == "__main__":
    main()

