# Review Checklist

Derived from 271 merged PRs in the ALARM fifty-states redistricting project.

---

## Common Reviewer Issues

| Issue | Stage | Fix | Severity |
|---|---|---|---|
| TODO comments left in code | Any | Remove all `TODO` markers before opening PR | must-fix |
| Wrong census year in data load | prep | Add explicit `year = 2010` (or 2000/2020) argument; delete cached intermediate files | must-fix |
| Copy-paste state name error (wrong state code in output filenames/objects) | prep/sim | Search for old state code; fix everywhere including saved `.rds` filenames | must-fix |
| Pseudocounties created in setup but `county` used in sim instead of `pseudo_county` | sim | Replace `admin = county` with `admin = pseudo_county` in `add_constr_splits()` | must-fix |
| R-hat > 1.05 (convergence failure) | sim | Increase `pop_temper` by 0.01; increase `nsims`; weaken most restrictive constraint | must-fix |
| Wrong hinge direction: using `hinge` when goal is "keep below" ceiling | sim | Switch to `form = "inv_hinge"` in `add_constr_grp_hinge()` | must-fix |
| VRA diagnostic plot missing | sim/doc | Add "VRA by Democratic performance" plot showing minority district vote share | must-fix |
| Population deviation too high (>1%) in validation plot | prep | Wrong census year loaded; fix data source year | must-fix |
| Final plan count wrong (e.g., 6,000 instead of 5,000) | sim | Fix thinning logic; thin *before* saving `.rds` and computing summary stats | must-fix |
| Missing contiguity/equal population in requirements section | doc | Always include federal requirements even if state does not explicitly list them | must-fix |
| Code runs side effects at source time (plots, file writes) | sim | Wrap in `if (interactive()) { }` | must-fix |
| Wrong EPSG/projection (copied from another state) | prep/setup | Use state-specific EPSG; verify against `EPSG[["ST"]]` lookup | must-fix |
| Extraneous race/party diagnostic plots | sim/doc | Remove plots not directly related to VRA or simulation quality; "avoid peeking at party/race unless VRA diagnostics warrant it" | warning |
| Pseudocounties not documented | doc | Add 1–2 sentence explanation: which counties split, why, and that it produces fewer muni splits than county-only constraint | warning |
| Placeholder values unfilled (X.X%, broken links) | doc | Fill in actual values; update broken URLs to archive links | warning |
| Unused/commented-out code blocks | prep/sim | Remove entirely; don't leave behind debug or exploratory code | warning |
| `merge_by` or preprocessing in wrong file | setup | Move all preprocessing merges to `02_setup_*.R`, not `03_sim_*.R` | warning |
| Low plan diversity warning (80% range too narrow) | sim | Try: weaken constraints, increase `pop_temper` by 0.01, increase `nsims`, remove cores constraint; note: acceptable for small states | warning |
| Hard-coded local paths | prep | Use `here()` package or standard public URLs; no local machine paths in PR | warning |
| R code embedded in documentation | doc | Rewrite as prose; documentation should not contain code blocks | warning |
| County constraint in code but documentation says "no county constraint" | doc | Correct documentation to match code | warning |
| enforce_style() not run before PR | PR | Run `enforce_style("{ST}", "{chamber}", {cycle})` and commit result | warning |
| Google Sheets tracker not updated | PR | Update status before merge | warning |
| Summary statistics computed on thinned instead of full pre-thin sample | sim | Run `summary(plans)` on the full sample to assess R-hat; then thin | warning |
| `pop_temper` included without justification | sim | Only use if acceptance rates drop in final splits; remove if not needed | warning |
| VRA constraint included in "legal requirements" section | doc | VRA constraints belong in "algorithmic notes / simulation choices" section, not legal requirements | warning |
| Pipe chains not line-broken | sim | Add line break after each `%>%` | warning |
| GEOID duplication (`*.x`, `*.y` columns in summary stats) | prep | Fix GEOID join; usually from a left_join creating duplicates | warning |

---

## Pre-PR Checklist

### Code Quality
- [ ] All `TODO` comments removed from every file
- [ ] No commented-out code blocks (remove, don't comment)
- [ ] No hard-coded local paths; all data sources use public URLs or `here()`
- [ ] All diagnostic/exploratory plots wrapped in `if (interactive()) { }`
- [ ] Preprocessing (merge_by, adjacency edits, core creation) in `01_prep_*.R` or `02_setup_*.R`, not `03_sim_*.R`
- [ ] `enforce_style("{ST}", "{chamber}", {cycle})` run and changes committed
- [ ] Correct EPSG projection for this state (not copied from another state)
- [ ] Pipes broken with line breaks after `%>%`
- [ ] Library calls consolidated at top of each file
- [ ] All four workflow files present: `01_prep_*.R`, `02_setup_*.R`, `03_sim_*.R`, `doc_*.md`

### Diagnostics
- [ ] All R-hat values ≤ 1.05
- [ ] Effective sample % > 80% in final SMC splits
- [ ] Log weight SD < 3.0
- [ ] Plan diversity (80% range) is reasonable given state geography
- [ ] If pseudocounties used: `plot(map, pseudo_county)` verified visually
- [ ] If cores used: `plot(map, core_id)` and `pop_overlap` histogram included
- [ ] Population deviation validation plot shows ≤ 0.5% (or state-specific tolerance)
- [ ] Final plan count is exactly 5,000
- [ ] Summary statistics computed on pre-thinned sample for R-hat assessment

### Documentation (`doc_*.md`)
- [ ] "Interpretation of requirements" includes contiguity and equal population (even if not explicitly stated in state law)
- [ ] Each legal constraint cited with source (statute or NCSL link)
- [ ] Pseudocounty structure explained in prose: which counties split, why, outcome (fewer muni splits)
- [ ] VRA constraints described in "algorithmic notes" section, not legal requirements
- [ ] No R code blocks in documentation
- [ ] All placeholder values (X.X%) filled with real numbers
- [ ] All links verified (use Wayback Machine archive links for dead URLs)
- [ ] Data sources section includes standard ALARM data citation
- [ ] Simulation choices section documents `pop_temper` justification if non-zero

### Data
- [ ] Correct census year loaded (2010 data for 2010 cycle, etc.)
- [ ] Adjacency graph modifications documented with rationale
- [ ] If VRA applies: BVAP/HVAP/CVAP plots included showing minority district performance
- [ ] If VRA applies: "VRA by Democratic performance" plot verifies minority districts elect presumed candidate of choice
- [ ] Enacted plan source URL works (update to ARP/archive URL if original is dead)
- [ ] No extraneous race/party plots unless directly relevant to VRA diagnostics

### PR Submission
- [ ] Google Sheets tracker updated to "Draft"
- [ ] Assigned graduate student reviewer tagged
- [ ] Labels and milestone added to PR
- [ ] Diagnostic plots pasted into PR description
- [ ] If unusual constraints: include figures showing constraint is binding
