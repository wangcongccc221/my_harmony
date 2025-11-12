// 可复用的折线图绘制函数（Canvas + CanvasRenderingContext2D + Path2D）

export interface LineChartOptions {
  // 画布与数据
  chartHeight: number;           // 画布高度（像素）
  canvasPadding: number;         // 内边距（像素）
  xStep: number;                 // 相邻数据点的水平间距（像素）
  data: number[];                // 数据序列（0..yMax）
  labels: string[];              // X 轴标签，与 data 同长度
  yMax?: number;                 // Y 轴最大值（默认 100）
  axisFontSizePx?: number;       // Y轴刻度字体大小（像素），默认12
  labelFontSizePx?: number;      // X轴标签字体大小（像素），默认10
  lineWidthPx?: number;          // 折线宽度（像素），默认2
  pointRadiusPx?: number;        // 数据点半径（像素），默认4
  axisFontBold?: boolean;        // Y 轴文字是否加粗
  labelFontBold?: boolean;       // X 轴文字是否加粗

  // 样式（可选）
  colors?: {
    background?: string;
    axis?: string;               // 边框/坐标轴颜色
    grid?: string;               // 辅助横线颜色
    line?: string;               // 折线颜色
    pointFill?: string;          // 数据点填充色
    pointStroke?: string;        // 数据点描边色
    axisText?: string;           // 坐标文字颜色
    labelText?: string;          // X 轴标签颜色
  };
}

export function measureChartWidth(options: Pick<LineChartOptions, 'canvasPadding' | 'xStep' | 'data'>): number {
  const count = options.data.length;
  if (count <= 0) return options.canvasPadding * 2;
  return options.canvasPadding * 2 + (count - 1) * options.xStep;
}

export function drawLineChart(ctx: CanvasRenderingContext2D, opts: LineChartOptions): void {
  const yMax = opts.yMax ?? 100;
  const width = measureChartWidth({ canvasPadding: opts.canvasPadding, xStep: opts.xStep, data: opts.data });
  const height = opts.chartHeight;
  const pad = opts.canvasPadding;
  const yScale = (height - pad * 2) / yMax;
  const axisFontPx = opts.axisFontSizePx ?? 12;
  const labelFontPx = opts.labelFontSizePx ?? 10;
  const lineWidthPx = opts.lineWidthPx ?? 2;
  const pointRadiusPx = opts.pointRadiusPx ?? 4;
  const axisFontWeight = opts.axisFontBold ? 'bold ' : '';
  const labelFontWeight = opts.labelFontBold ? 'bold ' : '';

  const colors = {
    background: '#FFFFFF',
    axis: '#E0E0E0',
    grid: '#F0F0F0',
    line: '#4A90E2',
    pointFill: '#4A90E2',
    pointStroke: '#FFFFFF',
    axisText: '#666666',
    labelText: '#666666',
    ...(opts.colors ?? {})
  };

  // 背景
  ctx.clearRect(0, 0, width, height);
  ctx.fillStyle = colors.background;
  ctx.fillRect(0, 0, width, height);

  // 边框与坐标轴
  ctx.strokeStyle = colors.axis;
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(pad, pad);
  ctx.lineTo(pad, height - pad);
  ctx.lineTo(width - pad, height - pad);
  ctx.stroke();

  // Y 轴刻度与辅助线（固定 5 等分）
  ctx.fillStyle = colors.axisText;
  ctx.font = axisFontWeight + axisFontPx + 'px sans-serif';
  ctx.textAlign = 'right';
  ctx.textBaseline = 'middle';
  for (let i = 0; i <= 5; i++) {
    const value = (yMax / 5) * (5 - i);
    const y = pad + i * ((height - pad * 2) / 5);
    ctx.fillText(value.toString(), pad - 5, y);
    ctx.strokeStyle = colors.grid;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(pad, y);
    ctx.lineTo(width - pad, y);
    ctx.stroke();
  }

  // 折线
  if (opts.data.length > 0) {
    const path = new Path2D();
    path.moveTo(pad, height - pad - opts.data[0] * yScale);
    for (let i = 1; i < opts.data.length; i++) {
      const x = pad + i * opts.xStep;
      const y = height - pad - opts.data[i] * yScale;
      path.lineTo(x, y);
    }
    ctx.strokeStyle = colors.line;
    ctx.lineWidth = lineWidthPx;
    ctx.stroke(path);
  }

  // 数据点
  ctx.fillStyle = colors.pointFill;
  ctx.strokeStyle = colors.pointStroke;
  ctx.lineWidth = Math.max(1, Math.round(lineWidthPx * 0.9));
  for (let i = 0; i < opts.data.length; i++) {
    const x = pad + i * opts.xStep;
    const y = height - pad - opts.data[i] * yScale;
    const cp = new Path2D();
    cp.arc(x, y, pointRadiusPx, 0, Math.PI * 2);
    ctx.fill(cp);
    ctx.stroke(cp);
  }

  // X 轴时间标签
  ctx.fillStyle = colors.labelText;
  ctx.font = labelFontWeight + labelFontPx + 'px sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'alphabetic';
  for (let i = 0; i < opts.labels.length; i++) {
    const x = pad + i * opts.xStep;
    const y = height - 6;
    ctx.fillText(opts.labels[i], x, y);
  }
}


