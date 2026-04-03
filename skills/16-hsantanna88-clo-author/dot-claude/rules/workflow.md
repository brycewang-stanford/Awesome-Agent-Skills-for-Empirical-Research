# Workflow: Planning, Orchestration, and Dependencies

---

## 1. Plan-First Protocol

**For any non-trivial task, enter plan mode before writing code.**

### The Protocol

1. **Enter Plan Mode** — use `EnterPlanMode`
2. **Check MEMORY.md** — read any `[LEARN]` entries relevant to this task
3. **Requirements Specification (for complex/ambiguous tasks)** — see below
4. **Draft the plan** — what changes, which files, in what order
5. **Save to disk** — write to `quality_reports/plans/YYYY-MM-DD_short-description.md`
6. **Present to user** — wait for approval
7. **Exit plan mode** — only after approval
8. **Save initial session log** — capture goal and key context while fresh
9. **Implement via orchestrator** — see Section 2

### Requirements Specification (For Complex/Ambiguous Tasks)

**When to use:**
- Task is high-level or vague ("improve the lecture", "analyze the data")
- Multiple valid interpretations exist
- Significant effort required (>1 hour or >3 files)

**When to skip:**
- Task is clear and specific ("fix typo in line 42")
- Simple single-file edit
- User has already provided detailed requirements

**Protocol:**
1. Use AskUserQuestion to clarify ambiguities (max 3-5 questions)
2. Create `quality_reports/specs/YYYY-MM-DD_description.md` using `templates/requirements-spec.md`
3. Mark each requirement:
   - **MUST** (non-negotiable)
   - **SHOULD** (preferred)
   - **MAY** (optional)
4. Declare clarity status for each major aspect:
   - **CLEAR:** Fully specified
   - **ASSUMED:** Reasonable assumption (user can override)
   - **BLOCKED:** Cannot proceed until answered
5. Get user approval on spec
6. THEN proceed to Step 4 (draft the plan) with spec as input

**Template:** `templates/requirements-spec.md`

**Why this helps:** Catches ambiguity BEFORE planning. Reduces mid-plan pivots by 30-50%.

### Plans on Disk

Plans survive context compression. Save every plan to:

```
quality_reports/plans/YYYY-MM-DD_short-description.md
```

Format: Status (DRAFT/APPROVED/COMPLETED), approach, files to modify, verification steps.

---

## 2. The Orchestrator Loop

**After a plan is approved, the orchestrator takes over autonomously.**

### The Dependency-Driven Loop

```
Plan approved → orchestrator activates
  │
  Step 1: IDENTIFY — Check dependency graph, determine which phases can activate
  │
  Step 2: DISPATCH — Launch worker agents (parallel when independent)
  │         Each worker paired with its critic (see agents.md)
  │
  Step 3: REVIEW — Critic evaluates worker output, produces score
  │         If score < 80 → worker fixes → critic re-reviews (max 3 rounds)
  │         If 3 rounds fail → ESCALATE (see agents.md)
  │
  Step 4: VERIFY — Compile, render, run code, check outputs
  │         If verification fails → fix → re-verify (max 2 attempts)
  │
  Step 5: SCORE — Aggregate scores across components (see quality.md)
  │
  └── Score >= threshold?
        YES → Present summary to user
        NO  → Identify blocking components, loop back to Step 2
              After max 5 overall rounds → present with remaining issues
```

### Agent Dispatch Rules

The Orchestrator selects agents based on what the task requires:

| Task Involves | Agents Dispatched |
|--------------|-------------------|
| Literature/references | librarian + librarian-critic |
| Data sourcing | explorer + explorer-critic |
| Data engineering | data-engineer + coder-critic |
| Identification strategy | strategist + strategist-critic |
| R/Stata/Python scripts | coder + coder-critic |
| Paper manuscript | writer + writer-critic |
| Peer review | Orchestrator → domain-referee + methods-referee |
| Beamer talks | storyteller + storyteller-critic |
| Replication package | verifier (submission mode) |
| Compilation only | verifier (standard mode) |

### Parallel Dispatch

Independent phases run concurrently:
- Literature and Data discovery run in parallel
- Code and Paper execution run in parallel (after Strategy)
- Presentation can run parallel with Peer Review

### Limits

- **Worker-critic pairs:** max 3 rounds (then escalate)
- **Overall loop:** max 5 rounds
- **Verification retries:** max 2 attempts
- Never loop indefinitely

### Simplified Mode (R Scripts / Explorations)

For standalone R scripts, simulations, and explorations — use the simplified loop:

```
Plan approved → implement → run code → check outputs → score → done
```

No multi-agent reviews. Just: write, test, verify quality >= 80.

**Verification Checklist (Simplified):**
- [ ] Script runs without errors
- [ ] All packages loaded at top
- [ ] No hardcoded absolute paths
- [ ] `set.seed()` once at top if stochastic
- [ ] Output files created at expected paths
- [ ] Quality score >= 80

### "Just Do It" Mode

When user says "just do it" / "handle it":
- Skip final approval pause
- Auto-commit if score >= 80
- Still run the full verify-review-fix loop
- Still present the summary

---

## 3. Dependency Graph

**Phases activate by dependency, not sequence. Research is not a waterfall.**

### Phase Dependencies

| Phase | Requires | Can Re-enter? |
|-------|----------|---------------|
| Discovery | Research idea | Always — librarian is persistent |
| Strategy | At least one of: literature review OR data assessment | Yes — new data or literature can trigger re-strategy |
| Execution (Code) | Approved strategy (strategist-critic >= 80) | Yes — strategy revision triggers re-coding |
| Execution (Write) | Approved code (coder-critic >= 80) | Yes — new results trigger rewriting |
| Peer Review | Approved paper (writer-critic >= 80) + approved code | Yes — major revisions loop back |
| Submission | Orchestrator accepts + Verifier PASS + overall >= 95 | No — terminal |
| Presentation | Approved paper (can run parallel with Peer Review) | Yes — paper revisions trigger talk updates |

### How It Works

The Orchestrator checks the dependency graph before dispatching any agent. If a phase's inputs are satisfied, it can activate — regardless of whether earlier phases are "complete."

**Example — entering mid-pipeline:**
You already have data and a draft paper. You can enter at Strategy (skip Discovery) or even at Peer Review (skip Execution). The Orchestrator checks dependencies, not phase numbers.

**Example — targeted re-entry:**
A referee says "control for X." The Orchestrator routes back to coder (not through the full pipeline), coder-critic reviews, writer updates, writer-critic reviews the update, then back to peer review.

### Parallel Activation

Independent phases run concurrently:
- Literature (librarian + librarian-critic) and Data (explorer + explorer-critic) run in parallel
- Code (coder + coder-critic) and Paper (writer + writer-critic) run in parallel after Strategy
- Presentation can run parallel with Peer Review

---

## 4. Standalone Access

**Any skill can be invoked directly, bypassing the pipeline.**

### Two Modes

**Mode 1: Orchestrated (within the pipeline)**

The Orchestrator dispatches agents through the dependency graph. The user says:

> "I want to study the effect of minimum wage on employment using CPS data."

The Orchestrator activates Discovery → Strategy → Execution → Peer Review automatically.

**Mode 2: Standalone (direct access)**

The user invokes a skill directly:

> `/strategize paper/main.tex`

This runs the strategist-critic agent alone, right now, no phase dependencies.

### Why Both Modes

- **Pipeline mode** is for full projects where the Orchestrator manages the flow
- **Standalone mode** is for targeted tasks: "just check this one thing"
- Most users start with standalone skills and graduate to the pipeline

### Standalone Skills

All skills in the reference below work without pipeline context when invoked directly. They dispatch their agent(s) and return results.

| Skill | What It Does |
|-------|-------------|
| `/discover` | Literature search + data discovery |
| `/strategize` | Identification strategy design + review |
| `/analyze` | End-to-end data analysis (code + debug) |
| `/write` | Draft paper sections + humanizer pass |
| `/review` | Simulated peer review (domain + methods referees) |
| `/revise` | R&R routing per revision-protocol |
| `/talk` | Beamer talk from paper |
| `/submit` | Final gate: score >= 95, all components >= 80 |
| `/tools` | Utility skills (compile, validate-bib, commit, etc.) |

### Constraint

`/new-project` is the only skill that is always orchestrated — it exists to launch the full pipeline. Everything else can run standalone.

---

## 5. Context Management

### General Principles
- Prefer auto-compression over `/clear`
- Save important context to disk before it's lost
- `/clear` only when context is genuinely polluted

### Context Survival Strategy

**Before Auto-Compression:**
When approaching context limits, ensure:
1. MEMORY.md has all `[LEARN]` entries from this session
2. Session log is current (updated within 10 minutes)
3. Active plan is saved to disk
4. Open questions are documented in session log

The pre-compact hook will remind you of this checklist.

**After Compression:**
First message should be: "Resuming after compression. Last task: [read most recent plan + git log]. Status: [next step]."

### Session Recovery

After compression or new session:
1. Read `CLAUDE.md` + most recent plan in `quality_reports/plans/`
2. Check `git log --oneline -10` and `git diff`
3. State what you understand the current task to be
