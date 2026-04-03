---
name: latex-thesis-zh
description: Chinese LaTeX thesis assistant for existing .tex degree thesis projects (XeLaTeX/LuaLaTeX/latexmk). Use this skill whenever a user works on a Chinese master's or doctoral thesis needing compilation, GB/T 7714 bibliography checks, chapter structure mapping, template detection (thuthesis, pkuthss), terminology consistency, logic coherence review, heading lead-in checks, title optimization, de-AI editing, experiment chapter review, three-line table validation, or abstract structure diagnosis. Trigger even for single issues like "帮我编译论文", "检查国标格式", "看看绪论逻辑", "毕业论文", "学位论文", "硕士/博士论文", "三线表", "检查摘要", or "摘要结构".
metadata:
  category: academic-writing
  tags: [latex, thesis, chinese, phd, master, xelatex, gb7714, thuthesis, pkuthss, compilation, bibliography, structure]
argument-hint: "[main.tex] [--section SECTION] [--module MODULE]"
allowed-tools: Read, Glob, Grep, Bash(uv *), Bash(xelatex *), Bash(lualatex *), Bash(latexmk *), Bash(bibtex *), Bash(biber *)
---

# LaTeX 中文学位论文助手

使用此 skill 处理已有中文 LaTeX 学位论文项目中的定向问题。保持低摩擦：先判断最小匹配模块，再运行对应脚本，最后以论文审阅友好的格式返回问题和建议。

## Capability Summary

- 编译并诊断 XeLaTeX / LuaLaTeX / latexmk 构建问题。
- 检查论文格式、GB/T 7714 相关要求、章节结构、模板类型和术语一致性。
- 审阅逻辑连贯性、文献综述质量、章节/小节/四级标题导语完整性、实验章节写法、标题表达与 AI 痕迹。
- 在不破坏引用、标签和数学环境的前提下给出可落地的中文论文修改建议。

## Triggering

当用户拥有一个现有中文 `.tex` 学位论文项目，并希望你帮助处理以下任务时使用本 skill：

- 编译失败或工具链不确定
- 学位论文格式、国标或学校模板检查
- 章节结构梳理或模板识别
- 术语、缩略语、命名一致性检查
- 逻辑连贯性、文献综述质量、标题后导语完整性、跨章节闭合检查
- 标题优化、学术表达或去 AI 化检查
- 实验章节语言与结构审阅

即使用户只提到单一问题，例如“帮我判断是不是 thuthesis”“检查绪论逻辑”或“按 GB/T 7714 看参考文献”，也应触发本 skill。

## Do Not Use

不要将此 skill 用于：

- 英文会议或期刊论文
- Typst 项目
- 仅有 DOCX/PDF、没有 LaTeX 源文件的场景
- 纯文献调研、没有学位论文工程的任务
- 从零写一篇学位论文
- 多维度审稿、评分或投稿门控检查（使用 `paper-audit`）
- 英文会议/期刊论文编辑（使用 `latex-paper-en`）

## Module Router

| Module | Use when | Primary command | Read next |
| --- | --- | --- | --- |
| `compile` | Thesis build fails or toolchain is unclear | `uv run python $SKILL_DIR/scripts/compile.py main.tex` | `references/modules/COMPILE.md` |
| `format` | User asks about thesis formatting or GB/T 7714 layout | `uv run python $SKILL_DIR/scripts/check_format.py main.tex` | `references/modules/FORMAT.md` |
| `structure` | Need chapter/section map or thesis skeleton overview | `uv run python $SKILL_DIR/scripts/map_structure.py main.tex` | `references/STRUCTURE_GUIDE.md` |
| `consistency` | Terms, abbreviations, or naming drift across chapters | `uv run python $SKILL_DIR/scripts/check_consistency.py main.tex --terms` | `references/modules/CONSISTENCY.md` |
| `template` | Need to identify or validate thesis class/template | `uv run python $SKILL_DIR/scripts/detect_template.py main.tex` | `references/modules/TEMPLATE.md` |
| `bibliography` | GB/T 7714 or BibTeX validation | `uv run python $SKILL_DIR/scripts/verify_bib.py references.bib --standard gb7714` | `references/modules/BIBLIOGRAPHY.md` |
| `title` | Optimize Chinese thesis titles and chapter titles | `uv run python $SKILL_DIR/scripts/optimize_title.py main.tex --check` | `references/modules/TITLE.md` |
| `deai` | Reduce AI-writing traces in visible Chinese prose | `uv run python $SKILL_DIR/scripts/deai_check.py main.tex --section introduction` | `references/modules/DEAI.md` |
| `logic` | Check logical coherence, introduction funnel, heading lead-ins, lit review quality, chapter mainline, and cross-section closure | `uv run python $SKILL_DIR/scripts/analyze_logic.py main.tex --section related` | `references/modules/LOGIC.md` |
| `experiment` | Review experiment chapter language, discussion layering, and conclusion completeness | `uv run python $SKILL_DIR/scripts/analyze_experiment.py main.tex --section experiments` | `references/modules/EXPERIMENT.md` |
| `tables` | 表格结构校验、三线表生成、booktabs 检查 | `uv run python $SKILL_DIR/scripts/check_tables.py main.tex` | `references/modules/TABLES.md` |
| `abstract` | 摘要五要素结构诊断与字数校验 | `uv run python $SKILL_DIR/scripts/analyze_abstract.py main.tex --lang zh` | `references/modules/ABSTRACT.md` |

## Required Inputs

- 论文入口文件，例如 `main.tex`。
- 可选 `--section SECTION`，当用户只关注某一章或某一节。
- 可选 bibliography 路径，当任务聚焦参考文献。
- 可选学校/模板上下文，当用户关心 `thuthesis`、`pkuthss` 或特定高校要求。

如果参数不完整，只追问入口 `.tex` 文件和目标模块，不额外扩展问题。

## Output Contract

- 尽量使用 LaTeX 友好的审阅格式返回问题：`% MODULE (L##) [Severity] [Priority]: ...`
- 明确给出执行的命令；若脚本失败，必须报告退出码和关键 stderr。
- 将“检查结果”和“建议改写”分开陈述，避免把脚本诊断和正文润色混在一起。
- 默认保留 `\cite{}`、`\ref{}`、`\label{}`、数学环境、参考文献键和模板宏命令。

## Workflow

1. Parse `$ARGUMENTS` for entry file and module. If missing, ask for the thesis `.tex` entry file and target module.
2. Read the one reference file tied to that module (see "Read next" column).
3. Run the corresponding script with `uv run python ...`.
4. Return findings as `% Module (L##) [Severity] [Priority]: ...`. Report exact command and exit code on failure.
5. If template and structure are both unclear, run `template` first, then `structure`.

## Safety Boundaries

- Never fabricate citations, funding statements, acknowledgements, or academic claims.
- Never rewrite `\cite{}`, `\ref{}`, `\label{}`, math blocks, or bibliography keys unless explicitly asked.
- Treat title suggestions, de-AI revisions, and logic comments as proposals; keep source-preserving checks separate from edits.

## Reference Map

- `references/COMPILATION.md`: compilation strategy and toolchain diagnosis.
- `references/GB_STANDARD.md`: GB/T 7714 and bibliography-related checks.
- `references/STRUCTURE_GUIDE.md`: thesis structure expectations and chapter mapping.
- `references/LOGIC_COHERENCE.md`: logic, coherence, heading lead-ins, consistency, and literature-review expectations.
- `references/TITLE_OPTIMIZATION.md`: Chinese academic title heuristics.
- `references/DEAI_GUIDE.md`: de-AI review heuristics.
- `references/modules/EXPERIMENT.md`: experiment-chapter review criteria.
- `references/UNIVERSITIES/`: school/template-specific constraints after template detection.

只读取当前模块所需的参考文件，避免一次加载整套指南。

## Example Requests

- “帮我定位这个中文学位论文 `main.tex` 为什么 XeLaTeX 一直编译失败，并判断是不是 thuthesis 模板。”
- “请梳理这篇硕士论文的章节结构，并检查术语和缩略语是否前后统一。”
- “按 GB/T 7714 帮我检查参考文献，再看看绪论是不是有明显 AI 腔。”
- “检查 related work 的逻辑链条和研究空白推导，但不要动任何引用和公式。”
- “帮我检查每一章、每一节、四级标题后有没有先写导语，不要只看格式。”
