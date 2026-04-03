---
name: stata-skill-contributor
description: >
  Guide for contributing to the stata-skill project. Use when the user wants to
  run the eval pipeline, analyze test results, improve reference docs, add new
  package documentation, or work on roadmap items. Covers the testing
  infrastructure, multi-agent analysis workflow, cost estimates, and links to
  prior eval results and improvement history.
---

# Stata Skill Contributor Guide

This skill helps you contribute to the [stata-skill](https://github.com/dylantmoore/stata-skill) project — the Stata reference skill for Claude Code. It covers how to run the evaluation pipeline, analyze results, and make data-driven improvements to the skill documentation.

## Cost Warning

Running the eval pipeline uses Claude Agent SDK `query()` calls, which consume API credits.

| What | Approximate cost |
|------|-----------------|
| Single task, 1 run | $0.50 - $1.50 |
| Single task, 5 runs | $2.50 - $7.50 |
| All 24 tasks, 1 run each | $12 - $36 |
| All 24 tasks, 5 runs each | $60 - $120 |
| Full A/B comparison (2 arms × 24 tasks × 5 runs) | $120 - $240 |
| Multi-agent post-test analysis (5 Sonnet subagents) | $3 - $8 |

Start small: run 1-3 tasks relevant to your change before running the full suite. Use `--runs 1` to validate the pipeline works before scaling up.

## Quick Reference

| File | What it is |
|------|-----------|
| `tests/eval.py` | Evaluation harness — sends tasks to Claude, judges responses |
| `tests/rubric.md` | 7-category scoring rubric (max 55 points) |
| `tests/tasks/task_*.md` | 24 test task definitions |
| `tests/runner-only-plugin/` | Minimal baseline plugin (execution instructions only) |
| `tests/results/` | All run directories and aggregate JSON results |
| `tests/EVAL_RESULTS_2026-03-22.md` | Prior eval results with full analysis and run index |
| `ROADMAP.md` | Open problems and improvement directions |
| `CONTRIBUTING.md` | General contribution guide (adding packages, filing issues) |

## Running the Eval Pipeline

### Basic commands

```bash
# Single task, single run — fast sanity check (~$1)
python tests/eval.py tests/tasks/task_01_data_cleaning.md

# Single task, 5 runs — measure variance (~$5)
python tests/eval.py tests/tasks/task_01_data_cleaning.md --runs 5

# Save results as a named baseline
python tests/eval.py tests/tasks/task_01_data_cleaning.md --runs 5 \
    --save tests/results/my_baseline.json

# Compare against a baseline
python tests/eval.py tests/tasks/task_01_data_cleaning.md --runs 5 \
    --compare tests/results/my_baseline.json
```

### A/B testing a doc change

```bash
# 1. Save baseline BEFORE your edit
python tests/eval.py tests/tasks/task_16_multiple_imputation.md --runs 5 \
    --save tests/results/before_mi_fix.json

# 2. Make your edit to the reference doc

# 3. Re-run and compare
python tests/eval.py tests/tasks/task_16_multiple_imputation.md --runs 5 \
    --compare tests/results/before_mi_fix.json
```

Look for: mean score going up, SD staying flat or going down, no new failure modes.

### Testing modes

```bash
# Full skill (default) — loads the complete plugin
python tests/eval.py tests/tasks/task_*.md

# Runner-only — minimal plugin with just execution instructions, no reference docs
python tests/eval.py tests/tasks/task_*.md --runner-only

# No skill — no plugin at all
python tests/eval.py tests/tasks/task_*.md --no-skill

# Alternative skill version — point at a different plugin directory
python tests/eval.py tests/tasks/task_*.md --skill-path /path/to/modified/plugin
```

The runner-only baseline is the meaningful comparison. It isolates what the reference material adds beyond "here's how to run Stata." The no-skill baseline is weaker (agent can't even execute code).

### Parallel execution

Run multiple tasks in parallel by launching separate processes:

```bash
python tests/eval.py tests/tasks/task_01_data_cleaning.md --runs 5 \
    --save tests/results/v3_task01.json &
python tests/eval.py tests/tasks/task_07_did.md --runs 5 \
    --save tests/results/v3_task07.json &
wait
```

Batch 3-4 tasks at a time to avoid resource exhaustion. Run directories are created atomically, so parallel execution is safe.

### Output structure

Each run creates `tests/results/run_NNN/` containing:

| File | Contents |
|------|----------|
| `transcript.json` | The test agent's full response |
| `judge_findings.md` | Per-category scores with justifications |
| `metadata.json` | Score, model, skill_mode, cost, duration, timestamp |
| `code_files/` | Any .do/.log files the agent wrote |

Aggregate results are saved to the `--save` path as a JSON list of per-run results.

## Multi-Agent Post-Test Analysis

After running evals, dispatch Sonnet subagents to analyze the results in parallel. This is the workflow that surfaces actionable improvements.

### Step 1: Generate the comparison table

```python
# Quick script to build the comparison table from saved results
import json, statistics
for i in range(1, 25):
    tn = f"{i:02d}"
    with open(f"tests/results/v3_task{tn}.json") as f:
        full = [r["score"] for r in json.load(f) if r["score"] is not None]
    with open(f"tests/results/v3_runner_task{tn}.json") as f:
        runner = [r["score"] for r in json.load(f) if r["score"] is not None]
    fm, rm = statistics.mean(full), statistics.mean(runner)
    print(f"Task {tn}: full={fm:.1f} runner={rm:.1f} delta={fm-rm:+.1f}")
```

### Step 2: Dispatch analysis subagents

Launch 4-5 parallel subagents, each investigating a specific pattern in the results. The prompts below are templates — adapt them to your actual results.

**Agent 1 — Regression analysis (skill hurts):**
> Investigate tasks where the full skill scores LOWER than runner-only. Read the result JSONs, the relevant reference docs, and the judge reasoning for low-scoring runs. Identify specific examples in the reference docs that teach wrong patterns. Compare what the with-skill agent does vs the runner-only agent.

**Agent 2 — Redundancy analysis (skill adds nothing):**
> Investigate tasks where full skill and runner-only score identically. Read the reference docs that would be triggered. Determine whether the content is redundant — the model already knows this material from training. Identify which reference files could be deprioritized or trimmed.

**Agent 3 — High-variance analysis (unreliable tasks):**
> Investigate tasks with SD > 10. Compare the LOW-scoring run vs HIGH-scoring run for each. Identify what went wrong — wrong syntax in the doc? Agent misinterpretation? Context collapse (agent wrote code for wrong task)? Quote specific code that failed.

**Agent 4 — Biggest wins analysis (what works):**
> Investigate the 5 tasks with the largest positive deltas. Read the runner-only judge reasoning to identify specific knowledge gaps. Categorize: community package syntax, Stata-specific idioms, workflow patterns, gotcha avoidance.

**Agent 5 — Graphics/weak area analysis:**
> Investigate the lowest-scoring full-skill tasks. Compare successful vs failed runs. Identify missing content in the reference docs.

### Step 3: Compile findings and make changes

Each agent returns specific, evidence-backed proposals. Typical findings:

- **Bugs in docs**: Wrong syntax that the agent copies faithfully (highest priority to fix)
- **Missing gotchas**: Common errors the docs don't warn about
- **Missing workflows**: Multi-step patterns the agent needs but can't find
- **Redundant content**: Topics the model already knows (lowest priority)

Fix bugs first, add missing gotchas second, then re-run to verify improvement.

### Example: prior results

See `tests/EVAL_RESULTS_2026-03-22.md` for a complete example of this workflow applied to the full 24-task suite. That analysis:
- Found 4 bugs in reference docs (wrong `mi estimate` pattern, wrong `ssc install` command, wrong variable names)
- Added 3 missing gotchas (`graph box`/`twoway` incompatibility, DiD event-study syntax, `nlcom` clobbers `e()`)
- Added 1 missing workflow (standardized coefficients in coefplot)
- Identified the "anchoring effect" — skills keep the agent on-task even when the content is "redundant"

## Deeper Engagement: Roadmap

See `ROADMAP.md` for bigger-picture improvement directions:

- **Gotchas-only skill variant**: Test whether a stripped-down skill with just gotchas (no reference files) scores close to the full skill. If so, the references are mostly noise.
- **Better test prompts**: Current prompts are structured step-by-step. Real researcher interactions are messier — goal-oriented, ambiguous, multi-step. Design tests that match real use.
- **Harder tests**: Several tasks hit ceiling (both arms score 55/55). Need tasks that discriminate — exact numerical verification, edge cases, less-common options.
- **The anchoring effect**: The skill's biggest contribution isn't always syntax knowledge — it's keeping the agent focused on the correct task. This has implications for how all skills should be designed and evaluated.
- **Real-world empirical test suite**: Tasks based on actual published papers with replication data.
- **Dynamic help file access**: Let the agent query Stata's built-in help system at runtime.

## Contribution Workflow Summary

1. **Identify a gap**: Run the eval, read judge findings from low-scoring runs, or pick a roadmap item
2. **Save a baseline**: `--runs 5 --save` on the relevant tasks
3. **Make your change**: Edit the reference/package doc
4. **Re-run and compare**: `--compare` against the baseline
5. **Dispatch analysis agents** if the results are surprising or if you want deeper insight
6. **Open a PR** with your results (scores, variance, before/after). See `CONTRIBUTING.md` for details.
