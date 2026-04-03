---


name: methods-paper-writer
description: JASA/Biometrika manuscript structure with VanderWeele notation standards


---

# Methods Paper Writer

**Comprehensive guide for writing statistical methodology manuscripts**

Use this skill when working on: methodology manuscripts, journal submissions, methods sections, simulation study write-ups, theoretical results presentation, or adapting papers for specific journals (JASA, Biometrika, Biostatistics).

---

## JASA Format

### Journal of the American Statistical Association Requirements

| Element | JASA Requirement |
|---------|------------------|
| Page limit | ~25 pages main text + unlimited supplement |
| Abstract | 150-200 words, no math symbols |
| Keywords | 3-6 keywords after abstract |
| Sections | Standard: Intro, Methods, Theory, Simulation, Application, Discussion |
| References | Author-year format (natbib) |
| Figures | High resolution, grayscale-compatible |
| Code | Reproducibility materials required |

```r
# JASA-compliant simulation results table
create_jasa_table <- function(results_df) {
  # Format for JASA: clean, no vertical lines, proper decimal alignment
  results_df %>%
    mutate(across(where(is.numeric), ~sprintf("%.3f", .))) %>%
    kable(format = "latex",
          booktabs = TRUE,
          align = c("l", rep("r", ncol(.) - 1)),
          caption = "Simulation results: Bias, SE, and Coverage") %>%
    kable_styling(latex_options = "hold_position") %>%
    add_header_above(c(" " = 1, "n = 200" = 3, "n = 500" = 3))
}
```

### JASA LaTeX Template

```latex
\documentclass[12pt]{article}
\usepackage{natbib}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}

\title{Your Title Here}
\author{Author One\thanks{Department, University, email} \and
        Author Two\thanks{Department, University, email}}
\date{}

\begin{document}
\maketitle

\begin{abstract}
Your abstract here (150-200 words, no math symbols).
\end{abstract}

\noindent\textbf{Keywords:} keyword1; keyword2; keyword3
```

---

## Introduction Structure

### The 6-Paragraph Introduction Formula

| Paragraph | Purpose | Word Count |
|-----------|---------|------------|
| 1 | Hook + Scientific Problem | 100-150 |
| 2 | Existing Methods | 150-200 |
| 3 | Gap/Limitation | 100-150 |
| 4 | Our Contribution | 150-200 |
| 5 | Results Preview | 100-150 |
| 6 | Paper Organization | 50-100 |

```r
# Template for tracking introduction components
intro_checklist <- function() {
  data.frame(
    paragraph = 1:6,
    element = c("Hook + Problem", "Literature", "Gap",
                "Contribution", "Results", "Organization"),
    key_phrases = c(
      "is fundamental to..., has important implications for...",
      "Existing methods include..., Prior work has...",
      "However, current approaches cannot..., A key limitation is...",
      "We propose..., Our method..., We develop...",
      "We show that..., Simulations demonstrate..., Application reveals...",
      "The remainder of this paper is organized as follows..."
    ),
    status = rep("pending", 6)
  )
}
```

---

## Simulation Section

### Standard Simulation Study Structure

```
1. Simulation Design
   - Data generating process (DGP)
   - Sample sizes
   - Number of replications
   - Scenarios/conditions

2. Methods Compared
   - Proposed method
   - Competing methods (2-4)
   - Oracle/benchmark

3. Performance Metrics
   - Bias
   - Standard error / RMSE
   - Coverage probability
   - Efficiency (relative to oracle)

4. Results
   - Tables by scenario
   - Figures for key patterns
   - Sensitivity analyses
```

```r
# Complete simulation template for mediation methods paper
run_simulation_study <- function(n_sims = 1000, n_vec = c(200, 500, 1000)) {
  scenarios <- expand.grid(
    n = n_vec,
    misspecification = c("none", "outcome", "mediator", "both"),
    effect_size = c("small", "medium", "large")
  )

  results <- map_dfr(1:nrow(scenarios), function(i) {
    scenario <- scenarios[i, ]

    replicate_results <- replicate(n_sims, {
      # Generate data under scenario
      data <- generate_dgp(
        n = scenario$n,
        misspec = scenario$misspecification,
        effect = scenario$effect_size
      )

      # Apply all methods
      list(
        proposed = proposed_method(data),
        baron_kenny = baron_kenny(data),
        product = product_method(data),
        bootstrap = bootstrap_method(data)
      )
    }, simplify = FALSE)

    # Summarize across replications
    summarize_simulation(replicate_results, true_effect)
  })

  results
}

# Standard metrics calculation
calculate_metrics <- function(estimates, true_value, ses) {
  list(
    bias = mean(estimates) - true_value,
    empirical_se = sd(estimates),
    mean_se = mean(ses),
    rmse = sqrt(mean((estimates - true_value)^2)),
    coverage = mean(abs(estimates - true_value) < 1.96 * ses)
  )
}
```

---

## Notation Conventions

### Standard Statistical Notation

| Symbol | Meaning | Usage |
|--------|---------|-------|
| $Y$ | Outcome | Capital for random variable |
| $y$ | Observed value | Lowercase for realization |
| $A$ | Treatment | Binary: $A \in \{0,1\}$ |
| $M$ | Mediator | Can be vector $\mathbf{M}$ |
| $X$ | Covariates | Often $\mathbf{X}$ for vector |
| $\theta$ | Parameter | Target of estimation |
| $\hat{\theta}$ | Estimator | Hat for estimate |
| $P, \mathbb{P}$ | Probability | Distribution |
| $E, \mathbb{E}$ | Expectation | Expected value |

### VanderWeele Mediation Notation

```latex
% Standard potential outcomes notation
Y(a)       % Outcome under treatment a
M(a)       % Mediator under treatment a
Y(a,m)     % Outcome under treatment a and mediator m

% Mediation effects
NDE(a) = E[Y(1,M(a)) - Y(0,M(a))]  % Natural direct effect
NIE(a) = E[Y(a,M(1)) - Y(a,M(0))]  % Natural indirect effect
TE = NDE + NIE                      % Total effect decomposition
```

---

## Figure Guidelines

### JASA Figure Requirements

| Aspect | Requirement |
|--------|-------------|
| Resolution | 300+ DPI for print |
| Format | PDF or EPS preferred |
| Colors | Must work in grayscale |
| Font size | Legible at print size (8pt minimum) |
| Legends | Inside figure, not separate |
| Captions | Below figure, complete description |

```r
# JASA-compliant ggplot theme
theme_jasa <- function() {
  theme_bw(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      strip.background = element_rect(fill = "gray95"),
      legend.position = "bottom",
      legend.box = "horizontal",
      axis.text = element_text(size = 9),
      axis.title = element_text(size = 10),
      plot.title = element_text(size = 11, face = "bold")
    )
}

# Create publication-ready figure
create_simulation_figure <- function(results) {
  ggplot(results, aes(x = n, y = bias, shape = method, linetype = method)) +
    geom_point(size = 2) +
    geom_line() +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    facet_wrap(~scenario, scales = "free_y") +
    scale_shape_manual(values = c(16, 17, 15, 18)) +
    scale_linetype_manual(values = c("solid", "dashed", "dotted", "dotdash")) +
    labs(
      x = "Sample Size",
      y = "Bias",
      shape = "Method",
      linetype = "Method"
    ) +
    theme_jasa()

  ggsave("figure1.pdf", width = 7, height = 5, dpi = 300)
}
```

---

## Manuscript Structure

### Standard Methods Paper Sections

```
1. Title
2. Abstract (structured or unstructured)
3. Introduction
4. Methods / Methodology
   - Notation and Setup
   - Identification
   - Estimation
   - Inference
5. Simulation Study
6. Application / Data Analysis
7. Discussion
8. Acknowledgments
9. References
10. Appendix / Supplementary Materials
    - Proofs
    - Additional simulations
    - Implementation details
```

---

## Section-by-Section Guidelines

### 1. Title

**Formula**: `[Method/Approach] for [Problem/Setting]`

**Examples**:
- "Efficient Estimation of Natural Direct and Indirect Effects"
- "Double Robust Inference for Mediation Analysis with Unmeasured Confounding"
- "A Semiparametric Approach to Sequential Mediation Analysis"

**Tips**:
- Lead with the contribution (method name or key concept)
- Include the setting/problem
- Avoid jargon unless widely known
- Keep under 15 words

### 2. Abstract

**Structure** (150-250 words):

```
[1-2 sentences: Problem/motivation]
[1-2 sentences: Gap in existing methods]
[2-3 sentences: Our contribution/approach]
[1-2 sentences: Key results - theory + empirical]
[1 sentence: Implications/availability]
```

**Example**:
> Mediation analysis is fundamental for understanding causal mechanisms in health research. Existing methods for sequential mediation assume correctly specified parametric models and cannot accommodate high-dimensional confounders. We develop a doubly robust estimator for sequential mediation effects that remains consistent when either the outcome or mediator models are correctly specified. We derive the efficient influence function and show our estimator achieves the semiparametric efficiency bound. Simulations demonstrate substantial efficiency gains over existing approaches, particularly under model misspecification. We apply our method to study the pathway from childhood adversity through inflammation to adult depression using MIDUS data. Software is available in the R package medrobust.

### 3. Introduction

**Structure** (4-6 paragraphs):

**Paragraph 1: Problem and Motivation**
- State the scientific problem
- Why does it matter?
- Concrete example/application

**Paragraph 2: Existing Approaches**
- What methods exist?
- What do they accomplish?
- (Be fair and accurate)

**Paragraph 3: Gap/Limitation**
- What can't current methods do?
- Why is this a problem?
- Make the need compelling

**Paragraph 4: Our Contribution**
- What do we propose?
- How does it address the gap?
- Key properties (robust, efficient, etc.)

**Paragraph 5: Results Preview**
- What do we show theoretically?
- What do simulations demonstrate?
- What does the application reveal?

**Paragraph 6: Paper Organization**
- "The remainder of this paper is organized as follows..."
- Brief section-by-section overview

**Tips**:
- Start broad, narrow to specific contribution
- Cite 3-5 key papers per existing approach
- Don't oversell or bash competitors
- Be specific about contributions

### 4. Notation and Setup

**Template**:
```latex
\section{Notation and Setup}
\label{sec:setup}

Let $O = (Y, A, M, X)$ denote the observed data, where:
\begin{itemize}
\item $Y \in \mathcal{Y}$ is the outcome of interest
\item $A \in \{0,1\}$ is the binary treatment
\item $M \in \mathcal{M}$ is the mediator
\item $X \in \mathcal{X}$ is a vector of pre-treatment confounders
\end{itemize}

We assume $n$ i.i.d. copies $O_1, \ldots, O_n$ from distribution $P$.

\subsection{Causal Framework}
We adopt the potential outcomes framework \citep{Rubin1974}. Let $Y(a)$
denote the potential outcome under treatment $A=a$, and $Y(a,m)$ the
potential outcome when treatment is set to $a$ and mediator to $m$.
```

**Tips**:
- Define ALL notation before use
- Use consistent notation throughout
- Follow field conventions (VanderWeele for mediation)
- Keep notation minimal but precise

### 5. Identification

**Structure**:

```latex
\section{Identification}
\label{sec:identification}

\subsection{Target Estimand}
Our target estimand is [precise definition with formula].

\subsection{Identification Assumptions}
We require the following assumptions:
\begin{assumption}[Consistency]
\label{A:consistency}
$Y = Y(A, M)$ and $M = M(A)$.
\end{assumption}
[... additional assumptions ...]

\subsection{Identification Result}
\begin{theorem}[Identification]
\label{thm:identification}
Under Assumptions \ref{A:consistency}--\ref{A:positivity},
the estimand $\psi$ is identified by [formula].
\end{theorem}
```

**Tips**:
- Number assumptions (A1, A2, ... or Assumption 1, 2, ...)
- State assumptions precisely
- Discuss plausibility of each assumption
- Proof in main text if simple, appendix if long

### 6. Estimation

**Structure**:

```latex
\section{Estimation}
\label{sec:estimation}

\subsection{Proposed Estimator}
Based on the identification result, we propose the estimator:
\begin{equation}
\hat{\psi}_n = [estimator formula]
\end{equation}

\subsection{Nuisance Estimation}
The estimator depends on nuisance functions $\eta = (\mu, \pi, \ldots)$.
We estimate these using [approach].

\subsection{Algorithm}
[Pseudocode or step-by-step procedure]
```

**Tips**:
- Motivate why this estimator (efficiency, robustness)
- Be explicit about nuisance estimation
- Provide algorithm/pseudocode for implementation
- Discuss computational considerations

### 7. Asymptotic Properties

**Structure**:

```latex
\section{Asymptotic Properties}
\label{sec:theory}

\subsection{Regularity Conditions}
We impose the following regularity conditions:
\begin{condition}
\label{C1}
[Condition statement]
\end{condition}

\subsection{Main Result}
\begin{theorem}[Asymptotic Normality]
\label{thm:asymptotics}
Under Conditions \ref{C1}--\ref{Cn}, as $n \to \infty$:
\[
\sqrt{n}(\hat{\psi}_n - \psi_0) \xrightarrow{d} N(0, V)
\]
where $V = E[\phi(O)^2]$ and $\phi$ is the influence function given by [formula].
\end{theorem}

\subsection{Variance Estimation}
Consistent variance estimation via [approach].

\subsection{Efficiency} [optional]
\begin{theorem}[Semiparametric Efficiency]
The estimator $\hat{\psi}_n$ achieves the semiparametric efficiency bound.
\end{theorem}
```

**Tips**:
- State conditions clearly (not buried in proof)
- Main results in theorems, not prose
- Provide intuition for influence function
- Proofs typically in appendix

### 8. Simulation Study

**Structure**:

```latex
\section{Simulation Study}
\label{sec:simulation}

\subsection{Design}
We assess finite-sample performance through Monte Carlo simulation.

\paragraph{Data Generation.}
[Describe DGP with formulas]

\paragraph{Parameter Grid.}
\begin{itemize}
\item Sample size: $n \in \{200, 500, 1000, 2000\}$
\item Effect size: $\psi \in \{0, 0.1, 0.3\}$
\item [Other factors]
\end{itemize}

\paragraph{Estimators.}
We compare:
\begin{enumerate}
\item Proposed estimator
\item [Competitor 1] \citep{...}
\item [Competitor 2] \citep{...}
\item Oracle (if applicable)
\end{enumerate}

\paragraph{Performance Metrics.}
\begin{itemize}
\item Bias: $\text{Bias} = \bar{\hat{\psi}} - \psi_0$
\item Empirical SE: $\text{ESE} = \text{SD}(\hat{\psi})$
\item Average SE: $\text{ASE} = \bar{\widehat{SE}}$
\item Coverage: $\text{Cov} = \text{proportion of CIs containing } \psi_0$
\item MSE: $\text{MSE} = \text{Bias}^2 + \text{ESE}^2$
\end{itemize}

Each scenario: 1000 replications.

\subsection{Results}
[Tables and interpretation]
```

**Tips**:
- Follow Morris et al. (2019) guidelines
- Include enough scenarios to stress-test
- Show both when method works AND when it doesn't
- Include oracle/optimal for context
- Report MCSE (Monte Carlo standard error)

### 9. Application

**Structure**:

```latex
\section{Application}
\label{sec:application}

\subsection{Data Description}
We apply our method to [dataset] to study [scientific question].

[Describe sample, variables, missingness]

\subsection{Analysis}
[Model specification, covariate selection, etc.]

\subsection{Results}
[Point estimates, CIs, interpretation]

\subsection{Sensitivity Analysis}
[Robustness to assumptions]
```

**Tips**:
- Use a compelling, relevant application
- Describe data clearly (can reproduce)
- Report all model specifications
- Include sensitivity analyses
- Interpret substantively (not just "significant")

### 10. Discussion

**Structure** (4-5 paragraphs):

**Paragraph 1: Summary**
- Brief recap of contribution
- Key findings (theory + empirical)

**Paragraph 2: Implications**
- What does this mean for practice?
- When should researchers use this?

**Paragraph 3: Limitations**
- What can't the method do?
- When might it fail?
- (Being honest builds credibility)

**Paragraph 4: Future Directions**
- Natural extensions
- Open problems
- Ongoing work (brief)

**Paragraph 5: Conclusion**
- Final statement of contribution
- Availability of software

---

## Journal-Specific Requirements

### JASA (Journal of the American Statistical Association)

**Format**:
- Double-spaced, 12pt font
- Separate title page with abstract
- Figures/tables at end
- Supplementary materials allowed

**Abstract**: ~150 words, unstructured

**Sections**: Standard methods paper structure

**Key reviewer expectations**:
- Novel methodology (not just application)
- Rigorous theory
- Comprehensive simulation
- Compelling application
- Reproducibility (code/data)

**Word limit**: ~25-30 pages (main), unlimited supplement

### Biometrika

**Format**:
- Double-spaced
- Abstract on title page
- References: author-year

**Abstract**: ~100-150 words

**Emphasis**:
- Mathematical rigor
- Elegant theory
- Concise writing
- Deep results > breadth

**Word limit**: ~20-25 pages

### Biostatistics

**Format**:
- Double-spaced
- Structured abstract (Background, Methods, Results, Conclusions)

**Abstract**: 250 words max

**Emphasis**:
- Biomedical motivation
- Practical impact
- Software availability
- Real data analysis essential

**Word limit**: ~30 pages

### Statistics in Medicine

**Format**:
- Double-spaced
- Structured abstract

**Emphasis**:
- Medical statistics focus
- Tutorial aspect welcomed
- Practical guidance
- Reproducibility

---

## Notation Standards

### VanderWeele Notation (Mediation/Causal)

| Symbol | Meaning |
|--------|---------|
| $Y(a)$ | Potential outcome under $A=a$ |
| $Y(a,m)$ | Potential outcome under $A=a$, $M=m$ |
| $M(a)$ | Potential mediator under $A=a$ |
| $NDE$ | Natural Direct Effect |
| $NIE$ | Natural Indirect Effect |
| $CDE(m)$ | Controlled Direct Effect at $M=m$ |
| $TE$ | Total Effect |
| $P_M$ | Proportion Mediated |

### Statistical Notation

| Symbol | Meaning |
|--------|---------|
| $\theta_0$ | True parameter value |
| $\hat{\theta}_n$ | Estimator based on $n$ observations |
| $\phi(O)$ | Influence function |
| $\mathbb{P}_n$ | Empirical measure: $n^{-1}\sum_i \delta_{O_i}$ |
| $\mathbb{G}_n$ | Empirical process: $\sqrt{n}(\mathbb{P}_n - P)$ |
| $\xrightarrow{p}$ | Convergence in probability |
| $\xrightarrow{d}$ | Convergence in distribution |
| $O_p(\cdot)$, $o_p(\cdot)$ | Stochastic order |

### Consistency in Notation

- Define ALL symbols before first use
- Use same symbol for same concept throughout
- Avoid notation conflicts within paper
- Follow journal/field conventions

---

## Common Writing Patterns

### Introducing Assumptions

```latex
We require the following assumptions for identification:
\begin{assumption}[Name]
\label{A:name}
[Mathematical statement]
\end{assumption}
Assumption \ref{A:name} requires that [plain language explanation]. This is plausible when [conditions]. It would be violated if [counter-examples].
```

### Presenting Theorems

```latex
Our main theoretical result establishes the asymptotic properties of $\hat{\psi}_n$.
\begin{theorem}[Title]
\label{thm:main}
Under Conditions \ref{C1}--\ref{Cn}, [statement].
\end{theorem}
Theorem \ref{thm:main} shows that [interpretation]. The key insight is [intuition]. Compared to [existing result], our result [improvement].
```

### Comparing to Existing Methods

```latex
Our approach differs from \citet{Author2020} in several ways. First, [difference 1]. Second, [difference 2]. Whereas their method requires [strong assumption], our estimator only needs [weaker assumption]. In the simulation study, we demonstrate [empirical comparison].
```

### Discussing Limitations

```latex
Several limitations deserve mention. First, our method assumes [assumption], which may not hold in settings where [violation scenario]. Second, the asymptotic approximation requires [sample size consideration]. Future work could address these by [potential solutions].
```

---

## LaTeX Best Practices

### Document Structure

```latex
\documentclass[12pt]{article}
\usepackage{amsmath,amsthm,amssymb}
\usepackage{natbib}
\usepackage{graphicx}
\usepackage{booktabs}

% Theorem environments
\newtheorem{theorem}{Theorem}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{assumption}{Assumption}
\newtheorem{condition}{Condition}

% Custom commands
\newcommand{\E}{\mathbb{E}}
\newcommand{\Var}{\text{Var}}
\newcommand{\Cov}{\text{Cov}}
\newcommand{\indep}{\perp\!\!\!\perp}

\begin{document}
...
\end{document}
```

### Tables

```latex
\begin{table}[ht]
\centering
\caption{Simulation results: Bias ($\times 100$), ESE, ASE, and Coverage (\%)}
\label{tab:sim}
\begin{tabular}{lcccccc}
\toprule
& \multicolumn{3}{c}{$n=500$} & \multicolumn{3}{c}{$n=1000$} \\
\cmidrule(lr){2-4} \cmidrule(lr){5-7}
Method & Bias & SE & Cov & Bias & SE & Cov \\
\midrule
Proposed & 0.2 & 0.15 & 94.8 & 0.1 & 0.11 & 95.2 \\
Naive    & 5.3 & 0.12 & 82.1 & 5.1 & 0.09 & 71.3 \\
\bottomrule
\end{tabular}
\end{table}
```

### Figures

```latex
\begin{figure}[ht]
\centering
\includegraphics[width=0.8\textwidth]{figures/sim_results.pdf}
\caption{Simulation results across sample sizes. Left: Bias. Right: Coverage.
Dashed line indicates nominal 95\% level.}
\label{fig:sim}
\end{figure}
```

---

## Quality Checklist

### Before Submission

**Content**:
- [ ] All claims supported by theory or evidence
- [ ] All notation defined before use
- [ ] Assumptions clearly stated and discussed
- [ ] Proofs complete and correct
- [ ] Simulations comprehensive
- [ ] Application compelling and well-analyzed

**Writing**:
- [ ] Clear, concise prose
- [ ] Logical flow between sections
- [ ] Active voice where appropriate
- [ ] No undefined acronyms
- [ ] Consistent terminology

**Formatting**:
- [ ] Follows journal guidelines
- [ ] Figures high resolution
- [ ] Tables properly formatted
- [ ] References complete and consistent
- [ ] Supplementary materials organized

**Reproducibility**:
- [ ] Code available (GitHub, Zenodo)
- [ ] Data available or simulated data provided
- [ ] Random seeds documented
- [ ] Software versions noted

---

## Integration with Other Skills

This skill works with:
- **proof-architect** - For presenting theoretical results
- **identification-theory** - For identification sections
- **asymptotic-theory** - For inference sections
- **simulation-architect** - For simulation study design
- **manuscript-writing-guide** - For project-specific standards

---

## Key References
- VanderWeele notation
- JASA style guide
- APA citations

- Morris, T.P. et al. (2019). Using simulation studies to evaluate statistical methods. Statistics in Medicine.
- VanderWeele, T.J. (2015). Explanation in Causal Inference. Oxford.
- van der Laan, M.J. & Rose, S. (2018). Targeted Learning in Data Science. Springer.

---

**Version**: 1.0
**Created**: 2025-12-08
**Domain**: Statistical Methods, Scientific Writing
