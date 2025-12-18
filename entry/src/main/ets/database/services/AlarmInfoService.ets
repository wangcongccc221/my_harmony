import { AlarmInfo } from '../models/AlarmInfo';
import { GetIBestORM } from '../orm';
import { relationalStore } from '@kit.ArkData';

/**
 * 告警信息CRUD接口
 * 使用ORM同步方法，直接内部调用
 */
export class AlarmInfoService {
  /**
   * Create - 创建记录
   */
  static create(alarmInfo: AlarmInfo): AlarmInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const id = orm.Session(AlarmInfo).Insert(alarmInfo) as number;
    const result = orm.Session(AlarmInfo).Where('alarm_id', id).Find(AlarmInfo);
    if (result.length === 0) {
      throw new Error('创建后查询失败');
    }
    return result[0] as AlarmInfo;
  }

  /**
   * Read - 根据ID查询
   */
  static findById(id: number): AlarmInfo | null {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const results = orm.Session(AlarmInfo).Where('alarm_id', id).Find(AlarmInfo);
    return results.length > 0 ? (results[0] as AlarmInfo) : null;
  }

  /**
   * Read - 查询所有
   */
  static findAll(): AlarmInfo[] {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    return orm.Session(AlarmInfo).Find(AlarmInfo) as AlarmInfo[];
  }

  /**
   * Update - 更新记录
   */
  static update(id: number, alarmInfo: Partial<AlarmInfo>): AlarmInfo {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    const values: relationalStore.ValuesBucket = {};
    if (alarmInfo.AlarmStartTime !== undefined) values['alarm_start_time'] = alarmInfo.AlarmStartTime;
    if (alarmInfo.AlarmEndTime !== undefined) values['alarm_end_time'] = alarmInfo.AlarmEndTime;
    if (alarmInfo.AlarmType !== undefined) values['alarm_type'] = alarmInfo.AlarmType;
    if (alarmInfo.AlarmGrade !== undefined) values['alarm_grade'] = alarmInfo.AlarmGrade;
    if (alarmInfo.AlarmMsg !== undefined) values['alarm_msg'] = alarmInfo.AlarmMsg;

    orm.Session(AlarmInfo).Where('alarm_id', id).Update(values);
    const updated = AlarmInfoService.findById(id);
    if (!updated) {
      throw new Error('更新后查询失败');
    }
    return updated;
  }

  /**
   * Delete - 删除记录
   */
  static delete(id: number): void {
    const orm = GetIBestORM();
    if (!orm) {
      throw new Error('ORM 未初始化');
    }

    orm.Session(AlarmInfo).Where('alarm_id', id).Delete();
  }
}

