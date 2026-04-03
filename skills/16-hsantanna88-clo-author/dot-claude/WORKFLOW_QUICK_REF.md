# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates via dependency graph)

---

## The Research Pipeline

```
/discover interview → Research Spec + Domain Profile
    ↓
/discover lit → Literature Synthesis (Librarian + librarian-critic)
    ↓
/discover data → Data Assessment (Explorer + explorer-critic)
    ↓
/strategize → Strategy Memo (Strategist + strategist-critic)
    ↓
/analyze → Scripts + Output (Coder/Data-engineer + coder-critic)
    ↓
/write → Paper Sections (Writer + writer-critic)
    ↓
/review → Weighted Score + Peer Review (domain-referee + methods-referee)
    ↓
/submit → Final Gate (score >= 95, all components >= 80)
```

Enter at any stage. Use `/new-project` for the full pipeline.

---

## The 10 Commands

| Command | What It Does |
|---------|-------------|
| `/new-project [topic]` | Full pipeline: idea to paper (orchestrated) |
| `/discover [interview\|lit\|data]` | Research spec, literature review, or data discovery |
| `/strategize [question]` | Identification strategy + Econometrician review |
| `/analyze [dataset]` | End-to-end analysis: scripts, output, code review |
| `/write [section]` | Draft paper sections + humanizer pass |
| `/review [file]` | Multi-agent quality review + weighted score |
| `/revise [report]` | Route referee comments, draft response letter |
| `/talk [format]` | Beamer presentation from paper (4 formats) |
| `/submit [journal]` | Final gate: score >= 95, all components >= 80 |
| `/tools [subcommand]` | commit, compile, validate-bib, journal, learn, deploy, context |

---

## Quality Gates at a Glance

| Score | Gate | What It Means |
|-------|------|--------------|
| >= 95 | Submission | Ready for top-5 (all components >= 80) |
| >= 90 | PR | Ready to merge (minor polish recommended) |
| >= 80 | Commit | Ready to commit (address major issues before submission) |
| < 80 | **Blocked** | Must fix critical/major issues |
| -- | Advisory | Talks: reported only, non-blocking |

Weighted aggregate: Literature 10% + Data 10% + Identification 25% + Code 15% + Paper 25% + Polish 10% + Replication 5%

---

## I Ask You When

- **Design forks:** "Option A vs. Option B. Which?"
- **Identification choice:** "CS DiD vs. Sun-Abraham for this setting?"
- **Disagreement with referee:** "DISAGREE classification — please review"
- **After 3 strikes:** "Coder and coder-critic can't agree — your call"

## I Just Execute When

- Code fix is obvious (bug, pattern)
- Verification (compilation, tolerance checks)
- Documentation (logs, commits)
- Plotting (per established standards)

---

## Exploration Mode

For experimental work:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check
- See `.claude/rules/content-standards.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.
