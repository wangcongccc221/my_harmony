# 数据库使用说明（RDB / SQLite）

本文档说明如何在本项目中使用已封装的数据库服务 `ArkDataDemoService`（基于 `@ohos.data.relationalStore`）。

参考：HarmonyOS ArkData/RDB 实战与最佳实践（含 CRUD 示例）[华为开发者博客](https://developer.huawei.com/consumer/cn/blog/topic/03176721032796068)

---

## 1. 快速开始

- 服务文件：`entry/src/main/ets/db/ArkDataDemo.ets`
- 已在 `EntryAbility.onCreate` 初始化：
  - `ArkDataDemoService.init(this.context)`
  - 默认建表：`ArkDataDemoService.createUsersTable()`

如需在其它 Ability/页面初始化（一般不用重复）：
```ts
import { ArkDataDemoService } from '../db/ArkDataDemo';
ArkDataDemoService.init(getContext(this));
```

---

## 2. 建表（Create Table）

- 已内置示例表 `users`：
  - 字段：`id INTEGER PRIMARY KEY AUTOINCREMENT`, `name TEXT NOT NULL`, `age INTEGER`
- 直接调用：
```ts
await ArkDataDemoService.createUsersTable();
```

- 如需新增你的业务表：在 `ArkDataDemo.ets` 内仿照实现一个方法：
```ts
static async createMyTable(): Promise<void> {
  const store = await ArkDataDemoService.getStore();
  const sql = `CREATE TABLE IF NOT EXISTS my_table(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    createdAt INTEGER
  )`;
  await store.executeSql(sql, []);
}
```
> 注意：ArkTS 不支持在 catch 中使用类型注解；抛错请用 `throw new Error(message)`。

---

## 3. 增删改查（CRUD）示例

- 插入（Insert）
```ts
import { ArkDataDemoService } from '../../db/ArkDataDemo';
await ArkDataDemoService.insertUser('张三', 25);
```

- 查询（Query）
```ts
const rows = await ArkDataDemoService.queryAllUsers();
// rows: Array<{ id: number; name: string; age: number }>
```

- 更新（Update）
```ts
await ArkDataDemoService.updateUserAgeByName('张三', 26);
```

- 删除（Delete）
```ts
await ArkDataDemoService.deleteUserByName('张三');
```

- 自定义 SQL（可在服务类里新增封装方法）
```ts
static async queryUsersByAge(minAge: number) {
  const store = await ArkDataDemoService.getStore();
  const rs = await store.querySql('SELECT id, name, age FROM users WHERE age >= ?', [minAge]);
  const out: Array<{ id: number; name: string; age: number }> = [];
  let ok = rs.goToFirstRow();
  while (ok) {
    out.push({ id: Number(rs.getLong(0)), name: rs.getString(1), age: Number(rs.getLong(2)) });
    ok = rs.goToNextRow();
  }
  rs.close();
  return out;
}
```

---

## 4. 在页面中调用（示例）
```ts
import { ArkDataDemoService } from '../../db/ArkDataDemo';

@Entry
@Component
struct DemoPage {
  @State log: string = '';

  aboutToAppear() {
    ArkDataDemoService.createUsersTable()
      .then(() => this.append('create ok'))
      .catch(e => this.append('create err: ' + e));
  }

  private append(msg: string) {
    this.log += (msg + '\n');
  }

  build() {
    Column() {
      Button('插入张三').onClick(async () => {
        try {
          await ArkDataDemoService.insertUser('张三', 25);
          this.append('insert ok');
        } catch (e) {
          this.append('insert err: ' + e);
        }
      });

      Button('查询全部').onClick(async () => {
        try {
          const rows = await ArkDataDemoService.queryAllUsers();
          this.append(JSON.stringify(rows));
        } catch (e) {
          this.append('query err: ' + e);
        }
      });

      Text(this.log).fontSize(12).lineHeight(16).width('100%');
    }
  }
}
```

---

## 5. 注意事项与最佳实践
- 初始化只需一次：建议在 `EntryAbility.onCreate` 中调用 `init`。
- 抛错规范：只抛出 `Error` 实例；`catch` 中不要写类型注解。
- 结果集释放：`ResultSet` 用完务必 `close()`，已在示例中演示。
- SQL 占位符：统一使用 `?` 与参数数组，避免拼接注入风险。
- 表结构升级：建议在打开数据库后做版本检查，按需 `ALTER TABLE`。

---

## 6. FAQ
- 需要权限吗？
  - 本地沙箱 SQLite 不需要额外存储权限。
- 为什么我在其它设备上访问不到？
  - 与数据库无关，HTTP 访问需网络连通、防火墙放行与端口转发设置正确。

---

以上即可满足“怎么用、怎么调 API”的常见诉求。若你要新增多张业务表，建议复制 `createUsersTable/CRUD` 的写法封装到一个新的 Service 文件中。


