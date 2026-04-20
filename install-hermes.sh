#!/usr/bin/env bash
# One-click Hermes Agent installer for Apple Silicon Mac
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# 检测是否有 TTY（SSH 无交互时跳过 read）
has_tty() { [ -t 0 ]; }

install_obsidian_optional() {
  if ! has_tty; then
    warn "非交互模式，跳过 Obsidian 可选安装。手动安装：brew install --cask obsidian"
    return
  fi
  echo ""
  echo -e "${CYAN}[可选] 安装 Obsidian 知识库？${NC}"
  read -r -p "  是否安装？(y/N) " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    if brew list --cask obsidian &>/dev/null 2>&1; then
      warn "Obsidian 已安装，跳过"
    else
      info "正在通过 Homebrew 安装 Obsidian..."
      brew install --cask obsidian && info "Obsidian 安装成功！" || warn "安装失败，可手动：brew install --cask obsidian"
    fi
  else
    echo "  跳过。手动安装：brew install --cask obsidian"
  fi
}

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

# 3. 安装 Homebrew（如未安装）
if ! command -v brew &>/dev/null; then
  info "正在安装 Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew：$(brew --version | head -1)"
fi

# 4. 检查 / 安装 Git（Xcode CLT 由 Homebrew 安装器自动处理）
if ! command -v git &>/dev/null; then
  error "Git 未找到。请先安装 Xcode Command Line Tools：xcode-select --install，完成后重新运行此脚本。"
fi
info "Git：$(git --version)"

# 5. 安装 Hermes（安装器内含 setup wizard，SSH 下 wizard 会失败但不影响主安装）
if "$HOME/.local/bin/hermes" --version &>/dev/null 2>&1; then
  warn "Hermes 已安装（$("$HOME/.local/bin/hermes" --version 2>/dev/null | head -1 || echo '版本未知')），跳过安装步骤。"
else
  info "开始下载并安装 Hermes Agent..."
  # 用子 shell 捕获 wizard 的 /dev/tty 错误，不影响主流程
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash || true
fi

# 6. 刷新 PATH
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.zshrc" 2>/dev/null || true

# 7. 验证安装
HERMES_BIN="$HOME/.local/bin/hermes"
if [[ -x "$HERMES_BIN" ]]; then
  info "Hermes 安装成功！$("$HERMES_BIN" --version 2>/dev/null | head -1)"
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

install_obsidian_optional
