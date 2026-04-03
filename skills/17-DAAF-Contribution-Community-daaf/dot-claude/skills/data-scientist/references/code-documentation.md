# Code Documentation

Writing thorough comments and documentation for data science code.

## Contents

- [Comment Philosophy](#comment-philosophy)
- [What to Document](#what-to-document)
- [Docstring Patterns](#docstring-patterns)
- [Marimo Cell Documentation](#marimo-cell-documentation)
- [Test Documentation](#test-documentation)
- [Documentation Examples](#documentation-examples)

## Comment Philosophy

### The Core Principle

**Code tells you HOW. Comments tell you WHY, WHAT FOR, and WHAT'S ASSUMED.**

In research workflows, the standard is the **Inline Audit Trail (IAT)** — see `agent_reference/INLINE_AUDIT_TRAIL.md` for the full specification.

Good comments explain:
- Why this approach was chosen over alternatives
- Why specific values or thresholds were selected
- Why edge cases are handled a particular way
- What business logic or domain knowledge informed the decision

Bad comments explain:
- What the code literally does (the code already shows this)
- Obvious operations (`# increment i by 1`)

### When to Be Verbose

**For research scripts (Stages 5-8): Be verbose ALWAYS.** The IAT standard applies to all research code. Every transformation, filter, join, and aggregation needs INTENT, REASONING, and ASSUMES comments.

Be MORE verbose when:
- Business logic is encoded
- Domain knowledge is required to understand
- Non-obvious decisions were made
- Assumptions are being made about the data
- Edge cases require special handling
- The operation is complex or multi-step
- Future maintainers need context

Be LESS verbose when (non-research code only):
- Code is self-explanatory
- Using well-known library patterns
- Operations are trivial

### Data Science Specific Guidance

Data science code should be MORE documented than typical code because:
- Analytical decisions have significant downstream impact
- Assumptions need to be explicit for reproducibility
- Domain expertise may be needed to understand choices
- Data quality issues need to be documented
- Statistical methodology should be explained

## What to Document

### For Every Code Block

1. **GOAL**: What are you trying to accomplish?
2. **APPROACH**: Why this method vs. alternatives?
3. **ASSUMPTIONS**: What must be true for this to work?
4. **EXPECTED RESULT**: What should the output look like?

### For Data Operations

```python
# ================================================================
# GOAL: Filter to customers with valid purchase history
# 
# APPROACH: Require at least one purchase in the last 365 days.
# We chose 365 days (vs. 90 or 180) because seasonal customers
# (e.g., holiday-only shoppers) are still valuable for this analysis.
#
# ASSUMPTIONS:
# - 'last_purchase_date' is populated for all customers with purchases
# - Customers with NULL last_purchase_date have never purchased
#
# EXPECTED: ~60% of customers retained (based on historical pattern)
# ================================================================
active_customers = customers.filter(
    pl.col("last_purchase_date") >= cutoff_date
)

# Verify expectation
retention_rate = len(active_customers) / len(customers) * 100
print(f"Retained {retention_rate:.1f}% of customers")
# If this is far from 60%, investigate before proceeding
```

### For Statistical Operations

```python
# ================================================================
# GOAL: Handle outliers in transaction amounts
#
# METHOD: Winsorization at 1st and 99th percentiles
#
# WHY WINSORIZE vs. REMOVE:
# - Removing outliers loses data and may bias toward "normal" transactions
# - Winsorizing preserves row count while reducing outlier influence
# - 1st/99th percentiles chosen to affect only extreme values (~2% of data)
#
# WHY NOT LOG TRANSFORM:
# - Need to preserve original scale for business interpretation
# - Log transform would complicate downstream aggregations
#
# ASSUMPTION: Outliers are measurement/entry errors, not real events
# (Verified: extreme values correspond to known data quality issues)
# ================================================================
p01 = df["amount"].quantile(0.01)
p99 = df["amount"].quantile(0.99)

df = df.with_columns(
    pl.col("amount").clip(p01, p99).alias("amount_winsorized")
)
```

### For Joins and Merges

```python
# ================================================================
# GOAL: Enrich orders with customer demographic data
#
# JOIN TYPE: Left join
# - Keep all orders even if customer demographics missing
# - Missing demographics will be analyzed separately
#
# JOIN KEY: customer_id
# - Verified unique in customers table (1:1 relationship)
# - Some orders may have customer_id not in customers table (new customers)
#
# EXPECTED RESULT:
# - Same row count as orders (left join preserves all left rows)
# - Additional columns from customers added
# - Some NULL values in customer columns where no match
# ================================================================
enriched_orders = orders.join(
    customers.select(["customer_id", "age_group", "region", "tenure_months"]),
    on="customer_id",
    how="left"
)

# Verify: row count unchanged
assert len(enriched_orders) == len(orders), "Unexpected row count change after join"

# Document match rate
match_rate = enriched_orders["age_group"].drop_nulls().len() / len(enriched_orders) * 100
print(f"Customer match rate: {match_rate:.1f}%")
```

## Docstring Patterns

> **Note for research scripts:** Formal docstrings are valuable for reusable utility functions
> (e.g., `fetch_all_pages`, `apply_coded_values`). For one-and-done script code, inline comments
> explaining the "why" are sufficient -- you do not need full NumPy-style docstrings on every block.

### Function Docstrings (for reusable utilities)

```python
def calculate_customer_lifetime_value(
    transactions: pl.DataFrame,
    customer_id_col: str = "customer_id",
    amount_col: str = "amount",
    date_col: str = "transaction_date",
) -> pl.DataFrame:
    """
    Calculate customer lifetime value (CLV) using historical transaction data.
    
    Uses a simple historical CLV model: total past spend per customer.
    For predictive CLV, consider BG/NBD or Pareto/NBD models.
    
    Parameters
    ----------
    transactions : pl.DataFrame
        Transaction-level data with customer ID, amount, and date.
    customer_id_col : str
        Name of customer identifier column.
    amount_col : str
        Name of transaction amount column (should be in consistent currency).
    date_col : str
        Name of transaction date column.
    
    Returns
    -------
    pl.DataFrame
        Customer-level DataFrame with columns:
        - customer_id: Customer identifier
        - total_spend: Sum of all transaction amounts
        - transaction_count: Number of transactions
        - first_purchase: Date of first transaction
        - last_purchase: Date of most recent transaction
        - tenure_days: Days between first and last purchase
    
    Assumptions
    -----------
    - Transactions are deduplicated (no duplicate transaction records)
    - Amounts are in consistent currency (no currency conversion needed)
    - Negative amounts represent refunds/returns
    
    Example
    -------
    >>> clv = calculate_customer_lifetime_value(transactions)
    >>> print(clv.head())
    """
```

### Data Validation (Inline Approach)

For research scripts, validate data inline rather than building validator classes:

```python
# Validate directly where you use the data
assert df["id"].null_count() == 0, "IDs must not be null"
assert df.select("id", "year").n_unique() == len(df), "id+year must be unique"
valid_states = set(range(1, 57))  # FIPS codes
invalid = set(df["fips"].unique().to_list()) - valid_states
assert not invalid, f"Invalid FIPS codes: {invalid}"
```

## Marimo Cell Documentation

### Cell Organization Pattern

```python
# Cell 1: Setup (minimal documentation needed)
import marimo as mo
import polars as pl

# Cell 2: Data Loading (document source)
# ================================================================
# DATA SOURCE: Customer transactions from DW export
# EXPORTED: 2024-01-15
# COVERAGE: All transactions from 2023-01-01 to 2023-12-31
# KNOWN ISSUES: December data may be incomplete (export ran early)
# ================================================================
transactions = pl.read_parquet("transactions_2023.parquet")

# Cell 3: Markdown explanation before analysis
mo.md("""
## Data Quality Assessment

Before analyzing customer behavior, we need to assess the quality of our 
transaction data. Key questions:

1. **Completeness**: Are there missing values in critical fields?
2. **Validity**: Are transaction amounts and dates reasonable?
3. **Consistency**: Do customer IDs match across systems?

The following cells examine each of these dimensions.
""")

# Cell 4: Analysis with inline comments
# Check for missing values in critical columns
# Critical = columns that would invalidate the transaction if missing
critical_columns = ["transaction_id", "customer_id", "amount", "transaction_date"]

missing_summary = transactions.select([
    pl.col(col).null_count().alias(f"{col}_missing")
    for col in critical_columns
])

mo.md(f"""
### Missing Values in Critical Fields

{missing_summary}

**Interpretation**: [Add interpretation of what the missing values mean]
""")
```

### When to Use Markdown Cells

Use `mo.md()` cells for:
- Section headers and transitions
- Explaining the analytical approach BEFORE the code
- Summarizing findings AFTER the code
- Documenting decisions and their rationale
- Providing business context

Keep in code comments:
- Technical implementation details
- Line-by-line explanations
- Assumptions specific to that code block

### Reactive Validation Documentation

```python
# Interactive column selector for exploration
# Purpose: Allow user to quickly inspect any column's distribution
column_selector = mo.ui.dropdown(
    options=df.columns,
    value=df.columns[0],
    label="Select column to inspect"
)

# This cell reacts to column_selector changes
# Automatically updates when user selects different column
mo.md(f"""
### Column: `{column_selector.value}`

- **Type**: {df[column_selector.value].dtype}
- **Null count**: {df[column_selector.value].null_count().item()}
- **Unique values**: {df[column_selector.value].n_unique()}

**Sample values**: {df[column_selector.value].unique().head(10).to_list()}
""")
```

## Test Documentation

### Validating Transformations

Instead of writing separate test files, validate transformations inline within the script that performs them:

```python
# Before aggregation
pre_total = transactions["amount"].sum()

# Aggregate
customer_summary = (
    transactions
    .group_by("customer_id")
    .agg(pl.col("amount").sum().alias("total_spend"))
)

# Validate immediately
post_total = customer_summary["total_spend"].sum()
print(f"Total spend preserved: {pre_total:,.2f} → {post_total:,.2f}")
assert abs(pre_total - post_total) < 1e-10, "STOP: Total spend changed during aggregation"
```

## Documentation Examples

### Good vs. Bad Examples

**Bad: Stating the obvious**
```python
# Loop through customers
for customer in customers:
    # Get customer id
    customer_id = customer["id"]
    # Filter transactions for this customer
    customer_transactions = transactions.filter(pl.col("customer_id") == customer_id)
```

**Good: Explaining the why**
```python
# Process customers individually rather than in a single groupby because:
# 1. Memory constraints: full aggregation exceeds available RAM
# 2. Partial results: we want to checkpoint progress every 1000 customers
# 3. Custom logic: per-customer CLV model requires sequential processing
for customer in customers:
    customer_id = customer["id"]
    customer_transactions = transactions.filter(pl.col("customer_id") == customer_id)
```

**Bad: No context**
```python
df = df.filter(pl.col("amount") > 0)
```

**Good: Business context**
```python
# Remove zero and negative amounts
# - Zero amounts are placeholder records created by legacy system (confirmed with IT)
# - Negative amounts are handled separately in refund analysis
# - This filter removes ~2% of records (validated against expectation)
df = df.filter(pl.col("amount") > 0)
print(f"Removed {original_count - len(df)} non-positive amount records")
```

### Full Analysis Block Example

```python
# ============================================================================
# ANALYSIS: Customer Segmentation by Purchase Frequency
# ============================================================================
# 
# OBJECTIVE: Segment customers into frequency tiers for targeted marketing
#
# METHODOLOGY:
# - Calculate purchase frequency (orders per month) for each customer
# - Segment into quartiles: Low, Medium, High, Very High frequency
# - Quartiles chosen over fixed thresholds because:
#   - Adapts to changes in overall customer behavior
#   - Ensures balanced segment sizes for marketing capacity
#   - Standard approach aligns with previous analyses
#
# ASSUMPTIONS:
# - Only counting orders with status='complete' (not cancelled/pending)
# - Using 12-month lookback window to smooth seasonality
# - New customers (<3 months tenure) excluded (not enough history)
#
# EXPECTED OUTPUT:
# - Customer-level DataFrame with frequency tier assignment
# - Approximately 25% of customers in each tier
# ============================================================================

# Calculate monthly order frequency
customer_frequency = (
    orders
    .filter(
        (pl.col("status") == "complete") &  # Only completed orders
        (pl.col("order_date") >= twelve_months_ago)  # 12-month window
    )
    .group_by("customer_id")
    .agg([
        pl.len().alias("order_count"),
        (pl.col("order_date").max() - pl.col("order_date").min()).dt.days().alias("active_days")
    ])
    .with_columns(
        # Orders per 30-day month
        (pl.col("order_count") / (pl.col("active_days") / 30)).alias("monthly_frequency")
    )
    .filter(pl.col("active_days") >= 90)  # Minimum 3 months history
)

# Assign quartile-based segments
# Using qcut logic manually since Polars doesn't have qcut
q25 = customer_frequency["monthly_frequency"].quantile(0.25)
q50 = customer_frequency["monthly_frequency"].quantile(0.50)
q75 = customer_frequency["monthly_frequency"].quantile(0.75)

customer_frequency = customer_frequency.with_columns(
    pl.when(pl.col("monthly_frequency") <= q25).then(pl.lit("Low"))
    .when(pl.col("monthly_frequency") <= q50).then(pl.lit("Medium"))
    .when(pl.col("monthly_frequency") <= q75).then(pl.lit("High"))
    .otherwise(pl.lit("Very High"))
    .alias("frequency_tier")
)

# Validate segment distribution
segment_distribution = customer_frequency["frequency_tier"].value_counts()
print("Segment distribution:")
print(segment_distribution)
# Expected: each tier ~25% of customers
```

---

## IAT Quick Reference

For research workflow scripts, follow the **Inline Audit Trail (IAT)** protocol. The full specification is in `agent_reference/INLINE_AUDIT_TRAIL.md`.

**5 Comment Types:**

| # | Type | Format | Required When |
|---|------|--------|---------------|
| 1 | Section Preamble | Block above `# --- Section ---` | Every section |
| 2 | Intent Comment | `# INTENT: ...` | Every transform, filter, join, agg |
| 3 | Reasoning Comment | `# REASONING: ...` | Non-obvious choices |
| 4 | Assumption Comment | `# ASSUMES: ...` | Data property dependencies |
| 5 | Inline Annotation | End-of-line `# ...` | Complex single operations |
