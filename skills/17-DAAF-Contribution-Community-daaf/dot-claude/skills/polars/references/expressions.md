# Expressions

Expressions are the core of Polars. They describe transformations on columns.

## Expression Basics

### What is an Expression?

An expression is a function that transforms Series → Series:

```python
pl.col("a")              # Reference column "a"
pl.col("a") + 1          # Add 1 to each value
pl.col("a").sum()        # Aggregate to single value
pl.col("a").alias("b")   # Rename result to "b"
```

Expressions are **lazy**: they describe transformations but don't execute until placed in a context.

### Column References

```python
pl.col("name")           # Single column
pl.col("a", "b", "c")    # Multiple columns
pl.col("^prefix_.*$")    # Regex pattern
pl.all()                 # All columns
pl.exclude("id")         # All except "id"
pl.first()               # First column
pl.last()                # Last column
```

### Literal Values

```python
pl.lit(5)                # Integer literal
pl.lit("hello")          # String literal
pl.lit(None)             # Null value
pl.lit([1, 2, 3])        # List literal
```

## Contexts

Expressions are evaluated in specific contexts that determine their behavior.

### select - Choose/Transform Columns

```python
df.select(
    pl.col("a"),
    pl.col("b") * 2,
    (pl.col("a") + pl.col("b")).alias("sum")
)
# Returns DataFrame with only these columns
```

### with_columns - Add New Columns

```python
df.with_columns(
    (pl.col("a") * 2).alias("a_doubled"),
    pl.col("b").str.to_uppercase().alias("b_upper")
)
# Returns DataFrame with original columns PLUS new ones
```

### filter - Filter Rows

```python
df.filter(pl.col("a") > 10)
df.filter((pl.col("a") > 10) & (pl.col("b") == "x"))
# Expression must return boolean
```

### group_by().agg() - Aggregation Context

```python
df.group_by("category").agg(
    pl.col("value").sum(),       # Aggregates
    pl.col("value").mean(),
    pl.len()                     # Row count per group
)
```

## Arithmetic Operations

```python
pl.col("a") + pl.col("b")    # Addition
pl.col("a") - pl.col("b")    # Subtraction
pl.col("a") * pl.col("b")    # Multiplication
pl.col("a") / pl.col("b")    # Division (float result)
pl.col("a") // pl.col("b")   # Floor division
pl.col("a") % pl.col("b")    # Modulo
pl.col("a") ** 2             # Power
-pl.col("a")                 # Negation

# With literals
pl.col("a") + 5
pl.col("a") * 1.1
```

## Comparison Operations

```python
pl.col("a") == pl.col("b")   # Equal
pl.col("a") != pl.col("b")   # Not equal
pl.col("a") > pl.col("b")    # Greater than
pl.col("a") >= pl.col("b")   # Greater or equal
pl.col("a") < pl.col("b")    # Less than
pl.col("a") <= pl.col("b")   # Less or equal

# With literals
pl.col("a") > 10
pl.col("name") == "Alice"
```

## Boolean Operations

```python
# AND
(pl.col("a") > 10) & (pl.col("b") < 20)

# OR
(pl.col("a") > 10) | (pl.col("b") < 20)

# NOT
~(pl.col("a") > 10)

# XOR
(pl.col("a") > 10) ^ (pl.col("b") < 20)
```

**Important**: Always wrap conditions in parentheses due to Python operator precedence.

## Common Expression Methods

### Numeric

```python
pl.col("a").abs()            # Absolute value
pl.col("a").sqrt()           # Square root
pl.col("a").log()            # Natural log
pl.col("a").log10()          # Log base 10
pl.col("a").exp()            # e^x
pl.col("a").pow(2)           # Power
pl.col("a").round(2)         # Round to 2 decimals
pl.col("a").floor()          # Floor
pl.col("a").ceil()           # Ceiling
pl.col("a").clip(0, 100)     # Clip to range
pl.col("a").sign()           # Sign (-1, 0, 1)
```

### Aggregation

```python
pl.col("a").sum()            # Sum
pl.col("a").mean()           # Mean
pl.col("a").median()         # Median
pl.col("a").min()            # Minimum
pl.col("a").max()            # Maximum
pl.col("a").std()            # Standard deviation
pl.col("a").var()            # Variance
pl.col("a").count()          # Non-null count
pl.col("a").n_unique()       # Unique count
pl.col("a").first()          # First value
pl.col("a").last()           # Last value
pl.col("a").quantile(0.95)   # Percentile
pl.len()                     # Total row count
```

### Null Handling

```python
pl.col("a").is_null()        # Boolean: is null
pl.col("a").is_not_null()    # Boolean: is not null
pl.col("a").fill_null(0)     # Fill nulls with value
pl.col("a").drop_nulls()     # Remove nulls
pl.col("a").null_count()     # Count nulls
```

### Type Conversion

```python
pl.col("a").cast(pl.Float64)
pl.col("a").cast(pl.String)
pl.col("a").cast(pl.Int32)
pl.col("a").cast(pl.Datetime)

# Strict vs lenient
pl.col("a").cast(pl.Int64, strict=True)   # Error on failure
pl.col("a").cast(pl.Int64, strict=False)  # Null on failure
```

### Renaming

```python
pl.col("a").alias("new_name")
(pl.col("a") + pl.col("b")).alias("sum")
```

## Conditional Logic

### when/then/otherwise

```python
# If-else
pl.when(pl.col("a") > 10)
  .then(pl.lit("high"))
  .otherwise(pl.lit("low"))

# If-elif-else
pl.when(pl.col("score") >= 90)
  .then(pl.lit("A"))
  .when(pl.col("score") >= 80)
  .then(pl.lit("B"))
  .when(pl.col("score") >= 70)
  .then(pl.lit("C"))
  .otherwise(pl.lit("F"))

# With column values
pl.when(pl.col("discount"))
  .then(pl.col("price") * 0.9)
  .otherwise(pl.col("price"))
```

### Coalesce

```python
# First non-null value
pl.coalesce("a", "b", "c")  # First non-null from a, b, or c
pl.coalesce(pl.col("primary"), pl.col("fallback"), pl.lit("default"))
```

## Horizontal Operations

Operations across multiple columns in the same row:

```python
# Sum across columns
pl.sum_horizontal("a", "b", "c")
pl.sum_horizontal(pl.col("^value_.*$"))  # Regex

# Mean across columns
pl.mean_horizontal("a", "b", "c")

# Min/Max across columns
pl.min_horizontal("a", "b", "c")
pl.max_horizontal("a", "b", "c")

# Any/All (boolean)
pl.any_horizontal("flag1", "flag2", "flag3")
pl.all_horizontal("check1", "check2")

# Concatenate strings
pl.concat_str(["first", "last"], separator=" ")
```

## List Operations

```python
# Create list column
pl.col("a").implode()                    # Column to single-row list

# List element access
pl.col("list_col").list.first()          # First element
pl.col("list_col").list.last()           # Last element
pl.col("list_col").list.get(0)           # By index
pl.col("list_col").list.len()            # List length

# List aggregations
pl.col("list_col").list.sum()
pl.col("list_col").list.mean()
pl.col("list_col").list.min()
pl.col("list_col").list.max()

# List transformations
pl.col("list_col").list.unique()
pl.col("list_col").list.sort()
pl.col("list_col").list.reverse()
pl.col("list_col").list.contains(5)
```

## Struct Operations

```python
# Create struct
pl.struct("a", "b", "c")
pl.struct(pl.col("a"), pl.col("b").alias("renamed"))

# Access fields
pl.col("struct_col").struct.field("name")
pl.col("struct_col").struct["name"]

# Unnest struct to columns
df.unnest("struct_col")
```

## Method Chaining

Chain expressions for readable transformations:

```python
(
    pl.col("price")
    .fill_null(0)
    .clip(0, 1000)
    .round(2)
    .alias("cleaned_price")
)

(
    pl.col("text")
    .str.strip_chars()
    .str.to_lowercase()
    .str.replace_all(r"\s+", " ")
    .alias("normalized")
)
```

## Apply Custom Functions (Use Sparingly)

```python
# map_elements - Python function per element (SLOW)
# Avoid when possible - prefer native expressions
pl.col("a").map_elements(lambda x: x * 2, return_dtype=pl.Int64)

# map_batches - Function on entire Series (faster)
pl.col("a").map_batches(lambda s: s * 2)

# Note: "apply" was renamed to "map_elements" in Polars 0.19+
```

**Warning**: `map_elements` is slow because it uses Python. Always prefer native Polars expressions.

## Expression Patterns

### Multiple Columns Same Operation

```python
# Apply same operation to multiple columns
df.with_columns(
    pl.col("a", "b", "c").fill_null(0)
)

df.with_columns(
    pl.all().exclude("id").round(2)
)

df.with_columns(
    cs.numeric().fill_null(0)
)
```

### Rename Pattern

```python
# Add suffix/prefix to column names
df.select(pl.all().name.suffix("_new"))
df.select(pl.all().name.prefix("col_"))

# Map names
df.select(pl.all().name.map(str.upper))
```

### Over (Window Context)

```python
# Expression within groups (see aggregations-grouping.md)
pl.col("value").sum().over("category")  # Sum per category
```

## Summary

| Purpose | Expression |
|---------|------------|
| Reference column | `pl.col("name")` |
| Literal value | `pl.lit(5)` |
| All columns | `pl.all()` |
| Exclude columns | `pl.exclude("id")` |
| Rename | `.alias("new_name")` |
| Cast type | `.cast(pl.Int64)` |
| Conditional | `pl.when().then().otherwise()` |
| Null check | `.is_null()`, `.is_not_null()` |
| Fill null | `.fill_null(value)` |
| Aggregate | `.sum()`, `.mean()`, `.count()` |
| Row count | `pl.len()` |
| Horizontal | `pl.sum_horizontal(...)` |
