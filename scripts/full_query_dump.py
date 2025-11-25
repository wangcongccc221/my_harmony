#!/usr/bin/env python3
"""
单次全量查询脚本：请求 HTTP 接口、打印完整响应，并统计耗时。
"""

import argparse
import json
import sys
import time
from typing import Any, Tuple

import requests


def fetch_and_dump(url: str, timeout: int) -> Tuple[float, float, float, int]:
    """
    发送 GET 请求，打印完整 JSON。

    返回 (http_ms, json_decode_ms, print_ms, record_count)
    """
    start_total = time.perf_counter()
    response = requests.get(url, timeout=timeout)
    end_http = time.perf_counter()

    response.raise_for_status()

    start_decode = time.perf_counter()
    data: Any = response.json()
    json_text = json.dumps(data, ensure_ascii=False, indent=2)
    end_decode = time.perf_counter()

    start_print = time.perf_counter()
    print(json_text)
    sys.stdout.flush()
    end_print = time.perf_counter()

    http_ms = (end_http - start_total) * 1000.0
    decode_ms = (end_decode - start_decode) * 1000.0
    print_ms = (end_print - start_print) * 1000.0

    record_count = _count_records(data)
    return http_ms, decode_ms, print_ms, record_count


def _count_records(data: Any) -> int:
    """
    根据响应结构估算记录条数。
    支持：
      - 直接返回数组
      - 返回 { data: [...] }
      - 返回 { rows: [...] }
    找不到时返回 -1。
    """
    if isinstance(data, list):
        return len(data)
    if isinstance(data, dict):
        for key in ("data", "rows"):
            value = data.get(key)
            if isinstance(value, list):
                return len(value)
    return -1


def main() -> None:
    parser = argparse.ArgumentParser(
        description="查询 /api/processing 并打印完整响应，同时统计耗时"
    )
    parser.add_argument(
        "--url",
        default="http://127.0.0.1:8000/api/processing?action=listJson",
        help="完整请求 URL（默认指向 listJson 接口）",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="请求超时时间（秒）",
    )

    args = parser.parse_args()

    try:
        http_ms, decode_ms, print_ms, record_count = fetch_and_dump(args.url, args.timeout)
    except requests.RequestException as exc:
        print(f"[ERROR] 请求失败: {exc}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as exc:
        print(f"[ERROR] 响应非 JSON: {exc}", file=sys.stderr)
        sys.exit(2)

    print("\n========== 统计 ==========")
    print(f"URL: {args.url}")
    print(f"HTTP 耗时: {http_ms:.2f} ms")
    print(f"JSON 解析/序列化耗时: {decode_ms:.2f} ms")
    print(f"打印耗时(估算): {print_ms:.2f} ms")
    if record_count >= 0:
        print(f"记录条数: {record_count}")
    else:
        print("记录条数: 未能自动识别（请手动查看输出）")


if __name__ == "__main__":
    main()

