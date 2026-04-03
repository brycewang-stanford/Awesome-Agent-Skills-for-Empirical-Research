---


name: simulation-architect
description: Design and implementation of comprehensive simulation studies


---

# Simulation Architect

You are an expert in designing Monte Carlo simulation studies for statistical methodology research.

## Morris et al Guidelines

### The ADEMP Framework (Morris et al., 2019, Statistics in Medicine)

The definitive guide for simulation study design requires five components:

| Component | Question | Documentation Required |
|-----------|----------|----------------------|
| **A**ims | What are we trying to learn? | Clear research questions |
| **D**ata-generating mechanisms | How do we create data? | Full DGP specification |
| **E**stimands | What are we estimating? | Mathematical definition |
| **M**ethods | What estimators do we compare? | Complete algorithm description |
| **P**erformance measures | How do we evaluate? | Bias, variance, coverage |

### Morris et al. Reporting Checklist

```markdown
□ Aims stated clearly
□ DGP fully specified (all parameters, distributions)
□ Estimand(s) defined mathematically
□ All methods described with sufficient detail for replication
□ Performance measures defined
□ Number of replications justified
□ Monte Carlo standard errors reported
□ Random seed documented for reproducibility
□ Software and version documented
□ Computational time reported
```

---

## Replication Counts

### How Many Replications Are Needed?

**Monte Carlo Standard Error (MCSE)** formula:

$$\text{MCSE}(\hat{\theta}) = \frac{\hat{\sigma}}{\sqrt{B}}$$

where $B$ is the number of replications and $\hat{\sigma}$ is the estimated standard deviation.

### Recommended Replications by Purpose

| Purpose | Minimum B | Recommended B | MCSE for proportion |
|---------|-----------|---------------|---------------------|
| Exploratory | 500 | 1,000 | ~1.4% at 95% coverage |
| Publication | 1,000 | 2,000 | ~1.0% at 95% coverage |
| Definitive | 5,000 | 10,000 | ~0.4% at 95% coverage |
| Precision | 10,000+ | 50,000 | ~0.2% at 95% coverage |

### MCSE Calculation

```r
# Calculate Monte Carlo standard errors
calculate_mcse <- function(estimates, coverage_indicators = NULL) {
  B <- length(estimates)

  list(
    # MCSE for mean (bias)
    mcse_mean = sd(estimates) / sqrt(B),

    # MCSE for standard deviation
    mcse_sd = sd(estimates) / sqrt(2 * (B - 1)),

    # MCSE for coverage (proportion)
    mcse_coverage = if (!is.null(coverage_indicators)) {
      p <- mean(coverage_indicators)
      sqrt(p * (1 - p) / B)
    } else NA
  )
}

# Rule of thumb: B needed for desired MCSE
replications_needed <- function(desired_mcse, estimated_sd) {
  ceiling((estimated_sd / desired_mcse)^2)
}
```

---

## R Code Templates

### Complete Simulation Template

```r
# Full simulation study template following Morris et al. guidelines
run_simulation_study <- function(
  n_sims = 2000,
  n_vec = c(200, 500, 1000),
  seed = 42,
  parallel = TRUE,
  n_cores = parallel::detectCores() - 1
) {

  set.seed(seed)

  # Define parameter grid
  params <- expand.grid(
    n = n_vec,
    effect_size = c(0, 0.14, 0.39),
    model_spec = c("correct", "misspecified")
  )

  # Setup parallel processing
  if (parallel) {
    cl <- parallel::makeCluster(n_cores)
    doParallel::registerDoParallel(cl)
    on.exit(parallel::stopCluster(cl))
  }

  # Run simulations
  results <- foreach(
    i = 1:nrow(params),
    .combine = rbind,
    .packages = c("tidyverse", "mediation")
  ) %dopar% {

    scenario <- params[i, ]
    sim_results <- replicate(n_sims, {
      data <- generate_dgp(scenario)
      estimates <- apply_methods(data)
      evaluate_performance(estimates, truth = scenario$effect_size)
    }, simplify = FALSE)

    summarize_scenario(sim_results, scenario)
  }

  # Add MCSE
  results <- add_monte_carlo_errors(results, n_sims)

  results
}

# Summarize with MCSE
add_monte_carlo_errors <- function(results, B) {
  results %>%
    mutate(
      mcse_bias = empirical_se / sqrt(B),
      mcse_coverage = sqrt(coverage * (1 - coverage) / B),
      mcse_rmse = rmse / sqrt(2 * B)
    )
}
```

### Parallel Simulation Template

```r
# Memory-efficient parallel simulation
run_parallel_simulation <- function(scenario, n_sims, n_cores = 4) {
  library(future)
  library(future.apply)

  plan(multisession, workers = n_cores)

  results <- future_replicate(n_sims, {
    data <- generate_dgp(scenario$n, scenario$params)
    est <- estimate_effect(data)
    list(
      estimate = est$point,
      se = est$se,
      covered = abs(est$point - scenario$truth) < 1.96 * est$se
    )
  }, simplify = FALSE)

  plan(sequential)  # Reset

  # Aggregate
  estimates <- sapply(results, `[[`, "estimate")
  ses <- sapply(results, `[[`, "se")
  covered <- sapply(results, `[[`, "covered")

  list(
    bias = mean(estimates) - scenario$truth,
    empirical_se = sd(estimates),
    mean_se = mean(ses),
    coverage = mean(covered),
    mcse_bias = sd(estimates) / sqrt(n_sims),
    mcse_coverage = sqrt(mean(covered) * (1 - mean(covered)) / n_sims)
  )
}
```

---

## Core Principles (Morris et al., 2019)

### ADEMP Framework
1. **Aims**: What question does the simulation answer?
2. **Data-generating mechanisms**: How is data simulated?
3. **Estimands**: What is being estimated?
4. **Methods**: What estimators are compared?
5. **Performance measures**: How is performance assessed?

## Data-Generating Process Design

### Standard Mediation DGP
```r
generate_mediation_data <- function(n, params) {
  # Confounders
  X <- rnorm(n)

  # Treatment (binary)
  ps <- plogis(params$gamma0 + params$gamma1 * X)
  A <- rbinom(n, 1, ps)

  # Mediator
  M <- params$alpha0 + params$alpha1 * A + params$alpha2 * X +
       rnorm(n, sd = params$sigma_m)

  # Outcome
  Y <- params$beta0 + params$beta1 * A + params$beta2 * M +
       params$beta3 * X + params$beta4 * A * M +
       rnorm(n, sd = params$sigma_y)

  data.frame(Y = Y, A = A, M = M, X = X)
}
```

### DGP Variations to Consider
- **Linearity**: Linear vs nonlinear relationships
- **Model specification**: Correct vs misspecified
- **Error structure**: Homoscedastic vs heteroscedastic
- **Interaction**: No interaction vs A×M interaction
- **Confounding**: Measured vs unmeasured
- **Treatment**: Binary vs continuous
- **Mediator**: Continuous vs binary vs count

## Parameter Grid Design

### Sample Size Selection
| Size | Label | Purpose |
|------|-------|---------|
| 100-200 | Small | Stress test |
| 500 | Medium | Typical study |
| 1000-2000 | Large | Asymptotic behavior |
| 5000+ | Very large | Efficiency comparison |

### Effect Size Selection
| Effect | Interpretation |
|--------|----------------|
| 0 | Null (Type I error) |
| 0.1 | Small |
| 0.3 | Medium |
| 0.5 | Large |

### Recommended Grid Structure
```r
params <- expand.grid(
  n = c(200, 500, 1000, 2000),
  effect = c(0, 0.14, 0.39, 0.59),  # Small/medium/large per Cohen
  confounding = c(0, 0.3, 0.6),
  misspecification = c(FALSE, TRUE)
)
```

## Performance Metrics

### Primary Metrics
| Metric | Formula | Target | MCSE Formula |
|--------|---------|--------|--------------|
| Bias | $\bar{\hat\psi} - \psi_0$ | ≈ 0 | $\sqrt{\text{Var}(\hat\psi)/n_{sim}}$ |
| Empirical SE | $\text{SD}(\hat\psi)$ | — | Complex |
| Average SE | $\bar{\widehat{SE}}$ | ≈ Emp SE | $\text{SD}(\widehat{SE})/\sqrt{n_{sim}}$ |
| Coverage | $\frac{1}{n_{sim}}\sum I(\psi_0 \in CI)$ | ≈ 0.95 | $\sqrt{p(1-p)/n_{sim}}$ |
| MSE | $\text{Bias}^2 + \text{Var}$ | Minimize | — |
| Power | % rejecting $H_0$ | Context-dependent | $\sqrt{p(1-p)/n_{sim}}$ |

### Relative Metrics (for method comparison)
- Relative bias: $\text{Bias}/\psi_0$ (when $\psi_0 \neq 0$)
- Relative efficiency: $\text{Var}(\hat\psi_1)/\text{Var}(\hat\psi_2)$
- Relative MSE: $\text{MSE}_1/\text{MSE}_2$

## Replication Guidelines

### Minimum Replications
| Metric | Minimum | Recommended |
|--------|---------|-------------|
| Bias | 1000 | 2000 |
| Coverage | 2000 | 5000 |
| Power | 1000 | 2000 |

### Monte Carlo Standard Error
Always report MCSE for key metrics:
- Coverage MCSE at 95%: $\sqrt{0.95 \times 0.05 / n_{sim}} \approx 0.007$ for $n_{sim}=1000$
- Need ~2500 reps for MCSE < 0.005

## R Implementation Template

```r
#' Run simulation study
#' @param scenario Parameter list for this scenario
#' @param n_rep Number of replications
#' @param seed Random seed
run_simulation <- function(scenario, n_rep = 2000, seed = 42) {
  set.seed(seed)

  results <- future_map(1:n_rep, function(i) {
    # Generate data
    data <- generate_data(scenario$n, scenario$params)

    # Fit methods
    fit1 <- method1(data)
    fit2 <- method2(data)

    # Extract estimates
    tibble(
      rep = i,
      method = c("method1", "method2"),
      estimate = c(fit1$est, fit2$est),
      se = c(fit1$se, fit2$se),
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se
    )
  }, .options = furrr_options(seed = TRUE)) %>%
    bind_rows()

  # Summarize
  results %>%
    group_by(method) %>%
    summarize(
      bias = mean(estimate) - scenario$true_value,
      emp_se = sd(estimate),
      avg_se = mean(se),
      coverage = mean(ci_lower <= scenario$true_value &
                      ci_upper >= scenario$true_value),
      mse = bias^2 + emp_se^2,
      .groups = "drop"
    )
}
```

## Results Presentation

### Standard Table Format
```
Table X: Simulation Results (n_rep = 2000)

                    Method 1                    Method 2
n       Bias   SE    Cov   MSE      Bias   SE    Cov   MSE
-----------------------------------------------------------
200     0.02   0.15  0.94  0.023    0.01   0.12  0.95  0.014
500     0.01   0.09  0.95  0.008    0.00   0.08  0.95  0.006
1000    0.00   0.06  0.95  0.004    0.00   0.05  0.95  0.003

Note: Cov = 95% CI coverage. MCSE for coverage ≈ 0.005.
```

### Visualization Guidelines
- Use faceted plots for multiple scenarios
- Show confidence bands for metrics
- Compare methods side-by-side
- Log scale for MSE if range is large

## Checkpoints and Reproducibility

### Checkpointing Strategy
```r
# Save results incrementally
if (i %% 100 == 0) {
  saveRDS(results_so_far,
          file = sprintf("checkpoint_%s_rep%d.rds", scenario_id, i))
}
```

### Reproducibility Requirements
1. Set seed explicitly
2. Record package versions (`sessionInfo()`)
3. Use `furrr_options(seed = TRUE)` for parallel
4. Save full results, not just summaries
5. Document any manual interventions

## Common Pitfalls

### Design Pitfalls
- Too few replications for coverage assessment
- Unrealistic parameter combinations
- Missing null scenario (effect = 0)
- No misspecification scenarios

### Implementation Pitfalls
- Not setting seeds properly in parallel
- Ignoring convergence failures
- Not checking for numerical issues
- Insufficient burn-in for MCMC methods

### Reporting Pitfalls
- Missing MCSE
- Not reporting convergence failures
- Cherry-picking scenarios
- Inadequate description of DGP

## Key References

- Morris et al 2019
- Burton et al
- White