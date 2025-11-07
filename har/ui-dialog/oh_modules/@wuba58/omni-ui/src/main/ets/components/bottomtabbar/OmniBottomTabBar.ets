import { TextModifier, CommonModifier, display } from '@kit.ArkUI'

@Preview
@Component
export struct OmniBottomTabBar {

  public data: Array<OmniBottomBarItem> = [];
  @State defaultSelectedIndex: number = 0;

  public iconModifier?: BarIconModifier = new BarIconModifier();
  public iconSelectedModifier?: BarSelectedIconModifier = new BarSelectedIconModifier();

  public textModifier?: BarTextModifier = new BarTextModifier();
  public textSelectedModifier?: BarSelectTextModifier = new BarSelectTextModifier();

  public badgeTextModifier?: BarBadgeTextModifier = new BarBadgeTextModifier();

  private oneIconWidth: number = 0;
  aboutToAppear() {
    this.oneIconWidth = px2vp(display.getDefaultDisplaySync().width) / this.data.length;
    console.log('===========', this.data.length, this.oneIconWidth)
  }

  build() {
    Row() {
      ForEach(this.data, (item: OmniBottomBarItem, index) => {
        Column() {
          Image(this.defaultSelectedIndex == index ? (item.selectedIcon || item.icon) : item.icon).attributeModifier(this.defaultSelectedIndex == index ? this.iconSelectedModifier : this.iconModifier)
          Text(this.defaultSelectedIndex == index ? (item.selectedText || item.text) : item.text).attributeModifier(this.defaultSelectedIndex == index ? this.textSelectedModifier : this.textModifier)
          if (item.badgeNo) {
            Text(item.badgeNo > (item.maxBadgeNo || 99) ? item.maxBadgeNo?.toString() + '+' : item.badgeNo?.toString()).attributeModifier(this.badgeTextModifier).position({x: -(this.oneIconWidth/2), y: -5})
          }
        }.height('100%').width(this.oneIconWidth).alignItems(HorizontalAlign.Center).onClick(() => {
          this.defaultSelectedIndex = index;
          item.action && item.action()
        })
      }, (item: string, index) => item)
    }
    .width('100%')
    .height(44)
  }


}

export class BarTextModifier implements AttributeModifier<TextModifier> {
  private fontSize: number | string | Resource = '14vp'
  private fontWeight: number | FontWeight | string = FontWeight.Medium
  private fontColor: ResourceColor | string = '#000000'
  private marginTop: number | string = '5vp'

  withFontSize(value: number | string | Resource) {
    this.fontSize = value
    return this
  }

  withMarginTop(value: number | string ) {
    this.marginTop = value
    return this
  }

  withFontWeight(value: number | FontWeight | string) {
    this.fontWeight = value
    return this
  }

  withFontColor(value: ResourceColor | string) {
    this.fontColor = value
    return this
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance.fontSize(this.fontSize)
    instance.fontWeight(this.fontWeight)
    instance.fontColor(this.fontColor)
    instance.margin({top: this.marginTop})
  }
}

export class BarSelectTextModifier implements AttributeModifier<TextModifier> {
  private fontSize: number | string | Resource = '14vp'
  private fontWeight: number | FontWeight | string = FontWeight.Medium
  private fontColor: ResourceColor = '#FFC0CB'
  private marginTop: number | string = '5vp'

  withFontSize(value: number | string | Resource) {
    this.fontSize = value
    return this
  }

  withMarginTop(value: number | string ) {
    this.marginTop = value
    return this
  }

  withFontWeight(value: number | FontWeight | string) {
    this.fontWeight = value
    return this
  }

  withFontColor(value: ResourceColor) {
    this.fontColor = value
    return this
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance.fontSize(this.fontSize)
    instance.fontWeight(this.fontWeight)
    instance.fontColor(this.fontColor)
    instance.margin({top: this.marginTop})
  }
}

export class BarIconModifier implements AttributeModifier<CommonModifier> {

  private height: Length = 24
  private width: Length = 24

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withWidth(value: Length) {
    this.width = value
    return this
  }


  applyNormalAttribute(instance: CommonModifier): void {
    instance.height(this.height)
    instance.width(this.width)
  }
}

export class BarSelectedIconModifier implements AttributeModifier<CommonModifier> {

  private height: Length = 24
  private width: Length = 24
  private backgroundColor: ResourceColor = Color.Transparent;

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withBackgroundColor(value: ResourceColor) {
    this.backgroundColor = value
    return this
  }

  withWidth(value: Length) {
    this.width = value
    return this
  }




  applyNormalAttribute(instance: CommonModifier): void {
    instance.height(this.height)
    instance.width(this.width)
    instance.backgroundColor(this.backgroundColor)
  }
}

export class BarBadgeTextModifier implements AttributeModifier<TextModifier> {
  private fontSize: number | string | Resource = '12vp'
  private fontWeight: number | FontWeight | string = FontWeight.Normal
  private backgroundColor:  ResourceColor = Color.Red
  private padding: Padding = {top: 2, left: 2, right: 2, bottom: 2}
  private borderRadius: number = 5
  private fontColor: ResourceColor = Color.White

  withFontSize(value: number | string | Resource) {
    this.fontSize = value
    return this
  }

  withBorderRadius(value: number) {
    this.borderRadius = value
    return this
  }
  withPadding(value: Padding) {
    this.padding = value
    return this
  }

  withBackgroundColor(value: ResourceColor | string) {
    this.backgroundColor = value
    return this
  }

  withFontWeight(value: number | FontWeight | string) {
    this.fontWeight = value
    return this
  }

  withFontColor(value: ResourceColor) {
    this.fontColor = value
    return this
  }

  applyNormalAttribute(instance: TextModifier): void {
    instance.fontSize(this.fontSize)
    instance.fontWeight(this.fontWeight)
    instance.fontColor(this.fontColor)
    instance.backgroundColor(this.backgroundColor)
    instance.padding(this.padding)
    instance.borderRadius(this.borderRadius)
  }
}

export interface OmniBottomBarItem {
  icon: string | ResourceStr,
  selectedIcon?: string | ResourceStr,
  text: string,
  selectedText?: string,
  badgeNo?: number,
  maxBadgeNo?: number // 默认99 >99显示 99+
  action?: () => void;
}

