# CLAUDE.md -- AI Assistant Instructions

**Your role:** Research assistant and workflow orchestrator for an academic research project.
For full documentation (installation, workflows, Overleaf sync, reproducibility), see `README.md`.

**First actions for every session:**

1. Read this file completely
2. Check `./handoffs/` for the most recent entry to understand prior work
3. Review the project context below for current status
4. Begin work or ask clarifying questions

---

## Project Context

| Field | Value |
| ----- | ----- |
| **Title** | `[FILL: Project title]` |
| **Authors** | `[FILL: Author names and affiliations]` |
| **Stage** | `[FILL: Idea / Data collection / Analysis / Writing / Revision]` |
| **Primary tools** | R, Python, Stata, Quarto, LaTeX |
| **Reference manager** | Zotero (exports to `references.bib`) |
| **Manuscript** | `index.qmd` (Quarto manuscript project) |
| **Environment** | `uv` + `pyproject.toml` (Python 3.12) |
| **Data source** | `[FILL: e.g., OSF repository, survey, API]` |

---

## Critical Rules

These are non-negotiable behavioral constraints.

1. **Never delete data or code** -- Do not delete files in `data/`, `code/`, `notebooks/`, `references/`, or `templates/`. Move old versions to `legacy/`.
2. **Stay within this directory** -- All work must remain inside this project folder. Ask before accessing external resources.
3. **Preserve raw data** -- Files in `data/rawData/` are source-of-truth inputs. Never modify them.
4. **Document progress** -- Write a handoff report to `./handoffs/` after significant work or before ending a session.

---

## Key Paths

| Path | Purpose |
| ---- | ------- |
| `index.qmd` | Main manuscript source |
| `_quarto.yml` | Quarto config (formats, notebook registrations) |
| `references.bib` | Bibliography (from Zotero) |
| `config.py` / `config.R` | Reproducibility config (seed = 42, project paths) |
| `pyproject.toml` / `uv.lock` | Python dependencies |
| `jupytext.toml` | Cell metadata filter |
| `notebooks/` | Jupyter notebooks (`.ipynb` + `.md:myst` pairs) |
| `data/rawData/` | Raw source data (never modify) |
| `scripts/render.sh` | Clean render + Overleaf staging |
| `handoffs/` | Session handoff reports |
| `.claude/skills/` | 24 skill definitions (SKILL.md with YAML frontmatter) |
| `.env` | API keys and secrets (gitignored, never commit) |

---

## Skills

Invoke with `/project:<name>`. See `README.md` § Available Skills for full descriptions and SKILL.md links.

**Build & Execution** -- Side-effect skills, manual invocation only.

| `/project:render` | `/project:execute` | `/project:init` | `/project:sync-tex` |
| --- | --- | --- | --- |

**Notebook & Presentation Creation** -- Create new files; accept arguments.

| `/project:new-notebook` | `/project:new-analysis` | `/project:new-slide-deck` |
| --- | --- | --- |

**Writing & Results** -- Draft prose, interpret output, format tables.

| `/project:draft-section` | `/project:abstract` | `/project:interpret-results` |
| --- | --- | --- |
| `/project:regression-table` | `/project:robustness-table` | `/project:referee-response` |

**References & Data** -- Manage citations, literature notes, data docs.

| `/project:cite` | `/project:literature-note` | `/project:codebook` |
| --- | --- | --- |

**Quality Checks & Audits** -- Read-only; can be auto-invoked when relevant.

| `/project:bib-check` | `/project:data-audit` | `/project:freeze-check` |
| --- | --- | --- |
| `/project:check-env` | `/project:submission-prep` | `/project:figures-gallery` |

**Session Management** -- `/project:handoff` and `/project:env-snapshot`

---

## Session Management

**Handoff reports** go in `./handoffs/` as `YYYYMMDD_HHMM.md`. Write one when you complete significant work, make major decisions, or end a session. Every handoff must include:

- Current project state (one paragraph)
- Work completed (bullet list)
- Decisions made and rationale
- Open issues or blockers
- Concrete next steps

---

## Essential Commands

See `README.md` § Manuscript Workflow and § Notebook Workflow for full details.

```bash
bash scripts/render.sh                                      # clean render (all formats)
uv run jupyter execute --inplace notebooks/<file>.ipynb      # execute notebook (--inplace REQUIRED)
uv add <package>                                             # add Python package (NEVER use pip)
```

---

## Workflow Gotchas

These are non-obvious pitfalls. See `README.md` for full context.

- **`--inplace` is required** for `jupyter execute` -- without it, outputs are discarded
- **Register new notebooks** in `_quarto.yml` under `manuscript.notebooks`
- **Stata cell directives** use `*|` prefix (not `#|`), e.g., `*| label: fig-name`
- **Never use `tbl-` prefix** for Stata text output cells -- it triggers Quarto's table parser and crashes. Use a plain label (e.g., `stata-summary`)
- **Never use `pip install`** -- it bypasses the lockfile. Always use `uv add`
- **Avoid `@fig-`/`@tbl-` cross-refs** to `{{< embed >}}`-ed notebook content -- use plain prose instead (avoids "Unable to resolve crossref" warnings)
- **Jupytext metadata filter** in `jupytext.toml` strips `_sphinx_cell_id`, `execution`, and `vscode` keys. Do not remove it.
- **Credentials** go in `.env` only. Never commit secrets to git.
