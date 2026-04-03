---
name: workflows:work
description: Execute research implementation plans efficiently while maintaining estimation quality and finishing features
argument-hint: "<plan file, estimation specification, or task description>"
allowed-tools: Read, Glob, Edit, Write, Bash
---

# Work Plan Execution Command

**Pipeline mode:** This command operates fully autonomously. All decisions are made automatically.

Execute a research implementation plan systematically. The focus is on **shipping complete, reproducible research code** by understanding requirements quickly, following existing patterns, and maintaining estimation quality throughout.

## Input Document

<input_document> #$ARGUMENTS </input_document>

**If no input document is provided:** Look for the most recent plan in `docs/plans/` and use it. If no plans exist, state "No plan found. Run `/workflows:plan` first." and stop.

## Execution Workflow

### Phase 1: Quick Start

1. **Read Plan**

   - Read the work document completely
   - Review any references, brainstorm origins, or linked code paths
   - Identify the estimation method, identification strategy, and key deliverables
   - Note any open questions from planning — resolve by picking the conservative default and documenting the choice
   - **Proceed immediately** — do not wait for approval

2. **Setup Environment**

   First, detect the project environment:

   ```bash
   # Detect estimation language
   if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
     echo "LANG=python"
   elif [ -f "DESCRIPTION" ] || [ -f "renv.lock" ] || [ -f ".Rprofile" ]; then
     echo "LANG=R"
   elif [ -f "Project.toml" ]; then
     echo "LANG=julia"
   elif ls *.do >/dev/null 2>&1; then
     echo "LANG=stata"
   fi

   # Detect pipeline tools
   ls Makefile Snakefile dvc.yaml 2>/dev/null
   ```

   Then check the current branch:

   ```bash
   current_branch=$(git branch --show-current)
   default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   if [ -z "$default_branch" ]; then
     default_branch=$(git rev-parse --verify origin/main >/dev/null 2>&1 && echo "main" || echo "master")
   fi
   ```

   **If already on a feature branch** (not the default branch):
   - Continue working on it. Proceed to step 3.

   **If on the default branch:**

   **Option A: Create a new branch (default)**
   ```bash
   git pull origin $default_branch
   git checkout -b <branch-name-from-plan>
   ```
   Use a meaningful name derived from the plan (e.g., `feat/callaway-santanna-did`, `fix/blp-convergence`).

   **Option B: Use a worktree (for parallel estimation runs)**
   See `references/worktree-patterns.md` if the plan involves parallel workstreams or the user has multiple active branches.

   Automatically choose Option A unless the plan explicitly mentions parallel workstreams.

3. **Activate Research Environment**

   Read `compound-science.local.md` for environment configuration. Then activate:

   **Python:**
   ```bash
   # Activate virtual environment
   if [ -d ".venv" ]; then source .venv/bin/activate
   elif [ -d "venv" ]; then source venv/bin/activate
   elif command -v conda &>/dev/null; then conda activate $(basename $PWD)
   fi
   # Verify key packages
   python -c "import numpy, scipy, pandas; print('Core packages OK')"
   ```

   **R:**
   ```bash
   # Check renv status
   Rscript -e "if (file.exists('renv.lock')) renv::status()"
   ```

   **Verify data paths:**
   ```bash
   # Check that referenced data files exist
   ls data/ 2>/dev/null | head -5
   ```

4. **Create Task List**
   - Use TodoWrite to break plan into actionable tasks
   - Include dependencies between tasks
   - Prioritize based on the plan's phase structure
   - Include estimation-specific quality check tasks:
     - Convergence verification after each estimation step
     - Standard error computation and diagnostic tests
     - Robustness checks specified in the plan
   - Keep tasks specific and completable

### Phase 2: Execute

1. **Task Execution Loop**

   For each task in priority order:

   ```
   while (tasks remain):
     - Mark task as in_progress in TodoWrite
     - Read any referenced files from the plan
     - Look for similar patterns in codebase
     - Implement following existing conventions
     - Write tests for new functionality
     - Run Estimation Quality Check (see below)
     - Run tests after changes
     - Mark task as completed in TodoWrite
     - Mark off the corresponding checkbox in the plan file ([ ] → [x])
     - Evaluate for incremental commit (see below)
   ```

   **Estimation Quality Check** — Before marking an estimation task done:

   | Check | What to verify |
   |-------|---------------|
   | **Convergence** | Did the optimizer converge? Check exit flag, gradient norm, iteration count. Multiple starting values yield consistent results? |
   | **Sensible estimates** | Are parameter signs correct? Magnitudes economically reasonable? No values at boundary constraints? |
   | **Standard errors** | Computed with appropriate method (robust, clustered, bootstrap)? Positive definite Hessian? No suspiciously small or large SEs? |
   | **Diagnostics** | First-stage F > 10 (if IV)? Overidentification test (if overidentified)? Hausman or specification tests where relevant? |
   | **Numerical stability** | Log-likelihood (not likelihood) used? Condition number of key matrices acceptable? No NaN/Inf in outputs? |
   | **Reproducibility** | Random seeds set? Results identical across runs? Dependencies pinned? |

   **When to skip:** Pure data cleaning, documentation updates, or pipeline configuration changes that don't involve estimation. If the task is purely additive (new utility function, data loading), the check takes 10 seconds and the answer is "no estimation, skip."

   **When this matters most:** Any change that touches estimation routines, moment conditions, likelihood functions, or simulation code.

   **IMPORTANT**: Always update the original plan document by checking off completed items. Use the Edit tool to change `- [ ]` to `- [x]` for each task you finish.

2. **Incremental Commits**

   After completing each task, evaluate whether to create an incremental commit:

   | Commit when... | Don't commit when... |
   |----------------|---------------------|
   | Estimation step complete with verified convergence | Partial estimation code that won't run |
   | Data pipeline stage verified | Incomplete data transformation |
   | Tests pass + meaningful progress | Tests failing |
   | About to switch contexts (data work → estimation) | Purely scaffolding with no behavior |
   | Robustness check complete | Would need a "WIP" commit message |

   **Heuristic:** "Can I write a commit message that describes a complete, verifiable change? If yes, commit."

   **Commit workflow:**
   ```bash
   # 1. Verify tests pass (use project's test command)
   # Examples: pytest, Rscript tests/run_tests.R, etc.

   # 2. Stage only files related to this logical unit
   git add <files related to this logical unit>

   # 3. Commit with conventional message
   git commit -m "feat(estimation): description of this unit"
   ```

   **Note:** Incremental commits use clean conventional messages. The final Phase 4 commit/PR includes full attribution.

3. **Follow Existing Patterns**

   - The plan should reference similar code — read those files first
   - Match naming conventions exactly (variable names, function signatures, file organization)
   - Reuse existing estimation utilities where possible
   - Follow project coding standards (see CLAUDE.md)
   - When in doubt, grep for similar implementations

4. **Test Continuously**

   - Run relevant tests after each significant change
   - Don't wait until the end to test
   - Fix failures immediately
   - Add new tests for new functionality
   - For estimation code: verify convergence AND test with known-parameter DGP if feasible

5. **Track Progress**
   - Keep TodoWrite updated as you complete tasks
   - Note any convergence issues or unexpected results
   - Create new tasks if scope expands (e.g., new robustness check needed)
   - Log estimation results at milestones (point estimates, standard errors, diagnostics)

### Phase 3: Quality Check


1. **Run Core Quality Checks**

   Always run before submitting:

   ```bash
   # Run full test suite
   # Python: pytest
   # R: Rscript tests/run_tests.R or testthat::test_dir("tests")

   # Run linting (per CLAUDE.md)
   # Python: ruff check . or flake8
   # R: lintr::lint_dir()
   ```

2. **Estimation-Specific Validation**

   For any work involving estimation:

   - [ ] Estimation converges with sensible parameters (check all specifications)
   - [ ] Standard errors computed correctly (appropriate clustering/robustness)
   - [ ] Diagnostic tests run and results documented
   - [ ] Multiple starting values checked (if nonlinear estimation)
   - [ ] Results reproducible with fixed random seed
   - [ ] No numerical warnings (NaN, overflow, singular matrices)

3. **Consider Reviewer Agents** (Optional)

   Use for complex or risky changes. Read agents from `compound-science.local.md` frontmatter (`review_agents`). If no settings file, create one following the template in `workflows-review/references/project-config.md`.

   Run configured agents in parallel with Task tool. Address critical issues before proceeding.

   Default agents for estimation work:
   - `econometric-reviewer` — identification and inference review
   - `numerical-auditor` — numerical stability and convergence
   - `identification-critic` — identification argument completeness

4. **Final Validation**
   - All TodoWrite tasks marked completed
   - All tests pass
   - Linting passes
   - Estimation converges with sensible results
   - Standard errors and diagnostics computed
   - Code follows existing patterns
   - Random seeds set and documented
   - No console errors or warnings

### Phase 4: Ship It

1. **Create Commit**

   ```bash
   git add <relevant files>
   git status  # Review what's being committed
   git diff --staged  # Check the changes

   git commit -m "$(cat <<'EOF'
   feat(estimation): description of what and why

   Brief explanation if needed.

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

2. **Create Pull Request**

   ```bash
   git push -u origin <branch-name>

   gh pr create --title "feat(estimation): [Description]" --body "$(cat <<'EOF'
   ## Summary
   - What was implemented
   - Methodological approach and key decisions
   - Estimation results summary (if applicable)

   ## Estimation Quality
   - Convergence: [status]
   - Diagnostics: [first-stage F, overid test, specification tests]
   - Robustness: [alternative specifications checked]

   ## Testing
   - Tests added/modified
   - Estimation verified with [approach]

   ## Reproducibility
   - Random seeds: [set/documented]
   - Pipeline: [runs end-to-end / specific steps]
   - Dependencies: [pinned in requirements.txt/renv.lock]

   ## Research Impact
   - Identification: [any changes to assumptions]
   - Estimation: [computational cost, convergence]
   - Robustness: [new checks added/updated]
   - Replication: [package changes]
   EOF
   )"
   ```

3. **Update Plan Status**

   If the input document has YAML frontmatter with a `status` field, update it:
   ```
   status: active  →  status: completed
   ```

4. **Summary**
   - Display what was completed
   - Link to PR
   - Summarize estimation results if applicable
   - Note any follow-up work needed (additional robustness checks, referee suggestions)

### Phase 5: Handoff

**Pipeline mode** (when invoked from `/lfg` or `/slfg`):
- Skip the interactive menu
- Auto-invoke `/workflows:review` on the files that were changed

**Standalone mode** (when invoked directly by the user):
- After the Phase 4 summary, present options:
  1. **Proceed to review** (Recommended) — Immediately run `/workflows:review` in this session
  2. **Continue working** — Return to Phase 2 task loop for additional implementation
  3. **End session** — Stop here; changes are committed

---

## Swarm Mode (Optional)

For complex plans with multiple independent workstreams, enable swarm mode for parallel execution.

### When to Use Swarm Mode

| Use Swarm Mode when... | Use Standard Mode when... |
|------------------------|---------------------------|
| Plan has independent estimation specifications | Single estimation pipeline |
| Multiple robustness checks can run in parallel | Sequential estimation steps |
| Monte Carlo with independent DGP variants | Simple parameter change |
| Large replication package with separable components | Small feature or bug fix |

### Enabling Swarm Mode

To trigger swarm execution, say:

> "Make a Task list and launch an army of agent swarm subagents to build the plan"

See `references/orchestration-patterns.md` in the `slfg` skill for detailed swarm patterns and best practices.

---

## Key Principles

### Start Fast, Execute Methodically

- Read the plan, set up environment, then execute
- Don't wait for perfect understanding — resolve ambiguity by picking conservative defaults
- The goal is to **finish the implementation with verified estimation quality**

### The Plan is Your Guide

- Plans reference existing code, methods papers, and brainstorm decisions — load those references
- Follow the plan's phase structure and acceptance criteria
- Don't reinvent — match existing patterns in the codebase

### Test Estimation Quality Continuously

- Verify convergence after each estimation step, not at the end
- Check diagnostics as you go — fix issues immediately
- Continuous quality checking prevents late-stage surprises

### Quality is Built In

- Follow existing patterns
- Write tests for new code
- Verify estimation convergence and diagnostics
- Run linting before pushing
- Use reviewer agents for complex or risky estimation changes only

### Ship Complete, Reproducible Research

- Mark all tasks completed before moving on
- Don't leave estimation code 80% done — partial results are worse than no results
- A finished, reproducible implementation ships; a perfect but incomplete one doesn't
- Seeds set, dependencies pinned, pipeline runs end-to-end

## Quality Checklist

Before creating PR, verify:

- [ ] All TodoWrite tasks marked completed
- [ ] Tests pass
- [ ] Linting passes
- [ ] Estimation converges with sensible parameters
- [ ] Standard errors computed correctly
- [ ] Diagnostic tests run and documented
- [ ] Random seeds set and results reproducible
- [ ] Code follows existing patterns
- [ ] Commit messages follow conventional format
- [ ] PR description includes estimation quality section
- [ ] PR description includes reproducibility section
- [ ] PR description includes research impact section
- [ ] Plan file updated with completed checkboxes

## Common Pitfalls to Avoid

- **Skipping convergence checks** — verify estimation converged, don't assume it did
- **Wrong standard errors** — check clustering level, robustness to heteroskedasticity, bootstrap if needed
- **Missing seeds** — set random seeds BEFORE any stochastic computation
- **Ignoring plan references** — the plan has code paths and method citations for a reason
- **Testing at the end** — test continuously or discover convergence failures too late
- **80% done syndrome** — finish the estimation, run diagnostics, compute standard errors
- **Hardcoded paths** — use relative paths, check data directory structure

## Routes To

- `/workflows:review` — review the implementation
- `/workflows:compound` — document solutions discovered during implementation
