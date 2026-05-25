# AER-Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Top-5 focused](https://img.shields.io/badge/focus-AER%20%2F%20AER%3AInsights%20%2F%20AEJ-1f6feb)](docs/workflow-map.md)
[![Workflow](https://img.shields.io/badge/workflow-identification--driven-blue)](docs/design-principles.md)
[![Claude Code](https://img.shields.io/badge/agent-Claude%20Code-cc785c)](docs/installation-claude.md)
[![Codex](https://img.shields.io/badge/agent-Codex-0a7ea4)](docs/installation-codex.md)

English | [简体中文](README.zh-CN.md)

Agent skills for **selecting, writing, identifying, formatting, submitting, and revising** manuscripts targeted at the *American Economic Review* (AER), *AER: Insights*, and the *AEJ* family.

This repository is opinionated. It is **not** a generic economics writing toolbox. It is a **top-5 economics skill stack** for: identification-first empirics, AEA-policy-compliant replication packages, Keith-Head-style introductions, AER-style booktabs tables, and editor-efficient rebuttals.

---

## Why a Separate AER Skill Stack?

Top-5 economics journals impose constraints that do not exist in life-science venues:

| Constraint                       | AER                | AER: Insights       | Implication                                          |
|----------------------------------|--------------------|---------------------|------------------------------------------------------|
| Abstract length                  | **100 words**      | 100 words           | 4-5 sentences. Sell results, not motivation.         |
| Main text length                 | ~40 typeset pages  | **≤ 7,000 words minus 200 per exhibit** | Tight prose; five exhibits leave 6,000 words.        |
| Desk rejection                   | High               | **~45%**            | First 3 pages decide the verdict.                    |
| Replication                      | Mandatory          | Mandatory           | AEA Data and Code Availability Policy is enforced.   |
| Identification                   | Causal, design-based| Causal, design-based | TWFE, weak IV, and naive RDD get desk-rejected.     |
| Cover letter                     | Optional           | Optional            | Use only for COI disclosure or data access limits.   |
| Disclosure statements            | Required           | Required            | One separate PDF per coauthor, even with no conflicts. |

Generic "scientific writing" skills (e.g. [Nature-Paper-Skills](https://github.com/Boom5426/Nature-Paper-Skills), [nature-skills](https://github.com/Yuan1z0825/nature-skills)) miss these constraints.

---

## Quick Start

### Option A — Claude Code Plugin (recommended)

```bash
# Add the marketplace (one-time)
/plugin marketplace add https://github.com/brycewang-stanford/AER-skills

# Install the plugin
/plugin install aer-skills

# Reload
/reload-plugins
```

All nine skills are then available automatically.

### Option B — Manual Copy

```bash
git clone https://github.com/brycewang-stanford/AER-skills.git
cd AER-skills

# Claude Code (user-scoped)
mkdir -p ~/.claude/skills && cp -R skills/aer-* ~/.claude/skills/

# Or Codex
mkdir -p ~/.codex/skills && cp -R skills/aer-* ~/.codex/skills/
```

Manual copy installs the skill instructions. Keep the cloned repository available
if you want the `templates/` and `examples/` resources referenced by the skills.

### First Prompt

After restarting your agent:

```text
Use aer-workflow to tell me which skill I should use next for this manuscript.
```

For longer install instructions see [docs/installation-claude.md](docs/installation-claude.md) and [docs/installation-codex.md](docs/installation-codex.md).

---

## Default Workflow

```text
aer-topic-selection
    -> aer-identification
        -> aer-robustness
            -> aer-introduction
                -> aer-tables-figures
                    -> aer-replication
                        -> aer-submission
                            -> aer-rebuttal
```

The default assumption is:

- **identification before writing** — if your design is fragile, no prose will save it
- **AER vs AER:Insights vs AEJ** is a *routing* decision made before the abstract is written
- **replication package quality** is part of the paper, not an afterthought
- **rebuttal letters** are written against the *revised* manuscript, never against the old draft

See [docs/workflow-map.md](docs/workflow-map.md).

---

## Skills

### Core — Lifecycle

| Skill | Purpose |
|---|---|
| [`aer-workflow`](skills/aer-workflow/SKILL.md) | Routing map. Tells you which skill to use next. |
| [`aer-topic-selection`](skills/aer-topic-selection/SKILL.md) | Top-5 bar test, novelty audit, AER vs Insights vs AEJ routing. |
| [`aer-introduction`](skills/aer-introduction/SKILL.md) | Keith Head five-paragraph formula + 100-word abstract drafting. |
| [`aer-identification`](skills/aer-identification/SKILL.md) | DiD (staggered), IV (weak-IV-robust), RDD, SCM, shift-share/Bartik. |
| [`aer-robustness`](skills/aer-robustness/SKILL.md) | Robustness, heterogeneity, mechanism, placebo. Referee-anticipating. |
| [`aer-tables-figures`](skills/aer-tables-figures/SKILL.md) | AER booktabs style, `etable`/`estout`/`modelsummary`, figure notes. |
| [`aer-replication`](skills/aer-replication/SKILL.md) | AEA Data and Code Availability Policy, README, openICPSR. |
| [`aer-submission`](skills/aer-submission/SKILL.md) | Format preflight, cover letter, length audit, conflict declaration. |
| [`aer-rebuttal`](skills/aer-rebuttal/SKILL.md) | R&R response letter, triage, concede / clarify / push-back rules. |

---

## Code Templates

Drop-in, pinned-version scripts for three common empirical economics stacks. Each
template includes a master script, a Callaway-Sant'Anna DiD example, an
AER-style booktabs regression table, and a README.

| Language | Stack | Path |
|---|---|---|
| Stata | `reghdfe`, `csdid`, `estout`, `bacondecomp`, `honestdid` | [`templates/stata/`](templates/stata/) |
| R | `fixest`, `did`, `HonestDiD`, `modelsummary`, `fwildclusterboot` | [`templates/r/`](templates/r/) |
| Python | `pyfixest`, `differences`, `linearmodels`, `statsmodels` | [`templates/python/`](templates/python/) |

Each template enforces: fixed seed (`20260101`), relative paths, version-
pinned packages, AER booktabs table style, vector-format figures.

---

## Examples

Worked examples grounded in classic AER and adjacent-top-5 papers.

| File | What it shows |
|---|---|
| [`examples/aer-exemplars.md`](examples/aer-exemplars.md) | Classic papers (Card-Krueger, AJR, ADH, Dell, Chetty-Hendren, Abadie, BDGK, Karlan-List …) mapped to each skill, with openICPSR / Dataverse links |
| [`examples/modern-aer-exemplars.md`](examples/modern-aer-exemplars.md) | **30+ recent (2018-2025) papers organized by 13 subfields** — Labor, Public, Development, Trade, Macro, IO, Health, Environment, Urban, Education, Finance, Political Economy, Social Networks — plus the modern identification-methods toolkit. Each with deposit link |
| [`examples/intro-example.md`](examples/intro-example.md) | Full Keith Head five-paragraph introduction + 97-word abstract, with a counterexample of what not to write |
| [`examples/rebuttal-example.md`](examples/rebuttal-example.md) | Complete R&R response: cover letter + editor + 3 referees, demonstrating concede / clarify / push-back / decline outcomes |
| [`examples/replication-package-skeleton/`](examples/replication-package-skeleton/) | Deposit-ready directory layout with AEA-compliant README template, master script, and globals file — drop-in starting point for an openICPSR submission |

---

## Design Principles

- **Identification-driven, not narrative-driven.** Decide and stress-test the research design *before* writing prose.
- **One contribution per paper.** AER editors reject competent extensions; rewrite around a single sharpest claim.
- **Cross-subfield interest is a hard filter.** A labor paper must speak to public, macro, and IO economists or it desk-rejects.
- **Modern econometrics, not 1990s defaults.** TWFE → Callaway-Sant'Anna; first-stage F → Anderson-Rubin; naive RDD → covariate-adjusted local linear.
- **The replication package is part of the paper.** A README that does not run is grounds for AEA Data Editor delay.
- **Editor time is the scarcest resource.** Cover letter ≤ 200 words. Response letter quotes the comment, states the action, and cites the revised location.

See [docs/design-principles.md](docs/design-principles.md).

---

## Repository Layout

```text
AER-skills/
├── README.md               (English, primary)
├── README.zh-CN.md         (Chinese, navigation)
├── LICENSE                 (MIT)
├── .claude-plugin/
│   ├── plugin.json         (plugin manifest)
│   └── marketplace.json    (Claude Code marketplace entry)
├── docs/
│   ├── installation-claude.md
│   ├── installation-codex.md
│   ├── workflow-map.md
│   └── design-principles.md
├── skills/                 (9 skill directories — SKILL.md + agents/openai.yaml)
│   ├── aer-workflow/
│   ├── aer-topic-selection/
│   ├── aer-introduction/
│   ├── aer-identification/
│   ├── aer-robustness/
│   ├── aer-tables-figures/
│   ├── aer-replication/
│   ├── aer-submission/
│   └── aer-rebuttal/
├── templates/              (drop-in pipelines, all three languages)
│   ├── stata/
│   ├── r/
│   └── python/
└── examples/
    ├── aer-exemplars.md
    ├── intro-example.md
    ├── rebuttal-example.md
    └── replication-package-skeleton/
```

---

## Scope

This repository is for:

- *American Economic Review* (full-length papers, ≤ 40 pages)
- *American Economic Review: Insights* (short-form, ≤ 7,000 words minus 200 per exhibit; ≤ 6,000 words with five exhibits)
- *American Economic Journal* family (Applied, Policy, Macro, Micro)
- Empirical and theoretical economics manuscripts
- Field experiments (with AEA RCT Registry workflow)

This repository is **not** trying to be:

- A finance-journal toolbox (JF, JFE, RFS have their own conventions)
- A theory-only stack (no proof-writing helpers)
- A generic "academic writing" library

---

## Acknowledgements

Skill architecture inspired by [Boom5426/Nature-Paper-Skills](https://github.com/Boom5426/Nature-Paper-Skills) and [Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills). Methodology distilled from public-domain advice by **Keith Head**, **Marc F. Bellemare**, **Susan Athey**, **Berk-Harvey-Hirshleifer**, the **AEA Data Editor's Office**, and the *Annual Review of Economics*.

---

## License

[MIT](LICENSE).
