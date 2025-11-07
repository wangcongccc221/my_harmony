# UI Dialog HAR 模块

通用对话框组件HAR模块，提供可复用的对话框组件。

## 📦 组件列表

- **BaseDialog**: 基础对话框组件，提供统一的对话框容器和布局
- **DialogButtons**: 对话框按钮组件，提供统一的对话框底部按钮样式

## 🚀 使用方法

### 1. 安装依赖

在 `oh-package.json5` 中添加依赖：

```json5
{
  "dependencies": {
    "ui-dialog": "file:../har/ui-dialog"
  }
}
```

### 2. 导入组件

```typescript
import { BaseDialog, DialogButtons, IThemeManager, ThemeStyle } from 'ui_dialog'
```

### 3. 使用 BaseDialog

```typescript
// 创建主题适配器（将你的主题管理器适配为IThemeManager接口）
import { ThemeAdapter } from '../utils/theme/ThemeAdapter'

@Entry
@Component
struct MyPage {
  @State isDialogVisible: boolean = false
  private themeAdapter = ThemeAdapter.getInstance()

  build() {
    Column() {
      Button('打开对话框')
        .onClick(() => {
          this.isDialogVisible = true
        })

      // 使用BaseDialog
      BaseDialog({
        isVisible: this.isDialogVisible,
        title: '提示',
        themeManager: this.themeAdapter,
        onConfirm: () => {
          console.log('确认')
          this.isDialogVisible = false
        },
        onCancel: () => {
          console.log('取消')
          this.isDialogVisible = false
        },
        onMaskClick: () => {
          this.isDialogVisible = false
        }
      }) {
        // 对话框内容
        Column() {
          Text('这是对话框内容')
            .fontSize(16)
            .fontColor('#333333')
        }
        .padding(20)
      }
    }
  }
}
```

### 4. 使用 DialogButtons

```typescript
DialogButtons({
  confirmText: '确认',
  cancelText: '取消',
  showCancel: true,
  confirmDisabled: false,
  themeManager: this.themeAdapter,
  onConfirm: () => {
    console.log('确认')
  },
  onCancel: () => {
    console.log('取消')
  }
})
```

## 🎨 主题支持

HAR模块通过 `IThemeManager` 接口支持主题。你需要创建一个适配器将你的主题管理器适配为 `IThemeManager` 接口。

### 主题接口定义

```typescript
export interface ThemeStyle {
  primary: string
  backgroundColor: string
  surfaceColor: string
  textColor: string
  subTextColor: string
  borderColor: string
}

export interface IThemeManager {
  getCurrentTheme(): ThemeStyle
}
```

### 创建主题适配器示例

```typescript
import { IThemeManager, ThemeStyle } from 'ui_dialog'
import { OmniThemeManager } from '../utils/theme/OmniThemeManager'

export class ThemeAdapter implements IThemeManager {
  private omniThemeManager = OmniThemeManager.getInstance()

  getCurrentTheme(): ThemeStyle {
    const omniTheme = this.omniThemeManager.getCurrentTheme()
    return {
      primary: omniTheme.primary,
      backgroundColor: omniTheme.backgroundColor,
      surfaceColor: omniTheme.surfaceColor,
      textColor: omniTheme.textColor,
      subTextColor: omniTheme.subTextColor,
      borderColor: omniTheme.borderColor
    }
  }

  static getInstance(): ThemeAdapter {
    return new ThemeAdapter()
  }
}
```

## 📝 组件属性

### BaseDialog

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| isVisible | boolean | false | 是否显示对话框 |
| title | string | '' | 对话框标题 |
| dialogWidth | string \| Length | '80%' | 对话框宽度（注意：使用dialogWidth避免与组件width方法冲突） |
| maxWidth | number | 500 | 最大宽度 |
| maxHeight | number | 600 | 最大高度 |
| showCancel | boolean | true | 是否显示取消按钮 |
| confirmText | string | '确认' | 确认按钮文字 |
| cancelText | string | '取消' | 取消按钮文字 |
| confirmDisabled | boolean | false | 确认按钮是否禁用 |
| themeManager | IThemeManager? | undefined | 主题管理器 |
| onConfirm | () => void | - | 确认回调 |
| onCancel | () => void | - | 取消回调 |
| onMaskClick | () => void | - | 遮罩点击回调 |
| content | @BuilderParam | - | 对话框内容插槽 |

### DialogButtons

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| confirmText | string | '确认' | 确认按钮文字 |
| cancelText | string | '取消' | 取消按钮文字 |
| showCancel | boolean | true | 是否显示取消按钮 |
| confirmDisabled | boolean | false | 确认按钮是否禁用 |
| themeManager | IThemeManager? | undefined | 主题管理器 |
| onConfirm | () => void | - | 确认回调 |
| onCancel | () => void | - | 取消回调 |

## 📄 许可证

Apache-2.0

