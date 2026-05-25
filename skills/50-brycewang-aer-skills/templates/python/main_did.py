"""
main_did.py
Staggered DiD using differences (via `differences` package by Bernardo-Mello),
the closest Python equivalent of R's `did` (Callaway-Sant'Anna).

Produces:
  * Main results table (TWFE vs CSDID) -- output/tables/tab_main_did.tex
  * Event-study figure                  -- output/figures/fig_event_study.pdf
"""

from __future__ import annotations

import logging

import numpy as np
import pandas as pd
import pyfixest as pf                # high-dim FE OLS, AER-style etable
from differences import ATTgt        # Callaway-Sant'Anna in Python
import matplotlib.pyplot as plt

import setup

log = logging.getLogger(__name__)


def _load() -> pd.DataFrame:
    df = pd.read_parquet(setup.INTERMEDIATE / "analytic.parquet")
    return df


def run() -> None:
    df = _load()
    log.info(f"Loaded analytic data: {df.shape[0]:,} rows, {df.shape[1]} cols")

    # ===============================================================
    # 1. Naive TWFE -- COMPARISON ONLY
    # ===============================================================
    twfe = pf.feols(
        "outcome ~ treat + x1 + x2 | unit_id + year",
        data    = df,
        vcov    = {"CRV1": "unit_id"},
    )

    # ===============================================================
    # 2. Callaway-Sant'Anna ATT(g,t) -- PREFERRED ESTIMATOR
    # ===============================================================
    cs = ATTgt(
        data           = df,
        outcome        = "outcome",
        treatment_time = "treat_year",
        time           = "year",
        entity         = "unit_id",
        covariates     = ["x1", "x2"],
        estimator      = "dr",                 # doubly-robust IPW
        control_group  = "never_treated",
    )
    cs.fit()

    simple_att = cs.aggregate(by="simple")
    dynamic    = cs.aggregate(by="dynamic", min_e=-5, max_e=5)

    log.info(f"Simple ATT: {simple_att.estimate:.4f} (SE {simple_att.se:.4f})")

    # ===============================================================
    # 3. Event-study plot
    # ===============================================================
    ev = dynamic.results_df.copy()
    ev["ci_lo"] = ev["estimate"] - 1.96 * ev["se"]
    ev["ci_hi"] = ev["estimate"] + 1.96 * ev["se"]

    fig, ax = plt.subplots(figsize=(6, 4))
    ax.axhline(0, color="grey", linestyle="--", linewidth=0.8)
    ax.axvline(-0.5, color="grey", linestyle="--", linewidth=0.8)

    pre  = ev[ev["event_time"] < 0]
    post = ev[ev["event_time"] >= 0]

    ax.errorbar(pre["event_time"],  pre["estimate"],
                yerr=[pre["estimate"] - pre["ci_lo"],
                      pre["ci_hi"]  - pre["estimate"]],
                fmt="o", color="grey", capsize=2, label="Pre-treatment")
    ax.errorbar(post["event_time"], post["estimate"],
                yerr=[post["estimate"] - post["ci_lo"],
                      post["ci_hi"]   - post["estimate"]],
                fmt="o", color="black", capsize=2, label="Post-treatment")

    ax.set_xlabel("Years relative to treatment")
    ax.set_ylabel("ATT estimate")
    ax.set_xticks(range(-5, 6))
    ax.legend(frameon=False, loc="upper left")

    fig.savefig(setup.FIGURES / "fig_event_study.pdf")
    plt.close(fig)
    log.info("Wrote fig_event_study.pdf")

    # ===============================================================
    # 4. Main results table (TWFE vs CSDID)
    # ===============================================================
    pf.etable(
        models   = [twfe],
        type     = "tex",
        file_path = str(setup.TABLES / "tab_twfe.tex"),
        signif_code = [0.01, 0.05, 0.10],
        digits   = 3,
        notes    = (
            "Standard errors clustered at the unit level. "
            "TWFE shown for comparison only; preferred estimate is Callaway-Sant'Anna "
            "(see Table A.X). *** p<0.01, ** p<0.05, * p<0.10."
        ),
    )

    pd.DataFrame({
        "Estimator":   ["TWFE", "Callaway-Sant'Anna"],
        "Estimate":    [twfe.coef()["treat"], simple_att.estimate],
        "SE":          [twfe.se()["treat"],   simple_att.se],
        "N":           [len(df),              len(df)],
    }).to_latex(
        setup.TABLES / "tab_main_did.tex",
        index=False, float_format="%.3f",
    )
    log.info("Wrote tab_main_did.tex")
