---
name: lfg
description: Full autonomous research workflow — brainstorm, plan, implement, review, and document
argument-hint: "[research task, estimation problem, or methodological improvement]"
disable-model-invocation: true
---

Run these 5 slash commands in order. Do not do anything else. Do not stop between steps — complete every step through to the end.

1. `/workflows:brainstorm $ARGUMENTS`
2. `/workflows:plan`
3. `/workflows:work`
4. `/workflows:review`
5. `/workflows:compound`

**Hard gates:**
- Step 2 must not start until step 1 has written a file to `docs/brainstorms/`. If brainstorm produced no file, stop and report.
- Step 3 must not start until step 2 has written a file to `docs/plans/`. If plan produced no file, stop and report.
- Steps 4 and 5 run on whatever step 3 produced. A failed review does not block compound.

Start with step 1 now.
