# 第三方软件声明

DownYoutube 的安装包内置了下列程序。它们各自遵循自己的许可证，与 DownYoutube 本身无关。
安装包内也有一份声明和各程序的许可证文本：macOS 版在 `DownYoutube.app/Contents/Resources/licenses/`。

## macOS 版

| 组件 | 版本 | 许可证 | 来源 |
| --- | --- | --- | --- |
| yt-dlp | 2026.08.19 | Unlicense（公有领域） | https://github.com/yt-dlp/yt-dlp |
| deno（yt-dlp 解析 YouTube 所需的 JavaScript 运行时） | 2.9.7 | MIT | https://github.com/denoland/deno |
| FFmpeg | 9.0.2 | GPL-3.0 或更高（该构建启用了 GPL 组件，如 x264、x265） | https://ffmpeg.org · 构建：https://ffmpeg.martin-riedl.de |
| Python | 3.13.15 | PSF License | https://www.python.org |
| Tcl/Tk | 8.6.18 | Tcl/Tk License（BSD 风格） | https://www.tcl-lang.org |
| CustomTkinter | 6.0.0 | CC0 1.0 | https://github.com/TomSchimansky/CustomTkinter |
| darkdetect | 0.8.0 | BSD-3-Clause | https://github.com/albertosottile/darkdetect |
| packaging | 26.3 | Apache-2.0 或 BSD-2-Clause | https://github.com/pypa/packaging |
| PyInstaller（打包工具，其引导程序随应用分发） | 6.22.3 | GPL-2.0 或更高，附带允许分发任意程序的例外条款 | https://pyinstaller.org |

## FFmpeg（GPL）

- DownYoutube **不链接** FFmpeg，只把它当作独立程序来调用。
- 内置的 FFmpeg 是 GPL 构建。GNU GPL v3 全文在安装包的 `licenses/GPL-3.0.txt` 中，也可以在 https://www.gnu.org/licenses/gpl-3.0.txt 查看。
- 对应的源代码：
  - FFmpeg 9.0.2 源代码：https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz
  - 该构建所用的编译选项、第三方库及构建脚本，见构建者的页面：https://ffmpeg.martin-riedl.de
  - 上述链接失效时，可以在本仓库的 Issues 里索取源代码。
- 运行 `ffmpeg -version` 可以查看该构建的完整配置。

## 内置程序的来源与校验

安装包在构建时，从官方发布地址下载下面的文件，并核对 SHA-256：

| 文件 | SHA-256 |
| --- | --- |
| yt-dlp_macos 2026.08.19（通用二进制） | `0f192b7ec147ab6288885d6351d9ab67367640029b4377576ef46dd79cf7b202` |
| deno-aarch64-apple-darwin.zip v2.9.7 | `5cd46d6268f6f78f5d88bdc7159d20bd44cdaa4b3303474839f87ec6fe7ae25c` |
| deno-x86_64-apple-darwin.zip v2.9.7 | `95daaff11c116a52ad54785e7914c8e9c9cdcaba793c5ed929c74ca2d8e6259a` |
| ffmpeg.zip 9.0.2（arm64） | `c8ed4c4e6978a03c485edbfe4e0a5dc2380f8a30bba5150531b31b094492d924` |
| ffmpeg.zip 9.0.2（x86_64） | `7c6b4125b191cbf773832dc51f424cf2b6bb7da43007d1e066f95909e47cacd4` |

deno 与 FFmpeg 的两个架构版本会用 `lipo` 合并成一个通用二进制，并重新做 ad-hoc 签名。
