# Reactivity & Cell Execution

## Core Concept

marimo notebooks are **reactive**: when you run a cell, marimo automatically runs all cells that depend on variables it defines. This eliminates hidden state and ensures outputs always match code.

## How It Works

### Static Analysis

marimo analyzes each cell to determine:
- **Definitions**: Global variables the cell defines
- **References**: Global variables the cell reads

This creates a **directed acyclic graph (DAG)** of dependencies.

### Execution Rule

> When a cell runs, marimo automatically runs all cells that **reference** any global variables it **defines**.

```python
# Cell 1
x = 10  # Defines 'x'

# Cell 2 (runs automatically when Cell 1 runs)
y = x * 2  # References 'x', defines 'y'

# Cell 3 (runs automatically when Cell 2 runs)
y + 5  # References 'y'
```

### Execution Order

Order is determined by **variable dependencies**, not cell position on the page. You can organize cells however makes sense for your story.

## No Hidden State

### Delete = Scrub

When you delete a cell, marimo **removes its variables from memory**. Cells that referenced those variables are invalidated.

This prevents the classic Jupyter problem: running cells out of order, then being unable to reproduce results.

### Consistent State

Code, outputs, and program state are always synchronized. What you see is what you get.

## Variable Rules

### Unique Global Names

Each global variable must be defined by **exactly one cell**.

```python
# WRONG: Two cells defining 'x'
# Cell 1
x = 10

# Cell 2 (ERROR: multiple definitions)
x = 20
```

Solutions:
1. Use different variable names
2. Use local variables (underscore prefix)
3. Combine into one cell

### Local Variables (Underscore Prefix)

Variables starting with `_` are **local** to a cell:

```python
# Cell 1
_temp = compute_something()
result1 = process(_temp)

# Cell 2 (OK: _temp is local, can reuse name)
_temp = compute_other()
result2 = process(_temp)
```

### Encapsulating with Functions

For many temporary variables, wrap in a function:

```python
def _():
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots()
    ax.plot([1, 2, 3])
    return ax

_()  # Call and display
```

Variables `plt`, `fig`, `ax` stay local to the function.

## Mutations Are Not Tracked

marimo does **not** track mutations to objects.

```python
# Cell 1
my_list = [1, 2, 3]

# Cell 2 (mutation - won't trigger re-runs!)
my_list.append(4)  # Other cells won't see this
```

### Solution: Mutate in Same Cell

```python
# Cell 1: Define AND mutate together
df = pd.DataFrame({"a": [1, 2]})
df["b"] = df["a"] * 2  # Same cell, OK
```

### Solution: Create New Variables

```python
# Cell 1
df = pd.DataFrame({"a": [1, 2]})

# Cell 2
df_with_b = df.assign(b=df["a"] * 2)  # New variable
```

## Runtime Configuration

### Disable Automatic Execution

In notebook settings, you can set runtime to **lazy** mode:
- Cells are marked **stale** instead of auto-running
- You control when to run
- Useful for expensive computations

### On-Startup Behavior

Configure whether to auto-run all cells when opening a notebook.

## Controlling Execution

### Disable Cells

Right-click a cell to disable it. Disabled cells (and their descendants) won't run.

Use case: Temporarily skip expensive computation while iterating.

### Stop Execution

Use `mo.stop()` to conditionally halt execution:

```python
mo.stop(not data_loaded, mo.md("Please load data first"))
# Code below only runs if data_loaded is True
process(data)
```

### Caching

For expensive operations:

```python
@mo.cache
def expensive_function(x):
    # Result cached based on arguments
    return heavy_computation(x)
```

Persistent cache (survives restarts):

```python
with mo.persistent_cache("my_cache"):
    result = expensive_operation()
```

## Type Annotations

Type annotations **are** tracked as references (for Pydantic, etc.):

```python
# Cell 1
class MyModel: pass

# Cell 2 (references MyModel)
def process(x: MyModel): pass
```

To exclude from dataflow, use string annotations:

```python
def process(x: "MyModel"): pass  # Not tracked
```

## Visualizing Dataflow

Use the **dependency graph** view in the editor to see how cells connect:
- Sidebar > Variables panel
- Click a variable to see its flow
- Helps debug unexpected behavior

## Summary

| Concept | Behavior |
|---------|----------|
| Run a cell | Dependent cells auto-run |
| Delete a cell | Variables scrubbed from memory |
| Global variables | Must be unique across cells |
| `_variable` | Local to cell, can be reused |
| Mutations | Not tracked, keep in same cell |
| Lazy mode | Cells marked stale, manual run |
| `mo.stop()` | Conditionally halt execution |
| `@mo.cache` | Cache expensive results |
