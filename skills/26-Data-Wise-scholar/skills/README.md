# Statistical Research Skills

This directory contains 17 specialized Claude skills for statistical methodology research.

## Categories

### Mathematical (4 skills)
- **proof-architect** - Rigorous mathematical proof construction
- **mathematical-foundations** - Core statistical theory
- **identification-theory** - Causal identification analysis
- **asymptotic-theory** - Large-sample behavior and convergence

### Implementation (5 skills)
- **simulation-architect** - Monte Carlo simulation design
- **algorithm-designer** - Statistical algorithm development
- **numerical-methods** - Numerical optimization and integration
- **computational-inference** - Computational statistics methods
- **statistical-software-qa** - R package quality assurance

### Writing (3 skills)
- **methods-paper-writer** - Academic methods paper structure
- **publication-strategist** - Journal targeting and submission
- **methods-communicator** - Technical communication clarity

### Research (5 skills)
- **literature-gap-finder** - Research gap identification
- **cross-disciplinary-ideation** - Cross-field method transfer
- **method-transfer-engine** - Adapting methods across domains
- **mediation-meta-analyst** - Meta-analysis for mediation
- **sensitivity-analyst** - Sensitivity analysis design

## Installation

Skills are installed to `~/.claude/skills/` via symlinks:

```bash
./scripts/install-skills.sh
```

## Skill Structure

Each skill contains:
- `SKILL.md` - Main skill definition with activation triggers
- `examples.md` (optional) - Usage examples
- `references.md` (optional) - Key references

## Benchmark Scores

All skills have been benchmarked and achieve A-grade (90+/100):

| Skill | Score | Grade |
|-------|-------|-------|
| proof-architect | 94.5 | A |
| mathematical-foundations | 91.0 | A |
| identification-theory | 93.0 | A |
| asymptotic-theory | 92.5 | A |
| simulation-architect | 95.0 | A |
| algorithm-designer | 94.0 | A |
| numerical-methods | 93.5 | A |
| computational-inference | 92.0 | A |
| statistical-software-qa | 91.5 | A |
| methods-paper-writer | 94.0 | A |
| publication-strategist | 92.0 | A |
| methods-communicator | 93.0 | A |
| literature-gap-finder | 93.5 | A |
| cross-disciplinary-ideation | 92.0 | A |
| method-transfer-engine | 93.0 | A |
| mediation-meta-analyst | 94.5 | A |
| sensitivity-analyst | 92.5 | A |

## Usage

Skills activate automatically when Claude detects relevant context. For manual activation, reference the skill name in your prompt.

Example:
```
Using the simulation-architect skill, help me design a Monte Carlo study for testing bootstrap confidence intervals.
```
