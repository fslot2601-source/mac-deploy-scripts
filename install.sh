#!/usr/bin/env bash
# Fresh Mac bootstrap installer.
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

BASE_URL="${MAC_DEPLOY_BASE_URL:-https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main}"
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
if [[ -n "$SCRIPT_SOURCE" && -f "$SCRIPT_SOURCE" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd -P || true)"
fi

INSTALL_CODEX=0
INSTALL_CLAUDE=0
INSTALL_CLAUDE_PLUGINS=0
INSTALL_OPENCLAW=0
INSTALL_HERMES=0
DRY_RUN=0
SKIP_SETUP=0
PROGRESS_TOTAL=0
PROGRESS_CURRENT=0

usage() {
  cat <<'EOF'
用法:
  bash install.sh
  bash install.sh --codex --openclaw --hermes
  bash install.sh --claude --with-claude-plugins --openclaw --hermes

默认:
  不传安装选项时，安装 Codex、OpenClaw、Hermes，不安装 Obsidian。

选项:
  --codex                 安装 Codex CLI
  --claude                安装 Claude Code CLI
  --with-claude-plugins   安装 Claude Code 常用插件
  --openclaw              安装 OpenClaw
  --hermes                安装 Hermes Agent
  --all                   安装 Codex、Claude Code、OpenClaw、Hermes
  --skip-setup            跳过支持该选项的首次配置向导
  --dry-run               只显示计划和命令，不执行安装
  -h, --help              显示帮助
EOF
}

progress_bar() {
  local current="$1"
  local total="$2"
  local width=24
  local filled=0
  local empty=0
  local bar=""
  local i

  if (( total > 0 )); then
    filled=$(( current * width / total ))
  fi
  empty=$(( width - filled ))

  for ((i = 0; i < filled; i++)); do bar+="#"; done
  for ((i = 0; i < empty; i++)); do bar+="-"; done
  printf '[%s]' "$bar"
}

start_step() {
  local label="$1"
  PROGRESS_CURRENT=$((PROGRESS_CURRENT + 1))
  echo ""
  echo -e "${CYAN}$(progress_bar "$PROGRESS_CURRENT" "$PROGRESS_TOTAL") 步骤 ${PROGRESS_CURRENT}/${PROGRESS_TOTAL}${NC} 当前：$label"
}

finish_step() {
  info "完成：$1"
}

refresh_path() {
  export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" >/dev/null 2>&1 || true
  fi
}

parse_args() {
  if [[ "$#" -eq 0 ]]; then
    return
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --codex)
        INSTALL_CODEX=1
        ;;
      --claude)
        INSTALL_CLAUDE=1
        ;;
      --with-claude-plugins)
        INSTALL_CLAUDE_PLUGINS=1
        ;;
      --openclaw)
        INSTALL_OPENCLAW=1
        ;;
      --hermes)
        INSTALL_HERMES=1
        ;;
      --all)
        INSTALL_CODEX=1
        INSTALL_CLAUDE=1
        INSTALL_OPENCLAW=1
        INSTALL_HERMES=1
        ;;
      --skip-setup)
        SKIP_SETUP=1
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "未知选项：$1"
        ;;
    esac
    shift
  done
}

any_selected() {
  [[ "$INSTALL_CODEX" == "1" || "$INSTALL_CLAUDE" == "1" || "$INSTALL_CLAUDE_PLUGINS" == "1" || "$INSTALL_OPENCLAW" == "1" || "$INSTALL_HERMES" == "1" ]]
}

select_default_install() {
  INSTALL_CODEX=1
  INSTALL_OPENCLAW=1
  INSTALL_HERMES=1
  SKIP_SETUP=1
}

selected_count() {
  local count=1
  [[ "$INSTALL_CODEX" == "1" ]] && count=$((count + 1))
  [[ "$INSTALL_CLAUDE" == "1" ]] && count=$((count + 1))
  [[ "$INSTALL_CLAUDE_PLUGINS" == "1" ]] && count=$((count + 1))
  [[ "$INSTALL_OPENCLAW" == "1" ]] && count=$((count + 1))
  [[ "$INSTALL_HERMES" == "1" ]] && count=$((count + 1))
  echo "$count"
}

run_shell_step() {
  local label="$1"
  local cmd="$2"

  start_step "$label"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[dry-run] $cmd"
    finish_step "$label"
    return
  fi

  eval "$cmd"
  refresh_path
  finish_step "$label"
}

check_system() {
  local os
  local arch
  local macos

  start_step "检查系统和 M 系列芯片"
  os="$(uname -s 2>/dev/null || true)"
  arch="$(uname -m 2>/dev/null || true)"

  if [[ "$os" != "Darwin" ]]; then
    error "此脚本面向 macOS。当前系统：${os:-未知}"
  fi

  if [[ "$arch" != "arm64" ]]; then
    error "此脚本支持 M 系列 Apple Silicon Mac（arm64）。当前架构：${arch:-未知}"
  fi

  macos="$(sw_vers -productVersion 2>/dev/null || echo unknown)"
  info "系统：macOS ${macos}"
  info "芯片：Apple Silicon / M 系列（${arch}）"
  finish_step "检查系统和 M 系列芯片"
}

install_codex() {
  if [[ "$DRY_RUN" != "1" ]] && command -v codex >/dev/null 2>&1; then
    start_step "检查 Codex CLI"
    info "已安装，跳过：$(codex --version 2>/dev/null || echo Codex CLI)"
    finish_step "检查 Codex CLI"
    return
  fi

  run_shell_step "安装 Codex CLI" \
    "curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=true sh"
}

install_claude() {
  if [[ "$DRY_RUN" != "1" ]] && command -v claude >/dev/null 2>&1; then
    start_step "检查 Claude Code CLI"
    info "已安装，跳过：$(claude --version 2>/dev/null || echo Claude Code)"
    finish_step "检查 Claude Code CLI"
    return
  fi

  run_shell_step "安装 Claude Code CLI" \
    "curl -fsSL https://claude.ai/install.sh | bash"
}

install_claude_plugins() {
  refresh_path
  if ! command -v claude >/dev/null 2>&1 && [[ "$DRY_RUN" != "1" ]]; then
    error "未找到 claude 命令。请加上 --claude，或先安装 Claude Code。"
  fi

  if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/install-claude-plugins.sh" ]]; then
    run_shell_step "安装 Claude Code 常用插件" "bash '$SCRIPT_DIR/install-claude-plugins.sh'"
  else
    run_shell_step "安装 Claude Code 常用插件" "bash <(curl -fsSL '$BASE_URL/install-claude-plugins.sh')"
  fi
}

install_openclaw() {
  if [[ "$DRY_RUN" != "1" ]] && command -v openclaw >/dev/null 2>&1; then
    start_step "检查 OpenClaw"
    info "已安装，跳过：$(openclaw --version 2>/dev/null || echo OpenClaw)"
    finish_step "检查 OpenClaw"
    return
  fi

  local args=""
  if [[ "$SKIP_SETUP" == "1" ]]; then
    args="--no-onboard --no-prompt"
  fi

  run_shell_step "安装 OpenClaw" \
    "curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash -s -- $args"
}

install_hermes() {
  if [[ "$DRY_RUN" != "1" ]] && command -v hermes >/dev/null 2>&1; then
    start_step "检查 Hermes Agent"
    info "已安装，跳过：$(hermes --version 2>/dev/null | head -1 || echo Hermes Agent)"
    finish_step "检查 Hermes Agent"
    return
  fi

  local args=""
  if [[ "$SKIP_SETUP" == "1" ]]; then
    args="--skip-setup --non-interactive"
  fi

  run_shell_step "安装 Hermes Agent" \
    "curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- $args"
}

print_summary() {
  echo ""
  echo -e "${CYAN}安装计划${NC}"
  [[ "$INSTALL_CODEX" == "1" ]] && echo "- Codex CLI"
  [[ "$INSTALL_CLAUDE" == "1" ]] && echo "- Claude Code CLI"
  [[ "$INSTALL_CLAUDE_PLUGINS" == "1" ]] && echo "- Claude Code 常用插件"
  [[ "$INSTALL_OPENCLAW" == "1" ]] && echo "- OpenClaw"
  [[ "$INSTALL_HERMES" == "1" ]] && echo "- Hermes Agent"
  [[ "$SKIP_SETUP" == "1" ]] && echo "- 跳过支持该选项的首次配置向导"
  return 0
}

print_next_steps() {
  echo ""
  echo -e "${CYAN}后续操作${NC}"
  if [[ "$INSTALL_CODEX" == "1" && "$INSTALL_OPENCLAW" == "1" && "$INSTALL_HERMES" == "1" && "$INSTALL_CLAUDE" == "0" && "$INSTALL_CLAUDE_PLUGINS" == "0" ]]; then
    echo "- 安装完成后，重新打开终端。"
    echo "- 想用 Codex：输入 codex"
    echo "- OpenClaw 和 Hermes 已安装；后续需要时再运行 openclaw onboard 或 hermes setup。"
    return
  fi

  [[ "$INSTALL_CODEX" == "1" ]] && echo "- 运行：codex"
  [[ "$INSTALL_CLAUDE" == "1" ]] && echo "- 运行：claude"
  [[ "$INSTALL_OPENCLAW" == "1" ]] && echo "- 运行：openclaw onboard"
  [[ "$INSTALL_HERMES" == "1" ]] && echo "- 运行：hermes setup"
  echo "- 如果命令暂时找不到，请重新打开终端。"
}

main() {
  refresh_path
  parse_args "$@"
  if ! any_selected; then
    select_default_install
  fi

  PROGRESS_TOTAL="$(selected_count)"
  print_summary
  check_system
  [[ "$INSTALL_CODEX" == "1" ]] && install_codex
  [[ "$INSTALL_CLAUDE" == "1" ]] && install_claude
  [[ "$INSTALL_CLAUDE_PLUGINS" == "1" ]] && install_claude_plugins
  [[ "$INSTALL_OPENCLAW" == "1" ]] && install_openclaw
  [[ "$INSTALL_HERMES" == "1" ]] && install_hermes
  print_next_steps
}

main "$@"
