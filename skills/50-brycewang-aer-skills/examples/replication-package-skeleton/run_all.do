/*------------------------------------------------------------------
  run_all.do
  Master script. See README.md for instructions.
-------------------------------------------------------------------*/

version 18.0
clear all
set more off
cap log close

do "code/00_globals.do"
do "code/00_install_packages.do"

log using "logs/run_all.log", replace text

do "code/01_clean.do"
do "code/02_descriptives.do"
do "code/03_main_did.do"
do "code/04_robustness.do"
do "code/05_heterogeneity.do"
do "code/06_tables.do"
do "code/07_figures.do"

log close

di as result _n "Pipeline complete. See output/ for tables and figures."
