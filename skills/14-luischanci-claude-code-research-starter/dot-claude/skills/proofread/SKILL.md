---
name: proofread
description: Run the proofreading protocol on manuscript files. Checks grammar, typos, overflow, consistency, and academic writing quality. Produces a report without editing files.
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

## Proofread Manuscript

Run a comprehensive proofreading review on the specified file. **Do NOT edit any source files** -- produce a report only.

### Steps

1. **Identify target**: Use `$ARGUMENTS` to find the file. If `all`, scan all `.tex` files in the paper folder.

2. **Launch proofreader agent** following the full protocol from `.claude/agents/proofreader.md`.

3. **Check five categories**:
   - **GRAMMAR:** Subject-verb agreement, articles, prepositions, tense consistency
   - **TYPOS:** Misspellings, search-and-replace artifacts, duplicated words
   - **OVERFLOW:** Overfull hbox in LaTeX, long equations without proper breaks
   - **CONSISTENCY:** Citation format, notation, terminology across sections
   - **ACADEMIC QUALITY:** Informal language, missing words, awkward constructions, claims without citations

4. **Save report** to `quality_reports/[filename]_report.md` with:
   - Line number, current text, proposed fix, category, severity for each issue

5. **Present summary**: Total issues, severity breakdown, top 3 critical issues.

### Important
- **NEVER edit source files.** Report only.
- Follow the three-phase protocol in `.claude/rules/proofreading-protocol.md`.
