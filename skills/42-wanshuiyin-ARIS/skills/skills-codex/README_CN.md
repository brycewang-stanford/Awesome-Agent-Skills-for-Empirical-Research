# skills-codex 说明

## 1. 这个包是什么

这是一个面向 **Codex** 的技能包目录，当前版本已经与主线 `skills/` 对齐：

- 保留主线科研技能的同名同步集
- 同步包含 `training-check`、`ablation-planner`、`result-to-claim`、`rebuttal`
- 同步包含 `mermaid-diagram`
- 附带 `shared-references/`，但它**不计入 skill 数量**

数量对比：

- 主线 `skills/` 当前技能数：`39`
- 本包技能数：`39`
- 另附支持目录：`shared-references/`

本包路径结构是：

```text
skills/skills-codex/
  <skill-name>/
    SKILL.md
    ...
  shared-references/
    ...
```

## 2. 和主线相比做了哪些变动

### 2.1 范围控制

本包只保留：

- 主线 `skills/` 中已有的同名技能
- 少量确实需要的资源目录

因此，本包 **不包含**：

- `doc`
- `pdf`
- `.system/*`

### 2.2 Codex 适配原则

- 保留原技能的任务边界和工作流
- 旧的控制型写法改成 `spawn_agent` / `send_input`
- 外部能力接入说明可以保留，但不迁移对应服务配置
- 尽量做最小修改，不把技能重写成另一套风格

### 2.3 哪些不是单文件

当前不是单文件的有：

- `paper-write`
- `comm-lit-review`
- `shared-references`

原因：

- `paper-write` 依赖 `templates/`
- `comm-lit-review` 依赖 `references/`
- `paper-plan` / `paper-write` 会引用 `shared-references/`

## 3. 如何安装

```bash
mkdir -p ~/.codex/skills
cp -a skills/skills-codex/* ~/.codex/skills/
```

## 4. 安装时需要知道的边界

本包只处理**技能文件**，不处理：

- Python 依赖
- LaTeX / Poppler / GPU / SSH / conda 环境
- MCP 配置
- API Key / 环境变量

也就是说，本包解决的是 **技能文件迁移**，不是 **运行环境迁移**。
