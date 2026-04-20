
# Mac Mini 一键部署脚本

三个脚本，一键在 Apple Silicon Mac 上部署 AI 工具环境（agent + 知识库）。

---

## 文件说明

| 文件 | 包含内容 |
|---|---|
| `install-hermes.sh` | Homebrew → Git → Hermes Agent → [可选] Obsidian |
| `install-openclaw.sh` | Homebrew → Node.js → OpenClaw → [可选] Obsidian |
| `install-claude-plugins.sh` | Claude Code 常用 plugins → [可选] Obsidian MCP |

---

## 使用方式

### 方式一：远程一行执行（推荐）

在任何地方，目标机器上直接跑：

```bash
# 安装 Hermes Agent
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-hermes.sh)

# 安装 OpenClaw
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-openclaw.sh)

# 安装 Claude Code 常用 Plugins
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/fslot2601-source/mac-deploy-scripts@main/install-claude-plugins.sh)
```

### 方式二：SSH 推过去跑

在你自己的机器上，把脚本推到目标机器执行：

```bash
# Hermes
ssh user@192.168.x.x "bash -s" < install-hermes.sh

# OpenClaw
ssh user@192.168.x.x "bash -s" < install-openclaw.sh

# Claude Plugins
ssh user@192.168.x.x "bash -s" < install-claude-plugins.sh
```

> 注意：SSH 模式下可选步骤（Obsidian）的交互提示仍然有效，会在远程机器上等待输入。

### 方式三：直接在目标机器上跑

把脚本复制到目标 Mac Mini，然后：

```bash
bash install-hermes.sh
bash install-openclaw.sh
bash install-claude-plugins.sh
```

---

## 安装后配置

### Hermes Agent

```bash
hermes setup     # 完整配置向导（推荐首次运行）
hermes model     # 选择 LLM 提供商（OpenAI / Anthropic / 本地等）
hermes doctor    # 诊断环境问题
hermes           # 启动对话
```

### OpenClaw

```bash
openclaw setup                        # 初始化配置向导
openclaw onboard --install-daemon     # 设为开机自启后台服务（可选）
```

---

## 注意事项

- 仅支持 Apple Silicon（M1/M2/M3/M4），Intel Mac 会直接报错退出
- 脚本幂等：已安装则跳过，重复执行安全
- Homebrew 如未安装会自动安装（需要网络，首次较慢）
- 安装完如果命令找不到，重启终端或运行 `source ~/.zshrc`
