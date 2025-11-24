import argparse
import json
import time
import uuid
import random
import threading
from urllib.parse import urlparse
import http.client

FRUITS = ['苹果', '香蕉', '橙子', '梨子', '葡萄', '草莓']
STATUS = ['已完成', '进行中', '待开始']

def build_record():
    now = time.strftime('%Y-%m-%d %H:%M:%S')
    fruit = random.choice(FRUITS)
    weight = round(random.uniform(0.5, 50.0), 2)
    count = random.randint(1, 10)
    status = random.choice(STATUS)
    return {
        'customerName': f'客户-{uuid.uuid4().hex[:8]}',
        'farmName': f'农场-{uuid.uuid4().hex[:6]}',
        'fruitName': fruit,
        'status': status,
        'startTime': now,
        'endTime': now,
        'totalWeight': weight,
        'count': count
    }

def worker(base_url: str, jobs: int, progress: list):
    u = urlparse(base_url)
    conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=15) if u.scheme == 'https' else http.client.HTTPConnection(u.hostname, u.port or 80, timeout=15)
    ok = 0
    for _ in range(jobs):
        rec = build_record()
        data = json.dumps(rec).encode('utf-8')
        try:
            conn.request('POST', '/api/processing?compact=1', body=data, headers={'Content-Type': 'application/json'})
            resp = conn.getresponse()
            _ = resp.read()
            if resp.status == 200:
                ok += 1
        except Exception:
            pass
    try:
        conn.close()
    except Exception:
        pass
    progress.append(ok)

def batch_worker(base_url: str, jobs: int, batch_size: int, progress: list):
    u = urlparse(base_url)
    conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=30) if u.scheme == 'https' else http.client.HTTPConnection(u.hostname, u.port or 80, timeout=30)
    ok = 0
    remaining = jobs
    try:
        while remaining > 0:
            n = min(batch_size, remaining)
            payload = [build_record() for _ in range(n)]
            data = json.dumps(payload, ensure_ascii=False).encode('utf-8')
            conn.request('POST', '/api/processing/batch', body=data, headers={'Content-Type': 'application/json'})
            resp = conn.getresponse()
            body = resp.read()
            if resp.status == 200:
                try:
                    jr = json.loads(body.decode('utf-8', errors='replace'))
                    ok += int(jr.get('data', {}).get('inserted', n))
                except Exception:
                    ok += n
            else:
                try:
                    msg = body.decode('utf-8', errors='replace')
                except Exception:
                    msg = '<binary>'
                print(f'批量请求失败: status={resp.status}, body={msg[:200]}')
            remaining -= n
    except Exception as e:
        print(f'批量插入异常: {e}')
    try:
        conn.close()
    except Exception:
        pass
    progress.append(ok)

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--base-url', default='http://127.0.0.1:8080')
    p.add_argument('--total', type=int, default=10000)
    p.add_argument('--concurrency', type=int, default=16)
    p.add_argument('--batch-size', type=int, default=0, help='>0 则启用批量接口')
    args = p.parse_args()

    total = max(1, args.total)
    concurrency = max(1, args.concurrency)
    jobs_per_thread = total // concurrency
    remainder = total % concurrency

    threads = []
    progress = []
    start = time.perf_counter()
    for i in range(concurrency):
        jobs = jobs_per_thread + (1 if i < remainder else 0)
        if args.batch_size and args.batch_size > 0:
            t = threading.Thread(target=batch_worker, args=(args.base_url, jobs, args.batch_size, progress))
        else:
            t = threading.Thread(target=worker, args=(args.base_url, jobs, progress))
        t.daemon = True
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    end = time.perf_counter()
    inserted = sum(progress)
    dur = end - start
    rps = inserted / dur if dur > 0 else 0.0
    print(f'插入完成：{inserted} 条，用时 {dur:.3f} 秒，平均 RPS {rps:.2f}')

if __name__ == '__main__':
    main()
