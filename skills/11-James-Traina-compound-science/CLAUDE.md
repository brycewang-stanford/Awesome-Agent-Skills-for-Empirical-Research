# compound-science Plugin

AI-powered research tools for quantitative social science: structural econometrics, causal inference, game theory, applied micro, and reproducible pipelines. Built on the compound workflow principle: each unit of research work makes subsequent work easier.

## Core Workflow

**Brainstorm → Plan → Work → Review → Compound → Repeat**

1. `/workflows:brainstorm` — Explore research approaches, compare methods, pick one. Writes to docs/brainstorms/.
2. `/workflows:plan` — Create an implementation plan from the brainstorm. Writes to docs/plans/.
3. `/workflows:work` — Execute the plan with quality gates and convergence monitoring.
4. `/workflows:review` — Multi-agent parallel review (econometric-reviewer, numerical-auditor, identification-critic, journal-referee).
5. `/workflows:compound` — Extract reusable solutions into docs/solutions/ by category.

Each step has an interactive handoff offering the next step. Use `/lfg` to chain all five automatically, or `/slfg` for parallel swarm execution. Ideate (`/workflows:ideate`) is an optional divergent pre-step before brainstorming.

## Skills (20)

### Workflow (6) — core research loop
- `/workflows:ideate`, `/workflows:brainstorm`, `/workflows:plan`, `/workflows:work`, `/workflows:review`, `/workflows:compound`

### Chain (2) — automated multi-step execution
- `/lfg` — Sequential: brainstorm → plan → work → review → compound (with hard gates)
- `/slfg` — Parallel swarm variant of `/lfg`

### Wrappers (2) — thin routing skills
- `/estimate` — Routes to `/workflows:work` with estimation pipeline context from `empirical-playbook`
- `/replicate` — Routes to `reproducibility-auditor` agent

### Domain knowledge (10) — reusable reference skills
- `structural-modeling` — NFXP, MPEC, BLP, dynamic discrete choice, auction models
- `causal-inference` — IV/2SLS/GMM, DiD, RDD, synthetic control, matching
- `causal-ml` — Double ML, causal forests (GRF), DR-Learner, post-LASSO, high-dimensional controls
- `game-theory` — Nash/SPE/BNE equilibria, entry models, conduct testing, bargaining, multiple equilibria
- `identification-proofs` — Formal identification arguments: target parameter → model → rank conditions → regularity conditions
- `bayesian-estimation` — MCMC, Stan/PyMC/Numpyro, prior elicitation, MCMC diagnostics, Bayesian structural models
- `reproducible-pipelines` — Makefile/Snakemake/DVC, Stata pipelines, environment management, replication standards
- `empirical-playbook` — Method selection, diagnostics by method, power analysis, estimation pipeline, sensitivity analysis, data acquisition (FRED/World Bank)
- `publication-output` — Publication-quality tables and figures: stargazer-style tables, event study plots, RD plots, specification curves
- `submission-guide` — Pre-submission checklists, journal-specific formatting for 20+ journals, referee response strategy and templates

## Agents

### Review (5) — domain-specific code review and methodology verification
- `econometric-reviewer` — Reviews identification, inference, standard errors, calibration strategy, specification flow (model → estimator → code)
- `mathematical-prover` — Verifies proof steps, completeness, regularity conditions, fixed-point arguments
- `numerical-auditor` — Checks floating-point stability, convergence, RNG seeding, matrix conditioning, simulation design (DGPs, metrics, seeds)
- `identification-critic` — Evaluates identification argument completeness, exclusion restrictions, support conditions, equilibrium existence/uniqueness
- `journal-referee` — Adversarial journal referee simulation (contribution, literature, robustness, external validity)

### Research (3) — literature and data investigation
- `literature-scout` — Systematic search for related methods, seminal papers, prior applications
- `methods-explorer` — Estimator properties, computational tradeoffs, software implementations, benchmark parameters and calibration targets
- `data-detective` — Data quality investigation: distributions, missingness, duplicates, panel structure

### Workflow (2) — process, reproducibility, and coordination
- `reproducibility-auditor` — Structural and functional checks for reproducible pipelines and replication packages
- `workflow-coordinator` — Multi-agent workflow coordination, dispatch, triage, and progress tracking

## Domain Signal → Agent Routing

When compaction drops context, use this table to route research questions:

| Signal | Primary Agent | Skill |
|--------|--------------|-------|
| Identification, instruments, exclusion, endogeneity | `identification-critic` | `causal-inference` |
| Estimation, SEs, convergence, calibration | `econometric-reviewer` | `empirical-playbook` |
| Proof, theorem, regularity conditions | `mathematical-prover` | `identification-proofs` |
| Floating-point, Hessian, conditioning, MCMC diagnostics | `numerical-auditor` | `bayesian-estimation` |
| Simulation, DGP, Monte Carlo, power | `numerical-auditor` | `empirical-playbook` |
| Equilibrium, Nash, entry, auction | `identification-critic` | `game-theory` |
| Data quality, merge, panel, missing | `data-detective` | — |
| Literature, citations, related work | `literature-scout` | — |
| Estimator choice, packages, benchmarks | `methods-explorer` | `structural-modeling` |
| Pipeline, seeds, versions, replication | `reproducibility-auditor` | `reproducible-pipelines` |
| Tables, figures, LaTeX output | `econometric-reviewer` | `publication-output` |
| Journal, referee, submission, R&R | `journal-referee` | `submission-guide` |
| Workflow coordination, next steps | `workflow-coordinator` | `slfg` |
| Design before results, magnitude interpretation | `identification-critic` | `identification-proofs` |

## Ambient Hooks

5 hooks covering 14 domain categories:
- **SessionStart** — Detects project type (empirical/paper), estimation language, data/pipeline presence
- **UserPromptSubmit** — Injects domain context across 14 categories (Haiku classifier)
- **Stop** — Completeness checks (Sonnet): unvalidated merges (blocking); unseeded scripts, unversioned pip, sensitivity, DiD pre-trends, IV first-stage (suggestions)
- **PreCompact** — Preserves 10 categories of research state before context compaction
- **SubagentStop** — Severity-routed next steps with agent-specific completeness checks (SEs for econometric-reviewer, seeds for numerical-auditor, regularity conditions for mathematical-prover)

All hooks use prompt type (no shell commands). 4 use Haiku for fast classification; Stop uses Sonnet for deeper reasoning.

## Integration

Works alongside optional companions: document-skills (docs), context7 (framework docs), pyright-lsp (Python types). No external plugins are required. Git operations use inline bash (no commit plugin needed).

## Development

### Directory Structure
```
.claude-plugin/   plugin.json manifest (must stay at repo root)
agents/
  review/         5 domain-specific review agents
  research/       3 literature and data investigation agents
  workflow/       2 process and coordination agents
skills/           20 skill directories (all entry points are skills)
  workflows-*/    6 core workflow skills (ideate, brainstorm, plan, work, review, compound)
  lfg/, slfg/     2 chain skills (automated multi-step)
  estimate/, replicate/  2 wrapper skills (thin routing)
  (10 domain knowledge skills with SKILL.md)
hooks/            hooks.json (5 prompt-based hooks)
output-styles/    research-mode output style (equations, citations, statistical notation)
docs/solutions/   reusable solutions by category (data, estimation, identification, numerical)
.tests/           test suite (dev-only, hidden from users)
.evals/           evaluation harness (dev-only, hidden from users)
.github/workflows/ CI pipeline (JSON validation + test suite)
```

### Testing
- Run: `bash .tests/run-all.sh`
- Selective: `bash .tests/run-all.sh 07` runs a single group; `--list` shows all groups
- Reports are gitignored at `.tests/reports/`

### CI
- GitHub Actions runs on push/PR to `main` (`.github/workflows/ci.yml`)
- Validates JSON (plugin.json, hooks.json), runs `claude plugin validate` if available, then runs full test suite

### Critical Invariants
- **Flat repo structure**: `.claude-plugin/plugin.json` must be at repo root — not nested in a subdirectory.
- **Version bumping required for updates**: Claude Code caches plugins; users only get updates if `version` in `plugin.json` is incremented.
- **Hook wrapper format**: `hooks.json` requires the `{"description":"...","hooks":{...}}` envelope. Missing the outer wrapper silently disables all hooks.
- **Dev-only dirs are hidden**: `.tests/` and `.evals/` start with `.` so they don't appear in the default file tree for users who install the plugin.
- **grep -P unavailable on macOS**: Use `python3 -c "import re; ..."` for Perl-compatible regex.
- **Chain command frontmatter**: `/lfg` and `/slfg` use `disable-model-invocation: true` so they delegate to sub-commands without an extra model call.
- **Plugin agent restrictions**: Plugin-shipped agents do NOT support `hooks`, `mcpServers`, or `permissionMode` frontmatter fields (silently ignored). Agent-specific checks must go in global hooks (e.g., SubagentStop).
- **Supported agent fields**: `effort`, `maxTurns`, `disallowedTools` (used by all 5 review agents to enforce read-only), `initialPrompt`, `background`, `isolation`, `memory`, `skills` all work for plugin agents.

### Deferred
- **`${CLAUDE_PLUGIN_DATA}`**: Persistent data dir surviving updates. No current use case with prompt-only hooks.
- **`agent` hook type**: Subagent-based verification. Haiku classifiers are sufficient for current needs.
- **Agent Teams**: Experimental (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Hooks: `TaskCreated`, `TaskCompleted`, `TeammateIdle`.
- **Agent `memory` field**: Cross-session persistence. Risk of writing to user's project `.claude/` directory.
- **CwdChanged / FileChanged hooks**: Re-detect project type on directory change. No reported use case.
- **`userConfig`**: Plugin-prompted settings. Requires command hooks to read; prompt hooks can't access `${user_config.*}` substitutions.
