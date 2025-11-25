#!/usr/bin/env python3
"""
多用户 CRUD 压测脚本
 - 并发模拟多人同时访问 HTTP + 数据库接口
 - 分别统计 Query / Insert / Update / Delete 的耗时分布
 - 支持自定义操作占比与总操作数
"""

import argparse
import json
import random
import statistics
import threading
import time
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

import requests


@dataclass
class OperationMetrics:
    """记录单个操作类型的统计数据"""
    name: str
    latencies: List[float] = field(default_factory=list)
    success: int = 0
    failed: int = 0
    lock: threading.Lock = field(default_factory=threading.Lock, repr=False)

    def record(self, success: bool, latency_ms: float):
        with self.lock:
            if success:
                self.success += 1
                self.latencies.append(latency_ms)
            else:
                self.failed += 1

    def summarize(self) -> Dict:
        with self.lock:
            total = self.success + self.failed
            if self.success == 0:
                return {
                    "operation": self.name,
                    "total": total,
                    "success": self.success,
                    "failed": self.failed,
                    "success_rate": "0%",
                    "latency": {}
                }

            def percentile(values: List[float], percent: float) -> float:
                if not values:
                    return 0.0
                k = (len(values) - 1) * percent / 100
                f = int(k)
                c = min(f + 1, len(values) - 1)
                if f == c:
                    return values[f]
                return values[f] + (values[c] - values[f]) * (k - f)

            lat_sorted = sorted(self.latencies)
            summary = {
                "operation": self.name,
                "total": total,
                "success": self.success,
                "failed": self.failed,
                "success_rate": f"{self.success * 100 / total:.2f}%",
                "latency": {
                    "min_ms": round(lat_sorted[0], 2),
                    "max_ms": round(lat_sorted[-1], 2),
                    "avg_ms": round(statistics.mean(lat_sorted), 2),
                    "median_ms": round(statistics.median(lat_sorted), 2),
                    "p90_ms": round(percentile(lat_sorted, 90), 2),
                    "p95_ms": round(percentile(lat_sorted, 95), 2),
                    "p99_ms": round(percentile(lat_sorted, 99), 2),
                    "std_ms": round(statistics.stdev(lat_sorted), 2) if len(lat_sorted) > 1 else 0.0
                }
            }
            return summary


class SharedIdPool:
    """保存已插入成功的记录 ID，供 Update/Delete 使用"""

    def __init__(self):
        self.ids: List[int] = []
        self.lock = threading.Lock()

    def add(self, record_id: int):
        with self.lock:
            self.ids.append(record_id)

    def get_random(self) -> Optional[int]:
        with self.lock:
            if not self.ids:
                return None
            return random.choice(self.ids)

    def remove(self, record_id: int):
        with self.lock:
            if record_id in self.ids:
                self.ids.remove(record_id)


class CrudBenchmark:
    def __init__(self, base_url: str, workers: int, ops_per_worker: int,
                 mix: Dict[str, int], warmup_inserts: int = 20):
        self.base_url = base_url.rstrip("/")
        self.workers = workers
        self.ops_per_worker = ops_per_worker
        self.mix = mix
        self.warmup_inserts = warmup_inserts

        self.metrics: Dict[str, OperationMetrics] = {
            "query": OperationMetrics("query"),
            "insert": OperationMetrics("insert"),
            "update": OperationMetrics("update"),
            "delete": OperationMetrics("delete"),
        }
        self.id_pool = SharedIdPool()
        self.total_lock = threading.Lock()
        self.total_ops = 0
        self.start_time = 0.0
        self.end_time = 0.0

    def run(self):
        print("🚀 启动 CRUD 压测")
        print(f"服务器: {self.base_url}")
        print(f"并发用户: {self.workers}")
        print(f"每个用户操作数: {self.ops_per_worker}")
        print(f"操作占比: {self.mix}")
        print(f"预热插入: {self.warmup_inserts} 条\n")

        self._warmup_data()

        self.start_time = time.time()
        threads = []
        for i in range(self.workers):
            th = threading.Thread(target=self._worker, args=(i,), daemon=True)
            threads.append(th)
            th.start()

        for th in threads:
            th.join()
        self.end_time = time.time()

        self._print_report()

    def _warmup_data(self):
        if self.warmup_inserts <= 0:
            return
        print("⚙️ 预热阶段：插入基础数据")
        for _ in range(self.warmup_inserts):
            success, _, new_id = self._insert_record(requests.Session())
            if success and new_id:
                self.id_pool.add(new_id)
        print(f"✅ 预热完成，ID 池大小: {len(self.id_pool.ids)}\n")

    def _worker(self, worker_id: int):
        session = requests.Session()
        rng = random.Random(time.time() + worker_id)
        choices = self._build_choice_table()

        for _ in range(self.ops_per_worker):
            op = self._pick_operation(rng, choices)
            if op == "query":
                success, latency = self._query_list(session, rng)
                self.metrics["query"].record(success, latency)
            elif op == "insert":
                success, latency, record_id = self._insert_record(session)
                if success and record_id:
                    self.id_pool.add(record_id)
                self.metrics["insert"].record(success, latency)
            elif op == "update":
                success, latency = self._update_record(session, rng)
                self.metrics["update"].record(success, latency)
            elif op == "delete":
                success, latency = self._delete_record(session, rng)
                self.metrics["delete"].record(success, latency)
            with self.total_lock:
                self.total_ops += 1

    def _build_choice_table(self) -> List[Tuple[str, int]]:
        total = sum(self.mix.values())
        choices = []
        cumulative = 0
        for op, weight in self.mix.items():
            cumulative += weight
            choices.append((op, cumulative))
        return choices

    def _pick_operation(self, rng: random.Random, choices: List[Tuple[str, int]]) -> str:
        total_weight = choices[-1][1]
        roll = rng.randint(1, total_weight)
        for op, threshold in choices:
            if roll <= threshold:
                return op
        return choices[-1][0]

    def _query_list(self, session: requests.Session, rng: random.Random) -> Tuple[bool, float]:
        params = {"page": rng.randint(1, 5), "size": 20}
        url = f"{self.base_url}/api/processing"
        start = time.time()
        try:
            resp = session.get(url, params=params, timeout=10)
            latency = (time.time() - start) * 1000
            ok = resp.status_code == 200
            return ok, latency
        except requests.RequestException:
            return False, (time.time() - start) * 1000

    def _insert_record(self, session: requests.Session) -> Tuple[bool, float, Optional[int]]:
        payload = {
            "customerName": f"压测用户-{random.randint(1000, 9999)}",
            "farmName": f"农场-{random.randint(1, 100)}",
            "fruitName": random.choice(["苹果", "梨", "橙子", "桃子"]),
            "status": random.choice(["进行中", "已完成"]),
            "startTime": "2025-01-15 10:00:00",
            "endTime": "2025-01-15 11:00:00",
            "weight": round(random.uniform(50, 150), 2),
            "count": random.randint(100, 3000)
        }
        url = f"{self.base_url}/api/processing"
        headers = {"Content-Type": "application/json"}
        start = time.time()
        try:
            resp = session.post(url, json=payload, headers=headers, timeout=10)
            latency = (time.time() - start) * 1000
            if resp.status_code in (200, 201):
                try:
                    data = resp.json()
                    new_id = None
                    if isinstance(data, dict):
                        # 常规响应: {"ok": true, "data": {"id": 1}}
                        payload = data.get("data")
                        if isinstance(payload, dict):
                            new_id = payload.get("id")
                        elif isinstance(payload, list) and payload:
                            first = payload[0]
                            if isinstance(first, dict):
                                new_id = first.get("id")
                    elif isinstance(data, list) and data:
                        first = data[0]
                        if isinstance(first, dict):
                            new_id = first.get("id")
                except (json.JSONDecodeError, AttributeError):
                    new_id = None
                return True, latency, new_id
            return False, latency, None
        except requests.RequestException:
            return False, (time.time() - start) * 1000, None

    def _update_record(self, session: requests.Session, rng: random.Random) -> Tuple[bool, float]:
        record_id = self.id_pool.get_random()
        if record_id is None:
            # 如果没有数据，退化为查询，避免无效请求
            return self._query_list(session, rng)
        payload = {
            "status": random.choice(["进行中", "已完成"]),
            "weight": round(random.uniform(60, 200), 2)
        }
        url = f"{self.base_url}/api/processing/{record_id}"
        headers = {"Content-Type": "application/json"}
        start = time.time()
        try:
            resp = session.put(url, json=payload, headers=headers, timeout=10)
            latency = (time.time() - start) * 1000
            return resp.status_code == 200, latency
        except requests.RequestException:
            return False, (time.time() - start) * 1000

    def _delete_record(self, session: requests.Session, rng: random.Random) -> Tuple[bool, float]:
        record_id = self.id_pool.get_random()
        if record_id is None:
            return self._query_list(session, rng)
        url = f"{self.base_url}/api/processing/{record_id}"
        start = time.time()
        try:
            resp = session.delete(url, timeout=10)
            latency = (time.time() - start) * 1000
            success = resp.status_code == 200
            if success:
                self.id_pool.remove(record_id)
            return success, latency
        except requests.RequestException:
            return False, (time.time() - start) * 1000

    def _print_report(self):
        duration = self.end_time - self.start_time
        overall_qps = self.total_ops / duration if duration > 0 else 0

        print("\n" + "=" * 70)
        print("📊 压测总览")
        print("=" * 70)
        print(f"总操作数: {self.total_ops}")
        print(f"总耗时:   {duration:.2f} 秒")
        print(f"整体 QPS: {overall_qps:.2f} ops/s")

        print("\n🔍 各操作类型统计：")
        for op in ["query", "insert", "update", "delete"]:
            summary = self.metrics[op].summarize()
            print(f"\n[{op.upper()}]")
            print(f"  总数       : {summary['total']}")
            print(f"  成功/失败  : {summary['success']} / {summary['failed']}")
            print(f"  成功率     : {summary['success_rate']}")
            if summary["latency"]:
                lat = summary["latency"]
                print(f"  延迟(ms)   : min {lat['min_ms']} | avg {lat['avg_ms']} | median {lat['median_ms']}")
                print(f"               p90 {lat['p90_ms']} | p95 {lat['p95_ms']} | p99 {lat['p99_ms']}")
                print(f"               max {lat['max_ms']} | std {lat['std_ms']}")

        print("\n✅ 压测完成！")


def parse_mix(mix_str: str) -> Dict[str, int]:
    allowed = {"query", "insert", "update", "delete"}
    mix = {}
    for part in mix_str.split(","):
        if "=" not in part:
            continue
        op, value = part.split("=", 1)
        op = op.strip().lower()
        if op not in allowed:
            raise ValueError(f"未知操作: {op}")
        mix[op] = int(value)
    if not mix:
        raise ValueError("操作占比不能为空")
    # 确保所有操作都有占比（未提供则默认 0）
    for op in allowed:
        mix.setdefault(op, 0)
    return mix


def main():
    parser = argparse.ArgumentParser(description="多用户 CRUD 压测脚本")
    parser.add_argument("--url", default="http://localhost:8080", help="服务器地址")
    parser.add_argument("--workers", type=int, default=20, help="并发用户数")
    parser.add_argument("--ops-per-worker", type=int, default=50, help="每个用户的操作次数")
    parser.add_argument("--mix", default="query=50,insert=20,update=15,delete=15",
                        help="操作占比，格式: query=50,insert=20,update=15,delete=15")
    parser.add_argument("--warmup", type=int, default=20, help="压测前预热插入数量")

    args = parser.parse_args()
    mix = parse_mix(args.mix)

    benchmark = CrudBenchmark(
        base_url=args.url,
        workers=args.workers,
        ops_per_worker=args.ops_per_worker,
        mix=mix,
        warmup_inserts=args.warmup
    )
    benchmark.run()


if __name__ == "__main__":
    main()

