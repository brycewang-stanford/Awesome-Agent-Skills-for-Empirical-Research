---
name: tools
description: Utility commands — commit, compile, validate-bib, journal, context-status, deploy, learn. Replaces individual utility skills.
argument-hint: "[subcommand: commit | compile | validate-bib | journal | context | deploy | learn | upgrade] [args]"
allowed-tools: Read,Grep,Glob,Write,Edit,Bash,Task
---

# Tools

Utility subcommands for project maintenance and infrastructure.

**Input:** `$ARGUMENTS` — subcommand followed by any arguments.

---

## Subcommands

### `/tools commit [message]` — Git Commit
Stage changes, create commit, optionally create PR and merge.
- Run git status to identify changes
- Stage relevant files (never stage .env or credentials)
- Create commit with descriptive message
- If quality score available and >= 80, note in commit

### `/tools compile [file]` — LaTeX Compilation
3-pass XeLaTeX + bibtex compilation.

For papers:
```bash
cd Paper && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode [file]
BIBINPUTS=..:$BIBINPUTS bibtex [file_base]
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode [file]
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode [file]
```

For talks:
```bash
cd Talks && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode [file]
```

### `/tools validate-bib` — Bibliography Validation
Cross-reference all \cite{} keys in paper and talk files against Bibliography_base.bib.
Report: missing entries, unused entries, duplicate keys.

### `/tools journal` — Research Journal
Regenerate the research journal timeline from quality reports and git history.
Shows chronological record of agent actions, phase transitions, scores, decisions.

### `/tools context` — Context Status
Show current context status and session health.
Check context usage, whether auto-compact is approaching, what state will be preserved.

### `/tools deploy` — Deploy Guide Site
Render Quarto guide site and publish to GitHub Pages.
```bash
cd guide && quarto publish gh-pages --no-browser
```

### `/tools learn` — Extract Learnings
Extract reusable knowledge from the current session. Auto-memory handles corrections automatically; this is for multi-step workflows worth turning into a full skill.

### `/tools upgrade` — Upgrade Clo-Author Infrastructure
Upgrade an existing project to the latest clo-author architecture.

**What it does:**
1. Clone the latest clo-author release into a temp directory
2. Save the user's filled-in domain-profile.md and any custom journal profiles
3. Delete the old `.claude/` directory
4. Copy the new `.claude/` in
5. Restore the user's domain-profile.md and custom journal profiles
6. Optionally copy new `templates/`
7. Report what changed

**Workflow:**
```
Step 1: DOWNLOAD
  - Clone latest clo-author into /tmp/clo-author-upgrade
  - Or: gh release download --repo hugosantanna/clo-author

Step 2: PRESERVE USER CUSTOMIZATIONS
  - Save .claude/references/domain-profile.md if filled in (not just placeholders)
  - Save any custom journal profiles the user added to journal-profiles.md
  - Save .claude/settings.json (user's permissions and hooks)
  - Save .claude/settings.local.json if it exists

Step 3: REPLACE
  - Delete old .claude/ entirely
  - Copy new .claude/ from the downloaded release
  - Restore saved customizations from Step 2

Step 4: DO NOT TOUCH
  - paper/, scripts/, data/, explorations/, quality_reports/
  - CLAUDE.md, Bibliography_base.bib, README.md, .gitignore
  - Any other user content

Step 5: REPORT
  - List what was updated (new agents, skills, rules)
  - List what was preserved (domain profile, settings, custom profiles)
  - Clean up temp directory
```

**No git merge. No upstream remote. No conflicts.** Just delete and replace `.claude/`.

---

## Principles
- **Each subcommand is lightweight.** No multi-agent orchestration needed.
- **Compile always uses 3-pass.** Ensures references and citations resolve.
- **validate-bib catches drift.** Run before commits to catch broken citations.
- **Upgrade preserves content.** Infrastructure changes, your paper doesn't.
