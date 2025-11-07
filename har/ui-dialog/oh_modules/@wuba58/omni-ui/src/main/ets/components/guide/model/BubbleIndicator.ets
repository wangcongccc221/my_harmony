import { PopupPosition } from '../../popup/PopupPosition';

export class BubbleIndicator {
  private _componentId: string = "";

  public get componentId(): string {
    return this._componentId;
  }

  private _bubblePosition: BubblePosition = BubblePosition.BOTTOM;

  public get popupPosition(): PopupPosition {
    switch (this._bubblePosition) {
      case BubblePosition.TOP:
        return PopupPosition.TOP;
      case BubblePosition.BOTTOM:
        return PopupPosition.BOTTOM;
      case BubblePosition.LEFT:
        return PopupPosition.LEFT;
      case BubblePosition.RIGHT:
        return PopupPosition.RIGHT;
    }
  }

  private _bubbleBean?: BubbleBean | undefined;

  public get bubbleBean(): BubbleBean | undefined {
    return this._bubbleBean;
  }

  constructor(componentId: string, bubbleBean: BubbleBean, bubblePosition?: BubblePosition) {
    this._componentId = componentId;
    this._bubblePosition = bubblePosition ?? BubblePosition.BOTTOM;
    this._bubbleBean = bubbleBean;
  }
}

export class BubbleBean {
  private _title: string = "";

  public get title(): string {
    return this._title;
  }

  private _content: string = "";

  public get content(): string {
    return this._content;
  }

  constructor(title: string, content: string) {
    this._title = title;
    this._content = content;
  }
}

export enum BubblePosition {
  TOP,
  BOTTOM,
  LEFT,
  RIGHT
}

@Builder
export function bubbleBuilder(data: BubbleBean) {
  Column() {
    Text(data.title)
      .fontSize(15)
      .fontColor(Color.Black)
    Text(data.content)
      .fontSize(14)
      .fontColor(Color.Gray)
      .margin({ top: 8 })
  }.alignItems(HorizontalAlign.Start)
}