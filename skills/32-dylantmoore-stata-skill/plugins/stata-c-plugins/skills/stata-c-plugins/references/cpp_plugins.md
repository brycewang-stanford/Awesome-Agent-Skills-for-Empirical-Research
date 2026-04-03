# C++ Plugins for Stata

Practical guidance for building Stata plugins in C++. **Wrapping an existing C++ library is the most common use case.** If a C++ implementation of your algorithm exists, prefer wrapping it — you get identical output, the same performance, and far less code to write and maintain. This file covers the patterns you need.

## When to Use C++

- **An existing C++ implementation exists.** This is the most common case and should always be your first check. If you're translating an R package that has a C++ backend in `src/`, or a standalone C++ library exists for the algorithm, wrap it. You get identical output (same code path), same performance, and a fraction of the code. **Prefer wrapping over reimplementing.** Only reimplement from scratch if no C++ backend exists, the backend has unmanageable dependencies, or its API is too poorly documented to wrap efficiently.
- **A standalone C++ library does what you need.** RapidFuzz for string matching, Eigen for linear algebra, nlohmann/json for config parsing, etc. Header-only libraries are especially easy — vendor the headers and add `-I`.
- **Complex data structures.** Trees, graphs, hash maps, priority queues — `std::map`, `std::unordered_map`, `std::priority_queue` are battle-tested.
- **Threading with `std::thread`/`std::async`.** Simpler than raw pthreads for many use cases.

## When C Is Fine

Use C only when no C++ backend or library exists and the algorithm is simple arrays-and-loops logic. The C approach in the main SKILL.md covers this case.

## The `extern "C"` Pattern

Stata loads plugins by looking for a function named `stata_call` with C linkage. C++ name-mangles all functions by default, so Stata can't find them. The fix is `extern "C"`.

```cpp
// wrapper.cpp
#include "stplugin.h"
#include <vector>
#include <stdexcept>
#include "my_algorithm.h"  // your C++ code or vendored library

extern "C" {

STDLL stata_call(int argc, char *argv[]) {
    try {
        if (argc < 2) {
            SF_error("myplugin requires 2 arguments\n");
            return 198;
        }

        int n = atoi(argv[0]);
        int seed = atoi(argv[1]);
        ST_int nobs = SF_nobs();
        ST_int nvars = SF_nvar();

        // Use C++ containers instead of malloc
        std::vector<double> X(nobs * (nvars - 1));
        std::vector<double> results(nobs);

        // Read from Stata (1-indexed)
        ST_double val;
        for (ST_int obs = 1; obs <= nobs; obs++) {
            for (int j = 0; j < nvars - 1; j++) {
                SF_vdata(j + 1, obs, &val);
                X[(obs - 1) * (nvars - 1) + j] = val;
            }
        }

        // Call C++ library
        MyAlgorithm algo(n, seed);
        algo.fit(X.data(), nobs, nvars - 1);
        algo.predict(X.data(), results.data(), nobs);

        // Write back to Stata
        for (ST_int obs = 1; obs <= nobs; obs++) {
            SF_vstore(nvars, obs, results[obs - 1]);
        }

        return 0;

    } catch (const std::exception &e) {
        char buf[512];
        snprintf(buf, sizeof(buf), "myplugin error: %s\n", e.what());
        SF_error(buf);
        return 909;
    } catch (...) {
        SF_error("myplugin: unknown error\n");
        return 909;
    }
}

}  // extern "C"
```

Key points:
- Only `stata_call` needs `extern "C"`. All other functions can be normal C++.
- The `extern "C"` block can wrap just the one function, or you can use `extern "C" STDLL stata_call(...)` on the declaration directly.
- Everything inside `stata_call` can use C++ freely: templates, classes, STL, exceptions (as long as they're caught).

## Handling `stplugin.c`

`stplugin.c` is C code. You have two options:

**Option 1 (recommended): Compile separately.**
```bash
gcc -c -O3 -fPIC -DSYSTEM=APPLEMAC stplugin.c -o stplugin.o
g++ -O3 -std=c++17 -fPIC -DSYSTEM=APPLEMAC -bundle -o plugin.plugin wrapper.cpp stplugin.o
```

**Option 2: Include with `extern "C"` trick.**
```cpp
// At the top of wrapper.cpp, before any C++ headers
extern "C" {
#include "stplugin.c"
}
```

Option 1 is cleaner and avoids any issues with C constructs that aren't valid C++. Option 2 works but can break if `stplugin.c` uses anything C++-incompatible.

## Exception Safety

**Uncaught exceptions escaping `stata_call` crash Stata instantly.** No error message, no recovery, the user loses all unsaved work. This is the single most important rule for C++ plugins.

Always wrap the entire body of `stata_call` in try/catch:

```cpp
extern "C" {
STDLL stata_call(int argc, char *argv[]) {
    try {
        // ALL your code here
        return 0;
    } catch (const std::bad_alloc &e) {
        SF_error("myplugin: out of memory\n");
        return 909;
    } catch (const std::exception &e) {
        char buf[512];
        snprintf(buf, sizeof(buf), "myplugin: %s\n", e.what());
        SF_error(buf);
        return 909;
    } catch (...) {
        SF_error("myplugin: unknown internal error\n");
        return 909;
    }
}
}
```

Catch `std::bad_alloc` separately so you can return Stata's memory error code (909). Catch `std::exception` for anything with a message. Catch `...` as a last resort for non-standard exceptions.

## Compilation

Use `g++` instead of `gcc` for the C++ files. `stplugin.c` must be compiled as C. Use whatever `-std=c++` version the library requires (C++11, C++14, C++17 are all common — check the library's docs). The examples below use C++17.

### darwin-arm64 (Apple Silicon Mac)

```bash
gcc -c -O3 -fPIC -DSYSTEM=APPLEMAC -arch arm64 stplugin.c -o stplugin.o
g++ -O3 -std=c++17 -fPIC -DSYSTEM=APPLEMAC -arch arm64 -bundle \
    -o myplugin.darwin-arm64.plugin wrapper.cpp stplugin.o -lm
```

### darwin-x86_64 (Intel Mac)

```bash
gcc -c -O3 -fPIC -DSYSTEM=APPLEMAC -target x86_64-apple-macos10.12 stplugin.c -o stplugin.o
g++ -O3 -std=c++17 -fPIC -DSYSTEM=APPLEMAC -target x86_64-apple-macos10.12 -bundle \
    -o myplugin.darwin-x86_64.plugin wrapper.cpp stplugin.o -lm
```

### linux-x86_64

```bash
gcc -c -O3 -fPIC -DSYSTEM=OPUNIX stplugin.c -o stplugin.o
g++ -O3 -std=c++17 -fPIC -DSYSTEM=OPUNIX -shared \
    -static-libstdc++ -static-libgcc \
    -o myplugin.linux-x86_64.plugin wrapper.cpp stplugin.o -lm
```

Static linking (`-static-libstdc++ -static-libgcc`) is important for Linux so end users don't need a compatible `libstdc++` installed.

**macOS users:** There is no native Linux cross-compiler on macOS. Run these commands inside a Docker container (see the Docker approach in the main SKILL.md Cross-Platform Compilation section).

### windows-x86_64 (cross-compile from Mac/Linux)

Install the cross-compiler first: `brew install mingw-w64`.

```bash
x86_64-w64-mingw32-gcc -c -O3 -DSYSTEM=STWIN32 stplugin.c -o stplugin.o
x86_64-w64-mingw32-g++ -O3 -std=c++17 -DSYSTEM=STWIN32 -shared \
    -static-libstdc++ -static-libgcc \
    -o myplugin.windows-x86_64.plugin wrapper.cpp stplugin.o -lm
```

Note the Windows flags: `-static-libstdc++ -static-libgcc` statically links the C++ runtime so users don't need to install anything extra.

### With header-only libraries (e.g., Eigen)

Just add the include path:

```bash
g++ -O3 -std=c++17 -fPIC -DSYSTEM=APPLEMAC -arch arm64 -bundle \
    -I./eigen -o myplugin.darwin-arm64.plugin wrapper.cpp stplugin.o -lm
```

No linking step needed for header-only libraries.

## Shipping

No difference from C plugins. The output is a single `.plugin` binary per platform, same naming convention (`pluginname.platform.plugin`), same `.ado` wrapper, same `.pkg` distribution.

- Header-only C++ libraries are compiled into the binary. No runtime dependency.
- **Always use `-static-libstdc++ -static-libgcc` on Windows and Linux.** This statically links the C++ runtime so end users don't need anything installed. Do this for every C++ plugin, no exceptions.
- Users cannot tell whether a plugin was written in C or C++. The `.plugin` file is opaque.
- Same cascade loading pattern, same `net install` distribution.
- **Binary size is not a concern.** Expected sizes: macOS ~100-300K, Linux ~1-2MB, Windows ~2-15MB (fully static). These are normal. Users care about correct results, not plugin file size. Ship all platforms with all dependencies statically linked.

## Wrapping an Existing C++ Library

**This is the primary use case for C++ plugins and should be your default approach.** If a C++ implementation exists — whether from an R package's `src/` directory, a standalone library, or a header-only library — wrap it. Do not reimplement the algorithm in C or C++ from scratch.

### Finding C++ Backends

- **R packages:** Check `src/` on GitHub or in the CRAN source tarball. Many R packages use Rcpp and have their algorithms in `.cpp` files. Look for R packages with a `src/` directory containing C++ code — these are wrapping candidates.
- **Python packages:** Look for Cython (`.pyx` files), C extensions, or vendored C/C++ code. Check `setup.py` or `pyproject.toml` for compiled extension definitions.
- **Standalone C++ libraries:** Search GitHub for `<algorithm-name> cpp` or `<algorithm-name> header-only`. Some algorithms have reference implementations as standalone C++ projects.

### Steps

1. **Clone or vendor the source** into your project (e.g., `c_plugin/lib/`).
2. **Identify the library's API.** Find the main classes/functions: typically a constructor, a `fit()`/`train()` method, and a `predict()` method.
3. **Write a thin `stata_call` wrapper** that:
   - Reads data from Stata with `SF_vdata()`
   - Converts to whatever format the library expects (arrays, Eigen matrices, custom structs)
   - Calls the library's training/prediction functions
   - Writes results back with `SF_vstore()`
4. **The `.ado` wrapper handles all Stata syntax.** The C++ just does computation. Users interact with Stata syntax, not the plugin directly.

### Example: Wrapping a library that uses Eigen

```cpp
// wrapper.cpp
#include "stplugin.h"
#include <Eigen/Dense>
#include "library_api.h"

extern "C" {
STDLL stata_call(int argc, char *argv[]) {
    try {
        ST_int nobs = SF_nobs();
        int p = SF_nvar() - 1;  // last var is output

        // Read into Eigen matrix
        Eigen::MatrixXd X(nobs, p);
        ST_double val;
        for (ST_int i = 0; i < nobs; i++) {
            for (int j = 0; j < p; j++) {
                SF_vdata(j + 1, i + 1, &val);  // 1-indexed!
                X(i, j) = val;
            }
        }

        // Call library
        Eigen::VectorXd result = library_compute(X);

        // Write back
        int out_var = SF_nvar();
        for (ST_int i = 0; i < nobs; i++) {
            SF_vstore(out_var, i + 1, result(i));
        }

        return 0;
    } catch (const std::exception &e) {
        char buf[512];
        snprintf(buf, sizeof(buf), "plugin error: %s\n", e.what());
        SF_error(buf);
        return 909;
    } catch (...) {
        SF_error("plugin: unknown error\n");
        return 909;
    }
}
}
```

## Using C++ Standard Library Features

When writing a plugin from scratch in C++ (rather than wrapping a library), the standard library gives you safer, simpler code than C equivalents:

- **`std::vector<double>`** instead of `malloc`/`free` -- automatic cleanup even on exceptions, bounds checking with `.at()`, no manual size tracking.
- **`std::sort`** instead of `qsort` -- type-safe, usually faster (inlines the comparator).
- **`std::thread`/`std::async`** for parallelism -- simpler than pthreads for independent work units. **Important:** never call Stata SDK functions (`SF_vdata`, `SF_vstore`, `SF_display`, etc.) from worker threads. Read all data on the main thread, dispatch computation to workers, then write results back on the main thread. Join all threads before returning from `stata_call`.
- **`std::unordered_map`** for hash tables -- no need to write your own.
- **`std::string`** for string handling -- no buffer overflow risk from `sprintf`.

But keep it simple. This is a Stata plugin, not a framework. Use the standard library where it makes code safer or shorter, not for the sake of being "modern C++."

## Caveats

- **Template errors produce unreadable compiler output.** This is especially painful when using Eigen or other template-heavy libraries. Focus on the first error and fix it — later errors are often cascading noise.
- **Always use `-static-libstdc++ -static-libgcc` on Windows and Linux** so users don't need a compatible C++ runtime. This is mandatory, not optional.
- **Debugging is the same challenge as C plugins.** You still can't attach a debugger to Stata's plugin host. Use `SF_display()`, log files, and standalone test harnesses (see Debugging section in main SKILL.md).
- **ABI compatibility matters.** If you compile the library with one compiler version and the wrapper with another, you can get silent corruption. Use the same compiler for everything.
