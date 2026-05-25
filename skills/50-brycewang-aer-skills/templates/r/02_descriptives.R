# ============================================================
# 02_descriptives.R
# Summary-statistics scaffold.
# ============================================================

analytic_path <- file.path(INTERMEDIATE, "analytic.dta")

if (file.exists(analytic_path)) {
  dt <- haven::read_dta(analytic_path) |>
    as.data.table()

  numeric_cols <- names(dt)[vapply(dt, is.numeric, logical(1))]
  if (length(numeric_cols) > 0) {
    summary_dt <- dt[, lapply(.SD, function(x) {
      c(N = sum(!is.na(x)), mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE))
    }), .SDcols = numeric_cols]
    data.table::fwrite(summary_dt, file.path(TABLES, "summary_statistics.csv"))
  }
}
