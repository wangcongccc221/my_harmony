import ArrayList from "@ohos.util.ArrayList"
import { JSON } from "@kit.ArkTS"
import { TextUtils } from "../../../utils/TextUtils"
import { OmniFilterUtil } from "../util/OmniFilterUtil";

export enum OmniFilterType {
  none,
  radio,
  checkbox,
  unLimit
}

export class OmniFilterShowType {
  static readonly dropList = "dropList";
  static readonly dropGrid = "dropGrid";
  static readonly more = "more";

  // 获取所有常量值的数组
  static values(): string[] {
    return [OmniFilterShowType.dropList, OmniFilterShowType.dropGrid, OmniFilterShowType.more];
  }
}

@Observed
export class OmniFilterDataRoot {
  items: OmniFilterItemBean[]

  constructor(items: OmniFilterItemBean[]) {
    this.items = items;
  }
}

@Observed
export class OmniFilterItemBean {
  type: OmniFilterType = OmniFilterType.none
  showType: string = OmniFilterShowType.dropList
  title: string
  key?: string
  value?: string
  defaultValue?: string
  children: OmniFilterItemBean[]
  parent?: OmniFilterItemBean
  ///自定义数据
  customMap?: Map<string, string | object>
  ///状态属性
  isSelected: boolean = false

  constructor(type: OmniFilterType, title: string, key: string, value: string, defaultValue: string,
    children: OmniFilterItemBean[]) {
    this.type = type
    this.title = title
    this.key = key
    this.value = value
    this.defaultValue = defaultValue
    this.children = children
  }

  static convertJsonToObj(json: string | object[],
    parent: OmniFilterItemBean | undefined = undefined): OmniFilterItemBean[] | undefined {
    if (!json) {
      return undefined
    }
    let filterJson: object
    if (typeof json === 'string') {
      let r = JSON.parse(json)
      if (r) {
        filterJson = r
      } else {
        //TODO 解析失败抛异常
        throw new Error(`解析异常`)
      }
    } else {
      filterJson = json
    }
    let result: ArrayList<OmniFilterItemBean> = new ArrayList()
    if (Array.isArray(filterJson)) {
      let filterJsonArray: object[] = filterJson
      for (const itemJson of filterJsonArray) {
        let children: OmniFilterItemBean[] = OmniFilterItemBean.convertJsonToObj(itemJson['children']) ?? []
        let itemObj = new OmniFilterItemBean(
          OmniFilterItemBean.convertFilterType(itemJson['type']),
          itemJson['title'],
          itemJson['key'],
          itemJson['value'],
          itemJson['defaultValue'],
          children
        );
        if (itemJson['showType']) {
          itemObj.showType = itemJson['showType']
        }
        if (itemJson['customMap']) {
          itemObj.customMap = itemJson['customMap']
        }
        if (parent) {
          itemObj.parent = parent
        }
        result.add(itemObj)
      }
    }
    result.forEach((item) => {
      item.configRelationshipAndDefaultValue()
    })
    return result.convertToArray();
  }

  static convertFilterType(type: string | undefined): OmniFilterType {
    if (type) {
      switch (type.toLowerCase()) { // 转换为小写以支持大小写不敏感的匹配
        case "radio":
          return OmniFilterType.radio;
        case "checkbox":
          return OmniFilterType.checkbox;
        case "unlimit":
          return OmniFilterType.unLimit;
        default:
          return OmniFilterType.none;
      }
    } else {
      return OmniFilterType.none;
    }
  }

  configRelationshipAndDefaultValue() {
    this.configRelationship();
    this.configDefaultValue();
  }

  private configRelationship() {
    if (this.children.length > 0) {
      for (let entity of this.children) {
        entity.parent = this;
      }
      for (let entity of this.children) {
        entity.configRelationship();
      }
    }
  }

  private configDefaultValue() {
    if (this.children.length > 0) {
      for (let entity of this.children) {
        if (!TextUtils.isBlank(this.defaultValue)) {
          let values = this.defaultValue!.split(',');
          if (entity.value) {
            entity.isSelected = values.includes(entity.value);
          }
        }
      }

      for (const entity of this.children) {
        entity.configDefaultValue();
      }

      if (this.hasCheckBoxBrother()) {
        this.isSelected = this.children.some((_) => _.isSelected);
      } else {
        this.isSelected = this.isSelected || this.children.some((_) => _.isSelected);
      }
    }
  }

  /**
   * 是否不限
   * @returns true 是 false 不是
   */
  isUnLimit(): boolean {
    return this.type == OmniFilterType.unLimit;
  }

  // 检查自己的兄弟节点是否存在 checkbox 类型。
  hasCheckBoxBrother(): boolean {
    const count = this.parent?.children?.filter(
      (f) => f.type === OmniFilterType.checkbox
    ).length;
    return count !== undefined && count > 0;
  }

  /// 是否在筛选数据的最后一层。 如果最大层次为 3；某个筛选数据层次为 2，但其无子节点。此时认为不在最后一层。
  isInLastLevel(): boolean {
    if (this.parent == null || this.parent!.children.length == 0) {
      return true;
    }
    for (let entity of this.parent!.children) {
      if (entity.children.length > 0) {
        return false;
      }
    }
    return true;
  }

  generateListKey(): string {
    let listKey: string = `${this.parentKey()}--${this.key}--${this.value}--${this.isSelected}`
    if (!this.isInLastLevel()) {
      listKey += this.selectedList()
        .filter(item => item.isSelected)// 筛选出选中的项
        .map(item => item.value)// 提取选中项的 value
        .join("-");
    }
    return listKey
  }

  private parentKey(): string {
    let key: string | undefined = ""
    if (this.parent) {
      key = `${this.parent.parentKey()}--${this.key}`
    } else {
      key = this.key
    }
    return key ?? ``;
  }

  // 清空子节点的选中状态
  clearChildSelectedStatus(): void {
    if (this.children.length > 0) {
      for (const child of this.children) {
        child.isSelected = false;
        child.clearChildSelectedStatus(); // 递归清空子节点
      }
    }
  }

  /// 获取当前节点的所有选中的子节点，支持 more 类型
  selectedList(): OmniFilterItemBean[] {
    //TODO 更多类型（更多类型可不同子项间多选，这里需要特殊处理）
    let results: OmniFilterItemBean[] = [];
    let firstColumn =
      OmniFilterUtil.currentSelectListForEntity(this);
    results = results.concat(firstColumn);
    if (firstColumn.length > 0) {
      for (let firstEntity of firstColumn) {
        let secondColumn =
          OmniFilterUtil.currentSelectListForEntity(firstEntity);
        results = results.concat(secondColumn);
        if (secondColumn.length > 0) {
          for (let secondEntity of secondColumn) {
            let thirdColumn =
              OmniFilterUtil.currentSelectListForEntity(secondEntity);
            results = results.concat(thirdColumn);
          }
        }
      }
    }
    return results;
  }

  selectedListWithoutUnlimit(): OmniFilterItemBean[] {
    const selected = this.selectedList();
    return selected.filter(entity =>!entity.isUnLimit());
  }
}