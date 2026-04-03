---
name: workflows:review
description: Run multi-agent econometric review on estimation code, identification arguments, and research artifacts
argument-hint: "<file paths, directory, plan reference, PR number, or empty for auto-detect>"
allowed-tools: Read, Grep, Glob, Bash
---

# Review Command

**Pipeline mode:** This command operates fully autonomously. All decisions are made automatically.

Perform exhaustive econometric and methodological review using multi-agent parallel analysis. Domain-specific reviewers check estimation quality, identification strategy, numerical stability, and mathematical rigor.

## Input

<review_target> #$ARGUMENTS </review_target>

## Execution Workflow

### Phase 1: Scope Detection

0. **Eligibility Check**

   Before launching review agents, verify there is something to review. If no research artifacts are found (no estimation code, no proofs, no pipeline files, no data scripts, no output files), state "No research artifacts found to review" and stop. Do not launch agents against an empty target.

1. **Determine Review Target**

   The review is artifact-centric: it reviews research files (estimation code, proofs, pipelines, data scripts), not git metadata. Determine the target in priority order:

   - **File paths or directories** (e.g., `estimation.py`, `src/models/`, `proof.tex`) → review those artifacts directly
   - **Plan reference** (e.g., `plan-3`) → find the plan in `docs/plans/`, review files it references
   - **PR number** → fetch file list with `gh pr view --json files`
   - **Empty** → auto-detect: scan the project for estimation code, proofs, pipeline files, and data scripts. If git shows recent changes, include those.

2. **Classify Artifacts**

   Scan the target files and classify by type:

   ```
   estimation_code: *.py with statsmodels/scipy.optimize/pyblp/linearmodels imports
                    *.R with fixest/lfe/AER/gmm imports
                    *.jl with Optim/NLsolve imports
                    *.do with reg/ivregress/gmm commands
   simulation_code: Monte Carlo loops, DGP code, bias/RMSE computation
   proofs:          *.tex with theorem/proof environments, *.md with derivation sections
   pipeline_files:  Makefile, Snakefile, dvc.yaml, master.do
   data_code:       data loading, cleaning, merge operations
   output_files:    tables/*, figures/*, *.csv result files
   ```

   This classification drives which domain reviewers to launch.

3. **Load Review Settings**

   Read `compound-science.local.md` in the project root. If found, use `review_agents` from YAML frontmatter. If the markdown body contains review context (e.g., "focus on identification strategy" or "this is a replication package"), pass it to each agent as additional instructions.

   If no settings file exists, use defaults:
   ```yaml
   review_agents:
     - econometric-reviewer
     - numerical-auditor
     - identification-critic
   ```

#### Protected Artifacts

The following paths are compound-science pipeline artifacts and must never be flagged for deletion or removal by any review agent:

- `docs/plans/*.md` — Plan files created by `/workflows:plan`
- `docs/brainstorms/*.md` — Brainstorm files created by `/workflows:brainstorm`
- `docs/solutions/*.md` — Solution documents created by `/workflows:compound`
- `docs/simulations/*.md` — Simulation study documentation

If a review agent flags any file in these directories for cleanup or removal, discard that finding during synthesis.

### Phase 2: Agent Dispatch

**Entry condition:** Phase 1 classified at least one artifact; review settings loaded.
**Exit condition:** All dispatched agents have returned findings.

Launch domain reviewers in parallel using the Task tool. The specific agents depend on artifact classification from Phase 1.

#### Always Run (Core Domain Review)

<parallel_tasks>

Launch `econometric-reviewer`, `numerical-auditor`, and `identification-critic` in parallel:

```
Task econometric-reviewer(changed files + review context)
  → Checks: identification strategy, endogeneity, standard errors, instrument validity,
    sample selection, asymptotic properties, correct package usage

Task numerical-auditor(changed files + review context)
  → Checks: floating-point stability, convergence diagnostics, integration accuracy,
    RNG seeding, matrix conditioning, overflow/underflow, gradient accuracy

Task identification-critic(changed files + review context)
  → Checks: completeness of identification argument, exclusion restriction plausibility,
    functional form assumptions, parametric vs nonparametric claims, support conditions,
    point vs set identification
```

</parallel_tasks>

#### Conditional Agents (Run Based on Artifact Types)

<conditional_agents>

**WRITTEN ARTIFACTS: If PR contains proofs, derivations, or paper sections:**
(Files matching: `*.tex`, `*.md` with theorem/proof/lemma/proposition content, `docs/proofs/*`)

```
Task journal-referee(written artifact files + review context)
  → Simulates top-5 journal referee: contribution clarity, relation to literature,
    identification concerns, economic vs statistical significance, R&R concerns
    (robustness, external validity, mechanism)
```

**PIPELINE/DATA CODE: If PR contains pipeline files or data processing:**
(Files matching: `Makefile`, `Snakefile`, `dvc.yaml`, `*.do`, data loading/cleaning code)

```
Task reproducibility-auditor(pipeline files + review context)
  → Checks: intermediate files generated by code (no manual steps), seeds documented,
    package versions pinned, end-to-end pipeline, relative paths, data not committed
```

**TABLES/FIGURES: If tables or figures were generated:**
(Files matching: `tables/*`, `figures/*`, `*.tex` with tabular content, `*.csv` result files)

```
Task econometric-reviewer(output files + estimation code + review context)
  → Checks: table numbers match underlying code output, no manual edits to generated tables,
    statistical summaries consistent with estimation logs, formatting correct
```

</conditional_agents>

#### Always Run Post-Review

```
Search docs/solutions/ for past issues related to this PR's modules and patterns
  → Flag matches as "Known Pattern" with links to solution docs
  → See workflows-compound/references/solution-schema.md for category detection and search workflow
```

### Phase 3: Finding Assembly

**Wait for all Phase 2 agents to complete before proceeding.**

1. **Collect All Findings**

   Gather outputs from all parallel agents into a unified findings list.

2. **Categorize by Severity**

   | Severity | Criteria | Action |
   |----------|----------|--------|
   | **CRITICAL** | Incorrect identification argument, biased estimator, wrong standard errors, numerical instability producing wrong results, missing convergence check | Must fix before proceeding |
   | **WARNING** | Suboptimal estimation approach, missing robustness check, incomplete diagnostics, weak instruments not flagged, reproducibility gap | Should fix |
   | **NOTE** | Style improvements, alternative approaches worth considering, minor efficiency gains, documentation gaps | Nice to have |

3. **Deduplicate and Cross-Reference**

   - Remove duplicate findings across agents (e.g., econometric-reviewer and identification-critic may both flag the same exclusion restriction)
   - Surface solution search results: if past solutions are relevant, tag findings as "Known Pattern — see docs/solutions/[path]"
   - Discard any findings that recommend deleting files in protected artifact directories

4. **Estimation-Specific Synthesis**

   For estimation code changes, synthesize a unified assessment:

   | Dimension | Status | Details |
   |-----------|--------|---------|
   | **Identification** | [valid/concerns/invalid] | Summary from econometric-reviewer + identification-critic |
   | **Estimation** | [correct/issues/incorrect] | Summary from econometric-reviewer + numerical-auditor |
   | **Inference** | [valid/concerns/invalid] | Standard error assessment from econometric-reviewer |
   | **Numerical Stability** | [stable/warnings/unstable] | Summary from numerical-auditor |
   | **Reproducibility** | [complete/gaps/missing] | Summary from reproducibility-auditor (if run) |
   | **Rigor** | [publication-ready/needs-work/insufficient] | Summary from journal-referee (if run) |

### Phase 4: Action

1. **Create Todos for All Findings**

   Use TodoWrite to create actionable items for all CRITICAL and WARNING findings:

   ```
   TodoWrite([
     { id: "review-001", task: "[CRITICAL] description", status: "pending" },
     { id: "review-002", task: "[WARNING] description", status: "pending" },
     ...
   ])
   ```

   For NOTES: include as a summary list — do not create individual todos unless the note is actionable.

2. **Generate Review Summary**

   ```markdown
   ## Econometric Review Complete

   **Review Target:** [files/directory/plan reviewed]

   ### Estimation Assessment
   | Dimension | Status |
   |-----------|--------|
   | Identification | [status] |
   | Estimation | [status] |
   | Inference | [status] |
   | Numerical Stability | [status] |
   | Reproducibility | [status] |
   | Rigor | [status] |

   ### Findings Summary
   - **CRITICAL:** [count] — must fix before proceeding
   - **WARNING:** [count] — should fix
   - **NOTE:** [count] — suggestions

   ### CRITICAL Findings
   1. [finding with agent source and file location]
   2. ...

   ### WARNING Findings
   1. [finding with agent source and file location]
   2. ...

   ### Notes
   - [summarized notes]

   ### Known Patterns (from docs/solutions/)
   - [any matches from solution search]

   ### Review Agents Used
   - econometric-reviewer
   - numerical-auditor
   - identification-critic
   - [conditional agents if triggered]
   - docs/solutions/ search

   ### Next Steps
   1. Address CRITICAL findings (must fix before proceeding)
   2. Address WARNING findings (recommended)
   3. Run `/workflows:compound` to document any novel solutions
   ```

---

## Review Perspectives

The review evaluates changes from multiple research-relevant angles:

### Methodological Rigor
- Is the identification strategy valid and complete?
- Are the maintained assumptions stated and plausible?
- Does the estimation approach match the identification argument?
- Are diagnostics and specification tests appropriate?

### Numerical Quality
- Does estimation code handle floating-point correctly?
- Are convergence criteria appropriate?
- Is the code robust to ill-conditioned data?
- Are random seeds set for all stochastic operations?

### Reproducibility
- Can results be reproduced from the replication package?
- Are all dependencies pinned?
- Does the pipeline run end-to-end without manual steps?
- Are data sources documented and accessible?

### Contribution (Referee Perspective, if triggered)
- Is the contribution clearly stated?
- How does this relate to existing literature?
- Are results economically meaningful (not just statistically significant)?
- What would a skeptical referee ask for?

---

## Configuring Review Agents

Review agents are configured in `compound-science.local.md` at the project root. The YAML frontmatter controls which agents run:

```yaml
---
review_agents:
  - econometric-reviewer
  - numerical-auditor
  - identification-critic
  # Uncomment to always include:
  # - journal-referee
  # - reproducibility-auditor
---
```

The markdown body provides additional context passed to all review agents:

```markdown
## Review Context
Focus on identification strategy — this paper uses a shift-share instrument
and we need to verify the exclusion restriction argument is complete.
```

To create or modify settings, edit `compound-science.local.md` directly.

---

## Severity Scale

All review findings must use this severity scale:

| Severity | Meaning | Action Required | Research Example |
|----------|---------|----------------|-----------------|
| **P0** | Invalidates core result | Must fix before proceeding | Identification failure, wrong estimator for the DGP |
| **P1** | Materially affects conclusions | Should fix | Wrong standard errors, convergence failure, missing first-stage |
| **P2** | Weakens but doesn't invalidate | Fix if straightforward | Missing robustness check, incomplete sensitivity analysis |
| **P3** | Style or documentation | Author's discretion | Code comments, variable naming, table formatting |

Aggregate verdict: **Ready** / **Ready with fixes** / **Not ready**

---

### Phase 5: Handoff

**Pipeline mode** (when invoked from `/lfg` or `/slfg`):
- Skip the interactive menu
- Auto-invoke `/workflows:compound` to document findings

**Standalone mode** (when invoked directly by the user):
- After the Phase 4 review summary, present options:
  1. **Document findings** (Recommended if issues were found) — Immediately run `/workflows:compound` to capture solutions
  2. **Fix findings** — Run `/workflows:work` to implement fixes for review findings
  3. **End session** — Stop here; the review summary is displayed
