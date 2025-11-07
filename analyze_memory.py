import csv
import statistics

# 读取CSV文件
data = []
with open('mem_monitor_com.nutpi.My_Project.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        data.append(row)

print('=== 内存稳定性分析 ===')
print(f'\n总数据点: {len(data)}')
print(f'时间范围: {data[0]["timestamp"]} 到 {data[-1]["timestamp"]}')

# 提取数值列
pss_values = [float(row['pss_mb']) for row in data]
native_heap_values = [float(row['native_heap_mb']) for row in data]
arkts_heap_values = [float(row['arkts_heap_mb']) for row in data]

print(f'\n=== PSS (总内存) ===')
print(f'最小值: {min(pss_values):.2f} MB')
print(f'最大值: {max(pss_values):.2f} MB')
print(f'平均值: {statistics.mean(pss_values):.2f} MB')
print(f'标准差: {statistics.stdev(pss_values):.2f} MB')

print(f'\n最后100个数据点:')
last100_pss = pss_values[-100:]
print(f'  最小值: {min(last100_pss):.2f} MB')
print(f'  最大值: {max(last100_pss):.2f} MB')
print(f'  平均值: {statistics.mean(last100_pss):.2f} MB')
print(f'  标准差: {statistics.stdev(last100_pss):.2f} MB')

print(f'\n=== Native Heap ===')
print(f'最小值: {min(native_heap_values):.2f} MB')
print(f'最大值: {max(native_heap_values):.2f} MB')
print(f'平均值: {statistics.mean(native_heap_values):.2f} MB')
print(f'标准差: {statistics.stdev(native_heap_values):.2f} MB')

print(f'\n最后100个数据点:')
last100_native = native_heap_values[-100:]
print(f'  最小值: {min(last100_native):.2f} MB')
print(f'  最大值: {max(last100_native):.2f} MB')
print(f'  平均值: {statistics.mean(last100_native):.2f} MB')
print(f'  标准差: {statistics.stdev(last100_native):.2f} MB')

print(f'\n=== ArkTS Heap ===')
print(f'最小值: {min(arkts_heap_values):.2f} MB')
print(f'最大值: {max(arkts_heap_values):.2f} MB')
print(f'平均值: {statistics.mean(arkts_heap_values):.2f} MB')
print(f'标准差: {statistics.stdev(arkts_heap_values):.2f} MB')

print(f'\n最后100个数据点:')
last100_arkts = arkts_heap_values[-100:]
print(f'  最小值: {min(last100_arkts):.2f} MB')
print(f'  最大值: {max(last100_arkts):.2f} MB')
print(f'  平均值: {statistics.mean(last100_arkts):.2f} MB')
print(f'  标准差: {statistics.stdev(last100_arkts):.2f} MB')

# 检查是否有持续增长趋势
print(f'\n=== 趋势分析 ===')
# 检查最后200个数据点是否有持续增长
last200_pss = pss_values[-200:]
first_half = statistics.mean(last200_pss[:100])
second_half = statistics.mean(last200_pss[100:])
diff = second_half - first_half
print(f'最后200个数据点，前半段平均: {first_half:.2f} MB')
print(f'最后200个数据点，后半段平均: {second_half:.2f} MB')
print(f'差异: {diff:.2f} MB ({diff/first_half*100:.2f}%)')

if abs(diff) < 5:
    print('✅ 内存非常稳定，无明显增长趋势')
elif diff < 10:
    print('⚠️  内存有轻微增长，但仍在可接受范围')
else:
    print('❌ 内存有明显增长趋势，可能存在泄漏')

# 检查异常峰值
print(f'\n=== 异常峰值检测 ===')
max_idx = pss_values.index(max(pss_values))
print(f'最大峰值: {pss_values[max_idx]:.2f} MB')
print(f'峰值时间: {data[max_idx]["timestamp"]}')
print(f'峰值时的Native Heap: {native_heap_values[max_idx]:.2f} MB')
print(f'峰值时的ArkTS Heap: {arkts_heap_values[max_idx]:.2f} MB')

# 检查峰值后的恢复情况
if max_idx < len(data) - 50:
    after_peak = pss_values[max_idx+1:max_idx+51]
    print(f'\n峰值后50个数据点的平均PSS: {statistics.mean(after_peak):.2f} MB')
    if statistics.mean(after_peak) < pss_values[max_idx] * 0.8:
        print('✅ 峰值后内存已恢复正常水平')
