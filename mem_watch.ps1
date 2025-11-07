# Requires: PowerShell 7+, hdc 在 PATH 中
param(
  [string]$Bundle = 'com.nutpi.My_Project',    # 应用包名
  [int]$ProcId = 0,                            # 指定PID（留空则自动获取）
  [int]$IntervalSec = 5,                       # 采样间隔秒
  [string]$OutCsv = '',                        # 输出CSV路径（留空则使用当前目录）
  [switch]$RawOut,                             # 是否保存原始文本
  [string]$RawDir = './logs'                   # 原始文本目录
)

if (-not $OutCsv -or $OutCsv.Trim() -eq '') {
  $OutCsv = Join-Path (Get-Location) "mem_monitor_$Bundle.csv"
}
if ($RawOut) {
  if (-not (Test-Path $RawDir)) { New-Item -ItemType Directory -Force -Path $RawDir | Out-Null }
}

function Get-ProcessIdByBundle([string]$bundle) {
  try {
    $line = hdc shell "ps -ef | grep $bundle | grep -v grep" 2>$null | Select-Object -First 1
    if (-not $line) { return 0 }
    $cols = ($line -split '\s+') | Where-Object { $_ -ne '' }
    # 常见 ps -ef 列：UID PID PPID ...
    if ($cols.Length -ge 2 -and ($cols[1] -match '^[0-9]+$')) { return [int]$cols[1] }
  } catch {
  }
  return 0
}

function KB2MB([nullable[int]]$kb){ if ($kb -ne $null) { [math]::Round($kb/1024,2) } else { '' } }

function Get-FirstNumKb([string]$line) {
  if (-not $line) { return $null }
  if ($line -match '(\d+)\s*\(.*?\)\s*kB') { return [int]$Matches[1] } # Total 行
  if ($line -match ':\s*(\d+)\s*kB')       { return [int]$Matches[1] }   # VmRSS 等
  if ($line -match '\s+(\d+)\s*$')         { return [int]$Matches[1] }
  if ($line -match '(\d+)')                  { return [int]$Matches[1] }
  return $null
}

# 从全机视图行解析 PSS（kB）：匹配包含 bundle 的行
function Get-PssFromGlobal([string]$bundle) {
  try {
    $globalOut = hdc shell "hidumper --mem" 2>$null
    if (-not $globalOut) { return $null }
    $line = ($globalOut | Select-String -SimpleMatch $bundle).Line | Select-Object -First 1
    if (-not $line) { return $null }
    # 该行形如：PID  TotalPss(...) kB  TotalVss ...  Name
    # 提取第一个形如 12345(...) kB 里的数字
    if ($line -match "\s(\d+)\(.*?\)\s*kB") { return [int]$Matches[1] }
  } catch {}
  return $null
}

if ($ProcId -le 0) {
  $ProcId = Get-ProcessIdByBundle $Bundle
}
if ($ProcId -le 0) {
  Write-Error "未找到进程PID，请确认包名或传入 -Pid"
  exit 1
}

if (-not (Test-Path $OutCsv)) {
  "timestamp,pss_mb,uss_mb,rss_mb,gl_mb,arkts_heap_mb,native_heap_mb,brk_heap_mb" | Out-File -Encoding utf8 $OutCsv
}

Write-Host "开始监控: Bundle=$Bundle PID=$ProcId 每 $IntervalSec 秒采样，CSV: $OutCsv （Ctrl+C 停止）"
$prevPss = $null

while ($true) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $tsFile = Get-Date -Format "yyyyMMdd_HHmmss"
  $raw = hdc shell "hidumper --mem $ProcId" 2>$null
  if (-not $raw) {
    Write-Warning "[$ts] hidumper 无输出，稍后重试"
    Start-Sleep -Seconds $IntervalSec
    continue
  }
  if ($RawOut) {
    $rawPath = Join-Path $RawDir ("mem_raw_" + $tsFile + ".txt")
    $raw | Out-File -Encoding utf8 $rawPath
  }

  $lineTotal = ($raw | Select-String -Pattern "^\s*Total\s+" -CaseSensitive:$false).Line | Select-Object -First 1
  $lineGL    = ($raw | Select-String -Pattern "^\s*GL\s+" -CaseSensitive:$false).Line        | Select-Object -First 1
  $lineArk   = ($raw | Select-String -Pattern "^\s*ark\s+ts\s+heap\s+" -CaseSensitive:$false).Line | Select-Object -First 1
  $lineNat   = ($raw | Select-String -Pattern "^\s*native\s+heap\s+" -CaseSensitive:$false).Line   | Select-Object -First 1
  $lineBrk   = ($raw | Select-String -Pattern "^\s*brk\s+heap:" -CaseSensitive:$false).Line         | Select-Object -First 1

  # 尝试从 Total 行抽取多列数字用于 PSS/USS/RSS 粗略参考
  $nums = @()
  if ($lineTotal) { $nums = ($lineTotal -split '\s+') | Where-Object { $_ -match '^[0-9]+$' } }
  $pssKb = $null; $ussKb = $null; $rssKb = $null
  if ($nums.Count -ge 5) {
    $pssKb = [int]$nums[0]
    $ussKb = [int]$nums[2]   # 近似参考（列位因版本差异，仅用于趋势）
    $rssKb = [int]$nums[4]
  } else {
    $pssKb = Get-FirstNumKb $lineTotal
  }

  # 若单进程页面未取到 PSS，则回退到全机视图按包名解析
  if (-not $pssKb -or $pssKb -le 0) {
    $pssKb = Get-PssFromGlobal $Bundle
    if ($RawOut -and $pssKb -ne $null) {
      $glob = hdc shell "hidumper --mem" 2>$null
      if ($glob) {
        $globPath = Join-Path $RawDir ("mem_global_" + $tsFile + ".txt")
        $glob | Out-File -Encoding utf8 $globPath
      }
    }
  }

  $glKb  = Get-FirstNumKb $lineGL;  if (-not $glKb)  { $glKb  = ([regex]::Match(($raw -join "`n"), "(?im)^\s*GL\s+(\d+)")).Groups[1].Value }
  $arkKb = Get-FirstNumKb $lineArk; if (-not $arkKb) { $arkKb = ([regex]::Match(($raw -join "`n"), "(?im)^\s*ark\s+ts\s+heap\s+(\d+)")).Groups[1].Value }
  $natKb = Get-FirstNumKb $lineNat; if (-not $natKb) { $natKb = ([regex]::Match(($raw -join "`n"), "(?im)^\s*native\s+heap\s+(\d+)")).Groups[1].Value }
  $brkKb = Get-FirstNumKb $lineBrk; if (-not $brkKb) { $brkKb = ([regex]::Match(($raw -join "`n"), "(?im)^\s*brk\s+heap:\s*(\d+)")).Groups[1].Value }

  $pssMB = KB2MB $pssKb
  $ussMB = KB2MB $ussKb
  $rssMB = KB2MB $rssKb
  $glMB  = KB2MB $glKb
  $arkMB = KB2MB $arkKb
  $natMB = KB2MB $natKb
  $brkMB = KB2MB $brkKb

  "$ts,$pssMB,$ussMB,$rssMB,$glMB,$arkMB,$natMB,$brkMB" | Out-File -Append -Encoding utf8 $OutCsv

  if ($prevPss -ne $null -and $pssMB -ne "") {
    $delta = [math]::Round(($pssMB - $prevPss), 2)
    if ($delta -ge 10) {
      Write-Warning "[$ts] PSS 上涨 $delta MB（当前 $pssMB MB）"
    } elseif ($delta -le -10) {
      Write-Host   "[$ts] PSS 下降 $delta MB（当前 $pssMB MB）" -ForegroundColor Green
    } else {
      Write-Host   "[$ts] PSS=$pssMB MB, native=$natMB MB, brk=$brkMB MB, arkts=$arkMB MB"
    }
  } else {
    Write-Host     "[$ts] PSS=$pssMB MB, native=$natMB MB, brk=$brkMB MB, arkts=$arkMB MB"
  }
  if ($pssMB -ne "") { $prevPss = $pssMB }

  Start-Sleep -Seconds $IntervalSec
}


