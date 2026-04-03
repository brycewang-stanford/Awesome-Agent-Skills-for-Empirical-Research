# Logging

## Session Report
Append to `SESSION_REPORT.md` at end of session or before context compression.
**Rules:** Append only. Bullet points. Include file paths and commit hashes when available.
Create the file if it doesn't exist: `# Session Report — [Project Name]`

**Entry format:**
```markdown
## YYYY-MM-DD HH:MM — [Brief Title]

**Operations:**
- [Scripts run, files created/modified/deleted]

**Decisions:**
- [Choice made] — [rationale]

**Results:**
- [Key findings, outputs produced]

**Commits:**
- `[hash]` [commit message]

**Status:**
- Done: [what's complete]
- Pending: [what remains]
```

## Research Journal
Append to `quality_reports/research_journal.md` whenever an agent completes work — writing code, drafting a section, producing a review, making an editorial decision, or transitioning between phases.
**Rules:** Append only. One entry per agent invocation. Include phase transitions and editorial decisions.

**Entry format:**
```markdown
### YYYY-MM-DD HH:MM — [Agent Name]
**Phase:** [Discovery/Strategy/Execution/Peer Review/Presentation]
**Target:** [file or topic]
**Score:** [XX/100 or PASS/FAIL or N/A]
**Verdict:** [one line — key finding or decision]
**Report:** [path to full report]
```
**Why it exists:** Agents read this to understand pipeline state — the editor checks what strategist-critic scored, the orchestrator checks which phases passed, the coder-critic checks what the coder built. It's the shared context across agents.

Agent outputs (reports, scripts, memos, decisions) are saved to `quality_reports/` by the skills that produce them.
