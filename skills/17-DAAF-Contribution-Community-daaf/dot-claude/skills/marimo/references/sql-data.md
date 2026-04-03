# SQL, DataFrames & Plotting

## SQL Cells

### Setup

Install SQL dependencies:

```bash
pip install "marimo[sql]"
# Includes: duckdb, polars
```

### Creating SQL Cells

1. Right-click "+" button > "SQL cell"
2. Or convert empty cell via context menu
3. Or click SQL button at bottom of notebook

### Basic Query

```python
# SQL cell (syntactic sugar for mo.sql())
result_df = mo.sql(f"SELECT * FROM my_table LIMIT 10")
```

The output variable (`result_df`) is a Polars DataFrame (or Pandas if Polars not installed).

### Query Python DataFrames

Reference any DataFrame variable directly:

```python
# Cell 1: Create DataFrame
users = pd.DataFrame({"name": ["Alice", "Bob"], "age": [30, 25]})

# Cell 2: Query it with SQL
active_users = mo.sql(f"""
    SELECT * FROM users WHERE age > 25
""")
```

### Parameterized Queries

Use f-strings to inject Python values:

```python
min_age = mo.ui.slider(0, 100, value=21)

filtered = mo.sql(f"""
    SELECT * FROM users WHERE age >= {min_age.value}
""")
```

### Escape Brackets

For literal `{}` in SQL (like JSON), double them:

```python
mo.sql(f"""
    SELECT unnest([{{'a': 42}}, {{'b': 84}}])
""")
```

### Query Files

```sql
-- CSV
SELECT * FROM read_csv('data.csv')

-- Parquet
SELECT * FROM read_parquet('data.parquet')

-- HTTP
SELECT * FROM 'https://example.com/data.csv'

-- S3
SELECT * FROM 's3://bucket/file.parquet'
```

### Output Types

Configure in app settings:
- `native` - DuckDB lazy relation (best performance)
- `polars` - Eager Polars DataFrame
- `lazy-polars` - Lazy Polars DataFrame
- `pandas` - Pandas DataFrame
- `auto` - Auto-detect based on installed packages

## Database Connections

### Via UI

Click "Add Database Connection" in notebook to configure:
- PostgreSQL
- MySQL
- SQLite
- DuckDB
- Snowflake
- BigQuery

### Via Code

```python
# SQLAlchemy
import sqlalchemy
engine = sqlalchemy.create_engine("postgresql://user:pass@host/db")

# SQLite
engine = sqlalchemy.create_engine("sqlite:///my_database.db")

# DuckDB file
import duckdb
conn = duckdb.connect("my_data.duckdb")
```

marimo auto-discovers engines and shows them in SQL cell dropdown.

### Supported Databases

PostgreSQL, MySQL, SQLite, DuckDB, Snowflake, BigQuery, ClickHouse, Databricks, Oracle, SQL Server, and many more via SQLAlchemy/Ibis.

## DataFrames

### Interactive Viewer

Any DataFrame as cell output gets an interactive viewer:
- Pagination
- Sorting
- Column filtering
- Search

```python
df  # Just output the DataFrame
```

### Table with Selection

```python
table = mo.ui.table(df, selection="multi")
table

# In another cell:
selected_rows = table.value  # List of selected row dicts
```

### No-Code Transformer

```python
transformer = mo.ui.dataframe(df)
transformer

# Get transformed result:
transformed_df = transformer.value
```

### Data Editor

```python
editor = mo.ui.data_editor(df)
editor

# Get edited data:
edited_df = editor.value
```

## Plotting

marimo supports all major Python plotting libraries.

### Altair (Recommended)

Interactive by default, supports selections:

```python
import altair as alt

chart = alt.Chart(df).mark_point().encode(
    x='x:Q',
    y='y:Q',
    color='category:N'
)
chart
```

#### Reactive Selection

```python
brush = alt.selection_interval()

chart = alt.Chart(df).mark_point().encode(
    x='x:Q',
    y='y:Q',
    color=alt.condition(brush, 'category:N', alt.value('lightgray'))
).add_params(brush)

# Wrap for reactivity
reactive_chart = mo.ui.altair_chart(chart)
reactive_chart

# Access selection in another cell:
selected_data = reactive_chart.value  # DataFrame of selected points
```

### Plotly

```python
import plotly.express as px

fig = px.scatter(df, x='x', y='y', color='category')
fig
```

#### Reactive Plotly

```python
reactive_fig = mo.ui.plotly(fig)
reactive_fig

# Access selection:
selected = reactive_fig.value
```

### Matplotlib

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots()
ax.plot(x_data, y_data)
plt.tight_layout()
fig  # or plt.gca()
```

#### Interactive Matplotlib

```python
mo.mpl.interactive(fig)
```

### Seaborn

```python
import seaborn as sns

fig = sns.scatterplot(data=df, x='x', y='y')
plt.gcf()  # Get current figure
```

## Data Sources Panel

The sidebar shows:
- Connected databases
- Available schemas/tables
- Column info

Enable auto-discovery in `pyproject.toml`:

```toml
[tool.marimo.datasources]
auto_discover_schemas = true
auto_discover_tables = "auto"
auto_discover_columns = false  # Can be slow for large DBs
```

## Common Patterns

### Load and Preview

```python
# Cell 1: Load
df = pd.read_csv("data.csv")

# Cell 2: Preview
mo.ui.table(df.head(100), selection=None)
```

### Filter with UI

```python
# Cell 1: UI
category = mo.ui.dropdown(df['category'].unique().tolist())
min_value = mo.ui.slider(df['value'].min(), df['value'].max())

# Cell 2: Filter
filtered = df[
    (df['category'] == category.value) &
    (df['value'] >= min_value.value)
]
```

### SQL + Visualization

```python
# Cell 1: Query
summary = mo.sql(f"""
    SELECT category, AVG(value) as avg_value
    FROM df
    GROUP BY category
""")

# Cell 2: Plot
alt.Chart(summary).mark_bar().encode(
    x='category',
    y='avg_value'
)
```

## Tips

- Use `mo.sql()` output type `native` for large datasets (lazy evaluation)
- Altair charts are most interactive out of the box
- Use `mo.ui.table()` for selectable data
- SQL cells are reactive - they re-run when referenced DataFrames change
