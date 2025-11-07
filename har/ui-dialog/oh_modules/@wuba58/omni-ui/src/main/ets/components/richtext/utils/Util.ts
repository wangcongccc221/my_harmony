/**
 * 将 style:"k:v;k:v" 解析成 map
 * @param style
 * @returns map
 */
export function parseStyle(style: string) {
  const styleMap: Map<string, string> = new Map();
  const regex = /([\w-]+)\s*:\s*([^;]+)/g;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(style)) !== null) {
    styleMap.set(match[1],match[2]);
  }
  return styleMap;
}

export function convertObjectToMap(obj: Object | undefined): Map<string, string> {
  const map = new Map<string, string>();
  if (obj != undefined) {
    for (const [key, value] of Object.entries(obj)) {
      map.set(key, `${value}`)
    }
  }
  return map
}