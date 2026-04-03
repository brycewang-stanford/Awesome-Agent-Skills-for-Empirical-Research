# Gotchas & Best Practices

## Common Errors

### "Multiple Definitions" Error

**Cause**: Same variable name defined in multiple cells.

```python
# Cell 1
x = 10

# Cell 2 (ERROR!)
x = 20
```

**Solutions**:

1. Use different names:
```python
# Cell 1
x_initial = 10

# Cell 2
x_final = 20
```

2. Use local variables (underscore prefix):
```python
# Cell 1
_x = compute()
result1 = process(_x)

# Cell 2 (OK - _x is local)
_x = compute_other()
result2 = process(_x)
```

3. Combine into one cell if they're related.

### "Cycle Detected" Error

**Cause**: Circular dependency between cells.

```python
# Cell 1
a = b + 1  # References b

# Cell 2
b = a + 1  # References a (CYCLE!)
```

**Solution**: Restructure to break the cycle. Usually means the logic should be in one cell.

### UI Element Not Updating

**Cause**: Element not assigned to a global variable.

```python
# WRONG
mo.hstack([mo.ui.slider(0, 10)])  # Anonymous, no reactivity

# CORRECT
slider = mo.ui.slider(0, 10)
mo.hstack([slider])
# Now slider.value works in other cells
```

### Mutations Not Triggering Re-runs

**Cause**: marimo doesn't track object mutations.

```python
# Cell 1
my_list = [1, 2, 3]

# Cell 2 (won't trigger updates to cells reading my_list)
my_list.append(4)
```

**Solutions**:

1. Mutate in the same cell that defines:
```python
# Cell 1
my_list = [1, 2, 3]
my_list.append(4)  # Same cell, OK
```

2. Create new variable:
```python
# Cell 2
my_list_extended = my_list + [4]
```

3. For DataFrames, use `.assign()`:
```python
df_new = df.assign(new_col=values)
```

### on_change Handler Not Called

**Cause**: Element not bound to global variable.

```python
# WRONG
mo.vstack([
    mo.ui.button(on_change=lambda _: print("clicked"))
    for _ in range(5)
])

# CORRECT - use mo.ui.array
buttons = mo.ui.array([
    mo.ui.button(on_change=lambda _: print("clicked"))
    for _ in range(5)
])
```

### Loop Closure Bug

**Cause**: Python late binding in loops.

```python
# WRONG - all print 9
buttons = mo.ui.array([
    mo.ui.button(on_change=lambda v: print(i))
    for i in range(10)
])

# CORRECT - bind i explicitly
buttons = mo.ui.array([
    mo.ui.button(on_change=lambda v, i=i: print(i))
    for i in range(10)
])
```

### SQL Brackets Issue

**Cause**: `{}` in SQL interpreted as f-string.

```python
# WRONG
mo.sql(f"SELECT {'a': 1}")  # SyntaxError

# CORRECT - double braces
mo.sql(f"SELECT {{'a': 1}}")
```

## Expensive Notebooks

### Problem: Cells Run Too Often

Every change triggers reactive re-runs.

**Solutions**:

1. **Lazy runtime**: Settings > Runtime > On cell change: "lazy"
   - Cells marked stale instead of auto-running

2. **Disable cells**: Right-click > Disable
   - Cell and descendants won't run

3. **Use forms**: Gate execution on submit
```python
config = mo.ui.text().form()
# Only updates on submit
```

4. **Use mo.stop()**:
```python
run_button = mo.ui.run_button()
mo.stop(not run_button.value)
expensive_operation()
```

5. **Cache results**:
```python
@mo.cache
def expensive(x):
    return heavy_computation(x)
```

6. **Persistent cache**:
```python
with mo.persistent_cache("my_cache"):
    result = very_expensive()
# Cached to disk, survives restarts
```

### Memory Management

Can't reassign to free memory (unique variable rule).

**Solutions**:

1. Use `del`:
```python
large_data = load_huge_file()
processed = process(large_data)
del large_data  # Free memory
```

2. Encapsulate in functions:
```python
def _():
    large = load_huge()
    return summarize(large)
    # large goes out of scope

summary = _()
```

## Best Practices

### Code Organization

- Put imports in first cell
- Helper functions can go at bottom (execution order is by dependencies)
- Use markdown cells to structure narrative

### Variable Naming

- Meaningful names for globals (they persist)
- `_temp` for throwaway values
- Avoid single letters except in tight loops

### UI Design

- Group related UI in forms
- Use `mo.stop()` for step-by-step workflows
- Embed UI in markdown for clean layouts

### Data Work

- Use SQL cells for queries (cleaner than pandas)
- `mo.ui.table()` for selectable data
- Cache expensive data loads

### Testing

Define tests in cells:

```python
def test_my_function():
    assert my_function(1) == 2
```

### Version Control

- Notebooks are `.py` files - git-friendly
- Include `layouts/` folder for grid layouts
- Use inline dependencies for reproducibility:
```python
# /// script
# dependencies = ["pandas", "altair"]
# ///
```

## Debugging

### Print Debugging

`print()` output appears below cells.

### Debugger

```python
breakpoint()  # or import pdb; pdb.set_trace()
```

Works in terminal where marimo is running.

### Visualize Dataflow

Sidebar > Variables panel shows dependency graph.

### Check Cell Order

Remember: execution order is by dependencies, not position.

## Migration from Jupyter

### Common Issues

1. **Out-of-order execution**: Jupyter habits don't work
2. **Variable reuse**: Can't redefine globals
3. **Stateful code**: Hidden state won't exist

### Automatic Conversion (Inbound)

```bash
# marimo convert imports OTHER formats INTO marimo (inbound only)
marimo convert notebook.ipynb -o notebook.py
# To export FROM marimo, use: marimo export md notebook.py, marimo export html notebook.py
```

Then review and fix:
- Split cells that define same variable
- Remove mutation patterns
- Add reactivity (UI elements)

## Summary Checklist

| Issue | Solution |
|-------|----------|
| Multiple definitions | Rename or use `_local` |
| Cycle detected | Restructure dependencies |
| UI not reactive | Assign to global variable |
| Mutation not tracked | Mutate in same cell or create new var |
| Expensive re-runs | Cache, forms, mo.stop(), lazy mode |
| Memory issues | del, encapsulate in functions |
| Loop closures | Bind with `i=i` in lambda |
