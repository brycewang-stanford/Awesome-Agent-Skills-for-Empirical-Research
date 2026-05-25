# ============================================================
# 01_clean.R
# Raw-to-analytic data construction placeholder.
#
# Replace this file with project-specific cleaning code. The downstream
# template expects data/intermediate/analytic.dta with at least:
# unit_id, year, treat, treat_year, outcome, x1, x2, endog, iv, balanced.
# ============================================================

analytic_path <- file.path(INTERMEDIATE, "analytic.dta")

if (!file.exists(analytic_path)) {
  stop(
    "Missing data/intermediate/analytic.dta. Replace 01_clean.R with ",
    "project-specific raw-to-analytic code, or create the analytic file ",
    "before sourcing run_all.R.",
    call. = FALSE
  )
}

message("Found existing analytic file: ", analytic_path)
