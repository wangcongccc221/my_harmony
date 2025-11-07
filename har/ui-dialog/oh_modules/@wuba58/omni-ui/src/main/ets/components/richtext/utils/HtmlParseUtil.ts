import * as htmlparser2 from "@ohos/htmlparser2";
import { JSON } from "@kit.ArkTS";

/**
 * 常用的html标签
 *
 文本格式化标签：

 <b>：定义粗体文本。 (已支持)
 <i>：定义斜体文本。 (已支持)
 <u>：定义下划线文本。 (已支持)
 <strong>：定义重要文本。
 <em>：定义强调文本。 (已支持)
 <small>：定义小号文本。
 <sub>：定义下标文本。
 <sup>：定义上标文本。
 链接和图片：

 <a>：定义超链接。 (已支持)
 <img>：定义图片。 (已支持)
 列表：

 <ul>：定义无序列表。
 <ol>：定义有序列表。
 <li>：定义列表项。
 表格：

 <table>：定义表格。
 <tr>：定义表格行。
 <th>：定义表格头单元格。
 <td>：定义表格数据单元格。
 表单：

 <form>：定义表单。
 <input>：定义输入控件。
 <select>：定义下拉列表。
 <option>：定义下拉列表的选项。
 <textarea>：定义文本区域。
 块级元素：

 <div>：定义一个块级元素。 (已支持)
 <p>：定义一个段落。 (已支持)
 <h1> 到 <h6>：定义标题。 (已支持)
 内联元素：

 <span>：定义一个内联元素。
 *
 * @param htmlStr
 * @returns
 */
export function parseHtml(htmlStr: string) {
  // 创建一个映射表来存储标签内容
  const tagContentMap = {};
  const keyStack = new Stack<string>()
  const flatmapList = []
  let counter = 0;
  const parser = new htmlparser2.Parser({
    onopentag(name, attributes) {
      //script标签应该略过
      if (name === "script" && attributes.type === "text/javascript") {
        return
      }
      keyStack.push(name)
      tagContentMap[name] = tagContentMap[name] || [];
      tagContentMap[name].push({ name, attributes, children: [] });
    },
    ontext(text) {
      // 将文本内容添加到当前标签的子节点中
      if (Object.keys(keyStack).length > 0) {
        const currentTag = keyStack.peek();
        if (currentTag) {
          const textLength = tagNeedBreakLine(currentTag) ? text.length + 2 : text.length
          tagContentMap[currentTag][tagContentMap[currentTag].length - 1].children.push({ counter, text, textLength });
        }else{
          const name = 'no_tag'
          //无tag内容
          tagContentMap[name] = tagContentMap[name] || [];
          tagContentMap[name].push({ name, children: [] });
          const textLength = text.length
          tagContentMap[name][tagContentMap[name].length-1].children.push({ counter, text, textLength });
        }
      }
      counter++
    },
    onclosetag(tagname) {
      if (tagname === "script") {
        return
      }
      keyStack.pop()
      if (tagNeedPlaceholder(tagname)) { //br标签没有内容，需要填充占位内容
        tagContentMap[tagname][tagContentMap[tagname].length - 1].children.push({ counter, text: '' });
        counter++
      } else if (tagNeedBreakLine(tagname)) { //p标签需要添加换行符
        const pList = tagContentMap[tagname][tagContentMap[tagname].length - 1].children
        pList[pList.length-1].text = '\n' + pList[pList.length-1].text +'\n'
      }
    },
    onend() {
      Object.keys(tagContentMap).forEach(key => {
        tagContentMap[key].forEach(item => {
          item.children.forEach(child => {
            flatmapList.push({
              position: child.counter,
              content: child.text,
              tag: item.name,
              attributes: item.attributes,
              textLength:child.textLength
            });
          });
        });
      });

      flatmapList.sort((a, b) => {
        const positionA = a.position || 0;
        const positionB = b.position || 0;
        return positionA - positionB;
      })
    }
  });
  parser.write(htmlStr);
  parser.end();

  return JSON.stringify(flatmapList);
}


/**
 * 标签需要占位
 * @param tagName
 * @returns
 */
function tagNeedPlaceholder(tagName: string) {
  return tagName === 'br' || tagName === 'img'
}

/**
 * 标签需要换行
 * @param tagName
 * @returns
 */
function tagNeedBreakLine(tagName: string) {
  return tagName === 'p' || tagName === 'h1' || tagName === 'h2' || tagName === 'h3' || tagName === 'h4' ||
    tagName === 'h5' || tagName === 'h6'
}

class Stack<T> {
  private items: T[] = [];

  push(item: T): void {
    this.items.push(item);
  }

  pop(): T | undefined {
    return this.items.pop();
  }

  peek(): T | undefined {
    return this.items[this.items.length - 1];
  }

  isEmpty(): boolean {
    return this.items.length === 0;
  }

  size(): number {
    return this.items.length;
  }

  clear(): void {
    this.items = [];
  }

  toString(): string {
    return this.items.toString();
  }
}