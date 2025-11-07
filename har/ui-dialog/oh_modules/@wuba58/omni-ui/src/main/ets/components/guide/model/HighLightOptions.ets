import { OnClickListener } from '../interface/OnClickListener';
import { OnHighLightDrewListener } from '../interface/OnHighLightDrewListener';

export class HighLightOptions {
  public onClickListener: OnClickListener | null = null;
  public onHighLightDrewListener: OnHighLightDrewListener | null = null;
  public fetchLocationEveryTime: boolean = false;
}