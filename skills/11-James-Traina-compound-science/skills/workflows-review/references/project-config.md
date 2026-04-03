# Project Configuration Reference

Configure `compound-science.local.md` to control which agents run during `/workflows:review`, `/workflows:work`, and `/workflows:compound`, and to set project-wide defaults for estimation language, project type, and data handling.

## Quick Start

For most projects, auto-detection handles everything. If no config file exists, workflow commands use defaults for `empirical-paper` with `python`.

## Agent Configuration by Project Type

**Empirical paper** (default -- most common):
```yaml
review_agents:
  - econometric-reviewer
  - numerical-auditor
  - identification-critic
  - reproducibility-auditor
plan_review_agents:
  - econometric-reviewer
  - identification-critic
```

**Methodology paper:**
```yaml
review_agents:
  - mathematical-prover
  - identification-critic
  - journal-referee
  - numerical-auditor
plan_review_agents:
  - mathematical-prover
  - identification-critic
```

**Empirical (data analysis without paper):**
```yaml
review_agents:
  - econometric-reviewer
  - numerical-auditor
  - data-detective
plan_review_agents:
  - econometric-reviewer
```

**Software package** (estimation library, simulation toolkit):
```yaml
review_agents:
  - numerical-auditor
  - econometric-reviewer
plan_review_agents:
  - numerical-auditor
```

**General** (fallback):
```yaml
review_agents:
  - econometric-reviewer
  - numerical-auditor
plan_review_agents:
  - econometric-reviewer
```

## Config File Template

```markdown
---
# compound-science Configuration

# Review agents run during /workflows:review
review_agents:
  - econometric-reviewer
  - numerical-auditor
  - identification-critic
  - reproducibility-auditor

# Agents for /workflows:plan review phase
plan_review_agents:
  - econometric-reviewer
  - identification-critic

# Estimation language (auto-detected)
estimation_language: python

# Project type: empirical-paper | methodology-paper | empirical | software-package | general
project_type: empirical-paper

# Data sensitivity: public | restricted | confidential
data_sensitivity: public

# Additional agents to include in /workflows:review (beyond defaults)
# extra_review_agents:
#   - journal-referee
#   - mathematical-prover

# Agents to exclude from default review set
# exclude_review_agents:
#   - reproducibility-auditor
---

# Research Context

Add project-specific instructions here. These notes are passed to all review agents during /workflows:review and /workflows:work.

Examples:
- "We exploit variation in minimum wage changes across states -- check parallel trends carefully"
- "Panel data with N=500 firms, T=20 years -- cluster at firm level"
- "BLP demand estimation -- convergence is the main concern, use tight tolerance"
- "Replication package for AEA submission -- strict reproducibility requirements"
```

## Configuration Options Reference

| Field | Type | Default | Valid Values | Description |
|---|---|---|---|---|
| `review_agents` | list | (per project type) | Any agent name from compound-science | Agents run during `/workflows:review` |
| `plan_review_agents` | list | (per project type) | Any agent name | Agents that review plans in `/workflows:plan` |
| `estimation_language` | string | (auto-detected) | `python`, `r`, `julia`, `stata` | Default language for code generation |
| `project_type` | string | (auto-detected) | `empirical-paper`, `methodology-paper`, `empirical`, `software-package`, `general` | Controls which agents are most relevant |
| `data_sensitivity` | string | `public` | `public`, `restricted`, `confidential` | Affects data handling suggestions |
| `extra_review_agents` | list | `[]` | Any agent name | Added on top of defaults |
| `exclude_review_agents` | list | `[]` | Any agent name | Removed from defaults |

## How Config Is Read

Workflow commands read `compound-science.local.md` at startup:

1. **`/workflows:review`** -- reads `review_agents` to decide which agents to launch in parallel
2. **`/workflows:plan`** -- reads `plan_review_agents` for the plan review phase
3. **`/workflows:work`** -- reads `estimation_language` for code generation defaults
4. **`/workflows:compound`** -- reads all settings for solution documentation routing
5. **`/estimate`** -- reads `estimation_language` and any `estimate_override` agents
6. **`numerical-auditor` agent** -- reads `estimation_language` for simulation code generation
7. **SessionStart hook** -- reads `project_type` to set environment context

## Project Type Behavior

**empirical-paper:**
- Review emphasizes identification, standard errors, and reproducibility
- Stop hook checks for: clustered SEs, convergence diagnostics, seed documentation

**methodology-paper:**
- Review emphasizes proof correctness and mathematical rigor
- Stop hook checks for: regularity conditions, proof completeness

**empirical:**
- Review emphasizes data quality and estimation correctness
- Lighter pipeline requirements

**software-package:**
- Review emphasizes numerical correctness and edge cases
- Stop hook checks for: test coverage, docstrings, numerical precision

## Data Sensitivity Levels

| Level | Behavior |
|---|---|
| `public` | No restrictions. Data paths can be logged, shared in docs |
| `restricted` | Data paths noted but actual data values never included in solution docs or commit messages |
| `confidential` | Solution docs reference data structure only. Pipeline suggestions use synthetic data for testing |

## Per-Command Agent Overrides

Override agents for specific commands:

```yaml
---
review_agents:
  - econometric-reviewer
  - numerical-auditor

# Override for /workflows:review only
review_override:
  - econometric-reviewer
  - numerical-auditor
  - identification-critic
  - journal-referee
  - reproducibility-auditor

# Override for /estimate only
estimate_override:
  - econometric-reviewer
  - numerical-auditor
---
```

## Conditional Agents

Add agents that only run when certain conditions are met:

```yaml
---
conditional_agents:
  journal-referee:
    when: "*.tex files exist or docs/paper/ directory exists"
  reproducibility-auditor:
    when: "Makefile or Snakefile or dvc.yaml exists"
  mathematical-prover:
    when: "proof or derivation files detected"
---
```

## Multi-Language Projects

```yaml
---
estimation_language: python
secondary_languages:
  - r        # For robustness checks in fixest
  - stata    # For legacy code comparison
---
```
