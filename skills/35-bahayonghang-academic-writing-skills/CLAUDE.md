# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic Writing Skills is a Claude Code skill suite (v3.0.0) for post-writing polish and validation of academic papers. It ships five skills under `academic-writing-skills/`, each installable to `~/.claude/skills/`. Python 3.10+, MIT license.

## Build & Development Commands

Task runner: `just` (requires `uv` for Python). All commands run through `uv run --extra dev`.

| Command | What it does |
|---|---|
| `just install` | `uv sync --extra dev` — install all deps |
| `just lint` | `ruff format --check . && ruff check .` |
| `just typecheck` | `pyright` |
| `just test` | `python -m pytest tests/` |
| `just ci` | lint → typecheck → test (full pipeline) |
| `just fix` | `ruff format . && ruff check --fix .` |
| `just docs` | VitePress dev server (`cd docs && npm run docs:dev`) |
| `just doc-build` | Build static docs site |
| `just clean` | Remove `__pycache__`, `.pytest_cache`, `.ruff_cache` |

Run a single test file: `uv run --extra dev python -m pytest tests/test_parsers.py`
Run a single test function: `uv run --extra dev python -m pytest tests/test_parsers.py::test_latex_split_sections`

## Architecture

### Skill Layout Convention

Each skill directory follows this structure:
```
academic-writing-skills/{skill-name}/
├── SKILL.md          # Entry point & contract (Claude reads this to activate)
├── scripts/          # Python automation tools
│   └── parsers.py    # Shared parser base class (per-skill copy)
├── references/       # Decision-making guides, style rules, forbidden terms
│   └── modules/      # Per-module detailed references
├── examples/         # Concrete usage examples
└── agents/           # Agent persona definitions (paper-audit, industrial-ai-research)
```

### Five Skills

| Skill | Input | Purpose |
|---|---|---|
| `latex-paper-en` | `.tex` | English conference/journal papers (IEEE, ACM, NeurIPS, ICML) |
| `latex-thesis-zh` | `.tex` | Chinese degree theses (GB/T 7714-2015; thuthesis, pkuthss, etc.) |
| `typst-paper` | `.typ` | Bilingual Typst papers with millisecond compilation |
| `paper-audit` | `.tex`/`.typ`/`.pdf` | Multi-perspective pre-submission audit with scoring |
| `industrial-ai-research` | topic query | Literature synthesis for industrial AI domains (no scripts) |

### Parser Hierarchy

All script-based skills share a common `DocumentParser` ABC in their `scripts/parsers.py`:
- `DocumentParser` (ABC) → `LatexParser`, `TypstParser`
- Key methods: `split_sections()`, `extract_visible_text()`, `clean_text()`, `get_comment_prefix()`
- Each skill has its own copy of `parsers.py` (not a shared import) — keep them aligned when changing shared behavior.

### Test Structure

Tests in `tests/` import scripts via `sys.path` manipulation in `conftest.py`. The conftest exports path constants:
- `SCRIPT_DIR_EN` — latex-paper-en/scripts
- `SCRIPT_DIR_ZH` — latex-thesis-zh/scripts
- `SCRIPT_DIR_TYPST` — typst-paper/scripts
- `SCRIPT_DIR_AUDIT` — paper-audit/scripts

Only `SCRIPT_DIR_EN` and `SCRIPT_DIR_AUDIT` are added to `sys.path` by default. Tests use bare imports like `from parsers import LatexParser`.

### paper-audit Agent System

`paper-audit` uses four reviewer agents that produce independent assessments, then a synthesis agent consolidates them:
- `methodology_reviewer_agent.md` — research design, statistical rigor
- `domain_reviewer_agent.md` — literature coverage, theoretical framework
- `critical_reviewer_agent.md` — logical fallacies, argument challenges
- `synthesis_agent.md` — consensus classification, revision roadmap

### Documentation Site

VitePress bilingual docs (EN root + `zh/` locale) in `docs/`. Deployed to GitHub Pages on release publish via `.github/workflows/deploy.yml`. Base URL: `/academic-writing-skills/`.

## Critical Rules

**Never break these constraints — they apply across all skills:**

1. **Never modify** content inside `\cite{}`, `\ref{}`, `\label{}`, math environments (LaTeX), or `@cite`, `<label>`, `$...$` (Typst).
2. **Never fabricate** bibliography entries, author names, venue names, or experimental results.
3. **Never change** protected terminology without explicit permission (see each skill's `references/FORBIDDEN_TERMS.md`).
4. **Output changes as diff/suggestion blocks** with severity and priority fields. Tag source as `[Script]` (automated) or `[LLM]` (agent judgment).

## Code Style

- Python 3.10+ target. Ruff enforces 100-char line length with rules: E, W, F, I, N, UP, B, C4, SIM.
- `snake_case` for Python modules/functions/tests. Skill directories are `kebab-case`.
- Run `just fix` before submitting changes.
- Pyright with `typeCheckingMode = "off"` (lenient — focus is on runtime correctness).

## Commit Convention

Scoped Conventional Commits: `docs: ...`, `refactor(latex-thesis-zh): ...`, `feat(paper-audit): ...`. Keep commits focused by skill or subsystem.
