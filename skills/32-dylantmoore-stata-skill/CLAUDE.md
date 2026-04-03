# stata-skill

Two Stata skills, installable individually or as a bundle via [dylantmoore/claude-plugins](https://github.com/dylantmoore/claude-plugins).

## Skills

| Plugin name | What you get |
|-------------|-------------|
| **stata** | General Stata reference — syntax, data management, econometrics, causal inference, graphics, Mata, 20+ community packages |
| **stata-c-plugins** | C/C++ plugin development — SDK, .ado wrappers, cross-platform builds, performance, Python/R translation |
| **stata-bundle** | Both of the above (installs the whole repo) |

## Repo Structure

```
.claude-plugin/
└── plugin.json                   # Bundle plugin (whole repo = both skills)
skills/                           # Symlinks for bundle installs
├── stata -> ../plugins/stata/skills/stata
└── stata-c-plugins -> ../plugins/stata-c-plugins/skills/stata-c-plugins
plugins/
├── stata/                        # Standalone plugin: stata only
│   ├── .claude-plugin/plugin.json
│   └── skills/stata/             # Actual skill files
│       ├── SKILL.md
│       ├── references/           # 37 topic files
│       └── packages/             # 20 community package guides
└── stata-c-plugins/              # Standalone plugin: c-plugins only
    ├── .claude-plugin/plugin.json
    └── skills/stata-c-plugins/   # Actual skill files
        ├── SKILL.md
        └── references/           # 5 reference files
```

Skill files live in `plugins/*/skills/` (single source of truth). Root `skills/` has symlinks so the bundle resolves both.

## Example Applications

- **[stata-rapidfuzz](https://github.com/dylantmoore/stata-rapidfuzz)** — String similarity and fuzzy matching. Wraps the rapidfuzz-cpp header-only C++ library. Demonstrates the C++ wrapping workflow: vendoring headers, thin `extern "C"` glue, cross-platform static linking.
- **[drf_stata](https://github.com/dylantmoore/drf_stata)** — Distributional Random Forests for Stata. Wraps the R `drf` package's C++ backend (lorismichel/drf). Demonstrates C++ wrapping with pthreads parallelism, XorShift RNG, and correlation-based validation against R.
- **[microimpute_stata](https://github.com/dylantmoore/microimpute_stata)** — High-performance statistical imputation with C plugin acceleration. Multi-method package (QRF, KNN, Neural Network) demonstrating the full plugin lifecycle: dispatcher .ado, multiple C plugins, preserve/merge pattern, cross-platform builds.
- **[ranger_stata](https://github.com/dylantmoore/ranger_stata)** — Random forests for Stata (regression, classification, probability, survival). Wraps the ranger C++ library via `initR()` API. Demonstrates 4-forest-type dispatching, save/load for prediction on new data, and extensive option passthrough (case weights, class weights, regularization, split rules).
- **[grf_stata](https://github.com/dylantmoore/grf_stata)** — Generalized Random Forests for Stata (Athey, Tibshirani, Wager). Wraps the grf C++ backend (grf-labs/grf, v2.5.0). 12 forest types (causal, instrumental, quantile, survival, etc.), 7 post-estimation commands (ATE, BLP, RATE, tuning), 335+ test cases. Demonstrates large-scale C++ wrapping with nuisance estimation pipelines, cross-validation tuning in .ado, and comprehensive option-level test coverage.
- **[splink_stata](https://github.com/dylantmoore/splink_stata)** — Probabilistic record linkage for Stata. C plugin implementation of the Fellegi-Sunter model, matching the feature set of Python splink. Demonstrates pure C plugin development (no C++ wrapping), EM parameter estimation, and multi-config validation against Python reference outputs.

## Conventions

- SKILL.md files must stay under 500 lines (hard limit for skills)
- Descriptions in YAML frontmatter must stay under 1024 characters
- No Mata content in the C plugins skill — if performance matters, go straight to C
- Reference files are pulled in on demand, so put detailed content there, not in SKILL.md
- The `stata` skill covers Mata adequately for anyone who actually wants it

## Usage Measurement (Future)

To measure how often skills get triggered, add a `PreToolUse` hook that logs whenever Claude loads a skill file (i.e., calls `Read` on a file inside `skills/`). This gives signal on which reference files are actually used vs. dead weight. Not implemented yet — just a hook away when needed.
