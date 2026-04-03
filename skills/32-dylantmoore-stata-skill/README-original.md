# Stata Skills for Claude Code

This project contains two Claude Code skills:

1. **Stata** — A comprehensive reference that tells Claude how to use Stata. Covers core syntax, data management, econometrics, causal inference, graphics, and 20+ community packages.

2. **Stata C Plugins** — A skill that tells Claude how to make Stata code that uses C plugins to do things. It includes information that Claude can use to translate existing packages into C plugins that can be called from Stata. This is very useful because it means you can do things in Stata that you wouldn't otherwise be able to do very easily.

As long as you can find an existing package somewhere, you can just let Claude go look at the existing Python package and this skill provides a workflow that Claude can use to develop a replication of whatever it is, implemented in Python or R or whatever, that runs in Stata and uses a C plugin. In many if not most cases, you should be able to get something that runs at least as fast in Stata as it did in the original language, if not faster.

## Installation

Add this repo as a marketplace in Claude Code:

```
/plugin marketplace add dylantmoore/stata-skill
```

Then install whichever option fits your needs:

| Plugin | Command |
|--------|---------|
| Stata reference only | `/plugin install stata` |
| C plugin development only | `/plugin install stata-c-plugins` |
| Both skills | `/plugin install stata-bundle` |

You can also find this and other plugins via the [claude-plugins](https://github.com/dylantmoore/claude-plugins) collection.

## What's Included

### Skill 1: Stata

**37 core reference files** covering:
- Data import/export, management, and cleaning
- Linear regression, panel data, time series
- Limited dependent variables, survival analysis, SEM
- Causal inference: DiD, RD, matching, treatment effects
- Mata programming and matrix operations
- Graphics, tables, and reporting
- Workflow best practices

**20 community package guides** including:
- `reghdfe` — high-dimensional fixed effects
- `estout` / `outreg2` — publication-quality tables
- `csdid`, `did_multiplegt` — modern DiD estimators
- `rdrobust` — regression discontinuity
- `psmatch2` — propensity score matching
- `synth` — synthetic control
- `ivreg2` / `xtabond2` — IV and dynamic panel GMM
- And more (binsreg, coefplot, grstyle, winsor2, gtools, ...)

### Skill 2: Stata C Plugins

**Reference files** covering:
- Stata plugin SDK (`stplugin.h`) setup and data flow
- Memory safety, debugging, and common failure modes
- `.ado` wrapper patterns (preserve/merge, plugin loading)
- Cross-platform compilation (macOS, Linux, Windows)
- Performance optimization (pthreads, pre-sorted indices, XorShift RNG)
- Packaging and distribution via `net install`
- Translation workflow for porting Python/R packages to Stata
- Testing strategy with correlation-based validation against reference implementations

## How It Works

Both skills use **progressive disclosure**: a compact SKILL.md file loaded on activation directs Claude to read only the reference files relevant to the current task. This keeps context usage efficient while giving Claude access to detailed reference documents when needed.

## Coverage

| Category | Files | Topics |
|----------|-------|--------|
| Data Operations | 7 | Import, management, strings, dates, math functions |
| Statistics | 10 | Regression, panel, time series, MLE, GMM, survey, MI |
| Causal Inference | 5 | DiD, RD, matching, treatment effects, selection |
| Advanced Methods | 5 | Survival, SEM, nonparametric, spatial, ML/lasso |
| Programming | 6 | Do-files, macros, loops, Mata |
| Output & Workflow | 3 | Tables, reporting, best practices, external tools |
| Packages | 20 | Community-contributed packages |
| C Plugins | 4 | SDK patterns, performance, packaging, translation |

## Contributing

This repo is also a good place to learn about building Claude Code skills. The [ROADMAP.md](ROADMAP.md) lists open problems around testing, progressive disclosure, and dynamic documentation that apply to skill development in general — not just Stata.

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add documentation for new Stata packages. Pull requests welcome!

## Disclaimer

This reference material is derived in part from Stata's official documentation and community package documentation. No copyright is claimed. Stata is a registered trademark of StataCorp LLC. This project is not affiliated with or endorsed by StataCorp.
