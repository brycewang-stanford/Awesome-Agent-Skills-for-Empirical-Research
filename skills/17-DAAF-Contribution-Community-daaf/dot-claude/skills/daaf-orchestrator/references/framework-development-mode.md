# Framework Development Mode

Structured collaboration for modifying DAAF's own framework components — skills, agents, modes, reference files, hooks, and configuration. The user brings a framework modification need (create a new skill, revise an agent, add a mode, update templates) and DAAF provides architectural context, template guidance, and systematic integration. Produces framework artifacts placed directly into the DAAF codebase, with a multi-angle review pass before completion.

## User Orientation

After mode confirmation, briefly orient the user:

- This mode is for modifying DAAF itself — its skills, agents, modes, templates, reference documents, and configuration
- I'll start by scoping the current state of whatever you want to change, then present findings before modifying anything
- All framework changes follow canonical templates and go through an integration checklist to ensure consistency across the system
- A multi-angle review pass at the end catches any missed registration points or quality issues
- You'll review and approve changes at two key points: after scoping (confirm approach) and after review (approve final state)

**When to skip:** User is a returning framework developer, has indicated familiarity, or immediately specifies a precise modification.

**For more detail:** Consult `{BASE_DIR}/user_reference/02_understanding_daaf.md` and `{BASE_DIR}/user_reference/04_extending_daaf.md`.

---

## Framework Development Workflow

```
┌─────────────────────────────────────┐
│   User describes framework need     │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   PHASE 1: SCOPE                    │
│   Classify work type, explore       │
│   existing state, present findings  │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   ★ CHECKPOINT 1                    │
│   User confirms scope and approach  │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   PHASE 2: DESIGN (adaptive)       │
│   Draft design for complex work;    │
│   skip for simple modifications     │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   PHASE 3: AUTHOR & INTEGRATE      │
│   Write artifacts, execute          │
│   integration checklist             │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   PHASE 4: REVIEW (mandatory)        │
│   Always dispatches review agents:  │
│   2-angle (simple) or 3-angle       │
│   (moderate/complex)                │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│   ★ CHECKPOINT 2                    │
│   User reviews findings, approves   │
│   or requests iteration             │
└──────────────────┬──────────────────┘
                   │
                   ▼
        [Complete or iterate]
```

**Iteration loop:** After Checkpoint 2, the user may request changes. The orchestrator classifies the request and either handles it directly, dispatches to framework-engineer, or loops back to the appropriate phase. This dispatch loop continues until the user is satisfied.

---

## Gate Definitions

| Gate | After | Criteria | Pass Condition |
|------|-------|----------|----------------|
| GFD-1 | Phase 1 (Scope) | Work type classified, exploration complete, user confirmed scope at Checkpoint 1 | User explicitly confirms scope and approach |
| GFD-2 | Phase 2 (Design) | Design approved (Complex) or Phase 2 skipped (Simple/Moderate) | User approves design OR complexity is Simple/Moderate |
| GFD-3 | Phase 3 (Author & Integrate) | All artifacts authored, integration checklist executed, framework-engineer returned COMPLETED | framework-engineer status is COMPLETED and all applicable checklist items are done |
| GFD-4 | Phase 4 (Review) | Review subagents returned, user approved final state at Checkpoint 2 | User explicitly approves OR requests only minor iteration |

**Iteration limits:**
- Max **2** framework-engineer dispatches per component before escalating to user for guidance
- Max **3** review-fix cycles total (Phase 3 → Phase 4 → fix → Phase 4 → fix → Phase 4 → STOP)
- If limits are exceeded, present current state to user and ask how to proceed

---

## Phase 1: Scope

### Work Type Classification

When the user describes their framework need, classify it into one of these work types:

| Work Type | Trigger | Key Template | Primary Checklist |
|-----------|---------|-------------|-------------------|
| **New Skill** | "create a skill for...", "add a data source..." | `skill-authoring` skill + `DATA_SOURCE_SKILL_TEMPLATE.md` (data sources) | FRAMEWORK_INTEGRATION_CHECKLIST.md § 1 |
| **New Agent** | "create an agent for...", "add a specialist..." | `AGENT_TEMPLATE.md` (12 sections) | FRAMEWORK_INTEGRATION_CHECKLIST.md § 2 |
| **New Mode** | "add a new mode for...", "create a workflow..." | `MODE_TEMPLATE.md` | FRAMEWORK_INTEGRATION_CHECKLIST.md § 3 |
| **New Reference File** | "create a reference for...", "document the protocol for..." | Examine 2-3 existing exemplars | FRAMEWORK_INTEGRATION_CHECKLIST.md § 4 |
| **Modify Existing** | "update the X skill...", "change the Y agent..." | Read existing artifact + template | FRAMEWORK_INTEGRATION_CHECKLIST.md § modification subsection |
| **Incorporate Learnings** | "incorporate learnings", "apply learnings", "process LEARNINGS.md", "update framework from learnings" | Existing LEARNINGS.md System Update Action Plans | FRAMEWORK_INTEGRATION_CHECKLIST.md (section varies by action item target) |
| **Multi-Component** | Complex work touching multiple component types | All applicable | Multiple sections |

For ambiguous requests, ask clarifying questions before classifying.

### Exploration Protocol

Launch **3 search-agent subagents** in parallel to thoroughly explore the relevant existing framework state. These are read-only research agents dispatched via the Agent tool with `subagent_type: "search-agent"` — they can read files, search code, and fetch web pages but cannot write. The exact focus of each subagent depends on the work type:

**For New Skill:**
1. **Existing skills survey:** List all skills in the same category (data source, tool, methodology). Read 2-3 exemplar SKILL.md files for structural patterns.
2. **Integration landscape:** Read skill-authoring references. Identify which agents and modes currently reference skills of this type.
3. **Naming and triggering:** Search for potential name collisions. Review description patterns that trigger well.

**For New Agent:**
1. **Agent ecosystem:** Read `.claude/agents/README.md`. Identify the 2-3 closest existing agents. Read their Core Distinction tables.
2. **Integration landscape:** Read agent-authoring references and integration checklist. Identify all registration points.
3. **Workflow context:** Read the WORKFLOW_PHASE file for the agent's target stage. Understand the invocation pattern and handoff expectations.

**For New Mode:**
1. **Existing modes survey:** Read all mode reference files (first 50-80 lines each). Identify the closest analog mode. Read it fully.
2. **Registration landscape:** Read orchestrator SKILL.md sections that reference modes (Decision Framework, Summary Table, Escalation Paths, Reference Index, Loading Tree). Count current modes.
3. **Downstream documentation:** Read `user_reference/02_understanding_daaf.md` mode sections, `README.md` modes table, `BOUNDARIES.md` mode sections, `AI_DISCLOSURE_REFERENCE.md`, `session-recovery.md`.

**For Modify Existing:**
1. **Current state:** Read the target artifact in full. Read files that reference it (grep for filename).
2. **Template compliance:** Read the canonical template for this artifact type. Note any structural gaps.
3. **Downstream impact:** Identify which other files reference or depend on the content being modified.

**For Incorporate Learnings:**
1. **Learnings scan:** Scan all `research/*/LEARNINGS.md` files. Extract every System Update Action Plan table. Consolidate action items across projects, noting source project for each. Flag duplicates where multiple projects identified the same issue.
2. **Current state check:** For each action item, read the target file(s) mentioned. Determine whether the proposed change has already been made (fully or partially). Mark items as "already addressed", "partially addressed", or "still needed".
3. **Dependency and ordering analysis:** Identify dependencies across action items (e.g., a skill change that requires an agent change). Group items by target file to minimize file-switching. Propose an execution order respecting dependencies and priority (P1 before P2 before P3).

**For Multi-Component:**
Combine the relevant exploration sets. Distribute across 3 subagents by grouping related explorations.

**Light scoping (orchestrator handles directly):** For clearly simple, well-bounded modifications (e.g., "update a description in a skill's SKILL.md", "fix a typo in a reference file"), the orchestrator may perform light scoping itself — read the target file, grep for references — rather than launching 3 subagents. Reserve the full 3-subagent exploration for new components or multi-file modifications.

### Phase 1 Exploration Prompt Template

```
**BASE_DIR:** {absolute path to DAAF root}

## Task: Framework Exploration — [focus area]

You are a READ-ONLY research agent. Do NOT write or modify any files.

## Focus

[Describe what to explore — e.g., "Survey all existing data source skills",
"Map all files that reference the plan-checker agent", etc.]

## Files to Read

[List specific files with absolute paths]

## Expected Output

Provide a structured report with:
1. Current state summary (what exists, how it's structured)
2. Key findings relevant to the planned modification
3. Potential impacts or dependencies discovered
4. Recommended approach considerations

Keep output under 800 words. Focus on findings, not descriptions of what you read.
```

### Phase 1 Exploration Prompt Template: Incorporate Learnings

For the "Incorporate Learnings" work type, the 3 search-agent subagents have specialized prompts:

**Subagent 1: Learnings Scan**
```
**BASE_DIR:** {absolute path to DAAF root}

## Task: Framework Exploration — Learnings Scan

You are a READ-ONLY research agent. Do NOT write or modify any files.

## Focus

Scan all LEARNINGS.md files across research projects. Extract every System Update
Action Plan section. Consolidate action items into a single deduplicated backlog.

## Files to Read

- Glob: `{BASE_DIR}/research/*/LEARNINGS.md`
- For each file found: read the "System Update Action Plan" section (if present)

## Expected Output

Provide a structured report with:
1. List of LEARNINGS.md files found (with project names and dates)
2. Consolidated action items table: #, Learning, Target File, Change Type,
   Proposed Change, Priority, Source Project(s)
3. Duplicates identified (same target + same proposed change from multiple projects)
4. Total counts: action items found, unique after dedup, by priority (P1/P2/P3)

Keep output under 800 words. Focus on the consolidated backlog, not descriptions
of each file.
```

**Subagent 2: Current State Check**
```
**BASE_DIR:** {absolute path to DAAF root}

## Task: Framework Exploration — Current State of Action Item Targets

You are a READ-ONLY research agent. Do NOT write or modify any files.

## Focus

For each action item from the consolidated backlog, check whether the proposed
change has already been made in the target file.

## Action Items to Check

{Paste consolidated action items table from Subagent 1, or instruct orchestrator
to inline the items here after Subagent 1 returns}

## Expected Output

Provide a structured report with:
1. For each action item: status (Already Addressed / Partially Addressed /
   Still Needed) with evidence (quote the relevant section or note its absence)
2. Summary counts: already done, partial, still needed
3. Any target files that no longer exist or have been restructured

Keep output under 800 words.
```

**Subagent 3: Dependency and Ordering Analysis**
```
**BASE_DIR:** {absolute path to DAAF root}

## Task: Framework Exploration — Dependency and Ordering Analysis

You are a READ-ONLY research agent. Do NOT write or modify any files.

## Focus

Analyze the "still needed" action items for dependencies, grouping, and
execution order.

## Action Items to Analyze

{Paste "still needed" items from Subagent 2, or instruct orchestrator to inline
them here after Subagent 2 returns}

## Expected Output

Provide a structured report with:
1. Dependency map: which items must precede others (e.g., template change before
   agent change that references the template)
2. Grouping by target file (to minimize file-switching during execution)
3. Recommended execution order respecting: dependencies first, then P1 > P2 > P3
4. Estimated complexity per item (Simple / Moderate / Complex) based on the
   number of files affected and nature of the change

Keep output under 800 words.
```

**Note:** Subagents 2 and 3 depend on earlier results. The orchestrator may run Subagent 1 first, then Subagents 2 and 3 in sequence (or parallel if the orchestrator inlines findings). Alternatively, the orchestrator can run all three with standing instructions and let each subagent scan independently — trading some duplication for parallelism.

### PSU-FD1: Scope Confirmation

Present after Phase 1 exploration completes. All user-facing text uses plain language — no internal terms (gate, GFD, PSU, subagent).

```
**Framework Development: Scope Review**

**Work Type:** [New Skill | New Agent | New Mode | Modify Existing | Incorporate Learnings | Multi-Component]

**Current State:**
- [What exists today and how it connects]
- [Key dependencies or downstream impacts discovered]

**Proposed Approach:**
- [What artifacts will be created or modified, in what order]
- [Which templates and checklists apply]

**Integration Scope:**
- Registration points: [N] mandatory, [N] conditional across [N] files
- Checklist: FRAMEWORK_INTEGRATION_CHECKLIST.md § [section(s)]

**Complexity:** [Simple | Moderate | Complex]
- [Simple: orchestrator handles directly or single dispatch]
- [Moderate: single framework-engineer dispatch]
- [Complex: multiple dispatches with design review]

**What Happens Next:**
[If Simple:] I'll make the changes directly and run a consistency and completeness review.
[If Moderate:] I'll dispatch to the framework specialist, then run a full 3-angle review pass.
[If Complex:] I'll present a design for your review first, then proceed with authoring and a full 3-angle review pass.

**Does this scope and approach look right? Any adjustments before I proceed?**
```

**STOP. Do not proceed to Phase 2 until the user confirms (GFD-1).**

---

## Phase 2: Design (Adaptive)

Phase 2 is **adaptive** — its depth scales with the complexity of the work:

| Complexity | Phase 2 Behavior |
|-----------|-----------------|
| **Simple** (updating a description, adding a table row, fixing a cross-reference) | Skip Phase 2 entirely. Proceed directly to Phase 3. |
| **Moderate** (creating a new skill, modifying an agent's protocol) | Brief design summary in the orchestrator's CP1 response. Proceed to Phase 3 after user confirms. |
| **Complex** (creating a new agent, creating a new mode, multi-component work) | Present detailed design for user review: proposed structure, key design decisions, template deviations (if any). Wait for user approval before Phase 3. |

For complex work, the design presentation should include:
- Proposed artifact structure (section outline for agents/modes, frontmatter for skills)
- Key design decisions and rationale
- Core Distinction table (for agents) or workflow diagram sketch (for modes)
- Any proposed deviations from templates, with justification

---

## Phase 3: Author & Integrate

### Dispatch Logic

The orchestrator dispatches to the `framework-engineer` agent for authoring and integration work. The dispatch pattern follows a **flexible loop** (like Ad Hoc Collaboration) — the orchestrator sends tasks and receives reports, potentially dispatching multiple times for complex or multi-component work.

### When the Orchestrator Handles Directly

- Simple count word updates ("seven" → "eight")
- Single table row additions when the row content is obvious from context
- Brief prose edits to user_reference when the change is straightforward
- Cross-reference fixes identified during review

### When to Dispatch to framework-engineer

- Creating any new artifact (skill, agent, mode, reference file)
- Modifications requiring template compliance verification
- Changes touching 3+ files (integration checklist territory)
- Any work where reading exemplars and templates is needed

### Standard Agent Prompt Structure

```
**MODE: Framework Development**
**BASE_DIR:** {absolute path to DAAF root}

## Task

**Work Type:** [New Skill | New Agent | New Mode | Modify Existing | Incorporate Learnings | Multi-Component]
**Scope:** [What to create or change, and why]

## Context

[Phase 1 scoping findings summary]
[User's confirmed scope and design decisions]
[For modifications: specific sections/content to change]

## Affected Files

[List of all files to read, create, or modify — absolute paths]

## Instructions

[Specific instructions for this dispatch]
Read FRAMEWORK_INTEGRATION_CHECKLIST.md and execute the applicable section.
Report all files created and modified.

## Output Format

Follow the standard framework-engineer output format (§ Output Format in agent definition).
```

### Orchestrator Behavior During Phase 3

- Track which integration checklist items the framework-engineer addresses
- For multi-component work, dispatch multiple times (one component type per dispatch, or group related items)
- After each framework-engineer return, check the artifact list and integration checklist completion
- Handle any remaining simple registration updates directly (count words, brief table rows)

---

## Phase 4: Review (Mandatory)

Phase 4 review is **mandatory for all work, regardless of complexity.** Review subagents must always be dispatched — the orchestrator never self-reviews in lieu of subagent dispatch. The number of review subagents scales with complexity:

| Complexity | Phase 4 Behavior |
|-----------|-----------------|
| **Simple** (single-file edit, count word update, cross-reference fix) | Launch **2 search-agent subagents** in parallel: Consistency Review + Completeness Review. |
| **Moderate** (new skill, modified agent protocol) | Launch **3 search-agent subagents** in parallel: Consistency Review + Quality Review + Completeness Review. |
| **Complex** (new agent, new mode, multi-component work) | Launch **3 search-agent subagents** in parallel: Consistency Review + Quality Review + Completeness Review. |

For **Moderate** and **Complex** work, launch 3 read-only research subagents in parallel. For **Simple** work, launch Subagent 1 (Consistency) and Subagent 3 (Completeness) in parallel:

### Subagent 1: Consistency Review

```
Review all files created or modified during this Framework Development session
for cross-file consistency.

Specific checks:
- Count words: grep for "N engagement modes", "N agents", etc. — are they all
  updated to the correct number?
- Cross-references: do all file paths mentioned in any document actually exist?
- Table schemas: do new rows match the column structure of existing rows?
- Escalation paths (if mode work): are they bidirectional?
- Naming conventions: do names follow the established patterns?

Files to review: [list all created/modified files with absolute paths]

Report: list of inconsistencies found, with file paths and line numbers.
```

### Subagent 2: Quality Review

```
Review all files created or modified during this Framework Development session
for quality against canonical templates and established patterns.

Specific checks:
- Template compliance: does each new artifact follow its canonical template?
  (AGENT_TEMPLATE.md for agents, MODE_TEMPLATE.md for modes, skill-authoring
  rules for skills)
- Content quality: are descriptions clear and specific? Are anti-patterns
  genuinely useful? Are boundaries precise?
- Style consistency: does new content match the tone and depth of adjacent
  existing content?
- Spirit and intention: does the artifact capture what was intended at the
  outset? Does it serve the stated purpose effectively?

Files to review: [list all created/modified files with absolute paths]
Templates to check against: [relevant template paths]

Report: quality issues found, with specific improvement suggestions.
```

### Subagent 3: Completeness Review

```
Review the integration of new/modified framework components for completeness.

Specific checks:
- Read FRAMEWORK_INTEGRATION_CHECKLIST.md. For each applicable item, verify
  the registration was actually done (read the target file and confirm).
- Orphan detection: is every new file referenced by at least one other file?
- Missing registrations: grep for the component name — does it appear in all
  expected locations?
- Best practices: are there patterns from existing components of the same type
  that were not followed?
- Extensions: are there other places this component should be mentioned or
  integrated that weren't in the checklist?

Files to review: [list all created/modified files with absolute paths]
Checklist: {BASE_DIR}/agent_reference/FRAMEWORK_INTEGRATION_CHECKLIST.md

Report: missing registrations, orphaned components, and suggested extensions.
```

### Subagent Output Verification

Before presenting Checkpoint 2, verify the framework-engineer's return (if dispatched):
- **Status** is COMPLETED (not PARTIAL or BLOCKED)
- **Artifacts Created/Modified** list is non-empty
- **Integration Checklist** section shows all applicable items addressed
- If PARTIAL or BLOCKED, resolve before proceeding to review

### PSU-FD2: Review & Approval

Present after Phase 4 review completes. All user-facing text uses plain language.

```
**Framework Development: Review Complete**

**Changes Made:**
- [File created/modified with path and brief description]
- [e.g., Created `.claude/agents/literature-reviewer.md` — new agent (482 lines)]
- [e.g., Updated `.claude/agents/README.md` — added to Agent Index, When to Use, Coordination Matrix]

**Integration Status:**
- Checklist: FRAMEWORK_INTEGRATION_CHECKLIST.md § [section]
- Completed: [n] of [total] mandatory items, [n] of [total] conditional items
- [Any items skipped with reason]

**Review Findings:**

[If Moderate or Complex — synthesize from 3 review subagents:]
*Consistency:* [summary — issues found or "no issues"]
*Quality:* [summary — issues found or "template-compliant, no issues"]
*Completeness:* [summary — missing registrations or "all registration points verified"]

[If Simple — synthesize from 2 review subagents:]
*Consistency:* [summary — issues found or "no issues"]
*Completeness:* [summary — missing registrations or "all registration points verified"]

**Issues to Resolve:** [if any — organized by severity]
- [Issue]: [what and where]

**Suggestions to Consider:** [if any — optional improvements]
- [Suggestion]: [rationale]

**What's Most Useful From You Here:**
Review the changes list above. If any files look unexpected, or if the review
found issues you want addressed, let me know. Otherwise, confirm and we're done.

**Are you satisfied with the current state, or should I address any of the findings above?**
```

If the user requests changes, loop back to Phase 3 for targeted fixes (respecting iteration limits from Gate Definitions).

---

## Orchestrator Skill Loading

**Exception to standard pattern:** The orchestrator loads `skill-authoring` and `agent-authoring` directly via the Skill tool at the start of Framework Development mode. This parallels Ad Hoc Collaboration's loading of `data-scientist`.

**Rationale:** In this mode, the orchestrator frequently advises on framework structure, answers questions about template requirements, and coordinates integration checklists. Having these skills loaded enables direct advisory responses without dispatching for every question.

Additional skills (e.g., specific data source skills when the user is modifying one) are loaded by subagents when dispatched, following the standard pattern.

**Context budget note:** Loading two skills at mode start consumes approximately 1,000-1,500 tokens of orchestrator context. Avoid loading additional skills directly in orchestrator context beyond these two — defer to subagents for any further skill loading. If context utilization reaches ELEVATED (≥ 40% or ≥ 150k tokens), consider whether direct advisory responses could be delegated to a framework-engineer dispatch instead.

---

## Workspace Setup

Framework Development typically modifies files in place (`.claude/skills/`, `.claude/agents/`, `agent_reference/`, `user_reference/`). No research project workspace is created unless the session produces artifacts that need a project home.

**SESSION_NOTES.md location:** If the session is substantial enough to warrant session notes, create them at:
```
research/YYYY-MM-DD_FrameworkDev_{Topic}/SESSION_NOTES.md
```

Follow the same deferred creation pattern as Ad Hoc Collaboration — only create the workspace when the first milestone warrants it.

**Natural restart boundaries:** Checkpoint 1 completion and Phase 3 completion are both natural restart boundaries. If context pressure is building, ensure SESSION_NOTES.md is updated at these points.

---

## Session Notes and Continuity

### When to Create SESSION_NOTES.md

Create `SESSION_NOTES.md` in the workspace root when the **first substantive milestone** occurs — whichever comes first:

- Phase 1 scoping completes (work type classified, exploration done)
- A framework artifact is created or substantially modified
- A key design decision is made
- Context utilization reaches ELEVATED (≥ 40% or ≥ 150k tokens)

If the session remains purely conversational with no milestones, SESSION_NOTES.md is not needed.

### SESSION_NOTES.md Template

```markdown
# Session Notes: Framework Development — {Topic}

**Started:** YYYY-MM-DD
**Workspace:** {PROJECT_DIR}
**Work Type:** [New Skill | New Agent | New Mode | Modify Existing | Incorporate Learnings | Multi-Component]

## Accomplishments

- [Specific files created/modified with absolute paths]
- [e.g., Created `.claude/agents/literature-reviewer.md` (new agent)]

## Key Decisions

- [Design choices with rationale]
- [e.g., "Chose dispatch loop over phased sub-workflows because work is variable-length"]

## Integration Status

**Component:** [what was created/modified]
**Checklist:** FRAMEWORK_INTEGRATION_CHECKLIST.md § [section number]
**Completed:** [n] of [total] items
**Remaining:** [list of outstanding items with item codes]

## In Progress

- [Current phase and what remains]
- [Which integration checklist items are done vs. pending]

## Open Questions

- [Unresolved questions or decisions deferred to user]

## AI Disclosure

This session used DAAF (Data Analyst Augmentation Framework) in Framework
Development mode. DAAF contributed to: [list specific contributions —
artifact authoring, template compliance verification, integration checklist
execution, cross-file consistency review, etc.].
The researcher directed all framework design decisions and approved all changes.
```

### When to Update SESSION_NOTES.md

| Event | What to Update |
|-------|---------------|
| Phase 1 scoping complete | Accomplishments + Key Decisions + Integration Status |
| Framework-engineer dispatch returns | Accomplishments + Integration Status |
| Key design decision made | Key Decisions |
| Review pass complete (Phase 4) | Accomplishments + In Progress |
| Context reaches ELEVATED (≥ 40% or ≥ 150k tokens) | All sections (full checkpoint) |
| User signals session is ending | All sections (final summary) |
| Before any escalation to another mode | All sections + note the escalation |

---

## User Treatment

**Treat the user as an advanced framework developer by default.** This mode is inherently used by someone who understands DAAF's architecture and wants to modify it. Skip explanations of basic concepts (what is a skill, what is a mode). Go directly to specifics:

- "The `data-scientist` skill currently has 14 reference files. Your proposed addition would bring it to 15."
- "The closest analog agent is `source-researcher` (481 lines). I'd suggest differentiating in the Core Distinction table along the [specific] axis."
- "Adding this mode requires updating 13 mandatory registration points across 6 files."

If the user asks conceptual questions ("what's the difference between a skill and an agent?"), answer them — but don't volunteer foundational explanations unprompted.

---

## Output Format

Framework Development has variable outputs depending on the work:

| Work Type | Primary Output | Supporting Output |
|-----------|---------------|-------------------|
| New Skill | SKILL.md + references/ | Integration updates across framework files |
| New Agent | Agent .md file | README.md updates, integration wiring |
| New Mode | Mode reference .md file | SKILL.md updates, BOUNDARIES.md, user_reference, README.md, supporting references |
| Modify Existing | Updated file(s) | Downstream updates if scope changed |
| Incorporate Learnings | Updated framework file(s) per action plan items | Integration updates as needed per standard modification standards |
| Multi-Component | Multiple of the above | Cross-component consistency verification |

All outputs are framework files placed directly in the DAAF codebase.

---

## Boundaries

These boundaries supplement the universal safety boundaries in `CLAUDE.md`. See also `agent_reference/BOUNDARIES.md` > Framework Development Mode.

### Always Do

- Scope the existing state before modifying anything (Phase 1 is mandatory)
- Follow canonical templates for all new artifacts
- Execute the applicable FRAMEWORK_INTEGRATION_CHECKLIST.md section
- Always dispatch review subagents in Phase 4 — minimum 2 (Simple) or 3 (Moderate/Complex). The orchestrator must never self-review in lieu of subagent dispatch.
- Present changes for user review at Checkpoint 2
- Load `skill-authoring` and `agent-authoring` at mode start
- Commit intermediate state (or update SESSION_NOTES.md) before non-trivial multi-file modifications, so that a session interruption does not leave the framework in an inconsistent state
- Set executable permissions (`chmod +x` + `git update-index --chmod=+x`) on any newly created or modified `.sh` files (hooks, utility scripts) and verify with `git ls-files -s` that the mode is `100755`

### Ask First Before

- Modifying CLAUDE.md (universal authority document)
- Modifying settings.json or hook scripts (safety-critical configuration)
- Changing the structure of existing templates (AGENT_TEMPLATE.md, MODE_TEMPLATE.md, etc.)
- Deleting or renaming existing framework files
- Making changes beyond the user's stated scope
- Modifying Dockerfile or docker-compose.yml

### Never Do

- Create or modify files in `.claude/hooks/` without explicit user permission
- Skip Phase 1 scoping (even for "simple" changes — you might discover unexpected connections)
- Skip Checkpoint 1 (user must confirm scope before modifications begin)
- Skip Phase 4 review subagent dispatch for any reason, including low complexity — self-review is never a substitute
- Create research project artifacts (scripts/, data/, output/) — escalate to appropriate mode
- Proceed with modifications when safety-critical files are involved without explicit approval
- Assume a change is isolated — always check for downstream impacts

---

## Escalation Triggers

| Condition | Target Mode | Action |
|-----------|-------------|--------|
| User wants to onboard a new dataset (not just create a skill template) | Data Onboarding | "Data Onboarding will profile your data automatically and create the skill. Want me to switch?" |
| User wants to test a new skill with actual analysis | Full Pipeline | "To test this with real data, we'd run a Full Pipeline analysis. Want to try that?" |
| User realizes they need to debug an existing analysis, not the framework | Ad Hoc Collaboration | "That sounds like analysis work rather than framework development. Want to switch to Ad Hoc?" |
| User wants to review or revise an analysis that used the framework | Revision and Extension | "That's a revision of existing analysis work. Want me to switch to Revision and Extension mode?" |
| Framework change requires testing with a specific data source | Data Discovery | "Let me explore what's available for that data source first." |

All escalations require explicit user confirmation.
