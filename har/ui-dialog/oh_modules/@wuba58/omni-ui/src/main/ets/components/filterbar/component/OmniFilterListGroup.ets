import { OmniFilterItemBean, OmniFilterType } from "../bean/OmniFilterItemBean"
import { OmniFilterConstants } from "../OmniFilterConstants"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"
import { OmniFilterUtil } from "../util/OmniFilterUtil"
import { OmniFilterBottomPanel } from "./OmniFilterBottomPanel"
import { OmniFilterSingleList } from "./OmniFilterSingleList"

@Component
@Preview
export struct OmniFilterListGroup {
  private static DEFAULT_MAX_HEIGHT = 300///默认最大高度，可从filterStyle中自定义
  @Consume filterStyle: OmniFilterStyle
  @ObjectLink item: OmniFilterItemBean
  onConfirmAction?: () => void
  @State private _firstList: OmniFilterItemBean[] = []
  @State private _secondList: OmniFilterItemBean[] = []
  @State private _thirdList: OmniFilterItemBean[] = []
  @State private _originalSelectedItemsList: OmniFilterItemBean[] = []
  @State private _firstIndex: number = -1;
  @State private _secondIndex: number = -1;
  @State private _thirdIndex: number = -1;
  @State listGroupHeight: Length = 0
  private totalLevel = 0;
  ///是否确认过（没确认过则重置数据）
  private _isConfirmClick = false;

  aboutToAppear(): void {
    // 生成筛选节点树
    this._originalSelectedItemsList = this.item.selectedList();
    // 初始化每列的选中 index 为 -1，未选中。
    this._configDefaultInitSelectIndex();
    // 遍历数据源，设置真正选中的index
    this._configDefaultSelectedData();
    // 使用真正选中的index来刷新数组
    this._refreshDataSource();

    this.totalLevel = OmniFilterUtil.getTotalLevel(this.item);
  }

  // 设置默认无选中项的时候默认选择index
  private _configDefaultInitSelectIndex() {
    this._firstIndex = this._secondIndex = this._thirdIndex = -1;
  }

  private _configDefaultSelectedData() {
    if (this.item && this.item.children) {
      this._firstList = this.item.children
    }
    if (this._firstList.length == 0) {
      this._secondIndex = -1;
      this._secondList = [];

      this._thirdIndex = -1;
      this._thirdList = [];

      return;
    }
    this._firstIndex = this._getInitialSelectIndex(this._firstList);

    if (this._firstIndex >= 0 && this._firstIndex < this._firstList.length) {
      this._secondList = this._firstList[this._firstIndex].children ?? [];
      this._secondIndex = this._getInitialSelectIndex(this._secondList);
    }

    if (this._secondList.length == 0) {
      this._thirdIndex = -1;
      this._thirdList = [];
      return;
    }
    if (this._secondIndex >= 0 && this._secondIndex < this._secondList.length) {
      this._thirdList = this._secondList[this._secondIndex].children ?? [];
      if (this._thirdList.length > 0) {
        this._thirdIndex = this._getInitialSelectIndex(this._thirdList);
      }
    }
  }

  private _getInitialSelectIndex(levelList: OmniFilterItemBean[] | undefined): number {
    let index = -1;
    if (!levelList || levelList.length == 0) {
      return index;
    }
    for (let entity of levelList) {
      if (entity.isSelected) {
        index = levelList.indexOf(entity);
        break;
      }
    }
    /// 非跨区域选择时，走此方法设置默认选择 index
    if (index < 0) {
      for (let entity of levelList) {
        if (entity.isUnLimit() &&
          OmniFilterUtil.getTotalLevel(entity) > 1 &&
          !(entity.parent?.hasCheckBoxBrother() ?? false)) {
          index = levelList.indexOf(entity);
          break;
        }
      }
    }
    return index;
  }

  // 刷新3个ListView的数据源
  _refreshDataSource() {
    if (this.item && this.item.children) {
      this._firstList = this.item.children
    }
    if (this._firstIndex >= 0 && this._firstList.length > this._firstIndex) {
      this._secondList = this._firstList[this._firstIndex].children ?? [];
      if (this._secondIndex >= 0 && this._secondList.length > this._secondIndex) {
        this._thirdList = this._secondList[this._secondIndex].children ?? [];
      } else {
        this._thirdList = [];
      }
    } else {
      this._secondList = [];
      this._thirdList = [];
    }
  }

  _setFirstIndex(firstIndex: number) {
    this._firstIndex = firstIndex;
    this._secondIndex = -1;
    if (this.item && this.item.children && this.item.children.length > this._firstIndex) {
      let seconds =
        this.item.children[this._firstIndex].children;
      this._secondIndex = this._getInitialSelectIndex(seconds);
      if (this._secondIndex >= 0) {
        this._setSecondIndex(this._secondIndex);
      }
    }
    this._refreshDataSource();
  }

  _setSecondIndex(secondIndex: number) {
    this._secondIndex = secondIndex;
    this._thirdIndex = -1;
    let seconds = this.item.children[this._firstIndex].children;
    if (seconds.length > this._secondIndex) {
      let thirds = seconds[this._secondIndex].children;
      if (thirds && thirds.length > 0) {
        this._thirdIndex = this._getInitialSelectIndex(thirds);
      }
    }
    this._refreshDataSource();
  }

  aboutToDisappear(): void {
    if (!this._isConfirmClick) {
      this._resetSelectedStatus(this.item);
      this._restoreOriginalData();
    }
  }

  ///还原数据选中状态
  private _resetSelectedStatus(entity: OmniFilterItemBean) {
    entity.isSelected = false;
    for (let subEntity of entity.children) {
      this._resetSelectedStatus(subEntity);
    }
  }

  ///数据还原
  private _restoreOriginalData() {
    for (let commonEntity of this._originalSelectedItemsList) {
      commonEntity.isSelected = true;
    }
  }

  private _clearAllSelectedItems() {
    this._resetSelectedStatus(this.item);
    this._configDefaultInitSelectIndex();
    this._refreshDataSource();
  }

  private _confirmButtonClickEvent() {
    this._isConfirmClick = true
    /// 确认回调前 根据规则，统一处理筛选数据选择状态
    this._processFilterDataOnConfirm()
    this.onConfirmAction?.()
  }

  // 提交前对筛选数据做进一步处理
  private _processFilterDataOnConfirm(): void {
    this._processSelectedStatus(this.item);
  }

  // 递归处理筛选项的选中状态
  private _processSelectedStatus(entity: OmniFilterItemBean): void {
    if (entity.children.length > 0) {
      entity.children.forEach(child => this._processSelectedStatus(child));

      if (entity.hasCheckBoxBrother()) {
        entity.isSelected = entity.children.some(child => child.isSelected);
      }
    }
  }

  build() {
    Column() {
      Stack() {
        ///用于背景填充
        Row() {
          Column()
            .width(this._getFlexByListIndex(1))
            .backgroundColor(this._getBgByListIndex(1))
            .height(this.listGroupHeight)
          Column()
            .width(this._getFlexByListIndex(2))
            .backgroundColor(this._getBgByListIndex(2))
            .height(this.listGroupHeight)
          Column()
            .width(this._getFlexByListIndex(3))
            .backgroundColor(this._getBgByListIndex(3))
            .height(this.listGroupHeight)
        }
        .width('100%')

        ///三列
        Row() {
          OmniFilterSingleList({
            items: this._firstList,
            listBackgroundColor: this._getBgByListIndex(1),
            selectedBackgroundColor: this._getSelectBgByListIndex(1),
            focusedIndex: this._firstIndex,
            singleListItemSelect: (listIndex, index, item) => {
              this._setFirstIndex(index)
              if (this.totalLevel == 1 &&
                this.item.type == OmniFilterType.radio) {
                this._confirmButtonClickEvent();
              }
            }
          })
            .width(this._getFlexByListIndex(1))

          OmniFilterSingleList({
            items: this._secondList,
            listBackgroundColor: this._getBgByListIndex(2),
            selectedBackgroundColor: this._getSelectBgByListIndex(2),
            focusedIndex: this._secondIndex,
            singleListItemSelect: (listIndex, index, item) => {
              this._setSecondIndex(index)
            }
          })
            .width(this._getFlexByListIndex(2))

          OmniFilterSingleList({
            items: this._thirdList,
            listBackgroundColor: this._getBgByListIndex(3),
            selectedBackgroundColor: this._getSelectBgByListIndex(3),
            focusedIndex: this._thirdIndex,
            singleListItemSelect: (listIndex, index, item) => {
              if (item.isSelected) {
                this._thirdIndex = index;
              } else {
                this._thirdIndex = -1;
              }
              this._refreshDataSource()
            }
          })
            .width(this._getFlexByListIndex(3))
        }
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.listGroupHeight = newValue.height
        })
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .constraintSize({
          maxHeight: this.filterStyle?.listStyle?.maxHeight ?? OmniFilterListGroup.DEFAULT_MAX_HEIGHT
        })
      }
      .alignContent(Alignment.Top)

      this._buildBottom()
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  _buildBottom() {
    if (this.totalLevel == 1 && this.item.type == OmniFilterType.radio) {
      //一级单选不显示，选择即确定
    } else {
      OmniFilterBottomPanel({
        onResetClick: () => {
          this._clearAllSelectedItems()
        },
        onConfirmClick: () => {
          this._confirmButtonClickEvent()
        }
      })
    }
  }

  /// 默认占比为 1，
  /// 其中一列、两列情况下，占比都是 1
  /// 当为三列数据时，占比随着 listIndex 增加而增大。为 3：3：4 比例水平占据屏幕
  _getFlexByListIndex(listIndex: number): string {
    let flex = "100%";
    if (this.totalLevel == 1) {
      flex = "100%";
    } else if (this.totalLevel == 2) {
      flex = "50%";
    } else if (this.totalLevel == 3) {
      if (listIndex == 1) {
        flex = "30%";
      } else if (listIndex == 2) {
        if (this._thirdList.length == 0) {
          flex = "70%";
        } else {
          flex = "30%";
        }
      } else if (listIndex == 3) {
        flex = "40%";
      }
    }
    return flex;
  }

  private _getSelectBgByListIndex(listIndex: number): number {
    let deepSelectBgColor = OmniFilterConstants.OMNI_FILTER_LIST_DEEP_SELECT_BG
    let middleSelectBgColor = OmniFilterConstants.OMNI_FILTER_LIST_MIDDLE_SELECT_BG
    let lightSelectBgColor = OmniFilterConstants.OMNI_FILTER_LIST_LIGHT_SELECT_BG
    if (this.totalLevel == 1) {
      return lightSelectBgColor;
    } else if (this.totalLevel == 2) {
      if (listIndex == 1) {
        return middleSelectBgColor;
      } else {
        return lightSelectBgColor;
      }
    } else {
      if (listIndex == 1) {
        return deepSelectBgColor;
      } else if (listIndex == 2) {
        return middleSelectBgColor;
      } else if (listIndex == 3) {
        return lightSelectBgColor;
      }
    }
    return lightSelectBgColor;
  }

  private _getBgByListIndex(listIndex: number): number {
    let deepNormalBgColor = OmniFilterConstants.OMNI_FILTER_LIST_DEEP_NORMAL_BG
    let middleNormalBgColor = OmniFilterConstants.OMNI_FILTER_LIST_MIDDLE_NORMAL_BG
    let lightNormalBgColor = OmniFilterConstants.OMNI_FILTER_LIST_LIGHT_NORMAL_BG
    if (this.totalLevel == 1) {
      return lightNormalBgColor;
    } else if (this.totalLevel == 2) {
      if (listIndex == 1) {
        return middleNormalBgColor;
      } else {
        return lightNormalBgColor;
      }
    } else {
      if (listIndex == 1) {
        return deepNormalBgColor;
      } else if (listIndex == 2) {
        return middleNormalBgColor;
      } else if (listIndex == 3) {
        return lightNormalBgColor;
      }
    }
    return lightNormalBgColor;
  }
}