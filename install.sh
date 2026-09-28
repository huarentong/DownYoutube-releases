#!/bin/sh
# DownYoutube 安装脚本（macOS）
#
# 用 curl 下载最新版安装包，核对 SHA-256，再把 DownYoutube.app 装进「应用程序」。
# 用 curl 下载的文件不带 macOS 的「隔离标记」，所以第一次打开时不会出现
# 「Apple 无法验证……」的警告。脚本不需要管理员密码，也不会改动别的东西。
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.sh | sh
#
# 想先看看脚本再运行：
#   curl -fsSL https://raw.githubusercontent.com/huarentong/DownYoutube-releases/main/install.sh -o install.sh
#   less install.sh
#   sh install.sh
#
# 环境变量 DOWNYOUTUBE_DEST 可以指定安装目录（默认 /Applications，
# 没有写入权限时用 ~/Applications）。
#
# 注意：macOS 自带的 sh（bash 3.2）会把变量名后面紧跟的中文标点当成变量名的一部分，
# 所以下面所有变量都写成 ${name}。

set -eu

REPO="huarentong/DownYoutube-releases"
APP="DownYoutube.app"
MIN_MACOS=12

say() { printf '%s\n' "$*"; }
die() { printf '出错了：%s\n' "$*" >&2; exit 1; }

# 所有步骤都放在 main 里，最后才调用：下载被截断时，不会执行到一半。
main() {
  [ "$(uname -s)" = "Darwin" ] || die "这个脚本只能在 macOS 上运行。"
  os_version="$(sw_vers -productVersion)"
  os_major="${os_version%%.*}"
  [ "${os_major}" -ge "${MIN_MACOS}" ] 2>/dev/null \
    || die "需要 macOS ${MIN_MACOS} 或更高版本，当前是 ${os_version}。"

  if [ -n "${DOWNYOUTUBE_DEST:-}" ]; then
    dest="${DOWNYOUTUBE_DEST}"
  elif [ -w /Applications ]; then
    dest="/Applications"
  else
    dest="${HOME}/Applications"
  fi
  mkdir -p "${dest}" || die "无法创建目录：${dest}"

  if pgrep -f "${dest}/${APP}/Contents/MacOS/" >/dev/null 2>&1; then
    die "DownYoutube 正在运行，请先退出它，再重新运行本脚本。"
  fi

  tmp_base="${TMPDIR:-/tmp}"
  work="$(mktemp -d "${tmp_base%/}/downyoutube-install.XXXXXX")" || die "无法创建临时目录。"
  mnt="${work}/mnt"
  mounted=""
  cleanup() {
    if [ -n "${mounted}" ]; then
      hdiutil detach "${mnt}" -quiet >/dev/null 2>&1 \
        || { sleep 1; hdiutil detach "${mnt}" -quiet -force >/dev/null 2>&1; } \
        || true
    fi
    if [ -d "${mnt}/${APP}" ]; then
      printf '%s\n' "提示：安装包没能自动推出，请在访达里手动推出：${mnt}" >&2
    else
      rm -rf "${work}"
    fi
  }
  trap cleanup EXIT
  trap 'exit 1' INT TERM HUP

  say "正在查找最新版本…"
  final_url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest" </dev/null)" \
    || die "无法连接 GitHub，请检查网络后重试。"
  tag="${final_url##*/}"
  case "${tag}" in
    v[0-9]*) ;;
    *) die "没有找到可用的发布版本。" ;;
  esac
  version="${tag#v}"
  dmg="DownYoutube-${version}-macOS.dmg"
  base_url="https://github.com/${REPO}/releases/download/${tag}"

  say "正在下载 ${dmg} …"
  curl -fL --retry 3 --progress-bar -o "${work}/${dmg}" "${base_url}/${dmg}" </dev/null \
    || die "下载失败，请检查网络后重试。"
  curl -fsSL --retry 3 -o "${work}/${dmg}.sha256" "${base_url}/${dmg}.sha256" </dev/null \
    || die "下载校验文件失败。"
  (cd "${work}" && shasum -a 256 -c "${dmg}.sha256" >/dev/null 2>&1) \
    || die "校验失败：安装包不完整或被改动，已停止安装。"
  say "校验通过。"

  mkdir -p "${mnt}"
  hdiutil attach "${work}/${dmg}" -nobrowse -readonly -noverify -mountpoint "${mnt}" -quiet </dev/null \
    || die "无法打开安装包。"
  mounted=1
  [ -d "${mnt}/${APP}" ] || die "安装包里没有找到 ${APP}。"

  say "正在安装到 ${dest} …"
  new="${dest}/.DownYoutube-new.app"
  old="${dest}/.DownYoutube-old.app"
  rm -rf "${new}" "${old}"
  ditto "${mnt}/${APP}" "${new}" </dev/null \
    || { rm -rf "${new}"; die "复制失败，请确认对 ${dest} 有写入权限。"; }
  if [ -e "${dest}/${APP}" ]; then
    mv "${dest}/${APP}" "${old}" || { rm -rf "${new}"; die "无法替换已安装的旧版本。"; }
  fi
  if ! mv "${new}" "${dest}/${APP}"; then
    [ -e "${old}" ] && mv "${old}" "${dest}/${APP}"
    rm -rf "${new}"
    die "安装失败，已恢复原来的版本。"
  fi
  rm -rf "${old}"
  # 万一安装包带着隔离标记（例如被浏览器下载过），一并清掉，避免弹出警告。
  xattr -dr com.apple.quarantine "${dest}/${APP}" 2>/dev/null || true

  say ""
  say "安装完成：${dest}/${APP}（版本 ${version}）"
  say "在「启动台」或「应用程序」里打开 DownYoutube 即可。"
}

main "$@"
