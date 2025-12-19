/**
 * 波形捕捉页面
 * 功能：显示从下位机接收的真实波形数据
 * 
 * 数据来源：
 * - FSM_CMD_WAVEINFO (0x1004) 命令
 * - StWaveInfo 结构体
 * - waveform0: AD0通道波形数据（256个采样点）
 * - waveform1: AD1通道波形数据（256个采样点）
 * - fruitweight: 水果重量
 */

import { StWaveInfo, WAVE_POINT_COUNT } from '../../utils/network/tcp/types/StWaveInfo';

@Component
export struct WaveCapturePage {
  @State private waveInfoList: StWaveInfo[] = [];
  @State private selectedChannelId: number = 0;
  @State private currentWaveIndex: number = 0;
  @State private canvasKey: number = 0; // 用于强制Canvas重新渲染
  @StorageLink('TCP_WAVEINFO_UPDATE') @Watch('onWaveInfoUpdate') private waveInfoUpdate: number = 0;

  aboutToAppear() {
    this.loadWaveInfoList();
  }

  onWaveInfoUpdate() {
    console.log(`[WaveCapturePage] 波形数据更新，当前索引: ${this.currentWaveIndex}, 列表长度: ${this.waveInfoList.length}`);
    this.loadWaveInfoList();
    // 如果有新数据，自动切换到最新的
    if (this.waveInfoList.length > 0) {
      this.currentWaveIndex = this.waveInfoList.length - 1;
      // 强制Canvas重新渲染
      this.canvasKey = Date.now();
    }
  }

  private loadWaveInfoList() {
    const list = AppStorage.get<StWaveInfo[]>('waveInfoList') || [];
    console.log(`[WaveCapturePage] 加载波形数据列表，数量: ${list.length}`);
    this.waveInfoList = list;
    
    // 如果有数据，显示最新的
    if (this.waveInfoList.length > 0) {
      if (this.currentWaveIndex >= this.waveInfoList.length) {
        this.currentWaveIndex = this.waveInfoList.length - 1;
      }
      console.log(`[WaveCapturePage] 当前显示索引: ${this.currentWaveIndex}, 通道ID: ${this.waveInfoList[this.currentWaveIndex].nChannelId}`);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('波形捕捉')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16, top: 16, bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#F5F5F5')

      // 控制栏
      Row() {
        Text(`数据总数: ${this.waveInfoList.length}`)
          .fontSize(14)
          .margin({ left: 16, right: 16 })

        Button('上一个')
          .onClick(() => {
            if (this.currentWaveIndex > 0) {
              this.currentWaveIndex--;
              this.canvasKey = Date.now(); // 强制Canvas重新渲染
            }
          })
          .enabled(this.currentWaveIndex > 0)

        Text(`${this.currentWaveIndex + 1} / ${this.waveInfoList.length}`)
          .fontSize(14)
          .margin({ left: 8, right: 8 })

        Button('下一个')
          .onClick(() => {
            if (this.currentWaveIndex < this.waveInfoList.length - 1) {
              this.currentWaveIndex++;
              this.canvasKey = Date.now(); // 强制Canvas重新渲染
            }
          })
          .enabled(this.currentWaveIndex < this.waveInfoList.length - 1)

        Button('刷新')
          .onClick(() => {
            this.loadWaveInfoList();
            this.canvasKey = Date.now();
          })
          .margin({ left: 8, right: 16 })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 波形显示区域
      Scroll() {
        Column() {
          if (this.waveInfoList.length > 0 && this.currentWaveIndex < this.waveInfoList.length) {
            const currentWave = this.waveInfoList[this.currentWaveIndex];
            
            // 信息显示
            Row() {
              Text(`水果重量: ${currentWave.fruitweight.toFixed(2)}g`)
                .fontSize(14)
                .margin({ left: 16, right: 16 })
              
              Text(`通道ID: ${currentWave.nChannelId}`)
                .fontSize(14)
                .margin({ left: 16, right: 16 })
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            // 波形数据预览（前10个点）
            Column() {
              Text('波形数据预览 (前10个点)')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 8, bottom: 8 })
              
              Row() {
                Text('AD0: ')
                  .fontSize(12)
                Text(currentWave.waveform0.slice(0, 10).join(', '))
                  .fontSize(12)
                  .fontColor('#00AA00')
              }
              .width('100%')
              .margin({ bottom: 4 })
              
              Row() {
                Text('AD1: ')
                  .fontSize(12)
                Text(currentWave.waveform1.slice(0, 10).join(', '))
                  .fontSize(12)
                  .fontColor('#0000AA')
              }
              .width('100%')
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })
            .alignItems(HorizontalAlign.Start)

            // 波形Canvas
            Canvas()
              .key(`waveCanvas_${this.canvasKey}_${this.currentWaveIndex}`)
              .width('100%')
              .height(400)
              .backgroundColor('#FFFFFF')
              .onReady((ctx: CanvasRenderingContext2D) => {
                console.log(`[WaveCapturePage] Canvas onReady - 通道ID: ${currentWave.nChannelId}, 水果重量: ${currentWave.fruitweight}g`);
                // 清空画布
                ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
                // 绘制波形
                this.drawWaveform(ctx, currentWave);
              })
          } else {
            Column() {
              Text('暂无波形数据')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 100 })
              
              Text(`数据列表长度: ${this.waveInfoList.length}`)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 8 })
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  private drawWaveform(ctx: CanvasRenderingContext2D, wave: StWaveInfo) {
    const width = ctx.canvas.width;
    const height = ctx.canvas.height;
    const halfHeight = height / 2;

    // 绘制坐标轴
    ctx.strokeStyle = '#000000';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, height);
    ctx.moveTo(0, height);
    ctx.lineTo(width, height);
    ctx.moveTo(0, halfHeight);
    ctx.lineTo(width, halfHeight);
    ctx.stroke();

    // 绘制波形0 (AD0通道) - 上半部分，绿色
    if (wave.waveform0 && wave.waveform0.length > 0) {
      const maxValue = Math.max(...wave.waveform0, 1);
      const stepX = width / WAVE_POINT_COUNT;
      
      ctx.strokeStyle = '#00FF00';
      ctx.lineWidth = 2;
      ctx.beginPath();
      
      for (let i = 0; i < wave.waveform0.length && i < WAVE_POINT_COUNT; i++) {
        const x = i * stepX;
        const normalizedValue = wave.waveform0[i] / maxValue;
        const y = halfHeight - (normalizedValue * halfHeight);
        
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      
      ctx.stroke();
    }

    // 绘制波形1 (AD1通道) - 下半部分，蓝色
    if (wave.waveform1 && wave.waveform1.length > 0) {
      const maxValue = Math.max(...wave.waveform1, 1);
      const stepX = width / WAVE_POINT_COUNT;
      
      ctx.strokeStyle = '#0000FF';
      ctx.lineWidth = 2;
      ctx.beginPath();
      
      for (let i = 0; i < wave.waveform1.length && i < WAVE_POINT_COUNT; i++) {
        const x = i * stepX;
        const normalizedValue = wave.waveform1[i] / maxValue;
        const y = halfHeight + (normalizedValue * halfHeight);
        
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      
      ctx.stroke();
    }

    // 绘制标签
    ctx.fillStyle = '#000000';
    ctx.font = '12px sans-serif';
    ctx.fillText('AD0', 10, 20);
    ctx.fillText('AD1', 10, halfHeight + 20);
  }
}

