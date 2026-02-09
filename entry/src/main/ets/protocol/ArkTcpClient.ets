import socket from '@ohos.net.socket'

export async function tcpSendOnce(ip: string, port: number, payload: ArrayBuffer, timeoutMs: number = 1200): Promise<boolean> {
  const client = socket.constructTCPSocketInstance()
  try {
    await client.connect({ address: { address: ip, port }, timeout: timeoutMs })
    await client.send({ data: payload })
    await client.close()
    return true
  } catch (_) {
    try {
      await client.close()
    } catch (_) {}
    return false
  }
}

