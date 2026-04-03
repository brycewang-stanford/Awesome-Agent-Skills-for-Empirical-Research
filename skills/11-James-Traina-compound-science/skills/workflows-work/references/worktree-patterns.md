# Git Worktree Patterns for Parallel Research Work

Manages Git worktrees for isolated parallel research work -- running concurrent estimation specifications, comparing identification strategies side-by-side, or isolating experimental numerical code.

## When to Use Worktrees

- Running multiple long-running estimation specifications in parallel (NFXP vs MPEC vs CCP)
- Comparing identification strategies side-by-side
- Isolating risky numerical experiments from working results
- Running multiple robustness specifications simultaneously
- Concurrent Monte Carlo simulations with different DGP variants

**Default to a new branch** for sequential single-branch work. Use a worktree only when true parallelism is needed.

## Using the Manager Script

**NEVER call `git worktree add` directly.** Always use the `worktree-manager.sh` script.

The script handles critical setup that raw git commands don't:
1. Copies `.env`, `.env.local`, `.env.test`, etc. from main repo
2. Ensures `.worktrees` is in `.gitignore`
3. Creates consistent directory structure

```bash
# CORRECT - Always use the script
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create nfxp-starting-values

# WRONG - Never do this directly
git worktree add .worktrees/nfxp-starting-values -b nfxp-starting-values main
```

## Commands

| Command | Description |
|---------|-------------|
| `create <branch-name> [from-branch]` | Create new worktree (copies .env files automatically; from-branch defaults to main) |
| `list` / `ls` | List all worktrees with status |
| `switch` / `go <name>` | Switch to an existing worktree |
| `copy-env` / `env [name]` | Copy .env files from main repo to worktree |
| `cleanup` / `clean` | Interactively clean up inactive worktrees |

## Directory Structure

```
.worktrees/
+-- blp-nfxp/               # NFXP estimation run
+-- blp-mpec/               # MPEC estimation run
+-- did-staggered-robust/   # Robustness specification
.gitignore (updated to include .worktrees)
```

## Workflow Examples

### Comparing Estimation Methods

```bash
# Run BLP with NFXP:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create blp-nfxp

# In parallel, run MPEC:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create blp-mpec

# And CCP:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create blp-ccp

# List all concurrent runs:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh list

# Switch to check convergence:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh switch blp-nfxp

# After comparing, clean up:
cd .
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh cleanup
```

### Parallel Robustness Specifications

```bash
# Baseline DiD with staggered adoption:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create did-staggered-robust

# Callaway-Sant'Anna:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create did-callaway-santanna

# Sun-Abraham:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create did-sun-abraham
```

### Concurrent Monte Carlo Simulations

```bash
# Baseline DGP with homoskedastic errors:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create mc-dgp-homoskedastic

# Variant with heteroskedastic errors:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create mc-dgp-heteroskedastic

# Variant with weak instruments:
bash ${CLAUDE_PLUGIN_ROOT}/skills/workflows-work/scripts/worktree-manager.sh create mc-dgp-weak-iv
```

## Key Design Principles

- **One manager script** handles all worktree operations
- Worktrees always created from **main** (unless specified)
- Worktrees stored in **.worktrees/** directory
- Branch name becomes worktree name
- **.gitignore** automatically managed
- **Won't remove the current worktree** (safety)
- Worktrees are lightweight (file system links, shared git objects)

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Worktree already exists" | Script asks if you want to switch to it instead |
| "Cannot remove worktree: it is the current worktree" | Switch out first: `cd $(git rev-parse --show-toplevel)` then cleanup |
| .env files missing in worktree | Run `bash .../worktree-manager.sh copy-env <name>` |
| Lost in a worktree? | Run `bash .../worktree-manager.sh list` |

## Integration with /workflows:work

Use a worktree when the plan involves parallel workstreams or the user has multiple active branches. Default to a new branch on the current worktree for sequential work.

```
- Parallel specs (NFXP vs MPEC, multiple robustness runs) -> worktree
- Sequential single-branch work -> create new branch normally
```

The `workflow-coordinator` agent can help decide when parallel worktrees are appropriate versus sequential work.
