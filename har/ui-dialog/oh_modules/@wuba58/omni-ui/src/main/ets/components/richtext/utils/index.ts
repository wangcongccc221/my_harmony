import { MetadataStorage } from './MetadataStorage';

export type ObjectLike = Record<PropertyKey, any>
export const defaultMetadataStorage = new MetadataStorage();
export declare type ClassConstructor<T> = {
  new (...args: any[]): T;
};