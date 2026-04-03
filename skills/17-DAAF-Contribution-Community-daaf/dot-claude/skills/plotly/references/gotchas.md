# Gotchas & Best Practices

## Plotly Express vs Graph Objects

### The Key Insight

**px functions return go.Figure objects.** You can use all go methods on px figures.

```python
import plotly.express as px

fig = px.scatter(df, x="x", y="y")  # Returns go.Figure
fig.update_layout(title="My Title")  # All go methods work
fig.add_trace(...)                   # Can add more traces
```

### When to Use Each

| Situation | Recommendation |
|-----------|----------------|
| Quick exploration | px |
| Standard charts | px |
| Need full control | go |
| Multiple trace types | go (or px + add_trace) |
| Custom subplots | go + make_subplots |
| Complex animations | go |

### Converting px to go

If you need more control, start with px and modify:

```python
# Start with px
fig = px.scatter(df, x="x", y="y", color="category")

# Access and modify traces
for trace in fig.data:
    trace.marker.size = 15

# Or update all at once
fig.update_traces(marker_size=15)
```

---

## Common Errors

### "No module named 'kaleido'" / write_image fails

**Error**: `ValueError: Image export using the "kaleido" engine requires the kaleido package`

**DAAF context**: kaleido is intentionally excluded from the DAAF container due to
its heavy Chromium dependency (~300MB binary + 9 system shared libraries). Use
**plotnine** for static figure export (PNG/SVG) and reserve Plotly for interactive
HTML output via `write_html()`.

If you need kaleido in a custom environment:

```bash
pip install -U kaleido
```

### Figure Not Displaying

**Problem**: Figure doesn't appear in Jupyter or script.

**Fixes**:

```python
# In scripts, always call show()
fig.show()

# In Jupyter, ensure plotly extension is loaded
# Or explicitly show
fig.show()

# Check renderer
import plotly.io as pio
pio.renderers.default = "notebook"  # For Jupyter
pio.renderers.default = "browser"   # For scripts
```

### Column Not Found

**Error**: `KeyError: 'column_name'`

**Causes**:
- Column name misspelled
- DataFrame doesn't have the column
- Using variable instead of string

```python
# WRONG: using variable name
px.scatter(df, x=column_x, y=column_y)

# CORRECT: using string
px.scatter(df, x="column_x", y="column_y")
```

### Empty or Blank Plot

**Causes**:
- Data has NaN/null values
- Wrong column names
- Data types mismatch

**Fixes**:

```python
# Check your data
print(df.head())
print(df.dtypes)
print(df.isna().sum())

# Drop NaN for plotting
fig = px.scatter(df.dropna(subset=["x", "y"]), x="x", y="y")
```

### Legend Issues

```python
# Hide legend
fig.update_layout(showlegend=False)

# Rename legend entries
fig.update_traces(name="New Name", selector=dict(name="Old Name"))

# Hide specific trace from legend
fig.update_traces(showlegend=False, selector=dict(name="Trace Name"))
```

---

## Performance

### Large Datasets

For datasets with >10,000 points, use WebGL rendering:

```python
# Plotly Express automatically uses WebGL for large data
# But you can force it with go.Scattergl

import plotly.graph_objects as go

fig = go.Figure(go.Scattergl(  # Note: Scattergl, not Scatter
    x=large_x,
    y=large_y,
    mode="markers"
))
```

### Performance Tips

| Points | Recommendation |
|--------|----------------|
| < 1,000 | Standard Scatter works fine |
| 1,000 - 100,000 | Use Scattergl |
| > 100,000 | Sample data or aggregate |

### Reduce Data

```python
# Sample for exploration
fig = px.scatter(df.sample(1000), x="x", y="y")

# Aggregate for visualization
df_agg = df.groupby("category").mean().reset_index()
fig = px.bar(df_agg, x="category", y="value")
```

### Disable Animations

```python
fig.update_layout(transition_duration=0)
```

---

## Data Type Issues

### Categorical vs Numeric

```python
# Problem: Numeric treated as categorical
fig = px.scatter(df, x="year", y="value")  # year=2020 might be categorical

# Fix: Ensure correct type
df["year"] = df["year"].astype(int)

# Or explicitly set axis type
fig.update_xaxes(type="linear")  # Force numeric
fig.update_xaxes(type="category")  # Force categorical
```

### Date/Time

```python
# Ensure dates are datetime type
df["date"] = pd.to_datetime(df["date"])

# Plotly handles datetime automatically
fig = px.line(df, x="date", y="value")

# Format date axis
fig.update_xaxes(tickformat="%Y-%m-%d")
```

---

## Subplot Gotchas

### Row/Col Indexing

Subplots use 1-based indexing:

```python
# CORRECT: row=1, col=1 for top-left
fig.add_trace(trace, row=1, col=1)

# WRONG: 0-based indexing
fig.add_trace(trace, row=0, col=0)  # Error!
```

### Updating Specific Axes

```python
# Update specific subplot axes
fig.update_xaxes(title_text="X", row=1, col=1)
fig.update_yaxes(title_text="Y", row=1, col=1)

# Without row/col, updates ALL axes
fig.update_xaxes(showgrid=False)  # All x-axes
```

### Secondary Y-Axis

Must be declared in make_subplots:

```python
from plotly.subplots import make_subplots

fig = make_subplots(specs=[[{"secondary_y": True}]])

fig.add_trace(go.Scatter(...), secondary_y=False)
fig.add_trace(go.Bar(...), secondary_y=True)
```

---

## Styling Gotchas

### Color in aes vs Fixed Color

```python
# Map color to data (in aes)
fig = px.scatter(df, x="x", y="y", color="category")

# Fixed color for all points (outside aes)
fig = px.scatter(df, x="x", y="y")
fig.update_traces(marker_color="red")
```

### Template Overrides

Templates set defaults; explicit settings override:

```python
fig = px.scatter(df, x="x", y="y", template="plotly_dark")
fig.update_layout(paper_bgcolor="white")  # Overrides template
```

### Legend Order

```python
# Control order via category_orders
fig = px.bar(df, x="cat", y="val", color="group",
             category_orders={"group": ["A", "B", "C"]})
```

---

## Best Practices

### 1. Start with px, Customize with go Methods

```python
fig = (
    px.scatter(df, x="x", y="y", color="cat")
    .update_traces(marker_size=10)
    .update_layout(title="My Plot")
)
```

### 2. Use Templates for Consistency

```python
import plotly.io as pio
pio.templates.default = "plotly_white"
```

### 3. Save Output

```python
fig.write_html("plot.html")           # Interactive (primary export in DAAF)
# fig.write_image() is NOT available — kaleido not installed
# Use plotnine for static PNG/SVG figures in reports
```

### 4. Use Meaningful Hover Templates

```python
fig.update_traces(
    hovertemplate="<b>%{x}</b><br>Value: %{y:.2f}<extra></extra>"
)
```

### 5. Check Data Before Plotting

```python
# Always verify
print(df.shape)
print(df.dtypes)
print(df.isna().sum())
```

---

## Quick Fixes

| Problem | Solution |
|---------|----------|
| Plot not showing | `fig.show()` or check renderer |
| Image export fails | Not available in DAAF (no kaleido); use plotnine for static images |
| Wrong colors | Check `color=` vs `marker_color=` |
| Axis wrong type | `fig.update_xaxes(type="linear")` |
| Slow with big data | Use `go.Scattergl` |
| Legend unwanted | `showlegend=False` |
| Grid lines ugly | `showgrid=False` |
| Title not centered | `title=dict(x=0.5)` |
| Overlapping labels | `tickangle=45` |
| Too much whitespace | Adjust `margin=dict(...)` |
