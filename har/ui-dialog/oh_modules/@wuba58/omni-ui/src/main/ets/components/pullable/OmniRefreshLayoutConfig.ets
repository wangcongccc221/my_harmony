export class OmniRefreshLayoutConfig {
  public pullRefreshEnable: boolean = true
  public loadMoreEnable: boolean = false

  /*******************************刷新配置*******************************************/
  /*true:释放刷新，false下拉到一定距离刷新*/
  public releaseRefresh: boolean = true
  /*下拉最大距离*/
  public pullMaxDistance: number = 500
  /*下拉阻力*/
  public pullRefreshResistance: number = 0.5
  /*下拉距离超过多少时达到刷新条件*/
  public pullHeaderHeightRefresh: number = 0

  /*释放刷新时，回弹至headerView高度的时间*/
  public durationToHeader: number = 250
  /*头布局刷新结束时回弹的时间*/
  public durationCloseHeader: number = 200
  /*刷新时是否显示头view*/
  public refreshKeepHeader: boolean = true
  /*是否显示刷新成功状态的view*/
  public refreshShowSuccess: boolean = true;
  /*是否显示刷新失败状态的view*/
  public refreshShowError: boolean = true;
  /*刷新结果view显示持续时间*/
  public refreshResultDurationTime: number = 600



  /*******************************加载更多配置*******************************************/
  /*true:释放加载，false下拉到一定距离加载*/
  public releaseLoad: boolean = true
  /*上拉最大距离*/
  public pullLoadMaxDistance: number = 500
  /*上拉阻力*/
  public pullLoadResistance: number = 0.5
  /*上拉距离超过多少时达到刷新条件*/
  public pullFooterHeightLoad: number = 0
  /*释放刷新时，回弹至footerView高度的时间*/
  public durationToFooter: number = 250
  /*footer布局刷新结束时回弹的时间*/
  public durationCloseFooter: number = 200
  /*刷新时是否显示footerView*/
  public loadKeepFooter: boolean = true
  /*是否显示刷新成功状态的view*/
  public loadShowSuccess: boolean = true;
  /*是否显示刷新失败状态的view*/
  public loadShowError: boolean = true;
  /*刷新结果view显示持续时间*/
  public loadResultDurationTime: number = 600
}