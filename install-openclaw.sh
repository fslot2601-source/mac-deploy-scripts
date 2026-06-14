#!/usr/bin/env bash
# One-click OpenClaw installer for M-series Apple Silicon Mac
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo "=============================="
echo " OpenClaw 一键安装脚本"
echo " 适用于 M 系列 Apple Silicon Mac"
echo "=============================="
echo ""

# 1. 检查芯片架构
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
  error "此脚本仅支持 M 系列 Apple Silicon (arm64)，当前架构：$ARCH"
fi
info "芯片架构：$ARCH"

# 2. 检查 macOS 版本
MACOS=$(sw_vers -productVersion)
info "macOS 版本：$MACOS"

# 3. 安装 Homebrew（如未安装）
if ! command -v brew &>/dev/null; then
  info "正在安装 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # 将 Homebrew 加入 PATH（Apple Silicon 路径）
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew：$(brew --version | head -1)"
fi

# 4. 安装 Node.js 22 LTS（强制用 Homebrew，避免与其他工具的内置 node 冲突）
info "正在通过 Homebrew 安装 Node.js 22 LTS..."
brew install node@22 2>/dev/null || true
brew link node@22 --force --overwrite 2>/dev/null || true
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> "$HOME/.zshrc"
info "Node.js：$(node --version)"

# 5. 检查 / 安装 OpenClaw
if /opt/homebrew/opt/node@22/bin/openclaw --version &>/dev/null 2>&1; then
  warn "OpenClaw 已安装（$(/opt/homebrew/opt/node@22/bin/openclaw --version 2>/dev/null)），跳过安装。"
else
  info "正在全局安装 OpenClaw..."
  npm install -g openclaw
fi

# 6. 验证安装
OPENCLAW_BIN="/opt/homebrew/opt/node@22/bin/openclaw"
if [[ -x "$OPENCLAW_BIN" ]] || command -v openclaw &>/dev/null; then
  info "OpenClaw 安装成功！"
  echo ""
  echo "=============================="
  echo " 后续配置步骤（手动运行）："
  echo "   openclaw setup              # 初始化配置向导"
  echo "   openclaw onboard --install-daemon  # 设为开机自启后台服务"
  echo "=============================="
else
  error "安装完成但 openclaw 命令未找到，请重启终端后重试。"
fi
