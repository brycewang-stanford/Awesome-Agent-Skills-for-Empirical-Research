# `skills-codex`

Codex-native mirror of the base ARIS skill set.

## Scope

This package keeps the main `skills/` workflows available for OpenAI Codex CLI.

Recent core workflow follow-up skills mirrored here include:

- `training-check`
- `result-to-claim`
- `ablation-planner`

These skills cover the experiment follow-up chain:

1. monitor training quality early
2. judge what claims the results actually support
3. design reviewer-facing ablations before paper writing

## Install

Copy this directory into your Codex skills path:

```bash
cp -a skills/skills-codex/* ~/.codex/skills/
```

If you also use reviewer overlay packages, install this base package first, then apply the overlay on top.
