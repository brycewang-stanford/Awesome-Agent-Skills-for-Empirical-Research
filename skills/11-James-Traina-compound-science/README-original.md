# compound-science

A Claude Code plugin for quantitative social science research: structural econometrics, causal inference, game theory, applied micro, identification arguments, Monte Carlo studies, and reproducible pipelines.

Every time you solve a methodological problem — a convergence fix, an identification argument, a numerical issue — that solution gets documented and made findable. The next project starts where the last one left off.

## The problem this solves

Empirical research in economics involves a lot of repeated pattern-matching: figuring out which DiD estimator applies when treatment timing is staggered, checking whether your BLP instruments are weak, making sure simulation seeds are set before you write down results, formatting a table to AER style. These problems have standard answers. Finding the right answer at the moment you need it is still slow.

The plugin intercepts your workflow and surfaces relevant expertise without you having to ask. When you write estimation code, it suggests the econometric-reviewer. When a session ends without standard errors being discussed, it flags it. When you open a project, it detects your estimation language and data structure. The idea is that you focus on the research question, not the checklist.

This plugin does not write papers, generate datasets, or replace your judgment. It catches common methodology mistakes and keeps solutions findable for next time.

## How it works

The core loop is **Plan → Work → Review → Compound → Repeat**.

1. **Plan** (`/workflows:plan`): You describe the task. The plugin creates an implementation plan, choosing between minimal, moderate, and detailed levels based on complexity. For a BLP demand model, this means settling the inner-loop choice (NFXP vs MPEC), the instruments, the standard errors, and the robustness checks before any code is written.

2. **Work** (`/workflows:work`): The plan executes with quality gates. If optimization fails, the numerical-auditor investigates. If the model produces implausible elasticities, the econometric-reviewer flags it.

3. **Review** (`/workflows:review`): Domain-specific review agents examine your work in parallel. The econometric-reviewer checks identification. The numerical-auditor checks floating-point stability and gradient accuracy. The identification-critic evaluates your exclusion restrictions. The journal-referee tries to find reasons to reject the paper. The econometric-reviewer, for instance, knows to ask about Montiel Olea-Pflueger effective F rather than Stock-Yogo, and about clustered wild bootstrap for staggered DiD, not just generic clustering.

4. **Compound** (`/workflows:compound`): Solutions get documented into `docs/solutions/` by category (identification, estimation, numerical, methodology). Future sessions search this via the solution schema. The knowledge base grows as the project does.

Run `/lfg [task]` to chain all four steps automatically. Run `/slfg [task]` to parallelize review and compound with agent swarms.

### Ambient hooks

Five ambient hooks run without being invoked.

- When you **open a session**, the plugin scans your project for `.py`/`.R`/`.do` files, `Makefile`/`Snakemake`/`DVC`, `data/` directories, and `.tex` files, then configures itself for your language, project type, and data setup.

- When you **submit a prompt**, the plugin classifies it across 14 domain categories and adds relevant context to the response. If you ask "is this estimate large?", it notes that you should first confirm whether your identification assumptions hold — evaluating magnitudes before validating the design is a common mistake.

- When a **session ends**, the plugin checks completeness conditions. Cross-cutting checks (unvalidated merges, unseeded scripts, unversioned pip, absolute paths, sensitivity analysis, replication package, DiD pre-trends, IV first-stage) run in the Stop hook. Agent-specific checks (missing SEs, unseeded simulations, unstated regularity conditions) run via the SubagentStop hook after econometric-reviewer, numerical-auditor, and mathematical-prover complete. The Stop hook uses Sonnet for deeper reasoning.

## Install

Via the [science-plugins](https://github.com/James-Traina/science-plugins) marketplace (recommended — enables one-command updates):

```bash
/plugin marketplace add James-Traina/science-plugins
/plugin install compound-science@science-plugins
```

Or directly from GitHub:

```bash
claude plugin install https://github.com/James-Traina/compound-science
```

Or from a local clone:

```bash
claude plugin install /path/to/compound-science
```

To update after a new release:

```bash
/plugin update compound-science
```

## Quick start

```bash
# Full autonomous pipeline: plan, implement, review, document
/lfg estimate a BLP demand model for the cereal dataset

# Or step by step
/workflows:brainstorm approaches for estimating entry games
/workflows:plan implement Bresnahan-Reiss entry model
/workflows:work
/workflows:review
/workflows:compound

# Canonical commands
/estimate run 2SLS with Bartik instruments
/replicate build replication package for journal submission

```

## Commands

### Workflow commands (5)

These chain together into the Plan → Work → Review → Compound loop. Run them individually or use `/lfg` to run all five automatically.

| Command | What it does |
|---------|-------------|
| `/workflows:brainstorm` | Explore research approaches with methods-explorer and literature-scout agents. Good when you have a question but aren't sure which method applies, or want to survey recent literature before committing to a design. |
| `/workflows:plan` | Create an implementation plan. The plugin picks between MINIMAL (simple task), MORE (moderate complexity), and A LOT (new estimator, identification challenge, multiple robustness checks). Returns a plan you can edit before execution. |
| `/workflows:work` | Execute the current plan with quality gates. Monitors convergence, routes problems to the relevant agent. |
| `/workflows:review` | Run the four review agents in parallel: econometric-reviewer, numerical-auditor, identification-critic, journal-referee. Each returns a report with numbered findings and severity ratings. |
| `/workflows:compound` | Extract methodological insights from the session into `docs/solutions/`. Creates searchable entries by category (identification arguments, convergence fixes, instrument choices) that future sessions can find via the solution schema. |

### Canonical commands (2)

| Command | What it does |
|---------|-------------|
| `/estimate` | Thin wrapper: routes to `/workflows:work` with estimation pipeline context from the `empirical-playbook` skill. |
| `/replicate` | Thin wrapper: routes to the `reproducibility-auditor` agent. |

### Chain commands (2)

| Command | What it does |
|---------|-------------|
| `/lfg` | Chains brainstorm → plan → work → review → compound. Use for the full autonomous pipeline. |
| `/slfg` | Same as `/lfg` but parallelizes review and compound using agent swarms. Faster when you have multiple reviewers queued. |

## Agents (10)

Each agent runs as a specialized subagent with its own structured output format. Review agents return numbered findings with severity ratings (critical, must-fix, should-fix, suggestion). Research agents return structured reports with citations and follow-up questions. All review agents include confidence gating (suppress findings below 0.60), "what would change my mind" for every major finding, and a read-only auditor rule.

### Review agents (5)

Invoked during `/workflows:review` or by ambient hooks when you write relevant code.

| Agent | What it examines | When it's most useful |
|-------|-----------------|----------------------|
| `econometric-reviewer` | Identification strategy, endogeneity, standard errors, calibration strategy (moment selection, sensitivity to targets), specification flow (model → estimator → code), results verification (table accuracy, significance stars). Instrument strength via Montiel Olea-Pflueger effective F. | After writing estimation code or completing a regression |
| `mathematical-prover` | Proof step validity, assumption completeness, regularity condition sufficiency, fixed-point arguments, quantifier ordering. | Writing theory appendices, proving identification propositions, verifying contraction mapping arguments |
| `numerical-auditor` | Floating-point stability (log-sum-exp, integration tolerances), convergence diagnostics (gradient norms, step sizes), RNG seeding, matrix conditioning, gradient accuracy, simulation design (DGP correctness, sample sizes, metrics), DGP formalization from structural primitives | After structural estimation, simulation, or any numerical optimization |
| `identification-critic` | Identification argument completeness — exclusion restrictions, support conditions, rank conditions, partial identification, observational equivalence, equilibrium existence/uniqueness/stability | Before finalizing an empirical strategy or submitting |
| `journal-referee` | Adversarial peer review simulation: contribution relative to the literature, methodological concerns, robustness gaps, external validity, exposition. Calibrated for 11 journals (AER, ECMA, JPE, QJE, REStud, AEJ-Applied, AEJ-Policy, JHR, JHE, RAND, JPubE) | Before submitting, or to stress-test a draft before an R&R response |

### Research agents (3)

These investigate literature, data, and past solutions. Most useful at the start of a project or when the estimation is stuck.

| Agent | What it does |
|-------|-------------|
| `literature-scout` | Searches for related methods, seminal papers, prior applications, and intellectual genealogy. Useful for knowing what comparable papers did and how they defend their identification. |
| `methods-explorer` | Digs into estimator properties, computational tradeoffs, software implementations, and benchmark parameters / calibration targets from the literature. Useful when you need plausible ranges for elasticities, discount factors, or cost parameters. |
| `data-detective` | Data quality: distributions, missingness patterns, duplicate records, panel structure (balanced?), merge validation (how many observations were lost and why?). Catches a class of problems that only surface late in estimation. |

### Workflow agents (2)

These coordinate processes and track state across long-running projects.

| Agent | What it does |
|-------|-------------|
| `reproducibility-auditor` | Structural and functional checks for reproducible pipelines and replication packages: no manual steps, no hardcoded paths, seeds set, package versions pinned, AEA Data Editor checklist compliance, table-to-code traceability. |
| `workflow-coordinator` | Coordinates multi-agent workflows, manages dispatch and handoffs between phases, tracks progress from git history and file timestamps, synthesizes findings into a Coordination Summary. |

## Skills (10)

Skills are domain knowledge references that load when you need them. Each has a lean `SKILL.md` with method selection guides and quick reference tables, plus a `references/` directory with full implementation code and API details. The idea is that you get a useful overview quickly and drill into the reference when you're implementing.

| Skill | What it covers |
|-------|---------------|
| `structural-modeling` | NFXP, MPEC, BLP demand, dynamic discrete choice (Rust, Hotz-Miller CCP), auction models. From model specification through estimation and post-estimation. |
| `causal-inference` | IV/2SLS/GMM with instrument validity checks, DiD including staggered adoption (Callaway-Sant'Anna, Sun-Abraham, de Chaisemartin-D'Haultfoeuille), RDD (sharp/fuzzy, rdrobust), synthetic control, matching and doubly-robust estimators. |
| `causal-ml` | Double ML (Chernozhukov et al. 2018) with cross-fitting, causal forests (GRF), DR-Learner, T/S/X-learners, post-double-selection LASSO, heterogeneous treatment effect inference. |
| `game-theory` | Nash/SPE/BNE equilibria and computation, entry models (Bresnahan-Reiss, Berry 1992, Ciliberto-Tamer), conduct testing, bargaining, multiple equilibria problem and selection. |
| `identification-proofs` | Seven-step identification argument: target parameter → model primitives → source of variation → assumptions → identification result → regularity conditions → estimation link. Covers IFT approach, completeness conditions, LATE, RD identification, BLP inversion. |
| `bayesian-estimation` | Stan, PyMC, NumPyro, brms from setup through MCMC diagnostics (R-hat, ESS, divergences), posterior inference (HDI, predictive checks, LOO-CV), and Bayesian structural models. |
| `reproducible-pipelines` | Makefile and Snakemake patterns, DVC for large data, Stata pipelines (master.do, batch mode, ado versioning), environment management (conda/renv/Docker), random seed management, AEA replication standards. |
| `empirical-playbook` | Method selection decision tree (what source of variation do you have?), within-method refinements (which DiD estimator given your timing and controls?), diagnostics by method, inference framework selection, power analysis, sensitivity analysis, minimum reporting standards, FRED/World Bank data acquisition. |
| `publication-output` | Publication-quality tables and figures: stargazer-style regression tables, event study plots, RD plots, coefficient plots, specification curves, summary statistics tables, Monte Carlo output tables. Journal-specific formatting. |
| `submission-guide` | Pre-submission checklists (manuscript, tables, figures, replication package, cover letter), journal-specific formatting for 20+ journals, referee response strategy and templates, revision management. |

## Ambient Hooks (5)

The plugin watches your session. Nothing to invoke.

| Hook | When it fires | What it does |
|------|--------------|-------------|
| **SessionStart** | Session opens | Scans for estimation scripts (`.py`, `.R`, `.do`, `.jl`), pipeline files (`Makefile`, `Snakemake`, `dvc.yaml`), data directories, and LaTeX files. Detects project type (empirical, paper, or empirical-paper), estimation language, and whether data and pipeline infrastructure exist. Loads `compound-science.local.md` if present. |
| **UserPromptSubmit** | Every prompt | Classifies your prompt across 14 domain categories (Haiku classifier) and adds relevant context to the response. ESTIMATION prompts get econometric context. SIMULATION prompts get Monte Carlo guidance. PROOF prompts get formal structure advice. If you ask whether a coefficient is large before the identification design is validated, it applies Cunningham's norm: confirm the assumptions hold before evaluating magnitudes. |
| **Stop** | Session ends | Cross-cutting completeness checks (Sonnet): unvalidated data merge (blocking), unseeded scripts, unversioned pip, absolute paths, sensitivity analysis, replication package, DiD pre-trends, IV first-stage F via Montiel Olea-Pflueger (suggestions). |
| **PreCompact** | Context compaction | Before the context window compresses, preserves 10 categories of research state: identification strategy, estimation results and convergence status, proof steps and regularity conditions, pipeline configuration, methodology decisions and rejections, sensitivity analysis results, diagnostic findings, submission status, software environment versions, and failed approaches. |
| **SubagentStop** | After any agent completes | Routes findings to the right next action. Critical findings (identification failure, numerical instability) get required actions. Includes agent-specific checks: SEs for econometric-reviewer, seeds for numerical-auditor, regularity conditions for mathematical-prover. Format: `[agent]: [finding] → [action]`. |

## Configuration

Create `compound-science.local.md` in your project's `.claude/` directory to configure the plugin for your project. You can specify which review agents to run by default, your preferred estimation language, project type, and data sensitivity level.

## Integration

This plugin handles domain-specific research methodology. No other plugins are required.

It works well alongside these optional companion plugins if you have them installed:

| Plugin | What it provides | How compound-science benefits |
|--------|-----------------|-------------------------------|
| `document-skills` | PDF, XLSX, DOCX export | Results export from `publication-output` skill and `/replicate` |
| `context7` | Up-to-date framework docs | Library documentation lookup for estimation packages |
| `pyright-lsp` | Python type checking | Type validation in estimation code |

> Git operations (commit, push, PR) use inline bash — no git plugin needed.

### Recommended MCP Servers

For the full research toolkit, add these MCP data servers:

| Server | What it adds | Install |
|--------|-------------|---------|
| OpenEcon Data | FRED, World Bank, IMF, Eurostat, Comtrade data access | `claude mcp add --transport sse openecon-data https://data.openecon.io/mcp` |
| Stata MCP | Live Stata execution from Claude Code (requires Stata 17+ license) | `claude mcp add --transport sse stata-mcp http://localhost:4000/mcp` |

## Component Counts

| Category | Count |
|----------|-------|
| Agents | 10 (5 review + 3 research + 2 workflow) |
| Skills | 20 (6 workflow + 2 chain + 2 wrappers + 10 domain knowledge) |
| Hooks | 5 |
| Output Styles | 1 |
| **Total** | **36 components** |

## Layout

```
.claude-plugin/   plugin.json (manifest)
agents/
  review/         econometric-reviewer, mathematical-prover, numerical-auditor,
                  identification-critic, journal-referee
  research/       literature-scout, methods-explorer, data-detective
  workflow/       reproducibility-auditor, workflow-coordinator
skills/           20 skills (all entry points are skills — no commands/ directory)
  workflows-*/    ideate, brainstorm, plan, work, review, compound
  lfg/, slfg/     chain skills (automated multi-step)
  estimate/, replicate/  wrapper skills (thin routing)
  (10 domain knowledge skills)
hooks/            hooks.json (5 ambient hooks, 14 domain categories)
output-styles/    research-mode (equations, citations, statistical notation)
.tests/           test suite (dev-only, gitignored reports)
.evals/           evaluation harness (dev-only)
```

## Testing

```bash
bash .tests/run-all.sh              # Run all 237 tests
bash .tests/run-all.sh 07           # Run a specific test group
bash .tests/run-all.sh --list       # List available test groups
```

## Background & Attribution

This plugin is directly inspired by [compound-engineering](https://github.com/EveryInc/compound-engineering-plugin) by [Every](https://every.to), which pioneered the compound workflow pattern for web development in Claude Code. The core loop and the idea of ambient hooks that watch for domain artifacts both come from their work. compound-science adapts that pattern to quantitative social science research.

The main adaptation was swapping web-focused agents for domain-specific ones: an `econometric-reviewer` instead of a frontend reviewer, a `numerical-auditor` instead of a performance profiler. The research commands and utility commands handle workflows that have no web equivalent, and the hooks watch for estimation packages, LaTeX files, and data directories rather than JavaScript frameworks and API endpoints.

## Domain Keywords

| Domain | Keywords |
|--------|----------|
| Structural Econometrics & Estimation | NFXP, MPEC, BLP, nested fixed point, Structural Estimation, Structural Modeling |
| Causal Inference & Empirical Methods | IV, 2SLS, GMM, DiD, RDD, synthetic control, matching, Empirical Methods, Empirical Reasoning |
| Identification | exclusion restriction, instrument, rank condition, Identification Arguments, Identification Proofs |
| Game Theory & Equilibrium | Nash equilibrium, best response, entry game, auction, Equilibrium Reasoning, Mathematical Equilibrium |
| Mathematical Modeling & Simulation | existence, uniqueness, fixed point, contraction mapping, Monte Carlo, DGP, Mathematical Modeling |
| Data Science & Engineering | panel data, cross-section, merge validation, imputation, Data Engineering, Data Science, Empirical Microdata |
| Reproducible Pipelines | Makefile, Snakemake, DVC, replication package, version pinning |
| Applied Statistics & Research | MLE, bootstrap, clustering, standard errors, Applied Statistics, Business Analytics, Academic Writing, Economic Research |
| Applied Micro & Research Design | method selection, power analysis, specification curve, research design, Applied Micro |

## Updating

```bash
/plugin update compound-science
```

## License

MIT
