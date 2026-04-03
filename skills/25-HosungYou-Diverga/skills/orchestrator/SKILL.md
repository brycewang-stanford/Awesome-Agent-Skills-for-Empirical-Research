---
name: orchestrator
description: |
  Unified Agent Teams orchestrator for Diverga v12.0.0.
  Manages Agent Teams creation, VS Arena debate, and subagent dispatch.
  Single entry point for all parallel/debate workflows.
  Replaces research-orchestrator and vs-arena skills.
  Triggers: orchestrator, agent team, create team, parallel agents, debate,
  competing, collaborate, VS Arena
version: "12.0.1"
---

# Diverga Orchestrator

## Role

Execution layer (HOW). Receives agent IDs, decides execution strategy, manages lifecycle.

Does NOT handle:
- Paradigm detection (research-coordinator)
- Checkpoint enforcement (research-coordinator)
- Agent selection logic (research-coordinator)

No circular dependency: coordinator calls orchestrator, never reverse. Orchestrator receives agent IDs and executes; it does not call back into the coordinator.

---

## Invocation

1. **Explicit**: `/diverga:orchestrator`
2. **Natural language**: "create team", "debate", "parallel agents", "run VS Arena", "compare methods", "competing hypotheses"
3. **Auto**: research-coordinator delegates when parallel or debate execution is needed

---

## Prerequisite Handling

Orchestrator does NOT enforce research checkpoints. It trusts the caller (coordinator or user) to have resolved prerequisites.

- When called by coordinator: all prerequisites already resolved. Orchestrator receives agent IDs + context + execution mode.
- When called directly by user: if `.research/` context exists, read it; otherwise proceed without checkpoint gating.
- Orchestrator's own checkpoint: only token cost confirmation before team creation.

---

## Decision Logic

```
Request received
  |
  v
Check config.agent_teams.enabled
  |
  +-- false --> Always use subagents (Task with run_in_background)
  |
  +-- true --> Check CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS env var
       |
       +-- not set --> Subagent fallback + warn user
       |
       +-- set --> Evaluate scenario
            |
            +-- Inter-agent debate needed? --> Agent Teams
            |     (VS Arena, cross-method comparison, competing hypotheses)
            |
            +-- Parallel independent work? --> Agent Teams
            |     (multi-DB fetch, parallel review, concurrent analysis)
            |
            +-- Sequential pipeline? --> Subagents
            |     (G5->G6->F5 humanize, single agent tasks)
            |
            +-- Simple single agent? --> Direct Task dispatch
```

---

## Agent Teams Mode

When `config.agent_teams.enabled = true` AND `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set.

### Team Lifecycle

1. **Evaluate scenario** -- determine if Teams adds value over subagents
2. **Create team** -- natural language prompt to Claude Code (conversational team creation, NOT raw TeamCreate API call)
3. **Spawn teammates** -- each teammate receives an agent-specific prompt with research context
4. **Monitor progress** -- track teammate status
5. **Collect results** -- gather outputs from all teammates
6. **Present at checkpoint** -- deliver results for user review
7. **Cleanup** -- delete team after user selection or task completion

### VS Arena Protocol (7 Stages)

#### Stage 1: Context Collection

Gather research context from `diverga_project_status` or user input:
- `research_question` (from CP_RESEARCH_DIRECTION or user)
- `paradigm` (from CP_PARADIGM_SELECTION or user)
- `research_field` (e.g., Education, Psychology, HRD)
- `target_journal` (if available)
- `key_variables` (if available)

#### Stage 2: Persona Selection

Select 3 of 5 personas (V1-V5) based on paradigm:

| Rule | Always include 1 persona differing from CP_PARADIGM_SELECTION |
|------|---------------------------------------------------------------|

| Paradigm | Selection |
|----------|-----------|
| Quantitative | V1 + V4 + one of V2/V3/V5 |
| Qualitative | V4 + V1 + one of V2/V3/V5 |
| Mixed | V3 + two of V1/V2/V4/V5 |
| No paradigm set | V1 + V3 + V4 (maximum paradigmatic spread) |

All VS Arena personas run on opus.

#### Stage 3: Team Creation

Create the team and spawn 3 persona teammates:
```
TeamCreate("vs-arena-{topic}")
Spawn teammate for each selected persona with prompt:
  - Research context (question, field, paradigm, variables, journal)
  - Persona definition reference (agents/v{N}.md)
  - Persona constraints reference (config/personas.json cannotRecommend)
  - Instruction: provide exactly ONE methodology recommendation
```

#### Stage 4: Independent Research

Each persona investigates the research question independently. No inter-agent communication during this stage.

#### Stage 5: Cross-Critique

Teammates message each other directly via team mailbox (SendMessage):
- Each persona receives the other two recommendations
- Each writes a 2-3 sentence critique from their epistemological perspective
- Personas may refine their recommendations based on feedback

#### Stage 6: Synthesis + Checkpoint

Lead collects all positions and presents at CP_METHODOLOGY_APPROVAL:
```
## VS Arena: Methodology Recommendations

### Option A: [Persona] Recommendation
Methodology: [name]
T-Score: [score]
Rationale: [brief]
Cross-critique from other personas: [summaries]

### Option B: ...
### Option C: ...

Which methodology would you like to proceed with? (A/B/C)
```

WAIT for user selection. Record decision.

#### Stage 7: Cleanup

TeamDelete after user makes selection.

### Scenario Templates

| Scenario | Team Name | Teammates | When |
|----------|-----------|-----------|------|
| VS Arena | `vs-arena-{topic}` | 3 of V1-V5 | CP_METHODOLOGY_APPROVAL or explicit request |
| Systematic Review | `sr-pipeline-{topic}` | I1 x3 (per DB) | I0 multi-DB fetch |
| Cross-Method | `method-compare-{topic}` | C1+C2+C3 | Competing design recommendations |
| Parallel Review | `review-{topic}` | 2-5 agents | Quality review from multiple angles |
| Custom | `{user-specified}` | User-specified | Explicit orchestrator call |

### Custom Teams

Users can request custom teams via natural language:

```
User: "/diverga:orchestrator create a team with C1 and C2 to compare
       quantitative designs for my RCT study"

Orchestrator parses:
  - agents: [C1, C2]
  - purpose: competing design recommendations
  - team_name: "design-compare-rct"
  - teammate_count: 2
```

```
User: "Have 3 agents review my methodology section from different angles"

Orchestrator infers:
  - agents: [X1 (ethics), B2 (quality), G2 (publication readiness)]
  - purpose: parallel review
  - team_name: "review-methodology"
  - teammate_count: 3
```

Maximum teammates: 5 (per Claude Code best practices). If user requests more, suggest splitting into phases.

---

## Subagent Mode (Fallback)

When teams are disabled or unavailable, all workflows fall back to subagent dispatch.

Same VS Arena stages, but:
- **Stage 3**: `Task(subagent_type="diverga:v{N}", model="opus", run_in_background=true)` instead of team creation
- **Stage 5**: SKIP cross-critique -- subagents cannot message each other. Orchestrator synthesizes comparison instead: reads all 3 outputs, identifies overlaps and contradictions, presents unified comparison.
- **Stage 6**: Lead presents orchestrator-synthesized comparison at checkpoint

Cross-critique is permanently unavailable in subagent mode. This is a known limitation, not a bug. The orchestrator compensates with its own synthesis.

---

## Model Routing

All agents route to their designated model tier. Source of truth: `config/agents.json`.

| Category | Agent | Display Name | Tier | Model |
|----------|-------|-------------|------|-------|
| **A: Foundation** | A1 | Research Question Refiner | HIGH | opus |
| | A2 | Theory & Critique Architect | HIGH | opus |
| | A5 | Paradigm Advisor | HIGH | opus |
| **B: Evidence** | B1 | Literature Scout | MEDIUM | sonnet |
| | B2 | Quality Appraiser | MEDIUM | sonnet |
| **C: Design** | C1 | Quantitative Design & Sampling | HIGH | opus |
| | C2 | Qualitative Design (Ethnography/AR) | HIGH | opus |
| | C3 | Mixed Methods Design | HIGH | opus |
| | C5 | Meta-Analysis Master | HIGH | opus |
| **D: Collection** | D2 | Data Collection Specialist | MEDIUM | sonnet |
| | D4 | Instrument Developer | HIGH | opus |
| **E: Analysis** | E1 | Quantitative Analysis & Code Gen | HIGH | opus |
| | E2 | Qualitative Coding | HIGH | opus |
| | E3 | Mixed Methods Integration | HIGH | opus |
| **F: Quality** | F5 | Humanization Verifier | MEDIUM | sonnet |
| **G: Publication** | G1 | Journal Matcher | MEDIUM | sonnet |
| | G2 | Publication Specialist | MEDIUM | sonnet |
| | G5 | Academic Style Auditor | MEDIUM | sonnet |
| | G6 | Academic Style Humanizer | HIGH | opus |
| **I: Systematic Review** | I0 | SR Pipeline Orchestrator | HIGH | opus |
| | I1 | Paper Retrieval | MEDIUM | sonnet |
| | I2 | Screening Assistant | MEDIUM | sonnet |
| | I3 | RAG Builder | LOW | haiku |
| **X: Cross-Cutting** | X1 | Research Guardian | HIGH | opus |

V1-V5 personas are not listed here -- they are always invoked through VS Arena at opus tier.

Always pass `model` parameter explicitly when dispatching:
```python
# HIGH tier
Task(subagent_type="general-purpose", model="opus", ...)
# MEDIUM tier
Task(subagent_type="general-purpose", model="sonnet", ...)
# LOW tier
Task(subagent_type="general-purpose", model="haiku", ...)
```

---

## Token Cost Awareness

Before creating a team, prompt the user:

```
"Agent Teams will spawn N independent sessions. Proceed?
 [Y] Yes  /  [S] Subagents instead  /  [N] Cancel"
```

Skip this prompt if the user explicitly requested teams.

---

## Removed Modes

Autonomous modes (Sisyphus, OMC, ralph, ultrawork, ecomode) removed in v6.0. See CHANGELOG.md.
