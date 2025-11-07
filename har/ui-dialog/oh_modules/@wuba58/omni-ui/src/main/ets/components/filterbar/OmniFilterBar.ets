import { OmniFilterDataRoot, OmniFilterItemBean, OmniFilterShowType } from "./bean/OmniFilterItemBean"
import { promptAction } from "@kit.ArkUI"
import { OmniFilterUtil } from "./util/OmniFilterUtil"
import { OmniFilterListGroup } from "./component/OmniFilterListGroup"
import immersionBar from "../../utils/ImmersionBar"
import { DefaultFilterConverter, OmniFilterConverterDelegate } from "./converter/OmniFilterConverter"
import { OmniFilterMenuItemComponent } from "./component/OmniFilterMenuItem"
import { OmniFilterCustomMenuTitle, OmniFilterMenuItemBean } from "./bean/OmniFilterMenuItemBean"
import { TextUtils } from "../../utils/TextUtils"
import { OmniFilterGridGroup } from "./component/OmniFilterGridGroup"
import { OmniFilterComponentRegistry, OnCloseAction, OnConfirmAction } from "./OmniFilterComponentRegistry"
import { OmniFilterStyle } from "./OmniFilterThemeConfig"

@Builder
function dropListBuilder(item: OmniFilterItemBean, onConfirmAction: OnConfirmAction, onCloseAction: OnCloseAction) {
  OmniFilterListGroup({
    item: item,
    onConfirmAction: onConfirmAction
  })
}

@Builder
function dropGridBuilder(item: OmniFilterItemBean, onConfirmAction: OnConfirmAction, onCloseAction: OnCloseAction) {
  OmniFilterGridGroup({
    item: item,
    isDrop: true,
    onConfirmAction: onConfirmAction
  })
}

@Builder
function moreBuilder(item: OmniFilterItemBean, onConfirmAction: OnConfirmAction, onCloseAction: OnCloseAction) {
  OmniFilterGridGroup({
    item: item,
    isDrop: false,
    onConfirmAction: onConfirmAction
  })
    .width(`80%`)
}

@Component
export struct OmniFilterDropContainer {
  componentRegistry?: OmniFilterComponentRegistry
  @ObjectLink item: OmniFilterItemBean
  onFilterConfirm?: () => void
  onClose?: () => void

  build() {
    Column() {
      Column() {
        this.componentRegistry?.getDropSlideComponentBuilder(this.item.showType.toString())!.builder(this.item,
          this.onFilterConfirm, this.onClose)
      }

      Blank()
        .onClick(() => {
          this.onClose?.()
        })
    }
    .width(`100%`)
    .height(`100%`)
  }
}

@Component
export struct OmniFilterRightSlideContainer {
  componentRegistry?: OmniFilterComponentRegistry
  @ObjectLink item: OmniFilterItemBean
  onFilterConfirm?: () => void
  onClose?: () => void

  build() {
    Row() {
      Blank()
        .onClick(() => {
          this.onClose?.()
        })
      this.componentRegistry?.getRightSlideComponentBuilder(this.item.showType.toString())!.builder(this.item,
        this.onFilterConfirm, this.onClose)
    }
    .width(`100%`)
    .height(`100%`)
    .justifyContent(FlexAlign.End)
  }
}

@Component
export struct OmniFilterBar {
  //筛选数据
  @ObjectLink filterDataRoot: OmniFilterDataRoot
  //组件控制器
  filterController?: OmniFilterController = undefined
  //筛选参数变更回调
  onFilterParamsChanged?: (selectedParams: Map<string, string>) => void
  //数据转换代理
  filterConverterDelegate: OmniFilterConverterDelegate = new DefaultFilterConverter()
  //点击menu的拦截
  onMenuClickInterceptor?: (index: number, item: OmniFilterItemBean) => boolean
  //menu title的自定义设置
  onMenuCustomTitle?: (index: number, item: OmniFilterItemBean) => OmniFilterCustomMenuTitle | undefined
  //组件注册器
  componentRegistry: OmniFilterComponentRegistry = new OmniFilterComponentRegistry()
  //样式设置
  @Provide filterStyle: OmniFilterStyle = {}
  ///内部属性
  @State private menuItemList: OmniFilterMenuItemBean[] = []
  @State private currentItem?: OmniFilterMenuItemBean = undefined
  @State private isMoreDialogShow: boolean = true;
  @State private isCustomDialogShow: boolean = true;
  private customDialogComponentId?: number = undefined
  private statusBarHeight: number = 0
  private filterTopMargin: number = 0;

  aboutToAppear(): void {
    ///初始化内置组件
    if (!this.componentRegistry) {
      this.componentRegistry = new OmniFilterComponentRegistry()
    }
    this.componentRegistry.registerDropSlideComponent(OmniFilterShowType.dropList, wrapBuilder(dropListBuilder))
    this.componentRegistry.registerDropSlideComponent(OmniFilterShowType.dropGrid, wrapBuilder(dropGridBuilder))
    this.componentRegistry.registerRightSlideComponent(OmniFilterShowType.more, wrapBuilder(moreBuilder))
    this.filterDataRoot.items?.forEach((item, index) => {
      const menuItem = new OmniFilterMenuItemBean(item, item.title, false, false)
      this.menuItemList.push(menuItem)
      this._refreshFilterMenuTitle(index, menuItem)
    })
    this.statusBarHeight = immersionBar.getStatusBarHeight()
    this.filterController?.registerOnClose(() => {
      this.tryCloseDialog()
    })
    this.filterController?.registerOnRefreshMenu(() => {
      this.menuItemList?.forEach((menuItem, index) => {
        this._refreshFilterMenuTitle(index, menuItem)
      })
    })
  }

  aboutToDisappear(): void {
    this.tryCloseDialog()
  }

  build() {
    Row() {
      ForEach(this.menuItemList, (menuItem: OmniFilterMenuItemBean, index: number) => {
        OmniFilterMenuItemComponent({
          menuItem: menuItem,
        })
          .layoutWeight(1)
          .onClick(() => {
            this.onMenuItemClick(menuItem, index)
          })
      }, (item: OmniFilterItemBean, index: number) => index.toString())
    }
    .onAreaChange((oldValue: Area, newValue: Area) => {
      if (newValue.globalPosition.y) {
        this.filterTopMargin =
          OmniFilterUtil.lengthToNumber(newValue.globalPosition.y) + OmniFilterUtil.lengthToNumber(newValue.height)
      }
      console.info(`misery Ace: on area change, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
    })
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(40)
  }

  private onMenuItemClick(menuItem: OmniFilterMenuItemBean, index: number) {
    if (this.customDialogComponentId && this.currentItem == menuItem) { //已经打开且点击当前menu，则关闭
      this.menuItemList.forEach((forItem) => {
        if (forItem == menuItem) {
          forItem.active = !forItem.active
        } else {
          forItem.active = false
        }
      })
      this.tryCloseDialog()
      return
    }
    const item = menuItem.item
    //menu点击拦截
    if (!menuItem.active && this.onMenuClickInterceptor?.(index, item, )) {
      return
    }
    this.menuItemList.forEach((forItem) => {
      if (forItem == menuItem) {
        forItem.active = !forItem.active
      } else {
        forItem.active = false
      }
    })
    this.tryCloseDialog()
    this.currentItem = menuItem
    if (this.componentRegistry.hasRightSlideType(item.showType)) {
      promptAction.openCustomDialog({
        transition: TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.Ease }),
        cornerRadius: 0,
        width: "100%",
        height: "100%",
        backgroundColor: Color.Transparent,
        backgroundBlurStyle: BlurStyle.NONE,
        maskRect: {
          x: 0,
          y: this.statusBarHeight,
          width: '100%',
          height: '100%',
        },
        offset: { dx: 0, dy: 0 },
        alignment: DialogAlignment.CenterEnd,
        builder: () => {
          this.customMoreComponent(menuItem, index)
        },
        onWillAppear: () => {
          this.isMoreDialogShow = true;
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          this.isMoreDialogShow = false;
          this.onDialogWillDismiss(dismissDialogAction)
        }
      }).then((dialogId: number) => {
        this.customDialogComponentId = dialogId
      })
      return
    } else if (this.componentRegistry.hasDropSlideType(item.showType)) {
      promptAction.openCustomDialog({
        transition: TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.Ease }),
        cornerRadius: 0,
        width: "100%",
        height: "100%",
        backgroundColor: Color.Transparent,
        backgroundBlurStyle: BlurStyle.NONE,
        maskRect: {
          x: 0,
          y: this.filterTopMargin,
          width: '100%',
          height: '100%',
        },
        offset: { dx: 0, dy: this.filterTopMargin - this.statusBarHeight },
        alignment: DialogAlignment.Top,
        builder: () => {
          this.customDialogComponent(menuItem, index)
        },
        onWillAppear: () => {
          this.isCustomDialogShow = true;
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          this.isCustomDialogShow = false;
          this.onDialogWillDismiss(dismissDialogAction)
        }
      }).then((dialogId: number) => {
        this.customDialogComponentId = dialogId
      })
    } else {
      throw new Error(`未知的组件类型，请配置componentRegistry并注册自定义类型`)
    }

  }

  onDialogWillDismiss(dismissDialogAction: DismissDialogAction) {
    this.menuItemList.forEach((forItem) => {
      forItem.active = false
    })
    if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
      dismissDialogAction.dismiss()
      this.customDialogComponentId = undefined
    }
    if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
      dismissDialogAction.dismiss()
      this.customDialogComponentId = undefined
    }
  }

  _refreshFilterMenuTitle(index: number, entity: OmniFilterMenuItemBean): void {
    const filterItem = entity.item
    if (this.onMenuCustomTitle) {
      const customMenuTitle = this.onMenuCustomTitle(index, entity.item)
      entity.customTitle = customMenuTitle?.menuTitle
      entity.isCustomTitleHighLight = customMenuTitle?.isHighLight ?? false
    }
    const title: string | undefined = this._getSelectedResultTitle(entity);
    let isHighlight: boolean
    if (filterItem.selectedListWithoutUnlimit().length > 0) {
      isHighlight = true;
    } else if (!TextUtils.isBlank(entity.customTitle)) {
      isHighlight = entity.isCustomTitleHighLight;
    } else {
      isHighlight = false;
    }
    let targetMenuItem = this.menuItemList[index]
    if (title) {
      targetMenuItem.menuTitle = title
    }
    targetMenuItem.isHighLight = isHighlight
  }

  /// 筛选 Title 展示规则
  private _getSelectedResultTitle(entity: OmniFilterMenuItemBean): string | undefined {
    const filterItem = entity.item
    /// TODO 更多筛选不改变 title.故返回 null
    if (filterItem.showType == OmniFilterShowType.more) {
      return undefined;
    }
    if (TextUtils.isBlank(entity.customTitle)) {
      return OmniFilterUtil.getTitle(filterItem);
    } else {
      return entity.customTitle;
    }
  }

  @Builder
  customDialogComponent(menuItem: OmniFilterMenuItemBean, index: number) {
    if (this.isCustomDialogShow) {
      OmniFilterDropContainer({
        componentRegistry: this.componentRegistry,
        item: menuItem.item,
        onFilterConfirm: () => {
          this.tryCloseDialog()
          let map = this.filterConverterDelegate.convertSelectedData(this.filterDataRoot.items)
          this.onFilterParamsChanged?.(map)
          menuItem.active = false
          this._refreshFilterMenuTitle(index, menuItem)
        },
        onClose: () => {
          this.isCustomDialogShow = false;
          this.tryCloseDialog()
          menuItem.active = false
          this._refreshFilterMenuTitle(index, menuItem)
        }
      })//TODO 计算y
        .transition(TransitionEffect.asymmetric(TransitionEffect.translate({ y: -700 }),
          TransitionEffect.move(TransitionEdge.TOP)).animation({ duration: 300 }))
    }
  }

  @Builder
  customMoreComponent(menuItem: OmniFilterMenuItemBean, index: number) {
    if (this.isMoreDialogShow) {
      OmniFilterRightSlideContainer({
        componentRegistry: this.componentRegistry,
        item: menuItem.item,
        onFilterConfirm: () => {
          this.tryCloseDialog()
          let map = this.filterConverterDelegate.convertSelectedData(this.filterDataRoot.items)
          this.onFilterParamsChanged?.(map)
          menuItem.active = false
          this._refreshFilterMenuTitle(index, menuItem)
        },
        onClose: () => {
          this.isMoreDialogShow = false;
          this.tryCloseDialog()
          menuItem.active = false
          this._refreshFilterMenuTitle(index, menuItem)
        }
      })
        .transition(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END),
          TransitionEffect.move(TransitionEdge.END)).animation({ duration: 300 }))
    }
  }

  private tryCloseDialog() {
    if (this.customDialogComponentId) {
      promptAction.closeCustomDialog(this.customDialogComponentId)
      this.customDialogComponentId = undefined
    }
  }
}

export class OmniFilterController {
  private onCloseListener?: () => void = undefined

  close() {
    this.onCloseListener?.()
  }

  registerOnClose(listener: () => void) {
    this.onCloseListener = listener
  }

  private onRefreshMenuListener?: () => void = undefined

  refreshMenu() {
    this.onRefreshMenuListener?.()
  }

  registerOnRefreshMenu(listener: () => void) {
    this.onRefreshMenuListener = listener
  }
}
