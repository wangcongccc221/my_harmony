import {
  AlbumPickerOptions,
  photoAccessHelper,
  PhotoBrowserInfo,
  PickerController, PickerOptions, ReminderMode } from "@kit.MediaLibraryKit";
import { BaseItemInfo,
  ClickType,
  DataType,
  ItemInfo,
  ItemType,
  MaxCountType, PhotoBrowserRange,
  PhotoPickerComponent,
  PickerColorMode} from "@ohos.file.PhotoPickerComponent";
import { TextUtils } from "../../utils/TextUtils";


@Component
export struct OmniImagePicker {

  onFinished?: (result: Object) => void;

  goAlbumPicker?: () => void;
  // 组件初始化时设置参数信息
  pickerOptions: PickerOptions = new PickerOptions();

  // 组件初始化完成后，可控制组件部分行为
  @State pickerController: PickerController = new PickerController();

  // 已选择的图片
  @State selectUris: Array<string> = new Array<string>();

  //目前选择的图片
  @State currentUri: string = '';

  //是否显示大图
  @State isBrowserShow: boolean = true;

  @Prop
  @Watch('onAlbumInfoChang')
  currentAlbumUrl: string = ""

  onAlbumInfoChang(propName: string): void {
    if (!TextUtils.isBlank(this.currentAlbumUrl)) {
      this.pickerController.setData(DataType.SET_ALBUM_URI, this.currentAlbumUrl)

    }
  }

  private onSelect(uri: string): void {
    // 添加
    if (uri) {
      this.selectUris.push(uri);
    }
  }

  private onDeselect(uri: string): void {
    // 移除
    if (uri) {
      this.selectUris = this.selectUris.filter((item: string) => {
        return item != uri;
      })
    }
  }

  // 资源被选中回调，返回资源的信息，以及选中方式
  private onItemClicked(itemInfo: ItemInfo, clickType: ClickType): boolean {
    if (!itemInfo) {
      return false;
    }
    let type: ItemType | undefined = itemInfo.itemType;
    let uri: string | undefined = itemInfo.uri;
    if (type === ItemType.CAMERA) {
      // 点击相机item
      return true; // 返回true则拉起系统相机，若应用需要自行处理则返回false。
    } else {
      if (clickType === ClickType.SELECTED) {
        // 应用做自己的业务处理
        if (uri) {
          this.selectUris.push(uri);
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
        return true; // 返回true则勾选，否则则不响应勾选。
      } else {
        if (uri) {
          this.selectUris = this.selectUris.filter((item: string) => {
            return item != uri;
          });
          this.pickerOptions.preselectedUris = [...this.selectUris];
        }
      }
      return true;
    }
  }

  // 进入大图的回调
  private onEnterPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = true;
    return true;
  }

  // 退出大图的回调
  private onExitPhotoBrowser(photoBrowserInfo: PhotoBrowserInfo): boolean {
    this.isBrowserShow = false;
    return true;
  }

  // 接收到该回调后，便可通过pickerController相关接口向picker发送数据，在此之前不生效。
  private onPickerControllerReady(): void {
  }

  // 大图左右滑动的回调
  private onPhotoBrowserChanged(browserItemInfo: BaseItemInfo): boolean {
    this.currentUri = browserItemInfo.uri ?? '';
    return true;
  }

  // 已勾选图片被删除时的回调
  private onSelectedItemsDeleted(baseItemInfos: Array<BaseItemInfo>): void {
  }

  // 超过最大选择数量再次点击时的回调
  private onExceedMaxSelected(exceedMaxCountType: MaxCountType): void {
  }

  // 当前相册被删除时的回调
  private onCurrentAlbumDeleted(): void {
  }
  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Start
    }) {
      PhotoPickerComponent({
        pickerOptions: this.pickerOptions,
        pickerController: this.pickerController,
        onItemClicked: (itemInfo: ItemInfo, clickType: ClickType): boolean => this.onItemClicked(itemInfo, clickType),
        onEnterPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onEnterPhotoBrowser(photoBrowserInfo),
        onExitPhotoBrowser: (photoBrowserInfo: PhotoBrowserInfo): boolean => this.onExitPhotoBrowser(photoBrowserInfo),
        onPickerControllerReady: (): void => this.onPickerControllerReady(),
        onPhotoBrowserChanged: (browserItemInfo: BaseItemInfo): boolean => this.onPhotoBrowserChanged(browserItemInfo),
      })

      // 这里模拟应用侧底部的选择栏
      if (this.isBrowserShow) {
      }
      //已选择的图片缩影图
      Row() {
        // ForEach(this.selectUris, (uri: string) => {
        //   if (uri === this.currentUri) {
        //     Image(uri).height(50).width(50)
        //       .onClick(() => {
        //       })
        //       .borderWidth(1)
        //       .borderColor('red')
        //   } else {
        //     Image(uri).height(50).width(50).onClick(() => {
        //       this.pickerController.setData(DataType.SET_SELECTED_URIS, this.selectUris);
        //       this.pickerController.setPhotoBrowserItem(uri, PhotoBrowserRange.ALL);
        //     })
        //   }
        // }, (uri: string) => JSON.stringify(uri))
        Text('选择相册')
          .margin({
            left: 10,
          })
          .onClick(() => {
            this.goAlbumPicker?.()
          })
        Button('完成' + (this.selectUris.length == 0 ? "" : this.selectUris.length))
          .margin({right: 10})
          .onClick(() => {
            this.onFinished?.(this.selectUris)
          })
      }
      .width('100%')
      .height(50)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  aboutToAppear(): void {
    // 设置picker宫格页数据类型
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE // 图片和照片都显示;
    // 最大选择数量
    this.pickerOptions.maxSelectNumber = 5;
    // 超出最大选择数量时
    this.pickerOptions.maxSelectedReminderMode = ReminderMode.TOAST;
    // 是否展示搜索框，默认false
    this.pickerOptions.isSearchSupported = false;
    // 是否支持拍照，默认false
    this.pickerOptions.isPhotoTakingSupported = true;

    this.pickerOptions.isRepeatSelectSupported = false
  }
}