#!/usr/bin/env python3
"""
查询历史加工数据表所有数据的脚本
支持两种查询方式：
1. 使用 action=listJson 获取所有数据（一次性）
2. 使用分页方式获取所有数据（逐页获取）
"""

import argparse
import sys
import json
import time
from urllib.parse import urlparse
import http.client


def _request(base_url: str, method: str, path: str, body=None, headers=None, return_timing=False):
    """发送HTTP请求
    
    Args:
        base_url: 服务器地址
        method: HTTP方法
        path: 请求路径
        body: 请求体
        headers: 请求头
        return_timing: 是否返回详细的时间统计
    
    Returns:
        如果return_timing=False: (status, text)
        如果return_timing=True: (status, text, timing_dict)
    """
    u = urlparse(base_url)
    timing = {}
    
    # 连接阶段
    connect_start = time.perf_counter()
    if u.scheme == 'https':
        conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=30)
    else:
        conn = http.client.HTTPConnection(u.hostname, u.port or 80, timeout=30)
    connect_end = time.perf_counter()
    timing['connect'] = connect_end - connect_start
    
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
        # 发送请求阶段
        request_start = time.perf_counter()
        conn.request(method, path, body=data, headers=h)
        request_end = time.perf_counter()
        timing['send_request'] = request_end - request_start
        
        # 等待响应阶段（TTFB - Time To First Byte）
        response_start = time.perf_counter()
        resp = conn.getresponse()
        response_end = time.perf_counter()
        timing['wait_response'] = response_end - response_start
        
        status = resp.status
        
        # 接收数据阶段
        read_start = time.perf_counter()
        text = resp.read().decode('utf-8', errors='replace')
        read_end = time.perf_counter()
        timing['read_data'] = read_end - read_start
        
        timing['total'] = read_end - connect_start
        
        if return_timing:
            return status, text, timing
        else:
            return status, text
    finally:
        conn.close()


def _parse_json(text: str):
    """解析JSON响应"""
    try:
        return json.loads(text)
    except Exception as e:
        return {'error': f'JSON解析失败: {e}', 'raw': text}


def query_all_via_listjson(base_url: str):
    """方式1：使用 action=listJson 获取所有数据"""
    print("=" * 60)
    print("方式1：使用 action=listJson 获取所有数据")
    print("=" * 60)
    
    start_time = time.perf_counter()
    
    # 发送请求（获取详细时间统计）
    status, body, timing = _request(base_url, 'GET', '/api/processing?action=listJson', return_timing=True)
    
    request_time = time.perf_counter()
    request_duration = request_time - start_time
    
    # 解析响应
    result = _parse_json(body)
    parse_time = time.perf_counter()
    parse_duration = parse_time - request_time
    
    total_duration = time.perf_counter() - start_time
    
    # 输出结果
    print(f"\nHTTP状态码: {status}")
    print(f"\n【详细时间统计】")
    print(f"  建立连接耗时: {timing['connect']*1000:.2f} 毫秒")
    print(f"  发送请求耗时: {timing['send_request']*1000:.2f} 毫秒")
    print(f"  等待响应耗时: {timing['wait_response']*1000:.2f} 毫秒 (服务器处理时间)")
    print(f"  接收数据耗时: {timing['read_data']*1000:.2f} 毫秒 (网络传输时间)")
    print(f"  请求总耗时: {timing['total']*1000:.2f} 毫秒 ({timing['total']:.4f} 秒)")
    print(f"  JSON解析耗时: {parse_duration*1000:.2f} 毫秒 ({parse_duration:.4f} 秒)")
    print(f"  总耗时: {total_duration*1000:.2f} 毫秒 ({total_duration:.4f} 秒)")
    
    if status != 200:
        print(f"\n❌ 请求失败!")
        print(f"响应内容: {body[:500]}")
        return None
    
    if not isinstance(result, dict):
        print(f"\n❌ 响应格式错误!")
        print(f"响应内容: {body[:500]}")
        return None
    
    if result.get('ok') is not True:
        print(f"\n❌ API返回错误!")
        print(f"响应内容: {json.dumps(result, ensure_ascii=False, indent=2)}")
        return None
    
    data = result.get('data', [])
    if not isinstance(data, list):
        print(f"\n❌ 数据格式错误，期望列表!")
        print(f"响应内容: {json.dumps(result, ensure_ascii=False, indent=2)[:500]}")
        return None
    
    print(f"\n✅ 查询成功!")
    print(f"数据条数: {len(data)}")
    print(f"平均每条耗时: {(total_duration / len(data) * 1000):.2f} 毫秒" if data else "N/A")
    
    # 显示前几条数据示例
    if data:
        print(f"\n前3条数据示例:")
        for i, record in enumerate(data[:3], 1):
            print(f"\n记录 {i}:")
            print(json.dumps(record, ensure_ascii=False, indent=2))
    
    return data


def query_all_via_pagination(base_url: str, page_size: int = 100):
    """方式2：使用分页方式获取所有数据"""
    print("=" * 60)
    print(f"方式2：使用分页方式获取所有数据（每页 {page_size} 条）")
    print("=" * 60)
    
    all_data = []
    page = 1
    total_start_time = time.perf_counter()
    
    # 先获取总数
    count_start = time.perf_counter()
    status, body = _request(base_url, 'GET', f'/api/processing?page=1&size=1&lite=1')
    count_duration = time.perf_counter() - count_start
    
    count_result = _parse_json(body)
    total_count = 0
    if isinstance(count_result, dict) and count_result.get('ok'):
        pagination = count_result.get('data', {}).get('pagination', {})
        total_count = pagination.get('total', 0)
        print(f"\n总记录数: {total_count}")
        print(f"获取总数耗时: {count_duration:.4f} 秒")
    
    print(f"\n开始分页获取数据...")
    
    while True:
      page_start = time.perf_counter()
      
      # 发送分页请求（获取详细时间统计）
      status, body, timing = _request(base_url, 'GET', f'/api/processing?page={page}&size={page_size}&nocount=1', return_timing=True)
      
      page_request_time = time.perf_counter()
      page_request_duration = page_request_time - page_start
      
      # 解析响应
      result = _parse_json(body)
      page_parse_time = time.perf_counter()
      page_parse_duration = page_parse_time - page_request_time
      
      page_total_duration = time.perf_counter() - page_start
      
      if status != 200:
        print(f"\n❌ 第 {page} 页请求失败! HTTP状态码: {status}")
        print(f"响应内容: {body[:200]}")
        break
      
      if not isinstance(result, dict) or result.get('ok') is not True:
        print(f"\n❌ 第 {page} 页API返回错误!")
        print(f"响应内容: {json.dumps(result, ensure_ascii=False)[:200]}")
        break
      
      page_data = result.get('data', {})
      if isinstance(page_data, dict):
        records = page_data.get('data', [])
      elif isinstance(page_data, list):
        records = page_data
      else:
        records = []
      
      if not records:
        print(f"\n第 {page} 页无数据，查询结束")
        break
      
      all_data.extend(records)
      
      # 只在第一页或每10页显示详细时间，其他页显示简化信息
      if page == 1 or page % 10 == 0:
        print(f"第 {page} 页: 获取 {len(records)} 条")
        print(f"  └─ 服务器处理: {timing['wait_response']*1000:.1f}ms, "
              f"网络传输: {timing['read_data']*1000:.1f}ms, "
              f"总耗时: {page_total_duration*1000:.1f}ms")
      else:
        print(f"第 {page} 页: 获取 {len(records)} 条, 耗时 {page_total_duration*1000:.1f}ms")
      
      # 如果返回的数据少于page_size，说明已经是最后一页
      if len(records) < page_size:
        break
      
      page += 1
    
    total_duration = time.perf_counter() - total_start_time
    
    print(f"\n" + "=" * 60)
    print(f"✅ 分页查询完成!")
    print(f"总页数: {page}")
    print(f"总数据条数: {len(all_data)}")
    print(f"总耗时: {total_duration:.4f} 秒")
    if all_data:
        print(f"平均每页耗时: {(total_duration / page):.4f} 秒")
        print(f"平均每条耗时: {(total_duration / len(all_data) * 1000):.2f} 毫秒")
    
    # 显示前几条数据示例
    if all_data:
        print(f"\n前3条数据示例:")
        for i, record in enumerate(all_data[:3], 1):
            print(f"\n记录 {i}:")
            print(json.dumps(record, ensure_ascii=False, indent=2))
    
    return all_data


def main():
    parser = argparse.ArgumentParser(
        description='查询历史加工数据表所有数据并输出耗时',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  # 使用 listJson 方式查询所有数据
  python query_all_history.py --base-url http://127.0.0.1:8080 --method listjson
  
  # 使用分页方式查询所有数据（每页100条）
  python query_all_history.py --base-url http://127.0.0.1:8080 --method pagination --page-size 100
  
  # 两种方式都测试
  python query_all_history.py --base-url http://127.0.0.1:8080 --method both
        """
    )
    
    parser.add_argument(
        '--base-url',
        default='http://127.0.0.1:8080',
        help='API服务器地址（默认: http://127.0.0.1:8080）'
    )
    
    parser.add_argument(
        '--method',
        choices=['listjson', 'pagination', 'both'],
        default='both',
        help='查询方式: listjson=一次性获取, pagination=分页获取, both=两种都测试（默认: both）'
    )
    
    parser.add_argument(
        '--page-size',
        type=int,
        default=100,
        help='分页查询时每页的数量（默认: 100，最大: 100）'
    )
    
    parser.add_argument(
        '--output',
        help='可选：将结果保存到JSON文件'
    )
    
    args = parser.parse_args()
    
    # 限制page_size范围
    page_size = max(1, min(100, args.page_size))
    
    print(f"\n{'='*60}")
    print(f"历史加工数据查询工具")
    print(f"{'='*60}")
    print(f"服务器地址: {args.base_url}")
    print(f"查询方式: {args.method}")
    if args.method in ['pagination', 'both']:
        print(f"每页数量: {page_size}")
    print(f"{'='*60}\n")
    
    results = {}
    
    # 测试方式1：listJson
    if args.method in ['listjson', 'both']:
        data1 = query_all_via_listjson(args.base_url)
        if data1 is not None:
            results['listjson'] = data1
        print("\n")
    
    # 测试方式2：分页
    if args.method in ['pagination', 'both']:
        data2 = query_all_via_pagination(args.base_url, page_size)
        if data2 is not None:
            results['pagination'] = data2
        print("\n")
    
    # 保存结果到文件
    if args.output and results:
        try:
            with open(args.output, 'w', encoding='utf-8') as f:
                json.dump(results, f, ensure_ascii=False, indent=2)
            print(f"✅ 结果已保存到: {args.output}")
        except Exception as e:
            print(f"❌ 保存文件失败: {e}")
    
    # 性能对比
    if args.method == 'both' and 'listjson' in results and 'pagination' in results:
        print("\n" + "=" * 60)
        print("性能对比:")
        print("=" * 60)
        print(f"listJson方式: {len(results['listjson'])} 条数据")
        print(f"分页方式: {len(results['pagination'])} 条数据")
        if len(results['listjson']) == len(results['pagination']):
            print("✅ 两种方式获取的数据条数一致")
        else:
            print("⚠️  两种方式获取的数据条数不一致！")


if __name__ == '__main__':
    main()

