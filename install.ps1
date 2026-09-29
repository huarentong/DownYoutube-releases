# DownYoutube 安装脚本（Windows）
#
# 下载最新版 Windows 安装包，核对 SHA-256，解压到本地，并在开始菜单创建快捷方式。
# 不需要管理员权限，只写入你自己的用户目录，也会清除文件的“网络来源”标记，避免 SmartScreen 拦截。
#
# 用法（在 PowerShell 中运行）：
#   irm https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.ps1 | iex
#
# 想指定安装目录，先设置环境变量再运行：
#   $env:DOWNYOUTUBE_DEST = "D:\Apps\DownYoutube"

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# 老系统的 PowerShell 默认不启用 TLS 1.2，GitHub 只接受 TLS 1.2 及以上。
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = 'huarentong/DownYoutube-releases'
$appName = 'DownYoutube'

function Fail($msg) { Write-Host "出错了：$msg" -ForegroundColor Red; exit 1 }

$dest = if ($env:DOWNYOUTUBE_DEST) { $env:DOWNYOUTUBE_DEST } else { Join-Path $env:LOCALAPPDATA "Programs\$appName" }
$work = Join-Path ([System.IO.Path]::GetTempPath()) ("downyoutube-install-" + [System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $work | Out-Null

try {
    Write-Host "正在查找最新版本…"
    $headers = @{ 'User-Agent' = 'DownYoutube-install' }
    try {
        $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers $headers
    } catch {
        Fail "无法连接 GitHub，请检查网络后重试。"
    }
    $version = ([string]$rel.tag_name).TrimStart('v')
    if (-not $version) { Fail "没有找到可用的发布版本。" }
    $zipName = "$appName-$version-Windows-x64.zip"
    $zipAsset = $rel.assets | Where-Object { $_.name -eq $zipName } | Select-Object -First 1
    $shaAsset = $rel.assets | Where-Object { $_.name -eq "$zipName.sha256" } | Select-Object -First 1
    if (-not $zipAsset) { Fail "最新版本（$version）没有 Windows 安装包。" }

    # 若已安装且正在运行，先让用户退出，避免替换失败。
    $exePath = Join-Path $dest "$appName.exe"
    if (Test-Path $exePath) {
        $running = Get-Process -Name $appName -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -eq $exePath }
        if ($running) { Fail "DownYoutube 正在运行，请先退出它，再重新运行本脚本。" }
    }

    Write-Host "正在下载 $zipName …"
    $zipPath = Join-Path $work $zipName
    Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -Headers $headers

    Write-Host "正在校验…"
    $actual = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash.ToLower()
    $expected = $null
    if ($shaAsset) {
        # 下载成文件再读：GitHub 把 .sha256 当二进制返回，直接取 .Content 会得到字节数组。
        $shaPath = "$zipPath.sha256"
        Invoke-WebRequest -Uri $shaAsset.browser_download_url -OutFile $shaPath -Headers $headers
        $expected = (((Get-Content -Raw $shaPath) -split '\s+') | Where-Object { $_ })[0].ToLower()
    }
    if ($expected -and $actual -ne $expected) {
        Write-Host "  期望 $expected" -ForegroundColor Yellow
        Write-Host "  实际 $actual" -ForegroundColor Yellow
        Fail "校验失败：安装包不完整或被改动，已停止安装。"
    }
    Write-Host "校验通过。"

    Write-Host "正在解压…"
    $unzip = Join-Path $work 'unzip'
    # PowerShell 5.1 的 Expand-Archive 需要 .zip 扩展名；上面已保证。
    Expand-Archive -Path $zipPath -DestinationPath $unzip -Force
    $payload = Join-Path $unzip $appName
    if (-not (Test-Path (Join-Path $payload "$appName.exe"))) { Fail "安装包内容异常，未找到 $appName.exe。" }

    Write-Host "正在安装到 $dest …"
    $backup = "$dest.old"
    if (Test-Path $dest) {
        if (Test-Path $backup) { Remove-Item -Recurse -Force $backup }
        Rename-Item -Path $dest -NewName (Split-Path $backup -Leaf)
    }
    try {
        New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
        Move-Item -Path $payload -Destination $dest
    } catch {
        if (Test-Path $backup) { Rename-Item -Path $backup -NewName (Split-Path $dest -Leaf) }
        Fail "安装失败，已恢复原来的版本。"
    }
    if (Test-Path $backup) { Remove-Item -Recurse -Force $backup }

    # 清除“来自网络”的标记，避免首次打开时 SmartScreen 拦截。
    Get-ChildItem -Path $dest -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

    # 开始菜单快捷方式。
    $programs = [Environment]::GetFolderPath('Programs')
    New-Item -ItemType Directory -Force -Path $programs | Out-Null
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $programs "$appName.lnk"))
    $shortcut.TargetPath = Join-Path $dest "$appName.exe"
    $shortcut.WorkingDirectory = $dest
    $shortcut.Save()

    Write-Host ""
    Write-Host "安装完成：$dest（版本 $version）" -ForegroundColor Green
    Write-Host "在开始菜单里打开 DownYoutube 即可。"
} finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}
