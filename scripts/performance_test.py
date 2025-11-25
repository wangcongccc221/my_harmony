#!/usr/bin/env python3
"""
HTTP + 数据库压力测试脚本
测试 API 性能并输出详细的耗时统计数据
"""

import requests
import time
import statistics
import json
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Tuple
import argparse
from datetime import datetime

class PerformanceTest:
    def __init__(self, base_url: str = "http://localhost:8080"):
        self.base_url = base_url
        self.results: List[Dict] = []
    
    def single_request(self, method: str, endpoint: str, data: dict = None, headers: dict = None) -> Tuple[bool, float, int]:
        """
        发送单个请求并记录耗时
        返回: (成功, 耗时ms, 状态码)
        """
        url = f"{self.base_url}{endpoint}"
        start_time = time.time()
        
        try:
            if method.upper() == 'GET':
                response = requests.get(url, params=data, headers=headers, timeout=10)
            elif method.upper() == 'POST':
                response = requests.post(url, json=data, headers=headers, timeout=10)
            elif method.upper() == 'PUT':
                response = requests.put(url, json=data, headers=headers, timeout=10)
            elif method.upper() == 'DELETE':
                response = requests.delete(url, headers=headers, timeout=10)
            else:
                return False, 0, 0
            
            elapsed_ms = (time.time() - start_time) * 1000
            success = response.status_code == 200 or response.status_code == 201
            
            return success, elapsed_ms, response.status_code
            
        except Exception as e:
            elapsed_ms = (time.time() - start_time) * 1000
            print(f"❌ 请求失败: {e}")
            return False, elapsed_ms, 0
    
    def run_test(self, method: str, endpoint: str, total_requests: int, 
                 concurrency: int, data: dict = None, headers: dict = None) -> Dict:
        """
        运行压力测试
        """
        print(f"\n🚀 开始压力测试: {method} {endpoint}")
        print(f"   总请求数: {total_requests}")
        print(f"   并发数: {concurrency}")
        
        results: List[Tuple[bool, float, int]] = []
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=concurrency) as executor:
            futures = []
            for i in range(total_requests):
                future = executor.submit(self.single_request, method, endpoint, data, headers)
                futures.append(future)
            
            completed = 0
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
                completed += 1
                if completed % 10 == 0:
                    print(f"   进度: {completed}/{total_requests} ({completed*100//total_requests}%)")
        
        total_time = time.time() - start_time
        
        # 统计结果
        success_count = sum(1 for r in results if r[0])
        fail_count = total_requests - success_count
        latencies = [r[1] for r in results if r[0]]  # 只统计成功的请求
        
        if not latencies:
            print("❌ 所有请求都失败了！")
            return {}
        
        stats = {
            'method': method,
            'endpoint': endpoint,
            'total_requests': total_requests,
            'concurrency': concurrency,
            'success_count': success_count,
            'fail_count': fail_count,
            'success_rate': f"{success_count*100/total_requests:.2f}%",
            'total_time_sec': round(total_time, 2),
            'qps': round(total_requests / total_time, 2),
            'latency': {
                'min_ms': round(min(latencies), 2),
                'max_ms': round(max(latencies), 2),
                'avg_ms': round(statistics.mean(latencies), 2),
                'median_ms': round(statistics.median(latencies), 2),
                'p95_ms': round(self.percentile(latencies, 95), 2),
                'p99_ms': round(self.percentile(latencies, 99), 2),
                'std_dev_ms': round(statistics.stdev(latencies) if len(latencies) > 1 else 0, 2)
            }
        }
        
        return stats
    
    def percentile(self, data: List[float], percentile: int) -> float:
        """计算百分位数"""
        sorted_data = sorted(data)
        index = int(len(sorted_data) * percentile / 100)
        if index >= len(sorted_data):
            index = len(sorted_data) - 1
        return sorted_data[index]
    
    def print_stats(self, stats: Dict):
        """打印统计结果"""
        if not stats:
            return
        
        print("\n" + "="*60)
        print(f"📊 测试结果: {stats['method']} {stats['endpoint']}")
        print("="*60)
        print(f"总请求数:     {stats['total_requests']}")
        print(f"并发数:       {stats['concurrency']}")
        print(f"成功数:       {stats['success_count']}")
        print(f"失败数:       {stats['fail_count']}")
        print(f"成功率:       {stats['success_rate']}")
        print(f"总耗时:       {stats['total_time_sec']} 秒")
        print(f"QPS:          {stats['qps']} 请求/秒")
        print("\n⏱️  响应时间统计:")
        print(f"  最小延迟:   {stats['latency']['min_ms']} ms")
        print(f"  最大延迟:   {stats['latency']['max_ms']} ms")
        print(f"  平均延迟:   {stats['latency']['avg_ms']} ms")
        print(f"  中位数:     {stats['latency']['median_ms']} ms")
        print(f"  P95延迟:    {stats['latency']['p95_ms']} ms")
        print(f"  P99延迟:    {stats['latency']['p99_ms']} ms")
        print(f"  标准差:     {stats['latency']['std_dev_ms']} ms")
        print("="*60)
    
    def save_report(self, all_stats: List[Dict], filename: str = None):
        """保存测试报告到JSON文件"""
        if filename is None:
            filename = f"performance_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'base_url': self.base_url,
            'tests': all_stats
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        print(f"\n💾 测试报告已保存到: {filename}")


def main():
    parser = argparse.ArgumentParser(description='HTTP + 数据库压力测试工具')
    parser.add_argument('--url', default='http://localhost:8080', help='服务器地址')
    parser.add_argument('--requests', type=int, default=100, help='总请求数')
    parser.add_argument('--concurrency', type=int, default=10, help='并发数')
    parser.add_argument('--test', choices=['query', 'insert', 'update', 'delete', 'all'], 
                       default='all', help='测试类型')
    
    args = parser.parse_args()
    
    tester = PerformanceTest(args.url)
    all_stats = []
    
    print("="*60)
    print("🔥 HTTP + 数据库压力测试工具")
    print("="*60)
    print(f"服务器地址: {args.url}")
    print(f"总请求数: {args.requests}")
    print(f"并发数: {args.concurrency}")
    print("="*60)
    
    # 测试查询接口
    if args.test in ['query', 'all']:
        stats = tester.run_test(
            'GET', 
            '/api/processing',
            args.requests,
            args.concurrency,
            data={'page': 1, 'size': 20}
        )
        if stats:
            tester.print_stats(stats)
            all_stats.append(stats)
    
    # 测试插入接口
    if args.test in ['insert', 'all']:
        insert_data = {
            'customerName': '压力测试客户',
            'farmName': '压力测试农场',
            'fruitName': '测试水果',
            'status': '已完成',
            'startTime': '2025-01-15 10:00:00',
            'endTime': '2025-01-15 11:00:00',
            'weight': 100.5,
            'count': 1000
        }
        stats = tester.run_test(
            'POST',
            '/api/processing',
            args.requests,
            args.concurrency,
            data=insert_data,
            headers={'Content-Type': 'application/json'}
        )
        if stats:
            tester.print_stats(stats)
            all_stats.append(stats)
    
    # 测试更新接口（需要先有数据）
    if args.test in ['update', 'all']:
        update_data = {
            'status': '已完成',
            'weight': 200.5
        }
        # 假设ID从1开始，实际应该先查询获取ID
        stats = tester.run_test(
            'PUT',
            '/api/processing/1',
            min(args.requests, 50),  # 更新测试用较少请求
            args.concurrency,
            data=update_data,
            headers={'Content-Type': 'application/json'}
        )
        if stats:
            tester.print_stats(stats)
            all_stats.append(stats)
    
    # 测试删除接口（需要先有数据）
    if args.test in ['delete', 'all']:
        # 假设ID从1开始，实际应该先查询获取ID
        stats = tester.run_test(
            'DELETE',
            '/api/processing/1',
            min(args.requests, 50),  # 删除测试用较少请求
            args.concurrency
        )
        if stats:
            tester.print_stats(stats)
            all_stats.append(stats)
    
    # 保存报告
    if all_stats:
        tester.save_report(all_stats)
    
    print("\n✅ 测试完成！")


if __name__ == '__main__':
    main()


