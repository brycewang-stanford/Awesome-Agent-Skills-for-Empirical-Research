"""
Calibration assessment for Bayesian models.

Computes coverage calibration, PIT ECDFs, and generates calibration plots
using ArviZ 1.0+ (arviz_plots). Supports both PPC-PIT and LOO-PIT.

Usage:
    python calibration_check.py --idata path/to/inference_data.nc
    python calibration_check.py --idata path/to/inference_data.nc --var-name obs --save-plots
    python calibration_check.py --idata path/to/inference_data.nc --loo-pit --save-plots
    python calibration_check.py --idata path/to/inference_data.nc --save-plots --plot-dir plots/
"""

import argparse
import json
import os
import sys
import warnings

import numpy as np

try:
    import arviz_plots as azp
    import arviz_stats as azs
    from arviz_base import convert_to_datatree
    from arviz_plots.plots.ppc_pit_plot import difference_ecdf_pit
    from arviz_stats.ecdf_utils import ecdf_pit
except ImportError:
    print(
        json.dumps(
            {
                "error": (
                    "arviz_plots and arviz_base are required. "
                    "Install with: pip install arviz-plots arviz-base"
                )
            }
        )
    )
    sys.exit(1)

warnings.filterwarnings("ignore", category=FutureWarning)


def _extract_ecdf_results(ds, var_name):
    """Extract ΔECDF check from a difference_ecdf_pit result Dataset.

    Returns (inside_bands, mean_delta_ecdf).
    """
    dy = ds[var_name].sel(plot_axis="y").values
    dy_lb = ds[var_name].sel(plot_axis="y_bottom").values
    dy_ub = ds[var_name].sel(plot_axis="y_top").values
    inside = bool(((dy >= dy_lb) & (dy <= dy_ub)).all())
    return inside, round(float(np.mean(dy)), 4)


def _ecdf_check(pit_vals, ci_prob=0.99, n_simulations=1000):
    """Compute ΔECDF and check if it stays inside simultaneous confidence bands.

    Uses arviz_stats.ecdf_pit. i.e the same computation that powers the ArviZ plots.
    Returns (inside_bands, mean_delta_ecdf).
    """
    eval_pts, ecdf_vals, ci_lb, ci_ub = ecdf_pit(
        pit_vals, ci_prob, n_simulations=n_simulations
    )
    dy = ecdf_vals - eval_pts
    dy_lb = ci_lb - eval_pts
    dy_ub = ci_ub - eval_pts
    inside = bool(((dy >= dy_lb) & (dy <= dy_ub)).all())
    return inside, round(float(np.mean(dy)), 4)


def assess_calibration(dt, var_name, use_loo, ci_prob=0.99):
    """Assess calibration using the same ΔECDF + simultaneous bands as the plots.

    For PPC-PIT, delegates to arviz_plots.difference_ecdf_pit which handles
    discrete-data randomization correctly. For LOO-PIT, uses arviz_stats.loo_pit
    (which also handles discrete data) then arviz_stats.ecdf_pit.

    "Well-calibrated" means the ΔECDF stays inside the simultaneous bands.

    The coverage direction follows ArviZ conventions (EABM reference):
        positive coverage ΔECDF → empirical > nominal → under-confident (too uncertain)
        negative coverage ΔECDF → empirical < nominal → over-confident (too certain)
    """
    if use_loo:
        pit_vals = azs.loo_pit(dt, var_names=var_name)[var_name].values
        pit_inside, _ = _ecdf_check(pit_vals, ci_prob=ci_prob)
        coverage_vals = 2 * np.abs(pit_vals - 0.5)
        coverage_inside, mean_cov_delta = _ecdf_check(coverage_vals, ci_prob=ci_prob)
    else:
        pp_ds = dt["posterior_predictive"].dataset
        obs_ds = dt["observed_data"].dataset
        ds_pit = difference_ecdf_pit(
            pp_ds, obs_ds, ci_prob=ci_prob, coverage=False, n_simulations=1000
        )
        pit_inside, _ = _extract_ecdf_results(ds_pit, var_name)
        ds_cov = difference_ecdf_pit(
            pp_ds, obs_ds, ci_prob=ci_prob, coverage=True, n_simulations=1000
        )
        coverage_inside, mean_cov_delta = _extract_ecdf_results(ds_cov, var_name)

    if mean_cov_delta > 0.02:
        calibration_diagnosis = "under-confident (predictions too uncertain)"
    elif mean_cov_delta < -0.02:
        calibration_diagnosis = "over-confident (predictions too certain)"
    else:
        calibration_diagnosis = "well-calibrated"

    return {
        "pit_ecdf_inside_bands": pit_inside,
        "coverage_ecdf_inside_bands": coverage_inside,
        "well_calibrated": pit_inside and coverage_inside,
        "mean_coverage_deviation": mean_cov_delta,
        "calibration_diagnosis": calibration_diagnosis,
    }


def save_pit_plot(
    dt, var_name, output_path, *, use_loo=False, coverage=False, ci_prob=0.99
):
    """Generate and save a PIT-based calibration plot.

    Uses azp.plot_loo_pit (LOO-PIT, avoids double-dipping) or
    azp.plot_ppc_pit (PPC-PIT) with optional coverage=True for the
    coverage transformation. Both produce ΔECDF plots with simultaneous
    confidence bands (Säilynoja et al. 2022).
    """
    plot_fn = azp.plot_loo_pit if use_loo else azp.plot_ppc_pit
    pc = plot_fn(dt, var_names=var_name, coverage=coverage, ci_prob=ci_prob)
    pc.savefig(output_path)
    return output_path


def main():
    parser = argparse.ArgumentParser(description="Bayesian model calibration check")
    parser.add_argument(
        "--idata", required=True, help="Path to InferenceData (.nc file)"
    )
    parser.add_argument(
        "--var-name",
        default=None,
        help="Name of the observed variable (auto-detected if not specified)",
    )
    parser.add_argument("--output", default=None, help="Path to save JSON report")
    parser.add_argument(
        "--save-plots", action="store_true", help="Save calibration plots"
    )
    parser.add_argument(
        "--loo-pit",
        action="store_true",
        help="Use LOO-PIT instead of PPC-PIT (requires log_likelihood group)",
    )
    parser.add_argument(
        "--plot-dir", default=".", help="Directory for saved plots (default: .)"
    )
    parser.add_argument(
        "--ci-prob",
        type=float,
        default=0.99,
        help="Probability for simultaneous confidence bands (default: 0.99)",
    )
    args = parser.parse_args()

    try:
        dt = convert_to_datatree(args.idata)
    except Exception as e:
        print(json.dumps({"error": f"Could not load InferenceData: {e}"}))
        sys.exit(1)

    # Validate data availability
    if "posterior_predictive" not in dt.children:
        print(
            json.dumps(
                {
                    "error": "No posterior_predictive group. Run pm.sample_posterior_predictive() first."
                }
            )
        )
        sys.exit(1)

    if "observed_data" not in dt.children:
        print(
            json.dumps({"error": "No observed_data group. Cannot compute calibration."})
        )
        sys.exit(1)

    # Auto-detect var_name if not specified
    var_name = args.var_name
    if var_name is None:
        pp_vars = set(dt["posterior_predictive"].data_vars)
        obs_vars = set(dt["observed_data"].data_vars)
        common = sorted(pp_vars & obs_vars)
        if not common:
            print(
                json.dumps(
                    {
                        "error": (
                            f"No common variables between posterior_predictive {sorted(pp_vars)} "
                            f"and observed_data {sorted(obs_vars)}."
                        )
                    }
                )
            )
            sys.exit(1)
        var_name = common[0]
        if len(common) > 1:
            print(
                f"Warning: multiple common variables found: {common}. Using '{var_name}'.",
                file=sys.stderr,
            )

    if var_name not in dt["posterior_predictive"].data_vars:
        available = list(dt["posterior_predictive"].data_vars)
        print(
            json.dumps(
                {
                    "error": f"Variable '{var_name}' not found in posterior_predictive. Available: {available}"
                }
            )
        )
        sys.exit(1)

    if var_name not in dt["observed_data"].data_vars:
        print(
            json.dumps(
                {
                    "error": f"No observed data for '{var_name}'. Cannot compute calibration."
                }
            )
        )
        sys.exit(1)

    # Validate LOO-PIT requirements
    if args.loo_pit and "log_likelihood" not in dt.children:
        print(
            json.dumps(
                {
                    "error": (
                        "LOO-PIT requires a log_likelihood group in the InferenceData. "
                        "Re-run sampling with idata_kwargs={'log_likelihood': True}, or "
                        "run `pm.compute_log_likelihood(idata, model_instance)."
                    )
                }
            )
        )
        sys.exit(1)

    # Assess calibration using ArviZ ΔECDF + simultaneous bands
    ci_prob = args.ci_prob
    assessment = assess_calibration(dt, var_name, use_loo=args.loo_pit, ci_prob=ci_prob)

    n_obs = len(dt["observed_data"][var_name].values)
    report = {
        "variable": var_name,
        "n_observations": n_obs,
        "pit_method": "loo_pit" if args.loo_pit else "ppc_pit",
        "assessment": assessment,
    }

    # Save plots using arviz_plots
    if args.save_plots:
        os.makedirs(args.plot_dir, exist_ok=True)
        prefix = "loo_pit" if args.loo_pit else "pit"
        report["plots"] = {
            "pit_ecdf": save_pit_plot(
                dt,
                var_name,
                os.path.join(args.plot_dir, f"{prefix}_ecdf.png"),
                use_loo=args.loo_pit,
                ci_prob=ci_prob,
            ),
            "coverage": save_pit_plot(
                dt,
                var_name,
                os.path.join(args.plot_dir, f"{prefix}_coverage.png"),
                use_loo=args.loo_pit,
                coverage=True,
                ci_prob=ci_prob,
            ),
        }

    output = json.dumps(report, indent=2)
    if args.output:
        with open(args.output, "w") as f:
            f.write(output)
        print(f"Report saved to {args.output}")
    else:
        print(output)


if __name__ == "__main__":
    main()
