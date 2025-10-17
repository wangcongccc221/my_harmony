/**
 * 重量设置页面组件
 * 功能：显示重量相关的设置内容
 * 用途：在工程设置对话框的"重量设置"Tab中使用
 */

import { BaseComponentHelper } from '../../common/BaseComponent'
import { OmniThemeManager, ExtendedOmniThemeStyle } from '../../../utils/theme/OmniThemeManager'
import { IBestButton } from '@ibestservices/ibest-ui'

@Component
export struct WeightSettingsPage {
  private baseComponentHelper = new BaseComponentHelper()

  // 获取当前主题配置
  getCurrentTheme(): ExtendedOmniThemeStyle {
    return this.baseComponentHelper.getCurrentTheme()
  }

  build() {
    Row() {
      // 左边大卡片容器
      Column() {
        // 工作状态区域 - 左上角
        Row() {
          Text('工作状态：')
            .fontSize(20)  // 标签字体
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ right: 12 })
          
          // 输入框
          TextInput()
            .fontSize(18)  // 输入框字体
            .width(120)  // 宽度调小
            .height(40)
            .backgroundColor(this.getCurrentTheme().backgroundColor)
            .border({ width: 1, color: this.getCurrentTheme().borderColor })
            .borderRadius(6)
            .padding({ left: 8, right: 8 })  // 内边距调小
            .margin({ right: 12 })
          
          // 复位按钮（矩形）- 与输入框垂直对齐
          IBestButton({
            text: '复位',
            type: 'primary'
          })
            .width(80)  // 宽度80px
            .height(40)  // 高度40px
            .onClick(() => {
              // 复位按钮点击事件
              console.log('复位按钮被点击')
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)  // 垂直居中对齐
        .margin({ bottom: 20 })
        
        // 参数卡片区域 - 并排显示
        Row() {
          // 全局参数卡片
          Column() {
            // 卡片标题 - 放在边框上
            Text('全局参数')
              .fontSize(18)  // 标题字体
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().surfaceColor)  // 背景色与卡片一致
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
              .alignSelf(ItemAlign.Start)
            
            // 卡片内容区域
            Column() {
              // 这里可以添加全局参数的内容
              Text('全局参数内容')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().subTextColor)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding(8)
            .layoutWeight(1)
          }
          .width('50%')  // 宽度50%
          .height('60%')  // 高度60px
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(8)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
          .margin({ right: 12 })
          
          // 通道参数卡片
          Column() {
            // 卡片标题 - 放在边框上
            Text('通道参数')
              .fontSize(18)  // 标题字体
              .fontWeight(FontWeight.Medium)
              .fontColor(this.getCurrentTheme().textColor)
              .backgroundColor(this.getCurrentTheme().surfaceColor)  // 背景色与卡片一致
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
              .alignSelf(ItemAlign.Start)
            
            // 卡片内容区域
            Column() {
              // 这里可以添加通道参数的内容
              Text('通道参数内容')
                .fontSize(14)
                .fontColor(this.getCurrentTheme().subTextColor)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding(8)
            .layoutWeight(1)
          }
          .width('50%')  // 宽度50%
          .height('60%')  // 高度60px
          .border({ width: 1, color: this.getCurrentTheme().borderColor })
          .borderRadius(8)
          .backgroundColor(this.getCurrentTheme().surfaceColor)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 20 })
        
        // 重量参数卡片
        Column() {
          // 卡片标题 - 放在边框上
          Text('重量参数')
            .fontSize(18)  // 标题字体
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .backgroundColor(this.getCurrentTheme().surfaceColor)  // 背景色与卡片一致
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .margin({ bottom: -8 })  // 负边距让标题"浮"在边框上
            .alignSelf(ItemAlign.Start)
          
          // 卡片内容区域
          Column() {
            // 这里可以添加重量参数的内容
            Text('重量参数内容')
              .fontSize(14)
              .fontColor(this.getCurrentTheme().subTextColor)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding(8)
          .layoutWeight(1)
        }
        .width('100%')  // 宽度100%
        .height('30%')  // 高度30%
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
        .borderRadius(8)
        .backgroundColor(this.getCurrentTheme().surfaceColor)
        .alignSelf(ItemAlign.Start)  // 左对齐，对齐全局参数
        .margin({ bottom: 20 })
      }
      .width('55%')
      .height('100%')
      .padding(24)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
      
      // 右边大卡片容器
      Column() {
        // 内部大卡片 - 包含表格
        Column() {
          // 表格标题
          Text('重量数据表格')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getCurrentTheme().textColor)
            .margin({ bottom: 16 })
          
          // 简化表格
          Column() {
            // 表头
            Row() {
              Text('车号').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('果重G').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('车重G').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('AD0').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('AD1').fontSize(16).fontWeight(FontWeight.Medium).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
            }
            .width('100%').backgroundColor(this.getCurrentTheme().backgroundColor)
            
            // 数据行
            Row() {
              Text('001').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('150.5').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('2000.0').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('1024').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
              Text('512').fontSize(14).width('20%').textAlign(TextAlign.Center).border({ width: 1, color: this.getCurrentTheme().borderColor }).padding(8)
            }
            .width('100%').backgroundColor(this.getCurrentTheme().surfaceColor)
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .padding(16)
        .backgroundColor(this.getCurrentTheme().backgroundColor)
        .borderRadius(8)
        .border({ width: 1, color: this.getCurrentTheme().borderColor })
      }
      .width('45%')
      .height('100%')
      .padding(24)
      .backgroundColor(this.getCurrentTheme().surfaceColor)
      .borderRadius(12)
      .border({ width: 1, color: this.getCurrentTheme().borderColor })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
      .margin({ left: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
