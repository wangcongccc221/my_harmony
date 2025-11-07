import { OmniFilterItemBean } from "./OmniFilterItemBean"

@Observed
export class OmniFilterMenuItemBean {
  item: OmniFilterItemBean
  menuTitle: string | undefined
  isHighLight: boolean
  active: boolean

  customTitle?:string = undefined
  isCustomTitleHighLight:boolean = false

  constructor(item: OmniFilterItemBean, menuTitle: string, isHighLight: boolean, active: boolean) {
    this.item = item
    this.menuTitle = menuTitle
    this.isHighLight = isHighLight
    this.active = active
  }

}

/**
 * 自定义Menu标题数据结构
 */
export class OmniFilterCustomMenuTitle{
  menuTitle: string
  isHighLight: boolean

  constructor(menuTitle: string, isHighLight: boolean) {
    this.menuTitle = menuTitle
    this.isHighLight = isHighLight
  }

}