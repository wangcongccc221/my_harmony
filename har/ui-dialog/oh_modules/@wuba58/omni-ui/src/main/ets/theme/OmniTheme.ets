import { OmniColorStyle } from "./OmniColorStyle";
import { FONT_SIZE, OmniFontStyle } from "./OmniFontStyle";
import { OmniThemeUtil } from "./OmniThemeUtil";

export enum OmniColor{
  PRIMARY_COLOR = -1
};

export type OmniResourceColor = number | string ;

export interface OmniThemeStyle extends OmniColorStyle, OmniFontStyle {}

export class OmniTheme {
  static KEY = 'OMNI_THEME_KEY'
  static DEFAULT_PRIMARY_COLOR = "#296DFF"

  static init() {
    AppStorage.setOrCreate(OmniTheme.KEY, OmniTheme.getDefaultStyle())
  }

  static getDefaultStyle(): OmniThemeStyle {
    const data: OmniThemeStyle = {
      primary: OmniTheme.DEFAULT_PRIMARY_COLOR,
      primaryColorWithOpacity: (opacity: number) => OmniThemeUtil.colorWithOpacity(data.primary, opacity),
      fontSizeXs: FONT_SIZE.XS,
      fontSizeSm: FONT_SIZE.SM,
      fontSizeMd: FONT_SIZE.MD,
      fontSizeLg: FONT_SIZE.LG,
      fontSizeXl: FONT_SIZE.XL,
    }
    return data;
  }

  static setThemeStyle(styleData?: Partial<OmniThemeStyle>) {
    const newStyleData = OmniTheme.getDefaultStyle();
    if (typeof styleData === 'object' && styleData !== null) {
      Object.keys(styleData).forEach(item => {
        if ((newStyleData as object)[item]) {
          (newStyleData as object)[item] = (styleData as object)[item] ?? (newStyleData as object)[item]
        }
      })
    }
    AppStorage.setOrCreate(OmniTheme.KEY, newStyleData)
  }
}