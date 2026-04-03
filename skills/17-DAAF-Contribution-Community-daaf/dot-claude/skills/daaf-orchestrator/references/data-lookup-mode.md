# Data Lookup Mode

Data Lookup mode is for specific lookup questions — coded values, variable definitions, data source details, or quick factual answers. It invokes a single relevant skill and returns a direct answer.

## User Orientation

Give the user a clear sense for how you'll operate -- what you'll look into, what you'll be looking for, what info you'll be paying attention to, and so on.

For unfamiliar users, add something like: *"If it turns out your question touches on something broader, I'll let you know and we can explore further."*

---

## Data Lookup Workflow

```
Stage 1: Classify as Data Lookup → Confirm with user
    ↓
Identify the single most relevant skill for the question
    ↓
Invoke skill via subagent (search-agent, read-only)
    ↓
Return direct, focused answer to user
```

## Subagent Invocation

- Invoke **one** subagent with the relevant skill (e.g., `education-data-source-ccd` for a CCD variable question)
- Use `search-agent` subagent type (read-only)
- **Always load `data-scientist`** in addition to the domain skill — it provides methodological rigor for interpreting results
- The subagent loads the skills, finds the answer, and returns it
- If the skill doesn't contain the answer, report that clearly rather than guessing

Review the skill inventory in the system message to identify the correct skill for the question.

### Agent Selection

Match agent protocol weight to question complexity:

| Question Type | Agent Protocol | Domain Skill | Example |
|--------------|----------------|--------------|---------|
| Simple fact, definition, year coverage | None (skill-only) | Source or explorer | "What years does CCD cover?" |
| Coded values, suppression patterns, caveats | `source-researcher` | Source (`*-data-source-*`) | "What are the suppression rules for CRDC discipline data?" |
| What data exists (narrow, single-source) | None (skill-only) | Explorer | "Does CCD include charter school flags?" |

> **Note:** Broad landscape questions ("What data exists about school poverty?") are better served by Data Discovery Mode. The Explorer row above is for narrow, source-specific existence checks where the user already knows which domain to look in.

**Default:** No agent protocol (skill-only). Use `source-researcher` when the question requires structured investigation of caveats, coded values, or suppression patterns — the cases where its 5-section output contract adds value.

### Invocation Template: Simple Lookup (Default)

```python
Agent({
    description: "Data Lookup: [question summary]",
    prompt: """You are answering a specific data lookup question.

**BASE_DIR:** {BASE_DIR}
All relative paths in referenced files resolve from BASE_DIR.

## SKILL LOADING
Call the skill tool with name 'data-scientist'.
Then, call the skill tool with name '[skill-name-from-catalog]'.

If a skill fails to load, report the failure clearly and attempt to answer
from base knowledge. Flag reduced confidence due to the missing skill.

## QUESTION
{user's specific question}

## RESPONSE FORMAT
**Hard cap: 500 words.** Answer directly and concisely.

Provide:
- The specific values, definitions, or information requested
- Source attribution (which skill/documentation provided the answer)
- Any important caveats or limitations
- Confidence level (HIGH/MEDIUM/LOW) with brief rationale

If the question cannot be fully answered from the available skill, say so
clearly and suggest what additional exploration might help.""",
    subagent_type: "search-agent"
})
```

### Invocation Template: Deep Lookup (source-researcher)

Use when the question requires investigating caveats, coded values, or suppression patterns in depth.

```python
Agent({
    description: "Data Lookup: [question summary]",
    prompt: """**BASE_DIR:** {BASE_DIR}
All relative paths in referenced files resolve from BASE_DIR.

## SKILL LOADING
Call the skill tool with name 'data-scientist'.
Then, call the skill tool with name '{domain}-data-source-{source}'.

If a skill fails to load, STOP and report the failure (see STOP Conditions
in your agent protocol).

## CONTEXT
**Question:** {user's specific question}
**Source:** {source_name}
**Variables of interest:** {variables, if applicable}

## TASK
Answer the user's specific question using the source-researcher protocol.
Focus your investigation on the sections most relevant to the question —
you do not need to produce a complete 5-section report if the question
only touches one area (e.g., coded values only → focus on VARIABLES section).

## RESPONSE FORMAT
**Hard cap: 500 words.** Return only the sections relevant to the question.

- The specific answer to the question
- Supporting detail from the relevant report section(s)
- Confidence level (HIGH/MEDIUM/LOW) with rationale
- Any caveats or warnings the user should know""",
    subagent_type: "source-researcher"
})
```

## Response Format

Provide a direct, actionable answer:

```
**[Variable/concept name]**

[Direct answer to the question]

**Source:** [Which skill/data source this comes from]

*If referencing in published work, see `agent_reference/AI_DISCLOSURE_REFERENCE.md` for disclosure guidance.*
```

Keep responses concise. The user asked a specific question — answer it specifically.

## Boundaries

These boundaries supplement the universal safety boundaries in `CLAUDE.md`. The detailed execution boundaries in `agent_reference/BOUNDARIES.md` do not apply to Data Lookup mode (no code execution, no data transformations, no commits).

**Always Do:**
- Answer the specific question asked
- Keep response focused and concise
- Suggest Data Discovery Mode if broader exploration needed
- Provide direct, actionable information

**Never Do:**
- Execute multiple skills without confirmation
- Create Plan files or generate code
- Expand into full data discovery without confirmation
- Assume Full Pipeline is needed from a single question

## Escalation Triggers

**To Data Discovery Mode** — when the question reveals broader data exploration is needed:
> "This question touches on broader data exploration. Would you like me to switch to Data Discovery Mode?"

**To Full Pipeline** — when the lookup reveals an actionable analysis opportunity:
> "This lookup suggests an interesting analysis could be done. Would you like me to explore this further?"

Wait for explicit user confirmation before switching modes.
