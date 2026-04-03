# Gate Mode Example Output

Example outputs from `uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode gate --venue ieee`.

---

## Example 1: FAIL

# Quality Gate Report

**File**: `paper.tex` | **Language**: EN | **Mode**: gate
**Generated**: 2026-03-11T14:45:00 | **Venue**: ieee

---

## Verdict: FAIL

**2 blocking issue(s) and 3 failed checklist item(s) prevent submission.**

---

## Blocking Issues (must fix)

| # | Module | Line | Issue |
|---|--------|------|-------|
| 1 | REFERENCES | — | Undefined reference: `tab:comparison` referenced but no `\label{tab:comparison}` found |
| 2 | PSEUDOCODE | 144 | IEEE-safe pseudocode should not use floating algorithm environments; wrap algorithmic content in a figure instead. |

---

## Pre-Submission Checklist

- [x] No placeholder text (TODO, FIXME, XXX)
- [x] All figures referenced in text
- [ ] All tables referenced in text — Unreferenced: {'tab:hyperparams'}
- [x] Anonymous submission (blind review check)
- [x] Consistent math notation
- [x] Acronyms defined on first use
- [ ] Abstract word limit (250 words for IEEE) — Abstract has 287 words (limit: 250)
- [x] [IEEE] Keywords section present
- [ ] [IEEE] No floating pseudocode environment used — IEEE-safe pseudocode should not use floating algorithm environments; wrap algorithmic content in a figure instead.
- [ ] [IEEE] Pseudocode blocks have caption and label — Pseudocode figure is missing a caption. IEEE-style algorithm blocks should carry a figure caption.
- [x] [IEEE] Pseudocode blocks are referenced before appearing

---

## Non-Blocking Issues (informational)

| # | Module | Line | Severity | Issue |
|---|--------|------|----------|-------|
| 1 | BIB | — | Major | Entry `wang2024` has mismatched year (bib: 2024, cited text mentions 2023) |
| 2 | FORMAT | 89 | Minor | Inconsistent figure caption style: some end with period, others don't |
| 3 | FIGURES | — | Minor | Figure 3 resolution below 300 DPI (estimated 220 DPI) |
| 4 | PSEUDOCODE | 151 | Minor | Line numbers were not detected. They are recommended for IEEE-like review but not required. |

---

*Gate verdict: resolve all blocking issues and failed checklist items before submission.*

---

---

## Example 2: PASS

# Quality Gate Report

**File**: `paper_v2.tex` | **Language**: EN | **Mode**: gate
**Generated**: 2026-03-11T15:00:00 | **Venue**: ieee

---

## Verdict: PASS

**No blocking issues. All checklist items passed. Paper is ready for submission.**

---

## Pre-Submission Checklist

- [x] No placeholder text (TODO, FIXME, XXX)
- [x] All figures referenced in text
- [x] All tables referenced in text
- [x] Anonymous submission (blind review check)
- [x] Consistent math notation
- [x] Acronyms defined on first use
- [x] Abstract word limit (250 words for IEEE) — Abstract has 231 words
- [x] Keywords count (3-5 for IEEE) — Found 4 keywords
- [x] [IEEE] Keywords section present
- [x] [IEEE] No floating pseudocode environment used
- [x] [IEEE] Pseudocode blocks have caption and label
- [x] [IEEE] Pseudocode blocks are referenced before appearing

---

## Non-Blocking Issues (informational)

| # | Module | Line | Severity | Issue |
|---|--------|------|----------|-------|
| 1 | FORMAT | 156 | Minor | Widow line at top of page 6 |
| 2 | BIB | — | Minor | Entry `chen2023` missing optional `doi` field |
| 3 | PSEUDOCODE | 188 | Minor | Line numbers were not detected. They are recommended for IEEE-like review but not required. |

---

*Gate verdict: PASS. 2 non-blocking minor issues noted for optional improvement.*
