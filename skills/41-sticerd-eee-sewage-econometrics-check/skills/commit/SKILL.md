---
name: commit
description: Stage, commit, and push changes for the sewage project. Creates a branch, commits with a descriptive message, pushes, and optionally creates a PR. This skill should be used when asked to "commit", "save changes", "push", or "create a PR".
argument-hint: "[optional: commit message]"
allowed-tools: ["Bash", "Read", "Glob"]
---

# Commit and Push

Stage changes, commit with a descriptive message, and push to remote.

## Steps

1. **Check current state:**

```bash
git status
git diff --stat
git log --oneline -5
```

2. **Create a branch** from current state:

```bash
git checkout -b <short-descriptive-branch-name>
```

3. **Stage files** — add specific files (never use `git add -A`):

```bash
git add <file1> <file2> ...
```

Do NOT stage:
- `.claude/settings.local.json`
- Any files containing secrets or API keys
- Large data files (anything in `data/`)
- Temporary files (anything in `data/temp/`)

4. **Commit** with a descriptive message:

If `$ARGUMENTS` is provided, use it as the commit message. Otherwise, analyse the staged changes and write a message that explains *why*, not just *what*.

```bash
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

5. **Push and optionally create PR:**

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points>

## Test plan
<checklist>
EOF
)"
```

6. **Merge and clean up** (only if user confirms):

```bash
gh pr merge <pr-number> --merge --delete-branch
git checkout main
git pull
```

7. **Report** the PR URL and what was merged.

## Important

- Always create a NEW branch — never commit directly to main
- Exclude data files, temp files, and secrets from staging
- Use `--merge` (not `--squash` or `--rebase`) unless asked otherwise
- If the commit message from `$ARGUMENTS` is provided, use it exactly
- Follow existing commit message style (see recent `git log`)
