---
name: commit
description: Stage, commit, create PR, and merge to main. Use for the standard commit-PR-merge cycle.
argument-hint: "[optional: commit message]"
allowed-tools: ["Bash", "Read", "Glob"]
---

# Commit, PR, and Merge

Stage changes, commit with a descriptive message, create a PR, and merge to main.

## Steps

1. **Check current state:**

```bash
git status
git diff --stat
git log --oneline -5
```

2. **Create a branch** from the current state:

```bash
git checkout -b <short-descriptive-branch-name>
```

3. **Stage files** — add specific files (never use `git add -A`):

```bash
git add <file1> <file2> ...
```

Do NOT stage `.claude/settings.local.json` or any files containing secrets.

4. **Commit** with a descriptive message:

If `$ARGUMENTS` is provided, use it as the commit message. Otherwise, analyze the staged changes and write a message that explains *why*, not just *what*.

```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

5. **Push and create PR:**

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Test plan
<checklist>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

6. **Merge and clean up:**

```bash
gh pr merge <pr-number> --merge --delete-branch
git checkout main
git pull
```

7. **Report** the PR URL and what was merged.

## Important

- Always create a NEW branch — never commit directly to main
- Exclude `settings.local.json` and sensitive files from staging
- Use `--merge` (not `--squash` or `--rebase`) unless asked otherwise
- If the commit message from `$ARGUMENTS` is provided, use it exactly
