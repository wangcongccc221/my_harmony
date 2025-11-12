/**
 * 数据库数据接口类型定义
 * 用于查询结果的数据结构
 */

/**
 * 用户数据接口
 */
export interface UserData {
  id?: number;
  Name?: string;
  Age?: number;
  created_at?: string;
  updated_at?: string;
}

/**
 * 测试数据接口
 */
export interface TestData {
  id?: number;
  Title?: string;
  Description?: string;
  Count?: number;
  IsEnabled?: number;
  created_at?: string;
  updated_at?: string;
}

export interface ProcessingHistoryData {
  id?: number;
  CustomerName?: string;
  FarmName?: string;
  FruitName?: string;
  Status?: string;
  StartTime?: string;
  EndTime?: string;
  Weight?: number;
  Quantity?: number;
  created_at?: string;
  updated_at?: string;
}

/**
 * 创建用户的参数接口
 */
export interface CreateUserParams {
  name: string;
  age: number;
}

/**
 * 创建测试记录的参数接口
 */
export interface CreateTestRecordParams {
  title: string;
  description?: string;
  count?: number;
  isEnabled?: number;
}

/**
 * 创建历史加工记录的参数接口
 */
export interface CreateProcessingHistoryParams {
  customerName: string;
  farmName: string;
  fruitName: string;
  status: string;
  startTime: string;
  endTime?: string;  // 可选，未完成的任务可以不传
  weight: number;
  quantity: number;
}

