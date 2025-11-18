#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
数据库性能测试客户端
通过 HTTP API 调用性能测试并展示结果
"""

import requests
import time
import json
from typing import Dict, Any, Optional

# 配置
BASE_URL = "http://localhost:8080"
API_BASE = f"{BASE_URL}/api/performance"

def print_section(title: str):
    """打印分节标题"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def check_server():
    """检查服务器连接"""
    try:
        response = requests.get(f"{BASE_URL}/api/status", timeout=5)
        response.raise_for_status()
        print("✓ 服务器连接正常")
        return True
    except requests.exceptions.RequestException as e:
        print(f"✗ 无法连接到服务器: {e}")
        print(f"  请确保 HTTP 服务器已启动（端口 8080）")
        return False

def get_api_info():
    """获取 API 信息"""
    try:
        response = requests.get(API_BASE, timeout=5)
        response.raise_for_status()
        info = response.json()
        
        if info.get('ok'):
            data = info.get('data', {})
            print_section("性能测试 API 信息")
            print(f"描述: {data.get('description', 'N/A')}\n")
            
            endpoints = data.get('endpoints', {})
            if endpoints:
                print("可用接口:")
                for endpoint, desc in endpoints.items():
                    print(f"  {endpoint:<40} {desc}")
            
            test_desc = data.get('testDescription', {})
            if test_desc:
                print(f"\n测试说明:")
                print(f"  窄表: {test_desc.get('narrowTable', 'N/A')}")
                print(f"  宽表: {test_desc.get('wideTable', 'N/A')}")
                
                scenarios = test_desc.get('testScenarios', [])
                if scenarios:
                    print(f"\n测试场景:")
                    for i, scenario in enumerate(scenarios, 1):
                        print(f"  {i}. {scenario}")
        
        return True
    except requests.exceptions.RequestException as e:
        print(f"✗ 获取 API 信息失败: {e}")
        return False

def start_test() -> bool:
    """启动性能测试"""
    print_section("启动性能测试")
    try:
        response = requests.post(f"{API_BASE}/start", timeout=5)
        response.raise_for_status()
        result = response.json()
        
        if result.get('ok'):
            data = result.get('data', {})
            print(f"✓ {result.get('message', '测试已启动')}")
            print(f"  状态: {data.get('status', 'N/A')}")
            return True
        else:
            print(f"✗ 启动失败: {result.get('message', '未知错误')}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"✗ 启动测试失败: {e}")
        return False

def get_status() -> Optional[Dict[str, Any]]:
    """查询测试状态"""
    try:
        response = requests.get(f"{API_BASE}/status", timeout=5)
        response.raise_for_status()
        result = response.json()
        
        if result.get('ok'):
            return result.get('data', {})
        else:
            print(f"⚠ API 返回错误: {result.get('message', '未知错误')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"✗ 查询状态失败: {e}")
        return None

def wait_for_completion(max_wait_time: int = 600) -> bool:
    """等待测试完成"""
    print_section("等待测试完成")
    start_time = time.time()
    last_progress = ""
    last_time = start_time
    no_status_count = 0
    
    print("正在执行性能测试，请稍候...\n")
    
    while time.time() - start_time < max_wait_time:
        status = get_status()
        
        if not status:
            no_status_count += 1
            if no_status_count > 3:
                print("✗ 连续无法获取测试状态，可能测试未启动或服务器异常")
                return False
            time.sleep(1)
            continue
        
        no_status_count = 0
        is_running = status.get('isRunning', False)
        progress = status.get('progress', '')
        start_time_stamp = status.get('startTime')
        end_time_stamp = status.get('endTime')
        duration = status.get('duration')
        
        # 显示进度变化
        if progress != last_progress:
            elapsed = time.time() - last_time
            print(f"  [{elapsed:>6.1f}s] {progress}")
            last_progress = progress
            last_time = time.time()
        
        if not is_running:
            if duration:
                print(f"\n✓ 测试完成！")
                print(f"  总耗时: {duration}ms ({duration/1000:.2f}秒)")
            else:
                print(f"\n✓ 测试完成！")
            return True
        
        time.sleep(1)  # 每秒轮询一次
    
    print(f"\n✗ 测试超时（超过 {max_wait_time} 秒）")
    print("  提示：可以手动查询状态: curl http://localhost:8080/api/performance/status")
    return False

def get_results() -> Optional[Dict[str, Any]]:
    """获取测试结果"""
    print_section("获取测试结果")
    try:
        response = requests.get(f"{API_BASE}/results", timeout=5)
        response.raise_for_status()
        result = response.json()
        
        if result.get('ok'):
            return result.get('data', {})
        else:
            print(f"✗ {result.get('message', '获取结果失败')}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"✗ 获取结果失败: {e}")
        return None

def display_results(results: Dict[str, Any]):
    """展示测试结果"""
    if not results:
        print("✗ 暂无测试结果")
        return
    
    print_section("性能测试报告")
    
    # 显示摘要
    summary = results.get('summary', {})
    if summary:
        print("测试配置:")
        print(f"  - 测试数据量: {summary.get('testDataCount', 'N/A')} 条")
        print(f"  - 窄表字段数: {summary.get('narrowTableFields', 'N/A')} 个")
        print(f"  - 宽表字段数: {summary.get('wideTableFields', 'N/A')} 个")
        print(f"  - 测试项数量: {summary.get('totalTests', 'N/A')} 项\n")
    
    # 显示测试结果对比
    test_results = results.get('results', [])
    if test_results:
        print("测试结果对比:")
        print(f"{'测试项':<20} {'窄表耗时':<15} {'宽表耗时':<15} {'性能差异':<15}")
        print("-" * 65)
        
        # 按测试项分组（每两个是一对：窄表和宽表）
        i = 0
        while i < len(test_results):
            if i + 1 < len(test_results):
                narrow = test_results[i]
                wide = test_results[i + 1]
                
                if narrow.get('tableType') == 'narrow' and wide.get('tableType') == 'wide':
                    narrow_time = narrow.get('totalTime', 0)
                    wide_time = wide.get('totalTime', 0)
                    diff = ((wide_time / narrow_time - 1) * 100) if narrow_time > 0 else 0
                    
                    test_name = narrow.get('testName', 'N/A')
                    print(f"{test_name:<20} {narrow_time:<15}ms {wide_time:<15}ms {diff:>13.2f}%")
            
            i += 2
        
        print()
    
    # 显示详细指标
    if test_results:
        print("详细性能指标:")
        print(f"{'测试项':<20} {'表类型':<10} {'操作数':<10} {'总耗时(ms)':<15} {'平均耗时(ms)':<15} {'QPS':<15}")
        print("-" * 85)
        
        for result in test_results:
            test_name = result.get('testName', 'N/A')
            table_type = result.get('tableType', 'N/A')
            count = result.get('count', 0)
            total_time = result.get('totalTime', 0)
            avg_time = result.get('avgTime', 0)
            qps = result.get('qps', 0)
            
            print(f"{test_name:<20} {table_type:<10} {count:<10} {total_time:<15} {avg_time:<15.2f} {qps:<15.2f}")
        
        print()
    
    # 显示结论
    conclusions = results.get('conclusions', {})
    if conclusions:
        print("测试结论:")
        print(f"  1. 插入操作：宽表比窄表慢 {conclusions.get('insertDiff', 'N/A')}")
        print(f"  2. 查询少量字段：性能差异 {conclusions.get('selectFewDiff', 'N/A')}")
        print(f"  3. SELECT * 查询：宽表比窄表慢 {conclusions.get('selectAllDiff', 'N/A')}")
        print(f"  4. 全表扫描：宽表比窄表慢 {conclusions.get('countDiff', 'N/A')}")
        print(f"  5. 更新操作：宽表比窄表慢 {conclusions.get('updateDiff', 'N/A')}")
        print()
    
    print("建议:")
    print("  - 避免使用 SELECT *，只查询需要的字段")
    print("  - 宽表（字段多）在 SELECT * 和全表扫描时性能明显下降")
    print("  - 查询少量字段时，宽表和窄表性能差异较小")
    print("  - 根据实际需求合理设计表结构，避免过度宽表设计")

def main():
    """主函数"""
    print_section("数据库性能压测客户端")
    print(f"服务器地址: {BASE_URL}")
    print(f"API 基础路径: {API_BASE}\n")
    
    # 检查服务器连接
    if not check_server():
        return
    
    print()
    
    # 显示 API 信息
    get_api_info()
    
    # 启动测试
    if not start_test():
        return
    
    # 等待测试完成
    if wait_for_completion():
        # 获取并展示结果
        results = get_results()
        if results:
            display_results(results)
        else:
            print("\n✗ 无法获取测试结果")
    else:
        print("\n✗ 测试未完成，无法获取结果")
    
    print_section("测试流程结束")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n用户中断测试")
    except Exception as e:
        print(f"\n✗ 发生错误: {e}")
        import traceback
        traceback.print_exc()

