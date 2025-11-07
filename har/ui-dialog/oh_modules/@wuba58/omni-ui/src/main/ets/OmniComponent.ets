import { window } from "@kit.ArkUI";
import immersionBar from "./utils/ImmersionBar";

export class OmniComponent{
  static init(window:window.Window){
    immersionBar.init(window)
  }
}