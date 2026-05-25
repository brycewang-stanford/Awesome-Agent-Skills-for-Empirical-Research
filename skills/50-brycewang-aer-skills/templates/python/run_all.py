#!/usr/bin/env python3
"""
run_all.py
Master script -- AER-compliant Python pipeline.

Author      : <your name>
Paper       : <short title>
Last update : <YYYY-MM-DD>
Python      : 3.11+ (recommended 3.12)

Reproducibility contract:
  1. Create a virtual env:  python -m venv .venv && source .venv/bin/activate
  2. Install pinned deps:    pip install -r requirements.txt
  3. Run from project root:  python run_all.py
  4. All output is written to output/. No file outside the project
     directory is read or written.

Approximate runtime: 25 minutes on a 2024-class laptop.
"""

from __future__ import annotations

import logging
import os
import sys
import time
from pathlib import Path

# ---- 1. Setup ------------------------------------------------------
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

LOG_DIR = ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)
log_file = LOG_DIR / f"run_all_{time.strftime('%Y%m%d_%H%M%S')}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger("run_all")

# ---- 2. Pipeline ---------------------------------------------------
log.info("Pipeline start.")

import setup            # noqa: E402  -- paths, seed, registry
import clean            # noqa: E402  -- raw -> intermediate
import descriptives     # noqa: E402  -- summary stats
import main_did         # noqa: E402  -- main DiD
import robustness       # noqa: E402  -- referee-anticipating checks
import heterogeneity    # noqa: E402
import tables           # noqa: E402  -- publication-ready tex tables
import figures          # noqa: E402  -- publication-ready pdf figures

for module in (clean, descriptives, main_did, robustness,
               heterogeneity, tables, figures):
    name = module.__name__
    log.info(f"--> running {name}")
    module.run()
    log.info(f"<-- finished {name}")

log.info("=" * 60)
log.info(f"Pipeline complete. Outputs in: {setup.OUTPUT}")
log.info("=" * 60)
