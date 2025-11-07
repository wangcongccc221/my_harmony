import { OmniFilterItemBean, OmniFilterType } from "../bean/OmniFilterItemBean"
import { OmniFilterUtil } from "../util/OmniFilterUtil"
import { OmniFilterListItem } from "./OmniFilterListItem"

@Component
@Preview
export struct OmniFilterSingleList {
  @Link items: OmniFilterItemBean[]
  listBackgroundColor: number = 1
  selectedBackgroundColor: number = 1
  @Link focusedIndex: number
  singleListItemSelect?: (listIndex: number, index: number, entity: OmniFilterItemBean) => void
  /// 当前选择的项
  private currentListIndex: number = -1;

  aboutToAppear(): void {
    if (this.items.length > 0) {
      this.currentListIndex = OmniFilterUtil.getCurrentListIndex(this.items[0])
    }
  }

  build() {
    List() {
      ForEach(this.items, (item: OmniFilterItemBean, index: number) => {
        ListItem() {
          Column() {
            OmniFilterListItem({
              item: item,
              listBackgroundColor: this.listBackgroundColor,
              selectedBackgroundColor: this.selectedBackgroundColor,
              focusedIndex: this.focusedIndex,
              listIndex: index,
              isFirstLevel: this.currentListIndex == 1,
              singleListItemSelect: () => {
                this.processFilterData(item)
                this.singleListItemSelect?.(this.currentListIndex, index, item)
              }
            })
          }
        }
        .width("100%")
      }, (item: OmniFilterItemBean, index: number) => item.generateListKey() + index)
    }
    .width('100%')
    .backgroundColor(this.listBackgroundColor)
  }

  // 处理点击后的数据
  private processFilterData(selectedEntity: OmniFilterItemBean): void {
    const totalLevel = OmniFilterUtil.getTotalLevel(selectedEntity);

    // 如果是 "不限"，清空子节点选中状态
    if (selectedEntity.type === OmniFilterType.unLimit) {
      selectedEntity.parent?.clearChildSelectedStatus();
    }

    // 设置选中状态
    if (totalLevel === 1) {
      this.configOneLevelList(selectedEntity);
    } else {
      this.configMultiLevelList(selectedEntity);
    }

    // 第一列的节点是否被选中，取决于子节点是否被选中
    if (this.items.length > 0) {
      const parent = this.items[0].parent;
      if (parent?.children) {
        parent.isSelected =
          parent.children.filter(child => child.isSelected).length > 0;
      }
    }
  }

  // 配置单级节点的选中状态
  configOneLevelList(selectedEntity: OmniFilterItemBean): void {
    if (selectedEntity.type === OmniFilterType.radio) {
      // 单选，清空同级节点的选中状态
      selectedEntity.parent?.clearChildSelectedStatus();
      selectedEntity.isSelected = true;
    } else if (selectedEntity.type === OmniFilterType.checkbox) {
      if (selectedEntity.isUnLimit()) {
        // 选中【不限】，清空同级节点状态
        selectedEntity.parent?.clearChildSelectedStatus();
        selectedEntity.isSelected = true;
      } else {
        // 清除【不限】类型的节点
        const brotherItems = selectedEntity.parent
          ? selectedEntity.parent.children
          : this.items;

        brotherItems.forEach(entity => {
          if (entity.isUnLimit()) {
            entity.isSelected = false;
          }
        });

        // 切换选中状态
        selectedEntity.isSelected = !selectedEntity.isSelected;
      }
    }
  }

  // 配置多级节点的选中状态
  configMultiLevelList(selectedEntity: OmniFilterItemBean): void {
    if (selectedEntity.isUnLimit()) {
      // 选中【不限】，清空同级节点状态
      selectedEntity.parent?.children
        .filter(f => f !== selectedEntity)
        .forEach(f => {
          f.clearChildSelectedStatus();
          f.isSelected = false;
        });
      selectedEntity.isSelected = true;
    } else if (selectedEntity.type === OmniFilterType.radio) {
      // 单选，清空同级节点的选中状态
      selectedEntity.parent?.children
        .filter(f => f !== selectedEntity)
        .forEach(f => {
          f.clearChildSelectedStatus();
          f.isSelected = false;
        });
      selectedEntity.isSelected = true;
    } else if (selectedEntity.type === OmniFilterType.checkbox) {
      // 清除【不限】类型的节点
      const brotherItems = selectedEntity.parent
        ? selectedEntity.parent.children
        : this.items;

      brotherItems.forEach(entity => {
        if (entity.isUnLimit()) {
          entity.clearChildSelectedStatus();
          entity.isSelected = false;
        }
      });

      // 切换选中状态
      selectedEntity.isSelected = !selectedEntity.isSelected;
    }
  }
}