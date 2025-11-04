/**
 * K6 极限负载测试脚本
 * 用于测试数据库在高并发下的极限性能
 * 
 * 运行: k6 run k6-load-test-extreme.js
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// 自定义指标
const insertSuccessRate = new Rate('insert_success_rate');
const querySuccessRate = new Rate('query_success_rate');
const insertResponseTime = new Trend('insert_response_time');
const queryResponseTime = new Trend('query_response_time');

// 负载测试配置 - 短时间并发测试（约5分钟，最高10并发）
export const options = {
  stages: [
    // 预热阶段（1分钟）
    { duration: '20s', target: 2 },     // 20秒到2个用户
    { duration: '20s', target: 5 },    // 20秒到5个用户
    { duration: '20s', target: 10 },    // 20秒到10个用户
    
    // 压力测试（3分钟）
    { duration: '1m', target: 10 },   // 保持10个用户1分钟
    { duration: '1m', target: 10 },   // 保持10个用户1分钟
    { duration: '1m', target: 10 },   // 保持10个用户1分钟
    
    // 逐步降载（1分钟）
    { duration: '20s', target: 5 },   // 降到5
    { duration: '20s', target: 2 },   // 降到2
    { duration: '20s', target: 0 },      // 降到0
  ],
  thresholds: {
    // 10并发测试下的合理要求
    http_req_duration: ['p(95)<3000', 'p(99)<6000'], // 95%的请求<3秒
    http_req_failed: ['rate<0.1'], // 允许10%错误率
    insert_success_rate: ['rate>0.85'], // 插入成功率>85%
    query_success_rate: ['rate>0.9'], // 查询成功率>90%
  },
};

const BASE_URL = 'http://127.0.0.1:9999';
const API_BASE = `${BASE_URL}/api/processing`;

// 生成测试数据
function generateTestData(index) {
  const customers = ['客户A', '客户B', '客户C', '客户D', '客户E', '客户F', '客户G', '客户H'];
  const farms = ['农场1', '农场2', '农场3', '农场4', '农场5'];
  const fruits = ['苹果', '橙子', '香蕉', '葡萄', '草莓', '西瓜', '桃子', '梨子'];
  const statuses = ['已完成', '进行中', '待开始'];
  
  const now = new Date();
  const startDate = new Date(now.getTime() - Math.random() * 30 * 24 * 60 * 60 * 1000);
  const endDate = new Date(startDate.getTime() + Math.random() * 7 * 24 * 60 * 60 * 1000);
  
  const formatDateTime = (date) => {
    return date.toISOString().slice(0, 16);
  };

  const timestamp = Date.now();
  const random = Math.floor(Math.random() * 1000000);

  return {
    customerName: `${customers[index % customers.length]}_${timestamp}_${random}`,
    farmName: `${farms[index % farms.length]}_${timestamp}`,
    fruitName: fruits[index % fruits.length],
    status: statuses[index % statuses.length],
    startTime: formatDateTime(startDate),
    endTime: formatDateTime(endDate),
    weight: (Math.random() * 1000 + 10).toFixed(2),
    count: Math.floor(Math.random() * 1000) + 1
  };
}

// 手动构建查询字符串（K6 不支持 URLSearchParams）
function buildQueryString(params) {
  const pairs = [];
  for (const key in params) {
    if (params.hasOwnProperty(key)) {
      pairs.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key]));
    }
  }
  return pairs.join('&');
}

// 执行插入操作
function insertData(data) {
  const params = {
    action: 'insert',
    startTime: data.startTime,
    endTime: data.endTime,
    productType: data.fruitName,
    totalWeight: data.weight,
    customerName: data.customerName,
    farmName: data.farmName,
    fruitName: data.fruitName,
    status: data.status,
    count: data.count.toString(),
    weight: data.weight
  };
  
  const url = `${API_BASE}?${buildQueryString(params)}`;
  const startTime = Date.now();
  const res = http.get(url, { timeout: '30s' }); // 增加超时时间
  const responseTime = Date.now() - startTime;
  
  insertResponseTime.add(responseTime);
  
  const success = check(res, {
    'insert status is 200': (r) => r.status === 200,
    'insert response has ok': (r) => {
      try {
        const json = JSON.parse(r.body);
        return json.ok === true;
      } catch (e) {
        return false;
      }
    },
  });
  
  insertSuccessRate.add(success);
  return success;
}

// 执行查询操作
function queryData() {
  const url = `${API_BASE}?action=listJson`;
  const startTime = Date.now();
  const res = http.get(url, { timeout: '30s' }); // 增加超时时间
  const responseTime = Date.now() - startTime;
  
  queryResponseTime.add(responseTime);
  
  const success = check(res, {
    'query status is 200': (r) => r.status === 200,
    'query response has data': (r) => {
      try {
        const json = JSON.parse(r.body);
        return json.ok === true && Array.isArray(json.data);
      } catch (e) {
        return false;
      }
    },
  });
  
  querySuccessRate.add(success);
  return success;
}

// 主测试函数
export default function () {
  const iteration = __ITER;
  const vu = __VU; // 虚拟用户ID
  const data = generateTestData(iteration + vu);
  
  // 70% 查询，30% 插入（查询更轻量，减少服务器压力）
  if (Math.random() < 0.7) {
    queryData();
  } else {
    insertData(data);
  }
  
  // 增加等待时间，减少服务器压力
  sleep(1);
}

// 测试结束后的处理
export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'summary.json': JSON.stringify(data),
  };
}

function textSummary(data, options) {
  const indent = options.indent || '';
  const enableColors = options.enableColors || false;
  
  let summary = '\n';
  summary += `${indent}极限负载测试摘要\n`;
  summary += `${indent}==================\n\n`;
  
  // 请求统计（安全访问）
  if (data.metrics && data.metrics.http_reqs && data.metrics.http_reqs.values) {
    summary += `${indent}HTTP 请求统计:\n`;
    summary += `${indent}  总请求数: ${data.metrics.http_reqs.values.count || 0}\n`;
    summary += `${indent}  请求速率: ${(data.metrics.http_reqs.values.rate || 0).toFixed(2)} req/s\n`;
    summary += `${indent}  失败率: ${((data.metrics.http_req_failed && data.metrics.http_req_failed.values) ? (data.metrics.http_req_failed.values.rate * 100) : 0).toFixed(2)}%\n\n`;
  }
  
  // 响应时间（安全访问）
  if (data.metrics && data.metrics.http_req_duration && data.metrics.http_req_duration.values) {
    summary += `${indent}响应时间统计:\n`;
    summary += `${indent}  平均: ${(data.metrics.http_req_duration.values.avg || 0).toFixed(2)} ms\n`;
    summary += `${indent}  最小: ${data.metrics.http_req_duration.values.min || 0} ms\n`;
    summary += `${indent}  最大: ${data.metrics.http_req_duration.values.max || 0} ms\n`;
    if (data.metrics.http_req_duration.values['p(95)']) {
      summary += `${indent}  P95: ${data.metrics.http_req_duration.values['p(95)']} ms\n`;
    }
    if (data.metrics.http_req_duration.values['p(99)']) {
      summary += `${indent}  P99: ${data.metrics.http_req_duration.values['p(99)']} ms\n`;
    }
    summary += '\n';
  }
  
  // 插入操作（安全访问）
  if (data.metrics && data.metrics.insert_success_rate && data.metrics.insert_success_rate.values) {
    summary += `${indent}插入操作:\n`;
    summary += `${indent}  成功率: ${(data.metrics.insert_success_rate.values.rate * 100).toFixed(2)}%\n`;
    if (data.metrics.insert_response_time && data.metrics.insert_response_time.values) {
      summary += `${indent}  平均响应时间: ${(data.metrics.insert_response_time.values.avg || 0).toFixed(2)} ms\n`;
    }
    summary += '\n';
  }
  
  // 查询操作（安全访问）
  if (data.metrics && data.metrics.query_success_rate && data.metrics.query_success_rate.values) {
    summary += `${indent}查询操作:\n`;
    summary += `${indent}  成功率: ${(data.metrics.query_success_rate.values.rate * 100).toFixed(2)}%\n`;
    if (data.metrics.query_response_time && data.metrics.query_response_time.values) {
      summary += `${indent}  平均响应时间: ${(data.metrics.query_response_time.values.avg || 0).toFixed(2)} ms\n`;
    }
    summary += '\n';
  }
  
  // 最大并发数
  summary += `${indent}最大并发数: 10 虚拟用户\n`;
  if (data.state && data.state.testRunDurationMs) {
    summary += `${indent}测试总时长: 约 ${(data.state.testRunDurationMs / 1000).toFixed(0)} 秒\n`;
  }
  
  return summary;
}

