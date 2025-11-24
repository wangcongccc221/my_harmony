import argparse
import sys
import json
import time
import uuid
import threading
import math
import random
from urllib.parse import urlparse
import http.client
import gzip

def _request(base_url: str, method: str, path: str, body=None, headers=None):
    u = urlparse(base_url)
    if u.scheme == 'https':
        conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=10)
    else:
        conn = http.client.HTTPConnection(u.hostname, u.port or 80, timeout=10)
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
    conn.request(method, path, body=data, headers=h)
    resp = conn.getresponse()
    status = resp.status
    raw = resp.read()
    enc = (resp.getheader('Content-Encoding') or '').lower()
    if 'gzip' in enc:
        try:
            raw = gzip.decompress(raw)
        except Exception:
            pass
    text = raw.decode('utf-8', errors='replace')
    conn.close()
    return status, text

def _parse_json(text: str):
    try:
        return json.loads(text)
    except Exception:
        return None

def _assert_ok(j):
    return isinstance(j, dict) and j.get('ok') is True

def _build_record():
    now_str = time.strftime('%Y-%m-%d %H:%M:%S')
    return {
        'customerName': '压测-' + uuid.uuid4().hex[:8],
        'farmName': '压力场',
        'fruitName': '苹果',
        'status': '进行中',
        'startTime': now_str,
        'endTime': now_str,
        'totalWeight': 1.0,
        'count': 1
    }

class _Stats:
    def __init__(self):
        self.total = 0
        self.success = 0
        self.errors = 0
        self.status_2xx = 0
        self.status_4xx = 0
        self.status_5xx = 0
        self.latencies = []
        self.lock = threading.Lock()
    def add(self, status, ok, latency):
        with self.lock:
            self.total += 1
            if 200 <= status < 300:
                self.status_2xx += 1
            elif 400 <= status < 500:
                self.status_4xx += 1
            elif 500 <= status < 600:
                self.status_5xx += 1
            if ok:
                self.success += 1
            else:
                self.errors += 1
            if latency is not None:
                self.latencies.append(latency)

def _percentile(xs, p):
    if not xs:
        return 0.0
    s = sorted(xs)
    idx = max(0, min(len(s) - 1, int(math.ceil(p * len(s)) - 1)))
    return s[idx]

def run_smoke(base_url: str):
    status, body = _request(base_url, 'GET', '/api/status')
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print('状态接口失败', status, body)
        sys.exit(1)
    status, body = _request(base_url, 'GET', '/api/processing?action=listJson')
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j) or not isinstance(j.get('data'), list):
        print('初始列表失败', status, body)
        sys.exit(1)
    before_ids = set([r.get('id') for r in j.get('data') if isinstance(r, dict)])
    record = _build_record()
    status, body = _request(base_url, 'POST', '/api/processing', body=record)
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j) or not isinstance(j.get('data'), list):
        print('插入失败', status, body)
        sys.exit(1)
    after = j.get('data')
    after_ids = set([r.get('id') for r in after if isinstance(r, dict)])
    new_ids = [i for i in after_ids if i not in before_ids and isinstance(i, int)]
    new_id = new_ids[0] if len(new_ids) > 0 else max([i for i in after_ids if isinstance(i, int)], default=None)
    if not new_id:
        print('无法确定插入ID', after)
        sys.exit(1)
    update_body = {'status': '已更新', 'weight': 15.0}
    status, body = _request(base_url, 'PUT', f'/api/processing/{new_id}', body=update_body)
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print('更新失败', status, body)
        sys.exit(1)
    data = j.get('data')
    target = None
    if isinstance(data, list):
        for r in data:
            if isinstance(r, dict) and r.get('id') == new_id:
                target = r
                break
    if not target:
        print('更新后未找到记录', data)
        sys.exit(1)
    status, body = _request(base_url, 'DELETE', f'/api/processing/{new_id}')
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print('删除失败', status, body)
        sys.exit(1)
    data = j.get('data')
    exists = False
    if isinstance(data, list):
        for r in data:
            if isinstance(r, dict) and r.get('id') == new_id:
                exists = True
                break
    if exists:
        print('删除后记录仍存在')
        sys.exit(1)
    print('测试通过')
    sys.exit(0)

def run_read_all_once(base_url: str, lite_count: bool = False, dump: bool = False, output: str = '', pack: bool = False, use_gzip: bool = False):
    t0 = time.perf_counter()
    if lite_count:
        status, body = _request(base_url, 'GET', '/api/processing?action=listJsonLite&page=1&size=1')
    else:
        path = '/api/processing?action=listJson'
        if pack:
            path += '&pack=1'
        headers = {'Accept-Encoding': 'gzip'} if use_gzip else None
        status, body = _request(base_url, 'GET', path, headers=headers)
    dt_ms = (time.perf_counter() - t0) * 1000.0
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print(f'查询失败 status={status} body={body[:200]}')
        return
    if lite_count:
        d = j.get('data') or {}
        total = int(d.get('total', 0))
        print(f'查询成功（lite计数），共 {total} 条，耗时 {dt_ms:.2f} 毫秒')
    else:
        data = j.get('data')
        if pack and isinstance(data, dict) and isinstance(data.get('rows'), list):
            rows = data.get('rows')
            cnt = len(rows)
            print(f'查询成功（pack），共 {cnt} 条，耗时 {dt_ms:.2f} 毫秒')
            if dump:
                out_path = output if output else 'select_all_packed.json'
                try:
                    with open(out_path, 'w', encoding='utf-8') as f:
                        f.write(json.dumps(data, ensure_ascii=False))
                    print(f'已保存到 {out_path}')
                except Exception as e:
                    print(f'保存失败: {e}')
        else:
            cnt = len(data) if isinstance(data, list) else 0
            print(f'查询成功，共 {cnt} 条，耗时 {dt_ms:.2f} 毫秒')
            if dump and isinstance(data, list):
                out_path = output if output else 'select_all.json'
                try:
                    with open(out_path, 'w', encoding='utf-8') as f:
                        f.write(json.dumps(data, ensure_ascii=False))
                    print(f'已保存到 {out_path}')
                except Exception as e:
                    print(f'保存失败: {e}')

def run_list_json_lite(base_url: str, page: int, size: int):
    t0 = time.perf_counter()
    status, body = _request(base_url, 'GET', f'/api/processing?action=listJsonLite&page={page}&size={size}')
    dt_ms = (time.perf_counter() - t0) * 1000.0
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print(f'查询失败 status={status} body={body[:200]}')
        return
    d = j.get('data') or {}
    total = int(d.get('total', 0))
    count = int(d.get('count', 0))
    print(f'轻量查询成功：总数 {total}，本页 {count} 条，耗时 {dt_ms:.2f} 毫秒')

def run_dump_paged(base_url: str, size: int, output: str):
    page = 1
    all_rows = []
    t0 = time.perf_counter()
    while True:
        status, body = _request(base_url, 'GET', f'/api/processing?page={page}&size={size}')
        if status != 200:
            print(f'分页查询失败：status={status} page={page}')
            break
        j = _parse_json(body)
        if not _assert_ok(j):
            print(f'分页查询返回非ok：page={page} body={body[:200]}')
            break
        data = j.get('data') or []
        pg = (j.get('pagination') or {})
        total = int(pg.get('total', 0))
        total_pages = int(pg.get('totalPages', 0))
        all_rows.extend([r for r in data if isinstance(r, dict)])
        print(f'页 {page}/{total_pages} 累计 {len(all_rows)} 条')
        if total_pages and page >= total_pages:
            break
        if not data or len(data) < size:
            break
        page += 1
    dt_ms = (time.perf_counter() - t0) * 1000.0
    try:
        out_path = output if output else 'select_all_paged.json'
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(json.dumps(all_rows, ensure_ascii=False))
        print(f'分页导出完成：{len(all_rows)} 条，耗时 {dt_ms:.2f} 毫秒，已保存到 {out_path}')
    except Exception as e:
        print(f'保存失败: {e}')

def run_stress(base_url: str, concurrency: int, duration: int, mode: str, write_ratio: float, cleanup: bool, page_size: int):
    status, body = _request(base_url, 'GET', '/api/status')
    j = _parse_json(body)
    if status != 200 or not _assert_ok(j):
        print('状态接口失败', status, body)
        sys.exit(1)
    stats = _Stats()
    stop_at = time.perf_counter() + duration
    u = urlparse(base_url)
    def one():
        conn = http.client.HTTPSConnection(u.hostname, u.port or 443, timeout=10) if u.scheme == 'https' else http.client.HTTPConnection(u.hostname, u.port or 80, timeout=10)
        while time.perf_counter() < stop_at:
            t0 = time.perf_counter()
            try:
                do_write = mode == 'write' or (mode == 'mixed' and random.random() < write_ratio)
                if not do_write:
                    conn.request('GET', f'/api/processing?page=1&size={page_size}&lite=1&nocount=1')
                    resp = conn.getresponse()
                    s = resp.status
                    b = resp.read().decode('utf-8', errors='replace')
                    jj = _parse_json(b)
                    ok = s == 200 and _assert_ok(jj)
                    stats.add(s, ok, time.perf_counter() - t0)
                else:
                    rec = _build_record()
                    data = json.dumps(rec).encode('utf-8')
                    conn.request('POST', '/api/processing?compact=1', body=data, headers={'Content-Type': 'application/json'})
                    resp = conn.getresponse()
                    s = resp.status
                    b = resp.read().decode('utf-8', errors='replace')
                    jj = _parse_json(b)
                    ok = s == 200 and _assert_ok(jj)
                    stats.add(s, ok, time.perf_counter() - t0)
                    if cleanup and ok and isinstance(jj.get('data'), dict):
                        rid = jj.get('data', {}).get('id')
                        if rid:
                            conn.request('DELETE', f'/api/processing/{rid}')
                            _ = conn.getresponse()
                            _.read()
            except Exception:
                stats.add(0, False, time.perf_counter() - t0)
    threads = []
    for _ in range(max(1, concurrency)):
        t = threading.Thread(target=one)
        t.daemon = True
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    lat = stats.latencies
    avg = (sum(lat) / len(lat)) if lat else 0.0
    p50 = _percentile(lat, 0.50)
    p90 = _percentile(lat, 0.90)
    p95 = _percentile(lat, 0.95)
    p99 = _percentile(lat, 0.99)
    print('总请求数', stats.total)
    print('成功数', stats.success)
    print('错误数', stats.errors)
    print('2xx', stats.status_2xx)
    print('4xx', stats.status_4xx)
    print('5xx', stats.status_5xx)
    print('平均延迟秒', round(avg, 6))
    print('P50秒', round(p50, 6))
    print('P90秒', round(p90, 6))
    print('P95秒', round(p95, 6))
    print('P99秒', round(p99, 6))
    print('吞吐RPS', round(stats.total / max(1.0, float(duration)), 2))

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--base-url', default='http://127.0.0.1:8080')
    p.add_argument('--stress', action='store_true')
    p.add_argument('--read-all-once', action='store_true')
    p.add_argument('--lite-count', action='store_true')
    p.add_argument('--pack', action='store_true')
    p.add_argument('--gzip', action='store_true')
    p.add_argument('--dump', action='store_true')
    p.add_argument('--output', type=str, default='')
    p.add_argument('--list-json-lite', action='store_true')
    p.add_argument('--page', type=int, default=1)
    p.add_argument('--size', type=int, default=20)
    p.add_argument('--dump-paged', action='store_true')
    p.add_argument('--dump-size', type=int, default=200)
    p.add_argument('--dump-output', type=str, default='select_all_paged.json')
    p.add_argument('--mode', choices=['read', 'write', 'mixed'], default='mixed')
    p.add_argument('--concurrency', type=int, default=32)
    p.add_argument('--duration', type=int, default=30)
    p.add_argument('--write-ratio', type=float, default=0.3)
    p.add_argument('--cleanup', action='store_true')
    p.add_argument('--page-size', type=int, default=20)
    args = p.parse_args()
    if args.read_all_once:
        run_read_all_once(args.base_url, args.lite_count, args.dump, args.output, args.pack, args.gzip)
        return
    if args.list_json_lite:
        run_list_json_lite(args.base_url, args.page, args.size)
        return
    if args.dump_paged:
        run_dump_paged(args.base_url, args.dump_size, args.dump_output)
        return
    if args.stress:
        run_stress(args.base_url, args.concurrency, args.duration, args.mode, args.write_ratio, args.cleanup, args.page_size)
        return
    run_smoke(args.base_url)

if __name__ == '__main__':
    main()
