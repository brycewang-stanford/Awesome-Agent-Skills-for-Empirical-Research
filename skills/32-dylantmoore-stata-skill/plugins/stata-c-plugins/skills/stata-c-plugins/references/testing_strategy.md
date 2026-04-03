# Testing Strategy for Translated Stata Packages

## Overview

Testing a Stata package translated from Python/R requires three things:
1. **Reference outputs** from the original implementation
2. **Stata tests** that compare against those references
3. **Integration tests** that verify the Stata user experience

## Layer 0: Repurpose the Original Test Suite

### Purpose
Before writing any new tests, mine the original package's test suite for test data, test cases, and expected outputs. The original authors already found the edge cases and tricky inputs — don't reinvent them.

### What to Extract

1. **Test datasets.** Copy or convert the original's test data into CSV for Stata. These are the most valuable artifacts — they represent inputs the original authors specifically chose to exercise edge cases.

2. **Test assertions.** Translate the original's test checks into Stata. If the Python test says `assert model.predict(X) == expected`, write the equivalent Stata assertion.

3. **Edge case inputs.** Look for tests that exercise boundary conditions: empty input, single records, all-identical values, missing data patterns, maximum-size inputs. These are the tests you'd otherwise have to discover through painful debugging.

4. **Expected outputs.** Run the original test suite and capture its outputs. Use these as reference data for your Stata fidelity tests.

### How to Extract

```bash
# Find the original's test files
find /path/to/source/package -name "test_*.py" -o -name "tests/" -o -name "testthat/"

# For Python: run tests and capture output
cd /path/to/source/package && python -m pytest tests/ -v --tb=short

# For R: run tests
cd /path/to/source/package && Rscript -e "testthat::test_dir('tests/')"
```

Generate a script that runs the original test suite, captures all inputs and expected outputs as CSV, and saves them in your Stata project's `tests/` directory. Pin the exact package version so results are reproducible.

### When the Original Has No Test Suite

Some packages have minimal or no tests. In this case, fall back to Layer 1 (generating reference data from scratch). But first check: documentation examples, vignettes, and README demos often contain implicit test cases with expected outputs.

## Layer 1: Reference Data Generation

### Purpose
Generate test inputs AND reference outputs using the original package. Save everything as CSV so Stata can load it.

### Script Template: `tests/generate_test_data.py` (or `.R`)

```python
#!/usr/bin/env python3
"""Generate reference test data for Stata package validation."""

import numpy as np
import pandas as pd
from original_package import OriginalModel

def generate_test_data(n, p, seed=42):
    """Generate data with known properties for validation."""
    rng = np.random.default_rng(seed)
    X = rng.standard_normal((n, p))

    # Known signal — choose something appropriate for your package
    beta = np.array([3.0 * np.exp(-i / 10) for i in range(p)])
    y = X @ beta + 0.3 * X[:, 0]**2 + rng.normal(0, 0.5, n)

    return X, y

def generate_validation_data():
    """Run the source implementation and save inputs + outputs."""
    X, y = generate_test_data(n=1000, p=4, seed=42)

    # Run original implementation
    model = OriginalModel(param1=value1, param2=value2)
    result = model.fit_or_run(X, y)

    # Save inputs and reference outputs as CSV
    df = pd.DataFrame(X, columns=[f'x{i+1}' for i in range(X.shape[1])])
    df['y'] = y

    # Save whatever the source produces — predictions, estimates, weights, etc.
    # The columns you add here depend on what your command outputs.
    df['ref_output'] = result.predictions  # or .estimates, .weights, etc.

    df.to_csv('test_data.csv', index=False)

if __name__ == '__main__':
    generate_validation_data()
```

### Key Principles

1. **Save complete inputs**, not just outputs. Stata needs to run its own implementation on the same data.
2. **Include ground truth** when applicable, so you can verify both implementations against reality.
3. **Use structured data** with known signal so you can distinguish implementation bugs from method limitations.
4. **Pin the source package version.** Without this, your reference data may become irreproducible.

## Layer 2: Correctness Tests

### Core Principle

For any input, the Stata implementation should produce the same output as the source. What "same" means depends on the algorithm:

| Algorithm Nature | What to Check | Metric |
|-----------------|---------------|--------|
| Deterministic | Exact match | Max absolute deviation < ε (e.g., 1e-10) |
| Numerically sensitive | Near-exact match | Max relative deviation small; correlation ≈ 1.0 |
| Fundamentally stochastic | Substantive agreement | Choose a metric appropriate to the output (see below) |

### Choosing the Right Metric

The comparison metric depends on what the command produces:

| Output Type | Appropriate Metrics |
|-------------|-------------------|
| Point predictions | Correlation, MAE, max absolute deviation |
| Scalar estimates (coefficients, SEs) | Relative error, exact match |
| Classifications / labels | Agreement rate, confusion matrix |
| Distributions / densities | KS statistic, moment comparisons, QQ correlation |
| Weights / ranks | Rank correlation (Spearman), weight sum checks |
| Conditional quantiles | Quantile coverage rates, crossing rates |

Don't default to correlation for everything. It's the right metric for predicted values but meaningless for, say, a single scalar estimate.

### Script Template: `tests/run_tests.do`

```stata
*! run_tests.do - Correctness validation against reference implementation

clear all
set more off

local total_tests 0
local passed_tests 0
local failed_tests 0

// ============================================================
// TEST: Output agrees with reference
// ============================================================

import delimited using "test_data.csv", clear

// Run Stata implementation
mycommand y x1 x2 x3 x4, [options]

// Compare Stata output to reference output
// Choose comparison appropriate to your output type:

// --- For predictions or continuous output ---
quietly correlate stata_output ref_output
local corr = r(rho)
gen double ad = abs(stata_output - ref_output)
quietly summarize ad
local max_dev = r(max)
local mean_dev = r(mean)

local total_tests = `total_tests' + 1
// Set threshold based on algorithm nature:
//   deterministic: max_dev < 1e-10
//   numerically sensitive: corr > 0.999
//   stochastic: corr > 0.95 (or whatever is appropriate)
if `corr' > 0.99 {
    di as res "PASS: correlation = `corr', max dev = `max_dev'"
    local passed_tests = `passed_tests' + 1
}
else {
    di as err "FAIL: correlation = `corr', max dev = `max_dev'"
    local failed_tests = `failed_tests' + 1
}

// --- For scalar estimates ---
// local ref_value = [known value from reference]
// local stata_value = [r(estimate) or e(b)]
// local reldiff = abs(`stata_value' - `ref_value') / abs(`ref_value')
// assert `reldiff' < 1e-6

// ============================================================
// Summary
// ============================================================
di _n "Tests: `total_tests', Passed: `passed_tests', Failed: `failed_tests'"
```

### Always Also Check Against Ground Truth

Matching the source implementation is necessary but not sufficient. If both implementations are wrong in the same way, you'd never know. When ground truth is available (synthetic data with known parameters, held-out test sets), compare against that too.

## Layer 3: Integration Tests

### Script Template: `tests/test_features.do`

```stata
*! test_features.do - Feature verification

clear all
set more off
local n_tests 0
local n_pass 0
local n_fail 0

// TEST: Basic invocation works
sysuse auto, clear
capture noisily mycommand price mpg weight, [minimal options]
local n_tests = `n_tests' + 1
if _rc == 0 {
    di as res "PASS: basic invocation"
    local n_pass = `n_pass' + 1
}
else {
    di as err "FAIL: basic invocation returned error `=_rc'"
    local n_fail = `n_fail' + 1
}

// TEST: Each option/method works
foreach opt in option1 option2 option3 {
    sysuse auto, clear
    capture noisily mycommand price mpg weight, method(`opt')
    local n_tests = `n_tests' + 1
    if _rc == 0 {
        di as res "PASS: method(`opt') works"
        local n_pass = `n_pass' + 1
    }
    else {
        di as err "FAIL: method(`opt') returned error `=_rc'"
        local n_fail = `n_fail' + 1
    }
}

// TEST: if/in conditions
sysuse auto, clear
mycommand price mpg weight if foreign == 1, [options]
// verify output is only produced for the specified subset

// TEST: replace option
sysuse auto, clear
mycommand price mpg weight, gen(test_var) [options]
capture noisily mycommand price mpg weight, gen(test_var) [options] replace
local n_tests = `n_tests' + 1
if _rc == 0 {
    di as res "PASS: replace option works"
    local n_pass = `n_pass' + 1
}
else {
    di as err "FAIL: replace option error `=_rc'"
    local n_fail = `n_fail' + 1
}

// TEST: Stored results
// After running command, verify r() or e() values are populated
mycommand price mpg weight, [options]
assert !missing(r(N))  // or whatever your command stores

// TEST: Edge cases
// - Single predictor
// - Many predictors
// - Small n
// - Constant variable
// - All identical values

// Summary
di _n "Total: `n_tests', Passed: `n_pass', Failed: `n_fail'"
```

### What to Test

1. **Basic invocation** — does the command run without error on simple data?
2. **Every option** — each option/method produces output without errors.
3. **`if`/`in` conditions** — subsetting works correctly.
4. **`replace` option** — calling twice with `replace` doesn't error.
5. **Stored results** — `r()` or `e()` values are populated correctly.
6. **Edge cases** — small n, high p, constant variables, collinear features.
7. **Error handling** — bad inputs produce informative error messages, not crashes.

## Layer 4: Stress Tests

### What to Stress

1. **High dimensionality** (p = 50, 100, 500): Does the method degrade gracefully?
2. **Large n** (n = 10,000+): Does it complete in reasonable time?
3. **Memory** (n * p large): Does it crash or hang?
4. **Correlated features**: AR(1) structure tests numerical stability.
5. **Near-singular data**: Multicollinearity stress test.

### Stress Test Data Generation

```python
from scipy.stats import multivariate_normal

# AR(1) correlation structure
rho = 0.5
cov = np.array([[rho ** abs(i-j) for j in range(p)] for i in range(p)])
X = multivariate_normal(np.zeros(p), cov).rvs(size=n)
```

## Running Tests

### Batch Mode

```bash
stata-mp -b do tests/run_tests.do
stata-mp -b do tests/test_features.do
```

Stata writes output to `run_tests.log` and `test_features.log` in the current directory.

### Checking Results

```bash
grep -E "PASS|FAIL|Total" run_tests.log
grep -E "PASS|FAIL|Total" test_features.log
```

Add `*.log` to `.gitignore` early. Log files are large and should not be committed.

## Debugging Test Failures

### Output Disagrees with Source

1. **Check data sorting.** Is the plugin receiving data in the order it expects?
2. **Check missing value handling.** Stata `.` vs Python `NaN` vs R `NA` — different semantics.
3. **Check merge logic.** Does `merge_id` survive preserve/restore?
4. **Check normalization.** Are inputs scaled the same way both implementations expect?
5. **Run on trivially simple data** (e.g., y = 2*x + 1) and verify by hand.

### Plugin Returns All Missing

1. **Check plugin loading.** Is the correct platform plugin found?
2. **Check variable count.** Does `SF_nvar()` match what the plugin expects?
3. **Check argument parsing.** Are `argv[]` values correct?
4. **Check observation count.** Did `keep if` leave zero observations?

### Tests Pass Locally But Fail on Another Platform

1. **Integer sizes differ.** Use `int32_t`/`int64_t` from `<stdint.h>`, not `int`/`long`.
2. **Floating point order differs.** Stochastic algorithms may produce different results.
3. **pthreads behavior differs.** Thread scheduling varies by OS.
