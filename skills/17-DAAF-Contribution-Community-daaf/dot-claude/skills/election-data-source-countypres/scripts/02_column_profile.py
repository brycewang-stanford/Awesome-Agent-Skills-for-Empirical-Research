#!/usr/bin/env python3
"""
DATA INGEST: Column-Level Profile
Data file: /daaf/data/ingest/election-returns/countypres_2000-2024.tab
Purpose: Detailed statistics for each column including distributions and value patterns
"""
import polars as pl

# --- Config ---
DATA_PATH = "/daaf/data/ingest/election-returns/countypres_2000-2024.tab"

# --- Load ---
df = pl.read_csv(DATA_PATH, separator='\t')

# --- Profile Each Column ---
for col in df.columns:
    print(f"\n{'='*60}")
    print(f"=== COLUMN: {col} ===")
    print(f"{'='*60}")
    print(f"Type: {df[col].dtype}")
    print(f"Nulls: {df[col].null_count()} ({df[col].null_count()/df.height*100:.2f}%)")
    print(f"Unique: {df[col].n_unique()}")

    # Type-specific profiling
    if df[col].dtype in [pl.Int64, pl.Float64, pl.Int32, pl.Float32]:
        # Numeric profiling
        stats = df.select(
            pl.col(col).min().alias("min"),
            pl.col(col).max().alias("max"),
            pl.col(col).mean().alias("mean"),
            pl.col(col).median().alias("median"),
            pl.col(col).std().alias("std"),
        ).row(0)
        print(f"Min: {stats[0]}, Max: {stats[1]}")
        print(f"Mean: {stats[2]:.4f}, Median: {stats[3]}, Std: {stats[4]:.4f}")

        # Percentiles
        quantiles = df.select(
            pl.col(col).quantile(0.01).alias("p01"),
            pl.col(col).quantile(0.05).alias("p05"),
            pl.col(col).quantile(0.25).alias("p25"),
            pl.col(col).quantile(0.75).alias("p75"),
            pl.col(col).quantile(0.95).alias("p95"),
            pl.col(col).quantile(0.99).alias("p99"),
        ).row(0)
        print(f"Percentiles: p01={quantiles[0]}, p05={quantiles[1]}, p25={quantiles[2]}, p75={quantiles[3]}, p95={quantiles[4]}, p99={quantiles[5]}")

        # Detect potential coded values (negatives)
        negatives = df.filter(pl.col(col) < 0)[col].unique().to_list()
        if negatives:
            print(f"POTENTIAL CODED VALUES (negative): {negatives}")

        # Check for zero values
        zero_count = df.filter(pl.col(col) == 0).height
        if zero_count > 0:
            print(f"Zero values: {zero_count} ({zero_count/df.height*100:.2f}%)")

    elif df[col].dtype == pl.Utf8:
        # String profiling
        non_null = df.select(pl.col(col).drop_nulls().str.len_chars())
        if non_null.height > 0:
            print(f"Length range: {non_null.min().item()} - {non_null.max().item()}")
            print(f"Mean length: {non_null.mean().item():.1f}")

        # Empty string check
        empty_count = df.filter(pl.col(col) == "").height
        if empty_count > 0:
            print(f"Empty strings: {empty_count} ({empty_count/df.height*100:.2f}%)")

    # Categorical detection and value distribution
    n_unique = df[col].n_unique()
    if n_unique <= 50:
        print(f"\nValue distribution (all {n_unique} values):")
        value_counts = df.group_by(col).agg(pl.len().alias("count")).sort("count", descending=True)
        for row in value_counts.iter_rows():
            val, cnt = row
            pct = cnt / df.height * 100
            print(f"  {val}: {cnt:,} ({pct:.2f}%)")
    elif n_unique <= 200:
        print(f"\nTop 30 values (of {n_unique} unique):")
        value_counts = df.group_by(col).agg(pl.len().alias("count")).sort("count", descending=True)
        for row in value_counts.head(30).iter_rows():
            val, cnt = row
            pct = cnt / df.height * 100
            print(f"  {val}: {cnt:,} ({pct:.2f}%)")
    else:
        # Sample for high-cardinality columns
        print(f"\nSample values (of {n_unique} unique):")
        samples = df[col].drop_nulls().unique().sort().head(15).to_list()
        print(f"  First 15: {samples}")
        samples_last = df[col].drop_nulls().unique().sort().tail(5).to_list()
        print(f"  Last 5: {samples_last}")


# =============================================================================
# EXECUTION LOG
# =============================================================================
#
# Executed: 2026-02-23 00:41:26
# Command: python /daaf/data/ingest/election-returns/scripts/02_column_profile.py
# Duration: s
# Exit code: 0
#
# --- STDOUT ---
# 
# ============================================================
# === COLUMN: state ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 51
# Length range: 4 - 20
# Mean length: 8.2
# 
# Top 30 values (of 51 unique):
#   TEXAS: 7,620 (8.09%)
#   GEORGIA: 5,088 (5.40%)
#   NORTH CAROLINA: 4,900 (5.20%)
#   IOWA: 4,356 (4.63%)
#   VIRGINIA: 4,268 (4.53%)
#   ARKANSAS: 4,200 (4.46%)
#   SOUTH CAROLINA: 3,404 (3.62%)
#   OKLAHOMA: 3,388 (3.60%)
#   MISSOURI: 2,900 (3.08%)
#   KENTUCKY: 2,880 (3.06%)
#   ILLINOIS: 2,544 (2.70%)
#   KANSAS: 2,415 (2.57%)
#   PENNSYLVANIA: 2,345 (2.49%)
#   INDIANA: 2,300 (2.44%)
#   MINNESOTA: 2,175 (2.31%)
#   NEBRASKA: 2,139 (2.27%)
#   OHIO: 2,112 (2.24%)
#   TENNESSEE: 2,090 (2.22%)
#   MICHIGAN: 2,075 (2.20%)
#   MISSISSIPPI: 2,050 (2.18%)
#   LOUISIANA: 2,048 (2.18%)
#   WISCONSIN: 1,872 (1.99%)
#   FLORIDA: 1,675 (1.78%)
#   COLORADO: 1,596 (1.70%)
#   NEW YORK: 1,550 (1.65%)
#   ALABAMA: 1,541 (1.64%)
#   SOUTH DAKOTA: 1,518 (1.61%)
#   CALIFORNIA: 1,458 (1.55%)
#   WEST VIRGINIA: 1,375 (1.46%)
#   MONTANA: 1,288 (1.37%)
# 
# ============================================================
# === COLUMN: county_name ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 1921
# Length range: 3 - 21
# Mean length: 7.1
# 
# Sample values (of 1921 unique):
#   First 15: ['ABBEVILLE', 'ACADIA', 'ACCOMACK', 'ADA', 'ADAIR', 'ADAMS', 'ADDISON', 'AIKEN', 'AITKIN', 'ALACHUA', 'ALAMANCE', 'ALAMEDA', 'ALAMOSA', 'ALBANY', 'ALBEMARLE']
#   Last 5: ['YUBA', 'YUMA', 'ZAPATA', 'ZAVALA', 'ZIEBACH']
# 
# ============================================================
# === COLUMN: year ===
# ============================================================
# Type: Int64
# Nulls: 0 (0.00%)
# Unique: 7
# Min: 2000, Max: 2024
# Mean: 2014.2073, Median: 2016.0, Std: 8.4886
# Percentiles: p01=2000.0, p05=2000.0, p25=2008.0, p75=2020.0, p95=2024.0, p99=2024.0
# 
# Value distribution (all 7 values):
#   2020: 22,093 (23.47%)
#   2024: 21,534 (22.87%)
#   2000: 12,628 (13.41%)
#   2012: 9,474 (10.06%)
#   2004: 9,474 (10.06%)
#   2016: 9,474 (10.06%)
#   2008: 9,474 (10.06%)
# 
# ============================================================
# === COLUMN: state_po ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 51
# Length range: 2 - 2
# Mean length: 2.0
# 
# Top 30 values (of 51 unique):
#   TX: 7,620 (8.09%)
#   GA: 5,088 (5.40%)
#   NC: 4,900 (5.20%)
#   IA: 4,356 (4.63%)
#   VA: 4,268 (4.53%)
#   AR: 4,200 (4.46%)
#   SC: 3,404 (3.62%)
#   OK: 3,388 (3.60%)
#   MO: 2,900 (3.08%)
#   KY: 2,880 (3.06%)
#   IL: 2,544 (2.70%)
#   KS: 2,415 (2.57%)
#   PA: 2,345 (2.49%)
#   IN: 2,300 (2.44%)
#   MN: 2,175 (2.31%)
#   NE: 2,139 (2.27%)
#   OH: 2,112 (2.24%)
#   TN: 2,090 (2.22%)
#   MI: 2,075 (2.20%)
#   MS: 2,050 (2.18%)
#   LA: 2,048 (2.18%)
#   WI: 1,872 (1.99%)
#   FL: 1,675 (1.78%)
#   CO: 1,596 (1.70%)
#   NY: 1,550 (1.65%)
#   AL: 1,541 (1.64%)
#   SD: 1,518 (1.61%)
#   CA: 1,458 (1.55%)
#   WV: 1,375 (1.46%)
#   MT: 1,288 (1.37%)
# 
# ============================================================
# === COLUMN: county_fips ===
# ============================================================
# Type: Int64
# Nulls: 52 (0.06%)
# Unique: 3158
# Min: 1001, Max: 2938000
# Mean: 31027.8807, Median: 30055.0, Std: 46080.6981
# Percentiles: p01=1081.0, p05=5047.0, p25=18169.0, p75=45047.0, p95=53011.0, p99=55117.0
# 
# Sample values (of 3158 unique):
#   First 15: [1001, 1003, 1005, 1007, 1009, 1011, 1013, 1015, 1017, 1019, 1021, 1023, 1025, 1027, 1029]
#   Last 5: [56039, 56041, 56043, 56045, 2938000]
# 
# ============================================================
# === COLUMN: office ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 1
# Length range: 12 - 12
# Mean length: 12.0
# 
# Value distribution (all 1 values):
#   US PRESIDENT: 94,151 (100.00%)
# 
# ============================================================
# === COLUMN: candidate ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 19
# Length range: 5 - 17
# Mean length: 10.5
# 
# Value distribution (all 19 values):
#   OTHER: 27,548 (29.26%)
#   DONALD J TRUMP: 10,303 (10.94%)
#   BARACK OBAMA: 6,316 (6.71%)
#   GEORGE W. BUSH: 6,315 (6.71%)
#   KAMALA D HARRIS: 5,186 (5.51%)
#   JOSEPH R BIDEN JR: 5,117 (5.43%)
#   CHASE OLIVER: 5,084 (5.40%)
#   JO JORGENSEN: 4,955 (5.26%)
#   MITT ROMNEY: 3,158 (3.35%)
#   HILLARY CLINTON: 3,158 (3.35%)
#   JOHN MCCAIN: 3,158 (3.35%)
#   DONALD TRUMP: 3,158 (3.35%)
#   JOHN KERRY: 3,158 (3.35%)
#   RALPH NADER: 3,157 (3.35%)
#   AL GORE: 3,157 (3.35%)
#   TOTAL VOTES CAST: 427 (0.45%)
#   UNDERVOTES: 402 (0.43%)
#   OVERVOTES: 380 (0.40%)
#   SPOILED: 14 (0.01%)
# 
# ============================================================
# === COLUMN: party ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 6
# Length range: 0 - 11
# Mean length: 7.8
# Empty strings: 501 (0.53%)
# 
# Value distribution (all 6 values):
#   REPUBLICAN: 26,092 (27.71%)
#   DEMOCRAT: 26,092 (27.71%)
#   OTHER: 25,392 (26.97%)
#   LIBERTARIAN: 10,039 (10.66%)
#   GREEN: 6,035 (6.41%)
#   : 501 (0.53%)
# 
# ============================================================
# === COLUMN: candidatevotes ===
# ============================================================
# Type: Int64
# Nulls: 37 (0.04%)
# Unique: 22108
# Min: 0, Max: 3028885
# Mean: 10440.4236, Median: 993.5, Std: 45808.5003
# Percentiles: p01=0.0, p05=1.0, p25=79.0, p75=5417.0, p95=43043.0, p99=171668.0
# Zero values: 3908 (4.15%)
# 
# Sample values (of 22108 unique):
#   First 15: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
#   Last 5: [2216903, 2295853, 2417109, 2464364, 3028885]
# 
# ============================================================
# === COLUMN: totalvotes ===
# ============================================================
# Type: Int64
# Nulls: 0 (0.00%)
# Unique: 16846
# Min: 0, Max: 4264365
# Mean: 43391.4607, Median: 11467.0, Std: 122037.4224
# Percentiles: p01=600.0, p05=1519.0, p25=5237.0, p75=30707.0, p95=188456.0, p99=542102.0
# Zero values: 50 (0.05%)
# 
# Sample values (of 16846 unique):
#   First 15: [0, 64, 65, 66, 79, 80, 97, 135, 137, 145, 156, 158, 159, 163, 167]
#   Last 5: [3181067, 3318248, 3434308, 3728427, 4264365]
# 
# ============================================================
# === COLUMN: version ===
# ============================================================
# Type: Int64
# Nulls: 0 (0.00%)
# Unique: 1
# Min: 20260211, Max: 20260211
# Mean: 20260211.0000, Median: 20260211.0, Std: 0.0000
# Percentiles: p01=20260211.0, p05=20260211.0, p25=20260211.0, p75=20260211.0, p95=20260211.0, p99=20260211.0
# 
# Value distribution (all 1 values):
#   20260211: 94,151 (100.00%)
# 
# ============================================================
# === COLUMN: mode ===
# ============================================================
# Type: String
# Nulls: 0 (0.00%)
# Unique: 20
# Length range: 0 - 20
# Mean length: 6.1
# Empty strings: 2795 (2.97%)
# 
# Value distribution (all 20 values):
#   TOTAL: 71,912 (76.38%)
#   ELECTION DAY: 5,609 (5.96%)
#   ABSENTEE: 3,513 (3.73%)
#   PROVISIONAL: 2,926 (3.11%)
#   : 2,795 (2.97%)
#   EARLY VOTING: 2,270 (2.41%)
#   ABSENTEE BY MAIL: 1,038 (1.10%)
#   EARLY: 585 (0.62%)
#   FAILSAFE PROVISIONAL: 552 (0.59%)
#   ONE STOP: 500 (0.53%)
#   PROV: 477 (0.51%)
#   ADVANCED VOTING: 477 (0.51%)
#   EARLY VOTE: 450 (0.48%)
#   MAIL-IN: 268 (0.28%)
#   FAILSAFE: 230 (0.24%)
#   IN-PERSON ABSENTEE: 230 (0.24%)
#   MAIL: 145 (0.15%)
#   2ND ABSENTEE: 120 (0.13%)
#   VOTE CENTER: 36 (0.04%)
#   LATE EARLY VOTING: 18 (0.02%)
#
# --- STDERR ---
# (captured in STDOUT above via 2>&1)
#
# =============================================================================
