/*------------------------------------------------------------------
  00_globals.do
  Project-wide globals. Edit the `project` line once.
-------------------------------------------------------------------*/

* ---- Edit this line, and only this line --------------------------
global project "/Users/<you>/Documents/replication-package"

* ---- Derived paths -----------------------------------------------
global data        "$project/data"
global raw         "$data/raw"
global intermediate "$data/intermediate"
global code        "$project/code"
global output      "$project/output"
global tables      "$output/tables"
global figures     "$output/figures"
global logs        "$project/logs"
global docs        "$project/docs"

* ---- Create expected directories ---------------------------------
foreach d in "$data" "$raw" "$intermediate" "$output" "$tables" "$figures" "$logs" "$docs" {
    capture mkdir "`d'"
}

* ---- Reproducibility ---------------------------------------------
set seed 20260101    // fixed seed for any randomization

* ---- House-style display options (table & graph) -----------------
graph set window fontface "Helvetica"
set scheme s2color
