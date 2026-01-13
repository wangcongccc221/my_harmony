/**
 * 设备状态面板组件
 * 显示FSM/IPM设备的连接状态
 * 对应48项目的设备监控区域
 */

import {
  GlobalDataInterface,
  getGlobalDataInterface,
  DeviceStatusListener
} from '../../protocol/GlobalDataInterface'
import { StFsmStatus } from '../../protocol/Structures'
import { ConstPreDefine } from '../../protocol/ConstPreDefine'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../utils/theme/OmniThemeManager'
import { getCurrentTheme } from '../../utils/theme/ThemeUtils'
import { AppleDesignStyle } from '../../utils/theme/AppleDesignStyle'

/**
 * 设备显示数据
 */
interface DeviceDisplayData {
  id: number
  name: string
  ipAddress: string
  online: boolean
  version: string
  lastHeartbeat: number
}

/**
 * 设备状态面板组件
 */
@Component
export struct DeviceStatusPanel {
  @State private devices: DeviceDisplayData[] = []
  @State private onlineCount: number = 0
  @State private totalCount: number = 0

  private dataInterface: GlobalDataInterface = getGlobalDataInterface()
  private deviceStatusListener: DeviceStatusListener | null = null

  getCurrentTheme(): ExtendedOmniThemeStyle {
    return getCurrentTheme(OmniThemeManager.getInstance().getCurrentTheme())
  }

  aboutToAppear(): void {
    // 获取初始设备状态
    this.updateDeviceList()

    // 注册设备状态监听器
    this.deviceStatusListener = (deviceMap: Map<number, StFsmStatus>) => {
      this.updateDeviceList()
    }
    this.dataInterface.addDeviceStatusListener(this.deviceStatusListener)
  }

  aboutToDisappear(): void {
    if (this.deviceStatusListener) {
      this.dataInterface.removeDeviceStatusListener(this.deviceStatusListener)
      this.deviceStatusListener = null
    }
  }

  /**
   * 更新设备列表
   */
  private updateDeviceList(): void {
    const deviceMap = this.dataInterface.getAllDeviceStatus()
    const devices: DeviceDisplayData[] = []
    let online = 0

    deviceMap.forEach((status: StFsmStatus, deviceId: number) => {
      devices.push({
        id: deviceId,
        name: `FSM-${status.subsysIndex + 1}`,
        ipAddress: status.ipAddress,
        online: status.online,
        version: status.version || '未知',
        lastHeartbeat: status.lastHeartbeat
      })

      if (status.online) online++
    })

    // 按ID排序
    devices.sort((a, b) => a.id - b.id)

    this.devices = devices
    this.onlineCount = online
    this.totalCount = devices.length
  }

  /**
   * 格式化最后心跳时间
   */
  private formatLastHeartbeat(timestamp: number): string {
    if (timestamp === 0) return '从未'

    const now = Date.now()
    const diff = Math.floor((now - timestamp) / 1000)

    if (diff < 60) return `${diff}秒前`
    if (diff < 3600) return `${Math.floor(diff / 60)}分钟前`
    return `${Math.floor(diff / 3600)}小时前`
  }

  build() {
    Column({ space: 12 }) {
      // 标题行
      Row() {
        Text('🖥️ 设备状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCurrentTheme().textColor)
          .layoutWeight(1)

        Row({ space: 8 }) {
          Circle()
            .width(10)
            .height(10)
            .fill(this.onlineCount > 0 ? '#4CAF50' : '#F44336')

          Text(`${this.onlineCount}/${this.totalCount} 在线`)
            .fontSize(12)
            .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
        }
      }
      .width('100%')

      // 设备列表
      if (this.devices.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.devices, (device: DeviceDisplayData) => {
            Row() {
              // 状态指示灯
              Circle()
                .width(12)
                .height(12)
                .fill(device.online ? '#4CAF50' : '#F44336')
                .margin({ right: 12 })

              // 设备信息
              Column({ space: 4 }) {
                Text(device.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getCurrentTheme().textColor)

                Text(`${device.ipAddress} | 版本: ${device.version}`)
                  .fontSize(11)
                  .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              // 最后心跳
              Column() {
                Text(device.online ? '在线' : '离线')
                  .fontSize(12)
                  .fontColor(device.online ? '#4CAF50' : '#F44336')

                Text(this.formatLastHeartbeat(device.lastHeartbeat))
                  .fontSize(10)
                  .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(device.online ?
              (this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor) :
              '#FFEBEE')
            .borderRadius(8)
            .border({ width: 1, color: device.online ? this.getCurrentTheme().borderColor : '#FFCDD2' })
          })
        }
        .width('100%')
      } else {
        // 无设备
        Column({ space: 8 }) {
          Text('📡')
            .fontSize(32)

          Text('暂无设备连接')
            .fontSize(14)
            .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)

          Text('等待下位机连接...')
            .fontSize(12)
            .fontColor(this.getCurrentTheme().subTextColor ?? this.getCurrentTheme().textColor)
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
        .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getCurrentTheme().surfaceColor ?? this.getCurrentTheme().backgroundColor)
    .borderRadius(AppleDesignStyle.BORDER_RADIUS_MEDIUM)
    .border({ width: 1, color: this.getCurrentTheme().borderColor })
  }
}
