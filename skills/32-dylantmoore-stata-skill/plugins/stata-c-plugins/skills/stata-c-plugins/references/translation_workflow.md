# Translating Python/R Packages into Stata

A complete workflow for porting a Python or R statistical package into a native Stata implementation with C plugin acceleration.

## Mandatory: Start in Plan Mode

**Every translation project MUST begin in plan mode.** Before writing any implementation code, produce a complete plan document covering:

1. All features/options of the source package (exhaustive inventory)
2. Architecture decisions (wrap C++ backend vs. reimplement)
3. Phase-by-phase implementation order with dependencies
4. Test strategy (what test data/suites exist in the original package)
5. The multi-agent review loop baked into every implementation step (see "Multi-Agent Review Loop" below)
6. A final fidelity audit as the last step (see "Final Fidelity Audit" below)

Enter plan mode to produce this document. The plan must be approved before implementation begins. Every step in the plan should specify what gets built, what gets tested, and that the review loop runs before proceeding.

## Phase 1: Scope and Understand the Source

Before writing any code, thoroughly understand the source package.

1. **Check for a C/C++ backend or standalone library first.** Many R packages (and some Python packages) have compiled backends — in R, check `src/` for `.c`/`.cpp`/`.h` files; in Python, look for Cython (`.pyx`), C extensions, or `cffi`/`ctypes` bindings. Also search for standalone C++ libraries that implement the same algorithm (e.g., rapidfuzz-cpp for string matching, Eigen for linear algebra). **If any C/C++ implementation exists, wrap it** rather than reimplementing the algorithm from scratch. This gives you identical output (same code path), the same performance, far less code to write, and easier maintenance. Vendor all dependencies — header-only or otherwise — and statically link everything for all platforms. Binary size is not a concern. See "Wrapping an Existing C++ Backend" below.

2. **Read the source package structure.** Identify all public-facing functions, their signatures, inputs, outputs, and options. Map Python classes/functions to what will become Stata commands.

3. **Identify the computational core.** Separate the algorithm (what computes) from the interface (how users call it). In Python, the algorithm is usually in model classes; in Stata, it will be in C plugins (or wrapped C++ code).

4. **Check the source license.** The translated package inherits licensing obligations. MIT and BSD allow any re-use. GPL requires the Stata package to also be GPL. If the source is proprietary or has no license, get permission before translating.

5. **Default: translate ALL features and options.** The goal is full feature parity with the source package. Do not defer features unless they are fundamentally impossible in Stata (e.g., interactive visualization, language-specific I/O utilities). If a feature presents implementation difficulty, flag it in your plan with a concrete explanation of the challenge — but still plan to implement it. "This is hard" is not a reason to skip; "Stata has no concept of X" might be. Every option, parameter, and mode the original package exposes should be available in the Stata version.

6. **Pin the source package version.** Create `requirements.txt` (Python) or record the exact package version (R) so reference test data can be reproduced later. If the source changes, your tests become meaningless.

7. **Repurpose the original package's test suite AND write new tests.** Before writing tests from scratch, examine the source package's existing test suite (`tests/`, `test_*.py`, `testthat/`, etc.). Extract or adapt:
   - **Test data** — at minimum, use the same datasets the original tests use. Copy them into your `tests/` directory.
   - **Test cases** — translate the original's test assertions into Stata equivalents. If the original tests check that `predict(model, X)` matches expected values, write the same check in Stata.
   - **Edge cases** — the original authors already found the tricky inputs. Don't reinvent them.
   - **Expected outputs** — run the original test suite, capture outputs, and use them as reference data for your Stata tests.

   This is far more valuable than writing tests from scratch because the original authors know where the bugs hide.

   **Then write additional tests** beyond what the original provides. The original test suite may be incomplete, may not cover Stata-specific concerns (preserve/restore, if/in, replace, missing value handling), and doesn't test the .ado wrapper interface. For every implementation step, the agent should write whatever tests are needed to ensure both fidelity (matches the original) and functionality (works correctly as a Stata command). Don't limit yourself to what the original tested — if you see an untested code path, test it.

8. **Map source concepts to Stata equivalents:**

   | Python/R Concept | Stata Equivalent |
   |-----------------|-----------------|
   | Function/method with args | `.ado` command with `syntax` options |
   | Class with fit/predict | C plugin called from `.ado` wrapper |
   | DataFrame I/O | Stata variables accessed via `SF_vdata()`/`SF_vstore()` |
   | Return values | `r()` stored results, new variables via `generate()` |
   | Optional parameters | Stata `syntax` options with defaults |
   | Configuration object | Local macros in `.ado` file |

## Phase 2: Choose Architecture

Three tiers of implementation. Choose based on what the source package provides and your performance needs.

### Tier 1: Pure Stata (ado-files only)
- **When:** Simple operations, linear algebra Stata already does well (OLS, quantile regression)
- **How:** Use native Stata commands (`regress`, `qreg`, `matrix`) inside `.ado` wrappers
- **Performance:** Limited. Loops over observations are extremely slow.

### Tier 2: Wrap Existing C++ Backend (preferred when available)
- **When:** The source package has a C/C++ backend (many R packages do — check `src/` for `.cpp` files). Examples: grf, ranger, Rcpp-based packages, anything using Eigen/Armadillo.
- **How:** Compile the existing C++ source into a Stata plugin. Write a thin `extern "C"` wrapper around the library's API. The plugin internals are C++ — only the `stata_call` entry point needs C linkage. See `references/cpp_plugins.md` for the `extern "C"` pattern, exception safety, and compilation commands.
- **Why this is better than reimplementing:** Near-identical output (same core code path as the original — minor differences from compiler flags or RNG seeding are possible), same performance, far less code to write, and easier to update when the upstream package changes. You only write the glue between Stata's SDK and the library's API.

### Tier 3: Plugin from Scratch (when no compiled backend exists)
- **When:** The source is pure Python/R with no compiled backend, AND no standalone C++ library implements the algorithm.
- **How:** Write C or C++ code using Stata's plugin SDK. See main SKILL.md for C patterns, `references/cpp_plugins.md` for C++.
- **Mata is not recommended** for compute-heavy algorithms — it's significantly slower than C/C++ and adds a layer of complexity without meaningful benefit for plugin-class workloads.

**Recommendation:** Always check for a C++ backend or standalone C++ library first. If one exists, wrap it (Tier 2) — this is faster to build, produces identical output, and is easier to maintain. Only fall back to Tier 3 when no compiled code exists to wrap.

## Wrapping an Existing C++ Backend

When the source package has a C/C++ backend, this is the recommended approach. You compile the original C++ code into a Stata plugin rather than reimplementing the algorithm. For full practical details on C++ plugins (exception safety, platform-specific build commands, the `extern "C"` pattern, and standard library usage), see `references/cpp_plugins.md`. This section covers the translation-specific workflow.

### Identifying a C++ Backend

- **R packages:** Check the `src/` directory in the package source (e.g., on GitHub or CRAN). Look for `.cpp`, `.c`, `.h` files. Many high-performance R packages use Rcpp and have their core algorithms in C++.
- **Python packages:** Look for Cython (`.pyx`), C extensions (`_module.c`), or `cffi`/`ctypes` bindings. Some packages vendor C/C++ libraries.
- **Standalone C++ libraries:** Many algorithms have standalone C++ implementations you can wrap directly. Examples: rapidfuzz-cpp (string matching), Eigen (linear algebra), nlohmann/json (JSON parsing). Search GitHub for `<algorithm-name> cpp` or `<algorithm-name> header-only`.
- **Header-only libraries:** These are the easiest to wrap — vendor the headers into your `c_source/` directory and add `-I.` at compile time. No separate linking needed. The headers get compiled into your plugin binary.

### The Basic Pattern

```cpp
// stata_wrapper.cpp — thin glue between Stata SDK and the C++ library

#include "stplugin.h"
#include "library_header.h"  // the existing C++ library

extern "C" {
    STDLL stata_call(int argc, char *argv[]) {
        // 1. Parse arguments from argv[]
        // 2. Read data from Stata via SF_vdata()
        // 3. Call the C++ library's API
        // 4. Write results back via SF_vstore()
        // 5. Return 0 on success
    }
}
```

The `extern "C"` block gives `stata_call` C linkage so Stata can load it. Everything inside (and all code it calls) can be full C++: templates, classes, STL containers, Eigen matrices, etc.

### Compilation Differences from Pure C

See `references/cpp_plugins.md` for full platform-specific build commands (darwin-arm64, darwin-x86_64, linux, windows cross-compilation).

| Aspect | C Plugin | C++ Plugin |
|--------|----------|------------|
| Compiler | `gcc` | `g++` (or `gcc -lstdc++`) |
| Standard | `-std=c99` | `-std=c++11` or later (match library requirements) |
| Entry point | `stata_call()` | `extern "C" { stata_call() }` |
| SDK files | `stplugin.c` compiled as C | `stplugin.c` compiled as C (keep separate, compile with `gcc`) |
| Header-only libs | N/A | `-I/path/to/headers` |

**Important:** Compile `stplugin.c` as C (with `gcc`), not C++. Then link the resulting object with your C++ code. This avoids name-mangling issues with the SDK symbols:

```bash
gcc -c -O3 -fPIC -DSYSTEM=APPLEMAC stplugin.c -o stplugin.o
g++ -c -O3 -fPIC -std=c++17 -DSYSTEM=APPLEMAC -I./library_headers stata_wrapper.cpp -o wrapper.o
g++ -bundle -o myplugin.darwin-arm64.plugin stplugin.o wrapper.o
```

### When to Wrap vs. Reimplement

| Scenario | Approach |
|----------|----------|
| Source has C++ backend (e.g., grf, ranger, Rcpp packages) | **Wrap** — identical output, same speed, less code |
| Standalone C++ library exists (RapidFuzz, Eigen, etc.) | **Wrap** — vendor the headers/source, write thin glue |
| Header-only C++ library | **Wrap** — just vendor headers and add `-I`, no linking needed |
| No C/C++ backend or library exists (pure Python/R) | **Reimplement** in C or C++ |
| C++ backend has massive dependency tree | Vendor what you need — binary size is not a concern |

**The default is always to wrap when possible.** Reimplementing from scratch is only for cases where no compiled code exists. Binary size is irrelevant — statically link everything (`-static-libstdc++ -static-libgcc`) and ship all platforms.

### Advantages of Wrapping

1. **Near-identical output** — same code path as the original package, not a reimplementation that might diverge. Minor differences can arise from compiler flags, RNG seeding, or threading nondeterminism, but the core algorithm is the same.
2. **Same performance** — you get the original authors' optimizations for free
3. **Less code to write** — you only write the Stata SDK glue, not the algorithm
4. **Easier maintenance** — when the upstream library fixes bugs or adds features, you pull the update and recompile
5. **Easier validation** — if the code is the same, output agreement is nearly guaranteed

## Phase 3: Package Structure

```
packagename/
├── stata.toc              # net install table of contents
├── packagename.pkg        # Package manifest
├── packagename.ado        # Main command (dispatcher)
├── packagename_sub.ado    # Method-specific wrapper (one per method)
├── packagename.sthlp      # Help file (SMCL format)
├── *.plugin               # Precompiled C plugins (4 platforms each)
├── c_plugin/              # C/C++ source (not distributed)
│   ├── lib/               # Vendored C++ library source (if wrapping)
└── tests/
    ├── generate_test_data.py  # Reference outputs from source package
    ├── run_tests.do           # Correctness tests
    └── test_features.do       # Feature verification
```

**One main command, multiple methods** using a dispatcher pattern. Each method also callable directly for advanced users.

**Subprograms in the same .ado file** are NOT auto-discoverable. Only the first `program define` matching the filename is auto-found. Prefer separate .ado files.

## Phase 4: Validating Against the Reference

The most critical translation-specific phase. See `testing_strategy.md` for detailed templates.

### Core Principle

For any given input, the Stata implementation should produce the same output as the source. The acceptable tolerance depends on the algorithm's nature:

| Algorithm Nature | Expected Agreement | Example |
|-----------------|-------------------|---------|
| Deterministic | Identical (within floating-point ε) | KNN, OLS, exact matching |
| Deterministic but numerically sensitive | Nearly identical (tiny deviations) | Matrix inversions, iterative solvers |
| Fundamentally stochastic | Substantively identical | Random forests, MCMC, neural nets |

"Substantively identical" means: applied to the same problem, both implementations should perform comparably. The right metric depends on what the command produces — correlation for predictions, relative error for scalar estimates, classification agreement for labels, distributional tests for density estimates, etc.

### Reference Data Generation

Write a script in the source language that:
1. Creates synthetic data with known properties
2. Runs the original package on it
3. Saves inputs and outputs as CSV for Stata to load

Pin the exact source package version so results are reproducible.

### What to Compare

Always compare against both the **source implementation** and **known ground truth** when possible. Matching the source perfectly is necessary but not sufficient — both implementations could be wrong in the same way.

### Feature Coverage Tests

Every feature and option from the original package must have at least one dedicated test verifying:
1. **Functionality** — the feature runs without error and produces reasonable output
2. **Fidelity** — the output matches the source package (within tolerance appropriate to the algorithm)

This means if the original package has 15 options, the test suite should exercise all 15, not just the 5 easiest ones. Generate reference data from the source package for each feature/option combination that affects output.

### Integration and Stress Tests

- Test every feature end-to-end (`if`/`in`, `replace`, option combinations, edge cases)
- Test "kitchen sink" combinations of multiple new features together
- Stress: high dimensions, large n, correlated features, near-singular data, boundary conditions

### Debugging Test Failures

| Symptom | Likely Cause |
|---------|-------------|
| Output disagrees with source | Sorting mismatch, missing data handling, merge key corruption, 0-vs-1 indexing |
| All missing output | Wrong variable count, plugin not loaded, zero obs after `keep if` |
| Platform differences | Integer sizes (`int` vs `int32_t`), thread scheduling |

## Multi-Agent Review Loop

**Every implementation step must pass a multi-agent review before proceeding.** This is not optional — it is baked into every step of the plan. The loop catches bugs, missed edge cases, and architectural issues that a single pass misses.

### The Loop

After completing each step (compile, test, verify no regressions):

1. **Dispatch review agents in parallel.** Aim for 2-3 agents with different focuses. If you have access to multiple AI models (Claude, GPT, Gemini, etc.), use different models for diversity of perspective. If not, dispatch multiple agents from the same model with different review prompts.

   Suggested review focuses:
   - **Correctness agent:** deep code review for bugs, edge cases, memory safety, architectural issues
   - **Completeness agent:** review for missed requirements, untested paths, gaps vs. original package
   - **Consistency agent:** verify behavior matches original package, check for API contract violations

   Each agent receives:
   - The step's requirements (from the plan)
   - The diffs or full files that were changed
   - The test results
   - Instruction: "List any gaps, bugs, or issues. If everything looks correct and complete, say LGTM."

2. **Collect findings.** Read all agents' reports.

3. **If any agent raised issues:** Fix the identified problems, re-compile, re-test, then re-dispatch all review agents. Loop until all agents say LGTM.

4. **If all agents say LGTM:** The step is complete. Proceed to the next step.

### Why Multi-Perspective Review

Different reviewers (whether different models or differently-prompted agents) catch different things. One may focus on algorithmic correctness while another catches a missing edge case or a documentation gap. The goal is genuine diversity of perspective, not three copies of the same review.

### Writing Tests During Implementation

Each implementation step should include writing tests for the new functionality — not as an afterthought, but as part of the step itself. The agent should write whatever tests are needed to ensure:

- **Fidelity** — output matches the original package (using repurposed test data where available, new reference data where not)
- **Functionality** — the feature works correctly as a Stata command (if/in, replace, missing values, error cases)
- **Edge cases** — boundary conditions, empty inputs, degenerate cases
- **Regressions** — existing tests continue to pass

If a reviewer identifies an untested code path, writing the test is part of the fix, not a separate task.

### What Reviewers Check

- Correctness: does the code do what the plan says?
- Edge cases: what happens with empty input, missing values, single-record blocks, etc.?
- Fidelity: does the behavior match the original package?
- Test coverage: is the new code tested? Are the tests meaningful (not just "runs without error")? Are there obvious untested paths?
- Regressions: do all existing tests still pass?
- Error handling: are failure modes handled gracefully?

## Final Fidelity Audit

**The last step of every plan is a comprehensive fidelity audit.** This is not a casual review — it is a structured, multi-agent investigation of whether the Stata implementation has achieved full feature parity with the original package.

### Audit Process

1. **Dispatch a team of 3 subagents** (aim for 2-3 agents with different review focuses; use multiple models if available). Each agent receives:
   - The original package's documentation (README, API docs, help pages)
   - The complete list of features/options from Phase 1 scoping
   - The Stata implementation's help file and source code
   - The full test suite and its results
   - Instruction: "For every feature and option in the original package, verify that (a) it is implemented in the Stata version, (b) it is tested, and (c) the test demonstrates correct behavior. List any features that are missing, untested, or incorrectly implemented. Score the overall fidelity on a 1-10 scale."

2. **Collect and merge findings.** Compile a unified list of gaps from all agents.

3. **If gaps exist:** Create a new plan to close the remaining gaps. The new plan MUST also use the multi-agent review loop for every step, and MUST end with another fidelity audit. This is recursive — keep planning and implementing until the audit passes clean.

4. **If no gaps (or only genuinely impossible features remain):** The translation is complete. Document any intentional omissions in the help file with explanations.

### What the Audit Checks

| Category | Check |
|----------|-------|
| Feature coverage | Every function/method in the original has a Stata equivalent |
| Option coverage | Every parameter/option is exposed and functional |
| Default values | Stata defaults match original defaults |
| Edge case handling | Missing data, empty input, boundary conditions match |
| Error messages | Invalid input produces helpful errors, not crashes |
| Output format | Stored results (`r()`, variables) contain equivalent information |
| Documentation | Help file accurately describes all implemented features |
| Test coverage | Every feature has at least one test; stochastic features have fidelity tests |

### Closing the Loop

The audit-plan-implement-audit cycle continues until the team of reviewers agrees that parity has been achieved. There is no fixed cap on iterations. A typical project might need 1-2 audit rounds after the initial implementation plan completes.

## Phase 5: Documentation

Be honest about what works, what has limitations, and how it was built. Don't claim features that are silently ignored. Only document what actually works.

## Translation-Specific Pitfalls

1. **Don't translate the interface literally.** Python OOP maps poorly to Stata. Use Stata idioms.
2. **Silently ignored options erode trust.** Either implement or reject with an error. Never accept an option and silently do nothing.
3. **Don't defer features by default.** Plan to implement everything. Flag genuine impossibilities in the plan, but "this is complex" is not a reason to skip.
4. **Pin your reference package version.** Use `requirements.txt`.
5. **Get correctness right first, optimize second.**
6. **Stata's `.` differs from Python's NaN.** `.` sorts to the top and compares as larger than all numbers.
7. **Be transparent about AI-assisted development.** If the package was AI-generated or AI-assisted, note this in the README. Users appreciate honesty about how the code was produced.

## Workflow Summary

```
 1. START IN PLAN MODE — produce a complete plan document before writing any code
 2. Read and understand source package — catalog ALL features, options, and modes
 3. Repurpose original test suite — extract test data, cases, and expected outputs
 4. Check for C/C++ backend (R: check src/, Python: check for Cython/C extensions)
 5. Check license compatibility
 6. Map ALL functions/options → Stata commands, identify compute-heavy algorithms
 7. Decide: wrap C++ backend, write C/C++ from scratch, or pure Stata
 8. Plan ALL features upfront — flag difficulties but do not defer by default
 9. Bake multi-agent review loop into every plan step
10. Scaffold: .ado dispatcher, method wrappers, .sthlp, .pkg, .toc
11. For each implementation step:
      a. Implement the feature
      b. Write tests for fidelity and functionality (don't skip this)
      c. Compile and run full test suite
      d. Dispatch review agents (use multiple review agents with different focuses)
      e. Fix any issues raised by reviewers (including writing missing tests)
      f. Re-review until all agents say LGTM
      g. Proceed to next step
12. Write reference data generator covering ALL features with pinned dependencies
13. Write Stata test suite: every feature tested for both functionality AND fidelity
14. Debug until outputs agree with original package
15. FINAL FIDELITY AUDIT — dispatch multi-agent team to verify full feature parity
16. If gaps found: create new plan (with review loop), implement, re-audit
17. Repeat until audit passes clean
18. Write honest README, package, distribute via net install
```
