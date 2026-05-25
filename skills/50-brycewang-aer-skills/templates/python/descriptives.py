"""
descriptives.py
Summary-statistics scaffold.
"""

from __future__ import annotations

import logging

import pandas as pd

import setup

log = logging.getLogger(__name__)


def run() -> None:
    analytic = setup.INTERMEDIATE / "analytic.parquet"
    if not analytic.exists():
        log.info("Skipping descriptives; analytic file does not exist yet.")
        return

    df = pd.read_parquet(analytic)
    numeric = df.select_dtypes("number")
    if numeric.empty:
        log.info("Skipping descriptives; no numeric columns found.")
        return

    out = setup.TABLES / "summary_statistics.csv"
    numeric.describe().T.to_csv(out)
    log.info("Wrote %s", out)
