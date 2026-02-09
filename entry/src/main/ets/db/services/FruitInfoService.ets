import { getORM } from '@ibestservices/ibest-orm'
import { TbFruitinfo } from '../entities/TbFruitinfo'

export interface FruitInfoFilters {
  startTimeFrom?: string
  startTimeTo?: string
  customerNameLike?: string
  farmNameLike?: string
  fruitNameLike?: string
  onlyVisible?: boolean
}

export class FruitInfoService {
  private static normalizeLike(v: string): string {
    const t = v.trim()
    return t.includes('%') ? t : `%${t}%`
  }

  static async upsertByBatchNo(batchNo: string, data: Partial<TbFruitinfo>): Promise<number | undefined> {
    const orm = getORM()
    const existingRaw = orm.query(TbFruitinfo)
      .where({ FBatchNo: batchNo })
      .first() as TbFruitinfo | null
    const existing = await Promise.resolve(existingRaw)

    if (existing && existing.CustomerID) {
      await Promise.resolve(
        orm.query(TbFruitinfo)
          .where({ CustomerID: existing.CustomerID })
          .update(data)
      )
      return existing.CustomerID
    }

    const row = new TbFruitinfo()
    row.FBatchNo = batchNo
    if (data.SysID !== undefined) row.SysID = data.SysID
    if (data.MajorCustomerID !== undefined) row.MajorCustomerID = data.MajorCustomerID
    if (data.ChainIdx !== undefined) row.ChainIdx = data.ChainIdx
    if (data.CustomerName !== undefined) row.CustomerName = data.CustomerName
    if (data.FarmName !== undefined) row.FarmName = data.FarmName
    if (data.FruitName !== undefined) row.FruitName = data.FruitName
    if (data.SortBaseName !== undefined) row.SortBaseName = data.SortBaseName
    if (data.StartTime !== undefined) row.StartTime = data.StartTime
    if (data.EndTime !== undefined) row.EndTime = data.EndTime
    if (data.StartedState !== undefined) row.StartedState = data.StartedState
    if (data.CompletedState !== undefined) row.CompletedState = data.CompletedState
    if (data.BatchWeight !== undefined) row.BatchWeight = data.BatchWeight
    if (data.BatchNumber !== undefined) row.BatchNumber = data.BatchNumber
    if (data.QualityGradeSum !== undefined) row.QualityGradeSum = data.QualityGradeSum
    if (data.WeightOrSizeGradeSum !== undefined) row.WeightOrSizeGradeSum = data.WeightOrSizeGradeSum
    if (data.ExportSum !== undefined) row.ExportSum = data.ExportSum
    if (data.ColorGradeName !== undefined) row.ColorGradeName = data.ColorGradeName
    if (data.ShapeGradeName !== undefined) row.ShapeGradeName = data.ShapeGradeName
    if (data.FlawGradeName !== undefined) row.FlawGradeName = data.FlawGradeName
    if (data.HardGradeName !== undefined) row.HardGradeName = data.HardGradeName
    if (data.DensityGradeName !== undefined) row.DensityGradeName = data.DensityGradeName
    if (data.SugarDegreeGradeName !== undefined) row.SugarDegreeGradeName = data.SugarDegreeGradeName
    if (data.ProgramName !== undefined) row.ProgramName = data.ProgramName
    if (data.FVisible !== undefined) row.FVisible = data.FVisible
    if (data.PageSize !== undefined) row.PageSize = data.PageSize
    if (data.PageIndex !== undefined) row.PageIndex = data.PageIndex
    if (data.IsMerge !== undefined) row.IsMerge = data.IsMerge
    if (data.SortColumn !== undefined) row.SortColumn = data.SortColumn
    if (data.SortOrder !== undefined) row.SortOrder = data.SortOrder
    const id = await Promise.resolve(orm.insert(row) as number)
    return id
  }

  static async updateById(id: number, data: Partial<TbFruitinfo>): Promise<void> {
    const orm = getORM()
    await Promise.resolve(
      orm.query(TbFruitinfo)
        .where({ CustomerID: id })
        .update(data)
    )
  }

  static async softDeleteByIds(ids: number[]): Promise<void> {
    const orm = getORM()
    await Promise.resolve(
      orm.transaction(async () => {
        for (const id of ids) {
          await Promise.resolve(
            orm.query(TbFruitinfo)
              .where({ CustomerID: id })
              .update({ FVisible: 0 })
          )
        }
      })
    )
  }

  static async queryByFilters(filters: FruitInfoFilters): Promise<TbFruitinfo[]> {
    const orm = getORM()
    let qb = orm.query(TbFruitinfo)

    if (filters.customerNameLike && filters.customerNameLike.trim() !== '') {
      qb = qb.where({ CustomerName: { like: FruitInfoService.normalizeLike(filters.customerNameLike) } })
    }
    if (filters.farmNameLike && filters.farmNameLike.trim() !== '') {
      qb = qb.where({ FarmName: { like: FruitInfoService.normalizeLike(filters.farmNameLike) } })
    }
    if (filters.fruitNameLike && filters.fruitNameLike.trim() !== '') {
      qb = qb.where({ FruitName: { like: FruitInfoService.normalizeLike(filters.fruitNameLike) } })
    }
    if (filters.startTimeFrom || filters.startTimeTo) {
      const from = (filters.startTimeFrom && filters.startTimeFrom.trim() !== '') ? filters.startTimeFrom.trim() : '1970-01-01 00:00:00'
      const to = (filters.startTimeTo && filters.startTimeTo.trim() !== '') ? filters.startTimeTo.trim() : '9999-12-31 23:59:59'
      qb = qb.whereBetween('StartTime', from, to)
    }

    const listRaw = qb.orderBy('CustomerID', 'desc').find() as TbFruitinfo[]
    const list = await Promise.resolve(listRaw)
    if (filters.onlyVisible) {
      return list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
    }
    return list
  }

  static async queryPage(page: number, size: number, onlyVisible: boolean = true): Promise<TbFruitinfo[]> {
    const orm = getORM()
    const p = Math.max(1, page)
    const s = Math.max(1, Math.min(200, size))
    const offset = (p - 1) * s

    const listRaw = orm.query(TbFruitinfo)
      .orderBy('CustomerID', 'desc')
      .limit(s)
      .offset(offset)
      .find() as TbFruitinfo[]
    const list = await Promise.resolve(listRaw)
    if (!onlyVisible) return list
    return list.filter(item => item.FVisible === undefined || item.FVisible === null || item.FVisible !== 0)
  }
}

