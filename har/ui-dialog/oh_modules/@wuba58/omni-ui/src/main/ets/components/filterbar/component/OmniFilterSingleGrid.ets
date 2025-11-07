import { OmniFilterItemBean } from "../bean/OmniFilterItemBean"
import { LengthMetrics } from "@kit.ArkUI"
import { OmniFilterGridItem } from "./OmniFilterGridItem"
import { OmniFilterUtil } from "../util/OmniFilterUtil"
import { GridAttr, GridEventBus } from "./OmniFilterGridGroup"
import { OmniFilterStyle } from "../OmniFilterThemeConfig"
import { OmniTheme, OmniThemeStyle } from "../../../theme/OmniTheme"

@Component
@Preview
export struct OmniFilterSingleGrid {
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  @ObjectLink item: OmniFilterItemBean
  @State childrens?: OmniFilterItemBean[] = undefined
  @State focusIndex: number = -1
  @Prop componentWidth:number = 0
  @Consume filterStyle: OmniFilterStyle
  gridEventBus?: GridEventBus

  aboutToAppear(): void {
    this.childrens = this.item.children
    this.focusIndex = this._getInitialSelectIndex(this.childrens)
    this.gridEventBus?.registerObserver(() => {
      this.focusIndex = this._getInitialSelectIndex(this.childrens)
    })
  }

build() {
    Column() {
      Text(this.item.title)
        .alignSelf(ItemAlign.Start)
        .fontColor(this.filterStyle?.gridStyle?.titleTextStyle?.fontColor ?? Color.Black)
        .fontWeight(this.filterStyle?.gridStyle?.titleTextStyle?.fontWeight ?? FontWeight.Bold)
        .fontSize(this.filterStyle?.gridStyle?.titleTextStyle?.fontSize ?? this.baseStyle.fontSizeLg)
        .margin({
          bottom: 20
        })
      Flex({
        wrap: FlexWrap.Wrap,
        alignItems: ItemAlign.Center,
        space: {
          main: LengthMetrics.vp(12),
          cross: LengthMetrics.vp(10)
        }
      }) {
        ForEach(this.childrens, (item: OmniFilterItemBean, index: number) => {
          OmniFilterGridItem({
            item: item,
            focusedIndex: this.focusIndex,
            listIndex: index,
            componentWidth:this.componentWidth,
            gridItemSelect: () => {
              OmniFilterUtil.processBrotherItemSelectStatus(item)
              this.focusIndex = this._getInitialSelectIndex(this.childrens)
            }
          })
        }, (item: OmniFilterItemBean, index: number) => item.generateListKey() + index)
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
}