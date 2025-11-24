#!/usr/bin/env python3
"""
对比查询数量 vs 查询全部数据的性能差异
"""

import argparse
import sys
import json
import time
from urllib.parse import urlparse
import http.client


def _request(base_url: str, method: str, path: str, body=None, headers=None):
    """发送HTTP请求"""
    u = urlparse(base_url)
    if u.scheme == 'https':
        conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=30)
    else:
        conn = http.client.HTTPConnection(u.hostname, u.port or 80, timeout=30)
    
    data = None
    h = {}
    if headers:
        h.update(headers)
    if body is not None:
        if isinstance(body, dict):
            data = json.dumps(body).encode('utf-8')
            h['Content-Type'] = h.get('Content-Type', 'application/json')
        elif isinstance(body, str):
            data = body.encode('utf-8')
        else:
            data = body
    
    try:
        conn.request(method, path, body=data, headers=h)
        resp = conn.getresponse()
        status = resp.status
        text = resp.read().decode('utf-8', errors='replace')
        return status, text
    finally:
        conn.close()


def _parse_json(text: str):
    """解析JSON响应"""
    try:
        return json.loads(text)
    except Exception as e:
        return {'error': f'JSON解析失败: {e}', 'raw': text}


def test_count_only(base_url: str):
    """测试1：只查询数量（COUNT）"""
    print("=" * 70)
    print("测试1：只查询数量（COUNT查询）")
    print("=" * 70)
    
    start_time = time.perf_counter()
    
    # 使用lite模式，只返回统计信息，不返回数据
    status, body = _request(base_url, 'GET', '/api/processing?page=1&size=1&lite=1')
    
    request_time = time.perf_counter()
    request_duration = request_time - start_time
    
    result = _parse_json(body)
    parse_time = time.perf_counter()
    parse_duration = parse_time - request_time
    
    total_duration = time.perf_counter() - start_time
    
    print(f"\nHTTP状态码: {status}")
    print(f"请求耗时: {request_duration*1000:.2f} 毫秒 ({request_duration:.4f} 秒)")
    print(f"解析耗时: {parse_duration*1000:.2f} 毫秒 ({parse_duration:.4f} 秒)")
    print(f"总耗时: {total_duration*1000:.2f} 毫秒 ({total_duration:.4f} 秒)")
    
    if status == 200 and isinstance(result, dict) and result.get('ok'):
        data = result.get('data', {})
        if isinstance(data, dict):
            total = data.get('total', 0)
            count = data.get('count', 0)
            print(f"\n✅ 查询成功!")
            print(f"总记录数: {total}")
            print(f"当前页记录数: {count}")
            print(f"响应数据大小: {len(body)} 字节")
            return total, total_duration
        else:
            print(f"\n❌ 数据格式错误")
            return None, total_duration
    else:
        print(f"\n❌ 请求失败!")
        print(f"响应: {body[:200]}")
        return None, total_duration


def test_query_all(base_url: str):
    """测试2：查询全部数据并列出"""
    print("\n" + "=" * 70)
    print("测试2：查询全部数据并列出（listJson方式）")
    print("=" * 70)
    
    start_time = time.perf_counter()
    
    # 查询所有数据
    status, body = _request(base_url, 'GET', '/api/processing?action=listJson')
    
    request_time = time.perf_counter()
    request_duration = request_time - start_time
    
    result = _parse_json(body)
    parse_time = time.perf_counter()
    parse_duration = parse_time - request_time
    
    total_duration = time.perf_counter() - start_time
    
    print(f"\nHTTP状态码: {status}")
    print(f"请求耗时: {request_duration*1000:.2f} 毫秒 ({request_duration:.4f} 秒)")
    print(f"解析耗时: {parse_duration*1000:.2f} 毫秒 ({parse_duration:.4f} 秒)")
    print(f"总耗时: {total_duration*1000:.2f} 毫秒 ({total_duration:.4f} 秒)")
    
    if status == 200 and isinstance(result, dict) and result.get('ok'):
        data = result.get('data', [])
        if isinstance(data, list):
            print(f"\n✅ 查询成功!")
            print(f"数据条数: {len(data)}")
            print(f"响应数据大小: {len(body)} 字节 ({len(body)/1024/1024:.2f} MB)")
            if data:
                print(f"\n前3条数据示例:")
                for i, record in enumerate(data[:3], 1):
                    print(f"\n记录 {i}:")
                    print(json.dumps(record, ensure_ascii=False, indent=2))
            return len(data), total_duration
        else:
            print(f"\n❌ 数据格式错误")
            return None, total_duration
    else:
        print(f"\n❌ 请求失败!")
        print(f"响应: {body[:200]}")
        return None, total_duration


def main():
    parser = argparse.ArgumentParser(
        description='对比查询数量 vs 查询全部数据的性能差异',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '--base-url',
        default='http://127.0.0.1:8080',
        help='API服务器地址（默认: http://127.0.0.1:8080）'
    )
    
    args = parser.parse_args()
    
    print(f"\n{'='*70}")
    print(f"性能对比测试：COUNT查询 vs 查询全部数据")
    print(f"{'='*70}")
    print(f"服务器地址: {args.base_url}")
    print(f"{'='*70}\n")
    
    # 测试1：只查询数量
    count_result, count_time = test_count_only(args.base_url)
    
    # 测试2：查询全部数据
    query_result, query_time = test_query_all(args.base_url)
    
    # 性能对比
    if count_result is not None and query_result is not None:
        print("\n" + "=" * 70)
        print("性能对比总结")
        print("=" * 70)
        print(f"COUNT查询耗时: {count_time*1000:.2f} 毫秒 ({count_time:.4f} 秒)")
        print(f"查询全部数据耗时: {query_time*1000:.2f} 毫秒 ({query_time:.4f} 秒)")
        
        if count_time > 0:
            speedup = query_time / count_time
            print(f"\n性能差异: 查询全部数据比COUNT查询慢 {speedup:.1f} 倍")
            print(f"时间差异: 多花了 {query_time - count_time:.4f} 秒 ({(query_time - count_time)*1000:.2f} 毫秒)")
            
            # 分析时间组成
            print(f"\n时间组成分析:")
            print(f"  - COUNT查询: 主要是数据库扫描索引/表的时间")
            print(f"  - 查询全部数据: 数据库查询 + 数据读取 + 序列化 + 网络传输")
            print(f"  - 额外开销: {((query_time - count_time) / query_time * 100):.1f}% 的时间用于读取和传输数据")


if __name__ == '__main__':
    main()

