# R pipeline v2 runner — produces the v2 artifacts that align this demo with
# the latest 00.3-Full-empirical-analysis-skill_R skill (Step -1 PAP, Step 0
# sample log + 5-check contract, Step 2.5 strategy.md, Step 3.5 ID graphics,
# Step 6 Pattern H robustness master + spec curve, Step 8 reproducibility
# stamp). Idempotent and standalone.

suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(jsonlite)
  library(pwr)
  library(MatchIt)
  library(cobalt)
  library(ggplot2)
  library(sandwich)
  library(lmtest)
  library(modelsummary)
  library(digest)
})

SEED <- 20260425
set.seed(SEED)

ROOT <- "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks/_r_pipeline_outputs"
TBL  <- file.path(ROOT, "tables")
FIG  <- file.path(ROOT, "figures")
ART  <- file.path(ROOT, "artifacts")
for (p in c(TBL, FIG, ART)) dir.create(p, recursive = TRUE, showWarnings = FALSE)

DATA_URL <- "https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv"

# ════════════════════════════════════════════════════════════════════════════════
# §-1 Pre-Analysis Plan — solve MDE on the analytic-sample N at 80% power, α=0.05
# ════════════════════════════════════════════════════════════════════════════════
df_pap <- readr::read_csv(DATA_URL, show_col_types = FALSE) |>
  janitor::clean_names() |>
  mutate(black  = as.integer(race == "black"),
         hispan = as.integer(race == "hispan"))

n_treat <- sum(df_pap$treat == 1)
n_ctrl  <- sum(df_pap$treat == 0)

# pwr::pwr.t2n.test solves the unequal-n two-sample t-test design
mde_d <- pwr::pwr.t2n.test(
  n1 = n_treat, n2 = n_ctrl,
  sig.level = 0.05, power = 0.80, alternative = "two.sided"
)$d
sd_re78     <- sd(df_pap$re78)
mde_dollars <- mde_d * sd_re78

pap <- list(
  design            = "selection on observables (Lalonde NSW)",
  population        = "Lalonde NSW treated workers + PSID comparison sample, 1976-78",
  outcome           = "re78 (1978 real earnings, USD)",
  treatment         = "treat (NSW assignment, 0/1)",
  estimand          = "ATT",
  n_treated_planned = n_treat,
  n_control_planned = n_ctrl,
  alpha             = 0.05,
  power_target      = 0.80,
  mde_cohens_d      = mde_d,
  mde_in_dollars    = mde_dollars,
  sd_re78           = sd_re78,
  frozen_at         = "2026-04-29",
  note              = paste("MDE solved by pwr::pwr.t2n.test with unequal arms;",
                             "convert d -> dollars via SD(re78) on analytic sample.")
)
write_json(pap, file.path(ART, "pap.json"), pretty = TRUE, auto_unbox = TRUE)
cat(sprintf("[§-1 PAP]  MDE Cohen's d = %.3f  ->  ~ $%.0f\n", mde_d, mde_dollars))

# ════════════════════════════════════════════════════════════════════════════════
# §0.1 Sample-construction log
# ════════════════════════════════════════════════════════════════════════════════
sample_log <- list()
add_log <- function(stage, n) sample_log[[length(sample_log) + 1]] <<- list(stage = stage, n = as.integer(n))

raw <- readr::read_csv(DATA_URL, show_col_types = FALSE)
add_log("0. raw rdatasets csv", nrow(raw))

df0 <- raw |> janitor::clean_names() |> select(-any_of("rownames")) |> drop_na()
add_log("1. clean_names + drop rownames + dropna", nrow(df0))

df1 <- df0 |>
  mutate(black  = as.integer(race == "black"),
         hispan = as.integer(race == "hispan"))
add_log("2. recode race -> black/hispan", nrow(df1))

df2 <- df1 |> filter(treat %in% c(0, 1))
add_log("3. enforce treat in {0,1}", nrow(df2))
df <- df2

write_json(sample_log, file.path(ART, "sample_construction.json"),
           pretty = TRUE, auto_unbox = TRUE)
cat("[§0.1 Sample log]\n")
for (e in sample_log) cat(sprintf("  %-40s  N = %4d\n", e$stage, e$n))

# ════════════════════════════════════════════════════════════════════════════════
# §0.2 Five-check data contract
# ════════════════════════════════════════════════════════════════════════════════
covariates <- c("age", "educ", "black", "hispan", "married", "nodegree", "re74", "re75")
keys       <- c("re78", "treat", covariates)

contract <- list(
  n_obs            = nrow(df),
  dtypes           = sapply(df[, keys], function(x) class(x)[1]),
  n_missing        = sapply(df[, keys], function(x) as.integer(sum(is.na(x)))),
  n_dupes_on_keys  = as.integer(sum(duplicated(df))),
  y_range          = c(min(df$re78), max(df$re78)),
  treatment_share  = mean(df$treat),
  treatment_levels = sort(unique(df$treat)),
  panel_balanced   = NULL,
  mcar_hint        = "vacuously OK (no missing y after Step 0.1 dropna)"
)
stopifnot(contract$n_obs > 0)
stopifnot(all(contract$n_missing == 0))
stopifnot(identical(as.integer(contract$treatment_levels), c(0L, 1L)))
write_json(contract, file.path(ART, "data_contract.json"), pretty = TRUE, auto_unbox = TRUE)
cat(sprintf("[§0.2 Contract] N=%d, treat share=%.3f, y range=[$%.0f, $%.0f]\n",
            contract$n_obs, contract$treatment_share,
            contract$y_range[1], contract$y_range[2]))

# ════════════════════════════════════════════════════════════════════════════════
# §2.5 Empirical strategy
# ════════════════════════════════════════════════════════════════════════════════
strategy_md <- "# Empirical Strategy — Lalonde NSW (pre-registration)

**Frozen at**: 2026-04-29
**Population**: Lalonde NSW treated workers + PSID comparison sample, 1976–78
**Treatment**: `treat` (binary, NSW assignment)
**Outcome**:   `re78` (1978 real earnings, USD)
**Estimand**:  ATT — average treatment effect on the program's actual participants
**Design**:    selection on observables (cross-sectional X-adjustment)

## Estimating equation

```
re78_i = α + β · treat_i + X_i' γ + ε_i
X_i = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumption

1. **Conditional unconfoundedness**: `Y(0), Y(1) ⊥ D | X` — outside the NSW
   experiment, PSID comparison units differ on observables; conditioning on
   `X` closes the back door.
2. **Overlap**: 0 < Pr(D=1 | X) < 1 in the joint support — verified in §3 via
   the propensity-score overlap plot.

## Auto-flagged threats (must defend in §6 robustness)

- Selection on unobservables (motivation, ability not in X) → Oster δ
- Functional-form sensitivity → progressive M1→M6 + spec curve
- Outcome scale (levels vs IHS / log) → robustness rows
- PSID comparison group choice (PSID-1 vs CPS-1) → out-of-scope here; flagged

## Fallback estimators (§6 / §7 robustness)

- IPW (HC3-corrected) on logistic propensity (`WeightIt::weightit`)
- AIPW / DR-Learner (`grf::causal_forest`, `DoubleML::DoubleMLPLR`)
- Entropy balancing (`WeightIt::weightit(method = 'ebal')`)

## Reporting checklist (Step 8)

- Report β̂(ATT) under M1→M6 progressive controls (Pattern A)
- Convergent evidence: feols / WeightIt / MatchIt / DoubleML (Pattern B)
- Attach Oster δ, spec curve, sensitivity dashboard
- Persist `result.json` reproducibility stamp with dataset SHA256 + version pins
"
writeLines(strategy_md, file.path(ART, "strategy.md"))
cat(sprintf("[§2.5 Strategy] wrote %s\n", file.path(ART, "strategy.md")))

# ════════════════════════════════════════════════════════════════════════════════
# §3.5 Identification graphics — love plot via MatchIt + cobalt; PS overlap via ggplot
# ════════════════════════════════════════════════════════════════════════════════
m_out <- MatchIt::matchit(
  treat ~ age + educ + black + hispan + married + nodegree + re74 + re75,
  data = df, method = "nearest", ratio = 1
)

# Love plot — cobalt's primary identification figure for selection-on-observables
p_love <- cobalt::love.plot(
  m_out, stats = "mean.diffs", binary = "std",         # force SMD throughout
  threshold = 0.10, abs = TRUE, var.order = "unadjusted",
  title = "Figure 2c. Love plot - covariate balance pre vs post 1:1 PSM"
)
ggsave(file.path(FIG, "fig2c_love_plot.pdf"), p_love, width = 7.5, height = 4.5)
ggsave(file.path(FIG, "fig2c_love_plot.png"), p_love, width = 7.5, height = 4.5, dpi = 300)
cat(sprintf("[§3.5] love plot -> %s\n", file.path(FIG, "fig2c_love_plot.png")))

# Propensity-score overlap (positivity check)
ps_logit <- glm(treat ~ age + educ + black + hispan + married + nodegree + re74 + re75,
                data = df, family = binomial())
df$ps <- predict(ps_logit, type = "response")

p_overlap <- ggplot(df, aes(x = ps, fill = factor(treat, levels = c(0, 1),
                                                   labels = c("Control", "Treated")))) +
  geom_histogram(aes(y = after_stat(density)), position = "identity", alpha = 0.55, bins = 25) +
  scale_fill_manual(values = c("Control" = "#cc4444", "Treated" = "#1f77b4"), name = NULL) +
  labs(x = "Estimated propensity score Pr(treat=1 | X)",
       y = "Density",
       title = "Figure 2c-bis. Propensity-score overlap (positivity diagnostic)") +
  theme(legend.position = "bottom")
ggsave(file.path(FIG, "fig2c2_overlap.pdf"), p_overlap, width = 7.5, height = 4.5)
ggsave(file.path(FIG, "fig2c2_overlap.png"), p_overlap, width = 7.5, height = 4.5, dpi = 300)
cat(sprintf("[§3.5] PS overlap -> %s\n", file.path(FIG, "fig2c2_overlap.png")))

# ════════════════════════════════════════════════════════════════════════════════
# §4 Main result — OLS with HC3 SE, full controls
# ════════════════════════════════════════════════════════════════════════════════
spec_full <- re78 ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75
m_main    <- lm(spec_full, data = df)
coef_test <- lmtest::coeftest(m_main, vcov. = sandwich::vcovHC(m_main, type = "HC3"))
b_main  <- coef_test["treat", "Estimate"]
se_main <- coef_test["treat", "Std. Error"]
ci_main <- c(b_main - 1.96 * se_main, b_main + 1.96 * se_main)
cat(sprintf("[§4 Main] beta(treat) = $%.0f  (HC3 SE = $%.0f, 95%% CI [$%.0f, $%.0f])\n",
            b_main, se_main, ci_main[1], ci_main[2]))

# ════════════════════════════════════════════════════════════════════════════════
# §6 Pattern H — Robustness master Table A1 + Figure 5 spec curve
# ════════════════════════════════════════════════════════════════════════════════
fit_hc3 <- function(formula, data) {
  m <- lm(formula, data = data)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC3"))
  list(model = m, coeftest = ct)
}
fit_hc1 <- function(formula, data) {
  m <- lm(formula, data = data)
  ct <- lmtest::coeftest(m, vcov. = sandwich::vcovHC(m, type = "HC1"))
  list(model = m, coeftest = ct)
}

specs_h <- list(
  "(1) Baseline (HC3)"    = fit_hc3(spec_full, df),
  "(2) HC1 SE"             = fit_hc1(spec_full, df),
  "(3) Drop top 1% re78"   = fit_hc3(spec_full, df |> filter(re78 < quantile(re78, 0.99))),
  "(4) Common support"     = fit_hc3(spec_full, df |> filter(ps > 0.05, ps < 0.95)),
  "(5) Add age^2 + educ^2" = fit_hc3(update(spec_full, . ~ . + I(age^2) + I(educ^2)), df),
  "(6) Add re74^2 + re75^2" = fit_hc3(update(spec_full, . ~ . + I(re74^2) + I(re75^2)), df),
  "(7) Drop u74 strata"    = fit_hc3(spec_full, df |> filter(re74 > 0)),
  "(8) Earners only"       = fit_hc3(spec_full, df |> filter(re78 > 0)),
  "(9) IHS outcome"        = fit_hc3(asinh(re78) ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75, df),
  "(10) Log outcome"       = fit_hc3(log1p(re78) ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75, df)
)

rob <- map_dfr(names(specs_h), function(label) {
  ct <- specs_h[[label]]$coeftest
  m  <- specs_h[[label]]$model
  tibble(
    spec  = label,
    beta  = ct["treat", "Estimate"],
    se    = ct["treat", "Std. Error"],
    p     = ct["treat", "Pr(>|t|)"],
    n     = nobs(m),
    ci_lo = ct["treat", "Estimate"] - 1.96 * ct["treat", "Std. Error"],
    ci_hi = ct["treat", "Estimate"] + 1.96 * ct["treat", "Std. Error"]
  )
})
write_csv(rob, file.path(TBL, "tableA1_robustness.csv"))

# Render LaTeX directly with modelsummary on bare lm objects (so coef_map applies)
ms_input <- map(specs_h, "model")
modelsummary::modelsummary(
  ms_input,
  output    = file.path(TBL, "tableA1_robustness.tex"),
  vcov      = "HC3",
  stars     = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map  = c("treat" = "Job training (treat)"),
  gof_omit  = "BIC|AIC|F|Log|RMSE|Adj",
  notes     = c("HC3 robust standard errors in parentheses (HC1 in column 2).",
                "* p<0.10, ** p<0.05, *** p<0.01.")
)
cat(sprintf("[§6 Pattern H] Table A1 -> %s  (%d rows)\n",
            file.path(TBL, "tableA1_robustness.tex"), nrow(rob)))

# Figure 5 — specification curve (sorted by beta, with 95% CI)
ord_rob <- rob |> arrange(beta) |> mutate(rank = row_number(),
                                            spec = factor(spec, levels = spec))
p_spec <- ggplot(ord_rob, aes(rank, beta)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.15, color = "#1f77b4") +
  geom_point(color = "#1f77b4", size = 2.5) +
  scale_x_continuous(breaks = ord_rob$rank, labels = ord_rob$spec) +
  labs(x = NULL, y = expression(hat(beta)["treat"] ~ "on re78  ($)"),
       title = "Figure 5. Specification curve - beta(treat) across robustness checks (95% CI)") +
  theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 8))
ggsave(file.path(FIG, "fig5_spec_curve.pdf"), p_spec, width = 9, height = 4.5)
ggsave(file.path(FIG, "fig5_spec_curve.png"), p_spec, width = 9, height = 4.5, dpi = 300)
cat(sprintf("[§6 Pattern H] spec curve -> %s\n", file.path(FIG, "fig5_spec_curve.png")))

# ════════════════════════════════════════════════════════════════════════════════
# §8 Reproducibility stamp
# ════════════════════════════════════════════════════════════════════════════════
dataset_sha256 <- substr(digest::digest(df, algo = "sha256"), 1, 16)

stamp <- list(
  R_version            = R.version$version.string,
  fixest_version       = as.character(packageVersion("fixest")),
  modelsummary_version = as.character(packageVersion("modelsummary")),
  matchit_version      = as.character(packageVersion("MatchIt")),
  cobalt_version       = as.character(packageVersion("cobalt")),
  pwr_version          = as.character(packageVersion("pwr")),
  seed                 = SEED,
  dataset_sha256_16    = dataset_sha256,
  n_obs                = nobs(m_main),
  estimand             = "ATT (selection on observables)",
  estimator            = "OLS with HC3 SE, full covariate set",
  headline_estimate    = b_main,
  headline_se          = se_main,
  headline_ci95        = ci_main,
  pre_registration     = "artifacts/pap.json + artifacts/strategy.md",
  data_contract        = "artifacts/data_contract.json",
  sample_log           = "artifacts/sample_construction.json",
  robustness_master    = "tables/tableA1_robustness.tex",
  spec_curve           = "figures/fig5_spec_curve.png",
  love_plot            = "figures/fig2c_love_plot.png",
  ps_overlap           = "figures/fig2c2_overlap.png",
  frozen_at            = "2026-04-29"
)
write_json(stamp, file.path(ART, "result.json"), pretty = TRUE, auto_unbox = TRUE)
cat(sprintf("[§8 Stamp] %s  (beta=%+.1f, 95%% CI [%+.1f, %+.1f])\n",
            file.path(ART, "result.json"), b_main, ci_main[1], ci_main[2]))

cat("\n[OK] All R v2 artifacts written under", ROOT, "\n")
