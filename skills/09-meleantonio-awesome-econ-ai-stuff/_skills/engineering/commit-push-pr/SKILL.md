---
name: commit-push-pr
description: Commit changes, push to remote, and create a pull request. Use for completing features or fixes ready for review.
workflow_stage: engineering
compatibility:
  - claude-code
  - cursor
  - codex
  - gemini-cli
author: Awesome Econ AI Community
version: 1.0.0
disable-model-invocation: true
tags:
  - git
  - github
  - pull-request
---

# Commit, Push, and Create PR

Automate the git workflow for completing a feature or fix.

## Pre-computed Context

Before proceeding, gather this information:
- Current branch: `!git branch --show-current`
- Git status: `!git status --short`
- Recent commits on this branch: `!git log --oneline -5`
- Diff summary: `!git diff --stat`

## Workflow

1. **Review Changes**
   - Check `git status` for all modified/added files
   - Review the diff to understand what's being committed
   - Ensure no sensitive files are staged (.env, credentials, etc.)

2. **Run Pre-commit Checks**
   - Format code: `ruff format .` (if Python files changed)
   - Lint code: `ruff check .` (if Python files changed)
   - Run tests: `pytest` (if tests exist)

3. **Stage and Commit**
   - Stage relevant files: `git add <files>`
   - Create a commit with Conventional Commits format:
     - `feat:` for new features
     - `fix:` for bug fixes
     - `docs:` for documentation
     - `refactor:` for refactoring
     - `test:` for tests
     - `chore:` for maintenance
   - Write a clear, concise commit message focusing on "why"

4. **Push to Remote**
   - Push the branch: `git push -u origin HEAD`
   - If branch doesn't exist on remote, create it

5. **Create Pull Request**
   - Use GitHub CLI: `gh pr create`
   - Include:
     - Clear title summarizing the change
     - Description with summary and context
     - Reference any related issues
   - Add appropriate labels if applicable

## Arguments

Pass a commit message or leave empty for auto-generated message based on changes.

Usage: `/commit-push-pr [optional commit message]`

Example: `/commit-push-pr feat: add user authentication`

## Output

Return the PR URL when complete.
