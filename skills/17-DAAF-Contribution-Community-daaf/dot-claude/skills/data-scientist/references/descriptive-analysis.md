# Rigorous Descriptive Analysis

Methodological guidance for descriptive analysis — the systematic characterization of data patterns, distributions, and associations. This reference covers the *why* and *when* of descriptive methods. For implementation syntax, load the appropriate library skill (`polars`, `pyfixest`, `statsmodels`).

**Relationship to EDA:** The `eda-checklist.md` reference covers initial data profiling — understanding what is in the data before transforming it. This file covers the analysis phase — systematically characterizing patterns, distributions, and associations to answer research questions. EDA asks "what does this data look like?" This file asks "what does this data tell us?"

## Acknowledgments

These materials draw extensively from several open-access resources that the authors have generously made available to the research community: Nick Huntington-Klein's *The Effect* (https://theeffectbook.net/), Scott Cunningham's *Causal Inference: The Mixtape* (https://mixtape.scunning.com/), Joshua Angrist and Jörn-Steffen Pischke's *Mastering 'Metrics* (https://www.masteringmetrics.com/) and *Mostly Harmless Econometrics* (https://www.mostlyharmlesseconometrics.com/), and Sergio Rey, Dani Arribas-Bel, and Levi John Wolf's *Geographic Data Science with Python* (https://geographicdata.science/book/).

## Contents

- [When Descriptive Analysis Is the Right Approach](#when-descriptive-analysis-is-the-right-approach)
- [Summary Statistics That Tell a Story](#summary-statistics-that-tell-a-story)
- [Subgroup Analysis and Stratification](#subgroup-analysis-and-stratification)
- [Distributional Analysis](#distributional-analysis)
- [Cross-Tabulations and Contingency Analysis](#cross-tabulations-and-contingency-analysis)
- [Trend Analysis and Time Series Description](#trend-analysis-and-time-series-description)
- [Decomposition Methods](#decomposition-methods)
- [Index Construction and Composite Measures](#index-construction-and-composite-measures)
- [Weighted Analysis](#weighted-analysis)
- [Inequality Measurement](#inequality-measurement)
- [Correlation and Association](#correlation-and-association)
- [Missing Data Characterization](#missing-data-characterization)
- [Sample Description and Representativeness](#sample-description-and-representativeness)
- [References and Further Reading](#references-and-further-reading)

## Quick Task Lookup

| If the plan says... | Read this section |
|---------------------|-------------------|
| "compute subgroup means," "stratify by," "compare groups" | Subgroup Analysis + Summary Statistics |
| "characterize the distribution," "describe the spread" | Distributional Analysis |
| "decompose the gap," "explain the difference between groups" | Decomposition Methods |
| "construct an index," "create a composite measure" | Index Construction |
| "describe trends," "analyze changes over time" | Trend Analysis |
| "present weighted estimates," "apply survey weights" | Weighted Analysis |
| "measure inequality," "compute Gini," "percentile ratios" | Inequality Measurement |
| "create Table 1," "describe the sample" | Sample Description |
| "cross-tabulate," "compute rates" | Cross-Tabulations |
| "assess correlation," "examine associations" | Correlation and Association |
| "characterize missing data," "assess missingness" | Missing Data Characterization |

## When Descriptive Analysis Is the Right Approach

### Descriptive vs. Inferential: A Spectrum, Not a Binary

Analysis does not split cleanly into "descriptive" and "causal." Rather, there is a spectrum from pure description ("what does the data look like?") through association ("what covaries with what?") to causal identification ("does X cause Y?"). Much valuable research lives in the descriptive-to-associational range without ever attempting causal claims — and this is not a limitation but a deliberate and appropriate design choice.

Following Angrist and Pischke's (2009) framing, every linear regression estimates the best linear approximation to the conditional expectation function E[Y|X]. This is a descriptive object: it tells you the average value of Y for each value of X. Whether that relationship is *causal* depends on the research design, not the statistical technique. When the model is saturated (a full set of group dummies), the regression *is* the CEF exactly, not merely an approximation. A regression can be purely descriptive and still deeply informative.

### When Description IS the Research Contribution

Descriptive analysis is the right primary approach when your goal is any of the following:

| Goal | Example |
|------|---------|
| **Prevalence estimation** | What fraction of schools offer AP courses? How does this vary by urbanicity? |
| **Trend documentation** | How has college enrollment changed over the past two decades? |
| **Disparity measurement** | How large is the Black-White gap in household income at each percentile? |
| **Benchmarking** | How does this district's spending per pupil compare to similar districts? |
| **Pattern discovery** | What types of institutions have the highest student loan default rates? |
| **Data characterization** | What does the distribution of school poverty rates look like nationally? |

In each case, the research contribution is *documenting what is* — carefully, precisely, and with appropriate uncertainty — rather than identifying *why it is*.

### When Description Precedes Causal Investigation

Even when the ultimate goal is causal, rigorous descriptive analysis is an essential precursor. As Huntington-Klein (2022) emphasizes, you cannot design a credible identification strategy if you do not first understand what is in the data: what variables are available, how they are distributed, how they relate to each other, and where there is meaningful variation. Descriptive work helps you:

- Identify which relationships are large enough to be worth explaining causally
- Detect potential confounders and selection patterns
- Assess whether the data has sufficient variation for the intended design
- Formulate testable hypotheses from observed patterns

### The Value of Rigorous Simplicity

A well-executed descriptive analysis with proper subgroups, appropriate weights, careful attention to missing data, and honest characterization of uncertainty is far more credible and useful than a poorly conceived causal design with questionable identification. The temptation to treat every research question as requiring causal identification leads to two common failure modes:

1. **Overstating causal claims** from observational data that cannot support them
2. **Dismissing descriptive findings** as "merely descriptive" when they are exactly what the question requires

Neither serves the research well. Match the method to the question, and recognize that rigorous description is itself a high-value analytical product.

> For guidance on causal vs. correlational language in communicating results, see `research-questions.md` > "Causal vs. Correlational Language." For causal inference methodology, see `causal-inference.md`.

## Summary Statistics That Tell a Story

### Beyond Mean/Median/SD

The default instinct — report the mean, maybe the median and standard deviation — is often insufficient. The right summary statistic depends on the distribution's shape and the analytical question being asked.

### Central Tendency

| Measure | When to Use | When to Avoid |
|---------|-------------|---------------|
| **Mean** | Symmetric distributions; when you need a population total (mean × N) | Highly skewed data (income, home prices, spending) where the mean is unrepresentative |
| **Median** | Skewed distributions; when you want the "typical" value | When you need aggregation properties (medians don't sum) |
| **Mode** | Categorical data; identifying the most common category | Continuous data with no repeated values |
| **Trimmed mean** | When you want robustness to outliers but still need additive properties | When outliers are substantively important (you'd be discarding real information) |
| **Geometric mean** | Growth rates, ratios, multiplicative processes | Data with zeros or negative values |

**Decision rule:** If the mean and median diverge substantially (ratio > 1.2 or < 0.8), the distribution is skewed and the median is usually more informative for characterizing "typical" values. Report both, and consider reporting percentiles instead of either.

### Dispersion

| Measure | What It Captures | Best For |
|---------|-----------------|----------|
| **Standard deviation (SD)** | Average distance from the mean | Symmetric distributions; comparisons within a single variable |
| **Interquartile range (IQR)** | Spread of the middle 50% | Skewed data; resistant to outliers |
| **Range** | Total spread (max − min) | Quick sense of scale; extremely sensitive to outliers |
| **Coefficient of variation (CV)** | SD relative to the mean (SD/mean) | Comparing variability across variables with different scales or units |
| **Median absolute deviation (MAD)** | Median distance from the median | Robust alternative to SD for skewed/heavy-tailed distributions |

### Shape

- **Skewness**: Positive skew (right tail) is common in income, expenditure, and count data. Important because it tells you the mean overrepresents high values.
- **Kurtosis**: Measures tail weight relative to the normal distribution. High kurtosis means more extreme values than expected. Relevant for risk assessment and outlier characterization.
- **Modality**: A bimodal or multimodal distribution suggests subpopulations in the data. Always investigate — don't summarize a bimodal distribution with a single mean.

### Log Transformations for Skewed Data

When data are right-skewed and strictly positive (income, expenditure, enrollment, school spending), log transformation is often the appropriate descriptive tool:

- **When to log**: Right-skewed positive data where ratios are more meaningful than differences. If "a district spending $20K vs. $10K" is similar in importance to "a district spending $40K vs. $20K," the comparison is multiplicative and logs are appropriate.
- **Interpretation**: Differences in log values approximate percentage differences. A 0.10 log-point difference ≈ 10% difference; a 0.50 log-point difference ≈ 65% difference (exact: exp(0.50) - 1). The approximation works well for differences under ~0.20.
- **Zeros**: Log(0) is undefined. Common approaches: log(x + 1) for count data (acceptable when values are large relative to 1), inverse hyperbolic sine transformation IHS(x) = ln(x + √(x² + 1)) for data with zeros or negative values.
- **When NOT to log**: Variables that are already rates or percentages; variables where additive differences are the natural comparison (temperature, test scores on a designed scale).

### Position: Percentiles as Tools

Percentiles are among the most informative descriptive statistics. They describe the entire distribution, not just its center or spread:

- **Quintiles (20th, 40th, 60th, 80th)** divide the data into five equal groups — useful for income analysis and equity studies
- **Deciles (10th through 90th)** provide finer resolution — standard in wage and wealth research
- **Specific quantile ratios** (90/10, 90/50, 50/10) compactly describe inequality (see Inequality Measurement section)
- **Percentile tables** — reporting the value at each 5th or 10th percentile — give a richer picture than any single summary statistic

### Principles of Effective Summary Tables

When presenting summary statistics:

1. **Group related variables** — demographics together, outcomes together, controls together
2. **Order meaningfully** — by importance, by variable type, or by the narrative structure
3. **Round consistently** — use the same number of decimal places within a column; typically 1-2 decimals for percentages, 0 for counts, 2 for standard deviations
4. **Label clearly** — full variable names, units, and sample restrictions in notes
5. **Report N** — always show the sample size, especially if it varies across rows (due to missing data)
6. **Consider stratified columns** — show summary statistics by group (e.g., treatment/control, male/female) side by side, with a "difference" or "overall" column

## Subgroup Analysis and Stratification

### Designing Subgroup Comparisons

Not all subgroup comparisons are created equal. The most credible are **a priori** — specified before looking at the data, motivated by theory or prior research. **Exploratory** subgroup analyses are valuable for hypothesis generation but carry multiple comparison risks.

| Type | Motivation | Credibility | Multiple Comparison Concern |
|------|-----------|-------------|----------------------------|
| **A priori** | Theory, prior research, policy relevance | High | Low (pre-specified) |
| **Exploratory** | Data-driven pattern detection | Medium | High (many possible cuts) |
| **Post hoc** | Explaining an unexpected finding | Lower | Very high (cherry-picking risk) |

**Best practice:** Clearly label which subgroup analyses were pre-specified and which emerged during exploration. This is not a judgment — exploratory analysis is valuable — but transparency about the distinction is essential for proper interpretation.

### Stratification by Categorical Variables

Common stratification dimensions and their analytical value:

- **Demographic cuts** (race/ethnicity, gender, age groups): Reveal disparities and differential patterns. When using race/ethnicity categories, be attentive to the categories available in the data and their limitations — administrative categories often mask within-group heterogeneity.
- **Geographic cuts** (state, region, urbanicity): Reveal spatial variation that may reflect policy differences, market conditions, or compositional differences.
- **Temporal cuts** (year, cohort, pre/post period): Reveal trends and structural changes. Be attentive to whether changes reflect real behavioral shifts or changes in measurement/reporting.
- **Institutional cuts** (sector, size, selectivity): Reveal how relationships vary across institutional contexts.

### Effect Sizes for Subgroup Comparisons

When comparing continuous outcomes across groups, report standardized effect sizes alongside raw differences. Raw differences depend on the variable's scale and are hard to compare across studies; standardized effect sizes are scale-free:

- **Cohen's d**: (mean_A - mean_B) / pooled_SD. Conventions: ~0.2 small, ~0.5 medium, ~0.8 large (Cohen 1988). These are rough guidelines — substantive significance depends on context.
- **Hedges' g**: Like Cohen's d but with a small-sample correction. Preferred when group sizes are unequal or small.
- **Glass's delta**: Uses only the control group's SD as the denominator. Preferred when group variances differ substantially.

Always report both the raw difference (in the variable's natural units) and a standardized measure. Confidence intervals on effect sizes communicate precision.

> For effect sizes in regression contexts and interpretation of model coefficients, see `statistical-modeling.md`.

### Conditional Statistics

The conditional expectation E[Y|X=x] — "the average value of Y among observations where X equals x" — is the foundation of subgroup analysis. Following Angrist and Pischke's (2009) framework, the conditional expectation function (CEF) is the best predictor of Y given X in a mean-squared-error sense, regardless of the underlying relationship's functional form.

**Practical implication:** When you compute the mean outcome within subgroups, you are estimating the CEF at those points. A regression with group dummies gives you exactly the same conditional means. Understanding this connection helps you see that subgroup analysis and regression analysis are not fundamentally different activities — regression is a tool for summarizing conditional comparisons.

### Interaction Effects as Descriptive Tools

When the relationship between X and Y differs by Z, this is an interaction. Descriptively, interactions answer questions like: "Does the gender gap in wages vary by education level?" or "Is the relationship between school poverty and test scores different in urban vs. rural areas?"

Interactions can be examined by:
- Computing conditional means within cross-classified groups (e.g., mean wages by gender × education)
- Running regressions with interaction terms (purely as a descriptive tool for summarizing conditional patterns)
- Presenting faceted visualizations that show the X-Y relationship separately for each level of Z

### Aggregation Level and the Ecological Fallacy

When working with data aggregated to the school, district, county, or state level, relationships observed at the aggregate level may not hold at the individual level. This is the **ecological fallacy** — and it is one of the most common interpretive errors in education and policy research.

- **Frame findings at the level of the data**: "Districts with higher poverty rates tend to have lower graduation rates" — not "Poor students graduate at lower rates." The first is a statement about districts; the second is a statement about individuals that the district-level data cannot support.
- **Be explicit about the unit of analysis**: Always state whether statistics describe students, schools, districts, or states. The same research question can yield different answers at different aggregation levels.
- **Compositional vs. contextual effects**: A school-level correlation between poverty and test scores reflects both the individual-level relationship (poor students tend to score lower) and contextual effects (attending a high-poverty school may independently affect scores). Aggregate data conflates these.
- **The Modifiable Areal Unit Problem (MAUP)**: Results can change depending on how geographic boundaries are drawn. County-level patterns may differ from state-level patterns, not because the underlying relationships differ but because aggregation changes the statistical properties.

> For full treatment of spatial aggregation issues, see `geospatial-analysis.md`.

### Education Data Caveat: FRPL as a Poverty Proxy

Free or Reduced-Price Lunch (FRPL) eligibility is the most common school-level poverty measure in U.S. education research, but the **Community Eligibility Provision (CEP)** has made FRPL rates unreliable since 2014-15. Under CEP, schools with ≥ 40% directly certified students can offer free meals to all students, making their reported FRPL rate 100% regardless of actual poverty levels. When stratifying by poverty or constructing poverty indices, consider using SAIPE estimates, MEPS estimates, or direct certification rates instead of FRPL in CEP-era data. See the `education-data-source-meps` and `education-data-source-saipe` skills for alternatives.

### Multiple Comparison Concerns

When conducting many subgroup comparisons, some "significant" differences will appear by chance. This matters more for exploratory analysis than for a priori comparisons. Approaches:

- **Bonferroni correction**: Divide the significance threshold by the number of comparisons. Conservative but simple — and overly conservative when comparisons are correlated (as subgroup comparisons often are, since subgroups share a common complement).
- **Benjamini-Hochberg**: Controls the false discovery rate — less conservative, more appropriate for exploratory work with many comparisons.
- **Reframing**: Instead of testing significance for each subgroup, estimate the magnitude of variation *across* subgroups and report it as a single measure of heterogeneity.
- **Transparency**: Report all comparisons attempted, not just the "significant" ones. Selective reporting of subgroup findings is a form of p-hacking.

### Sample Size Requirements

Subgroup estimates become unreliable when cells get too small. Rules of thumb:

- **Minimum cell size of 30** for means and proportions (CLT-based approximate normality)
- **Minimum cell size of ~100** for percentile estimates (more data needed for distributional tails)
- **Consider collapsing categories** when cells are sparse — combine adjacent groups or use broader categories
- **Report cell sizes** alongside estimates so readers can judge precision
- **Suppress or flag** estimates from very small cells rather than presenting them as comparable to large-cell estimates. Note that federal education data (NCES) has specific suppression rules requiring cells with fewer than 3 (sometimes 5 or 10) students be suppressed to protect privacy — this is a compliance requirement, not just a precision concern.

## Distributional Analysis

### When Distributions Matter More Than Averages

Two groups can have the same mean but very different distributions. Changes over time can reflect shifts in the entire distribution or only in the tails. Inequality is inherently a distributional concept. Whenever the research question involves variation, heterogeneity, or inequality, distributional analysis is essential.

### Kernel Density Estimation

Kernel density estimates (KDEs) provide a smooth approximation of the probability density function. Key considerations:

- **Bandwidth selection**: Too narrow → noisy; too wide → oversmoothed. Silverman's rule-of-thumb is a reasonable default for unimodal distributions. However, Silverman's rule assumes unimodality and can oversmooth multimodal distributions; for data where subpopulations may be present, cross-validation or plug-in bandwidth selection avoids oversmoothing multiple modes. When comparing groups, use the same bandwidth for all groups to ensure visual comparability.
- **Boundary effects**: KDEs can "leak" beyond the data's natural boundaries (e.g., showing negative density for income data). Consider boundary-corrected estimators or log-transforming before estimation.
- **Comparing distributions visually**: Overlay KDEs for two or more groups on the same axis. This reveals differences in location, spread, and shape simultaneously.

### Quantile Analysis

Quantiles provide a complete description of a distribution without assuming any particular functional form:

- **Percentile tables**: Report the value at every 5th or 10th percentile. This gives readers a far richer picture than any set of summary statistics.
- **Quantile ratios**: The 90/10 ratio measures overall inequality; the 90/50 ratio captures upper-tail inequality; the 50/10 ratio captures lower-tail inequality. These are simple, interpretable, and widely used in inequality research.
- **Quantile regression as a descriptive tool**: Rather than estimating E[Y|X], quantile regression estimates Q_τ[Y|X] — the conditional quantile. This reveals whether X's association with Y differs at the bottom vs. top of Y's distribution. For example: does school spending have a larger association with test scores for low-performing students than for high-performing ones?

### Comparing Distributions

| Method | What It Shows | When to Use |
|--------|--------------|-------------|
| **QQ plot** | Plots quantiles of one distribution against another | Checking if two distributions have the same shape; diagnosing departures from normality |
| **Kolmogorov-Smirnov test** | Tests whether two samples come from the same distribution | Formal test of distributional equality; note that with large N, even trivial differences are "significant" |
| **Distribution overlap measures** | Quantifies the fraction of probability mass shared between two distributions | Summarizing how similar two groups are across their entire distributions |
| **Cumulative distribution functions** | Plots the probability of observing a value ≤ x | Comparing distributions at every point simultaneously; identifying stochastic dominance |

### Counterfactual Distributions

A powerful descriptive exercise asks: "What would the distribution of Y look like if group A had group B's characteristics?" This connects to the Oaxaca-Blinder decomposition (see Decomposition Methods) and to DiNardo-Fortin-Lemieux (1996) reweighting. The insight is separating *composition effects* (group A has different X values) from *structural effects* (the X-Y relationship differs between groups).

### Mixture Distributions

When a distribution appears bimodal or has unusual shape, it may reflect distinct subpopulations. Descriptive strategies:

- Examine the distribution separately within known subgroups to see if the mixture resolves
- Look for natural breakpoints or gaps that suggest distinct populations
- Consider whether the data generation process naturally produces mixtures (e.g., combining part-time and full-time workers in a wage distribution)

## Cross-Tabulations and Contingency Analysis

### Constructing Cross-Tabs

Cross-tabulations display the joint distribution of two (or more) categorical variables. Interpretation depends critically on *how you percentagize*:

- **Row percentages**: Show the distribution of column variable *within each level of the row variable*. Use when the row variable is the "grouping" variable and you want to compare distributions across groups.
- **Column percentages**: Show the distribution of row variable *within each level of the column variable*.
- **Cell percentages (of grand total)**: Show each cell as a fraction of the entire table.

**Common mistake:** Percentagizing in the wrong direction. If you want to compare "what fraction of men vs. women have a college degree," you need row percentages (with gender as rows). Column percentages would answer a different question.

### Chi-Squared Tests and Their Limitations

The chi-squared test of independence tests whether two categorical variables are associated. However:

- **Large N makes everything "significant"**: With tens of thousands of observations (common in administrative education data), even trivially small associations produce tiny p-values. The test tells you the association is *non-zero*, not that it is *meaningful*. This warning applies to all hypothesis tests with large administrative datasets — always prioritize effect sizes and substantive interpretation over p-values.
- **The test is omnibus**: It detects *any* departure from independence, without telling you *where* the departure is.
- **Small expected cell counts**: The chi-squared approximation breaks down when expected counts are below 5. Use Fisher's exact test for small samples or sparse tables.

**Recommendation:** Always supplement chi-squared tests with effect size measures and substantive interpretation. A "significant" chi-squared result with Cramer's V < 0.1 is rarely meaningful.

### Effect Size Measures for Categorical Associations

| Measure | Range | Interpretation |
|---------|-------|---------------|
| **Cramer's V** | 0 to 1 | 0 = no association. Conventions depend on degrees of freedom (df = min(rows-1, cols-1)): for df=1 (2×2 tables), 0.1/0.3/0.5 = small/medium/large; for df=2, 0.07/0.21/0.35; for df=3, 0.06/0.17/0.29 (Cohen 1988). Using 2×2 thresholds on larger tables overstates effect sizes. |
| **Phi coefficient (φ)** | -1 to 1 | Only for 2×2 tables; equivalent to Pearson r for two binary variables |
| **Odds ratio** | 0 to ∞ | For 2×2 tables; 1 = no association; interpretable as the multiplicative change in odds |

### Simpson's Paradox

Controlling for a third variable in cross-tabulation means computing the two-way table *separately within each level of the third variable*. This can reveal **Simpson's paradox**: an association that appears in the aggregate may reverse within subgroups (or vice versa).

Simpson's paradox is not rare — it arises whenever group composition shifts across the conditioning variable. A classic education example: a state's overall average test score may rise over a decade even if *every subgroup's* average declines, if the population composition shifts toward higher-scoring subgroups. Conversely, a university's overall admission rate can appear to favor one gender, while every individual department favors the other.

**Decision guidance:** When you observe a surprising aggregate trend or comparison, always check whether it changes direction or magnitude within subgroups before reporting the aggregate finding. If it does, the aggregate is misleading without the subgroup context. The Shift-Share decomposition (see Decomposition Methods) is the formal tool for disentangling within-group changes from compositional shifts.

### Weighted Cross-Tabulations

When data come from complex surveys, cross-tabulations should incorporate survey weights. Weighted percentages estimate population quantities rather than sample quantities. Weighted chi-squared tests (Rao-Scott corrections) account for the survey design. See the Weighted Analysis section for details.

### Rate Calculations

- **Crude rates**: Events ÷ population. Simple but potentially misleading if populations have different compositions. **Always report the denominator** — comparing counts without normalizing by population is one of the most common errors in education data reporting (e.g., "more suspensions in district A than district B" is meaningless without enrollment denominators).
- **Rate ratios**: The ratio of rates in two populations. A rate ratio of 2.0 means the rate is twice as high in one group as the other.
- **Rate differences**: The absolute difference in rates. Important when the policy question is about the absolute number of events, not the relative risk.

### Direct and Indirect Standardization

When comparing rates across populations with different demographic compositions, standardization removes the effect of compositional differences:

| Method | How It Works | When to Use |
|--------|-------------|-------------|
| **Direct standardization** | Apply each population's observed group-specific rates to a common (standard) population structure | When group-specific rates are stable and based on adequate cell sizes |
| **Indirect standardization (SMR/SIR)** | Apply a reference population's group-specific rates to the observed population's structure; compare expected vs. observed totals | When group-specific rates are unstable due to small cell sizes within strata |

For example, comparing graduation rates across school districts with different racial/ethnic compositions: direct standardization reweights each district's race-specific graduation rates to a common racial distribution; indirect standardization asks "given this district's racial composition, how many graduates would we expect based on the state's race-specific rates?"

## Trend Analysis and Time Series Description

### Describing Temporal Patterns

Time series data typically exhibit some combination of:

- **Level**: The overall magnitude at any point in time
- **Trend**: The long-run direction (upward, downward, flat)
- **Seasonality**: Regular periodic fluctuations (monthly, quarterly, academic year)
- **Cyclicality**: Longer-run fluctuations not tied to a fixed period (business cycles)
- **Noise**: Irregular, unpredictable variation

Descriptive time series analysis aims to characterize these components, not forecast or model them causally.

### Moving Averages for Trend Extraction

| Type | How It Works | When to Use |
|------|-------------|-------------|
| **Simple moving average (SMA)** | Unweighted average of the last *k* observations | Quick smoothing; all observations equally weighted |
| **Weighted moving average (WMA)** | More recent observations get higher weight | When recent values are more relevant |
| **Exponential moving average (EMA)** | Exponentially decaying weights | Responsive to recent changes; widely used in finance |

**Window selection:** The moving average window should match the periodicity you want to smooth out. For monthly data with annual seasonality, a 12-month moving average removes the seasonal component and reveals the trend.

### Year-over-Year and Period-over-Period Comparisons

Comparing the same period across years (January 2024 vs. January 2023) naturally controls for seasonality. This is often the simplest and most interpretable approach for seasonal data.

### Growth Rates

| Measure | Formula (conceptual) | When to Use |
|---------|---------------------|-------------|
| **Simple growth rate** | (V_t - V_{t-1}) / V_{t-1} | Short-run, single-period changes |
| **Compound annual growth rate (CAGR)** | (V_end / V_start)^{1/years} - 1 | Smoothed multi-year growth; removes year-to-year volatility |
| **Log-difference** | ln(V_t) - ln(V_{t-1}) | Approximately equals growth rate for small changes; symmetric for gains/losses; additive over time |

**Log-differences are preferred** in much of economics because they are additive (growth from year 1 to 3 = growth from 1 to 2 + growth from 2 to 3) and approximately symmetric (a 10% gain and 10% loss have approximately equal magnitude in log points).

### Structural Breaks

A structural break is a point at which the data-generating process changes. Descriptive indicators include:

- **Visual identification**: Plot the series and look for abrupt changes in level or trend
- **Chow test**: Tests whether regression coefficients differ before and after a hypothesized break date. Requires specifying the break date a priori.
- **Quandt-Andrews / supremum Wald test**: Searches for the most likely break date within a range. Useful when the break point is unknown.

Structural breaks are important to identify before computing long-run trends or averages, since aggregating across a break obscures different regimes.

### Seasonal Adjustment

For descriptive purposes, simple approaches often suffice:

- **Ratio-to-moving-average**: Divide each observation by its centered moving average to extract the seasonal component
- **Month/quarter dummies**: Regress on period indicators and examine the residuals
- **Year-over-year comparisons**: Sidestep seasonality entirely by comparing same-period values

More sophisticated methods (X-13ARIMA-SEATS, STL decomposition) exist but are typically unnecessary for descriptive work that reports both raw and seasonally adjusted values.

### Presenting Trends

- **Indexed series** (base year = 100): Puts different series on a common scale for visual comparison. Essential when comparing variables with different units or magnitudes. Choose the base year carefully — it anchors all visual comparisons, so select a year that is representative (not an outlier) and meaningful for the research context.
- **Small multiples**: Show the same type of plot for many subgroups (states, demographic groups) in a grid. Effective for spotting patterns across many groups simultaneously.
- **Highlighted lines**: In a spaghetti plot (many overlapping lines), highlight 1-3 series of interest and gray out the rest. This prevents visual overload while maintaining context.

> For chart design principles and visual encoding guidance, see `visualization-design.md`. For color, labeling, and export standards, see `visualization-execution.md`.

## Decomposition Methods

Decomposition methods partition an observed difference or change into interpretable components. Each method answers a specific type of question. They are descriptive tools — they identify *what accounts for* a gap, not *what causes* it.

### Oaxaca-Blinder Decomposition

**What it does:** Decomposes the gap in mean outcomes between two groups (A and B) into:
- **Explained (composition) component**: How much of the gap is due to group differences in observable characteristics (X). "If group A had the same characteristics as group B, how much of the gap would close?"
- **Unexplained (structure/coefficients) component**: How much is due to group differences in the returns to those characteristics (β). Often loosely interpreted as "discrimination" in wage gap studies, but this is an overstatement — it captures *everything* not explained by the included covariates.

**Originally developed by:** Oaxaca (1973) and Blinder (1973), independently, for studying male-female wage differentials.

**Applications:** Wage gaps (gender, race), achievement gaps in education, health outcome disparities, any setting where you want to understand *why* two groups have different average outcomes.

**Key caveat:** The decomposition depends on which group's coefficients are used as the reference (the "index number problem"). Neumark (1988) and Cotton (1988) proposed pooled-coefficient approaches, but the choice remains consequential. Always report results using both groups' coefficients as the reference, or use a pooled specification, and discuss the sensitivity.

**Detailed decomposition pitfall:** When breaking the unexplained component into individual variable contributions, the results for categorical variables depend on which category is omitted as the reference group. This is a well-known identification problem — individual contributions in the "detailed" unexplained decomposition are not invariant to the choice of omitted category. Report the aggregate unexplained component (which is invariant) and interpret detailed contributions with caution.

### Kitagawa Decomposition

**What it does:** Decomposes the difference in aggregate rates between two populations into:
- **Composition effect**: How much of the difference is due to the populations having different demographic compositions
- **Rate effect**: How much is due to different group-specific rates within each demographic category

**Originally developed by:** Kitagawa (1955) for demographic rate comparisons.

**Applications:** Comparing mortality rates, graduation rates, or any aggregate rate across populations with different demographic structures. For example: "Is state A's higher graduation rate due to having a different mix of students (composition) or higher graduation rates within each student group (rate)?"

**Key distinction from Oaxaca-Blinder:** Kitagawa decomposes *rates* (not regression-based means) and uses actual group-specific rates rather than regression coefficients. It is the right tool when you have cross-tabulated rates rather than microdata.

### Gelbach Decomposition

**What it does:** Decomposes the change in a regression coefficient when additional controls are added. Specifically, if the coefficient on X changes from β_short to β_long when you add controls Z₁, Z₂, ..., Zₖ, Gelbach's method tells you exactly how much of that change is attributable to *each* control variable (Gelbach 2016).

**Applications:** Understanding which controls explain the most of a raw gap. For example: "The raw wage gap between men and women is 25%. Adding occupation controls reduces it to 15%. Adding industry controls reduces it further to 12%. How much does each control contribute?"

**Advantage over sequential decomposition:** The naive approach — adding controls one at a time and observing the coefficient change — is path-dependent (the order you add controls matters). Gelbach's decomposition is order-invariant because it decomposes the total change using the omitted variable bias formula applied to the full (long) regression.

### Shift-Share Decomposition

**What it does:** Decomposes an aggregate change over time into:
- **Within-group (rate) change**: Changes in outcomes within each group, holding composition constant
- **Between-group (composition) change**: Changes in the share of the population in each group, holding rates constant
- **Interaction term**: The joint effect of changing rates and changing shares

**Applications:** Understanding whether aggregate trends reflect changing behavior or changing composition. For example: "National college enrollment rates rose by 5 percentage points. Was this because enrollment rates rose within each demographic group (within effect), because the population shifted toward higher-enrolling demographic groups (between effect), or both?"

**Connection to Simpson's paradox:** When the between-group (composition) effect dominates and runs in the opposite direction from within-group trends, you get Simpson's paradox — the aggregate trend reverses or obscures the subgroup-level story.

### Choosing the Right Decomposition

| Question | Method |
|----------|--------|
| "Why do groups A and B have different average outcomes?" | Oaxaca-Blinder |
| "Why do populations A and B have different aggregate rates?" | Kitagawa |
| "Which controls explain the most of a raw regression gap?" | Gelbach |
| "Is an aggregate trend driven by within-group change or compositional shift?" | Shift-Share |

> For a comprehensive survey of decomposition methods, see Fortin, Lemieux, and Firpo (2011).

## Index Construction and Composite Measures

### Why Construct Indices?

When a concept (poverty, school quality, neighborhood advantage) cannot be measured by a single variable, researchers construct composite indices from multiple indicators. The key challenge is making construction choices transparent and defensible.

### Normalization Methods

Before combining variables, they must be put on a common scale:

| Method | Formula (conceptual) | Properties | When to Use |
|--------|---------------------|------------|-------------|
| **Z-score** | (x - mean) / SD | Mean 0, SD 1; preserves relative distances | When variable distributions are roughly symmetric |
| **Min-max** | (x - min) / (max - min) | Scales to [0, 1]; sensitive to outliers | When you want a bounded scale; when absolute position matters |
| **Rank-based** | rank(x) / N | Uniform on [0, 1]; robust to outliers | When distributions are highly skewed; when ordinal position matters more than cardinal distance |
| **Percentile rank** | fraction of observations ≤ x | Interpretable as "better than X% of observations" | Communicating results to non-technical audiences |

**Directionality alignment:** Before combining, ensure all components point the same direction (e.g., higher = better for all components, or higher = worse for all). Reverse-code as needed. Failing to align directionality produces a nonsensical index — this is easy to overlook and difficult to detect after the fact.

### Choosing Weights

Composite indices require weights for each component. This is often the most consequential design choice:

- **Equal weights**: Default when there is no theoretical or empirical basis for differential weighting. Simple and transparent. Defensible when components are genuinely equally important.
- **Theory-driven weights**: Based on domain knowledge or prior research about relative importance. More defensible but requires explicit justification.
- **PCA-derived weights**: Use the first principal component's loadings as weights. Data-driven, but the first PC captures *variance*, not necessarily *importance*. Components with more variation get more weight, which may or may not align with the construct you are measuring.
- **Expert elicitation**: Survey domain experts for weights. Labor-intensive but defensible for high-stakes applications.

### Principal Component Analysis (PCA) for Index Construction

> **Cross-reference:** This section covers PCA as a tool for constructing index weights — a specific application within descriptive analysis. For PCA as a general-purpose dimension reduction and exploratory tool (including how many components to retain, parallel analysis, and the PCA vs. factor analysis distinction), see `exploratory-unsupervised.md`.

PCA identifies linear combinations of variables that capture the most variance. When used for index construction:

- The **first principal component** is often used as the index. It captures the dimension of maximum variation across the input variables.
- **Factor loadings** show how much each input variable contributes to the index. Report these for transparency.
- **Variance explained**: Report the fraction of total variance captured by the first component. If it is low (< 40%), a single index may not adequately represent the underlying construct.
- **Rotation**: For indices, unrotated PCA is standard. Rotation (varimax, promax) is more relevant for factor analysis with multiple latent constructs.

### Reliability and Validity

- **Cronbach's alpha**: Measures internal consistency — do the components tend to agree? Values above 0.7 are conventionally acceptable. However, alpha increases mechanically with the number of components, so it is a necessary but not sufficient indicator of a good index.
- **Factor loadings**: Components should load reasonably strongly (> 0.3) on the common factor. Weak loadings suggest a component does not measure the same construct.
- **Face validity**: Does the index rank observations in a way that makes intuitive sense? Examine specific cases at the top, middle, and bottom.
- **Convergent validity**: Does the index correlate as expected with known related measures?

### Transparency Requirements

When reporting composite indices:

1. **Always report individual components alongside the composite** — readers should be able to see what drives the index value for any observation
2. **Document every construction choice** — normalization method, weighting scheme, handling of missing components
3. **Report sensitivity to choices** — does the ranking change substantially with different weights or normalization?
4. **Provide the formula** — explicitly state how the index is computed so others can replicate it
5. **Handle missing components explicitly** — if one of the component variables is missing for some observations, decide whether to drop those observations, impute, or compute the index from available components (with appropriate flagging). Document the choice and its implications.

## Weighted Analysis

### Types of Weights

Not all weights serve the same purpose. Using the wrong type of weight is a common and consequential error.

| Weight Type | Purpose | When to Use |
|-------------|---------|-------------|
| **Survey (sampling) weights** | Adjust for unequal probability of selection in complex survey designs | Any analysis of survey data with stratification, clustering, or oversampling (e.g., NCES surveys, ACS) |
| **Population weights** | Scale sample estimates to population totals | When each observation represents a different number of units (e.g., district-level data where districts vary in size) |
| **Frequency weights** | Each observation represents multiple identical units | Collapsed/aggregated data where a count variable indicates how many units share identical values |
| **Analytic (precision) weights** | Weight inversely proportional to the variance of the observation | When observations have different precision (e.g., estimates based on different sample sizes) |
| **Inverse probability weights (IPW)** | Adjust for non-response, attrition, or selection into treatment | When the sample has non-random selection that you can model using observables |

### Common Errors

- **Ignoring weights in survey data**: Produces biased estimates of population parameters when the survey design involves oversampling (as most federal surveys do)
- **Applying weights to census data**: CCD and IPEDS universe files are censuses, not samples — applying survey weights to them produces incorrect standard errors. Use unweighted analysis for census data.
- **Using weights when not needed**: If the analysis conditions on the same variables that determine sampling probability, weights may be unnecessary and even harmful (Solon, Haider, and Wooldridge 2015)
- **Normalizing weights incorrectly**: Survey packages typically handle this, but manual weight application requires ensuring weights sum to the target population (or to N, depending on the analysis)
- **Forgetting weighted standard errors**: Weighting affects not just point estimates but also standard errors. Using weighted means with unweighted standard errors understates uncertainty

### Weighted Means and Standard Errors

- **Weighted mean**: Σ(w_i × y_i) / Σ(w_i)
- **Weighted standard error**: Accounts for both the weights and the survey design (stratification, clustering). Analytical formulas exist for simple designs; for complex surveys, use linearization (Taylor series) or replicate weight methods (BRR, jackknife). Many NCES surveys provide replicate weights, which simplify variance estimation — consult the survey's technical documentation for the specific weight variable names and design variables.

### Design Effects and Effective Sample Sizes

- The **design effect (DEFF)** is the ratio of the variance under the actual survey design to the variance under simple random sampling. DEFF > 1 means clustering or stratification inflates variance.
- The **effective sample size** is N / DEFF. A survey with N = 10,000 and DEFF = 2.5 has the statistical precision of a simple random sample of 4,000.
- Always report effective sample sizes alongside actual sample sizes when using complex survey data.

### Domain (Subpopulation) Estimation

When computing weighted statistics for a subgroup (e.g., female students, low-income households), you must NOT filter the dataframe before analysis. Correct survey variance estimation requires information about the full design — all strata and all PSUs. Filtering the data first may drop entire PSUs or strata, corrupting the variance estimates and producing standard errors that are too small.

**The correct approach:** Use your survey software's domain/subpopulation mechanism, which retains the full design structure but zeros out contributions from out-of-domain observations for the point estimate. For implementation details, load the `svy` skill. For a thorough treatment of why this matters and what goes wrong, see `./survey-analysis.md`.

This rule applies to all survey-weighted analyses: descriptive statistics, cross-tabulations, and regression. It is one of the most common and most consequential errors in applied survey research.

### Replicate Weights

Many federal surveys provide **replicate weight columns** alongside the main analysis weight (e.g., ACS PUMS provides 80, CPS ASEC provides 160, MEPS provides 128). Replicate weights are constructed from the true (internal) survey design before disclosure avoidance masking, so they produce more accurate variance estimates than Taylor linearization with the (possibly perturbed) public-use design variables.

**Practical rule:** If the data file provides replicate weights, prefer them over Taylor linearization. Load the `svy` skill for implementation syntax. For the full conceptual treatment of variance estimation methods, see `./survey-analysis.md`.

### Weighted Percentiles

Computing weighted percentiles is less straightforward than weighted means. The standard approach interpolates the empirical CDF using the weights. Most statistical packages implement this, but be aware that different packages may use slightly different interpolation methods, which can affect results at the tails.

### Further Reading

For comprehensive guidance on complex survey analysis methodology — including survey design anatomy, weight selection, variance estimation methods, plausible values, and a pitfalls checklist — see `./survey-analysis.md`. For implementation syntax, load the `svy` skill.

## Inequality Measurement

### Gini Coefficient

The Gini coefficient is the most widely reported inequality measure:

- **Range**: 0 (perfect equality — everyone has the same value) to 1 (perfect inequality — one unit has everything)
- **Interpretation**: Can be understood as the expected absolute difference between two randomly chosen observations, divided by twice the mean
- **Lorenz curve visualization**: The Gini equals twice the area between the Lorenz curve and the 45-degree line of perfect equality
- **Limitations**: The Gini is more sensitive to changes in the middle of the distribution than in the tails. Two very different distributions can have the same Gini. It also does not decompose cleanly by population subgroups.

### Theil Index

The Theil index (specifically, Theil's T) has a crucial property the Gini lacks — **exact decomposability**:

- **Total inequality = between-group inequality + within-group inequality**
- This allows you to answer: "How much of total income inequality is between states vs. within states?"
- Two variants: Theil T (GE(1), more sensitive to upper tail) and Theil L (GE(0), the mean log deviation, more sensitive to lower tail)
- The ratio (between-group / total) measures how much of overall inequality is explained by the grouping variable

### Coefficient of Variation as an Inequality Measure

The CV (SD/mean) also belongs to the Generalized Entropy family: GE(2) = CV²/2. It is more sensitive to upper-tail changes than either Theil T or Theil L, making it appropriate when top-end inequality is the focus. Its advantage over other GE measures is intuitive interpretability — it expresses dispersion as a fraction of the mean.

### Percentile Ratios

Percentile ratios are the simplest and most interpretable inequality measures:

| Ratio | What It Captures | Example Interpretation |
|-------|-----------------|----------------------|
| **90/10** | Overall inequality — the gap between rich and poor | "The 90th percentile earns X times the 10th percentile" |
| **90/50** | Upper-tail inequality — the gap between rich and middle | "How far the top pulls away from the middle" |
| **50/10** | Lower-tail inequality — the gap between middle and poor | "How far the bottom falls behind the middle" |

**Advantage over the Gini:** Percentile ratios tell you *where* in the distribution inequality is concentrated. The Gini cannot distinguish between a society where the rich are very rich (high 90/50) and one where the poor are very poor (high 50/10).

### Spatial Inequality

Following Rey, Arribas-Bel, and Wolf (2023), spatial inequality adds a geographic dimension:

- **Spatial Gini**: Computes the Gini coefficient across geographic units (counties, states, regions)
- **Regional decomposition**: Using the Theil index's decomposability, partition national inequality into between-region and within-region components
- **Spatial autocorrelation of inequality**: Do high-inequality areas cluster together? Moran's I applied to inequality measures reveals spatial patterning

> For spatial analysis methodology, see `geospatial-analysis.md`.

### Presenting Inequality

- **Lorenz curves**: Plot the cumulative share of the outcome (y-axis) against the cumulative share of the population sorted from lowest to highest (x-axis). The further the curve bows from the 45-degree line, the greater the inequality.
- **Growth incidence curves**: Plot the growth rate at each percentile. Reveals whether growth was pro-poor (higher growth at lower percentiles) or pro-rich.
- **Quantile plots**: Show the value at each percentile over time or across groups. Effective for showing distributional shifts.

> For chart design principles and accessibility standards for these specialized plots, see `visualization-design.md` and `visualization-execution.md`.

## Correlation and Association

### Pearson Correlation

Measures the strength of the **linear** association between two continuous variables:

- **Range**: -1 (perfect negative linear relationship) to +1 (perfect positive linear relationship); 0 = no linear association
- **Assumptions**: Both variables are continuous; the relationship is linear; both are approximately normally distributed (for inference)
- **Confidence intervals**: Always report. A correlation of r = 0.3 with a 95% CI of [0.05, 0.52] tells a very different story than r = 0.3 with CI [0.28, 0.32].
- **Common conventions**: |r| < 0.3 weak, 0.3-0.7 moderate, > 0.7 strong. But these are rough guidelines — substantive significance depends on context.

### Spearman Rank Correlation

Measures the strength of the **monotonic** (not necessarily linear) association:

- Computed on ranks rather than raw values, making it robust to outliers and non-normality
- Appropriate for ordinal data or when the relationship is monotonic but nonlinear
- Comparing Pearson vs. Spearman can diagnose nonlinearity: if Spearman is substantially higher, the relationship exists but is not well captured by a line

### Partial Correlation

The association between X and Y **after removing the linear effect of Z from both**:

- Answers: "Is there still an association between X and Y once we account for Z?"
- Conceptually equivalent to correlating the residuals from two regressions: Y on Z, and X on Z (this is the Frisch-Waugh-Lovell insight applied to correlation)
- Essential for understanding whether a bivariate association is confounded by a third variable

### Conditional Correlation

How the X-Y relationship varies across levels of Z:

- Distinct from partial correlation: partial correlation removes Z; conditional correlation *stratifies by* Z
- Computed by calculating the X-Y correlation separately within each level of Z
- Connects to subgroup analysis (see above) — it is subgroup analysis applied to correlations

### Correlation Matrices

When presenting correlations among many variables:

- **Heatmaps**: Color intensity represents correlation magnitude. Effective for spotting blocks of highly correlated variables.
- **Ordering strategies**: Cluster correlated variables together using hierarchical clustering on the correlation matrix. This reveals structure that alphabetical ordering obscures.
- **Highlighting significance**: Use symbols (*, **, ***) or only color cells that are statistically significant. But remember: with many variables, some spurious correlations will be "significant."

### The Fundamental Warning

Correlation is not causation. This is stated so often it risks becoming a platitude, but it has specific practical implications:

- A correlation between X and Y could reflect X→Y, Y→X, Z→X and Z→Y (confounding), or coincidence
- **Language matters**: Use "associated with," "correlated with," "corresponds to" — not "affects," "impacts," or "leads to." See `research-questions.md` > "Causal vs. Correlational Language" for the full language guide.
- Even strong correlations (r > 0.8) do not imply causation. The correlation between per-capita cheese consumption and deaths by bedsheet tangling is famously high.

> For guidance on when and how to make causal claims, see `causal-inference.md`.

## Missing Data Characterization

### Three Mechanisms of Missingness

Understanding *why* data are missing determines how (and whether) the missingness can be handled:

| Mechanism | Definition | Implication | Example |
|-----------|-----------|-------------|---------|
| **MCAR** (Missing Completely At Random) | Missingness is unrelated to any variable — observed or unobserved | Complete cases are a random subsample; listwise deletion is unbiased (though less efficient) | A lab instrument randomly malfunctions |
| **MAR** (Missing At Random) | Missingness depends on observed variables but not on the missing values themselves | Can be corrected through imputation or weighting using the observed predictors of missingness | Higher-income respondents are more likely to skip the income question, but you observe their education, which predicts both income and non-response |
| **MNAR** (Missing Not At Random) | Missingness depends on the unobserved missing values | No fully satisfactory correction; requires assumptions about the missingness process | People with the highest incomes are most likely to refuse to report income — the missingness *is* related to the value itself |

### Diagnosing the Mechanism

No statistical test can definitively distinguish MAR from MNAR (because by definition you cannot observe the missing values). However, you can gather evidence:

- **Little's MCAR test**: Tests whether the pattern of missingness depends on observed values. Rejection suggests not MCAR, but does not distinguish MAR from MNAR.
- **Pattern analysis**: Examine which variables tend to be missing together. Correlated missingness suggests a common cause.
- **Comparing complete vs. incomplete cases**: If observations with missing values differ systematically on *observed* characteristics, the data are at minimum not MCAR. Compare means, distributions, and proportions.
- **Domain knowledge**: Understanding the data collection process is the most powerful diagnostic. Why might values be missing? Does the reason plausibly depend on the missing value itself?

As Huntington-Klein (2022, Ch. 23) emphasizes, the missingness mechanism is ultimately an assumption about the world, not something the data can prove. The goal of the diagnostic exercise is to make your assumption as informed as possible and to be transparent about it.

### Missingness Severity Thresholds

| Missingness Level | Concern | Recommended Action |
|-------------------|---------|--------------------|
| **< 5%** | Low | Listwise deletion usually acceptable under MCAR; document and proceed |
| **5-15%** | Moderate | Investigate mechanism; if MAR, consider multiple imputation; if MCAR, listwise deletion is acceptable but less efficient |
| **15-30%** | High | Results sensitive to assumptions; multiple imputation recommended under MAR; sensitivity analysis mandatory |
| **> 30%** | Very high | Variable should generally not serve as a primary outcome or key covariate; if unavoidable, bound results under MCAR/MAR/MNAR assumptions |

These are guidelines, not rigid rules. A 20% missingness rate in a variable that is MCAR by design (e.g., a random subsample received a supplemental survey module) is less concerning than 5% missingness that is clearly MNAR.

### Implications for Analysis by Mechanism

| Mechanism | Listwise Deletion | Simple Imputation (mean/median) | Multiple Imputation | Sensitivity Analysis |
|-----------|-------------------|-------------------------------|--------------------|--------------------|
| **MCAR** | Unbiased but less efficient | Biases variance downward | Works well | Unnecessary if N is large |
| **MAR** | Biased if missingness correlates with outcome | Biased | Appropriate — the gold standard | Recommended to assess robustness |
| **MNAR** | Biased | Biased | Biased (assumptions violated) | Essential — bound the bias under alternative assumptions |

### Reporting Requirements

For any analysis, always report:

1. **Missingness rates by variable**: What fraction of observations is missing for each variable used in the analysis?
2. **Patterns of co-missingness**: Do variables tend to be missing together? Are there observations that are missing on many variables?
3. **Evidence on the mechanism**: What diagnostic steps were taken? What is the assumed mechanism and why?
4. **How missingness was handled**: Listwise deletion, imputation, or another approach? Justify the choice.
5. **Sensitivity**: How would conclusions change under alternative assumptions about the missing data mechanism?

## Sample Description and Representativeness

### Sample vs. Population

Every analysis should clearly state:

- **Target population**: Who is the analysis intended to say something about?
- **Sampling frame**: What is the list from which the sample was drawn?
- **Sample**: What observations are actually in the data?
- **Analytic sample**: What observations remain after applying all inclusion/exclusion criteria?

Each transition — from population to sampling frame to sample to analytic sample — can introduce selection that affects the generalizability of findings.

### Comparing Sample to Known Benchmarks

When possible, compare sample characteristics to known population values:

- For school-level data: compare to NCES enrollment totals, school counts by type, urbanicity distribution
- For college-level data: compare to IPEDS universe counts by sector, size, selectivity
- For individual-level data: compare to Census/ACS demographic distributions

Systematic differences indicate that the sample is not representative of the target population on those dimensions. This does not necessarily invalidate the analysis, but it must be documented and its implications discussed.

### Coverage Analysis

Ask: "What fraction of the target population does the sample represent?" This is especially important for administrative data, which covers the universe of some populations but not others:

- IPEDS covers all Title IV institutions but not institutions that do not participate in federal financial aid programs
- CCD covers all public schools but not private schools
- CRDC covers all public schools but only in survey years, and with varying response rates by school

### Selection into the Sample

Understanding the process that generated the observed data is critical for interpretation:

- **Administrative selection**: Data exists only for individuals who interacted with a system (enrolled in a school, filed a tax return, received a service). Non-participants are invisible.
- **Survey non-response**: Even in well-designed surveys, non-response is typically non-random. Higher-SES, more-educated individuals tend to respond at higher rates.
- **Attrition**: In longitudinal data, who drops out over time? If dropout is related to the outcome of interest, the remaining sample becomes increasingly unrepresentative.

### Survivorship Bias

When analyzing entities that persist over time (schools that remain open, firms that survive, students who graduate), the observable sample at any point excludes entities that have exited. Trends computed on surviving entities alone can be misleading — apparent improvement may reflect attrition of worse-performing cases rather than genuine improvement among those that persist.

**Decision guidance:** Always ask "Who has dropped out of this sample over time, and how might their exclusion affect the pattern I observe?" Report the number of entities entering and exiting the sample in each period. Consider whether findings are driven by changes among stayers or by selective attrition.

### Table 1: The Standard Sample Characteristics Table

The "Table 1" convention (common in health and social science research) presents:

- **Demographics**: Key demographic variables with means/percentages and standard deviations
- **Outcomes**: Summary statistics of the outcome variables
- **Key covariates**: Variables that will be used in the analysis
- **By group**: If the analysis compares groups (treatment/control, male/female, urban/rural), show columns for each group plus an overall column
- **Difference test**: Optionally include p-values for group differences, though this is falling out of favor (especially in RCTs where randomization guarantees balance in expectation)
- **Formatting conventions**: Report continuous variables as mean (SD) or median (IQR) depending on distribution (see Summary Statistics section); report categorical variables as N (%); report N for each variable when it differs due to missing data

### Reporting Sample Flow

Report sample sizes at each stage of analysis:

```
Full dataset:           N = 100,000 schools
After excluding territories: N = 98,500
After requiring enrollment data: N = 95,200
After requiring poverty data:   N = 91,800
Final analytic sample:          N = 91,800
```

This "flow diagram" (or CONSORT diagram in clinical research) makes transparent how the analytic sample was constructed and what was lost at each step. Readers can then assess whether the exclusions might introduce bias.

## References and Further Reading

### Foundational Textbooks

Angrist, J.D. and Pischke, J.-S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press. https://www.mostlyharmlesseconometrics.com/

Angrist, J.D. and Pischke, J.-S. (2015). *Mastering 'Metrics: The Path from Cause to Effect*. Princeton University Press. https://www.masteringmetrics.com/

Cunningham, S. (2021). *Causal Inference: The Mixtape*. Yale University Press. https://mixtape.scunning.com/

Huntington-Klein, N. (2022). *The Effect: An Introduction to Research Design and Causality*. Chapman & Hall/CRC. https://theeffectbook.net/

### Effect Sizes

Cohen, J. (1988). *Statistical Power Analysis for the Behavioral Sciences*. 2nd edition. Lawrence Erlbaum Associates.

### Decomposition Methods

Blinder, A.S. (1973). "Wage Discrimination: Reduced Form and Structural Estimates." *Journal of Human Resources*, 8(4), 436-455.

Cotton, J. (1988). "On the Decomposition of Wage Differentials." *Review of Economics and Statistics*, 70(2), 236-243.

Fortin, N., Lemieux, T., and Firpo, S. (2011). "Decomposition Methods in Economics." *Handbook of Labor Economics*, Vol. 4A, 1-102.

Gelbach, J.B. (2016). "When Do Covariates Matter? And Which Ones, and How Much?" *Journal of Labor Economics*, 34(2), 509-543.

Kitagawa, E.M. (1955). "Components of a Difference Between Two Rates." *Journal of the American Statistical Association*, 50(272), 1168-1194.

Neumark, D. (1988). "Employers' Discriminatory Behavior and the Estimation of Wage Discrimination." *Journal of Human Resources*, 23(3), 279-295.

Oaxaca, R. (1973). "Male-Female Wage Differentials in Urban Labor Markets." *International Economic Review*, 14(3), 693-709.

### Inequality and Spatial Analysis

Cowell, F.A. (2011). *Measuring Inequality*. 3rd edition. Oxford University Press.

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*. CRC Press. https://geographicdata.science/book/

### Survey Methods and Weighting

Solon, G., Haider, S.J., and Wooldridge, J.M. (2015). "What Are We Weighting For?" *Journal of Human Resources*, 50(2), 301-316.

### Missing Data

Little, R.J.A. and Rubin, D.B. (2019). *Statistical Analysis with Missing Data*. 3rd edition. Wiley.

### Counterfactual Distributions

DiNardo, J., Fortin, N.M., and Lemieux, T. (1996). "Labor Market Institutions and the Distribution of Wages, 1973-1992: A Semiparametric Approach." *Econometrica*, 64(5), 1001-1044.
