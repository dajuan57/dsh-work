<#
.SYNOPSIS
    从 projects\_template 新建一个子项目：复制模板、替换占位符、git init 并提交首次快照。

.EXAMPLE
    .\tools\new-project.ps1 -Name invoice-tool -Desc "把发票 PDF 批量转成 Excel"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$Name,

    [string]$Desc = '（一句话说明这个项目做什么）'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$tpl  = Join-Path $root 'projects\_template'
$dst  = Join-Path $root ('projects\' + $Name)
$git  = Join-Path $root 'tools\PortableGit\cmd\git.exe'

if (-not (Test-Path -LiteralPath $tpl)) { throw "模板不存在：$tpl" }
if (-not (Test-Path -LiteralPath $git)) { throw "git 不存在：$git" }
if (Test-Path -LiteralPath $dst) { throw "目标已存在，拒绝覆盖：$dst" }

# 1. 复制模板（AGENTS.md.tpl -> AGENTS.md）
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Get-ChildItem -LiteralPath $tpl -Force | ForEach-Object {
    $target = Join-Path $dst ($_.Name -replace '\.tpl$', '')
    Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
}

# 2. 替换占位符（UTF-8 无 BOM 写回）
Get-ChildItem -LiteralPath $dst -Recurse -File -Force | ForEach-Object {
    $text = [System.IO.File]::ReadAllText($_.FullName, [System.Text.UTF8Encoding]::new($false))
    if ($text -match '\{\{PROJECT_(NAME|DESC)\}\}') {
        $text = $text.Replace('{{PROJECT_NAME}}', $Name).Replace('{{PROJECT_DESC}}', $Desc)
        [System.IO.File]::WriteAllText($_.FullName, $text, [System.Text.UTF8Encoding]::new($false))
    }
}

# 3. 标准子目录
foreach ($d in 'src', 'data', 'tests', 'out') {
    $p = Join-Path $dst $d
    if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

# 4. git init + 首个提交（身份从工作台仓库继承，缺失时兜底）
& $git -C $dst init --quiet
$uname = (& $git -C $root config user.name 2>$null).Trim()
$umail = (& $git -C $root config user.email 2>$null).Trim()
if (-not $uname) { $uname = 'mazix' }
if (-not $umail) { $umail = 'mazix@local' }
& $git -C $dst config user.name  $uname
& $git -C $dst config user.email $umail
# 换行交给 .gitattributes 管，避免 autocrlf 与属性规则互相打架
& $git -C $dst config core.autocrlf false
& $git -C $dst config core.eol lf
$null = New-Item -ItemType File -Path (Join-Path $dst 'src\.gitkeep') -Force
$null = New-Item -ItemType File -Path (Join-Path $dst 'data\.gitkeep') -Force
$null = New-Item -ItemType File -Path (Join-Path $dst 'tests\.gitkeep') -Force
& $git -C $dst add -A
& $git -C $dst commit --quiet -m "chore: 初始化 $Name"
& $git -C $dst log -1 --oneline

Write-Host ""
Write-Host "已创建：$dst" -ForegroundColor Green
Write-Host "下一步：打开 projects\$Name\AGENTS.md，把'三件套'填上（做什么 / 怎么算完成 / 别碰什么）。"
