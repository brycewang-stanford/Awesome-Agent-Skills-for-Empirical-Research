---
name: stata-c-plugins
description: >-
  Develop high-performance C/C++ plugins for Stata using the stplugin.h SDK.
  Use when the user asks to create a Stata plugin, write C/C++ code for Stata,
  accelerate a Stata command with C, build cross-platform Stata plugins,
  or translate/port a Python or R package into Stata. Covers the full
  lifecycle: SDK setup, data flow, memory safety, .ado wrappers with
  preserve/merge, cross-platform compilation, performance optimization
  (pthreads, pre-sorted indices, XorShift RNG), debugging, and distribution
  via net install. Also includes a translation workflow for porting Python/R
  packages to Stata — wrapping existing C++ backends when available, or
  writing C from scratch when not.
---

# Stata C/C++ Plugin Development

Build high-performance C/C++ plugins for Stata. This skill covers the full lifecycle from SDK setup through cross-platform distribution, based on real experience building production Stata plugins for statistical imputation, random forests, string matching, and causal inference.

**This skill assumes macOS (Apple Silicon or Intel) as the development platform.** Build commands, cross-compilation workflows, and Docker instructions are all Mac-oriented. The plugins themselves target all four platforms (macOS ARM64, macOS x86_64, Linux x86_64, Windows x86_64), but the *development environment* is macOS. If you need to develop on Linux or Windows natively, adapt the compilation and Docker sections accordingly.

## How to Approach Every Task

**Before writing any code, enter plan mode.** A good plan covers:

1. **Complete inventory** — every feature, option, and component to build (for translation: exhaustive catalog of the source package's API)
2. **Architecture decisions** — wrap C++ backend vs. write C from scratch vs. pure Stata
3. **Relevant reference files** — identify up front which of this skill's reference files contain info you'll need, and cite them explicitly in the plan steps so they get loaded at the right time:
   - `references/translation_workflow.md` — full translation workflow, test repurposing, fidelity audit
   - `references/testing_strategy.md` — test layers, reference data generation, Layer 0 (repurpose original tests)
   - `references/performance_patterns.md` — pthreads, XorShift RNG, quickselect, pre-sorted indices
   - `references/packaging_and_help.md` — .toc/.pkg/.sthlp templates, build scripts
   - `references/cpp_plugins.md` — C++ wrapping, extern "C", exception safety, compilation
4. **Phase-by-phase steps** with dependencies between them
5. **For each step:** what gets built, what tests get written, and that the review loop runs before proceeding
6. **For translation projects:** a final fidelity audit as the last step (see `translation_workflow.md`)

**Implement sequentially across components, in parallel within each component.** Once an interface is defined, dispatch independent sub-tasks as parallel subagents (e.g., C plugin implementation, .ado wrapper, and test suite can run simultaneously). Merge their work, run the full test suite, then proceed to the review loop before moving to the next component.

**Run the review loop after every component:**
- Default: dispatch 2-3 review agents in parallel, ideally from different models (e.g., Claude + GPT + Gemini) for diversity of perspective. Use whatever multi-model tools are available in your environment.
- If only one model is available: dispatch 2-3 agents with different review focuses (correctness, completeness, architecture). Different prompts approximate the diversity of different models.
- Each agent reviews the diff, test results, and requirements — instruction: "List any gaps, bugs, or issues. Say LGTM if everything looks correct."
- Fix all issues raised, re-dispatch, loop until all agents say LGTM. Then proceed.

## Wrap First, Write From Scratch Second

**When translating a package, always check for an existing C/C++ backend before writing any algorithm code.** Many R packages have C++ in `src/`. Many Python packages have Cython or vendored C/C++ libraries. Standalone C++ libraries exist for string matching, linear algebra, tree algorithms, and more.

**If a C++ implementation exists, wrap it.** Do not reimplement the algorithm in C. Wrapping gives you identical output (same code path), production-grade performance, and a fraction of the code. The plugin is just a thin `extern "C"` glue layer between Stata's SDK and the library's API. Binary size is irrelevant — statically link everything (`-static-libstdc++ -static-libgcc`) and ship whatever size the binary turns out to be, even 10-15 MB on Windows. Users don't care about plugin file size; they care about correct results.

See `references/cpp_plugins.md` for the full pattern and `references/translation_workflow.md` for the workflow. Working examples of this approach (wrapping C++ backends, multi-plugin dispatching, save/load for scoring on new data) can be found in the repos listed in the project CLAUDE.md under "Example Applications."

For translation projects, also: repurpose the original package's test suite and data (see `references/testing_strategy.md` Layer 0), write additional Stata-specific tests, and end the plan with a multi-agent fidelity audit. See `references/translation_workflow.md` for the complete workflow.

## The Plugin SDK

Download `stplugin.h` and `stplugin.c` from: https://www.stata.com/plugins/

These two files define the interface between your C code and Stata:

| Function/Macro | Purpose |
|---------------|---------|
| `SF_vdata(var, obs, &val)` | Read variable value (1-indexed!) |
| `SF_vstore(var, obs, val)` | Write variable value (1-indexed!) |
| `SF_nobs()` | Number of observations in current dataset |
| `SF_nvar()` | Number of variables in the **entire dataset** (not just plugin call) |
| `SF_is_missing(val)` | Check for Stata missing value (`.`) |
| `SV_missval` | The missing value constant |
| `SF_display(msg)` | Print informational text in Stata |
| `SF_error(msg)` | Print red error text in Stata |

**Indexing is 1-based.** Both variable indices and observation indices start at 1, not 0. Off-by-one errors here are silent and catastrophic — you read the wrong variable's data with no warning.

## Memory Safety

**A crash in your plugin kills the entire Stata session.** No save prompt, no recovery. The user loses all unsaved work. This is the single most important thing to internalize.

- Check every `malloc()`/`calloc()` return for `NULL`
- Validate `argc` before accessing `argv[]`
- Build with `-fsanitize=address` during development
- Test on small data first, scale up gradually
- Pre-allocate all memory upfront in `stata_call()`, free at the end

## The stata_call() Entry Point

Every plugin implements one function. **Plugins can also be written in C++** — the entry point just needs `extern "C"` linkage so Stata can find it; everything else can be full C++. The obvious case for C++ is when existing C++ code is available to wrap (e.g., an R package's `src/` directory). C++ also helps when you need complex data structures or threading via `std::thread`. For practical C++ guidance — the `extern "C"` pattern, exception safety, compilation commands, wrapping libraries — see `references/cpp_plugins.md`. The rest of this file focuses on C because it's the simpler default.

```c
#include "stplugin.h"

// For C++ plugins, wrap the entry point with extern "C":
//   extern "C" {
//     STDLL stata_call(int argc, char *argv[]) { ... }
//   }

STDLL stata_call(int argc, char *argv[]) {
    // 0. Validate arguments BEFORE accessing argv[]
    if (argc < 3) {
        SF_error("myplugin requires 3 arguments: n_train n_test seed\n");
        return 198;  // Stata's "syntax error" code
    }

    // 1. Parse arguments (all strings — use atoi/atof)
    int n_train = atoi(argv[0]);
    int n_test  = atoi(argv[1]);
    int seed    = atoi(argv[2]);

    // 2. Get dimensions
    ST_int nobs  = SF_nobs();
    // CAUTION: SF_nvar() returns ALL variables in the dataset, not just
    // the ones passed to `plugin call`. If the .ado creates tempvars
    // (touse, merge_id, etc.) the count will be higher than expected.
    // Pass the variable count via argv instead of relying on SF_nvar().
    int p = atoi(argv[3]);  // safer: pass feature count explicitly

    // 3. Allocate memory
    double *X    = calloc(nobs * p, sizeof(double));
    double *y    = calloc(nobs, sizeof(double));
    double *pred = calloc(nobs, sizeof(double));
    if (!X || !y || !pred) {
        SF_error("myplugin: out of memory\n");
        if (X) free(X); if (y) free(y); if (pred) free(pred);
        return 909;
    }

    // 4. Read data from Stata (1-indexed!)
    ST_double val;
    for (ST_int obs = 1; obs <= nobs; obs++) {
        SF_vdata(1, obs, &val);      // var 1 = depvar
        y[obs-1] = val;
        for (int j = 0; j < p; j++) {
            SF_vdata(j + 2, obs, &val);  // vars 2..nvars-1 = features
            X[(obs-1) * p + j] = val;
        }
    }

    // 5. Run your algorithm
    int rc = my_algorithm(X, y, pred, n_train, n_test, p, seed);
    if (rc != 0) {
        SF_error("myplugin: algorithm failed\n");
        free(X); free(y); free(pred);
        return 909;
    }

    // 6. Write results back to Stata
    for (ST_int obs = 1; obs <= nobs; obs++) {
        SF_vstore(nvars, obs, pred[obs-1]);  // last var = output
    }

    free(X); free(y); free(pred);
    return 0;  // 0 = success
}
```

### Return Codes

- `0` — success
- `198` — syntax error (bad arguments)
- `909` — insufficient memory
- `601` — file not found
- Any non-zero triggers a Stata error

## The .ado Wrapper Pattern

Users never call `plugin call` directly. An `.ado` file provides the Stata-native interface.

### The Preserve/Merge Pattern

This is the core pattern for plugins that operate on a subset of data:

```stata
program define mycommand, rclass
    syntax varlist(min=2) [if] [in], GENerate(name) [SEED(integer 12345) REPlace]

    gettoken depvar indepvars : varlist

    if "`replace'" != "" {
        capture drop `generate'
    }
    confirm new variable `generate'

    // Mark sample: novarlist ALLOWS missing depvar (critical for imputation)
    marksample touse, novarlist
    markout `touse' `indepvars'   // but DO exclude missing predictors

    // Stable merge key — create BEFORE any sorting or subsetting
    tempvar merge_id
    quietly gen long `merge_id' = _n

    // Count subsets
    quietly count if `touse' & !missing(`depvar')
    local n_train = r(N)
    quietly count if `touse' & missing(`depvar')
    local n_test = r(N)

    // Create output variable (all missing initially)
    quietly gen double `generate' = .

    // Preserve, subset, call plugin
    preserve
    quietly keep if `touse'

    // Sort if plugin requires it (donors first, test second)
    tempvar sort_order
    quietly gen `sort_order' = missing(`depvar')
    quietly sort `sort_order'

    // Call plugin
    plugin call myplugin `depvar' `indepvars' `generate', ///
        `n_train' `n_test' `seed'

    // Save results and restore
    tempfile results
    quietly keep `merge_id' `generate'
    quietly save `results'
    restore

    // Merge predictions back (update replaces missing with non-missing)
    quietly merge 1:1 `merge_id' using `results', nogenerate update
end
```

**Why `update` works:** The `generate` variable is all-missing before preserve. After restore, it's still all-missing. The `update` option replaces missing values with non-missing ones from the merge file. The `replace` option is handled earlier via `capture drop`, so by merge time the variable is always freshly created.

### Plugin Sorting Contract

**CRITICAL:** Some plugins expect data sorted a specific way (training rows first, test rows second). Others handle missing data internally. Sorting mismatches are among the most dangerous bugs — the plugin silently reads the wrong data, producing garbage output with no error message. A mismatched sort order can drop prediction quality dramatically (e.g., correlation going from 0.99 to 0.38) because the plugin treats test observations as training data and vice versa.

- If the plugin checks `SF_is_missing()` internally: do NOT sort in the .ado wrapper
- If the plugin expects `n_train` contiguous rows then `n_test` rows: sort by `missing(depvar)` before calling

Document which pattern your plugin uses.

### Plugin Loading (Cross-Platform)

Use the **gtools-style OS detection pattern**. This detects the OS via `c(os)` and constructs a bare filename. The bare filename is resolved via Stata's adopath, which is reliable across all platforms.

```stata
/* ---- Load plugin (gtools-style: detect OS, bare filename) ---- */
if ( inlist("`c(os)'", "MacOSX") | strpos("`c(machine_type)'", "Mac") ) local c_os_ macosx
else local c_os_: di lower("`c(os)'")

cap program drop myplugin
program myplugin, plugin using("myplugin_`c_os_'.plugin")
```

This resolves to `myplugin_macosx.plugin`, `myplugin_windows.plugin`, or `myplugin_unix.plugin` depending on platform.

**WARNING — DO NOT use `findfile` + absolute paths.** The following pattern is BROKEN on Windows and must never be used:

```stata
* BROKEN — DO NOT USE
capture findfile myplugin.plugin
capture program myplugin, plugin using("`r(fn)'")
```

`findfile` returns an absolute path (e.g., `C:\ado\plus\m\myplugin.plugin`). On Windows, Stata's `LoadLibrary` call fails when given certain absolute paths via `using()`. The gtools-style pattern avoids this by passing a **bare filename** (no path), which Stata resolves via the adopath — exactly how gtools, ftools, and other major packages work.

Similarly, **do not use a nested if/else cascade** trying each `platform-arch` suffix. This was the old pattern in several packages and fails for the same reason if `findfile` is involved, plus it's fragile and verbose.

**Plugin file naming:** `pluginname_os.plugin` where `os` is one of `macosx`, `unix`, `windows`. Examples: `qrf_plugin_macosx.plugin`, `grf_plugin_windows.plugin`.

**Note:** `clear all` wipes loaded plugin definitions. If a test script starts with `clear all`, all `program ... plugin` definitions are gone. Reload them.

## Cross-Platform Compilation

Build for three platforms (ARM Macs run x86_64 via Rosetta, so one macOS binary suffices). Install the Windows cross-compiler first: `brew install mingw-w64`.

| Target OS | Output name suffix | Compiler | `-D` flag | Link flag | pthreads |
|-----------|-------------------|----------|-----------|-----------|----------|
| macOS (ARM64) | `_macosx` | `gcc -arch arm64` | `-DSYSTEM=APPLEMAC` | `-bundle` | `-pthread` |
| Linux (x86_64) | `_unix` | `gcc` | `-DSYSTEM=OPUNIX` | `-shared` | `-pthread` |
| Windows (x86_64) | `_windows` | `x86_64-w64-mingw32-gcc` | `-DSYSTEM=STWIN32` | `-shared` | `-lwinpthread` |

All platforms: `-O3 -fPIC` for release, add `-g -fsanitize=address` for development.

**For C++ plugins:** use `g++` instead of `gcc`. Add `-std=c++` at the version the library requires (check its docs — C++11, C++14, and C++17 are all common). Header-only C++ libraries can be vendored into `c_source/` and included with `-I.`. Always use `-static-libstdc++ -static-libgcc` on Windows and Linux.

Naming convention: `pluginname_os.plugin` (e.g., `qrf_plugin_macosx.plugin`, `grf_plugin_windows.plugin`). The `os` suffix must match what the gtools-style loader produces: `macosx`, `unix`, or `windows`.

macOS note: use `-bundle`, NOT `-shared`. This is a common mistake.

### Linux from macOS (Docker Required)

There is no native Linux cross-compiler on macOS. Use Docker via Colima (`brew install colima docker`, then `colima start`). Build with a one-liner:

```bash
docker run --rm --platform linux/amd64 -v "$(pwd):/build" -w /build ubuntu:18.04 \
    bash -c "apt-get update -qq && apt-get install -y -qq g++ gcc make > /dev/null 2>&1 && make linux"
```

**glibc compatibility:** Build on Ubuntu 18.04 for maximum compatibility (requires only GLIBC 2.14, works on any Linux from ~2012+). Building on Ubuntu 22.04+ requires GLIBC 2.34, which excludes RHEL 8, Ubuntu 20.04, and many HPC environments.

## Performance Optimization

See `references/performance_patterns.md` for detailed code examples of:

1. **Pre-sorted feature indices** — Sort feature values once, scan linearly at each tree node. O(n) per split instead of O(n log n).
2. **Precomputed distance norms** — Exploit ||a-b||^2 = ||a||^2 + ||b||^2 - 2*a'b for KNN.
3. **Quickselect** — O(n) partial sort for finding k-th nearest neighbor.
4. **Parallel ensemble training (pthreads)** — Train multiple models concurrently. Each thread gets its own data copy and RNG state. **Never call Stata SDK functions (`SF_vdata`, `SF_vstore`, `SF_display`) from worker threads** — read all data on the main thread first, dispatch computation to workers, write results back on the main thread after joining.
5. **XorShift RNG** — C plugins cannot access Stata's internal RNG (`runiform()`). XorShift128+ is fast, statistically sound, and thread-safe (each thread gets its own state). Seed from `argv[]` for reproducibility.
6. **Dense arrays for trees** — Flat node arrays instead of linked lists for cache locality.

## Debugging

Debugging is hard because you can't attach a debugger to Stata's plugin host.

### Strategies

1. **Printf via SF_display():**
   ```c
   char buf[256];
   snprintf(buf, sizeof(buf), "Debug: n=%d, p=%d\n", n, p);
   SF_display(buf);
   ```

2. **Write diagnostic files:**
   ```c
   FILE *f = fopen("plugin_debug.log", "w");
   fprintf(f, "value at [%d][%d] = %f\n", i, j, val);
   fclose(f);
   ```

3. **Test standalone first.** Write a `main()` that reads CSV and calls your algorithm. Debug with normal tools (gdb, valgrind, sanitizers). Then adapt for the plugin interface.

4. **Build with sanitizers during development:** `-g -fsanitize=address`

5. **Check SF_vdata() return values.** It returns `RC` (0=success). Non-zero means invalid obs/var index.

### Common Failure Modes

| Symptom | Likely Cause |
|---------|-------------|
| Stata crashes silently | Segfault: buffer overflow, bad argv access, NULL deref |
| Plugin returns all missing | Wrong variable count, wrong obs indexing, plugin not loaded |
| Results are garbage | Sorting mismatch, 0-vs-1 indexing error, unnormalized inputs |
| "plugin not found" | Wrong filename, `clear all` wiped definition, wrong platform |
| Works on Mac, fails on Linux | Integer size difference, use `int32_t`/`int64_t` from `<stdint.h>` |

## Packaging and Distribution

**Use platform-specific `.pkg` files** so users only download the binary for their OS. Stata's `net install` has no conditional logic, so the way to avoid shipping all 4 binaries to every user is to offer separate packages per platform. All packages install the same `.ado` and `.sthlp` files — only the `.plugin` binary differs.

```
mypackage/
├── stata.toc                          # lists all package variants
├── mypackage.pkg                      # all platforms (for users who don't care)
├── mypackage_mac.pkg                  # macOS only
├── mypackage_linux.pkg                # Linux only
├── mypackage_win.pkg                  # Windows only
├── mycommand.sthlp                    # overview help file (short name!)
├── mycommand.ado                      # user-facing command
├── myplugin_macosx.plugin
├── myplugin_unix.plugin
├── myplugin_windows.plugin
└── c_source/                          # NOT distributed, for building
    ├── build.py
    ├── stplugin.c
    ├── stplugin.h
    └── algorithm.c
```

Users install their platform's package:
```stata
* macOS
net install mypackage_mac, from("https://raw.githubusercontent.com/user/repo/main") replace
* Linux
net install mypackage_linux, from("https://raw.githubusercontent.com/user/repo/main") replace
* Windows
net install mypackage_win, from("https://raw.githubusercontent.com/user/repo/main") replace
```

All platform binaries ship via the all-platform .pkg, or users can install platform-specific packages. Stata loads only the matching plugin at runtime via gtools-style OS detection. Windows C++ binaries can be 10-15MB due to static linking, which is normal.

See `references/packaging_and_help.md` for `.toc`, `.pkg`, `.sthlp` templates and SMCL formatting.

## Common Pitfalls

1. **Sorting destroys merge keys.** If you sort inside `preserve`/`restore`, the merge_id linkage breaks. Always create merge_id BEFORE preserve.

2. **1-indexed everything.** `SF_vdata(var, obs, &val)` — both var and obs start at 1. Off-by-one errors are silent.

3. **`marksample` excludes missing by default.** For imputation (where missing depvar IS the point), use `marksample touse, novarlist`.

4. **macOS `c(os)` returns "MacOSX".** Use the gtools pattern: `inlist("`c(os)'", "MacOSX") | strpos("`c(machine_type)'", "Mac")` to detect Mac. For other platforms, `lower(c(os))` gives `"windows"` or `"unix"`.

5. **argv[] has no bounds checking.** Accessing `argv[3]` when `argc == 2` is a segfault. Always check `argc` first.

6. **`clear all` wipes plugins.** Reload plugin definitions after `clear all` in test scripts.

7. **Only the first `program define` in a .ado file is auto-discovered.** Subprograms need their own .ado files or explicit `run` to load.

8. **Normalize inputs when the algorithm requires it** (neural networks, gradient-based methods, distance-based methods like KNN). Scale to mean=0, sd=1 in the .ado wrapper, denormalize predictions after. The plugin should receive clean, normalized data — let the .ado handle the scaling.

9. **pthreads on Windows needs `-lwinpthread`.** Use conditional linker flags.

10. **Memory errors crash Stata with no recovery.** Pre-allocate everything, check every allocation, build with sanitizers during development.

11. **glibc version mismatch.** Building Linux plugins on a modern distro produces binaries that won't load on older systems. Use Ubuntu 18.04 in Docker for maximum compatibility.

12. **`SF_nvar()` returns total dataset variables.** It counts ALL variables in the dataset, not just the ones in the `plugin call` varlist. If the .ado creates tempvars (`touse`, `merge_id`, sort keys), the count will be higher than expected. Never use `SF_nvar()` to validate argument counts — pass the expected count via `argv` instead.

13. **`findfile` + absolute paths breaks on Windows.** `findfile` returns an absolute path that Stata's `LoadLibrary` can't resolve on Windows. Use the gtools-style OS detection pattern instead (see Plugin Loading section above) — it constructs a bare filename that Stata resolves via the adopath.

## Naming Conventions

- Use `method()` not `model()` for method selection options
- Use `generate()` (abbreviation `gen()`) for output variable naming
- Use `replace` as a flag option, not `replace()`
- Plugin files: `algorithm_plugin_os.plugin` where os is `macosx`, `unix`, or `windows`
- .ado files: lowercase, underscores for multi-word
- Stata option convention: options lowercase, abbreviations capitalized (`GENerate`, `MAXDepth`)
- Target Stata 14.0+ (`version 14.0`) for plugin support
- **Help files use the short command name, not the repo name.** If the repo is called `mypackage_stata`, the overview help file should still be `mypackage.sthlp` (so `help mypackage` works). Don't append "stata" to help file or command names — the user is already in Stata.
