# baygent-skills

A set of skills to call your agent Bayes. Thomas Bayes.

[Agent Skills](https://agentskills.io) for Bayesian modeling, causal inference, and probabilistic thinking. Compatible with Claude Code, Kimi Code, Cursor, Gemini CLI, and any agent that supports the [Agent Skills spec](https://agentskills.io/specification).

## Available skills

| Skill | Description |
|---|---|
| [bayesian-workflow](bayesian-workflow/) | Full Bayesian modeling workflow with PyMC and ArviZ. [Full breakdown](https://learnbayesstats.com/blog-posts/bayesian-workflow-agent-skill-pymc-arviz). |
| [causal-inference](causal-inference/) | Production-grade Bayesian causal inference with PyMC, CausalPy, and DoWhy. [Full breakdown](https://learnbayesstats.com/blog-posts/causal-inference-agent-skill-pymc-causalpy-dowhy). |

More skills coming soon. Issues and PRs are welcome!

## Quick install

### Claude Code

```bash
git clone https://github.com/Learning-Bayesian-Statistics/baygent-skills.git /tmp/baygent-skills
mkdir -p ~/.claude/skills
cp -r /tmp/baygent-skills/bayesian-workflow ~/.claude/skills/
cp -r /tmp/baygent-skills/causal-inference ~/.claude/skills/
```

### Other compatible agents

Clone the repo and copy the skill folders you need into your agent's skills location:

```bash
git clone https://github.com/Learning-Bayesian-Statistics/baygent-skills.git /tmp/baygent-skills
cp -r /tmp/baygent-skills/bayesian-workflow/ ~/.config/agents/skills/bayesian-workflow/
cp -r /tmp/baygent-skills/causal-inference/ ~/.config/agents/skills/causal-inference/
```

> **Note:** causal-inference depends on bayesian-workflow — install both if you want causal inference.

## Philosophy

These skills are **opinionated and workflow-first**. They don't just teach an agent what PyMC functions exist — they enforce a specific sequence of steps (prior predictive checks, diagnostics, calibration, reporting) and guardrails (94% HDI, reproducible seeds, save-to-disk) that produce reliable analyses.

Each skill is focused and lean. Rather than one monolithic skill that covers everything, we build specialized skills that do one thing well:

- **bayesian-workflow** covers the fundamentals that every Bayesian analysis needs.
- **causal-inference** handles causal design, identification, and refutation — delegating the modeling to bayesian-workflow.

## About

Created by [Alexandre Andorra](https://alexandorra.github.io/), host of [Learning Bayesian Statistics](https://www.learnbayesstats.com/).

## License

MIT - see [LICENSE](LICENSE).
