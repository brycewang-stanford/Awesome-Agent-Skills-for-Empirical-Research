<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/fuhaoda/stats-paper-writing-agent-skills
  项目名称: stats-paper-writing-agent-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Title guidance (statistical papers)

## What a good title should do
A strong title should:
- **Predict the paper’s content** (so the right readers click and keep reading).
- **Attract the reader** (without hype).
- **Signal the tone** (methods paper vs application paper).
- **Contain the key search terms** your audience will use.

## Practical rules
- **Write the title late**: after you know the real contribution.
- Prefer **key phrases** over full sentences.
- Keep it **short and specific** (avoid filler like “A study of …”).
- Avoid unexplained abbreviations.
- Put the **most informative words early**.
- Avoid mathematical symbols in the title unless required by the venue.

## Common title patterns
Pick one pattern and fill in the blanks.

### Pattern A — Method + task + setting
> *[Method]* for *[Task]* in *[Setting/Data]*

Example skeleton:
- “Bayesian … for … in …”
- “Regularized … for … with …”

### Pattern B — Problem framing
> *[Task/Problem]* under *[Constraint]*

Example skeleton:
- “Inference for … under …”
- “Prediction with … under …”

### Pattern C — Contribution statement (careful: don’t overclaim)
> *A [new/adaptive/robust] [method/model] for [task]*

Avoid words like “first”/“unique” unless you can defend them.

### Pattern D — Application first (for applied journals)
> *[Domain/Outcome]*: *[Statistical method]*

## Quick checklist
- Does the title clearly indicate:
  - the **problem/task**?
  - the **method/model family**?
  - the **application or data setting** (if relevant)?
- Would someone searching for the method/domain find this paper?
- Is it free of empty phrases (“novel”, “new”, “powerful”)?

## Output format tips (LaTeX)
Return a ready-to-paste line:
```tex
	itle{...}
```

If you propose multiple options, provide 3–7 candidates and briefly explain the tradeoffs (precision vs breadth, methods vs application emphasis).
