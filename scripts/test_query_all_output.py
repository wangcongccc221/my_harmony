#!/usr/bin/env python3
"""
测试查询全部数据并完整输出的性能
会列出所有数据并统计耗时
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
        conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=60)
    else:
        conn = http.client.HTTPConnection(u.hostname, u.port or 80, timeout=60)
    
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


def main():
    parser = argparse.ArgumentParser(
        description='测试查询全部数据并完整输出，统计耗时',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '--base-url',
        default='http://127.0.0.1:8080',
        help='API服务器地址（默认: http://127.0.0.1:8080）'
    )
    
    parser.add_argument(
        '--output-file',
        help='可选：将数据保存到JSON文件（不输出到控制台）'
    )
    
    parser.add_argument(
        '--quiet',
        action='store_true',
        help='静默模式：只输出统计信息，不输出数据内容'
    )
    
    parser.add_argument(
        '--pack',
        action='store_true',
        help='使用pack格式（压缩格式，性能更好）'
    )
    
    args = parser.parse_args()
    
    print("=" * 80)
    print("测试：查询全部数据并完整输出")
    print("=" * 80)
    print(f"服务器地址: {args.base_url}")
    if args.output_file:
        print(f"输出文件: {args.output_file}")
    if args.quiet:
        print("模式: 静默模式（不输出数据内容）")
    print("=" * 80)
    print()
    
    # 开始计时
    total_start_time = time.perf_counter()
    
    print("正在查询全部数据...")
    if args.pack:
        print("使用pack格式（压缩格式）")
    query_start = time.perf_counter()
    
    # 发送请求
    path = '/api/processing?action=listJson'
    if args.pack:
        path += '&pack=1'
    status, body = _request(args.base_url, 'GET', path)
    
    query_end = time.perf_counter()
    query_duration = query_end - query_start
    
    print(f"✅ 请求完成，耗时: {query_duration*1000:.2f} 毫秒 ({query_duration:.4f} 秒)")
    print(f"响应数据大小: {len(body)} 字节 ({len(body)/1024/1024:.2f} MB)")
    print()
    
    # 解析JSON
    print("正在解析JSON数据...")
    parse_start = time.perf_counter()
    
    result = _parse_json(body)
    
    parse_end = time.perf_counter()
    parse_duration = parse_end - parse_start
    
    print(f"✅ JSON解析完成，耗时: {parse_duration*1000:.2f} 毫秒 ({parse_duration:.4f} 秒)")
    print()
    
    # 检查结果
    if status != 200:
        print(f"❌ HTTP请求失败! 状态码: {status}")
        print(f"响应内容: {body[:500]}")
        sys.exit(1)
    
    if not isinstance(result, dict) or result.get('ok') is not True:
        print(f"❌ API返回错误!")
        print(f"响应内容: {json.dumps(result, ensure_ascii=False, indent=2)[:500]}")
        sys.exit(1)
    
    data = result.get('data', [])
    
    # 处理pack格式
    if args.pack and isinstance(data, dict) and 'rows' in data:
        # pack格式：解包数据
        schema = data.get('schema', [])
        rows = data.get('rows', [])
        print(f"Pack格式：schema字段数={len(schema)}, 行数={len(rows)}")
        # 转换为普通格式以便后续处理
        unpacked_data = []
        for row in rows:
            record = {}
            for i, field_name in enumerate(schema):
                if i < len(row):
                    record[field_name] = row[i]
            unpacked_data.append(record)
        data = unpacked_data
    elif not isinstance(data, list):
        print(f"❌ 数据格式错误，期望列表或pack格式!")
        print(f"响应内容: {json.dumps(result, ensure_ascii=False, indent=2)[:500]}")
        sys.exit(1)
    
    # 输出数据
    output_start = time.perf_counter()
    
    if args.output_file:
        # 保存到文件
        print(f"正在保存数据到文件: {args.output_file}")
        with open(args.output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"✅ 数据已保存到文件")
    elif not args.quiet:
        # 输出到控制台
        print("=" * 80)
        print("全部数据列表:")
        print("=" * 80)
        print()
        
        for i, record in enumerate(data, 1):
            print(f"【记录 {i}/{len(data)}】")
            print(json.dumps(record, ensure_ascii=False, indent=2))
            print("-" * 80)
    
    output_end = time.perf_counter()
    output_duration = output_end - output_start
    
    # 总耗时
    total_end_time = time.perf_counter()
    total_duration = total_end_time - total_start_time
    
    # 输出统计信息
    print()
    print("=" * 80)
    print("性能统计")
    print("=" * 80)
    print(f"总记录数: {len(data)} 条")
    print(f"响应数据大小: {len(body)} 字节 ({len(body)/1024/1024:.2f} MB)")
    print()
    print("时间统计:")
    print(f"  查询请求耗时: {query_duration*1000:.2f} 毫秒 ({query_duration:.4f} 秒)")
    print(f"  JSON解析耗时: {parse_duration*1000:.2f} 毫秒 ({parse_duration:.4f} 秒)")
    print(f"  数据输出耗时: {output_duration*1000:.2f} 毫秒 ({output_duration:.4f} 秒)")
    print(f"  ─────────────────────────────────────")
    print(f"  总耗时: {total_duration*1000:.2f} 毫秒 ({total_duration:.4f} 秒)")
    print()
    print(f"平均每条记录耗时: {(total_duration / len(data) * 1000):.2f} 毫秒")
    print(f"平均每条记录大小: {len(body) / len(data):.0f} 字节")
    print("=" * 80)
    
    # 数据摘要
    if data and not args.quiet:
        print()
        print("=" * 80)
        print("数据摘要")
        print("=" * 80)
        
        # 统计不同状态的数量
        status_count = {}
        fruit_count = {}
        customer_count = {}
        
        for record in data:
            # 状态统计
            status = record.get('status', '未知')
            status_count[status] = status_count.get(status, 0) + 1
            
            # 水果类型统计
            fruit = record.get('fruitName', '未知')
            fruit_count[fruit] = fruit_count.get(fruit, 0) + 1
            
            # 客户统计
            customer = record.get('customerName', '未知')
            customer_count[customer] = customer_count.get(customer, 0) + 1
        
        print(f"\n状态分布:")
        for status, count in sorted(status_count.items(), key=lambda x: x[1], reverse=True):
            print(f"  {status}: {count} 条 ({count/len(data)*100:.1f}%)")
        
        print(f"\n水果类型分布 (前10):")
        for fruit, count in sorted(fruit_count.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {fruit}: {count} 条")
        
        print(f"\n客户数量: {len(customer_count)} 个不同客户")
        print("=" * 80)


if __name__ == '__main__':
    main()

