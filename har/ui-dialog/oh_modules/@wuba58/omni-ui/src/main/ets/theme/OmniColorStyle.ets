import { OmniResourceColor } from "./OmniTheme";

export interface OmniColorStyle {
  primary: OmniResourceColor
  primaryColorWithOpacity: (opacity: number) => OmniResourceColor;
}