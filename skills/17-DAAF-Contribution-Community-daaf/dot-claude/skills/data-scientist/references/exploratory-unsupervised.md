# Exploratory Unsupervised Analysis

Methodological guidance for exploratory unsupervised analysis — discovering structure, groupings, and patterns in data without pre-specified outcome variables. This reference covers the *why* and *when* of unsupervised methods. For implementation syntax, load the `scikit-learn` skill.

**When to read this file:** Stage 8 analysis tasks involving clustering, typology construction, dimension reduction, mixture models, or any task where the goal is discovering structure rather than testing hypotheses about known relationships.

**Relationship to other references:**
- For PCA as an *index construction* tool (creating composite measures), see `./descriptive-analysis.md` > "Index Construction and Composite Measures"
- For causal vs. correlational language guidance more broadly, see `./research-questions.md`
- For regression and model selection, see `./statistical-modeling.md`
- For causal identification strategies, see `./causal-inference.md`
- **Scope boundary:** This file covers unsupervised and exploratory methods only. Supervised ML methods (classification, regression trees, ensemble methods, cross-validation) are reserved for a future reference file.

## Acknowledgments

These materials draw extensively from several open-access resources that the authors have generously made available to the research community:

- Gareth James, Daniela Witten, Trevor Hastie, and Robert Tibshirani's *An Introduction to Statistical Learning* (https://www.statlearning.com/), particularly Chapter 12 on unsupervised learning
- Trevor Hastie, Robert Tibshirani, and Jerome Friedman's *The Elements of Statistical Learning* (https://hastie.su.domains/ElemStatLearn/download.html), particularly Chapter 14 on unsupervised learning
- The scikit-learn project's comprehensive documentation and user guide (https://scikit-learn.org/)
- Martin Wattenberg, Fernanda Viegas, and Ian Johnson's interactive guide "How to Use t-SNE Effectively" (https://distill.pub/2016/misread-tsne/)

## Contents

- [Quick Task Lookup](#quick-task-lookup)
- [When Unsupervised Methods Are the Right Approach](#when-unsupervised-methods-are-the-right-approach)
- [Cluster Analysis](#cluster-analysis)
- [Dimension Reduction: PCA as an Exploratory Tool](#dimension-reduction-pca-as-an-exploratory-tool)
- [Nonlinear Embeddings: t-SNE and UMAP](#nonlinear-embeddings-t-sne-and-umap)
- [Gaussian Mixture Models](#gaussian-mixture-models)
- [The Classify-Analyze Problem](#the-classify-analyze-problem)
- [Causal Language Warnings for Unsupervised Methods](#causal-language-warnings-for-unsupervised-methods)
- [References and Further Reading](#references-and-further-reading)

## Quick Task Lookup

| If the plan says... | Read this section |
|---------------------|-------------------|
| "identify groups," "construct typology," "classify units" | Cluster Analysis |
| "reduce dimensions," "simplify variable set" | Dimension Reduction (PCA) |
| "visualize high-dimensional data" | Nonlinear Embeddings (t-SNE, UMAP) |
| "model-based clustering," "soft assignments" | Gaussian Mixture Models |
| "validate clusters," "assess stability" | Cluster Analysis > Cluster Validation |
| "use clusters in regression," "cluster membership as predictor" | The Classify-Analyze Problem |

## When Unsupervised Methods Are the Right Approach

### Unsupervised vs. Supervised: A Complementary Pair

Supervised methods predict known outcomes; unsupervised methods discover unknown structure. This is not a quality hierarchy — unsupervised analysis is independently valuable. Much important social science research is fundamentally about discovering structure: typologies of schools, profiles of students, dimensions of inequality.

Unsupervised methods are **descriptive**. They identify patterns in observed data, not causes. Following Hennig's (2015) important argument, there is no single definition of "true clusters" — what constitutes a valid grouping depends on the research aims, the variables chosen, and the algorithm applied. A clustering is not "right" or "wrong" in the way a causal estimate can be biased or unbiased; it is more or less *useful* for a given purpose.

### When Unsupervised Analysis IS the Research Contribution

| Goal | Example |
|------|---------|
| **Typology construction** | What types of school districts exist based on demographics, resources, and outcomes? |
| **Data reduction** | Can 50 correlated socioeconomic indicators be reduced to a manageable set of dimensions? |
| **Subpopulation discovery** | Are there distinct profiles of college student engagement? |
| **Anomaly detection** | Which schools are statistical outliers across multiple dimensions? |
| **Hypothesis generation** | What groupings in the data suggest new research questions? |

In each case, the research contribution is *discovering and characterizing structure* — not testing a pre-specified hypothesis about known relationships.

### When Unsupervised Methods Precede Supervised Analysis

Unsupervised methods often serve as a preparatory step before supervised or confirmatory analysis:

- **Dimension reduction before regression**: PCA to address multicollinearity or reduce a large covariate set to a small number of components
- **Cluster membership as a predictor**: Using group assignments in subsequent regression — but with proper caveats (see [The Classify-Analyze Problem](#the-classify-analyze-problem))
- **Exploratory grouping to motivate subgroup analysis**: Discovering empirical groupings that inform subsequent causal designs or stratified analyses

The critical discipline is maintaining the boundary between *discovering* a pattern and *confirming* it. When unsupervised results are used to generate hypotheses, those hypotheses should ideally be tested on held-out data or in subsequent studies.

## Cluster Analysis

### Algorithm Selection

The choice of clustering algorithm is consequential — different algorithms impose different assumptions about cluster shape, size, and density. Following Everitt et al. (2011), there is no universally best algorithm; the choice should be guided by the data structure and research question.

| Algorithm | Best For | Assumptions | Key Parameters |
|-----------|----------|-------------|----------------|
| K-means | Large N; spherical, equal-size clusters | Spherical; equal variance; continuous data | k (number of clusters) |
| K-medoids (PAM) | Small-to-medium N; robust to outliers; any distance | Convex clusters | k; distance metric |

> **Implementation note:** K-medoids/PAM is not available in scikit-learn core. Use `sklearn_extra.cluster.KMedoids` from the `scikit-learn-extra` package, or the standalone `kmedoids` package.
| Hierarchical (agglomerative) | Small-to-medium N; dendrogram visualization; nested structure | Depends on linkage (Ward's assumes spherical) | Linkage method; distance metric; cut height |
| DBSCAN (Ester et al., 1996) | Arbitrary shapes; outlier detection; unknown k | Density-based separation; uniform density | epsilon; MinPts |
| HDBSCAN | Varying-density clusters; robust to parameters | Density-based; varying density | min_cluster_size |
| Gaussian Mixture Models (GMM) | Overlapping clusters; soft assignments; different shapes | Mixture of Gaussians | k; covariance structure |
| Spectral clustering | Non-convex shapes; graph-based structure | Connected components in similarity graph | k; affinity type |

**HDBSCAN vs. DBSCAN:** In most practical situations, prefer HDBSCAN over DBSCAN. HDBSCAN handles clusters of varying density (DBSCAN's single epsilon cannot), requires fewer parameter choices, and automatically identifies outliers. Use DBSCAN only when you specifically need its epsilon-based density definition or have a legacy workflow.

**Practical guidance:** For most applied social science work, start with K-means (simple, fast, widely understood) and hierarchical clustering (provides a dendrogram for visual assessment). If clusters appear non-spherical, overlapping, or varying in density, move to GMM or DBSCAN. A useful initialization strategy: use Ward's hierarchical clustering to generate initial centroids, then refine with K-means — this avoids K-means's sensitivity to random initialization (Steinley, 2006).

For implementation details of these algorithms, load the `scikit-learn` skill.

### Choosing the Number of Clusters

No single method definitively determines k. Use multiple complementary criteria and look for convergence:

| Method | Approach | Strengths | Status |
|--------|----------|-----------|--------|
| Gap Statistic (Tibshirani et al., 2001) | Compare within-cluster dispersion to a null reference distribution | Formal statistical comparison; usually outperforms alternatives | Strong — primary criterion |
| Silhouette Analysis (Rousseeuw, 1987) | Measure similarity to own cluster vs. nearest neighbor cluster | Intuitive; identifies individual misclassified points | Strong — complementary to gap |
| Information Criteria (BIC/AIC) | Penalized likelihood | Principled model selection framework | Strong — for GMM only |
| Elbow Method | Plot inertia vs. k; look for "elbow" | Simple, widely understood | Supplementary only — subjective |
| Consensus Clustering (Monti et al., 2003) | Resampling-based stability assessment | Directly measures robustness of cluster structure | Strong — computationally expensive |

**Best practice:** Use 2-3 methods together. If the gap statistic, silhouette analysis, and domain knowledge converge on the same k, the result is credible. If they disagree, report the disagreement transparently and present results for multiple values of k.

### Preprocessing Requirements

- **Standardization is mandatory** for distance-based methods (K-means, hierarchical with Euclidean distance). Variables on different scales dominate the distance metric, producing clusters driven by scale rather than structure.
- **Mixed data types**: Following Kaufman and Rousseeuw (1990), Gower's distance handles mixed continuous-categorical data. K-prototypes extends K-means for mixed types.
- **Missing data**: Most clustering algorithms cannot handle missing values natively. Options: listwise deletion (risks bias if not MCAR), imputation before clustering (multiple imputation preferred), or model-based approaches with FIML (GMM).
- **Curse of dimensionality**: When the number of variables p is large relative to n, distances converge and cluster structure degrades. Consider PCA before clustering to reduce dimensionality, or use substantive variable selection informed by domain knowledge.
- **Variable selection is critical and consequential.** The choice of which variables to include in a cluster analysis is one of the most impactful researcher degrees of freedom. Different variable sets produce entirely different clusterings. Follow these principles:
  - Prefer theory-driven selection: include variables that are conceptually relevant to the typology you are constructing
  - Exclude outcome variables that will be used in downstream analysis (including the same outcome as both a clustering variable and a regression dependent variable creates circular reasoning)
  - Avoid including highly redundant variables (if two variables correlate > 0.85, consider dropping one or using PCA to combine them)
  - Document and justify every inclusion/exclusion decision

### Cluster Validation

Three levels of validation should all be assessed. Following Rousseeuw (1987) and Monti et al. (2003), internal indices alone are insufficient — stability assessment is essential.

**Internal validation** (no external reference):
- **Silhouette coefficient**: Near +1 indicates well-separated clusters; near 0 indicates overlapping boundaries; negative values indicate misassignment. Following Kaufman and Rousseeuw's (1990) framework: >0.7 strong structure, >0.5 reasonable, >0.25 weak.
- **Davies-Bouldin Index**: Ratio of within-cluster to between-cluster dispersion. Lower is better.
- **Calinski-Harabasz Index**: Ratio of between-cluster to within-cluster variance. Higher is better.

**Stability validation** (resampling-based — CRITICAL):
- **Bootstrap resampling**: Cluster, resample with replacement, re-cluster, measure agreement. Repeat many times.
- **Split-half**: Cluster each random half of the data independently; compare solutions using the Adjusted Rand Index.
- **Consensus clustering** (Monti et al., 2003): Subsample repeatedly, cluster each subsample, build a consensus matrix. Clean block-diagonal structure in the consensus matrix indicates stable clusters.
- **Always assess stability.** Internal indices can improve simply by adding more clusters. A solution with high internal validity but low stability is unreliable.

**External validation** (against known groupings):
- **Adjusted Rand Index (ARI)** (Hubert & Arabie, 1985): Agreement with known groups, corrected for chance. ARI = 1 indicates perfect agreement; ARI = 0 indicates chance-level agreement.
- **Normalized Mutual Information (NMI)**: Information-theoretic measure of agreement between two partitions.

### Common Pitfalls

- **Initialization sensitivity**: K-means with a single random start can converge to a local optimum. Following Steinley's (2006) synthesis, always use a minimum of 25-50 random starts and retain the solution with the lowest inertia.
- **Over-interpreting clusters**: Clusters are descriptive summaries, not natural kinds. Different variables, algorithms, and parameters produce different clusterings of the same data (Hennig, 2015). Acknowledge this explicitly in reporting.
- **The "Salsa effect"**: When cluster profiles are parallel — all variables simply higher or lower across clusters — the clustering may merely stratify a severity continuum rather than identify distinct subgroups. Following Sinha et al. (2021), examine whether cluster profiles cross or diverge, not just whether they differ in level.
- **Treating cluster membership as "known"**: Using hard assignments in subsequent regression introduces classification error and attenuates associations. See [The Classify-Analyze Problem](#the-classify-analyze-problem).
- **Naming-induced reification**: Once clusters receive evocative labels ("resilient," "at-risk," "disengaged"), researchers tend to reason about the labels as if they described causally coherent groups. Always include caveats that labels are shorthand descriptions. See [Causal Language Warnings](#causal-language-warnings-for-unsupervised-methods).

### Reporting Standards

Following Clatworthy et al. (2005), Steinley (2006), and Van Mechelen et al. (2023), cluster analysis reports must include:

1. Rationale for why cluster analysis was chosen
2. Variables included, with justification for inclusion and exclusion
3. Preprocessing details: standardization method, missing data handling
4. Algorithm selected and why (with software and version)
5. Similarity or distance measure used
6. Method for determining k (with all criteria values, not just the chosen k)
7. Validation results: internal indices, stability assessment, or external validation
8. Cluster profiles: means or proportions of clustering variables by cluster, with sample sizes per cluster
9. Initialization details: number of random starts, convergence confirmation
10. Sensitivity: results under alternative k, algorithms, or variable subsets

### Cluster Profiling: Describing What You Found

Cluster profiles — the table or visualization showing what each cluster looks like — are the primary output of any cluster analysis. Without clear profiles, clusters are meaningless labels.

**What to present:**
- **Means table**: For each clustering variable, show the mean (or proportion, for binary/categorical variables) within each cluster, alongside the overall sample mean. This immediately reveals how each cluster deviates from the population.
- **Standardized means**: When variables are on different scales, present z-scored cluster means to make cross-variable comparisons interpretable. A cluster with z = +1.5 on poverty and z = -0.8 on test scores tells a clearer story than raw means.
- **Heatmap visualization**: A heatmap of standardized cluster means (clusters as rows, variables as columns) is the most efficient way to communicate cluster structure. Color intensity reveals which variables define each cluster.
- **Cluster sizes**: Always report n and percentage for each cluster. Clusters smaller than 5% of the sample warrant scrutiny (potential garbage cluster or overfitting).

**Diagnosing the "Salsa effect":**
If cluster profiles are approximately parallel (all variables higher or lower by a similar amount), the clustering may be stratifying a single continuum rather than identifying distinct types. Compare the between-cluster variance on each variable: if one variable dominates, the clusters are defined primarily by that variable. Consider whether a simple median split or tercile would achieve the same grouping more transparently.

**Naming clusters:**
Assign names based on the 2-3 variables with the most extreme deviations from the overall mean. Always present the profile table alongside any named typology so readers can evaluate whether the labels are justified.

## Dimension Reduction: PCA as an Exploratory Tool

### When to Use PCA

PCA identifies linear combinations of variables that capture maximum variance. As an exploratory tool — as opposed to an index construction tool — PCA serves two main purposes:

1. **Data reduction before analysis**: Reduce a large, correlated variable set to a smaller number of uncorrelated components for use in clustering or regression
2. **Structure exploration**: Examine the variance structure of a dataset to understand which variables co-vary and which dimensions capture the most information

> **Cross-reference:** PCA for *index construction* — creating composite measures from normalized components with researcher-chosen or data-driven weights — is covered in `descriptive-analysis.md`, Section "Index Construction and Composite Measures." That section addresses weighting choices, reliability, and validity of composite indices. This section covers PCA as a *general-purpose exploratory and dimension reduction tool* — discovering the dominant variance structure, deciding how many dimensions matter, and reducing dimensionality before downstream analysis.

### How Many Components to Retain

The decision about how many components to retain is consequential and should not be made casually. Following Jolliffe (2002):

| Method | Description | Status |
|--------|-------------|--------|
| Parallel Analysis (Horn, 1965) | Retain components with eigenvalues exceeding those from random data of the same dimensions | **Gold standard.** Use the 95th percentile of simulated eigenvalues, not the mean. |
| Scree Plot | Visual inspection for "elbow" in eigenvalue plot | Acceptable as supplement; inherently subjective |
| Cumulative Variance Threshold | Retain enough components for 70-90% of total variance | Common practical approach; threshold choice is arbitrary |
| Kaiser Criterion (eigenvalue > 1) | Retain all components with eigenvalue exceeding 1 | **Strongly discouraged.** Systematically overestimates the number of meaningful components (Glorfeld, 1995). |

**Best practice:** Run parallel analysis as the primary criterion with 5,000 or more simulation iterations. Supplement with the scree plot and cumulative variance explained. Never rely on the Kaiser criterion alone — it has been repeatedly shown to over-extract components.

### Interpreting Components

- **Loadings**: The correlation (or weight) of each original variable with each component. Variables with high absolute loadings on the same component are capturing the same underlying dimension of variation.
- **Variance explained**: The proportion of total variance captured by each component. Report both individual and cumulative percentages. A steep drop-off after the first few components suggests low-dimensional structure; a gradual decline suggests the data lacks strong dimensional organization.
- **Biplot visualization**: Plot observations in the space of the first two components, with arrows showing variable loadings. Useful for understanding both the structure of the component space and the position of individual observations or outliers.
- **Rotation**: For purely exploratory PCA, unrotated solutions are standard. Rotation (varimax, promax) is more relevant for factor analysis when the goal is identifying interpretable latent constructs. If rotation is applied, report both rotated and unrotated solutions.

### Reporting Standards for PCA

1. Number of components retained and retention criteria used (parallel analysis values, scree plot, cumulative variance threshold)
2. Variance explained: total and per-component
3. Loading table (all loadings, or loadings above a stated threshold with the threshold specified)
4. Standardization method used — PCA should almost always operate on standardized (correlation matrix) data rather than raw (covariance matrix) data, unless variables share a common scale and the researcher explicitly wants variance differences to influence component extraction
5. Sample size relative to number of variables (rules of thumb vary, but N:p ratios below 5:1 warrant caution)

## Nonlinear Embeddings: t-SNE and UMAP

### What They Do

t-SNE (van der Maaten & Hinton, 2008) and UMAP (McInnes, Healy, & Melville, 2018) are nonlinear dimension reduction methods that project high-dimensional data into two or three dimensions for visualization. They excel at preserving local neighborhood structure — points that are close in high-dimensional space remain close in the embedding.

### Visualization Tools, NOT Analysis Tools

Following Wattenberg, Viegas, and Johnson's (2016) essential interactive guide, these methods have fundamental limitations that must be understood before any interpretation:

- **Cluster sizes are meaningless**: Both algorithms equalize apparent cluster density. A group that is 10 times denser in the original space may appear the same size as a sparse group.
- **Between-cluster distances are unreliable**: The spatial separation between groups in the plot does not reliably reflect their distance in the original high-dimensional space.
- **Random noise can appear structured**: At low perplexity (t-SNE) or low n_neighbors (UMAP), spurious clusters emerge from genuinely random data.
- **Parameters dramatically change the output**: The same data with different perplexity or n_neighbors values can produce qualitatively different plots. There is no "correct" parameter setting.
- **Results are non-reproducible across runs**: Different random seeds produce different layouts, especially for t-SNE. UMAP is somewhat more stable but still sensitive to initialization.

These limitations mean t-SNE and UMAP plots should be treated as **hypothesis-generating visualizations**, not as evidence for the existence of clusters. A cluster visible in a t-SNE plot is a pattern worth investigating with formal methods — it is not itself a finding.

### t-SNE vs. UMAP

| Feature | t-SNE | UMAP |
|---------|-------|------|
| Speed | Slower, especially on large datasets | Significantly faster |
| Global structure | Poor — only local neighborhoods are meaningful | Better preservation of global structure |
| Reproducibility | Low — highly sensitive to initialization | More stable across runs |
| Embedding dimensions | Typically limited to 2-3 | Any number; usable for general dimension reduction |
| Key parameter | perplexity (5-50 typical range) | n_neighbors (5-50) + min_dist (0-1) |
| When to prefer | Small datasets; established convention in the field | Large datasets (>10K observations); when global layout matters |

### Best Practices

- Run multiple parameter values (varying perplexity or n_neighbors across a reasonable range) and multiple random seeds
- Present multiple plots showing parameter sensitivity — not just the single "best looking" result
- Treat apparent patterns as **hypotheses** requiring formal validation through clustering algorithms and stability assessment
- Never present a single t-SNE or UMAP plot as evidence for the existence of distinct clusters
- Always label plots with the exact parameter values and random seed used
- Prefer UMAP over t-SNE for large datasets or when global structure preservation matters

For implementation syntax, load the `scikit-learn` skill (t-SNE) or see the `umap-learn` companion library documentation.

## Gaussian Mixture Models

### What GMM Does

Following Fraley and Raftery's (2002) model-based clustering framework, Gaussian Mixture Models represent data as arising from a mixture of k Gaussian (normal) distributions, each with its own mean and covariance matrix. Unlike K-means, GMM provides:

- **Soft assignments**: Each observation receives a posterior probability of belonging to each cluster, rather than a hard 0/1 assignment
- **Flexible cluster shapes**: Different covariance structures allow elliptical, elongated, and differently-oriented clusters
- **Formal model selection**: BIC and AIC provide a principled framework for choosing k and covariance structure simultaneously

### Model Selection

| Criterion | What It Does | When to Use |
|-----------|-------------|-------------|
| BIC | Penalizes likelihood by log(n) per parameter | Primary criterion; tends to favor parsimony |
| AIC | Penalizes likelihood by 2 per parameter | Secondary; less conservative than BIC |
| ICL | BIC penalized by classification entropy | When clear class separation matters |

**Best practice:** Fit models across a range of k values AND covariance types (spherical, diagonal, tied, full). Compare BIC across all combinations. The model with the lowest BIC is preferred, but examine whether several models have similar BIC values — if so, the data do not strongly distinguish between them, and this ambiguity should be reported.

### Covariance Structure Selection

| Type | Assumption | When to Use |
|------|-----------|-------------|
| Spherical | Round clusters, equal size | Equivalent to probabilistic K-means |
| Diagonal | Axis-aligned ellipses | Variables are uncorrelated within clusters |
| Tied | All clusters share one covariance matrix | Clusters differ in location but not in shape |
| Full | Each cluster has its own covariance | Most flexible; highest parameter count |

Start with `full` covariance and let BIC select the appropriate complexity. Reduce to simpler structures if full covariance overfits (higher BIC) or if the number of parameters is large relative to the sample size.

### GMM vs. K-means

| Feature | GMM | K-means |
|---------|-----|---------|
| Assignment type | Probabilistic (posterior probabilities) | Deterministic (hard assignment) |
| Cluster shape | Any Gaussian shape (controlled by covariance) | Spherical only |
| Model selection | Formal via BIC/AIC | Heuristic (silhouette, elbow) |
| Outlier handling | Low posterior for all clusters signals a potential outlier | Forced into nearest centroid |
| Computational cost | Higher (EM algorithm with covariance estimation) | Lower |
| Downstream use | Posterior probabilities reduce classify-analyze bias | Hard labels introduce classification error |

**When to prefer GMM:** When clusters are not spherical; when soft assignments (uncertainty quantification) matter; when formal model comparison is needed; when cluster probabilities will be used in downstream analysis (this mitigates the classify-analyze bias discussed below).

## The Classify-Analyze Problem

This is the single most important methodological pitfall in applied unsupervised analysis. It affects every study that assigns observations to clusters and then uses those assignments in subsequent analysis.

### The Core Issue

When observations are assigned to clusters and those assignments are treated as "known" in subsequent regression or ANOVA, the resulting estimates are biased. The fundamental problem: classification error — the uncertainty in group assignment — is ignored. Hard cluster labels treat probabilistic membership as certain, which attenuates true associations toward zero.

Following Lanza, Tan, and Bray (2013), this bias affects ALL downstream uses of cluster membership:
- Cluster membership as a predictor in regression
- ANOVA comparing clusters on external outcomes
- Subgroup analysis stratified by cluster assignment
- Cross-tabulations of cluster membership with other variables

### Magnitude of the Bias

The bias is proportional to the misclassification rate. With well-separated clusters where assignment is unambiguous, the bias is modest. But with overlapping clusters — the common case in social science data — the bias can be substantial. Lanza, Tan, and Bray (2013) demonstrated attenuation ranging from -0.115 to -0.421 depending on measurement quality and class separation. This means that a true association of 0.50 could appear as anywhere from 0.08 to 0.39 when using hard cluster assignments.

The bias is always in the direction of attenuation (toward zero), meaning that true associations are *underestimated*. A non-significant result in a classify-analyze framework may reflect classification error rather than a genuine null effect.

### Practical Mitigations

| Strategy | How | When to Use |
|----------|-----|-------------|
| **Use GMM posterior probabilities** | GMM produces posterior probability of membership in each cluster; use these as weights or uncertainty measures in downstream analysis rather than hard labels | Whenever cluster membership feeds into regression or comparison |
| **Sensitivity to boundary cases** | Exclude observations with ambiguous assignment (e.g., maximum posterior probability < 0.70) and show results are robust to their inclusion or exclusion | Always — simple to implement and highly informative |
| **Bootstrap the full pipeline** | Bootstrap the clustering AND the downstream analysis together; show conclusions are robust to cluster reassignment across resamples | When results depend critically on cluster boundaries |
| **Present cluster profiles as primary** | Use clusters as a descriptive organizing framework rather than a formal predictor; emphasize the profile description itself | When the typology IS the research contribution |
| **Report uncertainty in assignments** | Show the distribution of posterior probabilities or the proportion of ambiguous cases | Always — readers need to assess how "crisp" the clusters are |

### What NOT to Do

- Do NOT treat K-means labels as a categorical variable in regression without acknowledging the classify-analyze limitation and reporting sensitivity analyses
- Do NOT claim that associations between cluster membership and outcomes are precise point estimates — they are attenuated by classification error
- Do NOT use cluster labels from one subsample to "predict" outcomes in another without first assessing cluster replicability across subsamples
- Do NOT dismiss the problem because clusters "look well-separated" in a visualization — t-SNE and UMAP equalize cluster density and can make overlapping groups appear distinct
- Do NOT use the same outcome variable both in the clustering step AND as the dependent variable in downstream regression — this creates circular reasoning where clusters are partly defined by the outcome, guaranteeing a spurious "association"

## Causal Language Warnings for Unsupervised Methods

Unsupervised methods are **descriptive**. They identify patterns in observed data. They cannot, by themselves, support causal claims. The temptation to slip into causal language is especially strong with unsupervised methods because clusters and components *feel* like they reveal something real about the world — but they are as much a product of methodological choices as of the data.

### Common Language Errors

| Incorrect Framing | Problem | Correct Framing |
|-------------------|---------|-----------------|
| "Students in the high-risk cluster *because* they had low SES" | Implies the cluster is caused by SES | "Students in the high-risk cluster were *characterized by* low SES" |
| "The resilient profile *caused* better outcomes" | Reifies cluster as a causal agent | "Students *classified in* the resilient profile *tended to have* better outcomes" |
| "PCA *revealed* three underlying dimensions" | Implies components exist independently of the method | "PCA *identified* three components *that explained* X% of total variance" |
| "The clustering *revealed* three distinct types of schools" | Implies clusters exist independently of analytic choices | "The cluster analysis *identified* three groups *that differed on* the clustering variables" |
| "These clusters are the natural groupings in the data" | Assumes clusters are ontologically real | "These clusters represent one possible partitioning given the variables, distance metric, and algorithm used" |
| "Cluster membership *predicts* dropout" | Implies directional relationship | "Cluster membership was *associated with* differential dropout rates" |

### Researcher Degrees of Freedom

Different variable selections, standardization choices, algorithms, and parameter values produce different clusterings of the same data. Following Hennig (2015), the "clusters" are as much a product of methodological choices as of the underlying data structure. This is not a deficiency of unsupervised methods — it is an inherent feature. But it must be acknowledged explicitly.

Specific degrees of freedom in cluster analysis that should be documented and tested via sensitivity analysis:
- Which variables to include (and which to exclude)
- How to standardize or transform variables
- Which algorithm to use
- Which distance metric to apply
- How many clusters to specify
- Initialization method and number of random starts
- How to handle missing data

Each choice can change the result. Conduct sensitivity analyses across the most consequential alternatives and report whether conclusions are robust.

### Naming Clusters Carefully

Assigning evocative names to clusters ("resilient," "at-risk," "disengaged") is useful for communication but dangerous for reasoning. Once named, clusters tend to be reified — treated as real, stable, causally coherent entities rather than as statistical summaries of observed patterns. Always:

- Include explicit caveats that labels are shorthand descriptions, not definitions of real types
- Present the cluster profile table alongside any named typology so readers can evaluate the labels against the data
- Demonstrate through sensitivity analysis that the substantive interpretation behind the label is robust to reasonable alternative methodological choices
- Avoid names that imply causation or clinical diagnosis ("dysfunctional," "thriving") when the analysis is purely descriptive

## References and Further Reading

### General Textbooks

James, G., Witten, D., Hastie, T., and Tibshirani, R. (2021). *An Introduction to Statistical Learning*, 2nd Edition. Springer. **Free:** https://www.statlearning.com/

Hastie, T., Tibshirani, R., and Friedman, J. (2009). *The Elements of Statistical Learning*, 2nd Edition. Springer. **Free:** https://hastie.su.domains/ElemStatLearn/download.html

Hair, J.F., Black, W.C., Babin, B.J., and Anderson, R.E. (2019). *Multivariate Data Analysis*, 8th Edition. Cengage.

Bartholomew, D.J., Steele, F., Moustaki, I., and Galbraith, J. (2008). *Analysis of Multivariate Social Science Data*, 2nd Edition. Chapman & Hall/CRC.

### Cluster Analysis

Everitt, B.S., Landau, S., Leese, M., and Stahl, D. (2011). *Cluster Analysis*, 5th Edition. Wiley.

Kaufman, L. and Rousseeuw, P.J. (1990). *Finding Groups in Data: An Introduction to Cluster Analysis*. Wiley.

Hennig, C., Meila, M., Murtagh, F., and Rocci, R. (Eds.) (2016). *Handbook of Cluster Analysis*. Chapman & Hall/CRC.

Steinley, D. (2006). "K-means clustering: A half-century synthesis." *British Journal of Mathematical and Statistical Psychology*, 59(1), 1-34.

Rousseeuw, P.J. (1987). "Silhouettes: A graphical aid to the interpretation and validation of cluster analysis." *Journal of Computational and Applied Mathematics*, 20, 53-65.

Tibshirani, R., Walther, G., and Hastie, T. (2001). "Estimating the number of clusters in a data set via the gap statistic." *Journal of the Royal Statistical Society: Series B*, 63(2), 411-423.

Hennig, C. (2015). "What are the true clusters?" *Pattern Recognition Letters*, 64, 53-62.

Clatworthy, J., Buick, D., Hankins, M., Weinman, J., and Horne, R. (2005). "The use and reporting of cluster analysis in health psychology." *British Journal of Health Psychology*, 10(3), 329-358.

Van Mechelen, I. et al. (2023). "A white paper on good research practices in benchmarking: The case of cluster analysis." *WIREs Data Mining and Knowledge Discovery*, e1511.

Ester, M., Kriegel, H.-P., Sander, J., and Xu, X. (1996). "A density-based algorithm for discovering clusters in large spatial databases with noise." *Proceedings of KDD-96*, 226-231.

Monti, S., Tamayo, P., Mesirov, J., and Golub, T. (2003). "Consensus clustering: A resampling-based method for class discovery and visualization of gene expression microarray data." *Machine Learning*, 52, 91-118.

Hubert, L. and Arabie, P. (1985). "Comparing partitions." *Journal of Classification*, 2, 193-218.

### Model-Based Clustering

Fraley, C. and Raftery, A.E. (2002). "Model-based clustering, discriminant analysis, and density estimation." *Journal of the American Statistical Association*, 97(458), 611-631.

Scrucca, L., Fraley, C., Murphy, T.B., and Raftery, A.E. (2023). *Model-Based Clustering, Classification, and Density Estimation Using mclust in R*. Chapman & Hall/CRC. **Free:** https://mclust-org.github.io/mclust-book/

Ahlquist, J.S. and Breunig, C. (2012). "Model-based clustering and typologies in the social sciences." *Political Analysis*, 20(1), 92-112.

### Dimension Reduction

Jolliffe, I.T. (2002). *Principal Component Analysis*, 2nd Edition. Springer.

Horn, J.L. (1965). "A rationale and test for the number of factors in factor analysis." *Psychometrika*, 30(2), 179-185.

> **Implementation note:** Parallel analysis implementation guidance is available in the scikit-learn skill's `decomposition.md` reference.

### Nonlinear Embeddings

van der Maaten, L. and Hinton, G. (2008). "Visualizing data using t-SNE." *Journal of Machine Learning Research*, 9, 2579-2605. https://www.jmlr.org/papers/v9/vandermaaten08a.html

McInnes, L., Healy, J., and Melville, J. (2018). "UMAP: Uniform Manifold Approximation and Projection for Dimension Reduction." arXiv:1802.03426.

Wattenberg, M., Viegas, F., and Johnson, I. (2016). "How to Use t-SNE Effectively." *Distill*, 1(10), e2. https://distill.pub/2016/misread-tsne/

### The Classify-Analyze Problem

Lanza, S.T., Tan, X., and Bray, B.C. (2013). "Latent class analysis with distal outcomes: A flexible model-based approach." *Structural Equation Modeling*, 20(1), 1-26.

Skrondal, A. and Laake, P. (2001). "Regression among factor scores." *Psychometrika*, 66(4), 563-575.

### Practitioner Guides

Sinha, P., Calfee, C.S., and Delucchi, K.L. (2021). "Practitioner's guide to latent class analysis: Methodological considerations and common pitfalls." *Critical Care Medicine*, 49(1), e63-e79.

### Software

Pedregosa, F. et al. (2011). "Scikit-learn: Machine Learning in Python." *Journal of Machine Learning Research*, 12, 2825-2830. https://scikit-learn.org/

McInnes, L., Healy, J., Saul, N., and Grossberger, L. (2018). "UMAP: Uniform Manifold Approximation and Projection." *Journal of Open Source Software*, 3(29), 861. https://umap-learn.readthedocs.io/

### Interactive Resources

Wattenberg, M., Viegas, F., and Johnson, I. (2016). "How to Use t-SNE Effectively." *Distill*. https://distill.pub/2016/misread-tsne/ [Interactive visualization]

Google PAIR. "Understanding UMAP." https://pair-code.github.io/understanding-umap/ [Interactive visualization]
