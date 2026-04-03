---
name: agent-authoring
description: >-
  Guide for creating DAAF agent definition files. Covers 12-section template, hook registration, skills-in-frontmatter, integration checklist. Use when adding or revising agents. For SKILL.md files, use skill-authoring instead.
metadata:
  audience: any-agent
  domain: skill-development
---

# Agent Authoring

Guide for creating new DAAF agent definition files with full ecosystem integration. Covers the 12-section agent template, cross-agent consistency standards, per-agent hook registration, skills-in-frontmatter assignment, and the complete integration checklist for wiring new agents into documentation. Use when adding a new specialized agent, revising agent structure, configuring per-agent hooks, or verifying agent integration completeness. For creating SKILL.md files (not agent definition files), use skill-authoring instead.

Create new DAAF agents that conform to the canonical template and are fully wired into the system documentation for discoverability and usability.

## What This Skill Does

- Guides creation of agent `.md` files conforming to `agent_reference/AGENT_TEMPLATE.md` (12 mandatory sections)
- Ensures cross-agent consistency (standardized confidence model, Learning Signal, STOP format, etc.)
- Provides a **complete integration checklist** covering every file that references agents across the codebase to ensure it is discoverable and its invocation patterns are well-understood by the system agents
- Complements `skill-authoring`: this skill handles the behavioral protocol file; if the new agent also needs a companion skill, invoke `skill-authoring` separately

## Decision Tree: What Do You Need?

```
What are you doing?
│
├─ Creating a brand-new agent
│   └─ Follow "New Agent Workflow" below
│
├─ Revising an existing agent to match the template
│   └─ Read: references/template-walkthrough.md
│          + agent_reference/AGENT_TEMPLATE.md (the canonical blueprint)
│
├─ Checking if an agent is fully integrated into the ecosystem
│   └─ Read: references/integration-checklist.md
│
├─ Understanding what must be identical across all agents
│   └─ Read: references/cross-agent-standards.md
│
└─ Understanding the current agent landscape before adding to it
    └─ Read: .claude/agents/README.md (Agent Index + "Commonly Confused Pairs")
```

## New Agent Workflow

### Phase 1: Design (before writing)

Before beginning, you MUST have a clear, coherent, and compelling answer to each of the following questions:

1. **Define the role** in one sentence — what does this agent do and why does it exist?
2. **Identify pipeline stage(s)** — which stage(s) does it operate in, or is it "any/on-demand"?
3. **Identify similar agents** — read `.claude/agents/README.md` (Agent Index + "Commonly Confused Pairs") to find the 1-3 most similar existing agents. You MUST differentiate from these in your Core Distinction table.
4. **Determine subagent type:**
   - `general-purpose` — needs file writes, code execution, or tool access beyond reading
   - `Plan` — read-only validation, discovery, or verification
5. **Determine skill dependencies** — will this agent need to invoke any skills?
6. **Determine hook requirements** — will this agent need per-agent hooks? (see "Per-Agent Hooks" below)

If any of these answers are vague, in doubt, or incomplete, the quality and reliability of the ensuing agent file will suffer. If the agent authoring process has been initiated by the user, make sure to ask these questions directly, and ask follow-up questions to enhance the quality of their responses as you go. Before proceeding to Phase 2, make sure the user agrees with your enhanced answers explicitly.

### Phase 2: Author (write the definition)

1. Read `agent_reference/AGENT_TEMPLATE.md` for the canonical 12-section structure
2. Read `references/template-walkthrough.md` for section-by-section guidance and common mistakes
3. Read `references/cross-agent-standards.md` for mandatory standardized elements
4. Write the agent file to `.claude/agents/[agent-name].md` following the template exactly
5. Run self-validation:
   - [ ] All 12 sections present (11 REQUIRED + 1 CONDITIONAL)
   - [ ] Core Distinction table differentiates from identified similar agents
   - [ ] Confidence Assessment uses standardized H/M/L model with rationale
   - [ ] Learning Signal uses standardized 5-category model
   - [ ] Anti-patterns in 4-column table format (# | Anti-Pattern | Problem | Correct Approach) (minimum 5)
   - [ ] STOP Conditions use standardized format
   - [ ] Invocation Pattern shows complete Agent() syntax with BASE_DIR
   - [ ] COMPLETE criteria: minimum 3
   - [ ] INCOMPLETE criteria: minimum 3
   - [ ] Self-Check has minimum 4 questions
   - [ ] Total length 400-700 lines (flag if approaching 800+)
   - [ ] Large inline code blocks minimized (extract to `agent_reference/` only if shared across agents)
   - [ ] Per-agent hooks registered in frontmatter if agent executes Python (see "Per-Agent Hooks" below)

### Phase 3: Integrate (wire into the ecosystem)

1. Read `agent_reference/FRAMEWORK_INTEGRATION_CHECKLIST.md` § 2 for the canonical checklist of registration points
2. Execute all [M] (mandatory) items — A1-A5, A14
3. Review and execute applicable [C] (conditional) items — A6-A13, A15-A16
4. Run cross-cutting consistency checks (§ 6) — count words, cross-references, naming
5. For supplementary walkthrough detail, also consult `references/integration-checklist.md`

### Phase 4: Validate (confirm completeness)

Run these verification checks:

```bash
# 1. Verify agent appears in all registry files
grep -l "agent-name" .claude/agents/README.md CLAUDE.md README.md

# 2. Cross-agent consistency (run for new agent file)
grep -c "HIGH.*MEDIUM.*LOW\|BLOCKER.*WARNING.*INFO\|Learning Signal\|STOP Conditions" .claude/agents/[agent-name].md

# 3. Verify agent count matches actual count
ls .claude/agents/*.md | grep -v README | grep -v _revised | wc -l
# Compare with the number in README.md "Agent Ecosystem (N Specialized Agents)"
```

### Phase 5: Human review

Before any agent authoring process is fully complete, a human user MUST review it for accuracy, intention, completeness, and value. When Phase 4 is complete, you MUST ask the user for review, providing as many details, file references, and decision points as possible to ensure full clarity for their awareness and revision if needed.

## Quick Reference: Current Agent Landscape

Consult `.claude/agents/README.md` for the authoritative Agent Index with:
- Agent name, purpose, subagent type, stage(s), and key distinction
- Commonly Confused Pairs (critical for writing your Core Distinction)
- Agent Coordination Matrix (producer/consumer relationships)
- Invocation patterns for every agent

## Reference Files

| File | When to Read | Purpose |
|------|-------------|---------|
| `references/template-walkthrough.md` | Writing or revising an agent | Section-by-section guidance for AGENT_TEMPLATE.md |
| `references/integration-checklist.md` | After writing, during Phase 3 | Complete list of files to update |
| `references/cross-agent-standards.md` | During writing, for consistency | Mandatory identical elements across all agents |

## Relationship to Other Skills and Resources

| Resource | Relationship |
|----------|-------------|
| `skill-authoring` skill | Invoke separately if the new agent also needs a companion skill |
| `agent_reference/AGENT_TEMPLATE.md` | The structural blueprint — read directly during Phase 2 |
| `agent_reference/PLAN_TEMPLATE.md` | Reference for wave-based task sequencing and plan structure |
| `.claude/agents/README.md` | The single source of truth for the agent landscape — read during Phase 1 |
| `data-ingest` agent | Related: creates new data source skills; agent-authoring creates new agents |

## Per-Agent Hooks

Agents can register hooks in their YAML frontmatter that fire only when that agent
is active. This is distinct from project-wide hooks in `settings.json` which fire
for all contexts.

**When to use per-agent hooks vs project-wide hooks:**

| Scope | Register in | Example |
|-------|-------------|---------|
| All agents, all contexts | `settings.json` | `bash-safety.sh` (destructive command prevention) |
| Specific agents only | Agent frontmatter `hooks` field | `enforce-file-first.sh` (file-first protocol for coding agents) |

**Current per-agent hook: `enforce-file-first.sh`**

Any agent that writes and executes Python scripts via `run_with_capture.sh` MUST
register this hook. It blocks direct `python`/`python3` invocations, enforcing the
file-first execution protocol at the hook layer.

Agents that need it: those with `Bash` in `tools` that execute Python scripts
(currently: research-executor, code-reviewer, debugger, data-ingest).

Agents that do NOT need it: read-only agents (`permissionMode: plan`), agents that
don't execute Python (report-writer, notebook-assembler), and the orchestrator.

**Frontmatter syntax:**

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/.claude/hooks/enforce-file-first.sh"
          timeout: 5
```

**Hook authoring conventions:**
- Hook scripts live in `.claude/hooks/` and are protected by deny rules (`Edit(.claude/hooks/*)`, `Write(.claude/hooks/*)`) — human-only deployment
- Use `exit 2` with stderr message to block Bash commands (convention from `bash-safety.sh`)
- Use JSON `permissionDecision: deny` output for Agent/Task tool hooks (convention from `enforce-explore-model.sh`)
- Fail-closed design: ERR trap should block, not allow
- Verify dependencies (e.g., `jq`) explicitly rather than relying on fallbacks that silently degrade

## Skills in Agent Frontmatter

Agents can preload skills via the `skills` frontmatter field. The skill is loaded
into the agent's context when it starts, providing domain knowledge without
requiring the agent to invoke the Skill tool.

**Syntax:**

```yaml
# Single skill
skills: data-scientist

# Multiple skills (YAML block list — matches official Claude Code docs)
skills:
  - data-scientist
  - polars
```

The full skill content is injected into the agent's context at startup. The agent
does NOT need to call the Skill tool for preloaded skills — doing so would load
the content a second time and waste context tokens.

**When to assign skills to an agent:**
- The agent routinely needs the skill's domain knowledge (e.g., all coding agents preload `data-scientist`)
- The skill provides methodology or conventions the agent must follow (not just reference data)
- The skill is small enough to fit without consuming excessive context

**When NOT to assign skills:**
- The agent only occasionally needs the skill — let it invoke via the Skill tool on demand instead
- The skill is large (e.g., data source skills with extensive reference tables) — on-demand loading is more context-efficient
- The skill is for a different domain than the agent's core responsibility

**Current skill assignments:**

| Skill | Assigned to |
|-------|-------------|
| `data-scientist` | research-executor, code-reviewer, debugger, data-ingest, data-planner, plan-checker, data-verifier, source-researcher, research-synthesizer, integration-checker, report-writer, notebook-assembler |
| `marimo` | notebook-assembler |

## Naming Convention

- **File:** `.claude/agents/[lowercase-hyphenated].md`
- **Frontmatter name:** `lowercase-hyphenated` (must match directory/file convention)
- **Title:** `# [Agent Name] Agent` (title case with "Agent" suffix)
- **Description:** Third person, includes WHAT the agent does AND WHEN to use it
