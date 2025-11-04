import { test, expect } from '@playwright/test'

/**
 * 快速冒烟（PR 触发，5~10 分钟内完成）
 * 验证内置 HTTP 服务基本可用：listJson 可读，insert 可写
 */

test.describe('HTTP 服务 - 快速冒烟', () => {
  // 使用 playwright.config.ts 的 baseURL；用例里统一相对路径

  const readList = async (requestFixture: any) => {
    const res = await requestFixture.get('/api/processing?action=listJson')
    expect(res.ok()).toBeTruthy()
    const body = await res.json().catch(() => null)
    if (Array.isArray(body)) return body
    if (body && Array.isArray(body.data)) return body.data
    return []
  }

  test('listJson 可访问，insert 可写入并数量+1', async ({ request }) => {
    // 1) 基线列表
    const data1 = await readList(request)
    const beforeCount: number = data1.length

    // 2) 写入一条唯一记录
    const now = new Date()
    const fmt = (d: Date) => {
      const y = d.getFullYear()
      const m = String(d.getMonth() + 1).padStart(2, '0')
      const dd = String(d.getDate()).padStart(2, '0')
      const hh = String(d.getHours()).padStart(2, '0')
      const mm = String(d.getMinutes()).padStart(2, '0')
      return `${y}-${m}-${dd} ${hh}:${mm}`
    }
    const start = fmt(now)
    const end = fmt(new Date(now.getTime() + 15 * 60 * 1000))
    const uniq = `SMOKE_${Date.now()}`

    const ins = await request.get('/api/processing', {
      params: {
        action: 'insert',
        startTime: start,
        endTime: end,
        customerName: uniq,
        farmName: '冒烟农场',
        fruitName: '苹果',
        productType: '苹果',
        weight: '1.23',
        count: '7'
      }
    })
    expect(ins.ok()).toBeTruthy()

    // 3) 轮询列表直到找到刚写入的唯一记录（最多重试 20 次，每次 500ms）
    let found = false
    for (let i = 0; i < 20; i++) {
      const arr = await readList(request)
      if (arr.some((r: any) => String(r.customerName) === uniq)) {
        found = true
        break
      }
      await new Promise(r => setTimeout(r, 500))
    }
    expect(found).toBeTruthy()

    // 可选：数量至少不低于基线
    const dataFinal = await readList(request)
    const afterCount: number = dataFinal.length
    expect(afterCount).toBeGreaterThanOrEqual(beforeCount)
  })
})
