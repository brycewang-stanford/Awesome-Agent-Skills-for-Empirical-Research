---
name: slfg
description: Full autonomous research workflow using swarm mode for parallel execution
argument-hint: "[research task, estimation problem, or methodological improvement]"
disable-model-invocation: true
---

Swarm-enabled LFG. Run these steps in order, parallelizing where indicated. Do not stop between steps — complete every step through to the end.

## Sequential Phase

1. `/workflows:brainstorm $ARGUMENTS`
   **Gate:** must produce a file in `docs/brainstorms/` before proceeding.

2. `/workflows:plan`
   **Gate:** must produce a file in `docs/plans/` before proceeding.

3. `/workflows:work` — **Use swarm mode**: Break the plan into independent tasks and launch parallel subagents via Task tool to build them concurrently. Each subagent handles one task from the plan. See `references/orchestration-patterns.md` for parallel dispatch patterns.
   **Gate:** must produce at least one code change (committed or staged) before proceeding. If work fails with no changes, stop and report the failure.

## Parallel Phase

After work completes, launch steps 4 and 5 as **parallel swarm agents** (both only need completed code to operate):

4. `/workflows:review` — spawn as background Task agent
5. `/workflows:compound` — spawn as background Task agent

Wait for both to complete before finishing.

## Output

When all steps are done, output:

```
Research workflow complete.

Brainstorm: [brainstorm file path]
Plan: [plan file path]
Work: [summary of implementation]
Review: [summary of findings]
Documentation: [docs/solutions/ path if created]
```

Start with step 1 now.
