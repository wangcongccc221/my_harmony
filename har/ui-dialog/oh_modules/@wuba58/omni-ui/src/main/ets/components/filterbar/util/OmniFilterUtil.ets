import { OmniFilterItemBean, OmniFilterType } from "../bean/OmniFilterItemBean";

export class OmniFilterUtil {
  static lengthToNumber(length: Length): number {
    if (typeof length === "number") {
      return length; // 已经是 number，直接返回
    } else if (typeof length === "string") {
      const parsed = parseFloat(length); // 尝试将字符串解析为数字
      if (isNaN(parsed)) {
        throw new Error(`Cannot convert string "${length}" to number`);
      }
      return parsed;
    } else {
      throw new Error("Unsupported type");
    }
  }

  /// 筛选项最多不超过三层,故直接写代码判断,本质为深度优先搜索。
  static getTotalLevel(entity: OmniFilterItemBean): number {
    let level = 0;
    let rootEntity = entity;
    while (rootEntity.parent != null) {
      rootEntity = rootEntity.parent!;
    }

    if (rootEntity.children && rootEntity.children.length > 0) {
      level = level > 1 ? level : 1;
      for (let firstLevelEntity of rootEntity.children) {
        if (firstLevelEntity.children && firstLevelEntity.children.length > 0) {
          level = level > 2 ? level : 2;
          for (let secondLevelEntity
            of firstLevelEntity.children) {
            if (secondLevelEntity.children && secondLevelEntity.children.length > 0) {
              level = 3;
              break;
            }
          }
        }
      }
    }
    return level;
  }

  /// 确定当前 Item 在第几层级
  static getCurrentListIndex(currentItem: OmniFilterItemBean): number {
    let listIndex = -1;
    if (currentItem != null) {
      listIndex = 0;
      let parent = currentItem.parent;
      while (parent != null) {
        listIndex++;
        parent = parent.parent;
      }
    }
    return listIndex;
  }

  /// 返回状态为选中的子节点
  static currentSelectListForEntity(entity: OmniFilterItemBean): OmniFilterItemBean[] {
    let list: OmniFilterItemBean[] = [];
    for (let item of entity.children) {
      if (item.isSelected) {
        list.push(item);
      }
    }
    return list;
  }

  static getTitle(entity: OmniFilterItemBean): string | undefined {
    let title: string | undefined = undefined;

    const firstColumn: OmniFilterItemBean[] = OmniFilterUtil.currentSelectListForEntity(entity);
    const secondColumn: OmniFilterItemBean[] = [];
    const thirdColumn: OmniFilterItemBean[] = [];

    if (firstColumn.length > 0) {
      for (const firstEntity of firstColumn) {
        secondColumn.push(...OmniFilterUtil.currentSelectListForEntity(firstEntity));
        if (secondColumn.length > 0) {
          for (const secondEntity of secondColumn) {
            thirdColumn.push(...OmniFilterUtil.currentSelectListForEntity(secondEntity));
          }
        }
      }
    }

    if (firstColumn.length === 0 || firstColumn.length > 1) {
      title = entity.title || undefined;
    } else {
      // 第一列选中了一个，为【不限】类型，使用上一级别的名字展示。
      if (firstColumn[0].isUnLimit()) {
        title = entity.title || undefined;
      } else {
        if (secondColumn.length === 0 || secondColumn.length > 1) {
          title = firstColumn[0].title || undefined;
        } else {
          // 第二列选中了一个，为【不限】类型，使用上一级别的名字展示。
          if (secondColumn[0].isUnLimit()) {
            title = firstColumn[0].title || undefined;
          } else {
            if (thirdColumn.length === 0 || thirdColumn.length > 1) {
              title = secondColumn[0].title || undefined;
            } else {
              // 第三列选中了一个，为【不限】类型，使用上一级别的名字展示。
              if (thirdColumn[0].isUnLimit()) {
                title = secondColumn[0].title || undefined;
              } else {
                title = thirdColumn[0].title || undefined;
              }
            }
          }
        }
      }
    }

    return title;
  }

  /**
   * 处理兄弟节点的选中状态，将当前节点置为选中状态
   */
  static processBrotherItemSelectStatus(filterItem: OmniFilterItemBean): void {
    let hasSelected = false
    if (filterItem.type === OmniFilterType.checkbox) {
      filterItem.isSelected = !filterItem.isSelected;
      if (filterItem.isSelected) {
        hasSelected = true
      }
      const allBrothers = filterItem.parent?.children;
      if (allBrothers && allBrothers.length > 0) {
        for (const entity of allBrothers) {
          if (entity !== filterItem) {
            if (entity.type === OmniFilterType.radio||entity.type === OmniFilterType.unLimit) {
              entity.isSelected = false;
            }
          }
        }
      }
    }

    if (filterItem.type === OmniFilterType.radio) {
      filterItem.parent?.clearChildSelectedStatus();
      filterItem.isSelected = true;
      hasSelected = true
    }

    if (filterItem.type === OmniFilterType.unLimit) {
      filterItem.parent?.clearChildSelectedStatus();
      filterItem.isSelected = true;
    }

    if (filterItem.parent){
      filterItem.parent.isSelected = hasSelected
    }
  }
}