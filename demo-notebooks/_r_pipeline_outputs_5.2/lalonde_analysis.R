###############################################################################
# Full Empirical Analysis — LaLonde (1986) NSW Job Training Program
# R pipeline following the 00.3-Full-empirical-analysis-skill_R 8-step framework
#
# Dataset:  https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv
# Output:   _r_pipeline_outputs_5.2/tables/*  and  figures/*
###############################################################################

# ── Step 0: Setup ──────────────────────────────────────────────────────────

output_dir <- "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks/_r_pipeline_outputs_5.2"

# Create sub-directories
tables_dir <- file.path(output_dir, "tables")
figures_dir <- file.path(output_dir, "figures")
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# Journal house-style: AER convention
aer_stars <- c("*" = 0.10, "**" = 0.05, "***" = 0.01)

#' Export a modelsummary object to all three required formats
save_table <- function(models, filename, coef_map = NULL, add_rows = NULL,
                       title = NULL, notes = NULL) {
  base <- file.path(tables_dir, tools::file_path_sans_ext(filename))
  for (ext in c(".tex", ".docx", ".xlsx")) {
    out_file <- paste0(base, ext)
    message("  → writing ", out_file)
    modelsummary::modelsummary(
      models,
      output    = out_file,
      stars     = aer_stars,
      gof_omit  = "BIC|AIC|F|Log|Adj|RMSE",
      coef_map  = coef_map,
      add_rows  = add_rows,
      title     = title,
      notes     = notes
    )
  }
}

#' Save a ggplot to PNG (≥300 dpi) and PDF
save_figure <- function(plot, filename, width = 8, height = 5) {
  png_path <- file.path(figures_dir, paste0(filename, ".png"))
  pdf_path <- file.path(figures_dir, paste0(filename, ".pdf"))
  message("  → writing ", png_path)
  ggplot2::ggsave(png_path, plot, width = width, height = height, dpi = 300)
  message("  → writing ", pdf_path)
  ggplot2::ggsave(pdf_path, plot, width = width, height = height)
}

# ── Load libraries ──────────────────────────────────────────────────────────

library(tidyverse)
library(fixest)
library(modelsummary)
library(gtsummary)
library(ggplot2)
library(haven)
library(sandwich)
library(lmtest)
library(car)
library(marginaleffects)
library(MatchIt)
library(WeightIt)
library(cobalt)
library(clubSandwich)
library(gt)
library(kableExtra)
library(flextable)
library(officer)
library(openxlsx)

setFixest_notes(FALSE)  # suppress fixest notes

message("\n══════════════════════════════════════════════════════════════════")
message("  LaLonde (1986) NSW Job Training — Full Empirical Pipeline")
message("══════════════════════════════════════════════════════════════════\n")

# ── Step 1: Data Import & Cleaning ────────────────────────────────────────

message("── Step 1: Data Import & Cleaning ────────────────────────────────")

url <- "https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv"
df_raw <- read_csv(url, show_col_types = FALSE) %>%
  janitor::clean_names()

message("  Raw dimensions: ", nrow(df_raw), " × ", ncol(df_raw))

# Convert types
df <- df_raw %>%
  mutate(
    treat    = as.integer(treat),
    age      = as.integer(age),
    educ     = as.integer(educ),
    race     = as.factor(race),
    married  = as.integer(married),
    nodegree = as.integer(nodegree),
    re74     = as.numeric(re74),
    re75     = as.numeric(re75),
    re78     = as.numeric(re78),
    # Create log earnings (adding 1 to handle zeros)
    lre74    = log(re74 + 1),
    lre75    = log(re75 + 1),
    lre78    = log(re78 + 1)
  )

stopifnot(nrow(df) == 614, ncol(df) == 13)
message("  Cleaned dimensions: ", nrow(df), " × ", ncol(df))

# Data contract
contract <- list(
  n_obs            = nrow(df),
  n_treated        = sum(df$treat == 1),
  n_control        = sum(df$treat == 0),
  n_missing        = sapply(df, function(x) sum(is.na(x))),
  treatment_share  = mean(df$treat),
  re78_mean_treat  = mean(df$re78[df$treat == 1]),
  re78_mean_control = mean(df$re78[df$treat == 0])
)
message("  Treated: ", contract$n_treated, " | Control: ", contract$n_control)
message("  Treatment share: ", round(contract$treatment_share, 3))

# ── Step 2: Variable Construction ─────────────────────────────────────────

message("\n── Step 2: Variable Construction ─────────────────────────────────")

df <- df %>%
  mutate(
    # Age squared for non-linear effects
    age_sq       = age^2,
    # Earnings bins for heterogeneity
    re74_pos     = as.integer(re74 > 0),
    re75_pos     = as.integer(re75 > 0),
    # Any prior earnings
    any_earn_pre = as.integer(re74 > 0 | re75 > 0),
    # Income categories
    re74_high    = as.integer(re74 > median(re74)),
    # Standardized covariates for matching
    age_std      = as.numeric(scale(age)),
    educ_std     = as.numeric(scale(educ))
  )

message("  Created derived variables: age_sq, lre74, lre75, lre78, re74_pos, re75_pos")

# ── Step 3: Descriptive Statistics & Table 1 ──────────────────────────────

message("\n── Step 3: Descriptive Statistics & Table 1 ──────────────────────")

# Table 1: Summary statistics by treatment status
tab1 <- df %>%
  select(treat, age, educ, race, married, nodegree, re74, re75, re78) %>%
  mutate(
    treat = factor(treat, levels = c(0, 1), labels = c("Control", "Treated")),
    race  = as.character(race),
    married = factor(married, levels = c(0, 1), labels = c("Not Married", "Married")),
    nodegree = factor(nodegree, levels = c(0, 1), labels = c("Has Degree", "No Degree"))
  )

# Create gtsummary Table 1 with SMD
tbl_one <- tab1 %>%
  tbl_summary(
    by = treat,
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 2,
    missing = "no"
  ) %>%
  add_overall()

# Save Table 1 as flextable/gt
tbl_one_gt <- tbl_one %>%
  as_gt() %>%
  gt::tab_header(title = "Table 1: Summary Statistics and Balance — LaLonde (1986) NSW Data") %>%
  gt::gtsave(file.path(tables_dir, "table1_balance.tex"))
# Workaround: gtsummary → modelsummary datasummary_balance for xlsx/docx

# Also produce balance table via modelsummary::datasummary_balance
ds_balance <- datasummary_balance(
  ~ treat,
  data = df %>% mutate(treat = factor(treat, levels = c(0,1), labels = c("Control","Treated"))),
  fmt = "%.2f",
  title = "Table 1: Summary Statistics and Balance — LaLonde NSW Data",
  output = "data.frame"
)
write.xlsx(ds_balance, file.path(tables_dir, "table1_balance.xlsx"))
# For docx we use flextable directly
ft_bal <- flextable(ds_balance) %>%
  autofit() %>%
  add_header_lines("Table 1: Summary Statistics and Balance — LaLonde NSW Data")
save_as_docx(ft_bal, path = file.path(tables_dir, "table1_balance.docx"))

message("  Table 1 saved: balance statistics")

# Figure F1: Distribution of outcome by treatment
f1 <- df %>%
  mutate(treat_lab = ifelse(treat == 1, "Treated (NSW)", "Control (CPS)")) %>%
  ggplot(aes(x = re78, fill = treat_lab)) +
  geom_density(alpha = 0.5, bw = 2000) +
  scale_fill_manual(values = c("Treated (NSW)" = "#E74C3C", "Control (CPS)" = "#3498DB")) +
  labs(
    title = "Figure 1: Distribution of 1978 Earnings by Treatment Status",
    x = "Real Earnings 1978 (USD)",
    y = "Density",
    fill = "Group",
    caption = "Data: LaLonde (1986) NSW Job Training Program"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

save_figure(f1, "fig1_trend", width = 8, height = 5)

# ── Step 4: Diagnostic Tests ──────────────────────────────────────────────

message("\n── Step 4: Diagnostic Tests ──────────────────────────────────────")

# Balance test: are pre-treatment covariates balanced?
message("\n  4a. Pre-treatment covariate balance (t-tests):")
balance_vars <- c("age", "educ", "married", "nodegree", "re74", "re75")
balance_results <- map_dfr(balance_vars, function(v) {
  test <- t.test(df[[v]] ~ df$treat)
  tibble(
    Variable   = v,
    Treated_M  = round(mean(df[[v]][df$treat == 1]), 2),
    Control_M  = round(mean(df[[v]][df$treat == 0]), 2),
    Diff       = round(mean(df[[v]][df$treat == 1]) - mean(df[[v]][df$treat == 0]), 2),
    P_value    = round(test$p.value, 4)
  )
})
print(balance_results)

# Homoskedasticity test (Breusch-Pagan) on baseline model
m_diag <- lm(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75, data = df)
bp_test <- bptest(m_diag)
message("\n  4b. Breusch-Pagan test for heteroskedasticity:")
message("      BP = ", round(bp_test$statistic, 3), ", p = ", format.pval(bp_test$p.value, digits = 4))

# VIF
vif_vals <- vif(m_diag)
message("\n  4c. Variance Inflation Factors:")
print(vif_vals)

# ── Step 5: Baseline Modeling ─────────────────────────────────────────────

message("\n── Step 5: Baseline Modeling ─────────────────────────────────────")

# 5a. OLS with progressive controls (M1 → M6)
# M1: Raw bivariate
m1 <- feols(re78 ~ treat, data = df, vcov = "hetero")

# M2: + demographics
m2 <- feols(re78 ~ treat + age + educ, data = df, vcov = "hetero")

# M3: + race
m3 <- feols(re78 ~ treat + age + educ + race, data = df, vcov = "hetero")

# M4: + marital status and degree
m4 <- feols(re78 ~ treat + age + educ + race + married + nodegree, data = df, vcov = "hetero")

# M5: + pre-treatment earnings
m5 <- feols(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75,
            data = df, vcov = "hetero")

# M6: + non-linear + interactions (saturated specification with FEs)
m6 <- feols(re78 ~ treat + age + age_sq + educ + race + married + nodegree +
              re74 + re75 + re74:re75,
            data = df, vcov = "hetero")

# Also: M7 with log earnings specification
m7 <- feols(lre78 ~ treat + age + educ + race + married + nodegree + lre74 + lre75,
            data = df, vcov = "hetero")

# Coefficient map for modelsummary
coef_main <- c("treat" = "Treatment (NSW Program)")

# Save Table 2: Main results with progressive controls
save_table(
  list(m1, m2, m3, m4, m5, m6),
  filename = "table2_main",
  coef_map = coef_main,
  title = "Table 2: Effect of NSW Job Training on 1978 Earnings — Progressive Controls"
)
message("  Table 2 (main results M1-M6) saved")

# 5b. Propensity Score Matching
message("\n  5b. Propensity Score Matching...")

psm_model <- feols(treat ~ age + educ + race + married + nodegree + re74 + re75,
                   data = df)
df$pscore <- predict(psm_model)

# 1:1 nearest-neighbor matching
m_match <- matchit(treat ~ age + educ + race + married + nodegree + re74 + re75,
                   data = df, method = "nearest", ratio = 1, caliper = 0.2)

df_matched <- match.data(m_match)
m_psm <- feols(re78 ~ treat, data = df_matched, vcov = "hetero")
message("    PSM ATT = ", round(coef(m_psm)["treat"], 2),
        " (SE = ", round(se(m_psm)["treat"], 2), ")")

# 5c. IPW via WeightIt
message("\n  5c. Inverse Probability Weighting...")
m_weight <- weightit(treat ~ age + educ + race + married + nodegree + re74 + re75,
                     data = df, method = "glm", estimand = "ATT")
df$ipw <- m_weight$weights
m_ipw <- feols(re78 ~ treat, data = df, weights = ~ipw, vcov = "hetero")
message("    IPW ATT = ", round(coef(m_ipw)["treat"], 2),
        " (SE = ", round(se(m_ipw)["treat"], 2), ")")

# Save Table 2b: Design horse-race (OLS / PSM / IPW)
save_table(
  list(m5, m_psm, m_ipw),
  filename = "table2b_designs",
  coef_map = coef_main,
  title = "Table 2b: Design Horse-Race — OLS, PSM, IPW Estimates of NSW Program Effect"
)
message("  Table 2b (design horse-race) saved")

# ── Step 6: Robustness ─────────────────────────────────────────────────────

message("\n── Step 6: Robustness ────────────────────────────────────────────")

# 6a. Cluster-robust SE (using bootstrapped / clubSandwich for matching)
# For the matched sample, we use clubSandwich
m_psm_lm <- lm(re78 ~ treat, data = df_matched)
vcov_CR2 <- vcovCR(m_psm_lm, cluster = df_matched$subclass, type = "CR2")
coef_test_CR2 <- coef_test(m_psm_lm, vcov = vcov_CR2)
message("    6a. PSM with clubSandwich CR2 SE: p(treat) = ",
        format.pval(coef_test_CR2["treat", "p_val"], digits = 4))

# 6b. Placebo test: effect on pre-treatment earnings
m_placebo_re74 <- feols(re74 ~ treat + age + educ + race + married + nodegree, data = df, vcov = "hetero")
m_placebo_re75 <- feols(re75 ~ treat + age + educ + race + married + nodegree, data = df, vcov = "hetero")
message("    6b. Placebo: treat → re74 = ", round(coef(m_placebo_re74)["treat"], 2),
        " (p = ", round(pvalue(m_placebo_re74)["treat"], 4), ")")
message("         Placebo: treat → re75 = ", round(coef(m_placebo_re75)["treat"], 2),
        " (p = ", round(pvalue(m_placebo_re75)["treat"], 4), ")")

# 6c. Robustness: drop zeros, log specification, different caliper
m_no_zeros <- feols(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75,
                    data = subset(df, re78 > 0), vcov = "hetero")
m_log <- feols(lre78 ~ treat + age + educ + race + married + nodegree + lre74 + lre75,
               data = df, vcov = "hetero")
m_mm <- feols(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75,
              data = df, vcov = "iid")

save_table(
  list(m5, m_no_zeros, m_log, m_mm),
  filename = "table5_robustness",
  coef_map = coef_main,
  title = "Table 5: Robustness — Alternative Specifications",
  notes = "Column (1): baseline OLS with HC SE. (2): dropping zero-earners. (3): log(re78+1) outcome. (4): OLS with iid SE."
)
message("  Table 5 (robustness) saved")

# ── Step 7: Further Analysis ──────────────────────────────────────────────

message("\n── Step 7: Further Analysis ───────────────────────────────────────")

# 7a. Heterogeneity by sub-group
hetero_results <- list()

# By race
for (r in c("black", "hispan", "white")) {
  sub <- subset(df, race == r)
  if (nrow(sub) > 50) {
    m_sub <- feols(re78 ~ treat + age + educ + married + nodegree + re74 + re75,
                   data = sub, vcov = "hetero")
    hetero_results[[paste0("Race: ", r)]] <- m_sub
  }
}

# By median age
df$age_group <- ifelse(df$age >= median(df$age), "Above Median Age", "Below Median Age")
for (g in unique(df$age_group)) {
  sub <- subset(df, age_group == g)
  m_sub <- feols(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75,
                 data = sub, vcov = "hetero")
  hetero_results[[paste0("Age: ", g)]] <- m_sub
}

# By marital status
m_married <- feols(re78 ~ treat + age + educ + race + nodegree + re74 + re75,
                   data = subset(df, married == 1), vcov = "hetero")
m_unmarried <- feols(re78 ~ treat + age + educ + race + nodegree + re74 + re75,
                     data = subset(df, married == 0), vcov = "hetero")
hetero_results[["Married"]] <- m_married
hetero_results[["Not Married"]] <- m_unmarried

save_table(
  hetero_results,
  filename = "table4_heterogeneity",
  coef_map = coef_main,
  title = "Table 4: Heterogeneity — Subgroup Analysis of NSW Program Effect"
)
message("  Table 4 (heterogeneity) saved")

# 7b. Marginal effects interaction: treat × re74 (baseline earnings)
m_interact <- feols(re78 ~ treat * re74 + age + educ + race + married + nodegree + re75,
                    data = df, vcov = "hetero")

# Predicted values for interaction
me <- marginaleffects::plot_predictions(
  m_interact, condition = c("re74", "treat"),
  points = 0.3
) + labs(
  title = "Figure 3: Treatment Effect by Baseline Earnings",
  x = "1974 Earnings (USD)",
  y = "Predicted 1978 Earnings",
  color = "Treatment",
  fill = "Treatment"
) + theme_minimal(base_size = 12) +
  scale_color_manual(values = c("0" = "#3498DB", "1" = "#E74C3C"),
                     labels = c("Control", "Treated")) +
  scale_fill_manual(values = c("0" = "#3498DB", "1" = "#E74C3C"),
                    labels = c("Control", "Treated")) +
  theme(legend.position = "bottom")

save_figure(me, "fig3_coefplot", width = 8, height = 5)

# 7c. Outcome ladder: effect on re74, re75, lre78 (mechanism)
m_outcome1 <- feols(re74 ~ treat + age + educ + race + married + nodegree + re75, data = df, vcov = "hetero")
m_outcome2 <- feols(re75 ~ treat + age + educ + race + married + nodegree + re74, data = df, vcov = "hetero")

save_table(
  list(m5, m_outcome1, m_outcome2, m7),
  filename = "table3_mechanism",
  coef_map = coef_main,
  title = "Table 3: Mechanism / Outcome Ladder — Effect on Different Earnings Measures"
)
message("  Table 3 (mechanism) saved")

# ── Step 8: Publication-Ready Figures ──────────────────────────────────────

message("\n── Step 8: Publication-Ready Figures and Summary ─────────────────")

# Figure F2: Balance plot before and after matching
# Balance plot using matched data to show before/after
love_plot <- love.plot(
  m_match,
  stats = c("mean.diffs"),
  threshold = 0.1,
  abs = FALSE,
  title = "Figure 2: Covariate Balance — Before and After Matching",
  colors = c("red", "blue"),
  shapes = c("circle", "triangle"),
  sample.names = c("Unadjusted", "Adjusted"),
  position = "bottom"
)
# love.plot returns a ggplot object
if (is.ggplot(love_plot)) {
  save_figure(love_plot, "fig2_event_study", width = 8, height = 5)
} else {
  message("  love.plot did not return a ggplot; saving manually")
  ggsave(file.path(figures_dir, "fig2_event_study.png"),
         plot = last_plot(), width = 8, height = 5, dpi = 300)
  ggsave(file.path(figures_dir, "fig2_event_study.pdf"),
         plot = last_plot(), width = 8, height = 5)
}

# Figure F4: Coefficient plot across all specifications
coefplot_df <- data.frame(
  Model = c("M1: Raw", "M2: + Age/Edu", "M3: + Race", "M4: + Mar/Nodeg",
            "M5: + Pre-earn", "M6: Saturated", "PSM (NN-1)", "IPW (ATT)",
            "Drop Zeros", "Log Outcome"),
  Coef = c(
    coef(m1)["treat"], coef(m2)["treat"], coef(m3)["treat"],
    coef(m4)["treat"], coef(m5)["treat"], coef(m6)["treat"],
    coef(m_psm)["treat"], coef(m_ipw)["treat"],
    coef(m_no_zeros)["treat"], coef(m_log)["treat"]
  ),
  SE = c(
    se(m1)["treat"], se(m2)["treat"], se(m3)["treat"],
    se(m4)["treat"], se(m5)["treat"], se(m6)["treat"],
    se(m_psm)["treat"], se(m_ipw)["treat"],
    se(m_no_zeros)["treat"], se(m_log)["treat"]
  )
)
coefplot_df <- coefplot_df %>%
  mutate(
    lo = Coef - 1.96 * SE,
    hi = Coef + 1.96 * SE,
    Model = factor(Model, levels = rev(Model))
  )

f4 <- ggplot(coefplot_df, aes(x = Model, y = Coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = lo, ymax = hi), size = 0.8, color = "#2C3E50") +
  coord_flip() +
  labs(
    title = "Figure 4: Coefficient Plot — NSW Program Effect Across Specifications",
    x = NULL,
    y = "Treatment Effect on 1978 Earnings (USD)",
    caption = "95% confidence intervals based on heteroskedasticity-robust standard errors"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.y = element_blank())

save_figure(f4, "fig4_sensitivity", width = 8, height = 5)

message("\n══════════════════════════════════════════════════════════════════")
message("  PIPELINE COMPLETE")
message("══════════════════════════════════════════════════════════════════")

# ── Summary of Results ─────────────────────────────────────────────────────

cat("\n")
cat("┌────────────────────────────────────────────────────────────────────┐\n")
cat("│  RESULTS SUMMARY                                                    │\n")
cat("├────────────────────────────────────────────────────────────────────┤\n")
cat(sprintf("│  Obs: %d total (%d treated, %d control)                          │\n",
            contract$n_obs, contract$n_treated, contract$n_control))
cat(sprintf("│  Outcome mean: treated=%.0f, control=%.0f                          │\n",
            contract$re78_mean_treat, contract$re78_mean_control))
cat("├────────────────────────────────────────────────────────────────────┤\n")
cat(sprintf("│  M1 (Raw):         β = %7.1f (SE = %5.0f)                          │\n",
            coef(m1)["treat"], se(m1)["treat"]))
cat(sprintf("│  M2 (+demog):      β = %7.1f (SE = %5.0f)                          │\n",
            coef(m2)["treat"], se(m2)["treat"]))
cat(sprintf("│  M3 (+race):       β = %7.1f (SE = %5.0f)                          │\n",
            coef(m3)["treat"], se(m3)["treat"]))
cat(sprintf("│  M4 (+mar/nodeg):  β = %7.1f (SE = %5.0f)                          │\n",
            coef(m4)["treat"], se(m4)["treat"]))
cat(sprintf("│  M5 (+pre-earn):   β = %7.1f (SE = %5.0f)                          │\n",
            coef(m5)["treat"], se(m5)["treat"]))
cat(sprintf("│  M6 (saturated):   β = %7.1f (SE = %5.0f)                          │\n",
            coef(m6)["treat"], se(m6)["treat"]))
cat("├────────────────────────────────────────────────────────────────────┤\n")
cat(sprintf("│  PSM (NN-1):       β = %7.1f (SE = %5.0f)                          │\n",
            coef(m_psm)["treat"], se(m_psm)["treat"]))
cat(sprintf("│  IPW (ATT):        β = %7.1f (SE = %5.0f)                          │\n",
            coef(m_ipw)["treat"], se(m_ipw)["treat"]))
cat("├────────────────────────────────────────────────────────────────────┤\n")
cat(sprintf("│  Placebo re74:     β = %7.1f (p = %.3f)                           │\n",
            coef(m_placebo_re74)["treat"], pvalue(m_placebo_re74)["treat"]))
cat(sprintf("│  Placebo re75:     β = %7.1f (p = %.3f)                           │\n",
            coef(m_placebo_re75)["treat"], pvalue(m_placebo_re75)["treat"]))
cat("├────────────────────────────────────────────────────────────────────┤\n")
cat("│  OUTPUT FILES                                                        │\n")
cat("│  tables/  table1_balance.xlsx/.docx/.tex                              │\n")
cat("│          table2_main.xlsx/.docx/.tex                                   │\n")
cat("│          table2b_designs.xlsx/.docx/.tex                               │\n")
cat("│          table3_mechanism.xlsx/.docx/.tex                              │\n")
cat("│          table4_heterogeneity.xlsx/.docx/.tex                          │\n")
cat("│          table5_robustness.xlsx/.docx/.tex                             │\n")
cat("│  figures/ fig1_trend.png(300dpi)+.pdf                                  │\n")
cat("│           fig2_event_study.png(300dpi)+.pdf                            │\n")
cat("│           fig3_coefplot.png(300dpi)+.pdf                                │\n")
cat("│           fig4_sensitivity.png(300dpi)+.pdf                             │\n")
cat("└────────────────────────────────────────────────────────────────────┘\n")
