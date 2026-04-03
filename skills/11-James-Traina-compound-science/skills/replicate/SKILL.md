---
name: replicate
description: "Build and verify replication packages — routes to reproducibility-auditor agent"
argument-hint: "<project directory or replication target>"
disable-model-invocation: true
---

This command routes to the `reproducibility-auditor` agent, which performs both structural checks (seeds, versions, paths, pipeline integrity) and functional checks (reproduction, data documentation, environment, output matching).

Run the `reproducibility-auditor` agent on the current project.
