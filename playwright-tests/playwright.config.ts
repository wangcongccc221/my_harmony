import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright 测试配置
 * 用于测试 HarmonyOS HTTP 服务器的稳定性
 */
export default defineConfig({
  testDir: './tests',
  /* 测试超时时间（增加到1小时，因为长时间稳定性测试需要约1小时） */
  timeout: 3600 * 1000,
  expect: {
    /* 断言超时时间 */
    timeout: 5000
  },
  /* 并行运行测试 */
  fullyParallel: true,
  /* 失败时重试 */
  retries: process.env.CI ? 2 : 0,
  /* 并发工作线程数 */
  workers: process.env.CI ? 1 : undefined,
  /* 测试报告配置 */
  reporter: 'html',
  /* 共享设置 */
  use: {
    /* 基础URL - 根据实际情况修改 */
    baseURL: 'http://127.0.0.1:9999',
    /* 浏览器操作超时 */
    actionTimeout: 10000,
    /* 导航超时 */
    navigationTimeout: 30000,
    /* 截图配置 */
    screenshot: 'only-on-failure',
    /* 视频录制配置 */
    video: 'retain-on-failure',
    /* 追踪配置 */
    trace: 'on-first-retry',
  },

  /* 配置不同的浏览器 */
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  /* 本地开发服务器配置（如果需要） */
  // webServer: {
  //   command: 'npm run start',
  //   url: 'http://127.0.0.1:8868',
  //   reuseExistingServer: !process.env.CI,
  // },
});

