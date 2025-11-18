import GlobalStore from './model/GlobalStore';
const init = GlobalStore.init
const GetIBestORM = () => {
  return GlobalStore.orm
}
export { init as IBestORMInit, GetIBestORM }
export { Table } from './decorator/Table';
export { Field } from './decorator/Field';
export * from './model/Global.type';
export * from './model/Mode';
export { GetTableName } from './decorator/Index'
export type { Class } from './decorator/Index'
export { HasOne, HasMany, BelongsTo, ManyToMany, RelationType, CascadeType } from './decorator/Relation';
export { IBestORM } from './core/SQLiteORM';