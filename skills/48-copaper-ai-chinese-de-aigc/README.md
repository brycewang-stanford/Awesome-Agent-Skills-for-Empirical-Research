# 中文学术降 AIGC Skill

> **作者**：CoPaper.AI · Stanford REAP
> **许可证**：MIT
> **适用工具**：Claude Code / Cursor / Codex / Gemini CLI / 任何支持 Agent Skills 标准的 AI 助手

一个面向**中文学术实证论文**的降 AIGC 检测率 Skill。与通用英文 humanizer 不同，它针对**知网 AMLC、万方、维普通达、Turnitin 中文版**的检测机制设计。

## 为什么需要一个专门的中文 Skill？

现有 GitHub 上优秀的 humanizer 都是面向英文的：

| Skill | 语言 | 覆盖 |
|-------|------|------|
| [blader/humanizer](https://github.com/blader/humanizer) | 英文 | 通用 20+ 模式 |
| [matsuikentaro1/humanizer_academic](https://github.com/matsuikentaro1/humanizer_academic) | 英文 | 23 类学术模式 |
| [stephenturner/skill-deslop](https://github.com/stephenturner/skill-deslop) | 英文 | 科学写作 |
| [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop) | 英文 | 通用散文 + 5 维评分 |
| [conorbronsdon/avoid-ai-writing](https://github.com/conorbronsdon/avoid-ai-writing) | 英文 | 结构化审计 |

**中文 AI 文本有完全不同的结构性特征**——四字套话、虚词堆叠、机械连接词、总分总对称结构，这些模式在英文 humanizer 中完全不涉及。本 Skill 专门解决中文场景。

## 核心设计

**五步闭环**：定位 → 诊断 → 差异化改写 → 五维自评 → 二次复查

**17 类模式库**：详见 [`references/patterns.md`](references/patterns.md)

**五维评分**：具体性、节奏性、谨慎性、隐衔接、研究者语气（[`references/scoring.md`](references/scoring.md)）

**分章节策略**：摘要/引言/文献综述/方法/结果/讨论/结论的改写力度各不相同（[`references/academic-sections.md`](references/academic-sections.md)）

**12 组案例**：覆盖实证论文七个章节的改写前后对照（[`references/examples.md`](references/examples.md)）

## 安装

方法一：放到 Claude Code 本地 skills 目录：

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/brycewang-stanford/Awesome-Agent-Skills-for-Empirical-Research.git /tmp/awesome-skills
cp -r /tmp/awesome-skills/skills/48-copaper-ai-chinese-de-aigc ~/.claude/skills/chinese-de-aigc
```

方法二：放到项目的 `.claude/skills/` 目录（仅该项目可用）：

```bash
mkdir -p .claude/skills
cp -r skills/48-copaper-ai-chinese-de-aigc .claude/skills/chinese-de-aigc
```

## 使用

在 Claude Code 中，用以下任一触发词调用：

- "请对这段文本降 AIGC 检测率"
- "把这篇论文改得不像 AI 写的"
- "走 chinese-de-aigc 五步闭环"
- "诊断这段文字的 AI 痕迹，给出修改建议"

## 与其他 Skill 配合

本 Skill 是 Awesome Agent Skills for Empirical Research 仓库的第 48 号 Skill。推荐组合使用：

| 场景 | 推荐组合 |
|------|---------|
| 中文论文降 AIGC | `chinese-de-aigc`（本 Skill）+ `revision-guard`（防过度修改）|
| 中英双语论文 | `chinese-de-aigc` + `humanizer_academic`（英文对应版本）|
| 需要审计报告 | `chinese-de-aigc` + `avoid-ai-writing`（结构化审计）|

## 重要声明

本 Skill 的目标是**让人工写作和 AI 辅助写作的文本回归到真实研究者的语言分布**。

✅ 适用：研究者自己写的初稿被 AIGC 检测误判；AI 辅助起草 + 人工修改定稿的混合场景
❌ 不适用：完全 AI 生成的论文，希望零改动通过检测；学术不端场景

**学术诚信优先于检测率**。

## 贡献

欢迎通过 PR 扩充：新的 AI 痕迹模式、更多章节级改写案例、中文学科特有的 hedge 表达库。

## 致谢

- 设计思想参考了 blader、matsuikentaro1、stephenturner、hardikpandya、conorbronsdon 等英文 humanizer skill
- 模式库的部分识别规则参考了 CHI 2025 和 Georgetown 2025 的 AI 写作检测研究
- 分章节策略借鉴了 Emory University Pedro Sant'Anna 的学术写作工作流
