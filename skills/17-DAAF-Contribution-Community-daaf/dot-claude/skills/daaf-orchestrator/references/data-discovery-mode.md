# Data Discovery Mode

Data Discovery mode is for answering "what data exists?" and "is this analysis feasible?" questions. It executes a subset of the Full Pipeline workflow (Stages 1-3 + synthesis) without producing Plans, code, or analysis artifacts.

## User Orientation

After mode confirmation, briefly orient the user. Key points:

- Read-only exploration — no code, no downloads
- Returns summary of available data and feasibility assessment
- Can escalate to full analysis if promising

**When to skip:** User has indicated familiarity, or this is an escalation from Data Lookup.

**For more detail:** Consult `{BASE_DIR}/user_reference/02_understanding_daaf.md`.

---

## Data Discovery Workflow

```
Stage 1: Classify as Data Discovery Mode → Confirm with user
    ↓
Stage 2: Data Exploration
    ├─ Invoke domain explorer skill via subagent (search-agent, read-only)
    ├─ Identify available endpoints and variables
    └─ Flag variables needing source-specific deep dives
    ↓
Stage 3: Source Deep-Dive (if needed)
    ├─ Invoke domain source skill(s) via subagent(s) for flagged variables
    ├─ Understand limitations, caveats, suppression patterns
    └─ Document source-specific gotchas
    ↓
Findings Synthesis
    ├─ Consolidate findings into a clear summary
    ├─ Assess feasibility of potential analyses
    └─ Present to user with escalation option
```

**Stage 2-3 can run in parallel** when exploring multiple sources — dispatch one subagent per source using `search-agent` subagent type (read-only is sufficient for exploration).

**Before dispatching subagents:** Read `{BASE_DIR}/agent_reference/WORKFLOW_PHASE1_DISCOVERY.md` for the detailed invocation templates (Stage 2: Domain Explorer, Stage 3: Source Deep-Dive). These templates specify the exact prompt structure, context fields, thoroughness directives, and output formats for each subagent type.

**Note:** Data Discovery mode does NOT require loading `agent_reference/BOUNDARIES.md`, or `full-pipeline-mode.md`. These contain execution-stage guidance (QA substages, code review patterns, git commit protocol) that is irrelevant to Data Discovery's read-only exploration.

## Subagent Invocation

Data Discovery uses read-only subagents to explore data availability. Follow the invocation templates in `{BASE_DIR}/agent_reference/WORKFLOW_PHASE1_DISCOVERY.md`, with these specifics:

- **Stage 2:** Subagent invokes the domain explorer skill (e.g., `education-data-explorer` for education domain)
- **Stage 3:** Subagent invokes domain source skill(s) (e.g., `education-data-source-ccd`) for deep dives on specific sources flagged in Stage 2
- **Skill lookup:** Review the skill inventory in the system message for the complete skill-to-source mapping
- **Subagent type:** `search-agent` (read-only — no data downloads or code execution)

## Output Format

Present findings as a structured summary:

```
**Data Discovery Findings**

**Data Availability:**
- [Source 1]: [What's available, key variables, years covered]
- [Source 2]: [What's available, key variables, years covered]

**Feasibility Assessment:**
- [Can the user's question be answered with available data?]
- [Key limitations or caveats to be aware of]

**Recommended Next Steps:**
- [Specific suggestion — e.g., proceed to Full Pipeline, narrow scope, etc.]

**AI Disclosure Note:** This exploration was conducted using DAAF with [model ID] on [date].
DAAF version: [commit hash]. See `agent_reference/AI_DISCLOSURE_REFERENCE.md` for
disclosure guidance if incorporating these findings into published work.
```

## Multi-Source Synthesis Protocol

When Data Discovery explores multiple data sources (multiple Stage 3 returns), the orchestrator consolidates findings directly (without dispatching the research-synthesizer agent). Follow this protocol:

1. **Merge structured outputs.** For each source-researcher return, extract: variables identified, temporal coverage, geographic coverage, key caveats, and coded values.
2. **Identify conflicts.** Flag cases where the same concept (e.g., "poverty rate") is measured differently across sources, or where temporal/geographic coverage doesn't align.
3. **Assess overall feasibility.** Based on merged findings: Can the user's question be answered with available data? What are the primary limitations? Which sources are essential vs. supplementary?
4. **Structure the synthesis** using the Output Format above, organizing by theme rather than by source.

**When NOT to synthesize here:** If findings reveal enough complexity to warrant formal analysis (multiple joins, derived measures, statistical modeling), propose escalation to Full Pipeline instead of attempting a comprehensive synthesis.

## Boundaries

These boundaries supplement the universal safety boundaries in `CLAUDE.md`. The detailed execution boundaries in `agent_reference/BOUNDARIES.md` (autonomous deviation rules, git commit protocol, STOP conditions) do not apply to Data Discovery mode's read-only exploration.

**Always Do:**
- Focus on data availability and feasibility
- Provide clear findings summary
- Note when Full Pipeline escalation might be beneficial
- Document what was searched and what was found

**Never Do:**
- Create Plan files
- Generate analysis code or notebooks
- Invoke code-generation agents (research-executor, notebook-assembler, etc.)
- Execute data queries beyond metadata exploration
- Over-scope beyond what user asked

## Escalation to Full Pipeline

When findings suggest analysis is feasible and valuable, propose escalation:

> "Based on these findings, data is available for this analysis. Would you like me to proceed with Full Pipeline mode?"

Wait for explicit user confirmation before switching modes. If the user confirms, load `{SKILL_REFS}/full-pipeline-mode.md` to begin the full workflow.
