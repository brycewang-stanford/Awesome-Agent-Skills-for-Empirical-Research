---
name: commit
description: Stage, commit, create PR, and merge to main. Use for the standard commit-PR-merge cycle.
disable-model-invocation: true
argument-hint: "[optional: commit message]"
allowed-tools: ["Bash", "Read", "Glob"]
---

## Commit Workflow

Perform the full commit-PR-merge cycle.

### Steps

1. **Check current state**:
   ```bash
   git status
   git diff --stat
   git log --oneline -5
   ```

2. **Create branch**: `git checkout -b [descriptive-branch-name]`

3. **Stage files**:
   - Stage specific files (never `git add -A`)
   - Exclude: `settings.local.json`, `.env`, credentials, large data files
   - Review what's being staged

4. **Commit**:
   - Use `$ARGUMENTS` as commit message if provided
   - Otherwise, analyze changes and write a descriptive message
   - Format: imperative mood, concise, explains WHY not WHAT

5. **Push and create PR**:
   ```bash
   git push -u origin [branch-name]
   gh pr create --title "[message]" --body "[summary of changes]"
   ```

6. **Merge** (with user approval):
   ```bash
   gh pr merge --merge --delete-branch
   git checkout main
   git pull
   ```

### Important
- Never commit directly to main
- Never use `git add -A` or `git add .`
- Never commit sensitive files
- Always review staged changes before committing
