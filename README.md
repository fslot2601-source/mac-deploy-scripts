# Mac 一键安装 AI 工具

适用于 M 系列 Apple Silicon Mac。脚本用 `arm64` 判断芯片，所以 M1、M2、M3、M4、M5 以及后续 M 系列都按同一规则支持。

## 发给朋友

让对方打开“终端”，复制下面这一整行，粘贴进去回车：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh | bash
```

默认会安装：

- Codex CLI
- OpenClaw
- Hermes Agent

不会安装 Obsidian，也不会询问 Obsidian 相关配置。

安装时会显示中文步骤进度条和当前正在做什么。如果 macOS 要求输入密码，对方输入自己这台 Mac 的登录密码即可。

安装完成后，重新打开终端，输入：

```bash
codex
```

## 其他用法

只预览安装流程，不真的安装：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --dry-run
```

安装 Claude Code、Claude 插件、OpenClaw、Hermes：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --claude --with-claude-plugins --openclaw --hermes
```

远程 SSH 触发安装：

```bash
ssh -tt user@mac-host 'curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh | bash'
```

## 可选参数

| 参数 | 内容 |
|---|---|
| `--codex` | 安装 Codex CLI |
| `--claude` | 安装 Claude Code CLI |
| `--with-claude-plugins` | 安装 Claude Code 常用插件 |
| `--openclaw` | 安装 OpenClaw |
| `--hermes` | 安装 Hermes Agent |
| `--all` | 安装 Codex、Claude Code、OpenClaw、Hermes |
| `--skip-setup` | 跳过支持该选项的首次配置向导 |
| `--dry-run` | 只打印计划，不执行安装 |

## 单项脚本

```bash
# Hermes Agent
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-hermes.sh)

# OpenClaw
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-openclaw.sh)

# Claude Code plugins
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-claude-plugins.sh)
```

## 安装器来源

- Codex: `https://chatgpt.com/codex/install.sh`
- Claude Code: `https://claude.ai/install.sh`
- OpenClaw: `https://openclaw.ai/install.sh`
- Hermes: `https://hermes-agent.nousresearch.com/install.sh`
