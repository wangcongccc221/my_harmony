# ArkTS 知识点速查（通俗版）

## 一、装饰器（Decorators）- 给变量/函数贴标签

### 1. `@Component` - 组件标签
```typescript
@Component
export struct LevelTable {
  // 这是一个组件，可以在其他地方使用
}
```
**通俗理解**：就像给一个盒子贴上"这是一个组件"的标签，告诉系统"这是可以重复使用的UI块"

### 2. `@Prop` - 外部传入的属性
```typescript
@Prop tableName: string = 'default'
```
**通俗理解**：
- 从**父组件**传进来的数据
- 子组件**不能修改**（只读）
- 就像"别人给你的东西，你不能改，只能看"

**例子**：
```typescript
// 父组件
LevelTable({ tableName: '等级统计表' })

// 子组件收到
@Prop tableName: string  // 收到 '等级统计表'，但不能改
```

### 3. `@State` - 内部状态（会触发UI更新）
```typescript
@State private selectedCells: Set<string> = new Set()
```
**通俗理解**：
- 组件**自己管理**的数据
- **可以修改**
- 修改后**自动刷新UI**（这是关键！）

**例子**：
```typescript
@State private count: number = 0

// 修改后，UI自动更新
this.count = 5  // UI会自动重新渲染
```

### 4. `@StorageLink` - 全局状态（跨组件共享）
```typescript
@StorageLink('KEY_NAME') data: string = ''
```
**通俗理解**：
- 存在**全局仓库**（AppStorage）里的数据
- 多个组件可以**共享**
- 一个组件改了，其他组件**自动更新**

**例子**：
```typescript
// 组件A
@StorageLink('USER_NAME') name: string = ''
this.name = '张三'  // 改了

// 组件B（自动收到更新）
@StorageLink('USER_NAME') name: string = ''  // 自动变成 '张三'
```

---

## 二、数据结构

### 1. `interface` - 接口（定义数据的形状）
```typescript
interface MultiSelectState {
  cells: MultiSelectCell[]
  isActive: boolean
}
```
**通俗理解**：
- 就像"合同模板"，规定数据必须有哪些字段
- 确保数据格式正确

**例子**：
```typescript
// 定义
interface Person {
  name: string
  age: number
}

// 使用（必须符合格式）
const person: Person = {
  name: '张三',
  age: 20
  // 不能少字段，也不能多字段
}
```

### 2. `type` - 类型别名（给类型起别名）
```typescript
export type TableRow = string[]
```
**通俗理解**：
- 给复杂类型起个**简单名字**
- 方便重复使用

**例子**：
```typescript
type TableRow = string[]  // 定义

const row: TableRow = ['A级', '15', '8']  // 使用
// 等同于
const row: string[] = ['A级', '15', '8']
```

### 3. `Set` - 集合（不重复的数组）
```typescript
const selectedCells: Set<string> = new Set()
selectedCells.add('1_2')  // 添加
selectedCells.has('1_2')  // 检查是否存在
selectedCells.delete('1_2')  // 删除
```
**通俗理解**：
- 像"不重复的数组"
- 自动去重
- 查找速度快

**例子**：
```typescript
const set = new Set<string>()
set.add('A')
set.add('A')  // 重复，不会添加
set.size  // 结果是 1，不是 2
```

### 4. `Array` - 数组（列表）
```typescript
const arr: string[] = ['A', 'B', 'C']
arr.push('D')  // 添加
arr.length  // 长度
arr.map(item => item + '级')  // 转换每个元素
```
**通俗理解**：
- 有序的列表
- 可以重复
- 有顺序

---

## 三、状态管理

### 1. `AppStorage` - 全局存储（全局变量仓库）
```typescript
// 存数据
AppStorage.set('KEY', value)

// 取数据
const value = AppStorage.get('KEY')

// 删除数据
AppStorage.delete('KEY')
```
**通俗理解**：
- 像"全局变量仓库"
- 任何地方都能存取
- 用于跨组件通信

**例子**：
```typescript
// 组件A
AppStorage.set('USER_NAME', '张三')

// 组件B（任何地方）
const name = AppStorage.get('USER_NAME')  // 得到 '张三'
```

### 2. `@Watch` - 监听器（数据变化时自动执行）
```typescript
@State @Watch('onNameChange') private name: string = ''

onNameChange() {
  console.log('名字变了！')
}
```
**通俗理解**：
- 数据变化时**自动执行**某个函数
- 像"自动报警器"

---

## 四、函数相关

### 1. 回调函数（Callback）
```typescript
onClick?: () => void
```
**通俗理解**：
- 父组件传给子组件的"函数"
- 子组件在特定时机**调用**这个函数
- 像"电话回拨"

**例子**：
```typescript
// 父组件
<Button onPress={() => {
  console.log('按钮被点了！')
}} />

// 子组件内部
if (this.onPress) {
  this.onPress()  // 调用父组件传的函数
}
```

### 2. 可选参数（`?`）
```typescript
onClick?: () => void
```
**通俗理解**：
- 带 `?` 表示**可以不传**
- 不带 `?` 表示**必须传**

---

## 五、拖拽相关

### 1. `DragItemInfo` - 拖拽数据
```typescript
const dragItemInfo: DragItemInfo = {
  pixelMap: undefined,  // 图片（可选）
  builder: undefined,   // 自定义UI（可选）
  extraInfo: '数据'     // 自定义数据（常用）
}
```
**通俗理解**：
- 拖拽时携带的"包裹"
- `extraInfo` 最常用，放JSON字符串

### 2. 拖拽事件
```typescript
.onDragStart((event: DragEvent, extraParams: string): DragItemInfo => {
  // 开始拖拽时执行
  return dragItemInfo
})
.onDragEnd(() => {
  // 拖拽结束时执行
})
```
**通俗理解**：
- `onDragStart`：开始拖拽时
- `onDragEnd`：结束拖拽时

---

## 六、常用方法

### 1. `forEach` - 遍历
```typescript
this.selectedCells.forEach(cellId => {
  console.log(cellId)
})
```
**通俗理解**：
- 对每个元素执行操作
- 像"挨个处理"

### 2. `map` - 转换数组
```typescript
const newArr = arr.map(item => item + '级')
// ['A', 'B'] => ['A级', 'B级']
```
**通俗理解**：
- 把数组的每个元素**转换**成新值
- 返回新数组（不改变原数组）

### 3. `slice` - 截取数组
```typescript
const arr = [1, 2, 3, 4, 5]
arr.slice(1)  // [2, 3, 4, 5]（从索引1开始）
arr.slice(1, 3)  // [2, 3]（从索引1到3，不包含3）
```
**通俗理解**：
- 像"切蛋糕"，取一部分

### 4. `split` - 分割字符串
```typescript
const str = '1_2'
const parts = str.split('_')  // ['1', '2']
```
**通俗理解**：
- 按某个字符**分割**字符串
- 返回数组

### 5. `join` - 拼接数组
```typescript
const arr = ['A', 'B', 'C']
arr.join(',')  // 'A,B,C'
```
**通俗理解**：
- 把数组**拼接**成字符串

---

## 七、条件判断

### 1. `if-else` - 如果...否则
```typescript
if (condition) {
  // 条件为真时执行
} else {
  // 条件为假时执行
}
```

### 2. 三元运算符（简化if-else）
```typescript
const result = condition ? '真' : '假'
// 等同于
let result: string
if (condition) {
  result = '真'
} else {
  result = '假'
}
```

### 3. `?.` - 可选链（安全访问）
```typescript
const value = obj?.property?.subProperty
```
**通俗理解**：
- 如果 `obj` 是 `null` 或 `undefined`，返回 `undefined`，不报错
- 像"安全访问"

**例子**：
```typescript
const row = this.tableRows[rowIndex]?.[colIndex] || ''
// 如果 tableRows[rowIndex] 不存在，返回 ''，不报错
```

---

## 八、常用操作符

### 1. `||` - 或（默认值）
```typescript
const value = data || '默认值'
```
**通俗理解**：
- 如果 `data` 是 `null/undefined/''`，用 `'默认值'`

### 2. `&&` - 与（条件执行）
```typescript
condition && doSomething()
```
**通俗理解**：
- 如果 `condition` 为真，执行 `doSomething()`

### 3. `===` - 严格相等
```typescript
if (a === b) { }
```
**通俗理解**：
- 值和类型都相等
- 推荐用 `===`，不用 `==`

---

## 九、JSON 操作

### 1. `JSON.stringify` - 对象转字符串
```typescript
const obj = { name: '张三', age: 20 }
const str = JSON.stringify(obj)  // '{"name":"张三","age":20}'
```

### 2. `JSON.parse` - 字符串转对象
```typescript
const str = '{"name":"张三","age":20}'
const obj = JSON.parse(str)  // { name: '张三', age: 20 }
```

---

## 十、常见问题

### Q1: `@Prop` 和 `@State` 的区别？
- **@Prop**：外部传入，只读，不能改
- **@State**：内部管理，可改，改后自动刷新UI

### Q2: 什么时候用 `AppStorage`？
- 需要**跨组件共享**数据时
- 比如：主题切换、用户信息、全局状态

### Q3: `interface` 和 `type` 的区别？
- **interface**：可以扩展（`extends`），适合定义对象
- **type**：可以定义联合类型，适合定义简单类型别名
- 大部分情况下可以互换

### Q4: 为什么用 `Set` 不用 `Array`？
- `Set` 自动去重
- `Set.has()` 查找速度快
- 适合"选中状态"这种场景

---

## 快速记忆口诀

1. **@Prop** = 外部给，不能改
2. **@State** = 自己管，能改，改后刷新
3. **@StorageLink** = 全局共享，一处改，处处变
4. **interface** = 数据模板，规定格式
5. **Set** = 不重复的数组，查找快
6. **AppStorage** = 全局仓库，跨组件通信

---

## 实战例子

### 例子1：组件通信
```typescript
// 父组件
@Component
struct Parent {
  @State count: number = 0
  
  build() {
    Child({ count: this.count })  // 传给子组件
  }
}

// 子组件
@Component
struct Child {
  @Prop count: number  // 接收，但不能改
  
  build() {
    Text(`${this.count}`)  // 显示
  }
}
```

### 例子2：全局状态
```typescript
// 组件A
AppStorage.set('THEME', 'dark')

// 组件B
@StorageLink('THEME') theme: string = 'light'
// theme 自动变成 'dark'
```

### 例子3：拖拽数据传递
```typescript
// 拖拽开始
.onDragStart(() => {
  const data = { type: 'cell', value: 'A级' }
  return {
    extraInfo: JSON.stringify(data)  // 转成字符串
  }
})

// 拖拽接收
.onDrop((event: DragEvent) => {
  const dataStr = event.extraInfo
  const data = JSON.parse(dataStr)  // 转回对象
  console.log(data.value)  // 'A级'
})
```

---

**记住**：看不懂就多看几遍，或者直接问我具体哪里不懂！😊

