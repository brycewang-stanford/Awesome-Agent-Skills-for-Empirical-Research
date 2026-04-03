---
name: submit
description: Submission pipeline — journal targeting, replication package, audit, and final gate. Replaces /submit, /target-journal, /audit-replication, /data-deposit.
argument-hint: "[mode: target | package | audit | final] [journal name (optional)]"
allowed-tools: Read,Grep,Glob,Write,Bash,Task
---

# Submit

Submission pipeline with four modes covering journal selection through final verification.

**Input:** `$ARGUMENTS` — mode keyword, optionally followed by journal name.

---

## Modes

### `/submit target` — Journal Targeting
Get ranked journal recommendations.

**Agent:** Orchestrator (journal selection function)

Considers: contribution fit, methodology fit, audience fit, recent publications, desk rejection risk. Consults .claude/references/domain-profile.md for journal tiers.

Output: Ranked list of 3 target journals with rationale.
Save to `quality_reports/journal_recommendations_[date].md`

### `/submit package` — Build Replication Package
Assemble AEA-compliant replication package.

**Agents:** Coder + Verifier

Produces:
- Master script that runs all analyses end-to-end
- README with data sources, computational requirements, instructions
- Data documentation and codebook
- Organized file structure per AEA standards
Save to `paper/replication/`

### `/submit audit` — Audit Replication Package
Verify replication package completeness.

**Agent:** Verifier (submission mode — 10 checks)

Checks:
1. Master script exists and runs
2. All tables reproduce
3. All figures reproduce
4. README complete
5. Data documentation present
6. Numbered script order
7. Dependencies listed
8. Runtime documented
9. Output paths match paper references
10. No hardcoded paths

### `/submit final [journal]` — Final Submission Gate
Full verification + score enforcement + submission checklist.

Workflow:
1. Run comprehensive review if not done recently
2. Run replication audit
3. Check score gate: aggregate >= 95, all components >= 80
4. If PASS: generate cover letter draft + submission checklist
5. If FAIL: list blocking issues and stop

---

## Principles
- **Score >= 95 + all components >= 80. No exceptions.**
- **Don't skip verification.** Even if reports exist, check they're recent.
- **If it fails, stop.** Don't generate materials for a failing paper.
- **Cover letter is a draft.** User must review before sending.
