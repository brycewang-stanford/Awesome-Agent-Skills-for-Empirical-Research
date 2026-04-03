# Common Issues and Fixes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Very skewed plan weights (1–2 plans dominate) | Constraint too tight; too few SMC particles | Loosen constraint strength or increase `n_sims` |
| Plan diversity stuck near 0 | Adjacency graph error or constraints over-determine sample | Check `adj` graph for isolated nodes or broken edges; relax constraints |
| Enacted plan population deviation very high | Enacted plan added incorrectly | Re-check `alarm_add_plan()` call and column names |
| Style enforcement changes many lines | `enforce_style()` not run during development | Run, review, and commit style changes before the final PR |
| PR flagged for missing constraint figures | State has unusual or additional constraints | Add plots showing constraint strength sweep and binding behavior |
