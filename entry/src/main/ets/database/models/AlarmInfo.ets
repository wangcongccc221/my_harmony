import { Table, Field, FieldType, Model } from '../orm';
import { GetIBestORM } from '../orm';

/**
 * 报警信息数据模型类
 * 用于存储系统报警记录
 * 对应数据库表：tb_alarm_info
 */
@Table({ name: 'tb_alarm_info' })
export class AlarmInfo extends Model {
  /**
   * 报警ID (主键)
   */
  @Field({ type: FieldType.INTEGER, tag: ['primaryKey', 'autoIncrement', 'notNull'] })
  AlarmID?: number;

  /**
   * 报警开始时间（格式：YYYY-MM-DD HH:mm:ss）
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  AlarmStartTime?: string;

  /**
   * 报警结束时间（格式：YYYY-MM-DD HH:mm:ss）
   */
  @Field({ type: FieldType.TEXT })
  AlarmEndTime?: string;

  /**
   * 报警类型
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  AlarmType?: string;

  /**
   * 报警等级
   */
  @Field({ type: FieldType.TEXT, tag: ['notNull'] })
  AlarmGrade?: string;

  /**
   * 报警消息
   */
  @Field({ type: FieldType.TEXT })
  AlarmMsg?: string;

  constructor(data?: Partial<AlarmInfo>) {
    super();
    
    // 从 data 复制属性
    if (data) {
      if (data.AlarmID !== undefined) this.AlarmID = data.AlarmID;
      if (data.AlarmStartTime !== undefined) this.AlarmStartTime = data.AlarmStartTime;
      if (data.AlarmEndTime !== undefined) this.AlarmEndTime = data.AlarmEndTime;
      if (data.AlarmType !== undefined) this.AlarmType = data.AlarmType;
      if (data.AlarmGrade !== undefined) this.AlarmGrade = data.AlarmGrade;
      if (data.AlarmMsg !== undefined) this.AlarmMsg = data.AlarmMsg;
    }
  }

  private static indexesCreated: boolean = false;

  /**
   * 创建索引以优化查询性能
   */
  static createIndexes(): void {
    if (AlarmInfo.indexesCreated) {
      return;
    }

    const orm = GetIBestORM();
    if (!orm) {
      console.warn('AlarmInfo.createIndexes: ORM 未初始化');
      return;
    }

    try {
      const core = orm.GetCore();
      if (core) {
        // 在报警类型上创建索引，便于按类型查询
        core.executeSql('CREATE INDEX IF NOT EXISTS idx_alarm_type ON tb_alarm_info(alarm_type);');
        // 在报警等级上创建索引，便于按等级查询
        core.executeSql('CREATE INDEX IF NOT EXISTS idx_alarm_grade ON tb_alarm_info(alarm_grade);');
        // 在开始时间上创建索引，便于按时间范围查询
        core.executeSql('CREATE INDEX IF NOT EXISTS idx_alarm_start_time ON tb_alarm_info(alarm_start_time);');
        console.log('AlarmInfo 索引创建成功');
      }
    } catch (error) {
      console.error('AlarmInfo 索引创建失败:', error);
    }

    AlarmInfo.indexesCreated = true;
  }
}

