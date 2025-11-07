export function isVideoFormat(url: string) {
  return url.endsWith(".mp4") || url.endsWith(".avi") || url.endsWith(".mov") || url.endsWith(".m4v") ||
  url.endsWith(".wmv")
}