# Agent Integration Checklist

> **Purpose:** Supplementary walkthrough for agent integration, organized by update obligation.
> The canonical registration-point checklist is `agent_reference/FRAMEWORK_INTEGRATION_CHECKLIST.md` § 2 — use it as the primary checklist. This document provides additional context, verification scripts, and tier-based organization to complement the canonical checklist.

---

## Tier 1: MANDATORY Registry Updates

**Update ALL of these for EVERY new agent. No exceptions.**

> These items correspond to FRAMEWORK_INTEGRATION_CHECKLIST.md items A3-A5 and A14. Consult that document for the canonical specification; this section provides walkthrough detail.

### 1. `.claude/agents/README.md` — Agent Index table

**Section:** "Agent Index"
**What to add:** New row with Agent, Purpose, Subagent Type, Stage(s), Key Inputs, Key Outputs

```markdown
| **new-agent** | [Purpose] | `[agent-name]` | [Stage(s)] | [Key Inputs] | [Key Outputs] |
```

### 2. `.claude/agents/README.md` — "When to Use" section

**Section:** "When to Use Each Agent" (add new subsection)
**What to add:** Complete subsection with:
- `**Use when:**` trigger description
- `**Key behaviors:**` bulleted list (3-5 items)
- `**Invocation template:**` reference to the appropriate `agent_reference/WORKFLOW_PHASE*.md` or mode reference file
- Any additional context (constraints, revision flow, etc.)

Follow the format of existing agent subsections in this file.

### 3. `.claude/agents/README.md` — Agent Coordination Matrix

**Section:** "Agent Coordination Matrix"
**What to add:** Producer/consumer row(s) showing:
- What this agent produces and who consumes it
- What this agent consumes and who produces it

### 4. `README.md` (project root) — Agent count and table

**Section:** Agent Ecosystem
**What to add:** Update agent count and add row to agent table if one exists. This is the project root `README.md`, distinct from `.claude/agents/README.md`.

---

## Tier 2: CONDITIONAL Workflow Integration

**Update these IF the new agent maps to a specific pipeline stage or changes the workflow.**

### 5. `full-pipeline-mode.md` — Skill-to-Stage Mapping table

**Condition:** Agent has a primary pipeline stage
**Section:** "Skill-to-Stage Mapping" (in `.claude/skills/daaf-orchestrator/references/full-pipeline-mode.md`)
**What to add:** New or updated row with Stage, Primary Skill(s), Subagent Type, Invocation Pattern

### 6. `full-pipeline-mode.md` — Core Workflow Overview diagram

**Condition:** Agent appears in the main workflow flow (not on-demand/any-stage agents)
**Section:** "Core Workflow Overview" (in `.claude/skills/daaf-orchestrator/references/full-pipeline-mode.md`)
**What to add:** Agent reference in the relevant stage description

### 7. `full-pipeline-mode.md` — Handoff Specifications table

**Condition:** Agent produces or consumes stage output that affects gate criteria
**Section:** "Handoff Specifications" (in `.claude/skills/daaf-orchestrator/references/full-pipeline-mode.md`)
**What to add:** Updated gate criteria for affected stages

### 8. `full-pipeline-mode.md` — Stage Gates table

**Condition:** Agent introduces a new gate or modifies an existing gate
**Section:** "Stage Gates (Cannot Proceed Without)" (in `.claude/skills/daaf-orchestrator/references/full-pipeline-mode.md`)
**What to add:** New or updated gate row

### 9. `full-pipeline-mode.md` — Stage Overview table

**Condition:** Agent maps to a specific stage
**Section:** "Stage Overview"
**What to add:** New or updated row with Stage, Phase, Name, Primary Skill/Agent, Subagent type

### 10. Appropriate `agent_reference/WORKFLOW_PHASE*.md` — Individual stage section

**Condition:** Agent operates within a specific stage
**Section:** The individual stage section (e.g., "Stage 7: EDA & Transformation")
**What to add:** Agent/subagent subsection or update to existing section
**Phase mapping:** Stages 1-3.5 → `WORKFLOW_PHASE1_DISCOVERY.md`, Stages 4-4.5 → `WORKFLOW_PHASE2_PLANNING.md`, Stages 5-6 → `WORKFLOW_PHASE3_ACQUISITION.md`, Stages 7-10 → `WORKFLOW_PHASE4_ANALYSIS.md`, Stages 11-12 → `WORKFLOW_PHASE5_SYNTHESIS.md`

### 11. Appropriate `agent_reference/WORKFLOW_PHASE*.md` — Stage invocation template

**Condition:** Agent has a unique invocation template not covered by existing patterns
**Section:** Add new stage-specific template section in the appropriate phase file
**What to add:** Complete invocation template following the file's existing format
**Phase mapping:** Same as item 10 above

### 12. `.claude/agents/README.md` — Orchestration Flow diagram

**Condition:** Agent changes the orchestration workflow
**Section:** "Orchestration Flow" (ASCII diagram)
**What to add:** Agent box in the relevant position

### 13. `agent_reference/ERROR_RECOVERY.md` — Error Recovery Routing

**Condition:** Agent handles specific error types or participates in error recovery
**Section:** "Error Recovery Routing"
**What to add:** New branch in the routing diagram and/or error budget entry

### 14. Agent file — `skills:` frontmatter field

**Condition:** Agent uses one or more skills during execution
**What to add:** Ensure the agent's `skills:` frontmatter field lists preloaded skills. Stage-specific skill loading is documented in the agent's Protocol section and the corresponding `agent_reference/WORKFLOW_PHASE*.md` invocation templates.

---

## Tier 3: CONDITIONAL Narrative Updates

**Review these files and update IF the new agent affects their described workflows or content.**

| # | File | Update Condition |
|---|------|-----------------|
| 15 | Appropriate `agent_reference/WORKFLOW_PHASE*.md` | Agent implements or extends a workflow phase |
| 16 | `agent_reference/BOUNDARIES.md` | Agent has special deviation authority or unique boundaries |
| 17 | `agent_reference/VALIDATION_CHECKPOINTS.md` | Agent runs validation checkpoints |
| 18 | `agent_reference/QA_CHECKPOINTS.md` | Agent participates in QA review |
| 19 | `agent_reference/ERROR_RECOVERY.md` | Agent handles specific error types |
| 20 | `CLAUDE.md` > "Context & Session Health" | Agent has special context considerations |
| 21 | `full-pipeline-mode.md` > "Learning Signal Protocol" | Agent generates learning signals |
| 22 | `agent_reference/PLAN_TEMPLATE.md` | Agent reads or writes Plan.md |
| 23 | `agent_reference/PLAN_TASKS_TEMPLATE.md` | Agent reads or writes Plan_Tasks.md |
| 24 | `agent_reference/STATE_TEMPLATE.md` | Agent affects STATE.md fields |
| 25 | `user_reference/02_understanding_daaf.md` | Agent changes the architecture description for users |
| 26 | `user_reference/04_extending_daaf.md` | Agent enables new extension patterns |
| 27 | `user_reference/07_faq_technical.md` | Agent affects common technical questions |

---

## Tier 4: NO Updates Required

These files do NOT need updating when adding agents:

- **Configuration files:** `docker-compose.yml`, `.claude/settings.json`, `.claude/settings.local.json`, `.pre-commit-config.yaml`
- **Research project outputs:** Anything in `research/` directory
- **Existing skill files:** Anything in `.claude/skills/` (unless the agent needs a companion skill)
- **Script templates:** `agent_reference/SCRIPT_EXECUTION_REFERENCE.md`, `agent_reference/INLINE_AUDIT_TRAIL.md` (unless the new agent writes scripts)

---

## Post-Integration Verification

After completing all applicable tiers, run these checks:

### 1. Registry Presence

```bash
# Verify agent name appears in all Tier 1 files
AGENT_NAME="new-agent-name"
for f in .claude/agents/README.md; do
  echo "$f: $(grep -c "$AGENT_NAME" "$f") references"
done
```

**Expected:** .claude/agents/README.md has 3+ references (index, when-to-use, coordination matrix).

### 2. Agent Count Consistency

```bash
# Count actual agent files (excluding README, _revised, and this file)
ACTUAL=$(ls .claude/agents/*.md | grep -v README | grep -v _revised | wc -l)
echo "Actual agent files: $ACTUAL"

# Check README.md header
grep "Specialized Agents" README.md
# The number in parentheses should match $ACTUAL
```

### 3. Cross-Reference Integrity

```bash
# Verify no broken agent references in .claude/agents/README.md
# (Every agent mentioned in .claude/agents/README.md should have a file in .claude/agents/)
grep -oP '\*\*\w[\w-]+\*\*' .claude/agents/README.md | sort -u | while read agent; do
  name=$(echo "$agent" | tr -d '*')
  if [ -f ".claude/agents/${name}.md" ]; then
    echo "OK: $name"
  else
    echo "MISSING: $name"
  fi
done
```

---

## Checklist Summary (Copy-Paste for Tracking)

```markdown
## New Agent Integration: [agent-name]

> Canonical checklist: `agent_reference/FRAMEWORK_INTEGRATION_CHECKLIST.md` § 2

### Tier 1: MANDATORY
- [ ] .claude/agents/README.md — Agent Index table (new row)
- [ ] .claude/agents/README.md — "When to Use" section (new subsection)
- [ ] .claude/agents/README.md — Agent Coordination Matrix (producer/consumer rows)
- [ ] README.md (project root) — Agent count and table

### Tier 2: CONDITIONAL (check applicability)
- [ ] full-pipeline-mode.md — Skill-to-Stage Mapping (if stage-specific)
- [ ] full-pipeline-mode.md — Core Workflow diagram (if in main flow)
- [ ] full-pipeline-mode.md — Handoff Specifications (if affects gates)
- [ ] full-pipeline-mode.md — Stage Gates table (if new/modified gate)
- [ ] full-pipeline-mode.md — Stage Overview (if stage-specific)
- [ ] agent_reference/WORKFLOW_PHASE*.md — Individual stage section (if stage-specific)
- [ ] agent_reference/WORKFLOW_PHASE*.md — Stage invocation template (if unique invocation template)
- [ ] .claude/agents/README.md — Orchestration Flow diagram (if changes workflow)
- [ ] agent_reference/ERROR_RECOVERY.md — Error Recovery Routing (if handles errors)
- [ ] Agent file — `skills:` frontmatter field (if uses skills)

### Tier 3: CONDITIONAL (review applicability)
- [ ] Appropriate agent_reference/WORKFLOW_PHASE*.md (if implements workflow phase)
- [ ] agent_reference/BOUNDARIES.md (if special boundaries)
- [ ] agent_reference/VALIDATION_CHECKPOINTS.md (if runs checkpoints)
- [ ] agent_reference/QA_CHECKPOINTS.md (if participates in QA)
- [ ] agent_reference/ERROR_RECOVERY.md (if handles error types)
- [ ] CLAUDE.md > "Context & Session Health" (if special context needs)
- [ ] full-pipeline-mode.md > "Learning Signal Protocol" (if generates learning signals)
- [ ] agent_reference/PLAN_TEMPLATE.md (if reads/writes Plan.md)
- [ ] agent_reference/PLAN_TASKS_TEMPLATE.md (if reads/writes Plan_Tasks.md)
- [ ] agent_reference/STATE_TEMPLATE.md (if affects STATE.md)
- [ ] user_reference/02_understanding_daaf.md (if changes architecture)
- [ ] user_reference/04_extending_daaf.md (if enables new extensions)
- [ ] user_reference/07_faq_technical.md (if affects FAQs)

### Post-Integration Verification
- [ ] Agent name found in all Tier 1 files
- [ ] Agent count in README.md matches actual count
- [ ] No broken cross-references
```
