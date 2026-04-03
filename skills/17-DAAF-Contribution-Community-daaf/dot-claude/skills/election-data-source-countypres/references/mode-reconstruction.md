# Mode Reconstruction: County Presidential Returns 2020+

## Why Naive `mode=="TOTAL"` Drops ~1,000 Counties

Starting in 2020, the MEDSL county presidential returns dataset reports voting method
breakdowns (ABSENTEE, ELECTION DAY, EARLY, etc.) alongside or *instead of* aggregate
TOTAL rows. **A simple `df.filter(pl.col("mode") == "TOTAL")` silently drops all
counties in states that report only breakdowns.** In 2020, this affects 10 states
(~1,000 counties). In 2024, the affected states differ but the pattern persists.

The correct approach is **3-pattern mode reconstruction**, which handles all county-year
combinations and produces a uniform dataset where every row has `mode == "TOTAL"`.

## Three Reconstruction Patterns

| Pattern | Condition | Action | Example States (2020) |
|---------|-----------|--------|-----------------------|
| **1: TOTAL present** | County-year has `mode == "TOTAL"` rows | Keep TOTAL rows, drop breakdown rows | Most states (41 in 2020) |
| **2: Only breakdowns** | County-year has NO `mode == "TOTAL"` rows | Sum `candidatevotes` across modes per (county_fips, year, candidate, party) | AR, AZ, GA, IA, KY, MD, NC, OK, SC, VA (2020) |
| **3: Empty-string = totals** | County-year has `mode == ""` representing aggregate totals | Reclassify `""` as `"TOTAL"`, then apply Pattern 1 | ID, RI, TX, UT, WA, WI, WV, WY (2024) |

## States Without TOTAL Rows

These states report ONLY mode breakdowns — no TOTAL rows exist. A naive `mode=="TOTAL"`
filter drops ALL their counties.

**2020 (10 states):** AR, AZ, GA, IA, KY, MD, NC, OK, SC, VA

**2024 (varies):** The specific states differ from 2020. Check the data for the version
you are using. In version 20260211, several states shifted between patterns.

**Note:** This list applies to dataset version 20260211. Verify for future MEDSL releases,
as states may gain or lose TOTAL rows between data versions.

## Empty-String Mode Detection Logic

Some 2024 state-years have `mode == ""` rows. These can represent EITHER aggregate
totals (Pattern 3) or additional breakdowns (treated as Pattern 2). **You must classify
per state-year** — do not assume all empty-string rows have the same meaning.

**Heuristic:** For each state-year with empty-string mode rows, count how many empty-string
rows exist per (county_name, candidate, party) group:

- **Exactly 1 per group** = totals (Pattern 3). Reclassify as `"TOTAL"`.
- **More than 1 per group** = breakdowns (Pattern 2). Leave as-is for aggregation.

**Critical lesson (NC 2024):** North Carolina 2024 has 4 empty-string rows per
county-candidate-party group — these are breakdowns, not totals. Blindly reclassifying
them as TOTAL creates ~202 duplicate DEM/REP groups and corrupts vote counts.

**2024 classification (version 20260211):**
- **Pattern 3 (totals):** ID, RI, TX, UT, WA, WI, WV, WY
- **Pattern 2 (breakdowns):** NC

## Complete Polars Code Pattern

Extracted and generalized from the battle-tested cleaning script (`01_clean-countypres_d.py`,
Steps B.1-B.6). This pattern survived 4 revision cycles and QA validation.

```python
import polars as pl

# --- Constants ---
# Columns for grouping during breakdown aggregation
GROUP_COLS = ["county_fips", "year", "state_po", "state", "county_name", "candidate", "party"]

# Minimal uniqueness key for post-concat deduplication.
# IMPORTANT: Do NOT use GROUP_COLS for dedup — text fields (state, county_name)
# may differ between the df_total and df_reconstructed paths (e.g., due to FIPS
# reassignment or normalization differences). Use only the numeric/categorical key.
DEDUP_KEY = ["county_fips", "year", "candidate", "party"]

# Metadata columns to carry forward with .first() during aggregation
CARRY_COLS = ["office", "version"]

# --- B.1: Classify empty-string mode states ---
empty_mode_rows = df.filter(pl.col("mode") == "")
empty_mode_states = (
    empty_mode_rows
    .select("state_po", "year")
    .unique()
    .sort("year", "state_po")
)

breakdown_state_years = []
total_state_years = []

for row in empty_mode_states.iter_rows(named=True):
    st, yr = row["state_po"], row["year"]
    state_empty = empty_mode_rows.filter(
        (pl.col("state_po") == st) & (pl.col("year") == yr)
    )
    rows_per_group = (
        state_empty
        .group_by("county_name", "candidate", "party")
        .len()
    )
    max_rows = rows_per_group["len"].max()
    if max_rows > 1:
        breakdown_state_years.append((st, yr))
    else:
        total_state_years.append((st, yr))

# --- B.2: Reclassify empty-string totals as "TOTAL" (Pattern 3) ---
if total_state_years:
    total_filter = pl.lit(False)
    for st, yr in total_state_years:
        total_filter = total_filter | (
            (pl.col("state_po") == st) & (pl.col("year") == yr) & (pl.col("mode") == "")
        )
    df = df.with_columns(
        pl.when(total_filter)
        .then(pl.lit("TOTAL"))
        .otherwise(pl.col("mode"))
        .alias("mode")
    )

# --- B.3: Breakdown empty-string rows left as-is for aggregation in B.5 ---

# --- B.4: Identify county-years that HAVE a TOTAL row ---
# Use (state_po, county_name, year) as composite key because county_fips
# may be null for some rows (e.g., RI 2020).
has_total = (
    df.filter(pl.col("mode") == "TOTAL")
    .select("state_po", "county_name", "year")
    .unique()
)

# --- B.5a: Counties WITH TOTAL -> keep only TOTAL rows (Pattern 1) ---
df_total = (
    df.join(has_total, on=["state_po", "county_name", "year"], how="semi")
    .filter(pl.col("mode") == "TOTAL")
)

# --- B.5b: Counties WITHOUT TOTAL -> aggregate breakdowns (Pattern 2) ---
df_no_total = df.join(has_total, on=["state_po", "county_name", "year"], how="anti")

if df_no_total.shape[0] > 0:
    agg_exprs = [
        pl.col("candidatevotes").sum(),
        pl.col("totalvotes").first(),
        pl.lit("TOTAL").alias("mode"),
    ]
    for col in CARRY_COLS:
        if col in df_no_total.columns:
            agg_exprs.append(pl.col(col).first())

    df_reconstructed = df_no_total.group_by(GROUP_COLS).agg(agg_exprs)
    df = pl.concat([df_total, df_reconstructed], how="diagonal_relaxed")
else:
    df = df_total

# --- B.6: Post-concat deduplication using DEDUP_KEY (NOT GROUP_COLS) ---
# This handles residual duplicates from cross-path text discrepancies.
dup_groups = df.group_by(DEDUP_KEY).len().filter(pl.col("len") > 1)
if dup_groups.shape[0] > 0:
    agg_exprs_dedup = [
        pl.col("candidatevotes").sum(),
        pl.col("totalvotes").first(),
        pl.col("mode").first(),
        pl.col("state_po").first(),
        pl.col("state").first(),
        pl.col("county_name").first(),
    ]
    for col in CARRY_COLS:
        if col in df.columns:
            agg_exprs_dedup.append(pl.col(col).first())
    df = df.group_by(DEDUP_KEY).agg(agg_exprs_dedup)
```

## Row Count Estimation

Raw row counts vary dramatically by year due to mode breakdowns. After reconstruction,
all rows are TOTAL-mode and counts stabilize to ~1 row per county per candidate.

| Year | Raw Rows (approx) | After Reconstruction | Approx Counties |
|------|--------------------|---------------------|-----------------|
| 2000 | ~12,600 | ~12,600 (all TOTAL) | ~3,100 |
| 2004-2016 | ~9,500 each | ~9,500 (all TOTAL) | ~3,150 |
| 2020 | ~22,000 | ~10,000 | ~3,150 |
| 2024 | ~21,500 | ~11,300 | ~3,150 |

**Note:** Post-reconstruction row counts depend on the number of candidates per county.
The county count (~3,150) is the more stable metric for validation.

## Validation Checklist

After mode reconstruction, verify all of these:

```python
# 1. All rows should be mode == "TOTAL"
assert df.filter(pl.col("mode") != "TOTAL").shape[0] == 0, "Non-TOTAL rows remain"

# 2. No duplicate (county_fips, year, candidate, party) groups
dup_check = df.group_by(DEDUP_KEY).len().filter(pl.col("len") > 1)
assert dup_check.shape[0] == 0, f"{dup_check.shape[0]} duplicate groups remain"

# 3. County coverage: at least 3,100 unique county_fips per year
for yr in df["year"].unique().to_list():
    n_counties = df.filter(pl.col("year") == yr)["county_fips"].n_unique()
    assert n_counties >= 3100, f"Only {n_counties} counties in {yr} (expected >= 3,100)"

# 4. State coverage: 51 unique states per year (50 + DC)
for yr in df["year"].unique().to_list():
    n_states = df.filter(pl.col("year") == yr)["state_po"].n_unique()
    assert n_states >= 50, f"Only {n_states} states in {yr} (expected 51)"
```
