import { OmniTheme, OmniThemeStyle } from '../../theme/OmniTheme';

// 展示模式，周视图模式，月视图模式
export enum DisplayMode {
  week,
  month
}

// 时间选择模式，单个时间，时间范围
export enum SelectMode {
  single,
  range
}

// 单选日期回调函数
type CalendarDateChange = (date: Date) => void;

interface CalendarRangeDate {
  start: Date;
  end: Date;
}

// 范围选择日期回调函数
type CalendarRangeDateChange = (range: CalendarRangeDate) => void;

@Component
export struct OmniCalendar {
  @StorageLink(OmniTheme.KEY)
  baseStyle: OmniThemeStyle = OmniTheme.getDefaultStyle()
  displayMode: DisplayMode = DisplayMode.month;
  selectMode: SelectMode = SelectMode.single;
  minDate: Date = new Date(1970, 0, 1);
  maxDate: Date = new Date(2100, 0, 1);
  initStartSelectedDate: Date | undefined;
  initEndSelectedDate: Date | undefined;
  initDisplayDate: Date | undefined;
  colorTextBase: string = '#222222';
  colorTextHint: string = '#CCCCCC';
  colorSelect?: string;
  colorRange?: string;
  dateChange: CalendarDateChange = () => {
  };
  rangeDateChange: CalendarRangeDateChange = (_: CalendarRangeDate) => {
  };
  showControllerBar: boolean = true;
  weekNames: string[] = ['日', '一', '二', '三', '四', '五', '六'];
  @State dateList: Date[] = [];
  @State showDateList: Date[][] = [];
  @State currentDate: Date = new Date();
  @State currentStartSelectedDate: Date | undefined | null = null;
  @State currentEndSelectedDate: Date | undefined | null = null;

  aboutToAppear() {
    this.currentDate = this.initDisplayDate ?? new Date();
    this.currentStartSelectedDate = this.initStartSelectedDate;
    this.currentEndSelectedDate = this.initEndSelectedDate;

    if (this.displayMode == DisplayMode.month) {
      this._setListOfMonthDate(this.currentDate);
    } else if (this.displayMode == DisplayMode.week) {
      this._setListOfWeekDate(this.currentDate);
    }
  }

  // 设置周日期列表
  _setListOfWeekDate(weekDate: Date) {
    this.dateList = [];
    let tmpDateList: Date[] = [];
    let previousDay = weekDate.getDay() % 7;
    for (let i = 0; i < weekDate.getDay(); i++) {
      tmpDateList.push(new Date(weekDate.getTime() - ((previousDay - i) * 24 * 60 * 60 * 1000)));
    }
    let preCount = tmpDateList.length;
    for (let i = 0; i < (7 - preCount); i++) {
      tmpDateList.push(new Date(weekDate.getTime() + (i * 24 * 60 * 60 * 1000)));
    }

    this.dateList = tmpDateList.map((f) => new Date(f.getFullYear(), f.getMonth(), f.getDate()));
    this._setShowDateList();
  }

  _setShowDateList() {
    this.showDateList = [];
    let count = 0;
    for (let i = 0; i < this.dateList.length / 7; i++) {
      let list: Date[] = [];
      for (let j = 0; j < 7; j++) {
        let date = this.dateList[count];
        list.push(date);
        count++;
      }
      this.showDateList.push(list);
    }
  }

  // 设置月日期列表的方法
  _setListOfMonthDate(monthDate: Date) {
    this.dateList = [];
    let tmpDateList: Date[] = [];
    let newDate = new Date(monthDate.getFullYear(), monthDate.getMonth(), 0);
    let previousMonthDay = (newDate.getDay() + 1) % 7;
    for (let i = 1; i <= previousMonthDay; i++) {
      tmpDateList.push(new Date(newDate.getTime() - ((previousMonthDay - i) * 24 * 60 * 60 * 1000)));
    }
    let preMonthCount = tmpDateList.length;
    for (let i = 0; i < (42 - preMonthCount); i++) {
      tmpDateList.push(new Date(newDate.getTime() + ((i + 1) * 24 * 60 * 60 * 1000)));
    }
    this.dateList = tmpDateList.map((f) => new Date(f.getFullYear(), f.getMonth(), f.getDate()));
    this._setShowDateList();
  }

  build() {
    Column() {
      this.controllerBar()
      this._getDaysNameUI()
      Divider()
        .color(Color.Transparent)
        .height(5)
      this._getDaysNoUI()
    }
  }

  // 顶部控制栏
  @Builder
  controllerBar() {
    if (this.showControllerBar) {
      RelativeContainer() {
        if (this._isIconEnable(true)) {
          Image($r('app.media.icon_calendar_pre_month'))
            .width(25)
            .height(25)
            .padding(5)
            .margin({ left: 15 })
            .onClick(() => {
              this.currentDate = this._updateDateOnPrevClick();
              if (this.displayMode == DisplayMode.month) {
                this._setListOfMonthDate(this.currentDate);
              } else if (this.displayMode == DisplayMode.week) {
                this._setListOfWeekDate(this.currentDate);
              }
            })
            .alignRules({
              left: { anchor: "__container__", align: HorizontalAlign.Start },
              center: { anchor: "__container__", align: VerticalAlign.Center }
            })
            .id("btn_preview_ctrl")
        }

        Text(this._formatCurrentDate())
          .fontSize(this.baseStyle.fontSizeLg)
          .fontWeight(FontWeight.Medium)
          .alignRules({
            center: { anchor: "__container__", align: VerticalAlign.Center },
            middle: { anchor: "__container__", align: HorizontalAlign.Center },
          })
          .id("txt_current_date")

        if (this._isIconEnable(false)) {
          Image($r('app.media.icon_calendar_next_month'))
            .width(25)
            .height(25)
            .padding(5)
            .margin({
              right: 15
            })
            .onClick(() => {
              this.currentDate = this._updateDateOnNextClick();
              if (this.displayMode == DisplayMode.month) {
                this._setListOfMonthDate(this.currentDate);
              } else if (this.displayMode == DisplayMode.week) {
                this._setListOfWeekDate(this.currentDate);
              }
            })
            .alignRules({
              right: { anchor: "__container__", align: HorizontalAlign.End },
              center: { anchor: "__container__", align: VerticalAlign.Center }
            })
            .id("btn_next_ctrl")
        }
      }
      .width('100%')
      .height(30)
      .margin({ bottom: 10 })
    }
  }

  // 判断图标是否可用
  _isIconEnable(isPre: boolean): boolean {
    if (isPre) {
      if (this.dateList[0].getFullYear() < this.minDate.getFullYear()) {
        return false;
      }
      if (this.dateList[0].getFullYear() == this.minDate.getFullYear()) {
        if (this.displayMode == DisplayMode.week) {
          if (this.dateList[0].getMonth() < this.minDate.getMonth()) {
            return false;
          }
          if (this.dateList[0].getMonth() == this.minDate.getMonth()) {
            if (this.dateList[0].getDate() <= this.minDate.getDate()) {
              return false;
            }
          }
        } else {
          if (this.dateList[0].getMonth() <= this.minDate.getMonth() &&
            this.currentDate.getMonth() == this.minDate.getMonth()) {
            return false;
          }
        }
      }
      return true;
    } else {
      if (this.dateList[this.dateList.length - 1].getFullYear() > this.maxDate.getFullYear()) {
        return false;
      }
      if (this.dateList[this.dateList.length - 1].getFullYear() == this.maxDate.getFullYear()) {
        if (this.displayMode == DisplayMode.week) {
          if (this.dateList[this.dateList.length - 1].getMonth() > this.maxDate.getMonth()) {
            return false;
          }
          if (this.dateList[this.dateList.length - 1].getMonth() == this.maxDate.getMonth()) {
            if (this.dateList[this.dateList.length - 1].getDate() >= this.maxDate.getDate()) {
              return false;
            }
          }
        } else {
          if (this.dateList[this.dateList.length - 1].getMonth() >= this.maxDate.getMonth() &&
            this.currentDate.getMonth() == this.maxDate.getMonth()) {
            return false;
          }
        }
      }
      return true;
    }
  }

  // 更新日期用于上一页点击
  _updateDateOnPrevClick(): Date {
    if (this.displayMode == DisplayMode.month) {
      return new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, 1);
    } else {
      return new Date(this.currentDate.getTime() - 7 * 24 * 60 * 60 * 1000);
    }
  }

  // 更新日期用于下一页点击
  _updateDateOnNextClick(): Date {
    if (this.displayMode == DisplayMode.month) {
      return new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() + 1, 1);
    } else {
      return new Date(this.currentDate.getTime() + 7 * 24 * 60 * 60 * 1000);
    }
  }

  // 格式化当前日期
  _formatCurrentDate(): string {
    let year = this.currentDate.getFullYear();
    let month = this.currentDate.getMonth() + 1;
    return `${year}年${month < 10 ? '0' + month : month}月`;
  }

  // 构建星期名称
  @Builder
  _getDaysNameUI() {
    Flex({ direction: FlexDirection.Row }) {
      ForEach(this.weekNames, (weekName: string) => {
        Text(weekName)
          .fontSize(this.baseStyle.fontSizeMd)
          .fontColor(this.colorTextBase)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      })
    }
    .width('100%')
  }

  // 构建日期数字UI组件列表
  @Builder
  _getDaysNoUI() {
    ForEach(this.showDateList, (list: Date[]) => {
      Flex({ direction: FlexDirection.Row }) {
        ForEach(list, (date: Date) => {
          Stack() {
            Column() {
              Row()
                .width(5)
                .height(5)
              Text(date.getDate() > 9 ? '' + date.getDate() : '0' + date.getDate())
                .fontSize(this.baseStyle.fontSizeMd)
                .fontColor(
                  this.displayMode == DisplayMode.month
                    ? (this._getIsItStartAndEndDate(date)
                    ? Color.White
                    : this.currentDate.getMonth() ==
                    date.getMonth() && date.getTime() >= this.minDate.getTime() &&
                      date.getTime() <= this.maxDate.getTime()
                      ? this.colorTextBase
                      : this.colorTextHint)
                    : (this._getIsItStartAndEndDate(date)
                    ? Color.White
                    : (date.getTime() >= this.minDate.getTime() &&
                      date.getTime() <= this.maxDate.getTime()
                      ? this.colorTextBase
                      : this.colorTextHint))
                )
              Row()
                .backgroundColor(
                  new Date().getFullYear() == date.getFullYear() &&
                    new Date().getMonth() == date.getMonth() &&
                    new Date().getDate() == date.getDate()
                    ? this.colorSelect ?? this.baseStyle.primary
                    : Color.Transparent
                )
                .width(5)
                .height(5)
                .borderRadius(3)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor(
              this._getIsItStartAndEndDate(date)
                ? this.colorSelect ?? this.baseStyle.primary
                : Color.Transparent
            )
            .width('100%')
            .height('100%')
            .borderRadius(32)
          }
          .backgroundColor(
            this.currentStartSelectedDate != null &&
              this.currentEndSelectedDate != null
              ? (this._getIsItStartAndEndDate(date) ||
            this._getIsInRange(date)
              ? this.colorRange ?? this.baseStyle.primaryColorWithOpacity(0.15)
              : Color.Transparent)
              : Color.Transparent
          )
          .borderRadius(
            {
              topLeft: this._isStartDateRadius(date) ? 24 : 0,
              bottomLeft: this._isStartDateRadius(date) ? 24 : 0,
              topRight: this._isEndDateRadius(date) ? 24 : 0,
              bottomRight: this._isEndDateRadius(date) ? 24 : 0,
            }
          )
          .margin({
            top: 3,
            bottom: 3
          })
          .aspectRatio(1)
          .layoutWeight(1)
          .onClick(() => {
            let newMinimumDate: Date = new Date(
              this.minDate.getFullYear(), this.minDate.getMonth(), this.minDate.getDate() - 1);
            let newMaximumDate: Date = new Date(
              this.maxDate.getFullYear(), this.maxDate.getMonth(), this.maxDate.getDate() + 1);
            if (date.getTime() > newMinimumDate.getTime() &&
              date.getTime() < newMaximumDate.getTime()) {
              this.currentDate = date;
              if (this.displayMode == DisplayMode.week) {
                this._setListOfWeekDate(this.currentDate);
              } else if (this.displayMode == DisplayMode.month) {
                this._setListOfMonthDate(this.currentDate);
              }
              if (this.selectMode == SelectMode.single) {
                this._onSingleDateClick(date);
              } else {
                this._onRangeDateClick(date);
              }
            }
          })
        })
      }
      .width('100%')
    })
  }

  _onSingleDateClick(date: Date) {
    this.currentStartSelectedDate = date;
    this.currentEndSelectedDate = date;
    this.dateChange(date)
  }

  // 在选择 [date] 这个时间时，startDate、endDate 的状态共四种组合（×: 代表无值， √: 代表有值）
  //   start    end
  // ①  √       √
  // ②  ×       ×
  // ③  √       ×
  // ④  ×       √
  _onRangeDateClick(date: Date) {
    // 当为 ①、② 都有值，或都无值的时候，在选择 date 后，将date 赋值给 start，end 置空
    if ((this.currentStartSelectedDate != null && this.currentEndSelectedDate != null) ||
      (this.currentStartSelectedDate == null && this.currentEndSelectedDate == null)) {
      this.currentStartSelectedDate = date;
      this.currentEndSelectedDate = null;
    } else {
      // 当为 ③、④ 其中有一个有值时，在选择 date 后，将 date 赋值给为空的一方
      if (this.currentStartSelectedDate == null) {
        this.currentStartSelectedDate = date;
      }
      if (this.currentEndSelectedDate == null) {
        this.currentEndSelectedDate = date;
      }
    }

    // 根据 start、end 时间大小，交换其值
    if (this.currentStartSelectedDate != null && this.currentEndSelectedDate != null) {
      if (this.currentEndSelectedDate.getTime() < this.currentStartSelectedDate.getTime()) {
        let d: Date = this.currentStartSelectedDate;
        this.currentStartSelectedDate = this.currentEndSelectedDate;
        this.currentEndSelectedDate = d;
      }
    }
    if (this.currentStartSelectedDate != null && this.currentEndSelectedDate != null) {
      this.rangeDateChange({ start: this.currentStartSelectedDate, end: this.currentEndSelectedDate! })
    }
  }

  _getIsInRange(date: Date): boolean {
    if (this.currentStartSelectedDate != null && this.currentEndSelectedDate != null) {
      if (date.getTime() > this.currentStartSelectedDate.getTime() &&
        date.getTime() < this.currentEndSelectedDate.getTime()) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  _getIsItStartAndEndDate(date: Date): boolean {
    if (this.currentStartSelectedDate != null &&
      this.currentStartSelectedDate.getDate() == date.getDate() &&
      this.currentStartSelectedDate.getMonth() == date.getMonth() &&
      this.currentStartSelectedDate.getFullYear() == date.getFullYear()) {
      return true;
    } else if (this.currentEndSelectedDate != null &&
      this.currentEndSelectedDate.getDate() == date.getDate() &&
      this.currentEndSelectedDate.getMonth() == date.getMonth() &&
      this.currentEndSelectedDate.getFullYear() == date.getFullYear()) {
      return true;
    } else {
      return false;
    }
  }

  _isStartDateRadius(date: Date): boolean {
    if (this.currentStartSelectedDate != null &&
      this.currentStartSelectedDate.getDate() == date.getDate() &&
      this.currentStartSelectedDate.getMonth() == date.getMonth()) {
      return true;
    } else if (date.getDay() == 0) {
      return true;
    } else {
      return false;
    }
  }

  _isEndDateRadius(date: Date): boolean {
    if (this.currentEndSelectedDate != null &&
      this.currentEndSelectedDate.getDate() == date.getDate() &&
      this.currentEndSelectedDate.getMonth() == date.getMonth()) {
      return true;
    } else if (date.getDay() == 6) {
      return true;
    } else {
      return false;
    }
  }
}