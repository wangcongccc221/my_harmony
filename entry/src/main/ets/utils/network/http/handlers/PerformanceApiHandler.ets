/**
 * 性能测试 API 处理器
 * 负责处理 /api/performance 相关的所有请求
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpResponseUtils } from '../../../helpers/HttpResponseUtils';
import { QueryStringUtils } from '../../../helpers/QueryStringUtils';
import { runPerformanceTest } from '../../../../database/examples/PerformanceTest';

const DOMAIN = 0x0000;

/**
 * 性能测试状态
 */
interface PerformanceTestStatus {
  isRunning: boolean;
  progress?: string;
  startTime?: number;
  endTime?: number;
  results?: CompleteTestResults;
}

/**
 * 测试结果摘要（导出）
 */
export interface TestSummary {
  testDataCount: number;
  narrowTableFields: number;
  wideTableFields: number;
  totalTests: number;
}

/**
 * 测试结论（导出）
 */
export interface TestConclusions {
  insertDiff: string;
  selectFewDiff: string;
  selectAllDiff: string;
  countDiff: string;
  updateDiff: string;
}

/**
 * 性能测试结果（导出）
 */
export interface PerformanceResult {
  testName: string;
  tableType: 'narrow' | 'wide';
  operation: string;
  count: number;
  totalTime: number;
  avgTime: number;
  qps: number;
  tps?: number;
}

/**
 * 完整测试结果（导出）
 */
export interface CompleteTestResults {
  summary: TestSummary;
  results: PerformanceResult[];
  conclusions: TestConclusions;
}

/**
 * 性能测试状态存储（单例）
 */
export class PerformanceTestState {
  private static instance: PerformanceTestState | null = null;
  private status: PerformanceTestStatus = { isRunning: false };
  private testResults: CompleteTestResults | null = null;

  private constructor() {}

  public static getInstance(): PerformanceTestState {
    if (!PerformanceTestState.instance) {
      PerformanceTestState.instance = new PerformanceTestState();
    }
    return PerformanceTestState.instance;
  }

  public setRunning(running: boolean): void {
    this.status.isRunning = running;
    if (running) {
      this.status.startTime = Date.now();
      this.status.endTime = undefined;
    } else {
      this.status.endTime = Date.now();
    }
  }

  public setProgress(progress: string): void {
    this.status.progress = progress;
  }

  public setResults(results: CompleteTestResults): void {
    this.testResults = results;
    this.status.results = results;
  }

  public getStatus(): PerformanceTestStatus {
    const status: PerformanceTestStatus = {
      isRunning: this.status.isRunning,
      progress: this.status.progress,
      startTime: this.status.startTime,
      endTime: this.status.endTime,
      results: this.status.results
    };
    return status;
  }

  public getResults(): CompleteTestResults | null {
    return this.testResults;
  }
}

/**
 * 性能测试 API 处理器
 */
export class PerformanceApiHandler {
  /**
   * 处理性能测试相关请求
   */
  static async handle(method: string, path: string, body?: string): Promise<string> {
    const pathAndQuery = QueryStringUtils.parsePathAndQuery(path);
    const cleanPath = pathAndQuery.path;
    const params = pathAndQuery.params;
    const upperMethod = method.toUpperCase();

    hilog.info(DOMAIN, 'PerformanceApiHandler', `处理请求: ${upperMethod} ${cleanPath}`);

    // POST /api/performance/start - 启动性能测试
    if (upperMethod === 'POST' && cleanPath === '/api/performance/start') {
      return PerformanceApiHandler.handleStart();
    }

    // GET /api/performance/status - 查询测试状态
    if (upperMethod === 'GET' && cleanPath === '/api/performance/status') {
      return PerformanceApiHandler.handleStatus();
    }

    // GET /api/performance/results - 获取测试结果
    if (upperMethod === 'GET' && cleanPath === '/api/performance/results') {
      return PerformanceApiHandler.handleResults();
    }

    // GET /api/performance - 获取测试信息
    if (upperMethod === 'GET' && cleanPath === '/api/performance') {
      return PerformanceApiHandler.handleInfo();
    }

    return HttpResponseUtils.buildErrorResponse('无效的API路径', 404);
  }

  /**
   * 启动性能测试
   */
  private static handleStart(): string {
    const state = PerformanceTestState.getInstance();
    const status = state.getStatus();

    if (status.isRunning) {
      return HttpResponseUtils.buildErrorResponse('性能测试正在运行中，请稍后再试', 400);
    }

    // 异步启动测试
    state.setRunning(true);
    state.setProgress('性能测试启动中...');

    runPerformanceTest()
      .then(() => {
        state.setProgress('性能测试完成');
        state.setRunning(false);
        hilog.info(DOMAIN, 'PerformanceApiHandler', '性能测试执行完成');
      })
      .catch((error: Error) => {
        state.setProgress(`性能测试失败: ${error.message}`);
        state.setRunning(false);
        hilog.error(DOMAIN, 'PerformanceApiHandler', `性能测试执行失败: ${JSON.stringify(error)}`);
      });

    interface StartResponse {
      message: string;
      status: string;
    }
    const response: StartResponse = {
      message: '性能测试已启动',
      status: 'running'
    };
    return HttpResponseUtils.buildSuccessResponse(response, '测试已开始执行，请通过 /api/performance/status 查询进度');
  }

  /**
   * 查询测试状态
   */
  private static handleStatus(): string {
    const state = PerformanceTestState.getInstance();
    const status = state.getStatus();

    interface StatusResponse {
      isRunning: boolean;
      progress: string;
      startTime?: number;
      endTime?: number;
      duration?: number;
    }
    const response: StatusResponse = {
      isRunning: status.isRunning,
      progress: status.progress || '未开始',
      startTime: status.startTime,
      endTime: status.endTime,
      duration: status.startTime && status.endTime ? status.endTime - status.startTime : undefined
    };
    return HttpResponseUtils.buildSuccessResponse(response);
  }

  /**
   * 获取测试结果
   */
  private static handleResults(): string {
    const state = PerformanceTestState.getInstance();
    const results = state.getResults();

    if (!results) {
      return HttpResponseUtils.buildErrorResponse('暂无测试结果，请先启动性能测试', 404);
    }

    return HttpResponseUtils.buildSuccessResponse(results);
  }

  /**
   * 获取测试信息
   */
  private static handleInfo(): string {
    interface Endpoints {
      'POST /api/performance/start': string;
      'GET /api/performance/status': string;
      'GET /api/performance/results': string;
      'GET /api/performance': string;
    }
    interface TestDescription {
      narrowTable: string;
      wideTable: string;
      testScenarios: string[];
    }
    interface InfoResponse {
      description: string;
      endpoints: Endpoints;
      testDescription: TestDescription;
    }
    const endpoints: Endpoints = {
      'POST /api/performance/start': '启动性能测试',
      'GET /api/performance/status': '查询测试状态',
      'GET /api/performance/results': '获取测试结果',
      'GET /api/performance': '获取API信息'
    };
    const testDescription: TestDescription = {
      narrowTable: '窄表（10个字段）',
      wideTable: '宽表（50个字段）',
      testScenarios: [
        '基准测试：插入性能对比（10000条数据）',
        '查询少量字段：SELECT field1, field2',
        'SELECT * 查询：全字段查询',
        '全表扫描：COUNT 操作',
        '更新操作：单字段更新',
        '并发测试：50个并发查询',
        '压力测试：1000次连续查询',
        '批量更新：100次批量更新',
        '复杂查询：多条件 + 排序'
      ]
    };
    const response: InfoResponse = {
      description: '性能测试 API',
      endpoints: endpoints,
      testDescription: testDescription
    };
    return HttpResponseUtils.buildSuccessResponse(response);
  }
}

