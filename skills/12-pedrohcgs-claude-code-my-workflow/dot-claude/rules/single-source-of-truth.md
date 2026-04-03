---
paths:
  - "Figures/**/*"
  - "Quarto/**/*.qmd"
  - "Slides/**/*.tex"
---

# Single Source of Truth: Enforcement Protocol

**The Beamer `.tex` file is the authoritative source for ALL content.** Everything else is derived.

## The SSOT Chain

```
Beamer .tex (SOURCE OF TRUTH)
  ├── extract_tikz.tex → PDF → SVGs (derived)
  ├── Quarto .qmd → HTML (derived)
  ├── Bibliography_base.bib (shared)
  └── Figures/LectureN/*.rds → plotly charts (data source)

NEVER edit derived artifacts independently.
ALWAYS propagate changes from source → derived.
```

---

## TikZ Freshness Protocol (MANDATORY)

**Before using ANY TikZ SVG in a Quarto slide, verify it matches the current Beamer source.**

### Diff-Check Procedure

1. Read the TikZ block from the Beamer `.tex` file
2. Read the corresponding block from `Figures/LectureN/extract_tikz.tex`
3. Compare EVERY coordinate, label, color, opacity, and anchor point
4. If ANY difference exists: update `extract_tikz.tex` from Beamer, recompile, regenerate SVGs
5. Only then reference the SVG in the QMD

### When to Re-Extract

Re-extract ALL TikZ diagrams when:
- The Beamer `.tex` file has been modified since last extraction
- Starting a new Quarto translation
- Any TikZ-related quality issue is reported
- Before any commit that includes QMD changes

---

## Environment Parity (MANDATORY)

**Every Beamer environment MUST have a CSS equivalent before translation begins.**

1. Scan the Beamer source for all custom environments
2. Check each against your theme SCSS file
3. If ANY environment is missing from SCSS, create it BEFORE translating

---

## Content Fidelity Checklist

```
[ ] Frame count: Beamer frames == Quarto slides
[ ] Math check: every equation appears with identical notation
[ ] Citation check: every \cite has a @key in Quarto
[ ] Environment check: every Beamer box has CSS equivalent
[ ] Figure check: every \includegraphics has SVG or plotly equivalent
[ ] No added content: Quarto does not invent slides not in Beamer
[ ] No dropped content: every Beamer idea appears in Quarto
```
