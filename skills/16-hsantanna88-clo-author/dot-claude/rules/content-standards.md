---
paths:
  - "**/*.R"
  - "**/*.py"
  - "**/*.jl"
  - "**/*.do"
  - "**/*.tex"
  - "paper/tables/**"
  - "paper/figures/**"
  - "master_supporting_docs/**"
  - "explorations/**"
---

# Content Standards: Tables, Figures, PDFs, and Explorations

---

## 1. Table Standards

**Target:** Publication-quality tables matching AER, QJE, and Econometrica formatting.

### No In-Table Titles or Notes

- **Never** embed titles inside the table body or as a table header row
- **Never** embed notes, sources, or footnotes inside the table itself
- Table numbering, titles, and notes are added in LaTeX via `\caption{}` and `\begin{tablenotes}`
- The file name and folder identify what the table contains

### Three-Line Format (Booktabs)

Every table uses exactly three horizontal rules and **zero vertical lines**:

```latex
\begin{table}[htbp]
\centering
\begin{tabular}{lcccc}
\toprule
            & (1)     & (2)     & (3)     & (4)     \\
\midrule
...coefficients...
\bottomrule
\end{tabular}
\end{table}
```

- `\toprule` above column headers
- `\midrule` below column headers (and to separate panels)
- `\bottomrule` at the very end
- `\cmidrule(lr){2-4}` for partial rules spanning column groups
- **Use `threeparttable`** — wrap tables with `\begin{threeparttable}` for proper alignment of notes via `\begin{tablenotes}`
- **Never** use `\hline`, `|`, or any vertical rules

### Coefficient Display

- Point estimates on one row, standard errors in parentheses on the row below
- Stars for significance: `*` p < 0.10, `**` p < 0.05, `***` p < 0.01
- Align significance note at the bottom: `\textit{Notes:} * p < 0.10, ** p < 0.05, *** p < 0.01`
- Standard errors labeled in the note (e.g., "Robust standard errors in parentheses" or "Clustered at municipality level")

```
Treatment        & 0.045**  & 0.038*   & 0.052*** \\
                 & (0.021)  & (0.020)  & (0.019)  \\
```

### Column and Row Structure

- **Column (1), (2), ...** headers in the first row after `\toprule`
- **Dependent variable** stated in a spanning header or the first subheader row
- **Variable names** left-aligned, human-readable (not raw R variable names)
  - `Log wages` not `ln_wage_deflated`
  - `Female` not `sex_2`
  - `Years of education` not `educ_yrs`
- **Numeric columns** right-aligned or decimal-aligned
- **N**, **R²**, **Fixed effects** (Yes/No), **Controls** (Yes/No) at the bottom before `\bottomrule`

### Panel Structure

For tables with multiple panels:

```latex
\multicolumn{5}{l}{\textit{Panel A: Full sample}} \\
\midrule
...
\\[0.5em]
\multicolumn{5}{l}{\textit{Panel B: Male workers}} \\
\midrule
...
```

- Panel labels in italics, left-aligned, spanning all columns
- `\midrule` after each panel label
- Small vertical space (`\\[0.5em]`) between panels

### Preferred R Packages

**Primary: `modelsummary`**

```r
library(modelsummary)

modelsummary(
  models,
  output   = "latex_tabular",  # bare tabular, no wrapper
  stars    = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_rename = c(
    "treatment"  = "Treatment",
    "log_income" = "Log income"
  ),
  gof_map = c("nobs", "r.squared", "adj.r.squared"),
  escape  = FALSE
)
```

**Alternative: `fixest::etable`**

```r
fixest::etable(
  models,
  tex      = TRUE,
  style.tex = style.tex(
    main     = "aer",
    depvar.title = "",
    fixef.title  = "",
    yesNo    = c("Yes", "No")
  ),
  se.below = TRUE,
  signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10)
)
```

**For summary / descriptive tables: `kableExtra`**

```r
library(kableExtra)

kbl(df, format = "latex", booktabs = TRUE, escape = FALSE,
    align = c("l", rep("c", ncol(df) - 1))) |>
  kable_styling(latex_options = "hold_position")
```

### Typography

- Serif font throughout (inherits from document class — no extra commands needed)
- `\small` or `\footnotesize` for tables that need to fit within column width
- Variable names in plain text, panel labels in `\textit{}`
- Never bold table body content; bold only for rare emphasis in headers

### Export

```r
# Write .tex fragment (no \begin{table} wrapper -- added in main.tex)
writeLines(tex_output, file.path("paper/tables", "reg_main_specification.tex"))
```

- Output **bare `tabular` environment** (no `\begin{table}` float)
- The paper's `main.tex` wraps it with `\begin{table}`, `\caption{}`, and `\input{}`
- Write to `paper/tables/`

### File Naming

```
tables/
├── descriptive/
│   ├── sumstats_main_sample.tex
│   └── balance_treatment_control.tex
├── estimation/
│   ├── reg_main_specification.tex
│   ├── reg_heterogeneity_gender.tex
│   └── did_event_study_coefficients.tex
└── robustness/
    └── reg_alternative_controls.tex
```

Pattern: `{table_type}_{content_description}.tex`

- `sumstats_` for summary statistics
- `balance_` for balance / pre-treatment tests
- `reg_` for regression output
- `did_` for difference-in-differences specific tables
- `first_stage_` for IV first stage

### Prohibited Patterns

| Pattern | Reason |
|---------|--------|
| Title row inside the table | Titles go in `\caption{}`, not the table body |
| Notes embedded in table body | Notes go below via `\begin{tablenotes}` |
| `\hline` | Use `\toprule` / `\midrule` / `\bottomrule` (booktabs) |
| Vertical rules (`\|` in column spec) | Never used in economics journals |
| `stargazer` package | Deprecated workflow; use `modelsummary` or `fixest::etable` |
| Raw variable names in labels | Human-readable labels required |
| `xtable` without booktabs | Produces non-journal-quality output |
| `\begin{table}` in R output | R exports bare `tabular`; float wrapper lives in `main.tex` |

### Table Type Templates

Use these as defaults. Adapt columns based on the paper's needs (e.g., add Min/Max, percentiles, or subgroup columns when substantively important).

**Descriptive Statistics:**
```
\toprule
                        &  Mean   &  SD     \\
\midrule
\multicolumn{3}{l}{\textit{Continuous variables}} \\
\quad Wages (USD)       &  45,230 &  12,400 \\
\quad Years of education&  13.2   &  2.8    \\
\quad Age               &  38.5   &  11.2   \\
\\[0.5em]
\multicolumn{3}{l}{\textit{Categorical variables (\%)}} \\
\quad Female            &  48.2   &         \\
\quad College degree    &  32.5   &         \\
\bottomrule
```
- Default: Mean and SD in separate columns (never stacked with parentheses — that's for regression SEs)
- Categorical/binary: percentage in Mean column, SD blank
- Sample size stated once in table notes, not as a column
- Add Min/Max only when the range is substantively important (RDD bandwidth, data coverage)

**Regression Results:**
```
\toprule
                        &  (1)    &  (2)    &  (3)    &  (4)    \\
                        &  OLS    &  OLS    &  IV     &  IV     \\
\midrule
Treatment               &  0.045**&  0.038* &  0.052**&  0.041* \\
                        & (0.021) & (0.020) & (0.025) & (0.022) \\
\midrule
Controls                &  No     &  Yes    &  No     &  Yes    \\
Fixed Effects           &  No     &  Yes    &  No     &  Yes    \\
Observations            &  10,000 &  10,000 &  10,000 &  10,000 \\
R$^2$                   &  0.05   &  0.12   &         &         \\
\bottomrule
```
- Coefficients on one row, standard errors in parentheses below
- Stars: `*` p < 0.10, `**` p < 0.05, `***` p < 0.01
- Bottom rows: Controls (Yes/No), Fixed Effects (Yes/No), Observations, R²

**Multi-Outcome (Panel Structure):**
```
\toprule
                        &  (1)    &  (2)    &  (3)    &  (4)    \\
\midrule
\multicolumn{5}{l}{\textit{Panel A: Wages}} \\
\midrule
Treatment               &  0.045**&  0.038* &  0.052**&  0.041* \\
                        & (0.021) & (0.020) & (0.025) & (0.022) \\
\\[0.5em]
\multicolumn{5}{l}{\textit{Panel B: Employment}} \\
\midrule
Treatment               &  0.021  &  0.033* &  0.015  &  0.028  \\
                        & (0.018) & (0.017) & (0.020) & (0.019) \\
\midrule
Controls                &  No     &  Yes    &  No     &  Yes    \\
Fixed Effects           &  No     &  Yes    &  No     &  Yes    \\
Observations            &  10,000 &  10,000 &  10,000 &  10,000 \\
\bottomrule
```
- Each outcome gets its own panel with same column structure
- Panel labels in italics, left-aligned, spanning all columns
- Controls/FE/Observations rows appear once at the bottom (shared across panels)

**Balance Table:**
```
\toprule
Variable                &  Treatment &  Control &  Difference &  SE     &  p-value \\
\midrule
Wages (USD)             &  45,800    &  44,650  &  1,150      &  (890)  &  0.197   \\
Years of education      &  13.4      &  13.1    &  0.3        &  (0.2)  &  0.134   \\
Female (\%)             &  47.8      &  48.6    &  -0.8       &  (1.2)  &  0.505   \\
\bottomrule
```

**Robustness:**
```
\toprule
                        &  (1)        &  (2)           &  (3)          &  (4)            \\
                        &  Baseline   &  Alt. controls &  Alt. sample  &  Alt. estimator \\
\midrule
```
- Column headers describe what changes across specifications
- Same outcome variable across all columns

---

## 2. Figure Standards

- **Never add titles or subtitles inside ggplot** — use `labs(title = NULL, subtitle = NULL)`
- **Figure information goes in two places:**
  1. **File name** — descriptive, e.g., `fig1_hispanic_enrollment_ascm.pdf`
  2. **LaTeX `\caption{}`** — the authoritative title, numbered and editable without re-running R
- **Panel labels are the exception** — "Panel A: Employment" inside multi-panel figures (via `patchwork`, `cowplot`, etc.) is fine since they identify sub-panels, not the whole figure
- **Axis labels must be publication-quality** — "Employment Rate" not "emp_rate". Clean labels stay in the figure; titles and context go in the caption
- **Use serif fonts** — figures should match the paper's body text. In ggplot, set `theme(text = element_text(family = "serif"))` or use `theme_minimal(base_family = "serif")`
- **Show all years on the x-axis** when the panel spans ~20 years or fewer — use `scale_x_continuous(breaks = min_year:max_year)`. Only thin out labels when they overlap (roughly >20 ticks)
- **Output PDF for figures** — vector graphics for LaTeX. Use `ggsave("fig.pdf")`. PNG only for raster content (maps, photos).
- **Colorblind-friendly palettes** — use `scale_color_brewer(palette = "Set2")`, `viridis`, or similar. Never rely on red/green contrast alone.
- **Color-independent design** — figures must be readable in grayscale. Combine color with shape (`shape` aesthetic) and linetype (`linetype` aesthetic) so series remain distinguishable without color.
- **Figure width** — single-panel: `width=0.8\textwidth`. Side-by-side panels: `width=0.48\textwidth` each.

---

## 3. PDF Processing

### The Safe Processing Workflow

**Step 1: Receive PDF Upload**
- User uploads PDF to `master_supporting_docs/supporting_papers/` or `supporting_slides/`
- Claude DOES NOT attempt to read it directly

**Step 2: Check PDF Properties**
```bash
pdfinfo paper_name.pdf | grep "Pages:"
ls -lh paper_name.pdf
```

**Step 3: Create Subfolder and Split**
```bash
mkdir -p paper_name/

for i in {0..9}; do
  start=$((i*5 + 1))
  end=$(((i+1)*5))
  gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
     -dFirstPage=$start -dLastPage=$end \
     -sOutputFile="paper_name/paper_name_p$(printf '%03d' $start)-$(printf '%03d' $end).pdf" \
     paper_name.pdf 2>/dev/null
done
```

**Step 4: Process Chunks Intelligently**
- Read chunks ONE AT A TIME using the Read tool
- Extract key information from each chunk
- Build understanding progressively
- Don't try to hold all chunks in working memory

**Step 5: Selective Deep Reading**
- After scanning all chunks, identify the most relevant sections
- Only read those sections in detail for slide development
- Skip appendices, references, or less relevant sections unless needed

### Error Handling Protocol

**If a chunk fails to process:**
1. Note the problematic chunk (e.g., "Chunk p021-025 failed")
2. Try splitting into 1-2 page pieces
3. If still failing, skip and document the gap

**If splitting fails:**
1. Check if Ghostscript is installed: `gs --version`
2. Try alternative: `pdftk paper.pdf burst output paper_%03d.pdf`
3. If all else fails, ask user to upload specific page ranges manually

**If memory/token issues persist:**
1. Process only 2-3 chunks per session
2. Focus on specific sections user identifies as most important

---

## 4. Exploration Folder Protocol

**All experimental work goes into `explorations/` first.** Never directly into production folders.

### Folder Structure

```
explorations/
├── ACTIVE_PROJECTS.md
├── [project]/
│   ├── README.md          # Goal, status, findings
│   ├── R/                 # Code (use _v1, _v2 for iterations)
│   ├── scripts/           # Test scripts
│   ├── output/            # Results
│   └── SESSION_LOG.md     # Progress notes
└── ARCHIVE/
    ├── completed_[project]/
    └── abandoned_[project]/
```

### Lifecycle

1. **Create** — `mkdir -p explorations/[name]/{R,scripts,output}` + README from `templates/exploration-readme.md`
2. **Develop** — work entirely within the exploration folder
3. **Decide:**

   - **Graduate to production** — copy to `R/`, `scripts/`; requires quality >= 80, tests pass, code clear. Move to `ARCHIVE/completed_[project]/`
   - **Keep exploring** — document next steps in README
   - **Abandon** — move to `ARCHIVE/abandoned_[project]/` with explanation (use `templates/archive-readme.md`)

### Graduate Checklist

- [ ] Quality score >= 80
- [ ] All tests pass
- [ ] Results replicate within tolerance
- [ ] Code is clear without deep context
- [ ] README explains approach and findings

---

## 5. Exploration Fast-Track

**Lightweight workflow for experimental work.** Quality threshold: 60/100 (vs 80 for production). No planning needed.

### Steps

1. **Research value check** — Does this improve the project? If NO, don't build it.
2. **Create folder** — `mkdir -p explorations/[name]/{R,scripts,output}` + README + SESSION_LOG.md
3. **Code immediately** — no plan needed. Must-haves: code runs, results correct, goal documented. Not needed: Roxygen docs, full tests, perfect style.
4. **Log progress** — append 2-3 lines to SESSION_LOG.md as you work
5. **Decision point** — keep exploring, graduate to production (upgrade to 80/100), or archive with brief explanation

### When to Stop (Kill Switch)

At any point: stop, archive with note ("Attempted X, hit blocker Y"), move on. No guilt — exploration is inherently uncertain.
