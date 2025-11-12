/**
 * Base64编码工具类
 */
export class Base64Utils {
  /**
   * 将Uint8Array转换为Base64字符串
   */
  static toBase64(data: Uint8Array): string {
    let base64 = '';
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    for (let i = 0; i < data.length; i += 3) {
      const b1 = data[i] || 0;
      const b2 = data[i + 1] || 0;
      const b3 = data[i + 2] || 0;
      const bitmap = (b1 << 16) | (b2 << 8) | b3;
      base64 += chars.charAt((bitmap >> 18) & 63);
      base64 += chars.charAt((bitmap >> 12) & 63);
      base64 += (i + 1 < data.length) ? chars.charAt((bitmap >> 6) & 63) : '=';
      base64 += (i + 2 < data.length) ? chars.charAt(bitmap & 63) : '=';
    }
    return base64;
  }
}

