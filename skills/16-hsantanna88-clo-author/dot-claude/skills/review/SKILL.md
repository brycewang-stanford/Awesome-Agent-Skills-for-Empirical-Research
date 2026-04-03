---
name: review
description: All quality reviews — routes to appropriate critics based on target file type and flags. Replaces /paper-excellence, /proofread, /econometrics-check, /review-r, /review-paper.
argument-hint: "[file path or --flag] Options: --peer [journal], --stress [journal], --methods, --proofread, --code, --replicate [lang], --all"
allowed-tools: Read,Grep,Glob,Write,Bash,Task
---

# Review

Unified review command that routes to the appropriate critic agents based on the target and flags.

**Input:** `$ARGUMENTS` — file path and/or flags.

---

## Routing Logic

### Auto-detect by file type
- `.tex` paper file → **Comprehensive review** (writer-critic + strategist-critic + Verifier)
- `.R`, `.py`, `.do`, `.jl` file → **Code review** (coder-critic standalone, categories 4-12)
- `.tex` talk file (in talks/) → **Talk review** (storyteller-critic)

### Explicit flags (override auto-detect)
- `--peer [journal]` → **Full peer review** (editor desk review → referee dispatch → editorial decision)
- `--peer --r2 [journal]` → **R&R second round** (same referees, same dispositions, memory of prior review)
- `--stress [journal]` → **Hostile stress test** (same flow, adversarial referee dispositions)
- `--methods` → **Causal audit** (strategist-critic standalone, 4-phase review)
- `--proofread` → **Manuscript polish** (writer-critic standalone, 6 categories)
- `--code [file]` → **Code review** (coder-critic standalone, categories 4-12)
- `--replicate [language]` → **Cross-language replication** (Coder re-implements in target language + coder-critic + comparison)
- `--all` or no file → **Paper excellence** (all critics in parallel + weighted score)

---

## Mode Details

### Comprehensive Review (default for .tex paper)
Dispatch in parallel:
1. **strategist-critic** — causal design audit (4 phases)
2. **writer-critic** — manuscript polish (6 categories)
3. **Verifier** — compilation check
Compute weighted aggregate score.

### Full Peer Review (`--peer [journal]`)

Simulates a realistic journal submission. Three phases, orchestrated sequentially.

#### Phase 1: Editor Desk Review
Dispatch the **editor** agent with the paper and target journal.

The editor:
1. Reads the paper (abstract, intro, contribution, identification, results)
2. Searches the literature via WebSearch to verify novelty claims
3. Decides: **DESK REJECT** or **SEND TO REFEREES**
4. If desk reject → report with reasons + suggested alternative journals. Done.
5. If send to referees → editor selects referee dispositions and pet peeves from the journal's **Referee pool** (see .claude/references/journal-profiles.md)

#### Phase 2: Referee Reports
The editor's referee assignment specifies for each referee:
- **Disposition** (one of: STRUCTURAL, CREDIBILITY, MEASUREMENT, POLICY, THEORY, SKEPTIC)
- **Critical pet peeve** (one from the critical pool)
- **Constructive pet peeve** (one from the constructive pool)

Dispatch **domain-referee** and **methods-referee** in parallel, each receiving:
1. The paper manuscript
2. The target journal name (for .claude/references/journal-profiles.md calibration)
3. Their assigned disposition and pet peeves, injected into the prompt:

```
DISPOSITION: [disposition name]
You approach this paper with the following intellectual prior: [disposition description]
This shapes your emphasis, not your scoring rubric — the 5 dimensions remain the same.

PET PEEVES:
- Critical: [critical pet peeve]
- Constructive: [constructive pet peeve]
Give extra weight to these in your review. The critical peeve is something you particularly
care about and will scrutinize. The constructive peeve is something you appreciate and will
reward when present.
```

Both reviews are independent and blind — neither referee sees the other's report.

Every major comment MUST include a **"What would change my mind"** statement — not just "this is wrong" but the specific evidence, test, or analysis that would resolve the concern.

#### Phase 3: Editorial Decision
Dispatch the **editor** agent again with both referee reports.

The editor:
1. Classifies each concern as FATAL / ADDRESSABLE / TASTE
2. When referees disagree, takes a side and explains why
3. Produces a decision letter: Accept / Minor Revisions / Major Revisions / Reject
4. Lists MUST address, SHOULD address, and MAY push back items

#### Save Reports
Save all outputs to `quality_reports/reviews/`:
- `YYYY-MM-DD_desk_review.md` (Phase 1)
- `YYYY-MM-DD_referee_domain.md` (Phase 2)
- `YYYY-MM-DD_referee_methods.md` (Phase 2)
- `YYYY-MM-DD_editorial_decision.md` (Phase 3)

Log the referee assignments (dispositions + pet peeves) in the editorial decision so the user can re-run with different combinations.

### R&R Second Round (`--peer --r2 [journal]`)

Continues the review cycle after the author has revised the paper.

1. **Load prior review state** — read previous referee reports and editorial decision from `quality_reports/reviews/`
2. **Skip desk review** — the paper was already accepted for review
3. **Same referees** — reload the same dispositions and pet peeves from round 1
4. **Referee R&R mode** — each referee receives their previous report alongside the revised manuscript:

```
You previously reviewed this paper. Your prior report is attached.
Check whether each concern you raised has been adequately addressed.
New concerns may arise from the revisions. Score the revision, not
the original — improvement matters.
```

They check whether each concern was: Resolved / Partially resolved / Not addressed. They may flag new concerns from the revisions.

5. **Editor R&R decision** — Round 2 allows Accept/Minor/Major/Reject. Round 3 allows Accept/Minor/Reject only. Max 3 rounds total — editor's patience runs out, just like real life.
6. **Save reports** with `_r2` or `_r3` suffix to `quality_reports/reviews/`

### Hostile Stress Test (`--stress [journal]`)

Same three-phase flow as `--peer`, with these changes:

1. **Editor assigns adversarial dispositions** — both referees get SKEPTIC or the most demanding disposition for that journal
2. **Double pet peeves** — each referee gets 2 critical and 1 constructive (instead of 1 and 1)
3. **Referee prompt addition:**
```
You are looking for reasons to REJECT this paper. Your prior is that
the paper is not good enough for [journal]. The authors must convince
you otherwise. Be specific about what would change your mind.
```

This is for pre-submission stress testing. If the paper survives two hostile referees, it's ready.

### Code Review (`--code` or auto-detect .R/.py/.do/.jl)

Dispatch **coder-critic** in standalone mode.

#### Full 12-Category Code Review Checklist

**Strategic alignment (categories 1-3) — only run within the pipeline or via `--methods`:**

| # | Category | What It Checks |
|---|----------|----------------|
| 1 | Design fidelity | Does code implement the strategy memo's design? |
| 2 | Estimand alignment | Does code estimate what the paper claims? |
| 3 | Specification match | Do controls, fixed effects, and samples match the paper? |

**Code quality (categories 4-12) — always run in standalone mode:**

| # | Category | What It Checks |
|---|----------|----------------|
| 4 | Script structure | Header, sections, logical flow |
| 5 | Console hygiene | No print/cat pollution, clean output |
| 6 | Reproducibility | set.seed, relative paths, no hardcoded values |
| 7 | Function design | DRY, appropriate abstraction level |
| 8 | Figure quality | Labels, dimensions, theme, transparency |
| 9 | RDS pattern | saveRDS for all computed objects |
| 10 | Comments | Explain why, not what |
| 11 | Error handling | Graceful failures, informative messages |
| 12 | Polish | Consistent style, no dead code, clean namespace |

#### Severity Calibration Examples

| Example | Severity |
|---------|----------|
| Missing `set.seed()` in stochastic script | **Major** |
| Hardcoded absolute path (`/Users/name/...`) | **Major** |
| No error handling on data load | **Major** |
| Missing comment on complex transformation | **Minor** |
| Inconsistent naming convention | **Minor** |
| Dead code left in script | **Minor** |
| Missing figure axis labels | **Major** |
| Using `print()` for debugging left in production | **Minor** |
| No package loading section at top of script | **Major** |

**Do NOT edit any source files.** Only produce reports. Fixes are applied after user review, either manually or by re-dispatching the Coder agent.

Save report to `quality_reports/[file]_code_review.md`

### Causal Audit (`--methods`)

Dispatch **strategist-critic** standalone for a full 4-phase causal inference review.

#### 4-Phase Econometrics Review Protocol

**Phase 1: Claim Identification**
- What causal design is used? (DiD, IV, RDD, Synthetic Control, Event Study, etc.)
- What is the estimand? (ATT, ATE, LATE, ITT, etc.)
- What is the treatment? What is the control?
- Is the design clearly stated and internally consistent?

**Phase 2: Core Design Validity**
- Design-specific assumption check:
  - **DiD:** Parallel trends (pre-trends test, event study plot), no anticipation, stable composition
  - **IV:** Relevance (first stage F), exclusion restriction, monotonicity
  - **RDD:** Continuity, no manipulation (McCrary/density test), bandwidth sensitivity
  - **Synthetic Control:** Pre-treatment fit, donor pool selection, no interference
  - **Event Study:** Clean identification of event timing, no confounding events, appropriate window
- Sanity check: Are the sign, magnitude, and dynamics of the estimates plausible?
- **EARLY STOPPING:** If Phase 2 finds CRITICAL issues, focus there instead of continuing to Phases 3-4. A broken design invalidates everything downstream.

**Phase 3: Inference**
- Standard error clustering: Is the clustering level appropriate for the design?
- Multiple testing: Are p-values adjusted when testing multiple outcomes?
- Code-theory alignment: Does the code actually implement what the paper describes?
- Wild bootstrap or other small-sample corrections when needed?

**Phase 4: Polish and Completeness**
- Robustness checks: Alternative specifications, placebo tests, sensitivity analysis
- Sensitivity bounds: Oster (2019), Rambachan & Roth (2023), or equivalent
- Citation fidelity: Are methodological citations accurate?
- Are limitations honestly discussed?

#### Overall Assessment Scale
- **SOUND** — Design is valid, implementation is correct
- **MINOR ISSUES** — Fixable concerns, none threatening core results
- **MAJOR ISSUES** — Significant concerns that could change conclusions
- **CRITICAL ERRORS** — Fundamental design flaw or incorrect implementation

Save report to `quality_reports/[file]_strategy_review.md`

### Manuscript Polish (`--proofread`)
Dispatch **writer-critic** standalone:
- 6 categories: structure, claims-evidence, ID fidelity, writing, grammar, compilation
- Save report to `quality_reports/[file]_proofread_report.md`

### Cross-Language Replication (`--replicate [language]`)
1. Auto-detect source language from file extension
2. Dispatch **Coder** in replication mode — re-implement in target language
3. **coder-critic** reviews both implementations
4. Compare numerical outputs per `.claude/references/domain-profile.md` Quality Tolerance Thresholds
5. Save replicated script and comparison report

---

## Verifier Pass/Fail Definition

The Verifier produces a binary PASS/FAIL result:

**For papers (`.tex`):**
- LaTeX compiles error-free (warnings acceptable, errors not)
- All figures referenced exist and render
- All references resolve (no `??`, no undefined citations)
- All tables render correctly
- Bibliography compiles without errors

**For code (`.R`, `.py`, `.do`, `.jl`):**
- Script runs without errors from start to finish
- All packages loaded at top of script
- No hardcoded absolute paths
- `set.seed()` present once at top if stochastic
- Output files created at expected paths

**For replication packages:**
- All scripts run in declared order
- Outputs match paper tables/figures within tolerance
- README accurately describes the pipeline

Verifier score maps to 0 (FAIL) or 100 (PASS) for weighted aggregation.

---

## Scoring

| Mode | Blocking? | Gate |
|------|-----------|------|
| Comprehensive | Yes | 80 commit, 90 PR |
| Peer Review | Yes | Editorial decision |
| Stress Test | Advisory | Reported, non-blocking |
| Code Review | Yes | 80 commit |
| Causal Audit | Yes | 80 commit |
| Proofread | Yes (paper), Advisory (talks) | 80 commit |

---

## Principles
- **Smart routing.** File type determines the default review mode.
- **Flags override.** Use explicit flags for targeted reviews.
- **Critics never edit.** All reviews produce reports only.
- **Journal drives everything.** The journal profile shapes the editor's bar, referee selection, and review culture.
- **Referees vary.** Different dispositions and pet peeves mean running `/review --peer` twice gives different feedback — just like submitting to two journals would.
- **"What would change my mind."** Every major comment must include the specific evidence or analysis that would resolve the concern.
- **Design-opinionated, package-flexible.** Recommend standard packages (fixest, did, rdrobust, etc.) but accept and validate alternatives. The design matters more than the package.
- **Sequential phases in causal audit.** Never skip to robustness before verifying the core design holds.
- **Proportional severity.** Missing `set.seed()` is Major; missing comment is Minor.
- **Worker-critic separation.** The reviewer never fixes code or rewrites text — it only critiques.
- **Actionable output.** Every issue must have a concrete fix, not vague advice.
