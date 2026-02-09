import { taskpool } from '@kit.ArkTS'
import { NativeModule } from '../utils/native/NativeModule'

@Concurrent
export function tcpSendOnce(ip: string, port: number, payload: ArrayBuffer): boolean {
  try {
    const bytes = new Uint8Array(payload)
    NativeModule.tcpClientDestroy()
    const ok = NativeModule.tcpClientConnect(ip, port, (_resp) => {})
    if (!ok) return false
    return NativeModule.tcpClientSend(bytes)
  } catch (_) {
    return false
  }
}

export function createTcpSendTask(ip: string, port: number, payload: ArrayBuffer): taskpool.Task {
  const task: taskpool.Task = new taskpool.Task(tcpSendOnce, ip, port, payload)
  task.setTransferList([payload])
  return task
}

