# CLAUDE.md

## Project overview

**baygent-skills** is a collection of Agent Skills for Bayesian modeling, causal inference, and probabilistic thinking. Each skill is a self-contained subfolder following the [Agent Skills spec](https://agentskills.io/specification).

## Repo structure

```
baygent-skills/
├── bayesian-workflow/          # Shipped skill (v1.2)
│   ├── SKILL.md                # Main workflow instructions
│   ├── references/             # Detailed reference docs (priors, diagnostics, sensitivity, etc.)
│   └── scripts/                # Utility scripts (diagnose_model.py, calibration_check.py)
├── causal-inference/           # Shipped skill (v1.0)
│   ├── SKILL.md                # Main workflow instructions (depends on bayesian-workflow)
│   └── references/             # DAGs, quasi-experiments, structural models, refutation, reporting
├── environment.yml             # Mamba/conda env definition (env name: baygent)
├── LICENSE                     # MIT
└── CLAUDE.md                   # This file
```

## Development conventions

### Python environment
- Use the `baygent` mamba env: `conda run -n baygent python <script>`
- Recreate with: `mamba env create -f environment.yml`
- Never use system Python

### Skill structure
Every skill follows the Agent Skills spec:
- `SKILL.md` with YAML frontmatter (name, description, license, metadata)
- `references/` for detailed docs (plural, not `reference/`)
- `scripts/` for utility scripts
- Description must be agent-neutral (no "Claude"-specific language)

### Code style
- PyMC 5+ syntax with coords and dims
- nutpie sampler by default
- Descriptive seeds: `RANDOM_SEED = sum(map(ord, "analysis-name"))`
- xarray-first for InferenceData operations

### Testing
- Eval workspace: `../bayesian-workflow-workspace/` (sibling directory)
- 6 test scenarios covering logistic regression, hierarchical models, divergences, count data, model comparison, prior elicitation
- Benchmark target: 100% with skill vs ~90% without
