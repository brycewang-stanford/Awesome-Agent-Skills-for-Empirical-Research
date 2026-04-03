#!/usr/bin/env python3
"""
DATA INGEST: Quality Profile + Relationship Analysis
Data file: /daaf/data/ingest/election-returns/countypres_2000-2024.tab
Purpose: Identify data quality issues, relationships, potential keys, anomalies
"""
import polars as pl

# --- Config ---
DATA_PATH = "/daaf/data/ingest/election-returns/countypres_2000-2024.tab"
CODED_VALUE_CANDIDATES = [-1, -2, -3, -9, -99, -999, 999, 9999]

# --- Load ---
df = pl.read_csv(DATA_PATH, separator='\t')

# === DATA QUALITY PROFILE ===
print("=" * 60)
print("=== DATA QUALITY PROFILE ===")
print("=" * 60)

# --- Completeness ---
print("\n--- Completeness Summary ---")
for col in df.columns:
    null_rate = df[col].null_count() / df.height * 100
    print(f"  {col}: {df[col].null_count()} nulls ({null_rate:.2f}%)")

# --- Coded Missing Values (numeric columns) ---
print("\n--- Coded Missing Values (Numeric Columns) ---")
for col in df.columns:
    if df[col].dtype in [pl.Int64, pl.Float64, pl.Int32, pl.Float32]:
        for code in CODED_VALUE_CANDIDATES:
            count = df.filter(pl.col(col) == code).height
            if count > 0:
                print(f"  {col}: {code} appears {count} times ({count/df.height*100:.2f}%)")

# --- Coded Missing Values (string columns) ---
print("\n--- Coded Missing Values (String Columns) ---")
for col in df.columns:
    if df[col].dtype == pl.Utf8:
        for code in ["NA", "N/A", "", " ", ".", "-", "MISSING", "UNKNOWN", "null", "NULL", "None"]:
            count = df.filter(pl.col(col) == code).height
            if count > 0:
                print(f"  {col}: '{code}' appears {count} times ({count/df.height*100:.2f}%)")

# === RELATIONSHIP ANALYSIS ===
print("\n" + "=" * 60)
print("=== RELATIONSHIP ANALYSIS ===")
print("=" * 60)

# --- Potential Key Columns ---
print("\n--- Potential Key Columns ---")
for col in df.columns:
    uniqueness = df[col].n_unique() / df.height
    print(f"  {col}: {df[col].n_unique()} unique / {df.height} rows = {uniqueness*100:.2f}% unique")

# --- Composite Key Analysis ---
print("\n--- Composite Key Analysis ---")
# Try year + county_fips + party + mode as potential composite key
key_cols_list = [
    ["year", "county_fips", "party", "candidate", "mode"],
    ["year", "county_fips", "party", "mode"],
    ["year", "county_fips", "candidate", "mode"],
    ["year", "state_po", "county_name", "party", "candidate", "mode"],
]
for key_cols in key_cols_list:
    try:
        n_combos = df.select(key_cols).unique().height
        is_key = n_combos == df.height
        print(f"  {key_cols}: {n_combos:,} unique combos vs {df.height:,} rows -> {'UNIQUE KEY' if is_key else 'NOT UNIQUE'}")
        if not is_key:
            # Find duplicates
            dups = df.group_by(key_cols).agg(pl.len().alias("count")).filter(pl.col("count") > 1)
            print(f"    Duplicates: {dups.height} groups with duplicates")
            if dups.height > 0 and dups.height <= 10:
                print(dups)
    except Exception as e:
        print(f"  {key_cols}: ERROR - {e}")

# --- Hierarchical Relationships ---
print("\n--- Hierarchical Relationships ---")
# state -> state_po mapping
state_po_map = df.select("state", "state_po").unique()
print(f"  state -> state_po: {state_po_map.height} unique pairs (should be ~51 for 50 states + DC)")
# Check 1-to-1 mapping
state_count = df.select("state").n_unique()
state_po_count = df.select("state_po").n_unique()
print(f"    Unique states: {state_count}, Unique state_po: {state_po_count}")
if state_count == state_po_count and state_count == state_po_map.height:
    print(f"    CONFIRMED: 1-to-1 mapping between state and state_po")

# state -> county mapping
state_county = df.select("state_po", "county_fips").unique()
print(f"\n  state_po -> county_fips: {state_county.height} unique pairs")
# Check if county_fips is unique within state
counties_per_state = df.group_by("state_po").agg(pl.col("county_fips").n_unique().alias("n_counties"))
print(f"  Counties per state (min/max): {counties_per_state['n_counties'].min()} - {counties_per_state['n_counties'].max()}")

# --- county_fips analysis (PRIORITY COLUMN) ---
print("\n--- PRIORITY: county_fips Analysis ---")
# Check FIPS format
fips_non_null = df.filter(pl.col("county_fips").is_not_null())
fips_null = df.filter(pl.col("county_fips").is_null())
print(f"  Non-null: {fips_non_null.height:,}, Null: {fips_null.height:,}")

if fips_null.height > 0:
    print(f"\n  States with null county_fips:")
    null_fips_states = fips_null.group_by("state_po", "year").agg(pl.len().alias("count"))
    null_fips_by_state = null_fips_states.group_by("state_po").agg(
        pl.col("year").sort().alias("years"),
        pl.col("count").sum().alias("total_rows")
    ).sort("state_po")
    for row in null_fips_by_state.iter_rows():
        st, yrs, cnt = row
        print(f"    {st}: {cnt} rows across years {yrs}")

# FIPS code range check
fips_vals = fips_non_null.select("county_fips").unique().sort("county_fips")
print(f"\n  FIPS range: {fips_vals['county_fips'].min()} - {fips_vals['county_fips'].max()}")
print(f"  Unique FIPS codes: {fips_vals.height}")

# Check FIPS codes that don't follow standard pattern (state_fips * 1000 + county)
# Standard county FIPS is 5 digits: 2-digit state + 3-digit county
odd_fips = fips_non_null.filter(
    (pl.col("county_fips") < 1000) | (pl.col("county_fips") > 72999)
).select("state_po", "county_fips", "county_name").unique().sort("county_fips")
if odd_fips.height > 0:
    print(f"\n  FIPS codes outside standard 1001-72999 range ({odd_fips.height} unique):")
    for row in odd_fips.iter_rows():
        print(f"    {row}")

# --- mode analysis (PRIORITY COLUMN) ---
print("\n--- PRIORITY: mode Column Analysis ---")
mode_by_year = df.group_by("year", "mode").agg(pl.len().alias("count")).sort("year", "mode")
print("  Mode values by year:")
for row in mode_by_year.iter_rows():
    yr, mode, cnt = row
    print(f"    {yr} | {mode}: {cnt:,} rows")

# Check 2020 mode breakdown specifically
print("\n  2020 mode detail:")
df_2020 = df.filter(pl.col("year") == 2020)
modes_2020 = df_2020.group_by("mode").agg(
    pl.len().alias("rows"),
    pl.col("candidatevotes").sum().alias("total_candidate_votes"),
    pl.col("state_po").n_unique().alias("n_states")
).sort("rows", descending=True)
print(modes_2020)

# --- version column analysis ---
print("\n--- version Column Analysis ---")
version_vals = df.select("version").unique().sort("version")
print(f"  Unique version values: {version_vals.height}")
for row in version_vals.iter_rows():
    print(f"    {row[0]}")

# --- Cross-column consistency ---
print("\n--- Cross-Column Consistency ---")
# totalvotes should be consistent within county-year-mode
print("  Checking totalvotes consistency within county-year-mode groups:")
consistency_check = df.group_by("year", "county_fips", "mode").agg(
    pl.col("totalvotes").n_unique().alias("n_totalvotes_values")
).filter(pl.col("n_totalvotes_values") > 1)
if consistency_check.height > 0:
    print(f"    INCONSISTENCY: {consistency_check.height} groups have multiple totalvotes values")
    print(consistency_check.head(10))
else:
    print(f"    CONSISTENT: totalvotes is unique within each county-year-mode group")

# candidatevotes vs totalvotes
print("\n  Checking candidatevotes vs totalvotes:")
# For TOTAL mode, sum of candidatevotes by county-year should approximate totalvotes
vote_check = df.filter(pl.col("mode") == "TOTAL").group_by("year", "county_fips").agg(
    pl.col("candidatevotes").sum().alias("sum_candidate_votes"),
    pl.col("totalvotes").first().alias("total_votes")
).with_columns(
    (pl.col("sum_candidate_votes") - pl.col("total_votes")).alias("diff"),
)
# Cases where candidate votes exceed total votes
over_total = vote_check.filter(pl.col("sum_candidate_votes") > pl.col("total_votes"))
print(f"    County-years where sum(candidatevotes) > totalvotes (TOTAL mode): {over_total.height}")
if over_total.height > 0 and over_total.height <= 20:
    print(over_total.sort("diff", descending=True).head(10))

# Cases where candidate votes are significantly less (>5% gap)
under_total = vote_check.filter(
    (pl.col("total_votes") > 0) &
    ((pl.col("total_votes") - pl.col("sum_candidate_votes")) / pl.col("total_votes") > 0.05)
)
print(f"    County-years where sum(candidatevotes) < 95% of totalvotes (TOTAL mode): {under_total.height}")
if under_total.height > 0 and under_total.height <= 20:
    print(under_total.sort("diff").head(10))

# --- Alaska 2004 anomaly check ---
print("\n--- Alaska 2004 Anomaly Check ---")
ak_2004 = df.filter((pl.col("state_po") == "AK") & (pl.col("year") == 2004))
print(f"  Alaska 2004 rows: {ak_2004.height}")
print(f"  county_fips values for AK 2004:")
ak_fips = ak_2004.select("county_fips", "county_name").unique().sort("county_fips")
for row in ak_fips.iter_rows():
    print(f"    {row}")
# Compare with other Alaska years
for yr in [2000, 2008, 2012, 2016, 2020, 2024]:
    ak_yr = df.filter((pl.col("state_po") == "AK") & (pl.col("year") == yr))
    if ak_yr.height > 0:
        fips_count = ak_yr.select("county_fips").n_unique()
        county_count = ak_yr.select("county_name").n_unique()
        print(f"  AK {yr}: {ak_yr.height} rows, {fips_count} unique FIPS, {county_count} unique county names")

# --- Null candidatevotes check ---
print("\n--- Null/Zero candidatevotes ---")
null_cv = df.filter(pl.col("candidatevotes").is_null())
print(f"  Null candidatevotes: {null_cv.height}")
if null_cv.height > 0:
    print("  Sample of null candidatevotes rows:")
    print(null_cv.head(10))

zero_cv = df.filter(pl.col("candidatevotes") == 0)
print(f"  Zero candidatevotes: {zero_cv.height} ({zero_cv.height/df.height*100:.2f}%)")
if zero_cv.height > 0:
    zero_by_party = zero_cv.group_by("party").agg(pl.len().alias("count")).sort("count", descending=True)
    print("  Zero candidatevotes by party:")
    for row in zero_by_party.iter_rows():
        print(f"    {row[0]}: {row[1]}")

# --- Duplicate detection ---
print("\n--- Exact Row Duplicate Check ---")
n_dupes = df.height - df.unique().height
print(f"  Exact duplicate rows: {n_dupes}")


# =============================================================================
# EXECUTION LOG
# =============================================================================
#
# Executed: 2026-02-23 00:41:31
# Command: python /daaf/data/ingest/election-returns/scripts/03_quality_profile.py
# Duration: s
# Exit code: 0
#
# --- STDOUT ---
# ============================================================
# === DATA QUALITY PROFILE ===
# ============================================================
# 
# --- Completeness Summary ---
#   state: 0 nulls (0.00%)
#   county_name: 0 nulls (0.00%)
#   year: 0 nulls (0.00%)
#   state_po: 0 nulls (0.00%)
#   county_fips: 52 nulls (0.06%)
#   office: 0 nulls (0.00%)
#   candidate: 0 nulls (0.00%)
#   party: 0 nulls (0.00%)
#   candidatevotes: 37 nulls (0.04%)
#   totalvotes: 0 nulls (0.00%)
#   version: 0 nulls (0.00%)
#   mode: 0 nulls (0.00%)
# 
# --- Coded Missing Values (Numeric Columns) ---
#   candidatevotes: 999 appears 10 times (0.01%)
#   candidatevotes: 9999 appears 1 times (0.00%)
#   totalvotes: 999 appears 14 times (0.01%)
# 
# --- Coded Missing Values (String Columns) ---
#   party: '' appears 501 times (0.53%)
#   mode: '' appears 2795 times (2.97%)
# 
# ============================================================
# === RELATIONSHIP ANALYSIS ===
# ============================================================
# 
# --- Potential Key Columns ---
#   state: 51 unique / 94151 rows = 0.05% unique
#   county_name: 1921 unique / 94151 rows = 2.04% unique
#   year: 7 unique / 94151 rows = 0.01% unique
#   state_po: 51 unique / 94151 rows = 0.05% unique
#   county_fips: 3158 unique / 94151 rows = 3.35% unique
#   office: 1 unique / 94151 rows = 0.00% unique
#   candidate: 19 unique / 94151 rows = 0.02% unique
#   party: 6 unique / 94151 rows = 0.01% unique
#   candidatevotes: 22108 unique / 94151 rows = 23.48% unique
#   totalvotes: 16846 unique / 94151 rows = 17.89% unique
#   version: 1 unique / 94151 rows = 0.00% unique
#   mode: 20 unique / 94151 rows = 0.02% unique
# 
# --- Composite Key Analysis ---
#   ['year', 'county_fips', 'party', 'candidate', 'mode']: 93,038 unique combos vs 94,151 rows -> NOT UNIQUE
#     Duplicates: 497 groups with duplicates
#   ['year', 'county_fips', 'party', 'mode']: 92,287 unique combos vs 94,151 rows -> NOT UNIQUE
#     Duplicates: 883 groups with duplicates
#   ['year', 'county_fips', 'candidate', 'mode']: 90,218 unique combos vs 94,151 rows -> NOT UNIQUE
#     Duplicates: 3317 groups with duplicates
#   ['year', 'state_po', 'county_name', 'party', 'candidate', 'mode']: 93,010 unique combos vs 94,151 rows -> NOT UNIQUE
#     Duplicates: 541 groups with duplicates
# 
# --- Hierarchical Relationships ---
#   state -> state_po: 51 unique pairs (should be ~51 for 50 states + DC)
#     Unique states: 51, Unique state_po: 51
#     CONFIRMED: 1-to-1 mapping between state and state_po
# 
#   state_po -> county_fips: 3160 unique pairs
#   Counties per state (min/max): 1 - 254
# 
# --- PRIORITY: county_fips Analysis ---
#   Non-null: 94,099, Null: 52
# 
#   States with null county_fips:
#     CT: 16 rows across years [2000, 2004, 2008, 2012, 2016]
#     ME: 16 rows across years [2000, 2004, 2008, 2012, 2016]
#     RI: 20 rows across years [2000, 2004, 2008, 2012, 2016, 2020]
# 
#   FIPS range: 1001 - 2938000
#   Unique FIPS codes: 3157
# 
#   FIPS codes outside standard 1001-72999 range (1 unique):
#     ('MO', 2938000, 'KANSAS CITY')
# 
# --- PRIORITY: mode Column Analysis ---
#   Mode values by year:
#     2000 | TOTAL: 12,628 rows
#     2004 | TOTAL: 9,474 rows
#     2008 | TOTAL: 9,474 rows
#     2012 | TOTAL: 9,474 rows
#     2016 | TOTAL: 9,474 rows
#     2020 | 2ND ABSENTEE: 120 rows
#     2020 | ABSENTEE: 1,995 rows
#     2020 | ABSENTEE BY MAIL: 1,038 rows
#     2020 | ADVANCED VOTING: 477 rows
#     2020 | EARLY: 453 rows
#     2020 | EARLY VOTE: 450 rows
#     2020 | EARLY VOTING: 120 rows
#     2020 | ELECTION DAY: 3,737 rows
#     2020 | FAILSAFE: 230 rows
#     2020 | FAILSAFE PROVISIONAL: 230 rows
#     2020 | IN-PERSON ABSENTEE: 230 rows
#     2020 | MAIL: 145 rows
#     2020 | ONE STOP: 500 rows
#     2020 | PROV: 477 rows
#     2020 | PROVISIONAL: 1,832 rows
#     2020 | TOTAL: 10,059 rows
#     2024 | : 2,795 rows
#     2024 | ABSENTEE: 1,518 rows
#     2024 | EARLY: 132 rows
#     2024 | EARLY VOTING: 2,150 rows
#     2024 | ELECTION DAY: 1,872 rows
#     2024 | FAILSAFE PROVISIONAL: 322 rows
#     2024 | LATE EARLY VOTING: 18 rows
#     2024 | MAIL-IN: 268 rows
#     2024 | PROVISIONAL: 1,094 rows
#     2024 | TOTAL: 11,329 rows
#     2024 | VOTE CENTER: 36 rows
# 
#   2020 mode detail:
# shape: (16, 4)
# ┌──────────────────────┬───────┬───────────────────────┬──────────┐
# │ mode                 ┆ rows  ┆ total_candidate_votes ┆ n_states │
# │ ---                  ┆ ---   ┆ ---                   ┆ ---      │
# │ str                  ┆ u32   ┆ i64                   ┆ u32      │
# ╞══════════════════════╪═══════╪═══════════════════════╪══════════╡
# │ TOTAL                ┆ 10059 ┆ 127403956             ┆ 41       │
# │ ELECTION DAY         ┆ 3737  ┆ 9724934               ┆ 11       │
# │ ABSENTEE             ┆ 1995  ┆ 6122368               ┆ 5        │
# │ PROVISIONAL          ┆ 1832  ┆ 188119                ┆ 6        │
# │ ABSENTEE BY MAIL     ┆ 1038  ┆ 1714541               ┆ 3        │
# │ …                    ┆ …     ┆ …                     ┆ …        │
# │ FAILSAFE PROVISIONAL ┆ 230   ┆ 3238                  ┆ 1        │
# │ IN-PERSON ABSENTEE   ┆ 230   ┆ 886812                ┆ 1        │
# │ MAIL                 ┆ 145   ┆ 495048                ┆ 1        │
# │ 2ND ABSENTEE         ┆ 120   ┆ 618801                ┆ 1        │
# │ EARLY VOTING         ┆ 120   ┆ 983985                ┆ 1        │
# └──────────────────────┴───────┴───────────────────────┴──────────┘
# 
# --- version Column Analysis ---
#   Unique version values: 1
#     20260211
# 
# --- Cross-Column Consistency ---
#   Checking totalvotes consistency within county-year-mode groups:
#     INCONSISTENCY: 2 groups have multiple totalvotes values
# shape: (2, 4)
# ┌──────┬─────────────┬───────┬─────────────────────┐
# │ year ┆ county_fips ┆ mode  ┆ n_totalvotes_values │
# │ ---  ┆ ---         ┆ ---   ┆ ---                 │
# │ i64  ┆ i64         ┆ str   ┆ u32                 │
# ╞══════╪═════════════╪═══════╪═════════════════════╡
# │ 2016 ┆ null        ┆ TOTAL ┆ 3                   │
# │ 2012 ┆ null        ┆ TOTAL ┆ 3                   │
# └──────┴─────────────┴───────┴─────────────────────┘
# 
#   Checking candidatevotes vs totalvotes:
#     County-years where sum(candidatevotes) > totalvotes (TOTAL mode): 49
#     County-years where sum(candidatevotes) < 95% of totalvotes (TOTAL mode): 0
# 
# --- Alaska 2004 Anomaly Check ---
#   Alaska 2004 rows: 123
#   county_fips values for AK 2004:
#     (2001, 'DISTRICT 1')
#     (2002, 'DISTRICT 2')
#     (2003, 'DISTRICT 3')
#     (2004, 'DISTRICT 4')
#     (2005, 'DISTRICT 5')
#     (2006, 'DISTRICT 6')
#     (2007, 'DISTRICT 7')
#     (2008, 'DISTRICT 8')
#     (2009, 'DISTRICT 9')
#     (2010, 'DISTRICT 10')
#     (2011, 'DISTRICT 11')
#     (2012, 'DISTRICT 12')
#     (2013, 'DISTRICT 13')
#     (2014, 'DISTRICT 14')
#     (2015, 'DISTRICT 15')
#     (2016, 'DISTRICT 16')
#     (2017, 'DISTRICT 17')
#     (2018, 'DISTRICT 18')
#     (2019, 'DISTRICT 19')
#     (2020, 'DISTRICT 20')
#     (2021, 'DISTRICT 21')
#     (2022, 'DISTRICT 22')
#     (2023, 'DISTRICT 23')
#     (2024, 'DISTRICT 24')
#     (2025, 'DISTRICT 25')
#     (2026, 'DISTRICT 26')
#     (2027, 'DISTRICT 27')
#     (2028, 'DISTRICT 28')
#     (2029, 'DISTRICT 29')
#     (2030, 'DISTRICT 30')
#     (2031, 'DISTRICT 31')
#     (2032, 'DISTRICT 32')
#     (2033, 'DISTRICT 33')
#     (2034, 'DISTRICT 34')
#     (2035, 'DISTRICT 35')
#     (2036, 'DISTRICT 36')
#     (2037, 'DISTRICT 37')
#     (2038, 'DISTRICT 38')
#     (2039, 'DISTRICT 39')
#     (2040, 'DISTRICT 40')
#     (2099, 'DISTRICT 99')
#   AK 2000: 164 rows, 41 unique FIPS, 41 unique county names
#   AK 2008: 123 rows, 41 unique FIPS, 41 unique county names
#   AK 2012: 123 rows, 41 unique FIPS, 41 unique county names
#   AK 2016: 123 rows, 41 unique FIPS, 41 unique county names
#   AK 2020: 205 rows, 41 unique FIPS, 41 unique county names
#   AK 2024: 164 rows, 41 unique FIPS, 41 unique county names
# 
# --- Null/Zero candidatevotes ---
#   Null candidatevotes: 37
#   Sample of null candidatevotes rows:
# shape: (10, 12)
# ┌────────────┬─────────────┬──────┬──────────┬───┬────────────┬────────────┬──────────┬────────────┐
# │ state      ┆ county_name ┆ year ┆ state_po ┆ … ┆ candidatev ┆ totalvotes ┆ version  ┆ mode       │
# │ ---        ┆ ---         ┆ ---  ┆ ---      ┆   ┆ otes       ┆ ---        ┆ ---      ┆ ---        │
# │ str        ┆ str         ┆ i64  ┆ str      ┆   ┆ ---        ┆ i64        ┆ i64      ┆ str        │
# │            ┆             ┆      ┆          ┆   ┆ i64        ┆            ┆          ┆            │
# ╞════════════╪═════════════╪══════╪══════════╪═══╪════════════╪════════════╪══════════╪════════════╡
# │ NEW MEXICO ┆ CATRON      ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 2354       ┆ 20260211 ┆ ABSENTEE   │
# │ NEW MEXICO ┆ CATRON      ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 2354       ┆ 20260211 ┆ EARLY      │
# │ NEW MEXICO ┆ CIBOLA      ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 8977       ┆ 20260211 ┆ EARLY      │
# │ NEW MEXICO ┆ CIBOLA      ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 8977       ┆ 20260211 ┆ ABSENTEE   │
# │ NEW MEXICO ┆ COLFAX      ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 5813       ┆ 20260211 ┆ ABSENTEE   │
# │ NEW MEXICO ┆ DE BACA     ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 867        ┆ 20260211 ┆ EARLY      │
# │ NEW MEXICO ┆ DE BACA     ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 867        ┆ 20260211 ┆ ELECTION   │
# │            ┆             ┆      ┆          ┆   ┆            ┆            ┆          ┆ DAY        │
# │ NEW MEXICO ┆ DE BACA     ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 867        ┆ 20260211 ┆ TOTAL      │
# │ NEW MEXICO ┆ DE BACA     ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 867        ┆ 20260211 ┆ ABSENTEE   │
# │ NEW MEXICO ┆ EDDY        ┆ 2024 ┆ NM       ┆ … ┆ null       ┆ 23472      ┆ 20260211 ┆ ABSENTEE   │
# └────────────┴─────────────┴──────┴──────────┴───┴────────────┴────────────┴──────────┴────────────┘
#   Zero candidatevotes: 3908 (4.15%)
#   Zero candidatevotes by party:
#     OTHER: 1304
#     LIBERTARIAN: 1020
#     GREEN: 805
#     DEMOCRAT: 410
#     REPUBLICAN: 368
#     : 1
# 
# --- Exact Row Duplicate Check ---
#   Exact duplicate rows: 83
#
# --- STDERR ---
# (captured in STDOUT above via 2>&1)
#
# =============================================================================
