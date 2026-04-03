# Troubleshooting

| Problem | Solution |
|---------|----------|
| No file path provided | Ask user for a valid `.tex`, `.typ`, or `.pdf` file |
| Script execution fails | Report the command, exit code, and stderr output |
| Missing sibling skill scripts | Check that `latex-paper-en/scripts/`, `latex-thesis-zh/scripts/`, or `typst-paper/scripts/` exist |
| PDF checks limited | PDF mode skips format/bib/figures checks; only visual and content analysis available |
| `--venue` not recognized | Use one of: `neurips`, `iclr`, `icml`, `ieee`, `acm`, `thesis-zh` |
| ScholarEval LLM dimensions show N/A | Run with `--scholar-eval`, then provide LLM scores via `--llm-json` |
| Re-audit missing previous report | Provide `--previous-report PATH` pointing to the prior audit output |
| Literature search returns no results | Check API keys; Semantic Scholar works without key but slower; arXiv always available |
| `TAVILY_API_KEY` not set | Set env var or pass `--tavily-key`; Tavily is optional — S2 + arXiv work without it |
| Semantic Scholar rate limited | Set `S2_API_KEY` for higher limits; the client has built-in exponential backoff |
| Literature Grounding shows N/A | Run with `--literature-search` to enable automated literature verification |
| Regression model gives unexpected scores | Check `scripts/models/scoring_model.json`; default coefficients approximate weighted average |
