"""
clean.py
Raw-to-analytic data construction placeholder.

Replace this file with project-specific cleaning code. The downstream
template expects data/intermediate/analytic.parquet with at least:
unit_id, year, treat, treat_year, outcome, x1, x2, endog, iv, balanced.
"""

from __future__ import annotations

import logging

import setup

log = logging.getLogger(__name__)


def run() -> None:
    analytic = setup.INTERMEDIATE / "analytic.parquet"
    if analytic.exists():
        log.info("Found existing analytic file: %s", analytic)
        return

    raise FileNotFoundError(
        "Missing data/intermediate/analytic.parquet. Replace clean.py with "
        "project-specific raw-to-analytic code, or create the analytic file "
        "before running run_all.py."
    )
