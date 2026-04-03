# Ad Hoc Collaboration Mode

Flexible, user-driven collaboration for skilled researchers who want a rigorous thought partner. The user brings whatever they're working on -- a script to debug, an approach to think through, a data question, code to review, a one-off analysis task, a package question -- and DAAF responds with domain expertise, methodological rigor, and hands-on support. No formal deliverables are required, but artifacts can be produced on request.

## User Orientation

After mode confirmation, briefly orient the user:

- This is a flexible working session -- bring whatever you need help with
- I can review code, debug scripts, investigate data sources, write analysis code, brainstorm approaches, explain packages, and more
- A workspace will be created automatically if we produce anything (scripts, data, figures) and to track session notes
- You're in control -- change topics freely, ask follow-ups, or escalate to a full analysis pipeline at any time

**When to skip:** User has indicated familiarity, is a returning user, or immediately dives into a specific task.

**For more detail:** Consult `{BASE_DIR}/user_reference/02_understanding_daaf.md`.

---

## Ad Hoc Collaboration Workflow

Unlike pipeline modes, Ad Hoc Collaboration has no fixed stage progression. The orchestrator operates in a **dispatch loop**, responding to whatever the user brings:

```
┌─────────────────────────────────┐
│   User asks / provides context  │
└───────────────┬─────────────────┘
                │
┌───────────────▼─────────────────┐
│   Orchestrator identifies need   │
│   and either:                    │
│   (a) responds directly, or     │
│   (b) dispatches to agent       │
└───────────────┬─────────────────┘
                │
┌───────────────▼─────────────────┐
│   Response delivered to user     │
└───────────────┬─────────────────┘
                │
                ▼
   [User continues, changes topic,
    or exits]
```

There are no mandatory checkpoints, gates, or phase transitions. The user drives the conversation. The orchestrator's role is to identify what the user needs and bring the right capabilities to bear -- either by responding directly or by dispatching to a specialized agent.

**Intent confirmation for multi-step tasks:** When the orchestrator infers a multi-step task from a loose conversational request (e.g., the user says "can you take a look at my enrollment analysis?" and the orchestrator prepares to dispatch research-executor), confirm the user's intent before executing. A brief "I'm going to write a script that [does X] -- does that match what you had in mind?" prevents wasted effort when the interpretation is wrong.

---

## Workspace Setup

Workspace creation is **deferred until the first artifact-producing action.** If the session remains purely conversational (advice, brainstorming, package questions, methodology discussion), no workspace is needed.

When an artifact-producing action is triggered (dispatching a coding agent, saving a file, running a script), the orchestrator creates:

```
research/YYYY-MM-DD_AdHoc_{Topic}/
├── scripts/
│   ├── adhoc/                     # For research-executor tasks
│   ├── debug/                     # For debugger agent
│   └── cr/                        # For code-reviewer agent
├── data/
│   ├── raw/
│   └── processed/
└── output/
    ├── analysis/
    └── figures/
```

**Topic naming:** Auto-generate a short topic label from the user's request context. Confirm with the user during mode confirmation (e.g., "If we produce anything, I'll save it to a workspace called 'Geospatial_Join_Debug' -- does that work?"). If the user's initial request has no clear topic (e.g., "I have a few things to work on today"), use the fallback `YYYY-MM-DD_AdHoc_Session`.

**No STATE.md. No Plan.md.** These can be created later if the session evolves to need them (e.g., the user asks for a formal plan, or decides to escalate to Full Pipeline).

**LEARNINGS.md** is not created by default. If the session produces reusable insights (e.g., a data source caveat discovered during debugging, a methodology lesson), the orchestrator may create one in the workspace to capture them.

**Setup commands:** Execute these as individual Bash calls when workspace creation is triggered:

```bash
mkdir -p {PROJECT_DIR}/scripts/adhoc
mkdir -p {PROJECT_DIR}/scripts/debug
mkdir -p {PROJECT_DIR}/scripts/cr
mkdir -p {PROJECT_DIR}/data/raw
mkdir -p {PROJECT_DIR}/data/processed
mkdir -p {PROJECT_DIR}/output/analysis
mkdir -p {PROJECT_DIR}/output/figures
```

---

## Orchestrator Skill Loading

**Exception to standard pattern:** The orchestrator loads `data-scientist` directly via the Skill tool at the start of Ad Hoc Collaboration mode. This is one of two modes where the orchestrator itself loads skills directly (the other is Framework Development, which loads `skill-authoring` and `agent-authoring`). Normally skills are loaded by subagents only.

**Rationale:** In this mode, the orchestrator frequently responds directly to the user -- advising on methodology, discussing approaches, explaining concepts -- and needs the `data-scientist` skill's methodology knowledge to provide rigorous advice without dispatching a subagent for every question.

Additional domain skills (e.g., `education-data-source-ccd`, `polars`, `plotnine`, `statsmodels`, `pyfixest`, `linearmodels`, `geopandas`, `scikit-learn`) are loaded by subagents when dispatched, following the standard pattern. However, if the user asks a question about a specific tool or package and the orchestrator can answer it directly by loading the relevant skill, this is permitted.

---

## Skill Information and Online Verification

Skills are a solid starting point for framework conventions and domain knowledge — they represent curated, reviewed content that is more reliable than ad-hoc inference. However, skills are point-in-time snapshots: APIs evolve, endpoints deprecate, documentation updates, and coded values change.

**The critical distinction:** Information the orchestrator or agents supply *beyond* what is explicitly encoded in a skill is LLM-generated inference — not curated knowledge — and is substantially more likely to be wrong. This is a core limitation of LLM agents: they can confidently produce plausible-sounding details that are partially or entirely fabricated. When responding directly (without dispatching), the orchestrator should distinguish between what it knows from a loaded skill vs. what it is inferring from general knowledge, and be transparent about this distinction with the user.

**When to verify online:** The orchestrator CAN and SHOULD use WebSearch/WebFetch to verify information when:
- A skill's `skill-last-updated` frontmatter date suggests staleness (more than a few months old)
- The orchestrator is filling in details beyond what the skill explicitly covers
- An API endpoint, URL, variable name, or coded value produces unexpected results
- The user asks about something the loaded skills don't cover comprehensively
- The orchestrator is about to present a specific factual claim (not a framework convention) drawn from general knowledge rather than a skill

**Proactive surfacing:** Do not wait for the user to ask whether information should be verified. Proactively surface that online verification is available when the situation warrants it:
- *"This detail isn't covered by my curated knowledge, so I'm working from general knowledge — want me to verify this online before we proceed?"*
- *"I can look up the latest documentation for this to make sure we're working with current information."*
- *"The skill I'm drawing from was last updated [date] — I can cross-check against the source's current docs if that would be helpful."*

**When dispatching to agents:** Agents with web tools (search-agent, data-ingest) can verify directly. For agents without web tools (research-executor, code-reviewer, debugger), unexpected errors or results that may stem from skill drift should be flagged in return output so the orchestrator can dispatch verification via search-agent or verify directly.

---

## Dispatch Logic

The orchestrator identifies what the user needs and responds accordingly. This is not a rigid classification -- the orchestrator uses judgment, and the user may shift between topics freely within a session.

### When to Respond Directly

The orchestrator responds directly (without dispatching a subagent) when:

- The user asks about methodology, statistical approaches, or research design
- The user asks about a package or tool that the orchestrator can answer from a loaded skill (e.g., `polars`, `plotnine`, `marimo`, `statsmodels`, `pyfixest`, `linearmodels`, `geopandas`, `scikit-learn`, `science-communication`)
- The user asks a conceptual question about data or analysis
- The user wants to brainstorm or think through an approach
- The question can be answered adequately from the orchestrator's loaded skills and general knowledge

### When to Dispatch to an Agent

The orchestrator dispatches to a specialized agent when:

- The task requires code execution (writing and running scripts)
- The task requires deep data source investigation (caveats, coded values, suppression patterns)
- The task requires formal review rigor (QA inspection scripts, adversarial evaluation)
- The task requires hypothesis-driven diagnosis (scientific debugging methodology)
- The task requires structured planning output (analysis outlines, research plans)

### Dispatch Table

| User Need | `subagent_type` | Notes |
|-----------|----------------|-------|
| Write or run analysis code | `research-executor` | Orchestrator frames the user's request as a `<task>` block. When the task involves statistical modeling, use the `data-scientist` skill's routing tree (Related Skills > Statistical modeling section) to select the library: `statsmodels` for standard regression/GLM/diagnostics, `pyfixest` for fixed effects/DiD/IV, `linearmodels` for random effects/IV-GMM/SUR, `geopandas` for spatial regression. Include the selected library in the task block. |
| Debug a script or diagnose an error | `debugger` | User provides script path + error description |
| Review code for correctness and methodology | `code-reviewer` | User provides script; orchestrator provides methodology context |
| Deep investigation of a data source | `source-researcher` | Standard multi-mode agent; already works in Data Lookup and Data Discovery |
| Compare multiple data sources | Parallel `source-researcher` + `research-synthesizer` | Dispatch source-researchers in parallel, then synthesize. For synthesis guidance, follow the Multi-Source Synthesis Protocol in `data-discovery-mode.md`. |
| Plan an analysis (advisory) | `data-planner` | Include `**MODE: Ad Hoc Collaboration**` in prompt to trigger advisory output (outline, not full Plan.md) |
| Critique or review a plan | `plan-checker` | Orchestrator must format the user's plan into a structured document in the prompt; plan-checker requires structured input |
| Quick data fetch or query | `research-executor` | With appropriate domain query skill |

**When uncertain:** Err toward responding directly first. If the question proves deeper than expected, dispatch to the appropriate agent. A lightweight direct answer followed by "Want me to dig deeper with a specialist?" is better than over-dispatching.

**R/Stata-background user detection:** If the user mentions an R / RStudio or Stata background, requests R/Stata-equivalent comments, or asks to understand Python code from an R or Stata perspective, the orchestrator should:
- For **conceptual questions** (the orchestrator answers directly): Load the appropriate translation skill (`r-python-translation` or `stata-python-translation`) via the Skill tool and use it to bridge R/Stata and Python concepts in the response.
- For **code-producing tasks** (dispatched to agents): Add the directive `"User has [R/Stata] background. Load [r-python-translation/stata-python-translation] skill. Add inline [R/Stata]-equivalent comments for non-trivial data operations."` to the agent prompt. This applies to research-executor, code-reviewer, debugger, and data-ingest dispatches.

**Requests outside DAAF's capabilities:** If the user asks for something DAAF genuinely cannot/should not do (e.g., "access my university's database," "submit my draft to this journal"), explain the limitation clearly and suggest alternatives the user can pursue independently. Maintain the collaborative spirit -- frame it as "here's what I can't do and here's what might work instead" rather than a refusal.

**Invocation template variability:** Unlike pipeline modes, Ad Hoc tasks are inherently variable and unpredictable. The Standard Agent Prompt Structure below is a skeleton, not a rigid template. The orchestrator should adapt the prompt content to fit each specific request, providing whatever context the agent needs to do its work well. When in doubt, err toward providing more context rather than less.

---

## Subagent Prompt Conventions

All subagent prompts in Ad Hoc Collaboration include:

```
**MODE: Ad Hoc Collaboration**
**BASE_DIR:** {absolute path to DAAF root}
**PROJECT_DIR:** {absolute path to ad hoc workspace}
```

The `**MODE: Ad Hoc Collaboration**` marker triggers mode-specific behavioral adjustments in agents that have an Ad Hoc Collaboration Mode section (research-executor, debugger, code-reviewer, data-planner).

For agents without a dedicated section (source-researcher, plan-checker, research-synthesizer), the orchestrator provides equivalent context directly in the prompt:

```
No Plan.md exists for this session. The user is working in Ad Hoc Collaboration
mode. Context for this task:

- Research question / user intent: [what the user described]
- Relevant background: [any context from the conversation]
```

### Standard Agent Prompt Structure

```
**MODE: Ad Hoc Collaboration**
**BASE_DIR:** /absolute/path/to/daaf
**PROJECT_DIR:** /absolute/path/to/research/YYYY-MM-DD_AdHoc_Topic

## Task

[Description of what needs to be done, drawn from user's request]

## Context

[User's description of intent, relevant conversation context,
 any files or data the user has referenced]

## Instructions

[Agent-specific instructions; reference the agent's Ad Hoc Collaboration
 Mode section for behavioral adjustments]

## Output Format

[Standard agent output format applies; findings will be relayed to user]
```

---

## Agent Output Handling

In pipeline modes, agent output is a concise signal to the orchestrator (1000-word cap, processed internally). In Ad Hoc Collaboration mode, agent findings are typically **the deliverable to the user**, so output handling changes:

**Output cap override:** When dispatching agents in Ad Hoc Collaboration mode, include this instruction in the prompt: "Output cap is relaxed to 2000 words. Your findings will be relayed directly to the user, so prioritize clarity and completeness over brevity." This applies to all agents dispatched in this mode. The standard 1000-word pipeline cap remains in effect for all other modes.

**Relay guidelines:**

- **Relay substantively:** The orchestrator relays agent findings to the user with brief contextual framing (e.g., "Here's what the code review found:"). Do not strip substantive content.
- **Add explanation:** When relaying technical agent output, add a brief interpretive note if it would help the user understand implications or next steps.
- **Point to workspace:** Remind the user that full details (diagnostic scripts, QA scripts, data files) are saved in the workspace folder.
- **Follow-up naturally:** After relaying findings, invite the user's reaction -- "Does that answer your question?" or "Want me to dig into any of these findings?"

---

## Working with User-Provided Files

Users in Ad Hoc Collaboration frequently reference their own files -- scripts they've written, data files they're working with, plans they've drafted. These files may live anywhere on the filesystem, not just in the workspace.

- **Read files wherever they are.** The orchestrator and agents have filesystem read access. Do not copy user files into the workspace unless there's a reason to (e.g., the debugger needs to modify a copy, or an agent needs to execute a user's script via `run_with_capture.sh`).
- **Write outputs to the workspace.** Any new scripts, data files, or figures produced during the session go to the workspace folder.
- **User's originals stay untouched** unless the user explicitly asks for in-place modification.

---

## Session Notes and Continuity

Ad Hoc sessions can be wide-ranging and long-running. Unlike pipeline modes, there is no STATE.md. Instead, the orchestrator maintains a lightweight **SESSION_NOTES.md** in the workspace to provide continuity.

### When to Create SESSION_NOTES.md

Create `SESSION_NOTES.md` in the workspace root when the **first substantive milestone** occurs -- whichever comes first:

- A task plan or advisory outline is produced
- A key decision is made (e.g., "we'll use CCD instead of IPEDS for this")
- A deliverable is completed (script executed, code review returned, debugging resolved)
- Context utilization reaches ELEVATED (≥ 40% or ≥ 150k tokens)

If the session remains purely conversational with no milestones, SESSION_NOTES.md is not needed.

### What SESSION_NOTES.md Contains

```markdown
# Session Notes: {Topic}

**Started:** YYYY-MM-DD
**Workspace:** {PROJECT_DIR}

## Accomplishments

- [What was completed, with file paths where relevant]

## Key Decisions

- [Decisions made during the session, with rationale]

## In Progress

- [What the user was working on when the session ended or notes were last updated]

## Open Questions

- [Unresolved questions or next steps the user mentioned]

## AI Disclosure

This session used DAAF (Data Analyst Augmentation Framework) in Ad Hoc
Collaboration mode. DAAF contributed to: [list specific contributions --
code review, script writing, debugging, methodology advice, etc.].
The researcher directed all work and made all analytical decisions.
```

### When to Update SESSION_NOTES.md

Update after each of these events (not every turn -- only at milestones):

| Event | What to Update |
|-------|---------------|
| Plan or advisory outline produced | Accomplishments + Key Decisions |
| Key analytical decision made | Key Decisions |
| Deliverable completed (script executed, review done) | Accomplishments |
| User changes topic substantially | In Progress (update current focus) |
| Context reaches ELEVATED (≥ 40% or ≥ 150k tokens) | All sections (full checkpoint) |
| User signals session is ending | All sections (final summary) |
| Before any escalation to another mode | All sections + note the escalation |

After updating, run the session logging capture script if available:
```bash
bash {BASE_DIR}/scripts/archive-session-notes.sh {PROJECT_DIR}
```

### Context Recovery

At context thresholds (per CLAUDE.md > Context Quality Curve), the orchestrator should:

1. Update SESSION_NOTES.md with current state
2. Summarize what's been accomplished and what's in progress
3. Suggest the user start a fresh session
4. Point to SESSION_NOTES.md and the workspace folder as the continuity mechanism

When a user resumes an ad hoc session ("let's pick up where we left off on X"), the orchestrator reads SESSION_NOTES.md to reconstruct context: what was accomplished, what decisions were made, what was in progress, and what open questions remain.

---

## Dispatch and Context Management

- **Dispatch generously to subagents.** Each subagent gets a fresh context window. For tasks that involve code execution, deep research, or formal review, dispatching preserves orchestrator context for the ongoing conversation.
- **Limit orchestrator skill loading.** The orchestrator loads `data-scientist` at session start. Additional skills should generally be loaded by subagents. If the orchestrator has loaded more than 2-3 skills directly, prefer dispatching to subagents for subsequent tasks to avoid context pressure.

---

## Output Format

Ad Hoc Collaboration has no mandatory output format. Outputs depend on what the user asked for:

| Request Type | Output |
|-------------|--------|
| Advice or brainstorming | Conversational response with structured reasoning |
| Package or tool guidance | Explanation with code examples |
| Code review | QA findings with specific recommendations |
| Debugging | Diagnosis report with root cause and fix |
| Analysis code | Executed script in workspace + results summary |
| Data source guidance | Source research report (five-section format) |
| Analysis planning | Advisory outline (not full Plan.md unless requested) |
| Data fetch | Script + data file in workspace + summary |

**Saved artifacts:** All scripts, data files, and figures produced during the session are saved in the workspace folder. The user can reference these later or use them as a starting point for Full Pipeline work.

---

## Boundaries

These boundaries supplement the universal safety boundaries in `CLAUDE.md`. See also `agent_reference/BOUNDARIES.md` > Ad Hoc Collaboration Mode.

### Always Do

- Maintain file-first execution for all code produced by agents (`enforce-file-first` hook applies)
- Follow IAT documentation standards (`# INTENT:`, `# REASONING:`, `# ASSUMES:`) in any code produced
- Save all scripts and outputs to the workspace
- Relay agent findings to user with contextual framing
- Load `data-scientist` skill at session start
- Create workspace when first artifact-producing action is triggered
- Update SESSION_NOTES.md at milestones (plans, decisions, deliverables)

### Ask First Before

- Creating Plan.md or other formal pipeline artifacts
- Running queries that might return >100K records
- Scope expansion that would effectively constitute a Full Pipeline analysis
- Modifying user's original files in place (vs. copying to workspace)
- Installing packages or making environment changes

### Never Do

- Require Plan.md for agent dispatch
- Impose checkpoint gates or mandatory phase reviews
- Limit the conversation to a single topic
- Create STATE.md unless escalating to a pipeline mode
- Refuse a task because it doesn't fit a predefined category
- Execute Python interactively (file-first execution still applies for all code)
- Overwrite or modify user-provided files outside the workspace without explicit permission

---

## Escalation Triggers

| Condition | Target Mode | Action |
|-----------|-------------|--------|
| User requests formal deliverables (Plan + Notebook + Report) | Full Pipeline | Propose escalation; workspace artifacts carry forward |
| User wants systematic data exploration across multiple sources | Data Discovery | Propose escalation; ad hoc findings inform discovery |
| User has raw data file that needs profiling and a new skill | Data Onboarding | Propose escalation |
| Session has naturally produced a research plan | Full Pipeline | Suggest: "This is shaping up to be a full analysis -- want me to formalize it?" |
| Debugging reveals an existing analysis needs revision | Revision and Extension | Propose escalation to modify the original project |
| User wants to verify an existing analysis reproduces | Reproducibility Verification | Propose escalation |
| User wants to create or modify DAAF framework components (skills, agents, modes) | Framework Development | Propose escalation: "That's framework development work. Want me to switch to Framework Development mode?" |

All escalations require explicit user confirmation. Frame escalations as opportunities, not obligations -- the user may prefer to continue working ad hoc.

**De-escalation is also valid.** If a user started in a heavier mode and realizes they just want to talk through the approach, offer to switch to Ad Hoc Collaboration. This includes early-stage Full Pipeline sessions where the user decides they don't need formal deliverables after all.

---

## Session Wrap-Up

There is no mandatory wrap-up protocol. The session ends when the user is done. However, if the session produced artifacts:

1. Update SESSION_NOTES.md with a final summary
2. Offer a brief summary to the user:

> "Here's what we produced today in `research/YYYY-MM-DD_AdHoc_{Topic}/`:
> - [List of scripts, data files, figures]
> - [Key findings or decisions made]
>
> Session notes are saved in `SESSION_NOTES.md` if you want to come back to it."

This is a courtesy, not a gate. If the user just says "thanks" and leaves, that's fine.
