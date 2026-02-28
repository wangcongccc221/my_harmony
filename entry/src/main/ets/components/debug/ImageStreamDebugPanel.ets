import { ImageFrameSnapshot, parseImageFrameSnapshotJson } from '../../protocol/ImageStreamService'

@Component
export struct ImageStreamDebugPanel {
  @StorageLink('IMAGE_STREAM_FRAME_VERSION') frameVersion: number = 0
  @StorageLink('IMAGE_STREAM_FRAME_JSON') frameJson: string = ''

  @Prop title: string = '图像链路调试'
  @Prop compact: boolean = false

  private getSnapshot(): ImageFrameSnapshot {
    return parseImageFrameSnapshotJson(this.frameJson)
  }

  private formatTime(ts: number): string {
    if (!ts || ts <= 0) {
      return '--'
    }
    const d = new Date(ts)
    const hh = `${d.getHours()}`.padStart(2, '0')
    const mm = `${d.getMinutes()}`.padStart(2, '0')
    const ss = `${d.getSeconds()}`.padStart(2, '0')
    return `${hh}:${mm}:${ss}`
  }

  build() {
    Column({ space: this.compact ? 6 : 10 }) {
      Text(this.title)
        .fontSize(this.compact ? 14 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')

      Text(`帧序号: ${this.getSnapshot().receiveCount}`)
        .fontSize(this.compact ? 12 : 13)
        .fontColor('#D0D7FF')
        .width('100%')
      Text(`命令: 0x${this.getSnapshot().cmdId.toString(16)} ${this.getSnapshot().cmdName}`)
        .fontSize(this.compact ? 12 : 13)
        .fontColor('#D0D7FF')
        .width('100%')
      Text(`来源: 0x${this.getSnapshot().srcId.toString(16)}  长度: ${this.getSnapshot().length}`)
        .fontSize(this.compact ? 12 : 13)
        .fontColor('#D0D7FF')
        .width('100%')
      Text(`时间: ${this.formatTime(this.getSnapshot().timestamp)}`)
        .fontSize(this.compact ? 12 : 13)
        .fontColor('#D0D7FF')
        .width('100%')

      Text('前64字节')
        .fontSize(this.compact ? 12 : 13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#9CC3FF')
        .width('100%')
      Text(this.getSnapshot().previewHex.length > 0 ? this.getSnapshot().previewHex : '--')
        .fontSize(this.compact ? 11 : 12)
        .fontColor('#F5F7FF')
        .width('100%')
        .maxLines(this.compact ? 4 : 6)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text('尾32字节')
        .fontSize(this.compact ? 12 : 13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#9CC3FF')
        .width('100%')
      Text(this.getSnapshot().tailHex.length > 0 ? this.getSnapshot().tailHex : '--')
        .fontSize(this.compact ? 11 : 12)
        .fontColor('#F5F7FF')
        .width('100%')
        .maxLines(this.compact ? 3 : 5)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(this.compact ? 10 : 14)
    .backgroundColor('#111827')
    .borderRadius(8)
  }
}
