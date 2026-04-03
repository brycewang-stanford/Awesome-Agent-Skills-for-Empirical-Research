# Cross-Agent Standards

> **Purpose:** Mandatory elements that MUST be identical across all DAAF agents.
> Deviating from these standards breaks orchestrator parsing and cross-agent consistency.

---

## Standardized Elements

### 1. Confidence Levels

Every agent's Output Format MUST include a Confidence Assessment using this exact model:

```markdown
### Confidence Assessment
**Overall Confidence:** [HIGH | MEDIUM | LOW]

| Aspect | Confidence | Rationale |
|--------|------------|-----------|
| [Aspect 1] | [H/M/L] | [Evidence-based reasoning, not just label] |
| [Aspect 2] | [H/M/L] | [Why] |
```

**Level Definitions (core definitions identical across all agents; agent-specific parenthetical examples permitted):**

| Level | Definition | Required Action |
|-------|------------|-----------------|
| **HIGH** | Evidence directly confirms correctness | Proceed normally |
| **MEDIUM** | Likely correct but some uncertainty; documented | Document caution; proceed |
| **LOW** | Significant uncertainty; resolution needed before proceeding | MUST resolve before proceeding |

**Aggregation Rule:** Overall confidence = weakest component (weakest-link rule).

**LOW Confidence Resolution (required):**
```markdown
**If any aspect is LOW:**
- **Item:** [Which aspect]
- **Concern:** [What's uncertain]
- **Resolution needed:** [What would raise confidence]
```

---

### 2. Learning Signal

Every agent's Output Format MUST include a Learning Signal section:

```markdown
### Learning Signal
**Learning Signal:** [Category] — [One-line insight] | "None"
```

**Categories (standardized — do not invent new ones):**

| Category | When to Use | Example |
|----------|-------------|---------|
| **Access** | Data availability, mirrors, rate limits | "CCD mirror requires auth after 2026-02" |
| **Data** | Quality, suppression, distributions | "MEPS has 12% ambiguous school keys" |
| **Method** | Methodology edge cases, transforms | "District aggregation requires LEAID type filter" |
| **Perf** | Performance, memory, runtime | "Polars left_join on 200M rows needs 8GB" |
| **Process** | Execution patterns, error patterns | "Script versioning needed 2+ attempts 40% of the time" |

If nothing novel was discovered, emit `"None"` — this is the expected common case.

---

### 3. Severity Levels

All agents that produce status assessments MUST use these three levels:

| Level | Definition | Orchestrator Action |
|-------|------------|-------------------|
| **BLOCKER** | Critical issue preventing valid results | Invoke revision flow (max 2 attempts) |
| **WARNING** | Non-critical issue; log for later review | Log for Stage 10 aggregation; proceed |
| **INFO** | Informational observation | Log only; proceed |

---

### 4. STOP Conditions Format

Every agent MUST include a "STOP Conditions" section (not "When to Escalate", not "Escalation") using this format:

```markdown
## STOP Conditions

Immediately stop and escalate when:

| Condition | Action |
|-----------|--------|
| [Condition 1] | STOP — [escalation description] |
| [Condition 2] | STOP — [escalation description] |

**STOP Format:**
**[AGENT NAME] STOP: [Condition]**

**What I Found:** [Description]
**Evidence:** [Specific data/code showing the problem]
**Impact:** [How this affects the analysis]
**Options:**
1. [Option with implications]
2. [Option with implications]
**Recommendation:** [Suggested path forward]

Awaiting guidance before proceeding.
```

---

### 5. Anti-Pattern Format

Every agent MUST include an `<anti_patterns>` section with:

1. **A 4-column table** (minimum 5 rows, maximum ~20):

```markdown
| # | Anti-Pattern | Problem | Correct Approach |
|---|--------------|---------|------------------|
| 1 | [Pattern 1] | [Why it's wrong] | [What to do instead] |
```

2. **Supplementary DO NOT paragraphs** for nuanced anti-patterns:

```markdown
**DO NOT [specific prohibition].** [2-3 sentence explanation of why this is
harmful and what to do instead.]
```

Anti-patterns must be SPECIFIC to the agent, not generic programming advice.

---

### 6. Tag Wrappers

Three sections use XML-style tag wrappers for structural clarity:

| Section | Tag |
|---------|-----|
| Upstream Inputs (§3) | `<upstream_input>` ... `</upstream_input>` |
| Downstream Consumers (§7) | `<downstream_consumer>` ... `</downstream_consumer>` |
| Anti-Patterns (§9) | `<anti_patterns>` ... `</anti_patterns>` |

No other sections use tag wrappers.

---

### 7. Terminology

| Standard Term | Do NOT Use |
|--------------|------------|
| "STOP Conditions" | "When to Escalate", "Escalation", "Error Handling" |
| "Confidence Assessment" | "Confidence Score", "Certainty Level" |
| "Learning Signal" | "Lessons Learned", "Takeaways" |
| "Core Distinction" | "Comparison", "Differentiation" |
| "Anti-Patterns" | "Common Mistakes", "Don'ts" |

---

### 8. Path Resolution

Every agent's Invocation Pattern MUST include:

```markdown
**BASE_DIR:** {BASE_DIR}
All relative paths in referenced files resolve from BASE_DIR.
```

All file paths in Agent prompts to subagents MUST be absolute paths. Relative paths in documentation are for human readability only.

---

### 9. Frontmatter

Every agent MUST include YAML frontmatter:

```yaml
---
name: agent-name-here           # lowercase, hyphens, matches filename
description: >
  Third person. What it does AND when to use it.
tools: [Read, Write, Edit, Bash, Glob, Grep]   # Explicit allowlist (omit for all)
permissionMode: default          # Or: plan (read-only agents)
---
```

**Description rules:**
- Third person ("Reviews executed scripts..." not "Review executed scripts...")
- Includes WHAT the agent does AND WHEN to use it
- No angle brackets in description text

---

### 10. Token Budget

| Metric | Target | Hard Limit |
|--------|--------|------------|
| Agent file length | 400-700 lines | Never exceed 1000 |
| Inline code blocks | Minimize where possible | Extract to `agent_reference/` only if shared across multiple agents; single-agent code stays in agent file |
| Examples per pattern | 1 representative | Link additional examples |

---

## Verification Script

After writing an agent, verify all standards are met:

```bash
AGENT_FILE=".claude/agents/[agent-name].md"

# Check for required sections
echo "=== Required Sections ==="
grep -c "## Identity\|Core Distinction\|## Inputs\|## Core Behaviors\|## Protocol\|## Output Format\|## Consumers\|## Boundaries\|STOP Conditions\|## Anti-Patterns\|## Quality Standards\|## Invocation" "$AGENT_FILE"
# Expected: 12 (one per section)

# Check standardized elements
echo "=== Standardized Elements ==="
grep -c "HIGH.*MEDIUM.*LOW\|Learning Signal\|BLOCKER.*WARNING\|STOP Conditions\|<anti_patterns>\|<upstream_input>\|<downstream_consumer>" "$AGENT_FILE"
# Expected: 7+ matches

# Check length
echo "=== Length ==="
wc -l "$AGENT_FILE"
# Target: 400-700 lines
```
