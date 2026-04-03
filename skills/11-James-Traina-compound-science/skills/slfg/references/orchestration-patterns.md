# Swarm Orchestration Patterns

## Overview

Swarm orchestration coordinates multiple Claude agents working in parallel on research tasks. The system provides **teams** (named groups with a leader and teammates), **tasks** (a shared work queue with dependencies), and **inboxes** (JSON-based inter-agent messaging). You (the leader) create a team, spawn teammates, assign work via tasks, collect results from inboxes, and shut down cleanly.

## Quick Start

```javascript
// 1. Create team
Teammate({ operation: "spawnTeam", team_name: "iv-estimation" })

// 2. Spawn a teammate
Task({
  team_name: "iv-estimation",
  name: "econometric-reviewer",
  subagent_type: "compound-science:review:econometric-reviewer",
  prompt: "Review src/estimators/ for identification and standard error issues. Send findings to team-lead via Teammate write.",
  run_in_background: true
})

// 3. Check results in your inbox
// cat ~/.claude/teams/iv-estimation/inboxes/team-lead.json

// 4. Shutdown and cleanup
Teammate({ operation: "requestShutdown", target_agent_id: "econometric-reviewer" })
// Wait for shutdown_approved message...
Teammate({ operation: "cleanup" })
```

---

## Two Ways to Spawn Agents

**Subagent (no team)** -- short-lived, returns result directly:
```javascript
Task({
  subagent_type: "Explore",
  description: "Find estimator files",
  prompt: "Find all estimation-related files in this codebase",
  model: "haiku"
})
```

**Teammate (with team)** -- persistent, communicates via inbox:
```javascript
Task({
  team_name: "my-team",
  name: "numerical-auditor",
  subagent_type: "compound-science:review:numerical-auditor",
  prompt: "Audit simulation code for convergence issues. Send findings to team-lead.",
  run_in_background: true
})
```

| Aspect | Subagent | Teammate |
|--------|----------|----------|
| Lifespan | Until task complete | Until shutdown requested |
| Communication | Return value | Inbox messages |
| Task access | None | Shared task list |
| Coordination | One-off | Ongoing |

### Available Agent Types

**Built-in:** `Bash`, `Explore` (read-only, fast), `Plan` (read-only), `general-purpose` (all tools)

**compound-science review agents:** `econometric-reviewer`, `mathematical-prover`, `numerical-auditor`, `identification-critic`, `journal-referee`

**compound-science research agents:** `literature-scout`, `methods-explorer`, `data-detective`

**compound-science workflow agents:** `reproducibility-auditor`, `workflow-coordinator`

Plugin agents use prefix format: `compound-science:review:econometric-reviewer`, `compound-science:research:literature-scout`, etc.

---

## Pattern 1: Parallel Review Swarm

Launch multiple specialist reviewers simultaneously, collect findings, synthesize.

```javascript
// 1. Create team
Teammate({ operation: "spawnTeam", team_name: "estimation-review" })

// 2. Spawn all reviewers in parallel (send all Task calls in one message)
Task({
  team_name: "estimation-review",
  name: "econometric-reviewer",
  subagent_type: "compound-science:review:econometric-reviewer",
  prompt: `Review estimation code for methodological correctness.
  Focus on: standard errors, endogeneity, functional form, sample selection.
  Send findings to team-lead via Teammate write.`,
  run_in_background: true
})

Task({
  team_name: "estimation-review",
  name: "numerical-auditor",
  subagent_type: "compound-science:review:numerical-auditor",
  prompt: `Review code for numerical issues.
  Focus on: optimizer convergence, floating-point precision, RNG seeding, matrix conditioning.
  Send findings to team-lead via Teammate write.`,
  run_in_background: true
})

Task({
  team_name: "estimation-review",
  name: "identification-critic",
  subagent_type: "compound-science:review:identification-critic",
  prompt: `Review identification strategy.
  Focus on: exclusion restrictions, parallel trends, SUTVA violations, external validity.
  Send findings to team-lead via Teammate write.`,
  run_in_background: true
})

// 3. Collect results from inbox, synthesize findings
// 4. Shutdown all teammates, then cleanup
Teammate({ operation: "requestShutdown", target_agent_id: "econometric-reviewer" })
Teammate({ operation: "requestShutdown", target_agent_id: "numerical-auditor" })
Teammate({ operation: "requestShutdown", target_agent_id: "identification-critic" })
// Wait for shutdown_approved messages...
Teammate({ operation: "cleanup" })
```

## Pattern 2: Sequential Research Pipeline

Each stage depends on the previous. Tasks auto-unblock as dependencies complete.

```javascript
// 1. Create team and task pipeline
Teammate({ operation: "spawnTeam", team_name: "estimation-pipeline" })

TaskCreate({ subject: "Research IV methods", description: "Survey literature on IV estimation with heterogeneous treatment effects", activeForm: "Researching..." })
TaskCreate({ subject: "Create estimation plan", description: "Design estimation strategy based on literature findings", activeForm: "Planning..." })
TaskCreate({ subject: "Implement estimator", description: "Implement IV estimator with robust standard errors", activeForm: "Implementing..." })
TaskCreate({ subject: "Run Monte Carlo validation", description: "Validate estimator bias, coverage, and size via simulation", activeForm: "Simulating..." })
TaskCreate({ subject: "Final methodology review", description: "Review complete pipeline for identification and numerical issues", activeForm: "Reviewing..." })

// Set sequential dependencies
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "3", addBlockedBy: ["2"] })
TaskUpdate({ taskId: "4", addBlockedBy: ["3"] })
TaskUpdate({ taskId: "5", addBlockedBy: ["4"] })

// 2. Spawn specialized workers -- each waits for its task to unblock
Task({
  team_name: "estimation-pipeline",
  name: "researcher",
  subagent_type: "compound-science:research:literature-scout",
  prompt: "Claim task #1. Research IV estimation with heterogeneous effects. Mark complete and send summary to team-lead.",
  run_in_background: true
})

Task({
  team_name: "estimation-pipeline",
  name: "planner",
  subagent_type: "Plan",
  prompt: "Wait for task #2 to unblock. Read research from task #1. Create detailed estimation strategy. Mark complete.",
  run_in_background: true
})

Task({
  team_name: "estimation-pipeline",
  name: "implementer",
  subagent_type: "general-purpose",
  prompt: "Wait for task #3 to unblock. Read plan. Implement the IV estimator with proper standard errors. Mark complete.",
  run_in_background: true
})

Task({
  team_name: "estimation-pipeline",
  name: "simulator",
  subagent_type: "general-purpose",
  prompt: "Wait for task #4 to unblock. Write Monte Carlo simulations to validate estimator properties. Mark complete with results.",
  run_in_background: true
})

Task({
  team_name: "estimation-pipeline",
  name: "reviewer",
  subagent_type: "compound-science:review:numerical-auditor",
  prompt: "Wait for task #5 to unblock. Review the complete pipeline for numerical stability. Send final assessment to team-lead.",
  run_in_background: true
})
```

## Pattern 3: Coordinated Estimation

Workers self-organize around a pool of independent tasks, racing to claim and complete them.

```javascript
// 1. Create team and task pool (all independent, no dependencies)
Teammate({ operation: "spawnTeam", team_name: "file-review-swarm" })

for (const file of [
  "src/estimators/iv_2sls.py",
  "src/estimators/panel_fe.py",
  "src/data/sample_construction.py",
  "src/simulations/monte_carlo.py",
  "src/utils/standard_errors.py"
]) {
  TaskCreate({
    subject: `Review ${file}`,
    description: `Review ${file} for methodological correctness and numerical stability`,
    activeForm: `Reviewing ${file}...`
  })
}

// 2. Spawn worker swarm with self-organizing prompt
const swarmPrompt = `
You are a swarm worker. Loop:
1. Call TaskList() to see available tasks
2. Find a pending, unowned, unblocked task
3. Claim it: TaskUpdate({ taskId: "X", owner: "YOUR_NAME" })
4. Start it: TaskUpdate({ taskId: "X", status: "in_progress" })
5. Do the review work
6. Complete it: TaskUpdate({ taskId: "X", status: "completed" })
7. Send findings to team-lead via Teammate write
8. Repeat until no tasks remain, then send idle notification
Replace YOUR_NAME with $CLAUDE_CODE_AGENT_NAME.
`

Task({ team_name: "file-review-swarm", name: "worker-1", subagent_type: "general-purpose", prompt: swarmPrompt, run_in_background: true })
Task({ team_name: "file-review-swarm", name: "worker-2", subagent_type: "general-purpose", prompt: swarmPrompt, run_in_background: true })
Task({ team_name: "file-review-swarm", name: "worker-3", subagent_type: "general-purpose", prompt: swarmPrompt, run_in_background: true })

// Workers race to claim tasks, naturally load-balance
```

---

## Operations Reference

### Create Team

```javascript
Teammate({
  operation: "spawnTeam",
  team_name: "iv-estimation",
  description: "Implementing instrumental variables estimator with diagnostics"
})
```

### Spawn Teammate

```javascript
Task({
  team_name: "iv-estimation",
  name: "econometric-reviewer",
  subagent_type: "compound-science:review:econometric-reviewer",
  prompt: "Review estimation code. Send findings to team-lead via Teammate write.",
  run_in_background: true
})
```

### Create Task

```javascript
TaskCreate({
  subject: "Review estimation module",
  description: "Review all files in src/estimators/ for methodological correctness",
  activeForm: "Reviewing estimation module..."  // Shown in spinner
})
```

### Task Dependencies and Updates

```javascript
// Set up dependency chain
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })   // #2 waits for #1

// Claim a task
TaskUpdate({ taskId: "2", owner: "econometric-reviewer" })

// Start and complete
TaskUpdate({ taskId: "2", status: "in_progress" })
TaskUpdate({ taskId: "2", status: "completed" })    // Auto-unblocks dependents
```

### Send Message

```javascript
// To one teammate
Teammate({
  operation: "write",
  target_agent_id: "econometric-reviewer",
  value: "Please prioritize the IV estimation module."
})

// To all teammates (expensive -- sends N messages for N teammates)
Teammate({
  operation: "broadcast",
  name: "team-lead",
  value: "Status check: report your progress."
})
```

### Shutdown and Cleanup

```javascript
// 1. Request shutdown for each teammate
Teammate({ operation: "requestShutdown", target_agent_id: "econometric-reviewer", reason: "All tasks complete" })

// 2. Wait for shutdown_approved messages in your inbox

// 3. Clean up team resources (fails if teammates still active)
Teammate({ operation: "cleanup" })
```

**As a teammate receiving a shutdown request**, you MUST call:
```javascript
Teammate({ operation: "approveShutdown", request_id: "shutdown-123" })
```

### Other Operations

| Operation | Purpose | Who |
|-----------|---------|-----|
| `discoverTeams` | List joinable teams | Any |
| `requestJoin` | Request to join existing team | Any |
| `approveJoin` / `rejectJoin` | Handle join requests | Leader |
| `approvePlan` / `rejectPlan` | Handle plan approval requests | Leader |
| `rejectShutdown` | Decline shutdown (still working) | Teammate |

---

## Spawn Backends

Claude Code auto-detects the best backend for running teammates:

| Backend | When Used | Visibility |
|---------|-----------|------------|
| **in-process** | Default (no tmux/iTerm2) | Hidden |
| **tmux** | Inside tmux session, or tmux available | Visible in tmux panes |
| **iterm2** | In iTerm2 with `it2` CLI installed | Visible in split panes |

Force a backend: `export CLAUDE_CODE_SPAWN_BACKEND=tmux`

---

## Environment Variables

Spawned teammates automatically receive:
```bash
CLAUDE_CODE_TEAM_NAME="iv-estimation"
CLAUDE_CODE_AGENT_ID="econometric-reviewer@iv-estimation"
CLAUDE_CODE_AGENT_NAME="econometric-reviewer"
CLAUDE_CODE_AGENT_TYPE="compound-science:review:econometric-reviewer"
```

---

## Key Message Types

Messages arrive in your inbox as JSON objects. The important structured types:

| Type | Meaning | Action |
|------|---------|--------|
| `shutdown_request` | Leader asks you to exit | Call `approveShutdown` or `rejectShutdown` |
| `shutdown_approved` | Teammate confirmed exit | Safe to cleanup if all approved |
| `idle_notification` | Teammate finished and is idle | Assign more work or shut down |
| `task_completed` | Teammate completed a task | Check results, manage pipeline |
| `plan_approval_request` | Teammate needs plan approved | Call `approvePlan` or `rejectPlan` |

---

## Anti-Patterns

- **Forgetting cleanup**: Always `requestShutdown` all teammates, wait for approvals, then `cleanup`. Orphaned teams leak resources.
- **Calling cleanup with active teammates**: `cleanup` fails if teammates are still running. Shut them down first.
- **Using broadcast for targeted messages**: `broadcast` sends N messages for N teammates. Use `write` to specific teammates.
- **Vague worker prompts**: "Review the code" gives poor results. Specify exact files, focus areas, and how to report findings.
- **Manual polling instead of task dependencies**: Use `TaskUpdate({ taskId: "3", addBlockedBy: ["2"] })` instead of telling workers to "check every 30 seconds if task #2 is done."
- **Skipping `run_in_background: true` for teammates**: Without it, the leader blocks waiting for the teammate to finish, defeating the purpose of parallel execution.
- **Using generic names**: Name teammates by role (`econometric-reviewer`, `monte-carlo-runner`) not by number (`worker-1`, `worker-2`) -- unless using a self-organizing swarm.
- **Text output instead of Teammate write**: A teammate's text output is NOT visible to the team. All inter-agent communication MUST use `Teammate({ operation: "write", ... })`.

---

## Debugging

```bash
# Check team members
cat ~/.claude/teams/{team}/config.json | jq '.members[] | {name, agentType, backendType}'

# Read your inbox
cat ~/.claude/teams/{team}/inboxes/team-lead.json | jq '.'

# Check task states
cat ~/.claude/tasks/{team}/*.json | jq '{id, subject, status, owner, blockedBy}'
```

| Error | Cause | Fix |
|-------|-------|-----|
| "Cannot cleanup with active members" | Teammates still running | `requestShutdown` all first |
| "Already leading a team" | Team exists | `cleanup` first or use different name |
| "Agent not found" | Wrong teammate name | Check `config.json` for actual names |
| "Team does not exist" | No team created | Call `spawnTeam` first |
