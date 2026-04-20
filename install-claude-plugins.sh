#!/usr/bin/env bash
# 一键安装 Claude Code 常用 plugins
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
title() { echo -e "\n${CYAN}── $1 ──${NC}"; }

echo "======================================"
echo " Claude Code Plugins 一键安装脚本"
echo "======================================"
echo ""

# 检查 claude CLI
if ! command -v claude &>/dev/null; then
  error "未找到 claude 命令，请先安装 Claude Code CLI：https://claude.ai/code"
fi
info "Claude CLI：$(claude --version 2>/dev/null || echo '已安装')"

# 安装函数：已安装则跳过，否则安装
install_plugin() {
  local plugin="$1"
  local desc="$2"
  if claude plugin list 2>/dev/null | grep -q "^${plugin%%@*}"; then
    warn "已安装：$plugin（$desc），跳过"
  else
    echo -e "  安装 ${CYAN}$plugin${NC}（$desc）..."
    claude plugin install "$plugin" --scope user 2>/dev/null && info "完成：$plugin" || warn "安装失败：$plugin，可手动重试"
  fi
}

# ── 开发工具 ──
title "开发工具"
install_plugin "feature-dev@claude-plugins-official"    "功能开发辅助"
install_plugin "code-review@claude-plugins-official"    "代码审查"
install_plugin "code-simplifier@claude-plugins-official" "代码简化"
install_plugin "commit-commands@claude-plugins-official" "git commit/push/PR 命令"
install_plugin "pr-review-toolkit@claude-plugins-official" "PR 审查工具集"

# ── 插件开发 ──
title "插件 & Agent 开发"
install_plugin "plugin-dev@claude-plugins-official"     "插件开发"
install_plugin "agent-sdk-dev@claude-plugins-official"  "Agent SDK 开发"
install_plugin "mcp-server-dev@claude-plugins-official" "MCP Server 开发"
install_plugin "skill-creator@claude-plugins-official"  "Skill 创建"

# ── 效率工具 ──
title "效率工具"
install_plugin "claude-hud@claude-hud"                  "状态栏 HUD"
install_plugin "hookify@claude-plugins-official"        "行为钩子管理"
install_plugin "playground@claude-plugins-official"     "HTML 交互 playground"
install_plugin "session-report@claude-plugins-official" "会话使用报告"
install_plugin "ralph-loop@claude-plugins-official"     "循环任务"
install_plugin "claude-md-management@claude-plugins-official" "CLAUDE.md 管理"

echo ""
echo "======================================"
info "全部插件安装完成！重启 Claude Code 生效。"
echo "======================================"

# ── 可选：Obsidian MCP ──
echo ""
echo -e "${CYAN}[可选] 安装 Obsidian MCP？${NC}"
echo "  让 Claude 直接读写你的 Obsidian vault。"
read -r -p "  是否安装？(y/N) " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  read -r -p "  请输入你的 vault 完整路径（例：/Users/你的名字/Documents/vault）: " vault_path
  if [[ -z "$vault_path" || ! -d "$vault_path" ]]; then
    warn "路径无效或不存在，跳过 Obsidian MCP 安装"
  else
    echo "  正在添加 Obsidian MCP..."
    claude mcp add obsidian -- npx -y obsidian-mcp "$vault_path" \
      && info "Obsidian MCP 添加成功！重启 Claude Code 生效。" \
      || warn "添加失败，可手动运行：claude mcp add obsidian -- npx -y obsidian-mcp \"$vault_path\""
  fi
else
  echo "  跳过。如需手动安装："
  echo "  claude mcp add obsidian -- npx -y obsidian-mcp \"/你的vault路径\""
fi
