# Venue-Specific Rules

When `--venue` (or `--journal`) is specified, the audit adds venue-specific checks:

| Venue | Key Rules |
|-------|-----------|
| `neurips` | 9-page limit, broader impact statement, paper checklist, double-blind |
| `iclr` | 10-page limit, reproducibility statement, double-blind |
| `icml` | 8-page limit, impact statement, 50MB supplementary limit |
| `ieee` | Abstract <=250 words, 3-5 keywords, >=300 DPI figures, no floating `algorithm` / `algorithm2e` pseudocode, figure-style pseudocode caption/label/reference checks |
| `acm` | CCS concepts required, acmart class, rights management |
| `thesis-zh` | GB/T 7714-2015 bibliography, bilingual abstract, university template |

Without `--venue`, only universal checklist items apply.
