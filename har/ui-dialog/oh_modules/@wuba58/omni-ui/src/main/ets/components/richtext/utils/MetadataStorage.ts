import { ClassConstructor } from '.'
import { ExposeData } from './ExposeData'

export class MetadataStorage {

  private _typeMetadatas = new Map<Function, Map<string, ClassConstructor<any>>>()

  private _exposeDatas = new Map<Function, Map<string, ExposeData>>()
  
  addMetadata(protoType: Function, propertyName: string, cls: ClassConstructor<any>) {
    if (!this._typeMetadatas.has(protoType)) {
      this._typeMetadatas.set(protoType, new Map<string, ClassConstructor<any>>())
    }
    this._typeMetadatas.get(protoType).set(propertyName, cls)
  }

  findMetadata(protoType: Function, propertyName: string): ClassConstructor<any> {
    if (this._typeMetadatas.has(protoType)) {
      const meta = this._typeMetadatas.get(protoType)
      if (meta) {
        return meta.get(propertyName)
      }
    }
    return undefined
  }

  addExposeData(protoType: Function, propertyName: string, expose: ExposeData) {
    if (!this._exposeDatas.has(protoType)) {
      this._exposeDatas.set(protoType, new Map<string, ExposeData>())
    }
    this._exposeDatas.get(protoType).set(propertyName, expose)
  }

  findExposeData(protoType: Function, propertyName: string): ExposeData {
    if (this._exposeDatas.has(protoType)) {
      const expose = this._exposeDatas.get(protoType)
      if (expose) {
        return expose.get(propertyName)
      }
    }
    return undefined
  }

}