@Component
export struct OmniLine {
  @Prop modifier: OmniDividerModifier

  build() {
    Divider().attributeModifier(this.modifier)
  }
}

export class OmniDividerModifier implements AttributeModifier<DividerAttribute> {
  private width: Length = '100%'
  private height: Length = '100%'
  private color: ResourceColor = '#FF552E'
  private padding: Padding | Length | LocalizedPadding = {
    top: 5,
    bottom: 5
  }

  withWidth(value: Length) {
    this.width = value
    return this
  }

  withHeight(value: Length) {
    this.height = value
    return this
  }

  withColor(value: ResourceColor) {
    this.color = value
    return this
  }

  withPadding(value: Padding | Length | LocalizedPadding) {
    this.padding = value
    return this
  }

  applyNormalAttribute(instance: DividerAttribute): void {
    instance.width(this.width)
    instance.height(this.height)
    instance.color(this.color)
    instance.padding(this.padding)

  }
}
