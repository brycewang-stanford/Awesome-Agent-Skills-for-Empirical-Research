#!/usr/bin/env python3
"""
DATA INGEST: Structural Profile
Data file: /daaf/data/ingest/election-returns/countypres_2000-2024.tab
Purpose: Extract basic structure (rows, columns, types, memory)
"""
import polars as pl

# --- Config ---
DATA_PATH = "/daaf/data/ingest/election-returns/countypres_2000-2024.tab"

# --- Load ---
df = pl.read_csv(DATA_PATH, separator='\t')

# --- Profile ---
print("=== STRUCTURAL PROFILE ===")
print(f"Rows: {df.height:,}")
print(f"Columns: {df.width}")
print(f"Memory: {df.estimated_size() / 1024 / 1024:.2f} MB")

print("\n=== COLUMN TYPES ===")
for col in df.columns:
    print(f"  {col}: {df[col].dtype}")

print("\n=== COLUMN ORDER (as in file) ===")
for i, col in enumerate(df.columns):
    print(f"  {i}: {col}")

print("\n=== FIRST 5 ROWS ===")
print(df.head(5))

print("\n=== LAST 5 ROWS ===")
print(df.tail(5))

print("\n=== SCHEMA ===")
print(df.schema)


# =============================================================================
# EXECUTION LOG
# =============================================================================
#
# Executed: 2026-02-23 00:41:23
# Command: python /daaf/data/ingest/election-returns/scripts/01_structural_profile.py
# Duration: s
# Exit code: 0
#
# --- STDOUT ---
# === STRUCTURAL PROFILE ===
# Rows: 94,151
# Columns: 12
# Memory: 8.42 MB
# 
# === COLUMN TYPES ===
#   state: String
#   county_name: String
#   year: Int64
#   state_po: String
#   county_fips: Int64
#   office: String
#   candidate: String
#   party: String
#   candidatevotes: Int64
#   totalvotes: Int64
#   version: Int64
#   mode: String
# 
# === COLUMN ORDER (as in file) ===
#   0: state
#   1: county_name
#   2: year
#   3: state_po
#   4: county_fips
#   5: office
#   6: candidate
#   7: party
#   8: candidatevotes
#   9: totalvotes
#   10: version
#   11: mode
# 
# === FIRST 5 ROWS ===
# shape: (5, 12)
# ┌─────────┬─────────────┬──────┬──────────┬───┬────────────────┬────────────┬──────────┬───────┐
# │ state   ┆ county_name ┆ year ┆ state_po ┆ … ┆ candidatevotes ┆ totalvotes ┆ version  ┆ mode  │
# │ ---     ┆ ---         ┆ ---  ┆ ---      ┆   ┆ ---            ┆ ---        ┆ ---      ┆ ---   │
# │ str     ┆ str         ┆ i64  ┆ str      ┆   ┆ i64            ┆ i64        ┆ i64      ┆ str   │
# ╞═════════╪═════════════╪══════╪══════════╪═══╪════════════════╪════════════╪══════════╪═══════╡
# │ ALABAMA ┆ AUTAUGA     ┆ 2024 ┆ AL       ┆ … ┆ 293            ┆ 28281      ┆ 20260211 ┆ TOTAL │
# │ ALABAMA ┆ AUTAUGA     ┆ 2024 ┆ AL       ┆ … ┆ 65             ┆ 28281      ┆ 20260211 ┆ TOTAL │
# │ ALABAMA ┆ AUTAUGA     ┆ 2024 ┆ AL       ┆ … ┆ 7439           ┆ 28281      ┆ 20260211 ┆ TOTAL │
# │ ALABAMA ┆ AUTAUGA     ┆ 2024 ┆ AL       ┆ … ┆ 20484          ┆ 28281      ┆ 20260211 ┆ TOTAL │
# │ ALABAMA ┆ BALDWIN     ┆ 2024 ┆ AL       ┆ … ┆ 1276           ┆ 122249     ┆ 20260211 ┆ TOTAL │
# └─────────┴─────────────┴──────┴──────────┴───┴────────────────┴────────────┴──────────┴───────┘
# 
# === LAST 5 ROWS ===
# shape: (5, 12)
# ┌─────────┬─────────────┬──────┬──────────┬───┬────────────────┬────────────┬──────────┬───────┐
# │ state   ┆ county_name ┆ year ┆ state_po ┆ … ┆ candidatevotes ┆ totalvotes ┆ version  ┆ mode  │
# │ ---     ┆ ---         ┆ ---  ┆ ---      ┆   ┆ ---            ┆ ---        ┆ ---      ┆ ---   │
# │ str     ┆ str         ┆ i64  ┆ str      ┆   ┆ i64            ┆ i64        ┆ i64      ┆ str   │
# ╞═════════╪═════════════╪══════╪══════════╪═══╪════════════════╪════════════╪══════════╪═══════╡
# │ VERMONT ┆ WINDSOR     ┆ 2024 ┆ VT       ┆ … ┆ 10458          ┆ 34579      ┆ 20260211 ┆ TOTAL │
# │ VERMONT ┆ WINDSOR     ┆ 2024 ┆ VT       ┆ … ┆ 22569          ┆ 34579      ┆ 20260211 ┆ TOTAL │
# │ VERMONT ┆ WINDSOR     ┆ 2024 ┆ VT       ┆ … ┆ 1096           ┆ 34579      ┆ 20260211 ┆ TOTAL │
# │ VERMONT ┆ WINDSOR     ┆ 2024 ┆ VT       ┆ … ┆ 16             ┆ 34579      ┆ 20260211 ┆ TOTAL │
# │ VERMONT ┆ WINDSOR     ┆ 2024 ┆ VT       ┆ … ┆ 274            ┆ 34579      ┆ 20260211 ┆ TOTAL │
# └─────────┴─────────────┴──────┴──────────┴───┴────────────────┴────────────┴──────────┴───────┘
# 
# === SCHEMA ===
# Schema({'state': String, 'county_name': String, 'year': Int64, 'state_po': String, 'county_fips': Int64, 'office': String, 'candidate': String, 'party': String, 'candidatevotes': Int64, 'totalvotes': Int64, 'version': Int64, 'mode': String})
#
# --- STDERR ---
# (captured in STDOUT above via 2>&1)
#
# =============================================================================
