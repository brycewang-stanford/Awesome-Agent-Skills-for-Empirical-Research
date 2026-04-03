# Agent Template Walkthrough

> **Purpose:** Section-by-section guidance for writing agents that conform to
> `agent_reference/AGENT_TEMPLATE.md`. For each section: what to write, what NOT
> to write, and which existing agent exemplifies best practice.
>
> **Read alongside:** `agent_reference/AGENT_TEMPLATE.md` (the canonical blueprint)

---

## Section 1: Title and Purpose

**What it is:** The agent's one-sentence identity and invocation type.

**Format:**
```markdown
# [Agent Name] Agent

**Purpose:** [One sentence — what this agent does and why it exists.]

**Invocation:** Via Agent tool with `subagent_type: "[general-purpose | search-agent]"`
```

**Guidance:**
- Title uses H1 (`#`) with agent name in title case + "Agent" suffix
- Purpose is ONE sentence, not a paragraph
- Purpose answers both "what" and "why" — not just "what"

| Good | Bad |
|------|-----|
| "Reviews executed scripts for correctness and methodology alignment, providing independent secondary QA after each Stage 5-8 execution." | "Helps with code review." |
| "Diagnoses execution failures using scientific hypothesis testing when root cause is unclear." | "Handles errors and debugging tasks." |

**Best exemplar:** `code-reviewer.md` — clear purpose with scope and timing.

---

## Section 2: Identity and Philosophy

**What it is:** The agent's worldview, default approach, and differentiation from similar agents.

**Components:**
1. **Identity paragraph** — Second person ("You are..."), ~5 sentences defining expertise and stance
2. **Philosophy maxim** — Quotable, 5-15 words, serves as decision heuristic
3. **Core Distinction table** — REQUIRED, differentiates from the 1-3 most similar agents

**Core Distinction Table (CRITICAL):**

This is the **#1 failure mode in multi-agent systems** — overlapping responsibilities. Before writing, consult `.claude/agents/README.md` for:
- The Agent Index table (Key Distinction column)
- The "Commonly Confused Pairs" subsection

Your Core Distinction table must use this format:

```markdown
### Core Distinction

| Aspect | This Agent | [Most Similar Agent] |
|--------|-----------|---------------------|
| Focus  | [What you care about] | [What they care about] |
| Timing | [When invoked] | [When they're invoked] |
| Output | [What you produce] | [What they produce] |
```

**If you cannot fill this table clearly, the agent may not be distinct enough.** Consider whether the functionality belongs in an existing agent instead.

**Philosophy maxim examples from existing agents:**
- research-executor: "Write first. Execute once. Capture everything."
- code-reviewer: "Trust but verify. Every script passed primary validation — now prove it was the right validation."
- data-verifier: "The analysis is guilty until proven innocent."

**Best exemplar:** `data-verifier.md` — strong adversarial stance with clear philosophy.

---

## Section 3: Upstream Inputs

**What it is:** Explicit contract of what the orchestrator must provide.

**Format:**
```markdown
<upstream_input>

## Inputs

| Input | Source | Required | How Used |
|-------|--------|----------|----------|
| [Input 1] | Orchestrator Agent prompt | Yes | [Specific purpose] |

**Context the orchestrator MUST provide:**
- [ ] [Specific item 1 — e.g., "Script path (absolute)"]
- [ ] [Specific item 2]

</upstream_input>
```

**Guidance:**
- The checklist catches incomplete Agent prompts early — be specific
- Every input must state HOW it's used, not just that it exists
- Include "Required" column — some inputs are optional (e.g., prior QA findings)

**Common mistake:** Listing inputs without explaining how they're used. "Plan path" tells the orchestrator nothing. "Plan path — used to verify transformation aligns with methodology" tells them exactly why it's needed.

**Best exemplar:** `research-synthesizer.md` — most explicit I/O specification.

---

## Section 4: Core Behaviors

**What it is:** 3-7 behavioral principles that guide the agent's decision-making.

**Key distinction:** Behaviors are PRINCIPLES, not STEPS. Steps go in Protocol (Section 5).

| Principle (belongs here) | Step (belongs in Protocol) |
|--------------------------|---------------------------|
| "Always capture pre-state before transforming" | "Step 1: Run shape check on input data" |
| "Never fix code directly — report and recommend" | "Step 3: Write findings to QA report" |

**Guidance:**
- 3-7 numbered principles, each 2-5 sentences
- Hit the "Goldilocks zone" — specific enough to guide, flexible enough to be heuristic
- Include concrete examples or good/bad comparisons where the behavior is non-obvious
- Domain-specific agents should include methodology subsections here

**Common mistake:** Abstract platitudes like "Be thorough and careful." This tells the agent nothing. Instead: "Validate row counts before AND after every join. A join that silently duplicates rows is worse than one that fails, because the duplication propagates undetected."

**Best exemplar:** `research-executor.md` — strong file-first protocol as behavioral principle with concrete guidance.

---

## Section 5: Execution Protocol

**What it is:** Sequential steps for the main execution flow, plus decision trees for branching.

**Degrees of freedom:**
- **High freedom** (text): When multiple valid approaches exist
- **Medium freedom** (pseudocode): When a preferred pattern exists
- **Low freedom** (exact script): When the operation is fragile or must be precise

**Guidance:**
- Sequential steps for the happy path
- Decision trees or tables for branching logic
- Mark which steps are auto-execute vs. require confirmation
- Reference external files rather than inlining large code blocks (progressive disclosure)
- For code-heavy protocols: provide ONE representative example inline, link the rest

**Common mistake:** Mixing principles (Section 4) with protocol steps. If a step starts with "Always..." or "Never...", it's probably a principle.

**Best exemplar:** `code-reviewer.md` — Three-Phase Review Protocol with clear decision points and the Five Lenses framework.

---

## Section 6: Output Format

**What it is:** The exact structure the agent returns to the orchestrator.

**MANDATORY components (every agent):**

1. **Summary** with Status + Severity fields (two-field convention: Status captures outcome, Severity captures impact)
2. **Agent-specific content** (the main findings/results)
3. **Confidence Assessment** (standardized H/M/L — see `cross-agent-standards.md`)
4. **Issues Found** (if any, with severity levels)
5. **Learning Signal** (standardized 5-category — see `cross-agent-standards.md`)
6. **Recommendations** with proceed/revise/escalate decision

**Guidance:**
- Output must be parseable by the orchestrator without ambiguity
- Use tables for structured data, not prose paragraphs
- The Confidence Assessment rationale column must contain REASONING, not labels

| Good rationale | Bad rationale |
|----------------|---------------|
| "3 independent checks confirm row counts match expected range" | "Seems correct" |
| "Join key uniqueness verified but 2.3% null keys require investigation" | "Medium confidence" |

**Best exemplar:** `data-verifier.md` — comprehensive multi-layer output with clear reasoning.

---

## Section 7: Downstream Consumers

**What it is:** Who uses this agent's output and how.

**Format:**
```markdown
<downstream_consumer>

## Consumers

| Consumer | Receives | How They Use It |
|----------|----------|-----------------|
| Orchestrator | Status + Findings | Gate decision (proceed / revise / escalate) |
| [Next Agent] | [Specific fields] | [Specific purpose] |

**Severity-to-Action Mapping:**

| Your Status | Orchestrator Action |
|-------------|-------------------|
| PASSED | Proceed to next stage |
| WARNING | Log for Stage 10 aggregation; proceed |
| BLOCKER | Invoke revision flow (max 2 attempts) |

</downstream_consumer>
```

**Guidance:**
- ALWAYS include the orchestrator as a consumer
- The severity-to-action mapping makes the output contract explicit — no ambiguity
- Think about ALL consumers: orchestrator, next-stage agents, Plan.md, Plan_Tasks.md, STATE.md, LEARNINGS.md

**Common mistake:** Omitting the orchestrator. Every agent's primary consumer is the orchestrator.

---

## Section 8: Boundaries and Error Handling

**What it is:** Three-tier boundary system + STOP conditions + autonomous deviation rules.

**Components:**
1. **Always Do** — Mandatory behaviors, no exceptions
2. **Ask First Before** — Actions requiring orchestrator/user approval
3. **Never Do** — Hard stops, absolute prohibitions
4. **Autonomous Deviation Rules** — What the agent MAY change without asking
5. **STOP Conditions** — Circuit breakers that halt execution

**Guidance:**
- The three-tier system (Always/Ask/Never) is REQUIRED
- STOP Conditions define when the agent MUST halt and escalate
- Use "STOP Conditions" as the section header (standardized terminology)
- STOP format is standardized — see `cross-agent-standards.md`

**Autonomous Deviation Rules pattern:**
```markdown
You MAY deviate without asking for:
- **RULE 1:** Bug fixes — Fix syntax errors, type mismatches, missing imports. Document in output.
- **RULE 2:** Critical functionality — Add validation, error handling if missing. Document.

You MUST ask before:
- Scope expansion
- Methodology changes
- Removing validation
- Skipping checkpoints
```

**Best exemplar:** `research-executor.md` — clear deviation rules with documentation requirements.

---

## Section 9: Anti-Patterns

**What it is:** Agent-specific things NOT to do, with explanations.

**Format:** 4-column table (with `#` numbering) PLUS supplementary DO NOT paragraphs:

```markdown
<anti_patterns>

## Anti-Patterns

| # | Anti-Pattern | Problem | Correct Approach |
|---|--------------|---------|------------------|
| 1 | [Pattern 1] | [Why it's wrong] | [What to do instead] |

**DO NOT [specific prohibition].** [2-3 sentences explaining why and what to do instead.]

</anti_patterns>
```

**Guidance:**
- Minimum 5 anti-patterns, maximum ~20
- Anti-patterns must be SPECIFIC to this agent, not generic programming advice
- "Don't use global variables" is generic → "Don't modify the input parquet file in place" is specific
- The DO NOT paragraphs are for nuanced anti-patterns that need explanation beyond a table row

**Best exemplar:** `code-reviewer.md` — 15 specific anti-patterns with detailed explanations. `notebook-assembler.md` — excellent WRONG/RIGHT comparison examples.

---

## Section 10: Quality and Completion

**What it is:** Measurable completion criteria from both directions (complete/incomplete) plus self-check.

**Format:**
```markdown
## Quality Standards

**This [task] is COMPLETE when:**
1. [ ] [Measurable criterion 1]
2. [ ] [Measurable criterion 2]
3. [ ] [Measurable criterion 3]

**This [task] is INCOMPLETE if:**
- [Failure criterion 1]
- [Failure criterion 2]

### Self-Check

Before returning output, verify:

| Question | If NO |
|----------|-------|
| [Quality question 1] | [Remediation action] |
| [Quality question 2] | [Remediation action] |
```

**Guidance:**
- Minimum 3 COMPLETE criteria, 3 INCOMPLETE criteria, 4 self-check questions
- COMPLETE criteria should be objectively measurable ("All 5 QA checks executed" not "Good quality review")
- Self-check questions should be introspective ("Did I form my own understanding BEFORE checking the Plan?")
- The COMPLETE/INCOMPLETE duality catches quality issues from both directions

**Best exemplar:** `data-verifier.md` — 8 self-check questions with specific remediation actions.

---

## Section 11: Invocation Pattern

**What it is:** A pointer to the canonical invocation template in the appropriate `WORKFLOW_PHASE*.md` file or mode reference file.

**Format:**
```markdown
## Invocation

**Invocation type:** `subagent_type: "[general-purpose | search-agent]"`

See the appropriate `agent_reference/WORKFLOW_PHASE[N]_[NAME].md` for the canonical stage-specific invocation template with full context fields.
For agent landscape context, see `.claude/agents/README.md`.
```

**Guidance:**
- Do NOT include a full Agent() call template — the `agent_reference/WORKFLOW_PHASE*.md` files and mode reference files are the sources of truth for invocation templates
- Specify `subagent_type` so readers know the agent's capability level at a glance
- Reference the relevant WORKFLOW_PHASE file for stage-specific invocation templates (e.g., `WORKFLOW_PHASE3_ACQUISITION.md` for Stage 5-6 agents)
- The invocation template must map to Upstream Inputs (Section 3)

---

## Section 12: References (CONDITIONAL)

**What it is:** External files the agent may need to read, with trigger conditions.

**Include when:** The agent references files outside its own definition.

**Format:**
```markdown
## References

Load on demand — do NOT read all at start:

| File | When to Read | Purpose |
|------|-------------|---------|
| `agent_reference/[file].md` | [Trigger condition] | [What it provides] |
```

**Guidance:**
- Progressive disclosure — reference, don't inline
- State WHEN to read each reference (trigger condition), not just what it contains
- Keep references one level deep from the agent file
- If the agent needs to read another agent's definition, that's a design smell — consider whether the orchestrator should coordinate instead

---

## Section Order Verification

After writing, verify sections appear in this exact order:

| # | Section | Tag Wrapper | Present? |
|---|---------|-------------|----------|
| — | YAML Frontmatter | `---` | [ ] |
| 1 | Title and Purpose | — | [ ] |
| 2 | Identity and Philosophy | — | [ ] |
| 3 | Upstream Inputs | `<upstream_input>` | [ ] |
| 4 | Core Behaviors | — | [ ] |
| 5 | Execution Protocol | — | [ ] |
| 6 | Output Format | — | [ ] |
| 7 | Downstream Consumers | `<downstream_consumer>` | [ ] |
| 8 | Boundaries and Error Handling | — | [ ] |
| 9 | Anti-Patterns | `<anti_patterns>` | [ ] |
| 10 | Quality and Completion | — | [ ] |
| 11 | Invocation Pattern | — | [ ] |
| 12 | References (if applicable) | — | [ ] |
