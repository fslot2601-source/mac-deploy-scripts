#!/usr/bin/env bash
# One-click Hermes Agent installer for Apple Silicon Mac
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo "=============================="
echo " Hermes Agent 一键安装脚本"
echo " 适用于 Apple Silicon Mac"
echo "=============================="
echo ""

# 1. 检查芯片架构
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
  error "此脚本仅支持 Apple Silicon (arm64)，当前架构：$ARCH"
fi
info "芯片架构：$ARCH"

# 2. 检查 macOS 版本
MACOS=$(sw_vers -productVersion)
info "macOS 版本：$MACOS"

# 3. 检查 / 安装 Git（Xcode CLT）
if ! command -v git &>/dev/null; then
  warn "未检测到 Git，正在触发 Xcode Command Line Tools 安装..."
  xcode-select --install 2>/dev/null || true
  echo "请在弹窗中点击安装，完成后重新运行此脚本。"
  exit 1
fi
info "Git：$(git --version)"

# 4. 检查是否已安装 Hermes
if command -v hermes &>/dev/null; then
  warn "Hermes 已安装（$(hermes --version 2>/dev/null || echo '版本未知')），跳过安装步骤。"
else
  info "开始下载并安装 Hermes Agent..."
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
fi

# 5. 刷新 shell 环境
SHELL_RC="$HOME/.zshrc"
if [[ -f "$SHELL_RC" ]]; then
  # shellcheck disable=SC1090
  source "$SHELL_RC" 2>/dev/null || true
fi

# 6. 验证安装
if command -v hermes &>/dev/null; then
  info "Hermes 安装成功！"
  echo ""
  echo "=============================="
  echo " 后续配置步骤（手动运行）："
  echo "   hermes setup     # 完整配置向导"
  echo "   hermes model     # 选择 LLM 提供商"
  echo "   hermes doctor    # 诊断问题"
  echo "=============================="
else
  error "安装完成但 hermes 命令未找到，请重启终端后重试，或运行：source ~/.zshrc"
fi
