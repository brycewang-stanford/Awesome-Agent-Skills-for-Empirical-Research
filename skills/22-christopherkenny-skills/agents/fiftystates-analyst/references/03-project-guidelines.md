# Project-Wide Guidelines

- Compress all `.rds` files: `readr::write_rds(object, "path.rds", compress = "gz")`.
- Shared functions used across multiple analyses go in `R/` with full roxygen documentation, in their own PR, reviewed by a graduate student. If the analyst is a graduate student, a *different* graduate student must review.
- Mark code sections with RStudio-style comments: `# Clean Data ----`
- Nothing in `data-raw/` or `data-out/` is committed to GitHub.
