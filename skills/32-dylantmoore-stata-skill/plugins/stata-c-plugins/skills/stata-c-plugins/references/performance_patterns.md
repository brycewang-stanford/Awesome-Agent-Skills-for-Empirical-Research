# C Plugin Performance Patterns

Each pattern below addresses a specific performance bottleneck. Use the one that matches your algorithm's hot path:

| Pattern | Use When | Speedup Source |
|---------|----------|---------------|
| Pre-sorted indices | Tree-based split search | O(n) scan instead of O(n log n) sort per split |
| Precomputed distance norms | KNN or distance-based methods | Avoids redundant norm computation |
| Quickselect | Finding k-th element (KNN neighbors, quantiles) | O(n) expected vs. O(n log n) full sort |
| Parallel training (pthreads) | Ensemble methods (random forests, bagging) | Trains multiple models simultaneously |
| XorShift RNG | Any stochastic algorithm | Fast, thread-safe RNG since Stata's RNG is inaccessible |
| Dense tree arrays | Tree-based methods | Cache locality from contiguous memory |
| Missing data handling | Any plugin that receives Stata data | Correctly interprets Stata's missing value representation |

You don't need all of these. Pick the ones relevant to your algorithm.

## 1. Pre-sorted Feature Indices (Tree Algorithms)

Sort feature values once, then scan linearly at each node:

```c
typedef struct { double val; int idx; } ValIdx;

// Sort once per feature per tree
ValIdx *sorted[n_features];
for (int f = 0; f < n_features; f++) {
    sorted[f] = calloc(n, sizeof(ValIdx));
    for (int i = 0; i < n; i++) {
        sorted[f][i].val = X[i * p + f];
        sorted[f][i].idx = i;
    }
    qsort(sorted[f], n, sizeof(ValIdx), compare_validx);
}

// At each node: scan O(n) through sorted array
// Use bitset to track left/right membership
```

## 2. Precomputed Distance Norms (KNN)

Exploit ||a-b||^2 = ||a||^2 + ||b||^2 - 2*a'b:

```c
// Precompute ||donor||^2 once
double *donor_norms = calloc(n_donors, sizeof(double));
for (int i = 0; i < n_donors; i++) {
    for (int j = 0; j < p; j++) {
        donor_norms[i] += X_donors[i*p + j] * X_donors[i*p + j];
    }
}

// For each test obs: compute dot products, assemble distances
double test_norm = dot(test, test, p);
for (int i = 0; i < n_donors; i++) {
    double dot_val = dot(test, &X_donors[i*p], p);
    dist[i] = test_norm + donor_norms[i] - 2.0 * dot_val;
}
```

## 3. Quickselect for Partial Sorting

O(n) expected time to find k-th smallest (vs O(n log n) full sort):

```c
int quickselect_partition(double *arr, int lo, int hi) {
    double pivot = arr[hi];
    int i = lo;
    for (int j = lo; j < hi; j++) {
        if (arr[j] <= pivot) {
            double tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
            i++;
        }
    }
    double tmp = arr[i]; arr[i] = arr[hi]; arr[hi] = tmp;
    return i;
}

void quickselect(double *arr, int n, int k) {
    int lo = 0, hi = n - 1;
    while (lo < hi) {
        int p = quickselect_partition(arr, lo, hi);
        if (p == k) return;
        else if (p < k) lo = p + 1;
        else hi = p - 1;
    }
}
```

## 4. Parallel Ensemble Training (pthreads)

```c
#include <pthread.h>

typedef struct {
    int model_id;
    double *X, *y;
    int n_train, n_features;
    NeuralNet *model;
    uint64_t seed;
} TrainArgs;

void *train_model(void *arg) {
    TrainArgs *a = (TrainArgs *)arg;
    // Each thread has its own RNG state seeded from a->seed
    // Train model with bootstrap sample
    return NULL;
}

// Launch parallel training
pthread_t threads[n_models];
TrainArgs args[n_models];
for (int m = 0; m < n_models; m++) {
    args[m] = (TrainArgs){m, X, y, n_train, p, models[m], seed + m};
    pthread_create(&threads[m], NULL, train_model, &args[m]);
}
for (int m = 0; m < n_models; m++) {
    pthread_join(threads[m], NULL);
}
```

## 5. XorShift RNG (Fast, Thread-Safe Random Numbers)

C plugins cannot access Stata's internal RNG (`runiform()`, `rnormal()`), so stochastic algorithms need their own. XorShift128+ is ideal because it is fast, has good statistical properties, and each thread can have its own independent state (thread-safe for pthreads). Seed from `argv[]` so the user controls reproducibility.

```c
typedef struct {
    uint64_t state[2];
} RNGState;

static uint64_t xorshift128plus(RNGState *rng) {
    uint64_t s1 = rng->state[0];
    uint64_t s0 = rng->state[1];
    rng->state[0] = s0;
    s1 ^= s1 << 23;
    rng->state[1] = s1 ^ s0 ^ (s1 >> 17) ^ (s0 >> 26);
    return rng->state[1] + s0;
}

static double rand_double(RNGState *rng) {
    return (xorshift128plus(rng) >> 11) / 9007199254740992.0;
}

// Initialize per-thread RNG from seed
void init_rng(RNGState *rng, uint64_t seed) {
    rng->state[0] = seed;
    rng->state[1] = seed ^ 0x6a09e667f3bcc908ULL;
    // Warm up
    for (int i = 0; i < 20; i++) xorshift128plus(rng);
}
```

## 6. Dense Arrays for Tree Structures

Instead of linked lists (which cause cache misses):

```c
typedef struct {
    int is_leaf;
    int split_var;
    double split_val;
    int left_child;   // index into node array
    int right_child;  // index into node array
    double *leaf_values;
    int n_leaf_values;
} TreeNode;

// Allocate all nodes as dense array
TreeNode *nodes = calloc(max_nodes, sizeof(TreeNode));
```

## 7. Missing Data Handling in C

Stata represents missing values as very large doubles. Two patterns:

### Pattern A: Plugin handles missing internally
```c
for (ST_int obs = 1; obs <= nobs; obs++) {
    SF_vdata(1, obs, &val);
    if (SF_is_missing(val)) {
        // This is a test observation — will predict
        test_indices[n_test++] = obs - 1;
    } else {
        // This is a training observation
        y_train[n_train] = val;
        train_indices[n_train++] = obs - 1;
    }
}
```
**.ado wrapper:** Do NOT sort. Let the plugin scan.

### Pattern B: Plugin expects sorted data
The .ado wrapper sorts non-missing first, missing second, and passes counts:
```c
// argv[0] = n_train, argv[1] = n_test
// Rows 1..n_train are donors, rows n_train+1..nobs are test
int n_train = atoi(argv[0]);
int n_test  = atoi(argv[1]);
```
**.ado wrapper:** Sort by `missing(depvar)` before `plugin call`.

Document which pattern your plugin uses.
