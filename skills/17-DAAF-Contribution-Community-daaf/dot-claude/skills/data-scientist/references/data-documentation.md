# Data Documentation

Understanding existing documentation and creating documentation when none exists.

## Contents

- [Questions to Ask About Data](#questions-to-ask-about-data)
- [Understanding Columns](#understanding-columns)
- [Data Provenance](#data-provenance)
- [Working with Undocumented Data](#working-with-undocumented-data)
- [Creating Documentation](#creating-documentation)
- [Red Flags to Surface](#red-flags-to-surface)

## Questions to Ask About Data

Before any analysis, seek answers to these questions.

### About Data Source

| Question | Why It Matters |
|----------|----------------|
| Where does this data come from? | Determines reliability, update frequency |
| What system/process generated it? | Understanding generation can reveal biases |
| Who owns or maintains the source? | Knowing who to ask for clarification |
| When was it last updated? | Staleness affects relevance |
| How is data extracted/exported? | Export process might introduce issues |

### About Data Collection

| Question | Why It Matters |
|----------|----------------|
| What was the collection method? | Survey, sensor, transaction, manual entry each have biases |
| What time period does it cover? | Affects generalizability |
| Are there known gaps in coverage? | Missing data might not be random |
| What population does it represent? | Sampling bias affects conclusions |
| Was any filtering applied before export? | May be missing important subsets |

### About Data Quality

| Question | Why It Matters |
|----------|----------------|
| Are there known quality issues? | Avoid rediscovering known problems |
| How are errors handled? | Might be silently dropped or flagged |
| What validation exists at entry? | Determines trust in values |
| Has data been cleaned already? | Avoid double-cleaning |
| Are there special codes for missing/invalid? | -999, "N/A", etc. need handling |

### About Business Context

| Question | Why It Matters |
|----------|----------------|
| What business process generates this data? | Context helps interpret values |
| What decisions are made using it? | Understand stake and scrutiny level |
| Who are the domain experts? | Know who to consult |
| Are there regulatory requirements? | May constrain what you can do |
| What would be surprising in this data? | Domain knowledge catches errors |

## Understanding Columns

For each column, understand these attributes:

### Essential Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| **Name** | Column identifier | `customer_id` |
| **Description** | What it represents in business terms | "Unique identifier assigned when customer account created" |
| **Data type** | Technical type | Integer, String, Datetime |
| **Nullability** | Can it be missing? | "Yes, for anonymous visitors" |
| **Domain/Valid values** | Allowed values | "Positive integers", "USA/CAN/MEX" |

### Extended Attributes (When Available)

| Attribute | Description |
|-----------|-------------|
| **Source** | Where the value originates |
| **Calculation logic** | If derived, how it's computed |
| **Update frequency** | How often it changes |
| **Dependencies** | Related columns or external data |
| **Known issues** | Documented problems or caveats |

### Questions for Each Column

When documentation is sparse, ask:

1. **What does this column represent in the real world?**
2. **What unit is it measured in?** (dollars, cents, kilograms, count)
3. **What does a null value mean?** (missing, not applicable, unknown)
4. **What are the valid values?** (range, enumeration, format)
5. **Is it directly captured or derived?** (if derived, from what?)
6. **Can it change over time?** (historical vs. current state)

## Data Provenance

Understanding where data comes from and how it got here.

### Lineage Questions

```
Data Flow:
Source System → Extraction → Transformation → Storage → Export → Your Analysis
     ↓              ↓             ↓            ↓          ↓
What system?   How often?    What changes?   What format?  Any filters?
```

### What to Document

1. **Source system(s)**: Original database, API, file system
2. **Extraction method**: SQL query, API call, file transfer
3. **Transformations applied**: Joins, filters, aggregations, cleaning
4. **Storage location**: Data warehouse, data lake, local file
5. **Export process**: How you received the data

### Why Provenance Matters

| Provenance Issue | Risk |
|-----------------|------|
| Unknown source | Can't validate correctness |
| Undocumented transforms | May have hidden assumptions |
| Multiple sources joined | Possible key mismatches |
| Old extraction | Data may be stale |
| Filtered export | Missing important subsets |

## Working with Undocumented Data

When you receive data with no documentation, follow this process.

### Step 1: Generate Basic Profile

```python
import polars as pl

def generate_basic_profile(df: pl.DataFrame):
    """Generate documentation from data inspection."""
    
    profile = []
    for col in df.columns:
        info = {
            "column": col,
            "dtype": str(df[col].dtype),
            "null_count": df[col].null_count().item(),
            "null_pct": round(df[col].null_count().item() / len(df) * 100, 1),
            "unique_count": df[col].n_unique(),
            "sample_values": df[col].drop_nulls().unique().head(5).to_list(),
        }
        profile.append(info)
    
    return pl.DataFrame(profile)

# Use
profile = generate_basic_profile(df)
print(profile)
```

### Step 2: Identify Granularity

**Critical question: What does each row represent?**

```python
# Test candidate keys for uniqueness
def find_granularity(df: pl.DataFrame):
    """Identify what uniquely identifies each row."""
    
    candidates = []
    
    # Test single columns
    for col in df.columns:
        if df[col].n_unique() == len(df):
            candidates.append([col])
    
    # Test common combinations
    if "id" in df.columns:
        candidates.append(["id"])
    
    # Test date + entity patterns
    date_cols = [c for c in df.columns if "date" in c.lower() or "time" in c.lower()]
    id_cols = [c for c in df.columns if "id" in c.lower()]
    
    for date_col in date_cols:
        for id_col in id_cols:
            if df.select([date_col, id_col]).n_unique() == len(df):
                candidates.append([date_col, id_col])
    
    return candidates

print("Candidate unique keys:", find_granularity(df))
```

### Step 3: Infer Column Meanings

```python
def infer_column_purpose(df: pl.DataFrame, col: str):
    """Infer what a column might represent."""
    
    dtype = df[col].dtype
    n_unique = df[col].n_unique()
    sample = df[col].drop_nulls().head(5).to_list()
    
    inferences = []
    
    # Name-based inference
    name_lower = col.lower()
    if "id" in name_lower:
        inferences.append("Likely identifier/key")
    if "date" in name_lower or "time" in name_lower:
        inferences.append("Likely temporal")
    if "amt" in name_lower or "amount" in name_lower or "price" in name_lower:
        inferences.append("Likely monetary value")
    if "count" in name_lower or "num" in name_lower or "qty" in name_lower:
        inferences.append("Likely count/quantity")
    if "flag" in name_lower or "is_" in name_lower or "has_" in name_lower:
        inferences.append("Likely boolean indicator")
    
    # Cardinality-based inference
    pct_unique = n_unique / len(df) * 100
    if pct_unique > 95:
        inferences.append("High cardinality (ID? Free text?)")
    elif pct_unique < 1:
        inferences.append("Low cardinality (categorical)")
    elif n_unique == 2:
        inferences.append("Binary (boolean?)")
    
    return {
        "column": col,
        "dtype": str(dtype),
        "unique_pct": round(pct_unique, 1),
        "sample": sample,
        "inferences": inferences
    }
```

### Step 4: Document As You Learn

As you discover what columns mean, CREATE documentation:

```python
# Build documentation dictionary as you learn
data_dictionary = {
    "customer_id": {
        "description": "Unique customer identifier",
        "type": "Integer",
        "nullable": False,
        "notes": "Assigned at account creation, never reused"
    },
    "order_date": {
        "description": "Date order was placed",
        "type": "Date",
        "nullable": False,
        "notes": "In UTC timezone"
    },
    # Add more as you discover...
}
```

## Creating Documentation

### Minimum Viable Data Dictionary

At minimum, document:

```markdown
## Data Dictionary: [Dataset Name]

### Overview
- **Source**: [Where data comes from]
- **Granularity**: [What each row represents]
- **Date range**: [Time period covered]
- **Row count**: [Number of records]

### Columns

| Column | Type | Description | Nullable | Notes |
|--------|------|-------------|----------|-------|
| customer_id | Int64 | Unique customer identifier | No | Primary key |
| order_date | Date | Date order was placed | No | UTC timezone |
| amount | Float64 | Order total in USD | No | Includes tax |
| status | String | Order status | No | Values: pending, shipped, delivered, cancelled |

### Known Issues
- [List any known data quality issues]

### Change Log
- [Date]: Initial documentation created
```

### Documentation Template

```python
def create_documentation_template(df: pl.DataFrame, dataset_name: str):
    """Generate a documentation template from DataFrame."""
    
    template = f"""# Data Dictionary: {dataset_name}

## Overview
- **Source**: [TODO: Document source]
- **Granularity**: [TODO: What does each row represent?]
- **Date range**: [TODO: Time period covered]
- **Row count**: {len(df):,}
- **Column count**: {len(df.columns)}

## Columns

| Column | Type | Nullable | Unique | Description |
|--------|------|----------|--------|-------------|
"""
    
    for col in df.columns:
        dtype = df[col].dtype
        nullable = "Yes" if df[col].null_count().item() > 0 else "No"
        unique_pct = round(df[col].n_unique() / len(df) * 100, 1)
        
        template += f"| {col} | {dtype} | {nullable} | {unique_pct}% | [TODO] |\n"
    
    template += """
## Known Issues
- [TODO: Document known issues]

## Change Log
- [DATE]: Documentation created
"""
    
    return template

# Use
print(create_documentation_template(df, "Customer Orders"))
```

## Red Flags to Surface

When reviewing data, flag these issues for discussion:

### Data Quality Red Flags

| Red Flag | Concern |
|----------|---------|
| >10% missing in critical column | May bias analysis |
| Unexpected data types | Possible parsing/export error |
| Values outside reasonable range | Data quality issue or different units |
| Dates in the future | Likely data entry errors |
| Duplicate primary keys | Data integrity violation |
| Inconsistent encodings | Same thing represented differently |

### Documentation Red Flags

| Red Flag | Concern |
|----------|---------|
| No documentation exists | Risk of misinterpretation |
| Documentation is outdated | Schema may have changed |
| Column meanings unclear | May use data incorrectly |
| No provenance information | Can't validate correctness |
| Unknown null conventions | May mishandle missing data |

### Sampling Red Flags

| Red Flag | Concern |
|----------|---------|
| Convenience sample | May not represent population |
| Low response rate | Non-response bias |
| Specific subsets only | Findings may not generalize |
| Time-limited data | Seasonality effects |
| Geographic limitations | Regional bias |

### Report Template for Red Flags

```markdown
## Data Quality Concerns

### Critical Issues
1. [Issue]: [Description and impact]
   - Recommendation: [How to address]

### Important Findings
1. [Finding]: [Description]
   - Implication: [What it means for analysis]

### Questions for Data Owner
1. [Question about unclear aspect]
2. [Question about data quality issue]

### Assumptions Made
1. [Assumption]: [Why it was necessary]
```
