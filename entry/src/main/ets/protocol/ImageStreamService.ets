import { IPM_HC_COMMAND_TYPE } from './CommandTypes'

export class ImageFrameSnapshot {
  timestamp: number = 0
  receiveCount: number = 0
  portName: string = ''
  cmdId: number = 0
  cmdName: string = ''
  srcId: number = 0
  length: number = 0
  previewHex: string = ''
  tailHex: string = ''
}

interface ImageFrameSnapshotRecord {
  timestamp?: number
  receiveCount?: number
  portName?: string
  cmdId?: number
  cmdName?: string
  srcId?: number
  length?: number
  previewHex?: string
  tailHex?: string
}

export type ImageStreamListener = (snapshot: ImageFrameSnapshot) => void

const IMAGE_FRAME_VERSION_KEY = 'IMAGE_STREAM_FRAME_VERSION'
const IMAGE_FRAME_JSON_KEY = 'IMAGE_STREAM_FRAME_JSON'

export class ImageStreamService {
  private static instance: ImageStreamService | null = null

  private readonly listeners: Set<ImageStreamListener> = new Set()
  private latestSnapshot: ImageFrameSnapshot = new ImageFrameSnapshot()
  private receiveCount: number = 0

  static getInstance(): ImageStreamService {
    if (!ImageStreamService.instance) {
      ImageStreamService.instance = new ImageStreamService()
    }
    return ImageStreamService.instance
  }

  private constructor() {
    AppStorage.setOrCreate(IMAGE_FRAME_VERSION_KEY, 0)
    AppStorage.setOrCreate(IMAGE_FRAME_JSON_KEY, this.stringifySnapshot(this.latestSnapshot))
  }

  addListener(listener: ImageStreamListener): void {
    this.listeners.add(listener)
  }

  removeListener(listener: ImageStreamListener): void {
    this.listeners.delete(listener)
  }

  getLatestSnapshot(): ImageFrameSnapshot {
    const next = new ImageFrameSnapshot()
    next.timestamp = this.latestSnapshot.timestamp
    next.receiveCount = this.latestSnapshot.receiveCount
    next.portName = this.latestSnapshot.portName
    next.cmdId = this.latestSnapshot.cmdId
    next.cmdName = this.latestSnapshot.cmdName
    next.srcId = this.latestSnapshot.srcId
    next.length = this.latestSnapshot.length
    next.previewHex = this.latestSnapshot.previewHex
    next.tailHex = this.latestSnapshot.tailHex
    return next
  }

  handleIncomingFrame(portName: string, cmdId: number, srcId: number, data: Uint8Array): void {
    this.receiveCount += 1
    const snapshot = new ImageFrameSnapshot()
    snapshot.timestamp = Date.now()
    snapshot.receiveCount = this.receiveCount
    snapshot.portName = portName
    snapshot.cmdId = cmdId
    snapshot.cmdName = this.resolveCmdName(cmdId)
    snapshot.srcId = srcId
    snapshot.length = data.byteLength
    snapshot.previewHex = this.toHexPreview(data, 64)
    snapshot.tailHex = this.toHexTail(data, 32)
    this.latestSnapshot = snapshot

    const currentVersion = (AppStorage.get(IMAGE_FRAME_VERSION_KEY) as number | undefined) ?? 0
    AppStorage.setOrCreate(IMAGE_FRAME_VERSION_KEY, currentVersion + 1)
    AppStorage.setOrCreate(IMAGE_FRAME_JSON_KEY, this.stringifySnapshot(snapshot))

    console.log(`[IMAGE_STREAM] frame#${snapshot.receiveCount} cmd=0x${cmdId.toString(16)}(${snapshot.cmdName}) src=0x${srcId.toString(16)} len=${snapshot.length}`)
    console.log(`[IMAGE_STREAM] preview64=${snapshot.previewHex}`)
    console.log(`[IMAGE_STREAM] tail32=${snapshot.tailHex}`)

    this.listeners.forEach((listener: ImageStreamListener) => {
      try {
        listener(this.getLatestSnapshot())
      } catch (e) {
        console.error('[IMAGE_STREAM] notify failed:', JSON.stringify(e))
      }
    })
  }

  private stringifySnapshot(snapshot: ImageFrameSnapshot): string {
    return JSON.stringify({
      timestamp: snapshot.timestamp,
      receiveCount: snapshot.receiveCount,
      portName: snapshot.portName,
      cmdId: snapshot.cmdId,
      cmdName: snapshot.cmdName,
      srcId: snapshot.srcId,
      length: snapshot.length,
      previewHex: snapshot.previewHex,
      tailHex: snapshot.tailHex
    })
  }

  private resolveCmdName(cmdId: number): string {
    switch (cmdId) {
      case IPM_HC_COMMAND_TYPE.IPM_CMD_IMAGE:
        return 'IPM_CMD_IMAGE'
      case IPM_HC_COMMAND_TYPE.IPM_CMD_AUTOBALANCE_COEFFICIENT:
        return 'IPM_CMD_AUTOBALANCE_COEFFICIENT'
      case IPM_HC_COMMAND_TYPE.IPM_CMD_IMAGE_SPLICE:
        return 'IPM_CMD_IMAGE_SPLICE'
      case IPM_HC_COMMAND_TYPE.IPM_CMD_IMAGE_SPOT:
        return 'IPM_CMD_IMAGE_SPOT'
      case IPM_HC_COMMAND_TYPE.IPM_CMD_SHUTTER_ADJUST:
        return 'IPM_CMD_SHUTTER_ADJUST'
      default:
        return 'UNKNOWN'
    }
  }

  private toHexPreview(view: Uint8Array, bytes: number): string {
    const count = Math.min(bytes, view.length)
    const parts: string[] = []
    for (let i = 0; i < count; i++) {
      parts.push(view[i].toString(16).padStart(2, '0'))
    }
    return parts.join(' ')
  }

  private toHexTail(view: Uint8Array, bytes: number): string {
    if (view.length <= 0) {
      return ''
    }
    const start = Math.max(0, view.length - bytes)
    const parts: string[] = []
    for (let i = start; i < view.length; i++) {
      parts.push(view[i].toString(16).padStart(2, '0'))
    }
    return parts.join(' ')
  }
}

export function getImageStreamService(): ImageStreamService {
  return ImageStreamService.getInstance()
}

export function parseImageFrameSnapshotJson(json: string): ImageFrameSnapshot {
  const snapshot = new ImageFrameSnapshot()
  if (!json || json.trim().length === 0) {
    return snapshot
  }
  try {
    const parsed = JSON.parse(json) as ImageFrameSnapshotRecord
    snapshot.timestamp = parsed.timestamp ?? 0
    snapshot.receiveCount = parsed.receiveCount ?? 0
    snapshot.portName = parsed.portName ?? ''
    snapshot.cmdId = parsed.cmdId ?? 0
    snapshot.cmdName = parsed.cmdName ?? ''
    snapshot.srcId = parsed.srcId ?? 0
    snapshot.length = parsed.length ?? 0
    snapshot.previewHex = parsed.previewHex ?? ''
    snapshot.tailHex = parsed.tailHex ?? ''
  } catch (_) {
    return snapshot
  }
  return snapshot
}
