# Constraint Pattern Reference

Derived from 271 merged PRs in the ALARM fifty-states redistricting project.

---

## Equal Population

**Legal basis:** Federal constitutional requirement; all congressional plans. State law for state legislative.

**Encoding:**
```r
# Set in redist_map() — not a separate constraint
map <- redist_map(shp, existing_plan = cd_2020, pop_tol = 0.005)
```

**Typical tolerance:** 0.005 (0.5%) for congressional; some states stricter:
- Indiana, Tennessee, Washington: 0.0005–0.001 (strict enacted plans)
- Minnesota: 0.001
- Iowa: 0.0001 (statutory)

**Calibration:** When SMC acceptance rates drop quickly in final splits, increase `pop_temper` by 0.01 (e.g., from 0 to 0.01). Do not go above 0.05–0.06 without strong justification. Higher `pop_temper` trades strict equality for better mixing.

**Common mistakes:**
- Confusing `pop_tol` (tolerance for map object) with `pop_temper` (SMC sampling parameter)
- Loading data from wrong census year → apparent 10%+ deviations
- Utah: state law defines 1% *total range*, implying `pop_tol = 0.005` (not 0.01 or 0.0005)

---

## Contiguity

**Legal basis:** Required in all states.

**Encoding:** Enforced by redist's sampling algorithm. The prep stage must ensure a valid connected adjacency graph.

```r
# In 01_prep: modify adjacency graph
adj <- geomander::get_adjacent(shp)

# Remove non-contiguous edges (e.g., across water/mountains)
adj <- geomander::subtract_edge(adj, which(shp$GEOID == "A"), which(shp$GEOID == "B"))

# Add edges for physically connected but non-adjacent units (e.g., ferry routes, bridges)
adj[[i]] <- c(adj[[i]], j)
adj[[j]] <- c(adj[[j]], i)
```

**State-specific patterns:**
- **Oregon:** Remove edges between counties not connected by a state or federal highway (Or. Rev. Stat. § 188.010)
- **Washington:** Remove edges across water barriers; reconnect via ferry/bridge/highway
- **Maryland/Michigan:** Remove water-area precincts from adjacency; connect islands to nearest land precinct in same county
- **Hawaii:** Islands manually connected (does not affect simulation contiguity, only for visualization)
- **Multi-island states:** Remove offshore/island tracts; reallocate population to nearest mainland precinct

**Calibration:** Binary — either the graph is valid or it isn't. Run `check_plans_piece_contiguity()` after simulation to verify. Document all adjacency modifications in `01_prep_*.R`.

**Common mistakes:**
- Disconnected precincts from water bodies create infeasible plans
- Bay areas (e.g., Chesapeake): use `subtract_edge()` on both sides of the bay
- Using polygon adjacency instead of piece-level adjacency → false negatives for slivers

---

## County/Municipality Preservation (Pseudocounty Constraint)

**Legal basis:** Most states require avoiding splits "where practicable" or "to the extent possible."

**Encoding:** Create pseudocounties that group units, then use as the county constraint unit:

```r
# In 02_setup: build pseudocounties
# Counties larger than the district target are split into per-municipality units
pseudo_county <- pick_county_muni(
  map,
  counties = county,
  munis = muni,
  pop_muni = get_target(map)   # split counties larger than one district
)

# In 03_sim: use in SMC
cons <- redist_constr(map) |>
  add_constr_splits(strength = 1.5, admin = pseudo_county)
```

**Logic:** Counties whose population exceeds the district population target are split into pseudocounties, where each municipality becomes its own unit. Counties below the target remain whole.

**State examples:**
- Illinois: Cook + DuPage counties → each municipality as pseudocounty; all other counties whole
- Pennsylvania: Allegheny, Montgomery, Philadelphia → per-municipality; others whole
- California: ~15 large counties split; remainder treated as county units
- Oklahoma: Oklahoma County → municipalities; all others whole
- Rhode Island: State senate districts used as pseudocounties (statutory boundary requirement)
- Iowa: County + municipal boundaries both enforced (strict statutory requirement)

**County constraint only (no pseudocounties):** Maine, Idaho, Kansas, Nevada, Nebraska (smaller states where no county exceeds district target).

**Calibration:**
- County constraint `strength = 2.0` is the typical sweet spot; test 2.5 and 3.0 if needed
- Strength > 2.5 often causes R-hat values > 1.05 (convergence failure)
- The pseudocounty approach produces fewer municipality splits than a raw county constraint

**Common mistakes:**
- Creating pseudocounties in `02_setup` but forgetting to use `pseudo_county` instead of `county` in `03_sim`
- Not documenting which counties triggered the pseudocounty split in `doc_*.md`
- Stating "no special techniques" when pseudocounties are actually in use

---

## Compactness

**Legal basis:** Many states require "geographically compact" districts. Not always encoded as an active constraint.

**Encoding:** Measured post-hoc; seldom constrained directly:
```r
# Validation metrics tracked automatically in summary(plans):
# comp_edge   — edge compactness
# comp_polsby — Polsby-Popper compactness

# If compactness constraint needed (rare):
cons <- cons |>
  add_constr_compactness(strength = 0.8)  # weaken for small/constrained states
```

**Calibration:**
- Default compactness weight = 1.0; weaken to 0.8–0.9 for small states (Maine) where geographic constraints already limit options
- Iowa requires two statutory compactness measures; verify both pass
- If reviewer flags low compactness: try increasing `rho` parameter in redist_smc(), or weaken other constraints that may be forcing irregular shapes

**Common mistakes:**
- Treating compactness as a hard constraint when state law only requires it "where practicable"
- Leaving Iowa-specific compactness code in another state's files

---

## Voting Rights Act / Majority-Minority Districts

**Legal basis:** Federal VRA §2; some states have additional minority representation requirements.

**Encoding:** Hinge Gibbs constraints encouraging minority VAP thresholds:

```r
# Standard hinge: penalize districts below target VAP (encourage ≥ threshold)
cons <- cons |>
  add_constr_grp_hinge(
    strength = 20,
    group_pop = map$vap_black,
    total_pop = map$vap,
    tgts_group = 0.50   # encourage ≥50% BVAP
  )

# Anti-packing (inverted hinge): penalize districts above threshold
cons <- cons |>
  add_constr_grp_hinge(
    strength = 10,
    group_pop = map$vap_black,
    total_pop = map$vap,
    tgts_group = 0.65,
    form = "inv_hinge"   # penalize > 65% BVAP (prevents packing)
  )
```

**Typical targets and strength values:**

| Group | Typical target | Strength | Notes |
|---|---|---|---|
| BVAP (Black VAP) | 0.50 | 20 | Primary MMD target |
| BVAP anti-packing | 0.65 | 10 | Prevents over-concentration |
| HVAP (Hispanic VAP) | 0.50 | 20 | Cuban district FL: Republican-leaning |
| Asian VAP | 0.40–0.50 | 10–20 | CA, HI |
| CVAP (Citizen VAP) | 0.50 | 20 | Use for Hispanic when large non-citizen pop |

**Fin/sharkfin constraint:** Use when a soft penalty on both sides is needed:
```r
# Penalizes both too-low and too-high minority share (smooth hill)
add_constr_grp_hinge(..., form = "fin")
```

**Post-hoc filtering (alternative/supplement):**
```r
# Oversample then subset to plans with ≥1 MMD meeting threshold
plans_filtered <- plans |>
  filter_plans_plurality(
    group_pop = map$vap_black,
    total_pop = map$vap,
    tgt = 0.30,           # ≥30% BVAP
    min_districts = 1
  )
```

**State-specific approaches:**
- **Alabama/South Carolina:** Generate 10k–20k plans, subset to 5k with ≥1 BVAP≥30% district + Democratic winner
- **Florida (regional):** Multi-region SMC (North/South/Central); separate BVAP/HVAP thresholds per region
- **Georgia:** strength=20 for target, strength=10 anti-packing
- **Mississippi:** strength=20, single majority-Black district
- **North Carolina:** Hinge targeting 1 majority-minority district; increase strength if plans fail performance check
- **Illinois:** BVAP + HVAP each needing a ≥30% district

**Calibration notes:**
- Constraints do not *guarantee* performance in all plans — they bias the distribution
- If minority district is non-performant (Republican winner despite high BVAP), increase target threshold or strength
- Too high strength → reduced plan diversity (80% range collapses) → weaken if VI distance drops
- Use `inv_hinge` (not `hinge`) when goal is "keep below a ceiling"
- When BVAP and HVAP constraints conflict, weaken the secondary one first

**Common mistakes:**
- Using `hinge` when `inv_hinge` is needed (nudges in wrong direction)
- Forgetting to include VRA diagnostic plot ("VRA by Democratic performance") in the PR
- Encoding VRA as a hard constraint in `doc_*.md` requirements when it should be in the "algorithmic notes" section

---

## District Core Preservation

**Legal basis:** Some states require "preserving cores of prior districts" (e.g., Kansas, Utah).

**Encoding:** Pre-processing step in `01_prep_*.R`:
```r
# Merge all precincts more than 2 precincts from any district border
# Precincts in split counties are only merged within their county
cores <- redist.make.cores(
  adj = adj,
  existing_plan = map$cd_2010,
  boundary = 2
)
map <- merge_by(map, cores)
```

**Calibration:**
- `boundary = 2` (merge precincts ≥2 away from border) is standard
- Reduces search space; can lower plan diversity — acceptable when legally required
- Validate with `plot(map, cores)` and `pop_overlap` histogram vs. prior plan

**When to use:** Only when state law or criteria explicitly require preserving prior district cores. Do not apply universally.

---

## Status Quo / Least-Change Constraint

**Legal basis:** Wisconsin Supreme Court ruling (least-change criterion); other states with continuity requirements.

**Encoding:**
```r
cons <- cons |>
  add_constr_status_quo(strength = 2, current_plan = map$cd_2010)
```

**Calibration:** Strength = 2 is standard. Higher values reduce plan diversity significantly.

---

## SMC Algorithm Parameters

These are not legal constraints but calibration knobs that affect simulation quality:

```r
plans <- redist_smc(
  map,
  nsims = 10000,          # per chain; × 5 chains = 50k total; thin to 5k
  runs = 5,
  ncores = 4,
  constraints = cons,
  adapt_k_thresh = 0.985, # standard; rarely changed
  seq_alpha = 0.5,        # standard; try 0.9–0.95 for very complex states
  est_label_mult = 1,     # standard
  pop_temper = 0,         # increase by 0.01 if acceptance rate drops in final splits
  ms_moves_multiplier = 35,   # increase (up to 65+) for large/complex states
  total_ms_steps = 3,     # range 2–12; increase for hard convergence cases
  mh_accept_per_smc = ceiling(ndists / 3) + 10   # scales with district count
)
```

**Thinning:** Generate ≥10k plans per run × 5 runs, then thin to 5,000 final plans. Always thin *before* computing final summary statistics.

**Convergence targets:**
- R-hat ≤ 1.05 for all tracked statistics
- Effective sample % > 80% in final splits
- Log weight SD well below 3.0
- Acceptance rates consistently > 1%

**When convergence fails (R-hat > 1.05):**
1. Increase `pop_temper` by 0.01
2. Increase `nsims`
3. Increase `total_ms_steps` or `mh_accept_per_smc`
4. Weaken the most restrictive constraint
5. As last resort: increase `seq_alpha` to 0.9–0.95
