# Mac 一键部署脚本

给全新的开发机器安装常用 AI coding / agent 工具。

默认推荐使用 `install.sh` 作为统一入口；旧的单项脚本仍保留，方便只安装某一个组件。

脚本面向 Apple Silicon Mac，判断逻辑是 `arm64`，因此不枚举 M1/M2/M3/M4/M5；只要是 M 系列芯片就属于支持范围。

## 一条命令

让对方打开“终端”，复制下面这一整行，粘贴进去回车：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh | bash
```

默认安装：

- Codex CLI
- OpenClaw
- Hermes Agent

脚本不会安装 Obsidian，也不会询问 Obsidian 相关配置。

安装时会显示中文步骤进度条和当前正在做什么。过程中如果 macOS 要求输入密码，对方输入自己这台 Mac 的登录密码即可。

## 本机一条命令

本机默认安装：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh)
```

## SSH 高级用法

如果你已经能 SSH 登录对方机器，也可以远程触发：

```bash
ssh -tt user@mac-host 'curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh | bash'
```

`-tt` 用来分配远程终端，这样中文提示、步骤进度条和需要输入的选择都能正常显示。

直接安装 Codex、OpenClaw、Hermes：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --codex --openclaw --hermes
```

直接安装 Claude Code、Claude 插件、OpenClaw、Hermes：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --claude --with-claude-plugins --openclaw --hermes
```

跳过 OpenClaw / Hermes 的首次向导：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --codex --openclaw --hermes --skip-setup
```

先看会做什么，不执行安装：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install.sh) --codex --openclaw --hermes --dry-run
```

## 可选组件

| 选项 | 内容 |
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

## 安装后配置

```bash
codex                  # 启动 Codex
claude                 # 启动 Claude Code
openclaw onboard       # OpenClaw 首次配置
hermes setup           # Hermes 完整配置向导
```

## 说明

- Codex 使用 OpenAI 官方安装器：`https://chatgpt.com/codex/install.sh`
- Claude Code 使用 Anthropic 官方安装器：`https://claude.ai/install.sh`
- OpenClaw 使用官方安装器：`https://openclaw.ai/install.sh`
- Hermes 使用 Nous Research 官方安装器：`https://hermes-agent.nousresearch.com/install.sh`
- 已安装的组件会跳过，重复执行是安全的
- 安装过程会显示中文步骤进度条和当前正在执行的内容
- 安装完成后如果命令找不到，重新打开终端
