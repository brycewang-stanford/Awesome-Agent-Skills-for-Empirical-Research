# ============================================================
# 03_main_did.R
# Staggered DiD with modern estimator (Callaway-Sant'Anna).
# Produces main table, event-study figure, Bacon decomposition,
# and Honest DiD sensitivity bounds.
# ============================================================

dt <- haven::read_dta(file.path(INTERMEDIATE, "analytic.dta")) |>
  as.data.table()

# ============================================================
# 1. Naive TWFE (FOR COMPARISON ONLY)
# ============================================================
m_twfe <- feols(
  outcome ~ treat + x1 + x2 | unit_id + year,
  data    = dt,
  cluster = ~ unit_id
)

# ============================================================
# 2. Goodman-Bacon decomposition
# ============================================================
bacon_out <- bacon(outcome ~ treat,
                   data       = as.data.frame(dt),
                   id_var     = "unit_id",
                   time_var   = "year")
saveRDS(bacon_out, file.path(INTERMEDIATE, "bacon_decomp.rds"))

# ============================================================
# 3. Callaway-Sant'Anna ATT(g,t) -- PREFERRED ESTIMATOR
# ============================================================
cs_att <- att_gt(
  yname         = "outcome",
  tname         = "year",
  idname        = "unit_id",
  gname         = "treat_year",
  xformla       = ~ x1 + x2,
  data          = as.data.frame(dt),
  est_method    = "dr",            # doubly-robust IPW
  control_group = "notyettreated", # avoids forbidden comparisons
  clustervars   = "unit_id"
)

# Simple aggregate ATT
cs_simple <- aggte(cs_att, type = "simple")
cs_dyn    <- aggte(cs_att, type = "dynamic", min_e = -5, max_e = 5)
cs_group  <- aggte(cs_att, type = "group")

# ============================================================
# 4. Event-study plot
# ============================================================
event_df <- data.frame(
  e        = cs_dyn$egt,
  estimate = cs_dyn$att.egt,
  se       = cs_dyn$se.egt
) |>
  mutate(
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se,
    post  = e >= 0
  )

p_event <- ggplot(event_df, aes(x = e, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey40") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi, color = post)) +
  scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = "black"),
                     guide  = "none") +
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  labs(x = "Years relative to treatment",
       y = "ATT estimate",
       title = NULL)

ggsave(file.path(FIGURES, "fig_event_study.pdf"),
       p_event, width = 6, height = 4, device = cairo_pdf)

# ============================================================
# 5. Honest DiD sensitivity (Rambachan-Roth)
# ============================================================
honest_out <- HonestDiD::createSensitivityResults_relativeMagnitudes(
  betahat      = cs_dyn$att.egt,
  sigma        = cs_dyn$V.egt,
  numPrePeriods  = sum(cs_dyn$egt < 0),
  numPostPeriods = sum(cs_dyn$egt >= 0),
  Mbarvec      = seq(0, 1, 0.1)
)
saveRDS(honest_out, file.path(INTERMEDIATE, "honest_did.rds"))

# ============================================================
# 6. Main results table -- TWFE vs Callaway-Sant'Anna
# ============================================================
modelsummary(
  list("TWFE (biased)"        = m_twfe,
       "Callaway-Sant'Anna"   = cs_simple),
  output     = file.path(TABLES, "tab_main_did.tex"),
  stars      = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  fmt        = 3,
  coef_map   = c("treat" = "Treatment", "ATT" = "Treatment"),
  gof_omit   = "IC|Log|RMSE|Adj|F|Pseudo",
  notes      = c("Standard errors clustered at the unit level.",
                 "TWFE shown for comparison only; Bacon decomposition (Fig A) reports forbidden-comparison weight."),
  booktabs   = TRUE
)
