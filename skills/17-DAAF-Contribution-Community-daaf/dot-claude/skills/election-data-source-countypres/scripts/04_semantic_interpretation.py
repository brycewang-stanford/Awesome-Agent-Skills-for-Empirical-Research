#!/usr/bin/env python3
"""
DATA INGEST: Semantic Interpretation (PRELIMINARY)
Data file: /daaf/data/ingest/election-returns/countypres_2000-2024.tab
Purpose: Infer likely variable meanings from names, values, and patterns

WARNING: All interpretations are PRELIMINARY HYPOTHESES.
They MUST be reviewed and confirmed by the user.
"""
import polars as pl
import re

# --- Config ---
DATA_PATH = "/daaf/data/ingest/election-returns/countypres_2000-2024.tab"

# --- Load ---
df = pl.read_csv(DATA_PATH, separator='\t')

# --- Semantic Analysis ---
print("=" * 60)
print("=== SEMANTIC INTERPRETATION (PRELIMINARY) ===")
print("WARNING: All interpretations require user confirmation")
print("=" * 60)

# --- Column: year ---
print("\n--- year ---")
year_vals = sorted(df["year"].unique().to_list())
print(f"  Values: {year_vals}")
print(f"  [PRELIMINARY] Election year. Values span {min(year_vals)}-{max(year_vals)}.")
print(f"  [PRELIMINARY] 4-year intervals consistent with presidential election cycle.")
gaps = [year_vals[i+1] - year_vals[i] for i in range(len(year_vals)-1)]
print(f"  Inter-election gaps: {gaps}")

# --- Column: state ---
print("\n--- state ---")
states = sorted(df["state"].unique().to_list())
print(f"  Unique values: {len(states)}")
print(f"  [PRELIMINARY] Full state names, likely uppercase. Includes DC.")
print(f"  Sample: {states[:5]} ... {states[-3:]}")

# --- Column: state_po ---
print("\n--- state_po ---")
st_po = sorted(df["state_po"].unique().to_list())
print(f"  Unique values: {len(st_po)}")
print(f"  [PRELIMINARY] USPS 2-letter state abbreviation codes.")
print(f"  Values: {st_po}")

# --- Column: county_name ---
print("\n--- county_name ---")
n_counties = df["county_name"].n_unique()
null_counties = df["county_name"].null_count()
print(f"  Unique values: {n_counties}, Nulls: {null_counties}")
print(f"  [PRELIMINARY] County name as string. LIKELY not standardized (may have variation).")
# Check for common patterns
samples = df["county_name"].drop_nulls().unique().sort().head(10).to_list()
print(f"  Sample: {samples}")
# Check if "COUNTY" appears in names
county_word = df.filter(pl.col("county_name").str.contains("(?i)county")).height
print(f"  Rows where name contains 'county': {county_word}")

# --- Column: county_fips ---
print("\n--- county_fips ---")
null_fips = df["county_fips"].null_count()
non_null_fips = df.filter(pl.col("county_fips").is_not_null())
print(f"  Nulls: {null_fips} ({null_fips/df.height*100:.2f}%)")
print(f"  [PRELIMINARY] 5-digit FIPS code (stored as integer). Standard format: SSCCC")
print(f"    where SS = 2-digit state FIPS, CCC = 3-digit county FIPS.")
print(f"  [PRELIMINARY] This is the PRIMARY JOIN KEY for linking to census, education,")
print(f"    and other geographic datasets (SAIPE, CCD, ACS, etc.).")
# Verify FIPS structure: should be SSCCC where SS*1000 + CCC
# Check leading digits
if non_null_fips.height > 0:
    fips_vals = non_null_fips["county_fips"].unique().sort()
    print(f"  Range: {fips_vals.min()} - {fips_vals.max()}")
    # Verify state_fips derivation
    check = non_null_fips.with_columns(
        (pl.col("county_fips") // 1000).alias("derived_state_fips")
    ).select("state_po", "derived_state_fips").unique().sort("state_po")
    # Count states with multiple state_fips (would indicate encoding issues)
    multi_fips = check.group_by("state_po").agg(pl.col("derived_state_fips").n_unique().alias("n")).filter(pl.col("n") > 1)
    if multi_fips.height > 0:
        print(f"  WARNING: States with multiple derived state FIPS: {multi_fips}")
    else:
        print(f"  CONFIRMED: county_fips // 1000 gives consistent state FIPS per state_po")

# --- Column: office ---
print("\n--- office ---")
office_vals = df["office"].unique().to_list()
print(f"  Values: {office_vals}")
print(f"  [PRELIMINARY] Constant value 'US PRESIDENT'. Identifies contest type.")
print(f"  This column is invariant in this dataset (single-office data).")

# --- Column: candidate ---
print("\n--- candidate ---")
n_candidates = df["candidate"].n_unique()
null_cands = df["candidate"].null_count()
print(f"  Unique values: {n_candidates}, Nulls: {null_cands}")
print(f"  [PRELIMINARY] Candidate full name. Format appears to be mixed case.")
# Sample by party
for party in ["DEMOCRAT", "REPUBLICAN", "LIBERTARIAN", "GREEN", "OTHER"]:
    cands = df.filter(pl.col("party") == party).select("candidate").unique().sort("candidate")
    print(f"  {party} candidates: {cands['candidate'].to_list()[:10]}")

# --- Column: party ---
print("\n--- party ---")
party_vals = df["party"].unique().sort().to_list()
print(f"  Values: {party_vals}")
print(f"  [PRELIMINARY] Political party affiliation in UPPERCASE.")
print(f"  [PRELIMINARY] Values align with codebook: DEMOCRAT, REPUBLICAN, LIBERTARIAN, GREEN, OTHER")
# Verify all parties present across years
party_by_year = df.group_by("year", "party").agg(pl.len().alias("count")).sort("year", "party")
print("  Party presence by year:")
years = sorted(df["year"].unique().to_list())
for yr in years:
    parties = party_by_year.filter(pl.col("year") == yr)["party"].to_list()
    print(f"    {yr}: {sorted(parties)}")

# --- Column: candidatevotes ---
print("\n--- candidatevotes ---")
null_cv = df["candidatevotes"].null_count()
print(f"  Nulls: {null_cv} ({null_cv/df.height*100:.2f}%)")
print(f"  [PRELIMINARY] Number of votes received by this candidate in this county-year-mode.")
print(f"  [PRELIMINARY] This is the RAW VOTE COUNT, not a share or percentage.")
# Check for negative values (coded missing?)
neg_cv = df.filter(pl.col("candidatevotes") < 0)
print(f"  Negative values: {neg_cv.height}")
# Range
non_null_cv = df.filter(pl.col("candidatevotes").is_not_null())
if non_null_cv.height > 0:
    print(f"  Range: {non_null_cv['candidatevotes'].min()} - {non_null_cv['candidatevotes'].max()}")
    # Top counties by candidatevotes
    top = non_null_cv.sort("candidatevotes", descending=True).head(5).select("year", "state_po", "county_name", "candidate", "candidatevotes")
    print(f"  Top 5 by candidatevotes:")
    print(top)

# --- Column: totalvotes ---
print("\n--- totalvotes ---")
null_tv = df["totalvotes"].null_count()
print(f"  Nulls: {null_tv} ({null_tv/df.height*100:.2f}%)")
print(f"  [PRELIMINARY] Total votes cast in this county-year-mode (all candidates).")
print(f"  [PRELIMINARY] This is the DENOMINATOR for calculating vote shares.")
# Range
non_null_tv = df.filter(pl.col("totalvotes").is_not_null())
if non_null_tv.height > 0:
    print(f"  Range: {non_null_tv['totalvotes'].min()} - {non_null_tv['totalvotes'].max()}")

# --- Column: mode ---
print("\n--- mode ---")
mode_vals = df["mode"].unique().sort().to_list()
print(f"  Values: {mode_vals}")
print(f"  [PRELIMINARY] Ballot counting mode / method of voting.")
print(f"  [PRELIMINARY] 'TOTAL' is the aggregate. Detailed modes (ABSENTEE,")
print(f"    ELECTION DAY, MAIL, PROVISIONAL, etc.) appear mainly in 2020.")
print(f"  [PRELIMINARY] CRITICAL for longitudinal analysis: Pre-2020 uses TOTAL only;")
print(f"    2020 has detailed breakdown. Analysts MUST filter to mode='TOTAL' for")
print(f"    cross-year comparisons or handle aggregation explicitly.")

# Check which years have non-TOTAL modes
non_total = df.filter(pl.col("mode") != "TOTAL")
print(f"\n  Rows with non-TOTAL mode: {non_total.height}")
years_with_modes = non_total.select("year").unique().sort("year")["year"].to_list()
print(f"  Years with non-TOTAL modes: {years_with_modes}")

# For 2020 specifically
if 2020 in years_with_modes:
    states_with_modes_2020 = non_total.filter(pl.col("year") == 2020).select("state_po").unique().sort("state_po")["state_po"].to_list()
    print(f"  States with non-TOTAL modes in 2020 ({len(states_with_modes_2020)}): {states_with_modes_2020}")

    # Check if TOTAL rows still exist for 2020
    total_2020 = df.filter((pl.col("year") == 2020) & (pl.col("mode") == "TOTAL"))
    print(f"  2020 rows with mode=TOTAL: {total_2020.height}")
    total_states = total_2020.select("state_po").unique()["state_po"].to_list()
    print(f"  2020 states with TOTAL mode ({len(total_states)}): {sorted(total_states)}")

# --- Column: version ---
print("\n--- version ---")
ver_vals = df["version"].unique().sort().to_list()
print(f"  Values: {ver_vals}")
print(f"  [PRELIMINARY] Dataset version date in YYYYMMDD integer format.")
print(f"  [PRELIMINARY] Represents when this row's data was finalized/updated.")
print(f"  [PRELIMINARY] Useful for tracking data freshness but NOT for analysis filtering.")

# --- Vote Share Computation Test ---
print("\n" + "=" * 60)
print("=== DERIVED METRIC TEST: Vote Share ===")
print("=" * 60)
# Test computing vote_share = candidatevotes / totalvotes
test = df.filter(
    (pl.col("mode") == "TOTAL") &
    pl.col("candidatevotes").is_not_null() &
    pl.col("totalvotes").is_not_null() &
    (pl.col("totalvotes") > 0)
).with_columns(
    (pl.col("candidatevotes") / pl.col("totalvotes") * 100).alias("vote_share_pct")
)
print(f"  Rows with computable vote share (TOTAL mode): {test.height}")
print(f"  Vote share range: {test['vote_share_pct'].min():.2f}% - {test['vote_share_pct'].max():.2f}%")
print(f"  Mean: {test['vote_share_pct'].mean():.2f}%, Median: {test['vote_share_pct'].median():.2f}%")
# Check for vote shares > 100% (data quality issue)
over_100 = test.filter(pl.col("vote_share_pct") > 100)
print(f"  Vote shares > 100%: {over_100.height}")
if over_100.height > 0:
    print("  Sample of >100% vote shares:")
    print(over_100.select("year", "state_po", "county_name", "candidate", "candidatevotes", "totalvotes", "vote_share_pct").head(10))

print("\n" + "=" * 60)
print("REMINDER: All [PRELIMINARY] interpretations need user confirmation")
print("=" * 60)


# =============================================================================
# EXECUTION LOG
# =============================================================================
#
# Executed: 2026-02-23 00:41:36
# Command: python /daaf/data/ingest/election-returns/scripts/04_semantic_interpretation.py
# Duration: s
# Exit code: 0
#
# --- STDOUT ---
# ============================================================
# === SEMANTIC INTERPRETATION (PRELIMINARY) ===
# WARNING: All interpretations require user confirmation
# ============================================================
# 
# --- year ---
#   Values: [2000, 2004, 2008, 2012, 2016, 2020, 2024]
#   [PRELIMINARY] Election year. Values span 2000-2024.
#   [PRELIMINARY] 4-year intervals consistent with presidential election cycle.
#   Inter-election gaps: [4, 4, 4, 4, 4, 4]
# 
# --- state ---
#   Unique values: 51
#   [PRELIMINARY] Full state names, likely uppercase. Includes DC.
#   Sample: ['ALABAMA', 'ALASKA', 'ARIZONA', 'ARKANSAS', 'CALIFORNIA'] ... ['WEST VIRGINIA', 'WISCONSIN', 'WYOMING']
# 
# --- state_po ---
#   Unique values: 51
#   [PRELIMINARY] USPS 2-letter state abbreviation codes.
#   Values: ['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV', 'WY']
# 
# --- county_name ---
#   Unique values: 1921, Nulls: 0
#   [PRELIMINARY] County name as string. LIKELY not standardized (may have variation).
#   Sample: ['ABBEVILLE', 'ACADIA', 'ACCOMACK', 'ADA', 'ADAIR', 'ADAMS', 'ADDISON', 'AIKEN', 'AITKIN', 'ALACHUA']
#   Rows where name contains 'county': 25
# 
# --- county_fips ---
#   Nulls: 52 (0.06%)
#   [PRELIMINARY] 5-digit FIPS code (stored as integer). Standard format: SSCCC
#     where SS = 2-digit state FIPS, CCC = 3-digit county FIPS.
#   [PRELIMINARY] This is the PRIMARY JOIN KEY for linking to census, education,
#     and other geographic datasets (SAIPE, CCD, ACS, etc.).
#   Range: 1001 - 2938000
#   WARNING: States with multiple derived state FIPS: shape: (1, 2)
# ┌──────────┬─────┐
# │ state_po ┆ n   │
# │ ---      ┆ --- │
# │ str      ┆ u32 │
# ╞══════════╪═════╡
# │ MO       ┆ 3   │
# └──────────┴─────┘
# 
# --- office ---
#   Values: ['US PRESIDENT']
#   [PRELIMINARY] Constant value 'US PRESIDENT'. Identifies contest type.
#   This column is invariant in this dataset (single-office data).
# 
# --- candidate ---
#   Unique values: 19, Nulls: 0
#   [PRELIMINARY] Candidate full name. Format appears to be mixed case.
#   DEMOCRAT candidates: ['AL GORE', 'BARACK OBAMA', 'HILLARY CLINTON', 'JOHN KERRY', 'JOSEPH R BIDEN JR', 'KAMALA D HARRIS']
#   REPUBLICAN candidates: ['DONALD J TRUMP', 'DONALD TRUMP', 'GEORGE W. BUSH', 'JOHN MCCAIN', 'MITT ROMNEY']
#   LIBERTARIAN candidates: ['CHASE OLIVER', 'JO JORGENSEN']
#   GREEN candidates: ['OTHER', 'RALPH NADER']
#   OTHER candidates: ['OTHER', 'OVERVOTES', 'UNDERVOTES']
# 
# --- party ---
#   Values: ['', 'DEMOCRAT', 'GREEN', 'LIBERTARIAN', 'OTHER', 'REPUBLICAN']
#   [PRELIMINARY] Political party affiliation in UPPERCASE.
#   [PRELIMINARY] Values align with codebook: DEMOCRAT, REPUBLICAN, LIBERTARIAN, GREEN, OTHER
#   Party presence by year:
#     2000: ['DEMOCRAT', 'GREEN', 'OTHER', 'REPUBLICAN']
#     2004: ['DEMOCRAT', 'OTHER', 'REPUBLICAN']
#     2008: ['DEMOCRAT', 'OTHER', 'REPUBLICAN']
#     2012: ['DEMOCRAT', 'OTHER', 'REPUBLICAN']
#     2016: ['DEMOCRAT', 'OTHER', 'REPUBLICAN']
#     2020: ['DEMOCRAT', 'GREEN', 'LIBERTARIAN', 'OTHER', 'REPUBLICAN']
#     2024: ['', 'DEMOCRAT', 'LIBERTARIAN', 'OTHER', 'REPUBLICAN']
# 
# --- candidatevotes ---
#   Nulls: 37 (0.04%)
#   [PRELIMINARY] Number of votes received by this candidate in this county-year-mode.
#   [PRELIMINARY] This is the RAW VOTE COUNT, not a share or percentage.
#   Negative values: 0
#   Range: 0 - 3028885
#   Top 5 by candidatevotes:
# shape: (5, 5)
# ┌──────┬──────────┬─────────────┬───────────────────┬────────────────┐
# │ year ┆ state_po ┆ county_name ┆ candidate         ┆ candidatevotes │
# │ ---  ┆ ---      ┆ ---         ┆ ---               ┆ ---            │
# │ i64  ┆ str      ┆ str         ┆ str               ┆ i64            │
# ╞══════╪══════════╪═════════════╪═══════════════════╪════════════════╡
# │ 2020 ┆ CA       ┆ LOS ANGELES ┆ JOSEPH R BIDEN JR ┆ 3028885        │
# │ 2016 ┆ CA       ┆ LOS ANGELES ┆ HILLARY CLINTON   ┆ 2464364        │
# │ 2024 ┆ CA       ┆ LOS ANGELES ┆ KAMALA D HARRIS   ┆ 2417109        │
# │ 2008 ┆ CA       ┆ LOS ANGELES ┆ BARACK OBAMA      ┆ 2295853        │
# │ 2012 ┆ CA       ┆ LOS ANGELES ┆ BARACK OBAMA      ┆ 2216903        │
# └──────┴──────────┴─────────────┴───────────────────┴────────────────┘
# 
# --- totalvotes ---
#   Nulls: 0 (0.00%)
#   [PRELIMINARY] Total votes cast in this county-year-mode (all candidates).
#   [PRELIMINARY] This is the DENOMINATOR for calculating vote shares.
#   Range: 0 - 4264365
# 
# --- mode ---
#   Values: ['', '2ND ABSENTEE', 'ABSENTEE', 'ABSENTEE BY MAIL', 'ADVANCED VOTING', 'EARLY', 'EARLY VOTE', 'EARLY VOTING', 'ELECTION DAY', 'FAILSAFE', 'FAILSAFE PROVISIONAL', 'IN-PERSON ABSENTEE', 'LATE EARLY VOTING', 'MAIL', 'MAIL-IN', 'ONE STOP', 'PROV', 'PROVISIONAL', 'TOTAL', 'VOTE CENTER']
#   [PRELIMINARY] Ballot counting mode / method of voting.
#   [PRELIMINARY] 'TOTAL' is the aggregate. Detailed modes (ABSENTEE,
#     ELECTION DAY, MAIL, PROVISIONAL, etc.) appear mainly in 2020.
#   [PRELIMINARY] CRITICAL for longitudinal analysis: Pre-2020 uses TOTAL only;
#     2020 has detailed breakdown. Analysts MUST filter to mode='TOTAL' for
#     cross-year comparisons or handle aggregation explicitly.
# 
#   Rows with non-TOTAL mode: 22239
#   Years with non-TOTAL modes: [2020, 2024]
#   States with non-TOTAL modes in 2020 (11): ['AR', 'AZ', 'GA', 'IA', 'KY', 'MD', 'NC', 'OK', 'SC', 'UT', 'VA']
#   2020 rows with mode=TOTAL: 10059
#   2020 states with TOTAL mode (41): ['AK', 'AL', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'HI', 'ID', 'IL', 'IN', 'KS', 'LA', 'MA', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OR', 'PA', 'RI', 'SD', 'TN', 'TX', 'UT', 'VT', 'WA', 'WI', 'WV', 'WY']
# 
# --- version ---
#   Values: [20260211]
#   [PRELIMINARY] Dataset version date in YYYYMMDD integer format.
#   [PRELIMINARY] Represents when this row's data was finalized/updated.
#   [PRELIMINARY] Useful for tracking data freshness but NOT for analysis filtering.
# 
# ============================================================
# === DERIVED METRIC TEST: Vote Share ===
# ============================================================
#   Rows with computable vote share (TOTAL mode): 71858
#   Vote share range: 0.00% - 100.00%
#   Mean: 29.09%, Median: 25.94%
#   Vote shares > 100%: 0
# 
# ============================================================
# REMINDER: All [PRELIMINARY] interpretations need user confirmation
# ============================================================
#
# --- STDERR ---
# (captured in STDOUT above via 2>&1)
#
# =============================================================================
