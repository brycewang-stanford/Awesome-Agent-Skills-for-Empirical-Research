---


name: literature-gap-finder
description: Method×Setting matrices and systematic gap identification


---

# Literature Gap Finder

**Systematic framework for identifying research opportunities in statistical methodology**

Use this skill when: positioning research contributions, finding gaps in methodology literature, identifying unexplored combinations of methods and settings, building literature reviews, or deciding on research directions.

---

## The Gap-Finding Framework

### What Makes a Good Research Gap?

A publishable gap must be:

1. **Real** - Not already addressed (check thoroughly!)
2. **Important** - Solves a problem researchers face
3. **Tractable** - Can be solved with available tools
4. **Novel** - Provides new insight, not just combination
5. **Timely** - Relevant to current research trends

### Types of Gaps

| Gap Type | Description | Example |
|----------|-------------|---------|
| **Method Gap** | No method exists for setting | No mediation analysis for network data |
| **Theory Gap** | Method exists but lacks theory | Bootstrap for mediation lacks consistency proof |
| **Efficiency Gap** | Methods exist but are inefficient | Doubly robust mediation more efficient |
| **Robustness Gap** | Methods fail under violations | Mediation under measurement error |
| **Computational Gap** | Existing methods don't scale | Mediation with high-dimensional confounders |
| **Extension Gap** | Existing method needs generalization | Binary → continuous mediator |

---

## Method-Setting Matrix

### Systematic Gap Identification Framework

The method-setting matrix is the core tool for finding research gaps systematically:

```r
# Build a method-setting matrix programmatically
create_gap_matrix <- function() {
  methods <- c("Regression", "Weighting/IPW", "DR/AIPW", "TMLE", "ML-based")
  settings <- c("Binary treatment", "Continuous treatment",
                "Time-varying", "Clustered", "High-dimensional",
                "Measurement error", "Missing data", "Network")

  matrix_data <- expand.grid(method = methods, setting = settings)
  matrix_data$status <- "unknown"  # To be filled: "developed", "partial", "gap"
  matrix_data$priority <- NA
  matrix_data$references <- ""

  matrix_data
}

# Visualize the gap matrix
visualize_gaps <- function(gap_matrix) {
  library(ggplot2)

  ggplot(gap_matrix, aes(x = method, y = setting, fill = status)) +
    geom_tile(color = "white") +
    scale_fill_manual(values = c(
      "developed" = "#2ecc71",
      "partial" = "#f39c12",
      "gap" = "#e74c3c",
      "unknown" = "#95a5a6"
    )) +
    theme_minimal() +
    labs(title = "Method × Setting Gap Matrix",
         x = "Method", y = "Setting") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}
```

---

## Verification Process

### Confirming a Gap is Real

Before claiming a gap, verify systematically:

| Step | Action | Tools |
|------|--------|-------|
| 1 | Search major databases | Google Scholar, Web of Science, Scopus |
| 2 | Search preprint servers | arXiv, bioRxiv, SSRN |
| 3 | Search R packages | CRAN, GitHub, R-universe |
| 4 | Check conference proceedings | ICML, NeurIPS, JSM, ENAR |
| 5 | Search dissertations | ProQuest, university repositories |
| 6 | Email domain experts | 2-3 experts for confirmation |

```r
# Systematic verification checklist
verify_gap <- function(topic, keywords) {
  checklist <- list(
    databases_searched = c("google_scholar", "web_of_science", "pubmed", "scopus"),
    search_terms = keywords,
    date_range = paste(Sys.Date() - 365*5, "to", Sys.Date()),
    results = list(
      papers_found = 0,
      closest_related = c(),
      why_not_the_same = ""
    ),
    expert_consultation = list(
      experts_contacted = c(),
      responses = c()
    ),
    verification_status = "pending"  # pending, confirmed, rejected
  )

  checklist
}

# Document the verification
document_verification <- function(gap_description, search_log) {
  cat("## Gap Verification Report\n\n")
  cat("**Gap:**", gap_description, "\n\n")
  cat("**Search Date:**", as.character(Sys.Date()), "\n\n")
  cat("**Databases Searched:**\n")
  for (db in search_log$databases_searched) {
    cat("- ", db, "\n")
  }
  cat("\n**Search Terms:**", paste(search_log$search_terms, collapse = ", "), "\n")
  cat("\n**Conclusion:**", search_log$verification_status, "\n")
}
```

---

## Priority Ranking

### Scoring Research Gaps

| Criterion | Weight | Score 1-5 |
|-----------|--------|-----------|
| Impact (how many benefit?) | 0.25 | ___ |
| Novelty (how new?) | 0.20 | ___ |
| Tractability (can we solve it?) | 0.20 | ___ |
| Timeliness (is it hot now?) | 0.15 | ___ |
| Fit (matches our expertise?) | 0.10 | ___ |
| Publication potential | 0.10 | ___ |

**Priority Score** = Σ(weight × score)

```r
# Priority scoring function
score_research_gap <- function(
  impact,        # 1-5: How many researchers would benefit
  novelty,       # 1-5: How new/original is this
  tractability,  # 1-5: How likely can we solve it
  timeliness,    # 1-5: Is this currently hot
  fit,           # 1-5: Matches our expertise
  publication    # 1-5: Publication potential
) {
  weights <- c(0.25, 0.20, 0.20, 0.15, 0.10, 0.10)
  scores <- c(impact, novelty, tractability, timeliness, fit, publication)

  priority <- sum(weights * scores)

  list(
    priority_score = priority,
    interpretation = case_when(
      priority >= 4.0 ~ "High priority - pursue immediately",
      priority >= 3.0 ~ "Medium priority - develop further",
      priority >= 2.0 ~ "Low priority - back burner",
      TRUE ~ "Skip - not worth pursuing"
    ),
    breakdown = data.frame(
      criterion = c("Impact", "Novelty", "Tractability",
                   "Timeliness", "Fit", "Publication"),
      weight = weights,
      score = scores,
      weighted = weights * scores
    )
  )
}

# Compare multiple gaps
rank_gaps <- function(gaps_list) {
  scores <- sapply(gaps_list, function(g) g$priority_score)
  order(scores, decreasing = TRUE)
}
```

---

## Method × Setting Matrix

### The Core Framework

Systematically map methods against settings to find gaps:

```
                    METHODS
          │ Regression │ Weighting │ DR/TMLE │ ML-based │
──────────┼────────────┼───────────┼─────────┼──────────│
Binary A  │     ✓      │     ✓     │    ✓    │    ✓     │
Continuous│     ✓      │     ?     │    ✓    │    ?     │
SETTINGS  ├────────────┼───────────┼─────────┼──────────│
Time-vary │     ?      │     ✓     │    ✓    │    ✗     │
Clustered │     ✓      │     ?     │    ?    │    ✗     │
High-dim  │     ✗      │     ✗     │    ?    │    ✓     │

✓ = Well-developed    ? = Partial/emerging    ✗ = Gap
```

### Building Your Matrix

**Step 1: Identify Dimensions**

For mediation analysis:

| Dimension | Variations |
|-----------|------------|
| Treatment | Binary, continuous, multi-level, time-varying |
| Mediator | Single, multiple, high-dimensional, latent |
| Outcome | Continuous, binary, count, survival, longitudinal |
| Confounding | Measured, unmeasured, time-varying |
| Structure | Single mediator, parallel, sequential, moderated |
| Data | Cross-sectional, longitudinal, clustered, network |
| Assumptions | Standard, relaxed positivity, measurement error |

**Step 2: List Methods**

| Method Family | Specific Methods |
|---------------|------------------|
| Regression | Baron-Kenny, product of coefficients, difference |
| Weighting | IPW, MSM, sequential g-estimation |
| Doubly Robust | AIPW, TMLE, cross-fitted |
| Semiparametric | Influence function-based |
| Bayesian | MCMC, variational |
| Machine Learning | Causal forests, DML, neural |
| Bounds | Partial identification, sensitivity |

**Step 3: Fill and Analyze**

Mark each cell:
- ✓ (green): Well-established with theory + software
- ? (yellow): Emerging or partial coverage
- ✗ (red): Clear gap

### Example: Sequential Mediation Matrix

```
                         │ Product │ Weighting │ DR │ Bounds │
─────────────────────────┼─────────┼───────────┼────┼────────│
2 mediators, linear      │    ✓    │     ✓     │  ✓ │   ?    │
2 mediators, nonlinear   │    ?    │     ✓     │  ? │   ✗    │
3+ mediators, linear     │    ?    │     ?     │  ✗ │   ✗    │
3+ mediators, nonlinear  │    ✗    │     ?     │  ✗ │   ✗    │
With measurement error   │    ✗    │     ✗     │  ✗ │   ✗    │
With unmeasured conf.    │    ✗    │     ✗     │  ✗ │   ?    │
```

**Gaps identified**:
- DR methods for 3+ mediators
- Any method with measurement error
- Bounds approach underdeveloped

---

## Assumption Relaxation Trees

### The Framework

Map how assumptions have been relaxed over time:

```
                    Standard Mediation (Baron-Kenny 1986)
                              │
            ┌─────────────────┼─────────────────┐
            ↓                 ↓                 ↓
    No unmeasured      Linearity         No interaction
    confounding        assumed           assumed
            │                 │                 │
            ↓                 ↓                 ↓
    ┌───────┴───────┐   Nonparametric    VanderWeele
    ↓               ↓     (Imai 2010)    4-way decomp
Sensitivity      Bounds                        │
(Imai 2010)   (partial ID)                    ↓
    │               │               Multiple mediators?
    ↓               ↓               Longitudinal?
 E-value        Sharp bounds?       Measurement error?
(Ding 2016)         │                    │
    │               ↓                    ↓
    ↓           [YOUR GAP?]         [YOUR GAP?]
[YOUR GAP?]
```

### Building the Tree

**Step 1: Identify Original Assumptions**

For a classic method, list ALL assumptions:
1. Explicit assumptions (stated in paper)
2. Implicit assumptions (unstated but required)
3. Computational assumptions (required for implementation)

**Step 2: Trace Relaxation History**

For each assumption, find papers that:
- Relax it partially
- Relax it completely
- Replace it with different assumption
- Show consequences of violation

**Step 3: Find Unexplored Branches**

Look for:
- Combinations of relaxations not yet explored
- Relaxations in one method not applied to another
- Partial relaxations that could be completed

### Example: Positivity Assumption

```
Positivity: P(A=a|X) > ε > 0 for all a, x
                    │
    ┌───────────────┼───────────────┐
    ↓               ↓               ↓
Near-violation  Practical      Structural
                positivity      violations
    │               │               │
    ↓               ↓               ↓
Trimming      Overlap         Extrapolation
weights       assessment       methods
    │               │               │
    ↓               ↓               ↓
Truncation?   Diagnostics?   Bounds under
                             violations?
```

---

## Citation Network Analysis

### Forward and Backward Searching

**Backward**: From recent key paper, trace citations:
- What foundational papers are cited?
- What parallel developments exist?
- What's the intellectual lineage?

**Forward**: Using Google Scholar "Cited by":
- Who has built on this work?
- What extensions were made?
- What gaps remain unaddressed?

### Key Paper Identification

For any topic, identify:

| Category | Description | How to Find |
|----------|-------------|-------------|
| **Foundational** | Original method papers | Most-cited, oldest |
| **Textbook** | Comprehensive treatments | Citations across subfields |
| **Recent reviews** | State-of-the-art summaries | "Review" in title, last 5 years |
| **Frontier** | Latest developments | Top journals, last 2 years |
| **Your competition** | Groups working on same gap | Recent similar titles |

### Building a Citation Map

```
1986: Baron & Kenny [foundations]
        │
        ├──→ 1990s: SEM extensions
        │
        ├──→ 2004: Robins & Greenland [causal foundations]
        │           │
        │           ├──→ 2010: Imai et al. [sensitivity]
        │           │
        │           ├──→ 2010: VanderWeele [4-way]
        │           │           │
        │           │           └──→ 2015: Book [comprehensive]
        │           │
        │           └──→ 2014: Tchetgen [semiparametric]
        │
        └──→ 2020s: ML integration [frontier]
```

---

## Gap Verification Checklist

Before claiming a gap, verify:

### 1. Literature Search

- [ ] Searched Google Scholar with multiple keyword combinations
- [ ] Searched arXiv stat.ME and stat.TH
- [ ] Searched JSTOR for older statistics journals
- [ ] Searched bioRxiv/medRxiv for preprints
- [ ] Checked reference lists of review papers
- [ ] Checked "cited by" for key papers

### 2. Terminology Check

- [ ] Same concept might have different names in different fields
- [ ] Checked econometrics terminology
- [ ] Checked biostatistics terminology
- [ ] Checked machine learning terminology
- [ ] Checked psychology/SEM terminology

### 3. Adjacent Literature

- [ ] Checked related but not identical settings
- [ ] Method might exist for similar problem
- [ ] Checked if general framework applies

### 4. Working Papers

- [ ] Checked key authors' websites
- [ ] Checked conference proceedings (JSM, ENAR)
- [ ] Asked collaborators/experts

### 5. Final Verification

- [ ] Gap is not addressed in supplementary materials
- [ ] Gap is not "obvious" extension reviewers will dismiss
- [ ] Gap is important enough to publish

---

## Gap Characterization Template

When you identify a gap:

```markdown
## Gap: [Brief Title]

### Setting
[Precise description of the setting where the gap exists]

### Current State
- **What exists**: [Methods that partially address this]
- **What works**: [Aspects of the problem already solved]
- **What fails**: [Where current methods break down]

### The Gap
- **Precise statement**: [What is missing]
- **Why it matters**: [Who needs this, for what applications]
- **Why it's hard**: [Technical challenges]

### Evidence of Gap
- [ ] Literature search documented
- [ ] No existing solution found
- [ ] Experts consulted (optional)

### Potential Approaches
1. [Approach 1]: [Brief description]
   - Pros: [Advantages]
   - Cons: [Challenges]

2. [Approach 2]: [Brief description]
   - Pros: [Advantages]
   - Cons: [Challenges]

### Related Work
- [Paper 1]: [How it relates, why it doesn't solve gap]
- [Paper 2]: [How it relates, why it doesn't solve gap]

### Contribution Positioning
"While [existing work] addresses [related problem], no method currently
handles [specific gap]. We propose [approach] which provides [properties]."
```

---

## Common Gap Patterns in Mediation

### Pattern 1: Data Structure Mismatch

**Gap template**: "[Method] assumes [simple structure], but in [application] data has [complex structure]"

Examples:
- Methods assume iid, but data is clustered
- Methods assume cross-sectional, but data is longitudinal
- Methods assume complete data, but missingness exists

### Pattern 2: Assumption Violation

**Gap template**: "[Method] requires [assumption], which is violated when [situation]"

Examples:
- Unmeasured mediator-outcome confounding
- Measurement error in mediator
- Treatment-mediator interaction

### Pattern 3: Estimand Ambiguity

**Gap template**: "When [complication], standard estimands [NDE/NIE] are not well-defined or interpretable"

Examples:
- Post-treatment confounding
- Time-varying treatments/mediators
- Multiple versions of treatment

### Pattern 4: Efficiency vs Robustness

**Gap template**: "Efficient methods require [strong assumptions], while robust methods are inefficient"

Examples:
- Doubly robust methods for mediation
- Semiparametric efficiency in complex settings
- Adaptive methods

### Pattern 5: Computational Barrier

**Gap template**: "Theoretically valid approach exists but [computational limitation]"

Examples:
- High-dimensional settings
- Continuous mediators requiring integration
- Bootstrap in complex models

---

## Research Positioning Strategies

### The Contribution Statement

**Strong positioning formula**:

> "Although [Author Year] developed [method] for [setting], their approach
> [limitation]. In contrast, our method [advantage] while maintaining [property].
> Specifically, we contribute: (1) [theoretical contribution], (2) [methodological
> contribution], (3) [practical contribution]."

### Positioning Types

| Position | When to Use | Example Language |
|----------|-------------|------------------|
| **Extension** | Build on existing | "We extend [method] to [new setting]" |
| **Synthesis** | Combine approaches | "We unify [method A] and [method B]" |
| **Alternative** | Different approach | "We propose an alternative that [advantage]" |
| **Correction** | Fix limitation | "We address the limitation of [method]" |
| **Generalization** | Broader framework | "We develop a general framework that includes [special cases]" |

### Differentiation Matrix

| Dimension | Competitor 1 | Competitor 2 | Our Method |
|-----------|--------------|--------------|------------|
| Setting | Binary A only | Any A | Any A |
| Theory | Consistency | + Normality | + Efficiency |
| Assumptions | Strong | Medium | Weaker |
| Computation | Fast | Slow | Medium |
| Software | R package | None | R + Python |

---

## Integration with Other Skills

This skill works with:
- **cross-disciplinary-ideation** - Find solutions from other fields for identified gaps
- **method-transfer-engine** - Transfer methods to fill gaps
- **identification-theory** - Understand what assumptions are needed
- **methods-paper-writer** - Write up the gap and solution

---

## Key References

### On Finding Research Gaps
- Alvesson, M. & Sandberg, J. (2011). Generating research questions through problematization
- Sandberg, J. & Alvesson, M. (2011). Ways of constructing research questions

### Mediation Reviews (for gap identification)
- VanderWeele, T.J. (2016). Mediation analysis: A practitioner's guide. Annual Review
- Nguyen, T.Q. et al. (2021). Clarifying causal mediation analysis. Psychological Methods

### Causal Inference Reviews
- Hernán, M.A. (2018). The C-word: Scientific euphemisms do not improve causal inference
- Imbens, G.W. (2020). Potential outcome and directed acyclic graph approaches

---

**Version**: 1.0
**Created**: 2025-12-08
**Domain**: Research Strategy, Literature Review
