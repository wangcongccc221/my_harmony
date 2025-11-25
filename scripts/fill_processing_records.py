#!/usr/bin/env python3
import argparse
import random
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from typing import Any, Dict

import requests

DEFAULT_BASE_URL = "http://localhost:8080"
TARGET_TOTAL = 20000
PRINT_INTERVAL = 200
SLEEP_SECONDS = 0.1
DEFAULT_WORKERS = 10

total_inserted_lock = threading.Lock()


def build_payload(idx: int) -> Dict[str, Any]:
    return {
        "customerName": f"压测客户-{idx}",
        "farmName": f"示范农场-{idx % 80}",
        "fruitName": random.choice(["苹果", "梨", "橙子", "猕猴桃", "葡萄"]),
        "status": random.choice(["已完成", "进行中", "待开始"]),
        "startTime": "2025-01-01 08:00:00",
        "endTime": "2025-01-01 10:00:00",
        "weight": round(random.uniform(50, 250), 2),
        "count": random.randint(500, 5000),
    }


def get_total_records(base_url: str) -> int:
    resp = requests.get(
        f"{base_url}/api/processing?page=1&size=1&nocount=0",
        timeout=30,
    )
    resp.raise_for_status()
    pagination = resp.json().get("pagination", {})
    return int(pagination.get("total", 0))


def worker_insert(base_url: str, start_idx: int, target_total: int, progress: Dict[str, int]):
    local_idx = start_idx
    session = requests.Session()
    while True:
        with total_inserted_lock:
            current_total = progress["total"]
            if current_total >= target_total:
                return
            progress["total"] += 1
            assigned_id = progress["total"]

        payload = build_payload(local_idx)
        resp = session.post(
            f"{base_url}/api/processing",
            json=payload,
            timeout=30,
        )
        if resp.status_code != 200:
            print(f"[worker] 插入失败（HTTP {resp.status_code}）: {resp.text}")
            with total_inserted_lock:
                progress["total"] -= 1
            time.sleep(0.5)
            continue

        if assigned_id % PRINT_INTERVAL == 0:
            print(f"[worker] 已插入到 {assigned_id} 条")
            time.sleep(SLEEP_SECONDS)

        local_idx += 1


def fill_records(base_url: str, target_total: int, workers: int) -> None:
    current_total = get_total_records(base_url)
    print(f"当前记录数: {current_total}")
    if current_total >= target_total:
        print("已达到目标数量，无需补充")
        return

    progress = {"total": current_total}
    next_idx = current_total + 1

    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = []
        for i in range(workers):
            futures.append(
                executor.submit(worker_insert, base_url, next_idx + i, target_total, progress)
            )
        for future in futures:
            future.result()

    print(f"完成，最终数量: {progress['total']}")


def main():
    parser = argparse.ArgumentParser(description="补充加工记录至指定数量（支持并发）")
    parser.add_argument(
        "--base-url",
        default=DEFAULT_BASE_URL,
        help="HTTP 服务地址 (默认 http://localhost:8080)",
    )
    parser.add_argument(
        "--target",
        type=int,
        default=TARGET_TOTAL,
        help=f"目标记录数 (默认 {TARGET_TOTAL})",
    )
    parser.add_argument(
        "--workers",
        type=int,
        default=DEFAULT_WORKERS,
        help=f"并发 worker 数量 (默认 {DEFAULT_WORKERS})",
    )
    args = parser.parse_args()
    fill_records(args.base_url.rstrip("/"), args.target, args.workers)


if __name__ == "__main__":
    main()

