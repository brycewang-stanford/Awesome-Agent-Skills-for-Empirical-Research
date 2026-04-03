# bayesian-workflow

An opinionated [Agent Skill](https://agentskills.io) for building, diagnosing, and reporting on Bayesian statistical models using PyMC and ArviZ.

Compatible with Claude Code, Kimi Code, Cursor, Gemini CLI, and any agent that supports the [Agent Skills spec](https://agentskills.io/specification).

Full breakdown [here](https://learnbayesstats.com/blog-posts/bayesian-workflow-agent-skill-pymc-arviz).

## What it does

Guides your coding agent through the full Bayesian workflow:

1. **Formulate** the generative story
2. **Specify priors** with documented justifications
3. **Implement in PyMC** using modern best practices (coords, dims, nutpie)
4. **Prior predictive checks** before fitting
5. **Inference** via MCMC (nutpie sampler by default)
6. **Convergence diagnostics** (R-hat, ESS, trace plots, energy plots)
7. **Model criticism** (posterior predictive checks, LOO-PIT calibration)
8. **Prior/likelihood sensitivity** (power-scaling via PSIS)
9. **Model comparison** (LOO-CV, ELPD, stacking weights)
10. **Reporting** with companion analysis notes and audience-adapted reports

The skill enforces guardrails that agents won't apply on their own: 94% HDI, mandatory calibration checks, prior/likelihood sensitivity checks, non-centered parameterizations for hierarchical models, reproducible descriptive seeds, immediate save-to-disk after sampling, and xarray-first data manipulation.

## Install

### Claude Code

Clone and copy the skill into your personal skills directory:

```bash
git clone https://github.com/Learning-Bayesian-Statistics/baygent-skills.git /tmp/baygent-skills
mkdir -p ~/.claude/skills
cp -r /tmp/baygent-skills/bayesian-workflow ~/.claude/skills/
```

For project-level installation (available only in that project), copy into `.claude/skills/` at the project root instead.

### Other compatible agents (Kimi Code, Cursor, etc.)

Clone the repo and copy the skill folder into your agent's skills directory:

```bash
git clone https://github.com/Learning-Bayesian-Statistics/baygent-skills.git /tmp/baygent-skills
cp -r /tmp/baygent-skills/bayesian-workflow/ ~/.config/agents/skills/bayesian-workflow/
```

### PyMC installation

The skill recommends conda-forge / mamba-forge for PyMC and its dependencies:

```bash
mamba install -c conda-forge pymc nutpie arviz arviz-stats preliz
```

## Example prompts

Once installed, just ask your agent naturally:

- *"I have customer churn data with binary outcome plus age, tenure, and monthly spend. Build me a Bayesian logistic regression with uncertainty estimates."*
- *"My model has 47 divergences and R-hat of 1.03. What do I do?"*
- *"I have test scores for 200 students across 15 schools. Some schools only have 5 students. Help me build a hierarchical model."*
- *"Compare these two models and tell me which one to use. I have the InferenceData objects."*
- *"I need to present Bayesian results to my boss who has no stats background."*

## What's included

```
bayesian-workflow/
├── SKILL.md                          # Main workflow instructions
├── main.py                           # Entrypoint for programmatic use
├── pyproject.toml                    # Package metadata
├── references/
│   ├── priors.md                     # Prior selection guide
│   ├── diagnostics.md                # Convergence diagnostics
│   ├── model-criticism.md            # PPC, calibration, LOO-PIT
│   ├── model-comparison.md           # LOO-CV, ELPD, stacking weights
│   ├── hierarchical.md               # Partial pooling, non-centered parameterization
│   ├── sensitivity.md                # Prior/likelihood sensitivity analysis (power-scaling)
│   └── reporting.md                  # Report templates, audience adaptation
└── scripts/
    ├── diagnose_model.py             # Post-sampling diagnostics report
    └── calibration_check.py          # Calibration plots from InferenceData
```

## License

MIT - see [LICENSE](../LICENSE).
