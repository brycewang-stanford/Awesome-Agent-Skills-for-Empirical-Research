/*------------------------------------------------------------------
  03_main_did.do
  Main specification — staggered DiD with modern estimator.

  Produces:
    * Table: main TWFE vs. Callaway-Sant'Anna comparison
    * Figure: event-study with 95% CI
    * Diagnostic: Goodman-Bacon decomposition
-------------------------------------------------------------------*/

use "$intermediate/analytic.dta", clear

* ==================================================================
* 1. Naive TWFE (FOR COMPARISON ONLY — DO NOT REPORT AS MAIN)
* ==================================================================
eststo twfe: reghdfe outcome treat $controls, ///
    absorb(unit_id year) cluster(unit_id)

* ==================================================================
* 2. Goodman-Bacon decomposition — show "forbidden comparison" weight
* ==================================================================
bacondecomp outcome treat, ddetail
graph export "$figures/fig_bacon_decomp.pdf", replace

* ==================================================================
* 3. Callaway-Sant'Anna ATT(g,t) — PREFERRED ESTIMATOR
* ==================================================================
csdid outcome $controls, ///
    ivar(unit_id) time(year) gvar(treat_year) ///
    method(dripw)                              // doubly-robust IPW
estat all                                      // simple, group, calendar, event

* Aggregated simple ATT
csdid_estat simple, window(0 5)
estimates store cs_simple

* Event-study aggregation
csdid_estat event, window(-5 5) wboot reps(999)
estimates store cs_event

* ==================================================================
* 4. Event-study plot (Callaway-Sant'Anna)
* ==================================================================
event_plot cs_event, ///
    default_look ///
    graph_opt(xtitle("Years relative to treatment") ///
              ytitle("ATT estimate") ///
              xlabel(-5(1)5) ///
              title("Event study — Callaway-Sant'Anna")) ///
    stub_lag(Tp#) stub_lead(Tm#)
graph export "$figures/fig_event_study.pdf", replace

* ==================================================================
* 5. Honest DiD — sensitivity bounds (Rambachan-Roth)
* ==================================================================
honestdid, pre(2/6) post(7/12) mvec(0(0.05)0.3)
graph export "$figures/fig_honest_did.pdf", replace

* ==================================================================
* 6. Export main results table
* ==================================================================
esttab twfe cs_simple using "$tables/tab_main_did.tex", ///
    replace booktabs ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("TWFE (biased)" "Callaway-Sant'Anna") ///
    label nonotes ///
    addnotes("Standard errors clustered at the unit level." ///
             "TWFE estimator shown for comparison only; Goodman-Bacon" ///
             "decomposition (Figure A) shows X% of weight comes from" ///
             "forbidden comparisons.")
