---
name: estimate
description: "Run a structural estimation pipeline — routes to /workflows:work with estimation context from empirical-playbook"
argument-hint: "<estimation specification or task>"
disable-model-invocation: true
---

This command routes to `/workflows:work` with estimation pipeline context.

Before starting, load the `empirical-playbook` skill and its `references/estimation-pipeline.md` for the phased estimation workflow (data validation → identification → estimation → standard errors → robustness → results).

Now run `/workflows:work` with the estimation pipeline framing. Follow the phase gates in `estimation-pipeline.md` — do not proceed to the next phase until the current phase's gate conditions are met.
