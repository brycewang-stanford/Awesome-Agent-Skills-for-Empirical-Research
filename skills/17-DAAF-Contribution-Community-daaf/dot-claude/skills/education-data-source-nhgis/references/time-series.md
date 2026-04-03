# NHGIS Time Series Tables and Geographic Crosswalks

Analyzing change over time requires either harmonized data or tools to align different census years.

## The Challenge of Temporal Analysis

Census boundaries change between censuses:
- **Tracts split** when population grows
- **Tracts merge** when population declines
- **Boundaries adjust** for operational reasons
- **New tracts created** in developing areas

**Result**: A "tract" in 1990 may correspond to multiple tracts in 2020, making direct comparison impossible without adjustment.

## Two Solutions

| Solution | Description | Best For |
|----------|-------------|----------|
| Time Series Tables | Pre-harmonized data | Quick analysis of common variables |
| Geographic Crosswalks | Interpolation weights | Custom variables, advanced analysis |

## Time Series Tables

### What Are They?

NHGIS time series tables link comparable statistics across multiple censuses:
- Consistent variable definitions
- Available in two geographic integration modes
- Downloadable as single files with all years

### Integration Methods

#### Nominally Integrated Tables

- **Method**: Match units by name/code across years
- **Boundaries**: Original boundaries for each year
- **Use case**: When you want data for units as they existed at each time
- **Caveat**: Same code may refer to different areas in different years

**Available levels**: Nation, Region, Division, State, County, Tract, County Subdivision, Place

**Year coverage**: Some tables back to 1790 (Total Population); most start 1970

#### Geographically Standardized Tables

- **Method**: Interpolate data to common boundary set
- **Standard year**: All data expressed for 2010 boundaries
- **Use case**: True apples-to-apples comparison
- **Caveat**: Only 100% count variables; estimates have uncertainty

**Available levels**: State, County, Tract, Block Group, Place, County Subdivision, CBSA, Congressional District, Urban Area, ZCTA

**Years covered**: 1990, 2000, 2010, 2020 (standardized to 2010 units)

### Available Topics

| Topic Category | Nominal Tables | Standardized Tables |
|----------------|----------------|---------------------|
| Total Population | Yes (back to 1790) | Yes |
| Population by Sex | Yes (back to 1820) | Yes |
| Population by Age | Yes | Yes |
| Population by Race | Yes | Yes |
| Hispanic/Latino Origin | Yes | Yes |
| Household/Family Type | Yes | Yes |
| Housing Occupancy/Tenure | Yes | Yes |
| Education Attainment | Yes | No |
| Income/Poverty | Yes | No |
| Nativity/Immigration | Yes | No |
| Employment | Yes | No |
| Transportation | Yes | No |

**Key limitation**: Standardized tables only cover 100% count (short-form) variables. Sample-based variables (income, education, poverty) are only nominally integrated.

### Table Layouts

Three download options:

| Layout | Structure | Best For |
|--------|-----------|----------|
| Time varies by column | One row per geography, years as columns | Wide-format analysis |
| Time varies by row | One row per geography-year | Long-format, panel data |
| Time varies by file | Separate file per year | Large extracts |

### Example: Downloading Time Series

1. Go to [NHGIS Data Finder](https://data2.nhgis.org/main)
2. Click "TIME SERIES TABLES" tab
3. Filter by topic, geographic level, years
4. Add to Data Cart
5. Select layout option
6. Submit extract

### Uncertainty in Standardized Tables

For standardized data, NHGIS provides **lower and upper bounds**:

- **Interpolation uncertainty**: When source blocks straddle target unit boundaries
- **Bounds interpretation**: True value is between lower and upper bound
- **Narrow bounds**: Little uncertainty (source units nest well)
- **Wide bounds**: Significant interpolation required

### Coverage Summary

**Nominally Integrated**:
- Decennial: 1970-2020 for most topics
- ACS: 5-year periods 2006-2010 through present
- Geographic levels: Up to 8 levels depending on table

**Geographically Standardized**:
- Years: 1990, 2000, 2010, 2020
- Standard: 2010 geographic units
- Topics: 100% count only

## Geographic Crosswalks

### What Are They?

Crosswalk files describe relationships between census units from different years:
- Each row = one intersection between source and target zones
- Includes interpolation weights for allocating data
- Based on advanced models (not simple area weighting)

### Available Crosswalks

| Source Year | Target Year | Available Levels |
|-------------|-------------|------------------|
| 1990 | 2010 | Blocks, BG, Tracts, Counties |
| 2000 | 2010 | Blocks, BG, Tracts, Counties |
| 2010 | 2020 | Blocks, BG, Tracts, Counties |
| 2020 | 2010 | Blocks, BG, Tracts, Counties |

**Non-census years** (for ACS): 2011, 2012, 2014, 2015, 2022

### Crosswalk Structure

| Field | Description |
|-------|-------------|
| Source zone ID | GISJOIN for source year unit |
| Target zone ID | GISJOIN for target year unit |
| Weight | Proportion to allocate |

**Weights vary by data type**:

| Weight Field | Use For |
|--------------|---------|
| `wt_pop` | Population counts |
| `wt_hh` | Household counts |
| `wt_hu` | Housing unit counts |
| `wt_adult` | Adult population |
| `wt_fam` | Family counts |

### Using Crosswalks: Example

**Goal**: Get 2000 Census data for 2010 tract boundaries

```python
import polars as pl

# Load crosswalk: 2000 blocks to 2010 tracts (direct NHGIS download, not Portal data)
crosswalk = pl.read_csv("nhgis_blk2000_tr2010.csv")

# Load 2000 block data
blocks_2000 = pl.read_csv("nhgis_2000_blocks.csv")

# Join crosswalk to block data
merged = crosswalk.join(blocks_2000, left_on="GJOIN2000", right_on="GISJOIN")

# Apply weights to allocate population
merged = merged.with_columns(
    (pl.col("total_pop") * pl.col("wt_pop")).alias("pop_allocated")
)

# Aggregate to 2010 tracts
tracts_2010 = merged.group_by("GJOIN2010").agg(
    pl.col("pop_allocated").sum()
)
```

### Start from Lowest Level

**Critical**: Always use the smallest available source units:

| Data Type | Recommended Source |
|-----------|-------------------|
| 100% count (decennial) | Blocks |
| Long-form 1990, 2000 | Block Group Parts |
| ACS 5-year | Block Groups |
| Tract-only variables | Tracts (last resort) |

**Why?** Smaller units require less disaggregation, reducing interpolation error.

### Methodology: Target-Density Weighting

NHGIS uses "target-density weighting" (TDW):

1. **Assumption**: Characteristics within source zones are distributed proportionally to target zone densities
2. **Example**: If a 2000 block overlaps two 2010 blocks (density 10:1), allocate 91% to denser block
3. **Advantage**: More accurate than area-based weighting
4. **Reference**: Schroeder 2007, *Geographical Analysis*

### Crosswalks for Education Research

**Common scenarios**:

1. **Track neighborhood change around schools**
   - Get 1990, 2000, 2010, 2020 data for consistent 2010 tracts
   - Use block-to-tract crosswalks from each year

2. **Analyze historical school district composition**
   - Get tract data for each decade
   - Use crosswalks to standardize to current district boundaries
   - Aggregate tracts to district

3. **Control for community change in school outcomes**
   - Standardize demographics to consistent geography
   - Create panel dataset with school fixed effects

### Handling ACS Data

ACS 5-year estimates span multiple years:
- E.g., 2016-2020 ACS ≈ 2018 center point
- Boundaries: Typically based on survey's end year

**Crosswalk selection**:
- 2016-2020 ACS uses 2020 boundaries → Use 2020 crosswalks
- 2006-2010 ACS uses 2010 boundaries → Use 2010 crosswalks

### Limitations

| Issue | Description | Mitigation |
|-------|-------------|------------|
| No sample variable standardization | Income, poverty not in standardized tables | Use crosswalks on BG-level ACS data |
| 2020 differential privacy | 2020 Census has noise injection | Check for anomalies; use bounds |
| Interpolation uncertainty | All estimates have error | Report bounds when available |
| Pre-1990 limited | Few crosswalks for earlier decades | Use county-level analysis |

## Practical Workflow

### Creating Standardized Panel Data

1. **Define target geography**: Usually most recent census year
2. **Identify variables**: Check if available in standardized tables
3. **Download data**:
   - If in standardized tables: Download directly
   - If not: Download source data + crosswalks
4. **Apply crosswalks** (if needed):
   - Match to lowest available level
   - Apply weights
   - Aggregate to target geography
5. **Quality checks**:
   - Compare totals before/after
   - Check bounds on standardized estimates
   - Flag areas with large interpolation

### Example: 30-Year Population Change by Race

```python
# Download geographically standardized time series table:
# "Persons by Race" standardized to 2010 tracts

# Data will include:
# - 1990 estimates for 2010 tracts
# - 2000 estimates for 2010 tracts  
# - 2010 actual counts
# - 2020 estimates for 2010 tracts

# Plus bounds for interpolated years:
# - 1990_lower, 1990_upper
# - 2000_lower, 2000_upper
# - 2020_lower, 2020_upper
```

## Recommended Resources

| Resource | URL | Content |
|----------|-----|---------|
| Time Series Documentation | nhgis.org/time-series-tables | Full methodology |
| Crosswalk Documentation | nhgis.org/geographic-crosswalks | Detailed usage guide |
| Crosswalk Downloads | nhgis.org/geographic-crosswalks#download | All crosswalk files |
| Webinar: Time Series | YouTube (NHGIS) | Visual walkthrough |
