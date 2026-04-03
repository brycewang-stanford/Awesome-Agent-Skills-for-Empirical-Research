---


name: method-transfer-engine
description: Six-phase protocol for adapting methods across research domains


---

# Method Transfer Engine

**Rigorous framework for adapting statistical methods across domains and settings**

Use this skill when: adapting a method from one field to another, extending a method to a new setting, formalizing an intuitive connection between methods, or verifying that a transferred method retains its properties.

---

## The Transfer Framework

### What is Method Transfer?

Taking a technique that works in Setting A and adapting it to work in Setting B, while:
- Preserving desirable theoretical properties
- Identifying what changes are needed
- Understanding what can and cannot transfer

### Transfer Quality Spectrum

```
Direct Application → Minor Adaptation → Major Modification → Inspired-By
      │                    │                   │                  │
   Same theory         Adjust for          Rewrite theory      New method,
   applies            new setting          for new setting     similar spirit
```

### Transfer Success Criteria

A successful transfer must:

1. **Solve the target problem** - Method actually helps in new setting
2. **Preserve key properties** - Consistency, efficiency, robustness transfer
3. **Have clear assumptions** - Know what's required in new setting
4. **Be verifiable** - Can prove/simulate that it works
5. **Add value** - Better than existing approaches

---

## The 6-Phase Protocol

This protocol provides a systematic approach to method transfer, covering all critical steps from source extraction through validation.

### Source Extraction

**Goal**: Extract the core mathematical and algorithmic essence of the source method

```r
# Template for source method extraction
extract_source_method <- function(method_name, reference) {
  list(
    name = method_name,
    estimand = "formal expression of what is estimated",
    estimator = "formula for the estimator",
    assumptions = c("A1: condition", "A2: condition"),
    properties = c("consistency", "asymptotic normality"),
    algorithm = c("Step 1: ...", "Step 2: ..."),
    complexity = "O(n^2) or similar"
  )
}

# Example: Extract Lasso from signal processing
lasso_extraction <- list(
  name = "Lasso/Basis Pursuit",
  field = "Signal Processing / Compressed Sensing",
  estimand = "argmin ||y - Xb||_2^2 + lambda * ||b||_1",
  key_insight = "L1 penalty induces sparsity via soft thresholding",
  assumptions = c("RIP condition", "Incoherence"),
  properties = c("Sparse solution", "Variable selection consistency")
)
```

### Abstraction

**Goal**: Identify the abstract mathematical structure that enables the method

```r
# Abstract structure identification
identify_abstraction <- function(source_method) {
  list(
    mathematical_structure = "e.g., M-estimation, U-statistics, kernels",
    core_operation = "e.g., reweighting, regularization, projection",
    information_used = "e.g., first moments, covariance, distributional",
    key_invariance = "what property makes it work",
    generalization_path = "how to extend beyond original setting"
  )
}

# Example: Abstraction of propensity score methods
propensity_abstraction <- list(
  mathematical_structure = "Reweighting to balance distributions",
  core_operation = "Inverse probability weighting",
  invariance = "Balances covariate distribution across groups",
  generalization = "Any selection mechanism with known probabilities"
)
```

---

### Phase 1: Source Method Analysis

**Goal**: Deeply understand what you're transferring

```markdown
## Source Method Profile

### Basic Information
- Name: [Method name]
- Source field: [Domain/area]
- Key reference: [Citation]
- What it does: [One sentence]

### Problem Solved
- Input: [What data/information goes in]
- Output: [What estimate/inference comes out]
- Setting: [When it applies]

### Mathematical Structure
- Estimand: [What it estimates, formally]
- Estimator: [How it estimates, formula]
- Loss/objective: [What it optimizes]

### Assumptions Required
1. [Assumption 1]: [Mathematical statement]
   - Why needed: [Role in proof/method]
   - When violated: [Failure mode]

2. [Assumption 2]: ...

### Theoretical Properties
- Consistency: [When/how proved]
- Rate: [Convergence rate]
- Asymptotic distribution: [If known]
- Efficiency: [Relative to what]
- Robustness: [To what violations]

### Computational Aspects
- Algorithm: [How implemented]
- Complexity: [Time/space]
- Software: [Available implementations]
```

### Phase 2: Target Problem Analysis

**Goal**: Understand where you want to apply it

```markdown
## Target Problem Profile

### Basic Information
- Problem name: [Description]
- Target field: [Domain/area]
- Motivation: [Why solve this]

### Problem Structure
- Data available: [What's observed]
- Estimand: [What you want to estimate]
- Challenges: [Why existing methods inadequate]

### Current Approaches
- Method 1: [Name, limitations]
- Method 2: [Name, limitations]
- Gap: [What's missing]

### Constraints
- Assumptions willing to make: [List]
- Assumptions NOT willing to make: [List]
- Computational constraints: [If any]
```

### Target Mapping

**Goal**: Map source concepts to their target domain counterparts

```r
# Target mapping framework
create_target_mapping <- function(source, target) {
  mapping <- list(
    objects = data.frame(
      source = c("treatment", "outcome", "confounder"),
      target = c("mediator", "effect", "moderator"),
      relationship = c("direct", "indirect", "modifies")
    ),
    assumptions = data.frame(
      source_assumption = c("SUTVA", "Ignorability"),
      target_version = c("Consistency", "Sequential ignorability"),
      status = c("transfers", "needs modification")
    )
  )

  mapping
}

# Example: IV to Mendelian randomization mapping
iv_to_mr <- list(
  price_instrument = "genetic_variant",
  demand = "biomarker_exposure",
  endogeneity = "unmeasured_confounding",
  exclusion = "pleiotropic_effects",
  key_difference = "biological vs economic mechanisms"
)
```

### Phase 3: Structure Mapping

**Goal**: Identify correspondences between source and target

```markdown
## Structure Map

### Object Correspondence

| Source | Target | Notes |
|--------|--------|-------|
| [Source object 1] | [Target object 1] | [How they relate] |
| [Source object 2] | [Target object 2] | [How they relate] |
| ... | ... | ... |

### Assumption Correspondence

| Source Assumption | Target Version | Status |
|-------------------|----------------|--------|
| [Source A1] | [Target A1'] | ✓ Transfers / ✗ Fails / ? Modify |
| [Source A2] | [Target A2'] | ... |
| ... | ... | ... |

### What Transfers Directly
- [Property 1]: Because [reason]
- [Property 2]: Because [reason]

### What Needs Modification
- [Element 1]: From [source version] to [target version]
  - Why: [Reason for change]
  - How: [Specific modification]

### What Doesn't Transfer
- [Element 1]: Because [reason]
  - Impact: [What we lose]
  - Alternative: [How to address]
```

### Gap Analysis

**Goal**: Identify what doesn't transfer and what modifications are needed

```r
# Gap analysis framework
analyze_transfer_gaps <- function(source, target, mapping) {
  gaps <- list(
    assumption_gaps = list(
      violated = c("iid assumption in clustered data"),
      modified = c("independence -> conditional independence"),
      new_required = c("mediator positivity")
    ),

    property_gaps = list(
      lost = c("efficiency under misspecification"),
      weakened = c("convergence rate n^{-1/2} -> n^{-1/4}"),
      preserved = c("consistency", "asymptotic normality")
    ),

    computational_gaps = list(
      new_challenges = c("non-convex optimization"),
      workarounds = c("ADMM algorithm", "approximate methods")
    ),

    bridging_strategies = c(
      "Add regularization for new setting",
      "Derive modified variance estimator",
      "Implement robustness check"
    )
  )

  gaps
}
```

### Phase 4: Adaptation Design

**Goal**: Design the transferred method

```markdown
## Adapted Method Design

### Overview
[One paragraph describing the adapted method]

### Formal Definition

**Estimand**:
$$\psi = [target estimand formula]$$

**Estimator**:
$$\hat{\psi}_n = [adapted estimator formula]$$

**Algorithm**:
1. [Step 1]
2. [Step 2]
3. ...

### Modified Assumptions
1. [Assumption A1']: [New statement for target setting]
   - Analogous to: [Source assumption]
   - Modified because: [Reason]

### Expected Properties
- Consistency: [Conjecture/claim]
- Rate: [Expected]
- Efficiency: [Expected]

### Key Differences from Source
1. [Difference 1]: [Explanation]
2. [Difference 2]: [Explanation]
```

### Validation

**Goal**: Systematically verify the transferred method works correctly

```r
# Comprehensive validation framework for method transfer
validate_transfer <- function(adapted_method, n_sims = 1000) {
  results <- list()

  # 1. Bias check: Is estimator unbiased at truth?
  results$bias <- run_bias_simulation(adapted_method, n_sims)

  # 2. Coverage check: Do CIs achieve nominal coverage?
  results$coverage <- run_coverage_simulation(adapted_method, n_sims)

  # 3. Efficiency check: Compare to alternatives
  results$efficiency <- compare_to_alternatives(adapted_method)

  # 4. Robustness check: Behavior under violations
  results$robustness <- test_assumption_violations(adapted_method)

  # 5. Edge cases: Extreme scenarios
  results$edge_cases <- test_edge_cases(adapted_method)

  # Validation report
  list(
    passed = all(sapply(results, function(x) x$passed)),
    details = results,
    recommendations = generate_recommendations(results)
  )
}

# Simulation template for validation
run_transfer_validation <- function(n = 500, n_sims = 1000) {
  estimates <- replicate(n_sims, {
    # Generate data under true model
    data <- generate_dgp(n)

    # Apply transferred method
    est <- adapted_method(data)

    c(estimate = est$point, se = est$se)
  })

  list(
    bias = mean(estimates["estimate", ]) - true_value,
    rmse = sqrt(mean((estimates["estimate", ] - true_value)^2)),
    coverage = mean(abs(estimates["estimate", ] - true_value) <
                   1.96 * estimates["se", ])
  )
}
```

### Phase 5: Verification

**Goal**: Prove/demonstrate the transfer works

```markdown
## Verification Plan

### Theoretical Verification
- [ ] Consistency proof
  - Approach: [Proof strategy]
  - Key lemma: [What needs to be shown]

- [ ] Asymptotic normality
  - Approach: [Proof strategy]
  - Influence function: [If applicable]

- [ ] Efficiency (if claiming)
  - Approach: [Efficiency bound derivation]

### Simulation Verification
- [ ] Scenario 1: [Description]
  - DGP: [Data generating process]
  - Expected result: [What should happen]

- [ ] Scenario 2: Comparison to oracle
  - Purpose: [Verify optimality]

- [ ] Scenario 3: Stress test
  - Purpose: [Find failure modes]

### Empirical Verification
- [ ] Benchmark dataset: [If available]
- [ ] Real application: [Domain]
```

### Phase 6: Documentation

**Goal**: Document for publication

```markdown
## Transfer Documentation

### Contribution Statement
"We adapt [source method] from [source field] to [target setting] by
[key modification]. Our adapted method [key property]. Unlike [alternative],
our approach [advantage]."

### Theoretical Contribution
- New result 1: [Theorem statement]
- New result 2: [If applicable]

### Methodological Contribution
- Adaptation insight: [What's novel about the transfer]
- Practical guidance: [When to use]

### What We Learned
- About source method: [New understanding]
- About target problem: [New understanding]
- General principle: [Broader insight]
```

---

## Common Transfer Patterns

### Pattern 1: Estimator Family Transfer

**Template**: Estimator type from one setting to another

**Example**: IPW from survey sampling → causal inference

```
Source: Horvitz-Thompson estimator
        E[Y] ≈ Σᵢ Yᵢ/πᵢ where πᵢ = P(selected)

Target: IPW for ATE
        E[Y(1)] ≈ Σᵢ Yᵢ·Aᵢ/e(Xᵢ) where e(x) = P(A=1|X=x)

Mapping:
- Selection indicator → Treatment indicator
- Selection probability → Propensity score
- Survey weights → Inverse propensity weights

Key insight: Both correct for selection bias via reweighting
```

### Pattern 2: Robustness Property Transfer

**Template**: Robustness technique from one method to another

**Example**: Double robustness from missing data → causal inference

```
Source: Augmented IPW for missing data
        DR = IPW + Imputation - (IPW × Imputation)

Target: AIPW for causal effects
        Same structure but for counterfactual outcomes

Mapping:
- Missing indicator → Treatment indicator
- Missingness model → Propensity model
- Imputation model → Outcome model

Key insight: Product-form bias enables robustness to one misspecification
```

### Pattern 3: Asymptotic Result Transfer

**Template**: Asymptotic theory from simpler to complex setting

**Example**: Influence function theory → semiparametric mediation

```
Source: IF for smooth functional of CDF
        √n(T(Fₙ) - T(F)) → N(0, E[φ²])

Target: IF for mediation effect functional
        Requires: mediation-specific tangent space

Mapping:
- General functional → Mediation estimand
- CDF → Joint distribution (Y,M,A,X)
- Generic IF → Mediation-specific IF

Key insight: EIF theory applies to any pathwise differentiable functional
```

### Pattern 4: Identification Strategy Transfer

**Template**: Identification approach from one causal setting to another

**Example**: IV from economics → Mendelian randomization

```
Source: Instrumental variables for demand estimation
        Z → A → Y, Z ⫫ U

Target: MR for causal effects of exposures
        Gene → Biomarker → Outcome

Mapping:
- Price instrument → Genetic variant
- Demand → Exposure level
- Endogeneity → Confounding

Key insight: Exogenous variation strategy is general
```

### Pattern 5: Computational Method Transfer

**Template**: Algorithm from optimization → statistical estimation

**Example**: SGD from ML → online causal estimation

```
Source: Stochastic gradient descent for ERM
        θₜ₊₁ = θₜ - ηₜ∇L(θₜ; Xₜ)

Target: Online updating for streaming causal data
        Sequential estimation as data arrives

Mapping:
- Loss function → Estimating equation
- Gradient → Score contribution
- Learning rate → Weighting scheme

Key insight: Streaming updates possible for M-estimators
```

---

## Transfer Verification Checklist

### Theoretical Checks

- [ ] **Identification preserved**: Estimand still identified under adapted assumptions
- [ ] **Consistency maintained**: Proof carries over or new proof provided
- [ ] **Rate preserved**: Convergence rate same or characterized
- [ ] **Variance characterized**: Influence function derived if applicable
- [ ] **Efficiency understood**: Know if/when efficient

### Practical Checks

- [ ] **Computable**: Can actually implement the adapted method
- [ ] **Stable**: Numerical issues don't prevent use
- [ ] **Scalable**: Works at relevant data sizes

### Simulation Checks

- [ ] **Correct at truth**: Estimator unbiased when DGP matches assumptions
- [ ] **Proper coverage**: CIs achieve nominal coverage
- [ ] **Efficiency comparison**: Compared to alternatives
- [ ] **Robustness**: Behavior under assumption violations

### Documentation Checks

- [ ] **Assumptions clear**: All requirements stated
- [ ] **Limitations stated**: Known failure modes documented
- [ ] **Guidance provided**: When to use/not use

---

## Common Transfer Pitfalls

### Pitfall 1: Hidden Assumption Dependence

**Problem**: Source method relies on assumption not explicit in exposition

**Example**: Many ML methods implicitly assume iid data
- Transfer to clustered data fails silently
- Variance underestimated, inference invalid

**Prevention**:
- Read proofs, not just statements
- Check what each step requires
- Simulate under violations

### Pitfall 2: Changed Meaning

**Problem**: Same symbol/concept means different things

**Example**: "Independence" in different fields
- Statistical independence: P(A,B) = P(A)P(B)
- Causal independence: No causal pathway
- Conditional independence: Given covariates

**Prevention**:
- Define all terms explicitly
- Verify mathematical equivalence
- Don't assume same word = same concept

### Pitfall 3: Lost Efficiency

**Problem**: Method transfers but loses optimality properties

**Example**: MLE transferred to semiparametric setting
- Parametric MLE is efficient
- Plugging into semiparametric problem: no longer efficient
- Need to derive new efficient estimator

**Prevention**:
- Re-derive efficiency in target setting
- Don't assume optimality transfers
- Compare to efficiency bound

### Pitfall 4: Computational Invalidity

**Problem**: Algorithm doesn't work in new setting

**Example**: Newton-Raphson for optimization
- Works when Hessian well-behaved
- In ill-conditioned problems: numerical disaster

**Prevention**:
- Test on representative problems
- Check condition numbers, stability
- Have fallback algorithms

### Pitfall 5: False Generalization

**Problem**: Transfer works for one case, claimed general

**Example**: Method for binary → continuous
- Test case: continuous Y is approximately binary
- Claim: works for all continuous Y
- Reality: fails for skewed/heavy-tailed

**Prevention**:
- Test diverse scenarios
- Characterize where it works
- State limitations clearly

---

## Transfer Feasibility Assessment

### Quick Assessment Questions

| Question | If No | If Yes |
|----------|-------|--------|
| Same mathematical structure? | Major adaptation needed | Direct transfer possible |
| All assumptions translatable? | Some properties lost | Full transfer possible |
| Same data requirements? | Additional modeling needed | Straightforward application |
| Existing theory applicable? | New proofs required | Theory transfers |
| Similar computational structure? | Algorithm redesign | Code adaptation |

### Feasibility Score

For each dimension, score 1-5:

| Dimension | Score | Interpretation |
|-----------|-------|----------------|
| Structural similarity | __ /5 | 5 = identical structure |
| Assumption compatibility | __ /5 | 5 = all assumptions transfer |
| Theoretical portability | __ /5 | 5 = proofs carry over |
| Computational similarity | __ /5 | 5 = same algorithm works |
| Value added | __ /5 | 5 = major improvement |

**Total**: __/25

- 20-25: Strong transfer candidate
- 15-19: Feasible with moderate effort
- 10-14: Significant adaptation required
- <10: May need different approach

---

## Integration with Other Skills

This skill works with:
- **cross-disciplinary-ideation** - Find candidate methods to transfer
- **literature-gap-finder** - Identify where transfer would be valuable
- **proof-architect** - Verify transferred properties
- **identification-theory** - Ensure identification in target setting
- **asymptotic-theory** - Derive properties in target setting
- **simulation-architect** - Validate the transfer

---

## Key References

### On Method Transfer
- Box, G.E.P. (1976). Science and statistics (on borrowing strength)
- Breiman, L. (2001). Statistical modeling: The two cultures

### Successful Transfer Examples
- Rosenbaum & Rubin (1983). Central role of propensity score [survey → causal]
- Tibshirani (1996). Regression shrinkage via lasso [signals → regression]
- Robins et al. (1994). Estimation of regression coefficients [missing → causal]

### Transfer in Causal Inference
- Pearl, J. (2009). Causality [AI → statistics]
- Hernán & Robins (2020). Causal Inference: What If

---

**Version**: 1.0
**Created**: 2025-12-08
**Domain**: Method Development, Research Innovation
