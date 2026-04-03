# Worked Examples

Real analysis files from the ALARM fifty-states project, with annotations explaining each decision. Use these as ground-truth templates — this is actual passing code, not reconstructed examples.

Six analyses are shown. The first three cover simulation complexity tiers; the last three cover adjacency graph patterns:

**Simulation tiers:**
- **ME_cd_2020** — minimal: 2 districts, county constraint, compactness tweak
- **GA_cd_2020** — moderate: 17 districts, pseudocounties, BVAP hinge constraints
- **IL_cd_2020** — complex: 17 districts, pseudocounties (two large counties), BVAP + HVAP hinge constraints

**Adjacency patterns:**
- **ID_cd_2020** — highway-connectivity: `seam_rip()` removes county borders not crossed by a road
- **WA_cd_2020** — water barriers + ferries: `st_difference(water)` + `remove_edge()` + ferry/bridge/manual reconnects; also `seq_alpha = 0.9` and multi-target non-white VAP hinge
- **MD_cd_2010** — 2010 cycle + bay isolation: `subtract_edge()`/`add_edge()` for Chesapeake Bay pseudo-units; `year = 2010` data loading; GEOID `.x`/`.y` dedup fix
- **HI_cd_2020** — multi-island + partial SMC: block-level data aggregated to tracts; island connections for visualization only; `n_steps = 1` partial simulation; manual plan matrix construction with `redist_plans()`

---

## Tier 1 — Simple State: ME_cd_2020

Maine: 2 congressional districts, 2020 cycle. Small state, no VRA, standard county constraint.

### 01_prep_ME_cd_2020.R

```r
###############################################################################
# Download and prepare data for `ME_cd_2020` analysis
# © ALARM Project, December 2021
###############################################################################

suppressMessages({
    library(dplyr)
    library(readr)
    library(sf)
    library(redist)
    library(geomander)
    library(cli)
    library(here)
    devtools::load_all() # load utilities
})

# Download necessary files for analysis -----
cli_process_start("Downloading files for {.pkg ME_cd_2020}")

path_data <- download_redistricting_file("ME", "data-raw/ME")

cli_process_done()

# Compile raw data into a final shapefile for analysis -----
shp_path <- "data-out/ME_2020/shp_vtd.rds"
perim_path <- "data-out/ME_2020/perim.rds"

if (!file.exists(here(shp_path))) {
    cli_process_start("Preparing {.strong ME} shapefile")

    # NOTE: Maine uses census tracts (not VTDs) because 2020 VTDs don't cover
    # most of the state's geography. This is state-specific — most states use
    # join_vtd_shapefile() + read_csv() instead of the tract-level approach below.
    years <- c(2016, 2018, 2020)
    state <- "ME"
    el_l <- lapply(years, function(year) {
        get_vest(state, year)
    })

    block <- censable::build_dec("block", state, year = 2010)

    m_l <- lapply(el_l, function(x) {
        geo_match(from = block, to = x, method = "area")
    })

    el_l <- lapply(seq_along(el_l), function(x) {
        vest <- el_l[[x]]
        elec_at_2010 <- tibble(GEOID = block$GEOID)
        elections <- names(vest)[str_detect(names(vest), str_c("_", years[x] - 2000)) &
            (str_detect(names(vest), "_rep_") | str_detect(names(vest), "_dem_"))]
        for (election in elections) {
            elec_at_2010 <- elec_at_2010 %>%
                mutate(!!election := estimate_down(
                    value = vest[[election]], wts = block[["vap"]],
                    group = m_l[[x]]
                ))
        }
        elec_at_2010
    })
    elec_at_2010 <- purrr::reduce(el_l, left_join, by = "GEOID")
    vest_cw <- cvap::vest_crosswalk(state)
    rt <- PL94171::pl_retally(elec_at_2010, crosswalk = vest_cw)
    names(rt)[4:13] <- names(elec_at_2010)[2:11]

    tract <- rt %>%
        censable::breakdown_geoid() %>%
        censable::construct_geoid("tract") %>%
        select(GEOID, contains(paste(years - 2000))) %>%
        group_by(GEOID) %>%
        summarize(across(.fns = sum)) %>%
        mutate(
            arv_16 = rowMeans(select(., contains("_16_rep_")), na.rm = TRUE),
            adv_16 = rowMeans(select(., contains("_16_dem_")), na.rm = TRUE),
            arv_18 = rowMeans(select(., contains("_18_rep_")), na.rm = TRUE),
            adv_18 = rowMeans(select(., contains("_18_dem_")), na.rm = TRUE),
            arv_20 = rowMeans(select(., contains("_20_rep_")), na.rm = TRUE),
            adv_20 = rowMeans(select(., contains("_20_dem_")), na.rm = TRUE),
            nrv = rowMeans(select(., contains("_rep_")), na.rm = TRUE),
            ndv = rowMeans(select(., contains("_dem_")), na.rm = TRUE)
        )

    me_shp <- censable::build_dec("tract", state) %>%
        left_join(tract, by = "GEOID")
    me_shp <- me_shp %>%
        censable::breakdown_geoid() %>%
        mutate(state = censable::match_fips(state[1]))

    # NOTE: EPSG$ME is the standard state-specific projection from the project's
    # EPSG lookup table. Always use EPSG[[ST]] — never hardcode a projection number.
    me_shp <- me_shp %>%
        st_transform(EPSG$ME) %>%
        rename_with(function(x) gsub("[0-9.]", "", x), starts_with("GEOID"))

    me_shp <- me_shp %>% filter(!st_is_empty(geometry))

    # add municipalities (BAF = block assignment file)
    d_muni <- PL94171::pl_get_baf("ME")$INCPLACE_CDP %>%
        censable::breakdown_geoid("BLOCKID") %>%
        censable::construct_geoid("tract") %>%
        group_by(GEOID) %>%
        summarize(muni = Mode(PLACEFP))
    d_cd <- PL94171::pl_get_baf("ME")$CD %>%
        censable::breakdown_geoid("BLOCKID") %>%
        censable::construct_geoid("tract") %>%
        group_by(GEOID) %>%
        summarize(cd_2010 = Mode(DISTRICT))
    me_shp <- left_join(me_shp, d_muni, by = "GEOID") %>%
        left_join(d_cd, by = "GEOID") %>%
        mutate(county_muni = if_else(is.na(muni), county, str_c(county, muni))) %>%
        relocate(muni, county_muni, cd_2010, .after = county)

    # load the enacted plan from a public URL
    dists <- read_sf("https://redistrict2020.org/files/ME-2021-09-16/US_Congressional_Districts_Unified_Proposal.geojson")
    me_shp <- me_shp %>% mutate(
        cd_2020 = geo_match(from = me_shp, to = dists, method = "area"),
        .after = cd_2010
    )

    # Create perimeters for compactness metrics
    redistmetrics::prep_perims(shp = me_shp,
        perim_path = here(perim_path)) %>%
        invisible()

    # Simplify geometry for performance
    if (requireNamespace("rmapshaper", quietly = TRUE)) {
        me_shp <- rmapshaper::ms_simplify(me_shp, keep = 0.05,
            keep_shapes = TRUE) %>%
            suppressWarnings()
    }

    # Build adjacency graph
    me_shp$adj <- redist.adjacency(me_shp)

    # NOTE: suggest_component_connection() finds disconnected island tracts and
    # connects them to the nearest precinct in the same district. Always run this
    # for coastal states. Document which tracts were connected in the doc file.
    adds <- suggest_component_connection(me_shp, me_shp$adj, me_shp$cd_2020)
    me_shp$adj <- me_shp$adj %>% add_edge(adds$x, adds$y)

    me_shp <- me_shp %>%
        fix_geo_assignment(muni)

    me_shp$state <- "ME"

    write_rds(me_shp, here(shp_path), compress = "gz")
    cli_process_done()
} else {
    me_shp <- read_rds(here(shp_path))
    cli_alert_success("Loaded {.strong ME} shapefile")
}
```

### 02_setup_ME_cd_2020.R

```r
###############################################################################
# Set up redistricting simulation for `ME_cd_2020`
# © ALARM Project, December 2021
###############################################################################
cli_process_start("Creating {.cls redist_map} object for {.pkg ME_cd_2020}")

# NOTE: pop_tol = 0.005 is the standard 0.5% tolerance for congressional plans.
# No pseudocounties needed — Maine has no county larger than the district target.
map <- redist_map(me_shp, pop_tol = 0.005,
    existing_plan = cd_2020, adj = me_shp$adj)

# Add an analysis name attribute
attr(map, "analysis_name") <- "ME_2020"

# Output the redist_map object. Do not edit this path.
write_rds(map, "data-out/ME_2020/ME_cd_2020_map.rds", compress = "xz")
cli_process_done()
```

### 03_sim_ME_cd_2020.R

```r
###############################################################################
# Simulate plans for `ME_cd_2020`
# © ALARM Project, December 2021
###############################################################################

# Run the simulation -----
cli_process_start("Running simulations for {.pkg ME_cd_2020}")

set.seed(2020)

# NOTE: No explicit redist_constr() block — only county constraint (via `counties`)
# and a weakened compactness weight. This is the minimal case: no VRA, no
# pseudocounties, no pop_temper, no special constraints.
# compactness = 0.8: weakened from default 1.0 because Maine is a small state
# with few tracts, and full compactness weight reduces plan diversity too much.
plans <- redist_smc(
    map,
    nsims = 1250, runs = 4L,
    counties = county, compactness = 0.8
)

plans <- match_numbers(plans, "cd_2020")

cli_process_done()
cli_process_start("Saving {.cls redist_plans} object")

# Output the redist_plans object. Do not edit this path.
write_rds(plans, here("data-out/ME_2020/ME_cd_2020_plans.rds"), compress = "xz")
cli_process_done()

# Compute summary statistics -----
cli_process_start("Computing summary statistics for {.pkg ME_cd_2020}")

plans <- add_summary_stats(plans, map)

# Output the summary statistics. Do not edit this path.
save_summary_stats(plans, "data-out/ME_2020/ME_cd_2020_stats.csv")

cli_process_done()
```

### doc_ME_cd_2020.md

```markdown
# 2020 Maine Congressional Districts

## Redistricting requirements
In Maine, following Title 21-A, Chapter 15, Section 1206, districts must:

1. be contiguous (1)
2. have equal populations (1)
3. be geographically compact (1)
4. preserve county and municipality boundaries as much as possible (1)

### Algorithmic Constraints
We enforce a maximum population deviation of 0.5%.
We apply the standard algorithmic county constraint.

## Data Sources
Data for Maine comes from the Voting and Election Science Team for 2016, 2018,
and 2020. It is retabulated to 2020 Census tracts, as 2020 Census VTDs do not
cover the majority of Maine's geography.

## Pre-processing Notes
Islands tracts were connected to the nearest tract within the same district.

## Simulation Notes
We sample 5,000 districting plans for Maine across 4 independent runs of the
SMC algorithm. We use the standard county constraint. We weaken the compactness
parameter to 0.8 due to the relatively small state size and total number of
tracts to encourage more diversity in the sample.
```

**Key decisions in ME:**
- Tracts instead of VTDs (state-specific; document it)
- No pseudocounties (no county exceeds district target)
- `compactness = 0.8` — weakened for small states; document why
- `nsims = 1250 × 4 runs = 5000` final plans (no thinning needed at this scale)
- No `redist_constr()` block at all — county passed directly as `counties =` argument

---

## Tier 2 — Moderate: GA_cd_2020

Georgia: 17 congressional districts, 2020 cycle. Pseudocounties + BVAP constraints for VRA compliance.

### 02_setup_GA_cd_2020.R

```r
###############################################################################
# Set up redistricting simulation for `GA_cd_2020`
# © ALARM Project, October 2021
###############################################################################
cli_process_start("Creating {.cls redist_map} object for {.pkg GA_cd_2020}")

map <- redist_map(ga_shp, pop_tol = 0.005,
    existing_plan = cd_2020, adj = ga_shp$adj)

attr(map, "analysis_name") <- "GA_2020"

# NOTE: pick_county_muni() with default settings (no pop_muni argument) uses
# the district target automatically. Counties larger than the target become
# per-municipality pseudocounties; smaller counties remain whole.
map <- map %>%
    mutate(pseudo_county = pick_county_muni(map, counties = county, munis = muni))

# Output the redist_map object. Do not edit this path.
write_rds(map, "data-out/GA_2020/GA_cd_2020_map.rds", compress = "xz")
cli_process_done()
```

### 03_sim_GA_cd_2020.R

```r
###############################################################################
# Simulate plans for `GA_cd_2020`
# © ALARM Project, October 2021
###############################################################################

# Run the simulation -----
cli_process_start("Running simulations for {.pkg GA_cd_2020}")

# NOTE: Three BVAP constraints:
#   1. Hinge strength 20, target 0.52: penalize districts below 52% BVAP
#      (encourages at least one majority-Black district)
#   2. Hinge strength -20, target 0.45: penalize districts between 45–52% BVAP
#      (discourages near-majority districts that don't cross threshold)
#   3. Inv_hinge strength 10, target 0.62: penalize districts above 62% BVAP
#      (prevents packing Black voters into a single super-majority district)
constr <- redist_constr(map) %>%
    add_constr_grp_hinge(20, vap_black, vap, 0.52) %>%
    add_constr_grp_hinge(-20, vap_black, vap, 0.45) %>%
    add_constr_grp_inv_hinge(10, vap_black, vap, 0.62)

set.seed(2020)
# NOTE: counties = pseudo_county (NOT county) — the pseudocounty column from 02_setup.
# pop_temper = 0.01 added because acceptance rates dropped in final splits
# with 17 districts. Generate 10k × 2 runs = 20k, thin to 5k.
plans <- redist_smc(map, nsims = 1e4, runs = 2L, counties = county, constraints = constr,
                    pop_temper = 0.01) %>%
    group_by(chain) %>%
    filter(as.integer(draw) < min(as.integer(draw)) + 2500) %>% # thin to 5k
    ungroup()
plans <- match_numbers(plans, "cd_2020")

cli_process_done()
cli_process_start("Saving {.cls redist_plans} object")

write_rds(plans, here("data-out/GA_2020/GA_cd_2020_plans.rds"), compress = "xz")
cli_process_done()

# Compute summary statistics -----
cli_process_start("Computing summary statistics for {.pkg GA_cd_2020}")

plans <- add_summary_stats(plans, map)

# NOTE: Always call summary(plans) before thinning to get pre-thin R-hat values.
# The summary() call here is on the thinned sample — for R-hat assessment the
# full pre-thin sample should be used (done in the loop before filtering).
summary(plans)

save_summary_stats(plans, "data-out/GA_2020/GA_cd_2020_stats.csv")

cli_process_done()

# Extra validation plots for custom constraints -----
# NOTE: All diagnostic/plotting code must be wrapped in if (interactive()) {}
# so it doesn't run when the script is sourced programmatically.
if (interactive()) {
    library(ggplot2)
    library(patchwork)

    validate_analysis(plans, map)

    # VRA performance plot — required in PR when VRA constraints are used
    redist.plot.distr_qtys(plans, vap_black / total_vap,
                           color_thresh = NULL,
                           color = ifelse(subset_sampled(plans)$ndv > subset_sampled(plans)$nrv,
                                          '#3D77BB', '#B25D4C'),
                           size = 0.5, alpha = 0.5) +
        scale_y_continuous('Percent Black by VAP') +
        labs(title = 'Approximate Performance') +
        scale_color_manual(values = c(cd_2020_prop = 'black')) +
        ggredist::theme_r21()
    ggsave("figs/performance.pdf", height = 7, width = 7)
}
```

---

## Tier 3 — Complex: IL_cd_2020

Illinois: 17 congressional districts, 2020 cycle. Two large counties (Cook + DuPage) split into pseudocounties; BVAP + HVAP hinge constraints for two separate VRA districts.

### 02_setup_IL_cd_2020.R

```r
###############################################################################
# Set up redistricting simulation for `IL_cd_2020`
# © ALARM Project, January 2022
###############################################################################
cli_process_start("Creating {.cls redist_map} object for {.pkg IL_cd_2020}")

map <- redist_map(il_shp, pop_tol = 0.005,
    existing_plan = cd_2020, adj = il_shp$adj)

# NOTE: pop_muni = get_target(map) is explicit here (vs. GA which used the default).
# Both are equivalent — the default for pop_muni is get_target(map). Being explicit
# makes the intent clearer for a large state with multiple counties above the target.
map <- map %>%
    mutate(pseudo_county = pick_county_muni(map, counties = county, munis = muni,
        pop_muni = get_target(map)))

attr(map, "analysis_name") <- "IL_2020"

write_rds(map, "data-out/IL_2020/IL_cd_2020_map.rds", compress = "xz")
cli_process_done()
```

### 03_sim_IL_cd_2020.R

```r
###############################################################################
# Simulate plans for `IL_cd_2020`
# © ALARM Project, January 2022
###############################################################################

# Run the simulation -----
cli_process_start("Running simulations for {.pkg IL_cd_2020}")

# NOTE: Five constraints total — two groups (BVAP + HVAP), each needing a
# majority district. Pattern for each group:
#   - Positive hinge at 0.55: encourage ≥55% (above 50% to ensure majority)
#   - Negative hinge at 0.44-0.45: penalize near-majority districts
#   - Inv_hinge at 0.60: anti-packing ceiling (BVAP only here)
# Using vap_black and vap_hisp (not CVAP) — appropriate when non-citizen
# population is not unusually large.
constr <- redist_constr(map) %>%
    add_constr_grp_hinge(20, vap_black, vap, tgts_group = 0.55) %>%
    add_constr_grp_hinge(-20, vap_black, vap, tgts_group = 0.45) %>%
    add_constr_grp_inv_hinge(10, vap_black, vap, tgts_group = 0.60) %>%
    add_constr_grp_hinge(20, vap_hisp, vap, tgts_group = 0.55) %>%
    add_constr_grp_hinge(-20, vap_hisp, vap, tgts_group = 0.44)

set.seed(2020)
# NOTE: nsims = 3e4 × 2 runs = 60k total; thin to 5k (2500 per chain).
# counties = pseudo_county (the column built in 02_setup).
# pop_temper = 0.01 needed for IL's complex constraints + large district count.
plans <- redist_smc(map, nsims = 3e4, runs = 2L, counties = pseudo_county,
    pop_temper = 0.01) %>%
    group_by(chain) %>%
    filter(as.integer(draw) < min(as.integer(draw)) + 2500) %>% # thin to 5k
    ungroup()
plans <- match_numbers(plans, "cd_2020")

cli_process_done()
cli_process_start("Saving {.cls redist_plans} object")

write_rds(plans, here("data-out/IL_2020/IL_cd_2020_plans.rds"), compress = "xz")
cli_process_done()

# Compute summary statistics -----
cli_process_start("Computing summary statistics for {.pkg IL_cd_2020}")

plans <- add_summary_stats(plans, map)

summary(plans)

save_summary_stats(plans, "data-out/IL_2020/IL_cd_2020_stats.csv")

cli_process_done()

# Extra validation plots for custom constraints -----
if (interactive()) {
    library(ggplot2)
    library(patchwork)

    validate_analysis(plans, map)

    # BVAP performance plot
    redist.plot.distr_qtys(plans, vap_black/total_vap,
        color_thresh = NULL,
        color = ifelse(subset_sampled(plans)$ndv > subset_sampled(plans)$nrv, "#3D77BB", "#B25D4C"),
        size = 0.5, alpha = 0.5) +
        scale_y_continuous("Percent Black by VAP") +
        labs(title = "Approximate Performance") +
        scale_color_manual(values = c(cd_2020_prop = "black")) +
        ggredist::theme_r21()
    ggsave("figs/performance.pdf", height = 7, width = 7)
}
```

### doc_IL_cd_2020.md

```markdown
# 2020 Illinois Congressional Districts

## Redistricting requirements
In Illinois, districts must, under Ill. Const. Art. IV, § 3:

1. be contiguous
2. have equal populations
3. be geographically compact

### Algorithmic Constraints
We enforce a maximum population deviation of 0.5%.

## Data Sources
Data for Illinois comes from the ALARM Project's 2020 Redistricting Data Files.

## Pre-processing Notes
No manual pre-processing decisions were necessary.

## Simulation Notes
We sample 60,000 districting plans for Illinois across two independent runs
of the SMC algorithm, and then thin the sample down to 5,000 plans.

To balance county and municipality splits, we create pseudocounties for use
in the county constraint, which leads to fewer municipality splits than using
a county constraint. These are counties outside of Cook County and DuPage
County. Within Cook County and DuPage County, each municipality is its own
pseudocounty as well. Cook County and DuPage County were chosen since they are
necessarily split by congressional districts.

To comply with the federal VRA and to respect communities of interest, we add
hinge Gibbs constraints of strength 20 targeting one majority-Black district
(IL-01) and one majority-Hispanic district (IL-04), focusing on districts with
relatively higher proportions of Black and Hispanic voters. We also apply a
hinge Gibbs constraint of strength 10 to discourage packing of Black voters.
```

**Key decisions in IL:**
- `nsims = 30000 × 2 = 60k` total; thinned to 5k via `filter(draw < min(draw) + 2500)`
- `counties = pseudo_county` — critical: must match what's in `02_setup`
- `pop_temper = 0.01` — needed for complex constraints + large state
- Five constraints: BVAP hinge + negative hinge + inv_hinge; HVAP hinge + negative hinge
- No HVAP anti-packing inv_hinge — only applied to BVAP here (document why if deviating)
- VRA constraints go in "Simulation Notes", NOT in the "Redistricting requirements" section

---

## Pattern Summary

### How thinning works

```r
# Generate 10k per run × 2 runs = 20k total
plans <- redist_smc(map, nsims = 1e4, runs = 2L, ...) %>%
    group_by(chain) %>%
    filter(as.integer(draw) < min(as.integer(draw)) + 2500) %>% # keep first 2500 per chain
    ungroup()
# Result: 2500 × 2 = 5000 plans
```

Common patterns:
- `nsims = 1250, runs = 4`: small states (ME: 5k total, no thin needed)
- `nsims = 1e4, runs = 2, thin to 2500/chain`: moderate states (GA: 20k → 5k)
- `nsims = 3e4, runs = 2, thin to 2500/chain`: complex states (IL: 60k → 5k)

### Standard file skeleton (most states)

**01_prep:** `suppressMessages({...}) → download_redistricting_file() → read_csv() %>% join_vtd_shapefile() → st_transform(EPSG$ST) → make_from_baf() for muni+cd → add enacted plan → prep_perims() → ms_simplify() → redist.adjacency() → [adjacency edits if needed] → fix_geo_assignment() → write_rds()`

**02_setup:** `redist_map(shp, pop_tol, existing_plan, adj) → [mutate pseudo_county if needed] → attr(map, "analysis_name") → write_rds()`

**03_sim:** `[redist_constr() block if VRA/special] → set.seed() → redist_smc(...) → [thin if needed] → match_numbers() → write_rds() → add_summary_stats() → summary() → save_summary_stats() → if (interactive()) { validate_analysis(); VRA plots; ggsave() }`

### Key column names to use consistently

| Variable | Where set | Used in |
|---|---|---|
| `county` | BAF in 01_prep | `pick_county_muni()` in 02_setup; `counties =` in 03_sim (when no pseudocounties) |
| `muni` | BAF in 01_prep | `pick_county_muni()` in 02_setup |
| `pseudo_county` | `mutate()` in 02_setup | `counties = pseudo_county` in 03_sim |
| `cd_2020` | Enacted plan in 01_prep | `existing_plan =` in 02_setup; `match_numbers()` in 03_sim |
| `vap_black`, `vap_hisp`, `vap` | From ALARM data | `add_constr_grp_hinge()` in 03_sim |

---

## Adjacency Pattern 1 — Highway Connectivity: ID_cd_2020

Idaho: 2 congressional districts. State law (72-1506(9)) requires counties be connected by highways. The adjacency graph removes county-border edges that lack a road crossing.

### 01_prep_ID_cd_2020.R (adjacency section only)

```r
# Standard setup (read_csv → join_vtd_shapefile → st_transform → make_from_baf) ...

# create adjacency graph
id_shp$adj <- redist.adjacency(id_shp)

# NOTE: Idaho law requires county connections to be along highways.
# Strategy:
#   1. Build county-level adjacency to find all county-border pairs
#   2. Check which borders are crossed by a primary/secondary road
#   3. Remove border edges where no road crosses (seam_rip removes all VTD-level
#      edges on the seam between two given counties)

# Build county polygons and their adjacency
cty <- id_shp %>%
    group_by(county) %>%
    summarize(geometry = sf::st_as_sfc(geos::geos_unary_union(geos::geos_make_collection(geometry))))

cty_adj <- adjacency(cty) %>% lapply(\(x) x + 1)

# All county-border pairs
cty_pair <- purrr::map_dfr(seq_along(cty_adj), \(x){
    tibble(x = x, y = cty_adj[[x]])
})

# Download road network
roads <- tigris::primary_secondary_roads("ID") %>%
    st_transform(st_crs(id_shp)) %>%
    geos::as_geos_geometry()

# Find which roads intersect which counties; pairs sharing a road are "connected"
ints <- geos::geos_intersects_matrix(geom = roads, tree = cty)
tbl <- purrr::map_dfr(ints, \(x){
    if (length(x) > 1) {
        tidyr::expand_grid(x = x, y = x) %>% filter(x != y)
    } else {
        data.frame()
    }
}) %>% distinct() %>%
    mutate(magic = TRUE)

# Keep only county pairs WITHOUT a road crossing (magic == NA means no road)
cty_pair <- cty_pair %>%
    left_join(tbl, by = c("x", "y")) %>%
    filter(is.na(magic))

cty_pair <- cty_pair %>%
    mutate(x = cty$county[x], y = cty$county[y])

# Remove all VTD-level edges on each disconnected county seam
adj <- id_shp$adj
for (i in seq_len(nrow(cty_pair))) {
    adj <- seam_rip(adj, shp = id_shp,
        admin = "county", seam = c(cty_pair$x[i], cty_pair$y[i])
    )
}

id_shp$adj <- adj
```

### 03_sim_ID_cd_2020.R

```r
set.seed(2020)

# NOTE: After removing highway-less borders, the standard county constraint
# ensures the simulation respects the resulting adjacency. No VRA needed.
plans <- redist_smc(map, nsims = 2500, runs = 2L, counties = county)

plans <- match_numbers(plans, "cd_2020")

# Diagnostic plot: verify adjacency against the road network
if (interactive()) {
    library(ggplot2)
    redist.plot.adj(id_shp, id_shp$adj, plan = redist.sink.plan(id_shp$county)) +
        geom_sf(data = tigris::primary_secondary_roads("ID"), color = "orange") +
        theme_void() +
        guides(fill = "none")
}
```

**Key decisions in ID:**
- `seam_rip(adj, shp, admin = "county", seam = c("County A", "County B"))` removes all VTD-level edges on a county border seam — the right tool when a whole border must be severed
- Road check uses `geos_intersects_matrix` for performance on large road networks
- The diagnostic plot (inside `if (interactive())`) overlays roads on the adjacency graph to visually verify the result — include this in the PR

---

## Adjacency Pattern 2 — Water Barriers + Ferries: WA_cd_2020

Washington: 10 congressional districts. Puget Sound and the Cascades act as geographic barriers. Strategy: disconnect water-separated precincts, then reconnect via roads and ferry routes.

### 01_prep_WA_cd_2020.R (adjacency section only)

```r
# NOTE: Two extra downloads needed: the enacted plan (BAF format) and ferry routes
url <- "https://data.wsdot.wa.gov/geospatial/DOT_TDO/FerryRoutes/FerryRoutes.zip"
path_ferries <- "data-raw/WA/WA_ferries.zip"
download(url, path_ferries)
unzip(here(path_ferries), exdir = here(dirname(path_ferries), "WA_ferries"))

# Standard prep → st_transform → make_from_baf ...

# Load roads, water bodies, and ferry routes
sf::sf_use_s2(FALSE)
wa_shp$geometry <- st_make_valid(wa_shp$geometry)

d_roads <- tigris::primary_secondary_roads("53", 2020) %>%
    st_transform(EPSG$WA)
d_water <- filter(tigris::fips_codes, state == "WA")$county_code %>%
    lapply(function(cty) tigris::area_water("53", cty)) %>%
    do.call(bind_rows, .) %>%
    st_transform(EPSG$WA)
d_ferries <- read_sf(path_ferries) %>%
    st_transform(EPSG$WA) %>%
    st_cast("MULTILINESTRING")

# Step 1: Build adjacency on water-subtracted geometry
# Remove large water bodies from precinct shapes, then compute adjacency.
# This breaks cross-Sound edges automatically.
d_bigwater <- filter(d_water, as.numeric(st_area(d_water)) > 1e7) %>%
    summarize() %>%
    rmapshaper::ms_simplify(keep = 0.05) %>%
    st_snap(wa_shp$geometry, tolerance = 100) %>%
    st_buffer(1.0)
geom_adj <- st_difference(wa_shp, d_bigwater$geometry)
geom_adj <- bind_rows(
    geom_adj,
    st_buffer(filter(wa_shp, !GEOID %in% geom_adj$GEOID), -50)
)
geom_adj <- slice(geom_adj, match(wa_shp$GEOID, geom_adj$GEOID))

adj_nowater <- redist.adjacency(wa_shp)   # full adjacency (needed for road reconnect)
adj_0 <- redist.adjacency(geom_adj)       # water-subtracted adjacency
wa_shp$adj <- adj_0

# Step 2: Disconnect all cross-county edges (since county borders follow
# major geographic features like the Cascade crest and Columbia River)
for (i in seq_along(wa_shp$adj)) {
    cty_i <- wa_shp$county[i]
    adj_i <- wa_shp$adj[[i]] + 1L
    cty_j <- wa_shp$county[adj_i]
    diff_cty <- which(cty_j != cty_i)
    if (length(diff_cty) > 0) {
        wa_shp$adj <- remove_edge(wa_shp$adj, rep(i, length(diff_cty)), adj_i[diff_cty])
    }
}

# Step 3: Reconnect precincts that share a road or ferry crossing
# NOTE: Uses adj_nowater (the full set of touching neighbors) to find candidates;
# only adds back edges that were originally adjacent but got removed in step 2.
geom_roads_ferries <- c(d_roads$geometry, d_ferries$geometry)
rel_roads_ferries <- st_crosses(geom_roads_ferries, wa_shp)
for (i in seq_along(rel_roads_ferries)) {
    rel_i <- rel_roads_ferries[[i]]
    if (length(rel_i) == 1) next
    for (j in rel_i) {
        adj_j <- setdiff(intersect(adj_nowater[[j]] + 1L, rel_i), wa_shp$adj[[j]] + 1L)
        if (length(adj_j) > 0) {
            wa_shp$adj <- add_edge(wa_shp$adj, rep(j, length(adj_j)), adj_j)
        }
    }
}

# Step 4: Manual connections for specific island/ferry precincts not caught above
# (Vashon Island, Bremerton ferry, several small islands)
add_update_edge <- function(vtd1, vtd2) {
    wa_shp$adj <<- add_edge(wa_shp$adj, which(wa_shp$GEOID == vtd1), which(wa_shp$GEOID == vtd2))
}

add_update_edge("53033WV0732", "53033000514")  # Vashon and N Seattle
add_update_edge("53033001818", "53033001817")
add_update_edge("53033WV0734", "53033001150")
add_update_edge("53033WV0733", "53033000853")
add_update_edge("53033WV0933", "53033002416")
add_update_edge("53033WV0930", "53033003014")
add_update_edge("53035000007", "53035000006")  # Bremerton
add_update_edge("53045000114", "53045000113")  # Harstine Island
add_update_edge("53053026350", "53053026342")  # Fox, McNeil, and Ketron islands
add_update_edge("53053028575", "53053028542")
add_update_edge("53053028571", "53053028574")
add_update_edge("53073000101", "53073000102")  # Point Roberts
```

### 03_sim_WA_cd_2020.R

```r
# NOTE: Non-white VAP constraint with multiple targets in a single hinge call.
# c(0.52, 0.35, 0.25) means: penalize plans without a district at ≥52%, ≥35%, ≥25%
# non-white VAP — targeting one majority-minority and two influence districts.
# The negative hinge at c(0.35, 0.25) discourages near-threshold districts.
constr <- redist_constr(map) %>%
    add_constr_grp_hinge(10.0, vap - vap_white, vap, c(0.52, 0.35, 0.25)) %>%
    add_constr_grp_hinge(-8.0, vap - vap_white, vap, c(0.35, 0.25))

set.seed(2020)

# NOTE: seq_alpha = 0.9 (default 0.5) — use when convergence is slow for complex
# states. Higher seq_alpha makes sampling more aggressive per SMC step, trading
# speed for potentially less diversity. Only increase from default when needed.
# pop_temper = 0.02 — higher than usual (typical 0.01) for WA's complex geography.
plans <- redist_smc(map, nsims = 8e3, runs = 2L, counties = pseudo_county,
    constraints = constr, pop_temper = 0.02, seq_alpha = 0.9) %>%
    group_by(chain) %>%
    filter(as.integer(draw) < min(as.integer(draw)) + 2500) %>%
    ungroup()

plans <- match_numbers(plans, map$cd_2020)
```

**Key decisions in WA:**
- Three-step adjacency: water subtraction → county disconnection → road+ferry reconnection
- `adj_nowater` preserved separately — needed as the candidate set for road reconnect step
- `vap - vap_white` as the group_pop: correct when no single minority group dominates
- Multiple targets in one hinge call: `c(0.52, 0.35, 0.25)` targets three thresholds simultaneously
- `seq_alpha = 0.9`: increases SMC aggressiveness; use only when standard 0.5 fails to converge
- `pop_temper = 0.02`: higher than the typical 0.01 floor; document why in `doc_*.md`

---

## Adjacency Pattern 3 — Bay Isolation + 2010 Cycle: MD_cd_2010

Maryland: 8 congressional districts, **2010 cycle**. The Chesapeake Bay creates Bay pseudo-precincts that would falsely connect the Eastern and Western Shores. Strategy: isolate all Bay units, then reconnect each to one same-side neighbor.

### 01_prep_MD_cd_2010.R (key differences from 2020 cycle)

```r
# NOTE: 2010 cycle — add year = 2010 to every data-loading function
path_data <- download_redistricting_file("MD", "data-raw/MD", year = 2010)

# Standard prep with year = 2010 throughout
md_shp <- read_csv(here(path_data), col_types = cols(GEOID10 = "c")) %>%
    join_vtd_shapefile(year = 2010) %>%
    st_transform(EPSG$MD) %>%
    rename_with(function(x) gsub("[0-9.]", "", x), starts_with("GEOID"))

# NOTE: make_from_baf also needs year = 2010
d_muni <- make_from_baf("MD", "INCPLACE_CDP", "VTD", year = 2010) %>%
    mutate(GEOID = paste0(censable::match_fips("MD"), vtd)) %>%
    select(-vtd)
d_cd <- make_from_baf("MD", "CD", "VTD", year = 2010) %>%
    transmute(GEOID = paste0(censable::match_fips("MD"), vtd),
              cd_2000 = as.integer(cd))  # prior cycle column name

# create adjacency graph
md_shp$adj <- redist.adjacency(md_shp)

# NOTE: Bay pseudo-units (GEOID ending in ZZZZZZ) would connect Eastern and
# Western shores. Strategy:
#   1. Remove ALL adjacency edges for each Bay pseudo-unit
#   2. Add back exactly one edge to a same-side neighbor (keeps pseudo-unit
#      in the graph without creating cross-Bay paths)
bay_ids <- c("24037ZZZZZZ", "24009ZZZZZZ", "24041ZZZZZZ")

for (bid in bay_ids) {
    if (!(bid %in% md_shp$GEOID)) next
    i <- match(bid, md_shp$GEOID)

    # Remove all existing neighbors
    nbr_idx <- md_shp$adj[[i]] + 1L
    nbr_geoids <- md_shp$GEOID[nbr_idx]
    for (nid in nbr_geoids) {
        md_shp$adj <- geomander::subtract_edge(
            md_shp$adj, bid, nid, ids = md_shp$GEOID
        )
    }
}

# Reconnect each Bay pseudo-unit to a chosen same-side neighbor;
# also connect one isolated island precinct
connect_pairs <- list(
    c("2403702-001", "2403709-001"),  # island bridge
    c("24041ZZZZZZ", "2404103-003"),  # Bay → mainland (Eastern Shore)
    c("24009ZZZZZZ", "2400902-004"),  # Bay → mainland (Eastern Shore)
    c("24037ZZZZZZ", "2403707-001")   # Bay → mainland (Western Shore)
)

for (p in connect_pairs) {
    u <- match(p[1], md_shp$GEOID)
    v <- match(p[2], md_shp$GEOID)
    if (!is.na(u) && !is.na(v)) {
        md_shp$adj <- geomander::add_edge(md_shp$adj, u, v, zero = TRUE)
    }
}
```

### 02_setup_MD_cd_2010.R

```r
# NOTE: For 2010 cycle, the enacted plan column is cd_2010 (not cd_2020).
# The FIPS prefix may be attached to district numbers — strip it before
# passing to redist_map().
md_shp <- md_shp %>%
    mutate(cd_2010 = as.integer(stringr::str_remove(cd_2010, "^24")))

map <- redist_map(md_shp, pop_tol = 0.005,
                  existing_plan = cd_2010, adj = md_shp$adj)

map <- map %>%
    mutate(pseudo_county = pick_county_muni(map, counties = county, munis = muni,
                                            pop_muni = get_target(map)))

attr(map, "analysis_name") <- "MD_2010"
write_rds(map, "data-out/MD_2010/MD_cd_2010_map.rds", compress = "xz")
```

### 03_sim_MD_cd_2010.R

```r
set.seed(2010)  # NOTE: use the cycle year as the seed for 2010 analyses

plans <- redist_smc(
    map,
    nsims = 2500, runs = 2,
    counties = county  # MD has no county larger than district target; no pseudocounties needed in sim
)

plans <- match_numbers(plans, "cd_2010")

plans <- add_summary_stats(plans, map)

# NOTE: GEOID deduplication — when a left_join in 01_prep creates duplicate GEOID
# columns (GEOID.x, GEOID.y), add_summary_stats produces .x/.y suffixed columns
# in the plans object. Fix before saving:
plans <- plans |>
    select(-ends_with('.y')) |>
    rename_with(.fn = \(x) str_sub(x, end = -3), .cols = ends_with('.x'))

save_summary_stats(plans, "data-out/MD_2010/MD_cd_2010_stats.csv")
```

**Key decisions in MD:**
- `subtract_edge(adj, id1, id2, ids = shp$GEOID)` — removes a single named edge by GEOID; use when you know which specific units to disconnect
- `add_edge(adj, u, v, zero = TRUE)` — `zero = TRUE` means both directions added (bidirectional); always use this unless deliberately one-directional
- Bay pseudo-units (`GEOID` ending in `ZZZZZZ`) must remain in the graph (they have population) but must not bridge the Bay — isolate then reconnect to same-side neighbor
- 2010 cycle: add `year = 2010` to `download_redistricting_file()`, `join_vtd_shapefile()`, and all `make_from_baf()` calls; use `GEOID10` not `GEOID20`; prior-cycle column is `cd_2000`
- GEOID dedup: if `add_summary_stats()` produces `.x`/`.y` columns, strip them in `03_sim` before `save_summary_stats()`

---

---

## Adjacency Pattern 4 — Multi-Island + Partial SMC: HI_cd_2020

Hawaii: 2 congressional districts. The state is an island chain — contiguity across islands is legally allowed but physically meaningless for simulation. The solution is **partial SMC**: simulate only the single Honolulu-based district (CD-1) and assign all other tracts to CD-2 by definition.

**Unique features:** block-level data aggregated to tracts; island chain adjacency added for visualization only; `n_steps = 1` partial simulation; manual plan matrix construction with `redist_plans()`.

### 01_prep_HI_cd_2020.R (key differences)

```r
# NOTE: type = "block" — Hawaii uses block-level data, not VTDs.
# Most states use the default (VTD). Only use block when VTD coverage is inadequate.
path_data <- download_redistricting_file("HI", "data-raw/HI", type = "block")

# Join block data directly to Census block geometry (not join_vtd_shapefile)
hi_shp <- read_csv(here(path_data), col_types = cols(GEOID20 = "c")) %>%
    left_join(y = tigris::blocks("HI", year = 2020), by = "GEOID20") %>%
    st_as_sf() %>%
    st_transform(EPSG$HI) %>%
    rename_with(function(x) gsub("[0-9.]", "", x), starts_with("GEOID"))

# BAF joins use PL94171 block-level (not make_from_baf which is VTD-based)
d_muni <- PL94171::pl_get_baf("HI", "INCPLACE_CDP")[[1]] %>%
    rename(GEOID = BLOCKID, muni = PLACEFP)
d_cd <- PL94171::pl_get_baf("HI", "CD")[[1]] %>%
    transmute(GEOID = BLOCKID, cd_2010 = as.integer(DISTRICT))

hi_shp <- left_join(hi_shp, d_muni, by = "GEOID") %>%
    left_join(d_cd, by = "GEOID") %>%
    mutate(county_muni = if_else(is.na(muni), county, str_c(county, muni))) %>%
    relocate(muni, county_muni, cd_2010, .after = county)

# Enacted plan is a block-level BAF (not a shapefile)
cd_baf <- read_csv(path_enacted, col_names = c("GEOID", "cd_2020"), col_types = c("ci"))

# NOTE: Aggregate blocks to tracts after joining enacted plan.
# Hawaii's law requires preserving tract boundaries (HRS 25-2(b)(4)).
# This also reduces the unit count for computational efficiency.
hi_shp <- hi_shp %>%
    left_join(cd_baf, by = "GEOID") %>%
    mutate(tract = str_sub(GEOID, 1, 11)) %>%
    group_by(tract) %>%
    summarize(
        cd_2010 = Mode(cd_2010),
        cd_2020 = Mode(cd_2020),
        muni = Mode(muni),
        state = unique(state),
        county = unique(county),
        across(where(is.numeric), sum)
    )

# create adjacency graph
hi_shp$adj <- redist.adjacency(hi_shp)

# NOTE: Connect islands in the adjacency graph for visualization and plan validity,
# but this does NOT affect simulation — the partial SMC approach (see 03_sim)
# bypasses the need for cross-island adjacency in the sampling step.
# Connections are by tract index (1-based), manually determined.
islands <- tribble(
    ~v1, ~v2,
    379, 413,
    413, 412,
    412, 411,
    411, 390,
    390, 459,
    459, 461,
    461, 460,
    460, 55
)
hi_shp$adj <- hi_shp$adj %>% add_edge(islands$v1, islands$v2)
```

### 02_setup_HI_cd_2020.R

```r
map <- redist_map(hi_shp, pop_tol = 0.005,
    existing_plan = cd_2020, adj = hi_shp$adj)

# NOTE: Create a sub-map for partial SMC.
# Honolulu County contains both Oahu (CD-1 territory) and an outlying island tract
# (index 379) that connects the chain — exclude it so only contiguous Oahu remains.
# The pop_bounds attribute must be copied from the full map so the partial
# simulation knows the correct target population.
map_honolulu <- map %>%
    slice(-379) %>%
    filter(county == "Honolulu County") %>%
    `attr<-`("pop_bounds", attr(map, "pop_bounds"))

attr(map, "analysis_name") <- "HI_2020"
write_rds(map, "data-out/HI_2020/HI_cd_2020_map.rds", compress = "xz")
```

### 03_sim_HI_cd_2020.R

```r
set.seed(2020)

# NOTE: Partial SMC — simulate only CD-1 (Honolulu).
# n_steps = 1 means: draw exactly ONE district, then stop.
# The constraint uses coalesce(muni, county): if a tract is in a municipality,
# use that; otherwise fall back to the county name. This handles rural tracts
# that aren't assigned to any municipality.
plans_honolulu <- redist_smc(
    map_honolulu,
    nsims = 2500, runs = 2L,
    n_steps = 1,
    counties = coalesce(muni, county)
)

# NOTE: Manually construct the full-state plans matrix.
# - Create an all-zero matrix with nrow = nrow(map) (all tracts), ncol = 5001
#   (5000 plans + 1 for the reference plan slot)
# - Fill Honolulu rows with the partial simulation results
# - Assign everything else (non-Honolulu tracts) to district 2
plans <- matrix(data = 0, nrow = nrow(map), ncol = 5001)
plans[map$tract %in% map_honolulu$tract, ] <- get_plans_matrix(plans_honolulu)
plans[plans == 0] <- 2

# Wrap in redist_plans, pulling weights and diagnostics from the partial run
plans <- redist_plans(
    plans = plans[, -1],   # drop column 1 (the reference slot)
    algorithm = "smc",
    map = map,
    wgt = get_plans_weights(plans_honolulu)[-1],
    diagnostics = attr(plans_honolulu, "diagnostics")
)

# NOTE: add_reference() instead of match_numbers() — because we constructed the
# plan matrix directly, we just add the enacted plan as a labeled reference rather
# than reordering to match it.
plans <- plans %>%
    mutate(chain = rep(1:2, each = 5000), .after = draw) %>%
    add_reference(ref_plan = map$cd_2020, "cd_2020")

write_rds(plans, here("data-out/HI_2020/HI_cd_2020_plans.rds"), compress = "xz")

plans <- add_summary_stats(plans, map)
save_summary_stats(plans, "data-out/HI_2020/HI_cd_2020_stats.csv")
```

**Key decisions in HI:**
- `type = "block"` in `download_redistricting_file()` — only needed when VTD coverage is inadequate; must aggregate to tracts before adjacency
- Island chain connections: add for graph validity/visualization, but partial SMC means they're never traversed during sampling
- `map_honolulu`: sub-map of just Oahu (minus the island-chain connector tract at index 379); `pop_bounds` attribute must be explicitly copied
- `n_steps = 1`: draw exactly one district, stop — the rest is assigned deterministically
- `coalesce(muni, county)`: graceful fallback for tracts with no municipality assignment
- Manual plan matrix: `get_plans_matrix()` + `get_plans_weights()` to extract from partial simulation, then `redist_plans()` to wrap
- `add_reference()` not `match_numbers()` — use when the plan was constructed directly rather than sampled

---

## Adjacency Function Reference

| Function | Purpose | Signature |
|---|---|---|
| `redist.adjacency(shp)` | Build initial adjacency from polygon geometry | returns adj list |
| `add_edge(adj, i, j)` | Add edge(s) between precinct indices | i, j are 1-based integer vectors |
| `geomander::add_edge(adj, i, j, zero=TRUE)` | Add bidirectional edge by index | zero=TRUE for symmetric |
| `remove_edge(adj, i, j)` | Remove edge(s) by index | i, j are 1-based integer vectors |
| `geomander::subtract_edge(adj, id1, id2, ids=shp$GEOID)` | Remove edge by GEOID string | ids= maps names to indices |
| `seam_rip(adj, shp, admin, seam)` | Remove all edges on a county-border seam | seam = c("County A", "County B") |
| `suggest_component_connection(shp, adj, plan)` | Find disconnected islands; suggest edges | returns tibble of x, y pairs |
| `fix_geo_assignment(shp, col)` | Ensure geographic column assignments are consistent | run after adjacency edits |
