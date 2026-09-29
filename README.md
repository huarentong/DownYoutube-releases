# DownYoutube

DownYoutube 是 YouTube 下载工具，界面为简体中文，支持 macOS 和 Windows。它调用本机的 yt-dlp 和 ffmpeg，把视频保存为可以直接播放的 MP4，也可以只保存音频、下载字幕或整个播放列表。

**这个仓库只发布安装包。DownYoutube 的源代码不公开，也不是开源软件。**

请只下载你有权保存的内容。

## 安装（macOS）

系统要求：macOS 12 或更高版本；Apple 芯片和 Intel 芯片的 Mac 都支持。

### 方法一：一行命令（推荐，不会弹出警告）

打开「终端」，粘贴并运行：

```bash
curl -fsSL https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.sh | sh
```

脚本会下载最新版本、核对 SHA-256，再把 DownYoutube 装进「应用程序」，不需要管理员密码。装好后直接打开即可。

想先看看脚本写了什么，可以先下载，看过再运行：

```bash
curl -fsSL https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.sh -o install.sh
less install.sh
sh install.sh
```

### 方法二：从浏览器下载

1. 在 [Releases](https://github.com/huarentong/DownYoutube-releases/releases/latest) 下载 `DownYoutube-<版本>-macOS.dmg`，打开后把 DownYoutube 拖进「应用程序」。
2. 第一次打开时，macOS 会提示「Apple 无法验证“DownYoutube”是否包含可能危害 Mac 安全或泄漏隐私的恶意软件」（旧版本的 macOS 可能显示「无法验证开发者」）。这是因为安装包没有经过 Apple 公证，文件本身没有问题。先点「完成」，再任选一种方法放行，只需做一次：
   - 打开「系统设置 › 隐私与安全性」，滚到最下面，点「已阻止使用 DownYoutube」旁的「仍要打开」，输入登录密码
   - 或在「终端」运行：`xattr -dr com.apple.quarantine /Applications/DownYoutube.app`

### 卸载

把 `/Applications/DownYoutube.app` 移到废纸篓。设置、下载记录和下载历史保存在 `~/Library/Application Support/DownYoutube/`，不需要时可以一并删除。

## 安装（Windows）

系统要求：Windows 10 或更高版本（64 位）。

### 方法一：一行命令（推荐，不会被 SmartScreen 拦截）

按 `Win + X`，选「终端」或「Windows PowerShell」，粘贴并运行：

```powershell
irm https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.ps1 | iex
```

脚本会下载最新版本、核对 SHA-256，解压到 `%LOCALAPPDATA%\Programs\DownYoutube`，并在开始菜单创建快捷方式，不需要管理员权限。装好后在开始菜单打开 DownYoutube 即可。

如果提示「无法加载脚本，因为在此系统上禁止运行脚本」，先运行一次下面这句再重试：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 方法二：从浏览器下载

1. 在 [Releases](https://github.com/huarentong/DownYoutube-releases/releases/latest) 下载 `DownYoutube-<版本>-Windows-x64.zip`，解压到任意文件夹（例如「文档」下）。
2. 双击里面的 `DownYoutube.exe`。第一次打开时 Windows 可能弹出蓝色的「Windows 已保护你的电脑」（SmartScreen）。这是因为程序没有购买代码签名证书，文件本身没有问题。点「更多信息」，再点「仍要运行」即可，只需做一次。（用上面的一行命令安装则不会出现此提示。）

不要把整个文件夹里的文件拆开移动；`DownYoutube.exe` 需要和同目录的 `_internal`、`bin` 文件夹在一起。

### 卸载

删除安装目录（默认 `%LOCALAPPDATA%\Programs\DownYoutube`）和开始菜单里的 DownYoutube 快捷方式。设置、下载记录和下载历史保存在 `%APPDATA%\DownYoutube`，不需要时可以一并删除。

## 功能

- 单个视频和播放列表（可只下载指定序号范围）
- 画质：兼容 MP4、最高画质 MP4、不超过 1080p、仅音频 M4A
- 字幕：简体中文 / 英文，可选自动字幕；另存为 `.srt` 并嵌入 MP4
- 下载记录（已下载的会自动跳过）和下载历史列表（可打开视频、在访达中显示、删除记录）
- 遇到「Sign in to confirm you're not a bot」时，可以使用浏览器的 Cookies
- 内置 yt-dlp、ffmpeg 和 deno，不需要另外安装。YouTube 变化导致下载出错时，先点窗口右上角的「更新 yt-dlp」

DownYoutube 只是调用本机的 yt-dlp 和 ffmpeg 来下载，不破解 DRM，不收集你的账号密码，也不上传你的数据。

## 第三方软件

安装包里带有 yt-dlp、ffmpeg 和 deno（macOS 与 Windows 版本相同：yt-dlp 2026.08.19、ffmpeg 9.0.2、deno 2.9.7）。其中 ffmpeg 是 GPL 构建，各程序的许可证和 ffmpeg 的源代码获取方式见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 问题反馈

可以在 [Issues](https://github.com/huarentong/DownYoutube-releases/issues) 里留言。
