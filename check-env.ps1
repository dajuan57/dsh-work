<#
    环境自检 —— 检查 DSH 工作台的工具链是否可用
    用法：powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\mazix\work\check-env.ps1
    不写任何系统位置，只在本机临时目录里做一次 docx->pdf 验证。
#>
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$Dep  = 'C:\Users\mazix\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies'
$Py   = Join-Path $Dep 'python\python.exe'
$Node = Join-Path $Dep 'node\bin\node.exe'
$Pnpm = Join-Path $Dep 'pnpm\bin\pnpm.mjs'
$Cli  = 'C:\Users\mazix\AppData\Local\Programs\DeepSeek Harness\resources\app.asar.unpacked\dsh\node_modules\@deepseek-ai\libreoffice-kit\lib\cli.js'
$GitPortable = 'C:\Users\mazix\work\tools\PortableGit\cmd\git.exe'

$results = New-Object System.Collections.Generic.List[object]
function Add-Result($name, $ok, $detail) {
    $results.Add([pscustomobject]@{ 项目 = $name; 结果 = $(if ($ok) { 'PASS' } else { 'FAIL' }); 详情 = $detail })
}
function Try-Run($exe, $argsList) {
    try { $o = & $exe @argsList 2>&1 | Out-String; return @{ ok = ($LASTEXITCODE -eq 0); out = $o.Trim() } }
    catch { return @{ ok = $false; out = $_.Exception.Message } }
}

# 1. Python
if (Test-Path $Py) {
    $r = Try-Run $Py @('-c', 'import sys;print(sys.version.split()[0])')
    Add-Result 'Python' $r.ok $r.out
} else { Add-Result 'Python' $false "未找到 $Py" }

# 1b. 共享 venv（工作台根目录 .venv；pip 用 -m pip 调；核心库来自系统 Python 的 site-packages）
$VenvPy = 'C:\Users\mazix\work\.venv\Scripts\python.exe'
if (Test-Path $VenvPy) {
    $r = Try-Run $VenvPy @('-c', 'import numpy,pandas,openpyxl,docx,pptx,PIL,lxml,xlsxwriter,pip as p;print(p.__version__,numpy.__version__,pandas.__version__)')
    Add-Result 'venv（pip+核心库）' $r.ok $r.out
} else { Add-Result 'venv（pip+核心库）' $false "未找到 $VenvPy" }

# 2. Node / pnpm
if (Test-Path $Node) {
    $r = Try-Run $Node @('-v'); Add-Result 'Node' $r.ok $r.out
    if (Test-Path $Pnpm) {
        $r2 = Try-Run $Node @($Pnpm, '-v'); Add-Result 'pnpm' $r2.ok $r2.out
    } else { Add-Result 'pnpm' $false "未找到 $Pnpm" }
} else { Add-Result 'Node' $false "未找到 $Node" }

# 3. Git（先看 PATH，再看便携版）
$gitExe = $null
$cmd = Get-Command git -ErrorAction SilentlyContinue
if ($cmd) { $gitExe = $cmd.Source }
elseif (Test-Path $GitPortable) { $gitExe = $GitPortable }
if ($gitExe) {
    $r = Try-Run $gitExe @('--version')
    $where = if ($cmd) { 'PATH 中' } else { '便携版（PATH 未生效）' }
    Add-Result 'Git' $r.ok ("{0}  [{1}]" -f $r.out, $where)
} else { Add-Result 'Git' $false 'PATH 和 C:\Users\mazix\work\tools\PortableGit 都没有' }

# 4. Office 引擎
$officeOk = $false
if ((Test-Path $Node) -and (Test-Path $Cli)) {
    $r = Try-Run $Node @($Cli, 'capabilities')
    if ($r.ok -and $r.out -match '"backend"\s*:\s*"native"') { $officeOk = $true }
    Add-Result 'Office 引擎' $r.ok $($r.out.Substring(0, [Math]::Min(60, $r.out.Length)))
} else { Add-Result 'Office 引擎' $false '缺少 node 或 libreoffice-kit CLI' }

# 5. 真实转换：docx -> pdf
if ($officeOk) {
    $tmp = Join-Path $env:TEMP ('dshcheck_' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    try {
        $docx = Join-Path $tmp 'probe.docx'
        $pdf  = Join-Path $tmp 'probe.pdf'
        $pyOne = "from docx import Document;d=Document();d.add_paragraph('ok');d.save(r'$docx')"
        & $Py -c $pyOne 2>&1 | Out-Null
        $conv = Try-Run $Node @($Cli, 'convert', '--input', $docx, '--output', $pdf)
        $sig = ''
        if (Test-Path $pdf) {
            $b = [System.IO.File]::ReadAllBytes($pdf)
            if ($b.Length -ge 5) { $sig = [System.Text.Encoding]::ASCII.GetString($b[0..4]) }
        }
        Add-Result 'docx→PDF' ($sig -eq '%PDF-') ("签名={0} 大小={1}B" -f $sig, (Get-Item $pdf -ErrorAction SilentlyContinue).Length)
    } catch { Add-Result 'docx→PDF' $false $_.Exception.Message }
    finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}

# 6. 指令文件
$hasGlobal = Test-Path 'C:\Users\mazix\.dsh\AGENTS.md'
$hasProject = Test-Path 'C:\Users\mazix\work\AGENTS.md'
Add-Result '全局 AGENTS.md' $hasGlobal 'C:\Users\mazix\.dsh\AGENTS.md'
Add-Result '项目 AGENTS.md' $hasProject 'C:\Users\mazix\work\AGENTS.md'

# 7. 工作台仓库
if ($gitExe -and (Test-Path 'C:\Users\mazix\work\.git')) {
    $r = Try-Run $gitExe @('-C', 'C:\Users\mazix\work', 'log', '-1', '--oneline')
    Add-Result '工作台仓库' $r.ok $r.out
} else { Add-Result '工作台仓库' $false 'C:\Users\mazix\work 尚未 git init' }

# 8. 磁盘
try {
    $d = [System.IO.DriveInfo]::new('C')
    $free = [math]::Round($d.AvailableFreeSpace / 1GB, 1)
    Add-Result '磁盘剩余' ($free -gt 5) "$free GB"
} catch { Add-Result '磁盘剩余' $false '无法读取' }

# 输出
$results | Format-Table -AutoSize -Wrap | Out-String | Write-Host
$fail = @($results | Where-Object { $_.结果 -eq 'FAIL' }).Count
if ($fail -eq 0) { Write-Host "全部通过（$($results.Count) 项）" -ForegroundColor Green }
else { Write-Host "$fail / $($results.Count) 项未通过，见上表" -ForegroundColor Yellow }
exit $fail
