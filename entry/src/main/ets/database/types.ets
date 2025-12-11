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
  ID?: number; // 模型基类返回的 ID 字段（大写）
  CustomerID?: number;
  CustomerName?: string;
  FarmName?: string;
  FruitName?: string;
  Status?: string;
  StartTime?: string;
  EndTime?: string;
  Weight?: number;
  Quantity?: number;
  BatchNo?: string;
  OrderID?: number;
  ProgramName?: string;
  ChannelNum?: number;
  ExportSum?: number;
  QualityGradeSum?: number;
  WeightOrSizeGradeSum?: number;
  CompletedState?: string;
  CreatedAt?: string; // 模型基类字段（大写）
  UpdatedAt?: string; // 模型基类字段（大写）
  created_at?: string; // 兼容小写
  updated_at?: string; // 兼容小写
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
  customerID: number;
  customerName: string;
  farmName: string;
  fruitName: string;
  status: string;
  startTime: string;
  endTime?: string;  // 可选，未完成的任务可以不传
  weight: number;
  quantity: number;
  batchNo?: string;
  orderID?: number;
  programName?: string;
  channelNum?: number;
  exportSum?: number;
  qualityGradeSum?: number;
  weightOrSizeGradeSum?: number;
  completedState?: string;
}

/**
 * 水果信息数据接口
 * 对应数据库表：tb_fruitinfo
 */
export interface FruitInfoData {
  id?: number;
  ID?: number;
  CustomerID?: number;
  SysID?: number;
  FeedPortID?: number;
  MajorCustomerID?: number;
  FBatchNo?: string;
  OrderID?: number;
  ChainIdx?: string;
  CustomerName?: string;
  FarmName?: string;
  FruitName?: string;
  StartTime?: string;
  EndTime?: string;
  StartedState?: string;
  CompletedState?: string;
  BatchWeight?: number;
  BatchNumber?: number;
  SortType?: number;
  SystemNum?: number;
  SizeIDNum?: number;
  ChannelNum?: number;
  QualityGradeSum?: number;
  WeightOrSizeGradeSum?: number;
  ColorGradeName?: string;
  ShapeGradeName?: string;
  FlawGradeName?: string;
  HardGradeName?: string;
  DensityGradeName?: string;
  SugarDegreeGradeName?: string;
  ExportSum?: number;
  ProgramName?: string;
  created_at?: string;
  updated_at?: string;
}

/**
 * 等级信息数据接口
 * 对应数据库表：tb_gradeinfo
 */
export interface GradeInfoData {
  id?: number;
  ID?: number;
  FID?: number;
  CustomerID?: number;
  ChannelID?: number;
  QualityIndex?: number;
  SizeID?: number;
  SizeIndex?: number;
  BoxNumber?: number;
  BoxWeight?: number;
  FruitNumber?: number;
  FruitWeight?: number;
  FPrice?: number;
  GradeID?: number;
  QualityName?: string;
  WeightOrSizeName?: string;
  WeightOrSizeLimit?: number;
  SelectWeightOrSize?: string;
  TraitWeightOrSize?: string;
  TraitColor?: string;
  TraitShape?: string;
  TraitFlaw?: string;
  TraitHard?: string;
  TraitDensity?: string;
  TraitSugarDegree?: string;
  created_at?: string;
  updated_at?: string;
}

/**
 * 导出信息数据接口
 * 对应数据库表：tb_exportinfo
 */
export interface ExportInfoData {
  id?: number;
  ID?: number;
  FID?: number;
  CustomerID?: number;
  ChannelID?: number;
  ExportID?: number;
  FruitNumber?: number;
  FruitWeight?: number;
  BoxNumber?: number;
  ExitName?: string;
  created_at?: string;
  updated_at?: string;
}

