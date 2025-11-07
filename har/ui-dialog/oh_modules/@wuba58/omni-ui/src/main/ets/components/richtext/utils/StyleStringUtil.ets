import { LengthMetrics } from "@kit.ArkUI";
import { convertObjectToMap, parseStyle } from "./Util";
import { image } from "@kit.ImageKit";
import { http } from "@kit.NetworkKit";

/**
 * p标签属性字符串
 */
export const pTagStyleString = (content: string, length: number) => new StyledString(content, [{
  start: 0,
  length: length,
  styledKey: StyledStringKey.FONT,
  styledValue: new TextStyle({ fontColor: '#333333', fontSize: LengthMetrics.vp(14) })
}])

/**
 * u标签属性字符串
 */
export const uTagStyleString = (content: string, length: number) => new StyledString(content, [{
  start: 0,
  length: length,
  styledKey: StyledStringKey.DECORATION,
  styledValue: new DecorationStyle({
    type: TextDecorationType.LineThrough,
    color: '#000000',
    style: TextDecorationStyle.SOLID
  })
},
  {
    start: 0,
    length: length,
    styledKey: StyledStringKey.FONT,
    styledValue: new TextStyle({ fontColor: '#999999', fontSize: LengthMetrics.vp(14) })
  }
])

/**
 * br标签属性字符串
 */
export const brTagStyleString = () => new StyledString('\n')

/**
 * em标签属性字符串
 */
export const emTagStyleString = (content: string, length: number) => new StyledString(content, [{
  start: 0,
  length: length,
  styledKey: StyledStringKey.FONT,
  styledValue: new TextStyle({
    fontColor: '#333333',
    fontSize: LengthMetrics.vp(14),
    fontStyle: FontStyle.Italic
  })
}])


/**
 * b标签属性字符串
 */
export const bTagStyleString = (content: string, length: number) => new StyledString(content, [{
  start: 0,
  length: length,
  styledKey: StyledStringKey.FONT,
  styledValue: new TextStyle({
    fontColor: '#333333',
    fontSize: LengthMetrics.vp(14),
    fontWeight: FontWeight.Bold
  })
}])


/**
 * div标签属性字符串
 */
export const divTagStyleString = (content: string, length: number, attributes?: object) => {
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    //这里只解析基础样式属性，如 font-size: 16px;color: rgba(255, 255, 255, 1);font-style: italic;font-weight: bold;
    //TextStyle 只支持 fontColor?: ResourceColor;/fontFamily?: ResourceStr;/fontSize?: LengthMetrics;/fontWeight?: number | FontWeight | string;/fontStyle?: FontStyle;
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'font-size') {
          //这里应该加上对字体大小单位的解析，这里先略过
          textStyle.fontSize = LengthMetrics.vp(Number.parseInt(v))
        } else if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })

      return new StyledString(content, [{
        start: 0,
        length: length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content)
}

/**
 * i标签属性字符串
 */
export const iTagStyleString = (content: string, length: number) => {
  return new StyledString(content, [
    {
      start: 0,
      length: length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#333333',
        fontSize: LengthMetrics.vp(14),
        fontStyle: FontStyle.Italic
      })
    }
  ])
}

/**
 * a标签属性字符串
 */
export const aTagStyleString =
  (content: string, length: number, attributes?: object, onClick?: (url: string) => void) => {
    const attrMap: Map<string, string> = convertObjectToMap(attributes)
    if (attrMap.has("href")) {
      const url = attrMap.get("href")
      if (url) {
        return new StyledString(content, [
          {
            start: 0,
            length: length,
            styledKey: StyledStringKey.FONT,
            styledValue: new TextStyle({
              fontColor: Color.Blue,
              fontSize: LengthMetrics.vp(14),
            })
          }, {
          start: 0,
          length: length,
          styledKey: StyledStringKey.GESTURE,
          styledValue: new GestureStyle({
            onClick: () => {
              onClick?.(url)
            }
          })
        }])
      }
    }
    return new StyledString(content)
  }

/**
 * img标签属性字符串
 */
export const imgTagStyleString =
  (content: string, attributes?: object, callback?: ((image: ImageAttachment) => void)) => {
    const attrMap: Map<string, string> = convertObjectToMap(attributes)
    let imagePixelMap: image.PixelMap
    if (attrMap.has("src")) {
      let alt = attrMap.get("alt") //占位图逻辑，暂时先不实现
      let imgUrl = attrMap.get("src")
      let imgWidth = attrMap.get("width")
      let imgWHeight = attrMap.get("height")
      if (imgUrl) {
        //网络图片
        if (imgUrl.startsWith("http") || imgUrl.startsWith("https")) {
          try {
            let httpRequest = http.createHttp();
            httpRequest.request(imgUrl).then((response) => {
              const imageSource = image.createImageSource((response.result as ArrayBuffer).slice(0,
                (response.result as ArrayBuffer).byteLength))
              imageSource.createPixelMap({ desiredPixelFormat: image.PixelMapFormat.RGBA_8888 }).then((pixelMap) => {
                imagePixelMap = pixelMap
                const imageInfo = imagePixelMap.getImageInfoSync()
                imageSource.release()

                callback?.(new ImageAttachment({
                  value: imagePixelMap!, //这里应该兼容图片加载失败的情况，给一个默认裂开的占位图
                  size: {
                    width: imgWidth ?? imageInfo.size.width,
                    height: imgWHeight ?? imageInfo.size.height,
                  },
                  verticalAlign: ImageSpanAlignment.BASELINE,
                  layoutStyle: { borderRadius: LengthMetrics.vp(10) },
                  objectFit: ImageFit.Contain
                }))
              })
            });
            return new MutableStyledString(content)
          } catch (e) {
          }
        } else {
          //本地图片
        }
      }
    }
    return new MutableStyledString(content)
  }


const em = 16


/**
 * h1标签属性字符串
 */
export const h1TagStyledString = (content: string, attributes?: object) => {
  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(2 * em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}

/**
 * h2标签属性字符串
 */
export const h2TagStyledString = (content: string, attributes?: object) => {
  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(1.5 * em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}

/**
 * h3标签属性字符串
 */
export const h3TagStyledString = (content: string, attributes?: object) => {
  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(1.17 * em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}

/**
 * h4标签属性字符串
 */
export const h4TagStyledString = (content: string, attributes?: object) => {
  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}

/**
 * h5标签属性字符串
 */
export const h5TagStyledString = (content: string, attributes?: object) => {
  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }
  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(0.83 * em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}

/**
 * h6标签属性字符串
 *
 * attributes 除了font-size无法被覆盖其余都能覆盖
 */
export const h6TagStyledString = (content: string, attributes?: object) => {

  //优先使用自定义style
  const attrMap: Map<string, string> = convertObjectToMap(attributes)
  if (attrMap.has("style")) {
    let styles = parseStyle(attrMap.get("style"))
    if (styles) {
      let textStyle: TextStyleInterface = {}
      styles.forEach((v, k) => {
        if (k === 'color') {
          //这里得支持常见的css颜色设置
          textStyle.fontColor = v
        } else if (k === 'font-style') {
          textStyle.fontStyle = v === 'italic' ? FontStyle.Italic : FontStyle.Normal
        } else if (k === 'font-weight') {
          textStyle.fontWeight = v
        }
      })
      return new StyledString(content, [{
        start: 0,
        length: content.length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle(textStyle)
      }])
    }
  }

  return new StyledString(content, [
    {
      start: 0,
      length: content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: new TextStyle({
        fontColor: '#000000',
        fontSize: LengthMetrics.vp(0.67 * em),
        fontWeight: FontWeight.Bold
      })
    }
  ])
}