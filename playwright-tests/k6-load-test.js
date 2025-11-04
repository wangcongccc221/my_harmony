import http from 'k6/http'
import { sleep, check } from 'k6'

// 15 分钟总时长：1m 预热 + 13m 稳态 + 1m 降载
export const options = {
  stages: [
    { duration: '1m', target: 10 },   // 预热
    { duration: '13m', target: 10 },  // 稳态
    { duration: '1m', target: 0 }     // 降载
  ],
  thresholds: {
    http_req_failed: ['rate<0.05'],      // 失败率 < 5%
    http_req_duration: ['p(95)<1500']    // 95 分位 < 1.5s
  }
}

const BASE = __ENV.BASE_URL || 'http://127.0.0.1:8080'

export default function () {
  // 70% 列表，30% 插入
  if (Math.random() < 0.7) {
    const res = http.get(`${BASE}/api/processing?action=listJson`)
    check(res, { ok: r => r.status === 200 })
  } else {
    const now = new Date()
    const fmt = (d) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
    const start = fmt(now)
    const end = fmt(new Date(now.getTime() + 15 * 60 * 1000)) // 15 分钟窗口
    const uniq = `K6_${Date.now()}_${Math.floor(Math.random()*1e6)}`
    const url = `${BASE}/api/processing?action=insert&startTime=${encodeURIComponent(start)}&endTime=${encodeURIComponent(end)}&customerName=${encodeURIComponent(uniq)}&farmName=${encodeURIComponent('压力农场')}&fruitName=${encodeURIComponent('苹果')}&productType=${encodeURIComponent('苹果')}&weight=1.23&count=7`
    const res = http.get(url)
    check(res, { ok: r => r.status === 200 })
  }
  sleep(1)
}


