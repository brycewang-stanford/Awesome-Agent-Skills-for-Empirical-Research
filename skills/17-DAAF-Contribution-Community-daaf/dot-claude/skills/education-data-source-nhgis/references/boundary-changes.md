# Census Boundary Changes Over Time

Understanding how census boundaries change is critical for valid longitudinal analysis.

## Why Boundaries Change

| Reason | Frequency | Example |
|--------|-----------|---------|
| Population growth | Each census | Tract split in suburban area |
| Population decline | Each census | Tracts merged in shrinking city |
| Boundary corrections | Each census | Align with new streets |
| Political changes | Varies | New county (rare), city annexation |
| Federal guidelines | Each census | Target population thresholds |

## Tract Changes: Patterns

### Tract Splits

When tract population exceeds threshold (~8,000), it's split:

```
1990: Tract 1001.00
      ↓
2000: Tract 1001.01, Tract 1001.02
      ↓
2010: Tract 1001.01, Tract 1001.02, Tract 1001.03 (1001.01 split again)
```

**Common in**: Fast-growing suburbs, exurban areas

**Implication**: Cannot directly compare 1990 Tract 1001.00 to any single 2010 tract.

### Tract Mergers

When population falls below threshold (~1,200), tracts may merge:

```
1990: Tract 2001.00, Tract 2002.00
      ↓
2000: Tract 2001.00 (absorbed 2002.00)
```

**Common in**: Declining central cities, rural areas

### Boundary Adjustments

Minor changes to align with:
- New streets
- Changed municipal boundaries
- Improved mapping accuracy

### Renumbering

Sometimes entire county's tracts are renumbered:
- New numbering scheme
- Accommodate splits/mergers
- Results in discontinuous tract histories

## Quantifying Changes: 1990-2020

| Transition | Approximate Scale |
|------------|-------------------|
| 1990 to 2000 | ~15% of tracts changed |
| 2000 to 2010 | ~18% of tracts changed |
| 2010 to 2020 | ~20% of tracts changed |

**Net growth**: ~62,000 tracts (1990) → ~74,000 tracts (2010) → ~85,000 tracts (2020)

## Block Group Changes

Block groups change more than tracts:
- Smaller population thresholds
- More sensitive to population shifts
- First digit of block numbers indicates block group

## Block Changes

Blocks are completely redefined each census:
- Based on current street network
- No continuity assumed
- Must use crosswalks for any historical analysis

## County Changes (Rare)

Counties rarely change, but notable exceptions:

| Change | Year | Description |
|--------|------|-------------|
| Broomfield, CO | 2001 | Created from parts of 4 counties |
| Alaska regions | Various | Borough/census area changes |
| Virginia cities | Various | Independent city changes |
| Connecticut | 2022 | Counties replaced by planning regions |

### 2022 Connecticut County Changes

**Major change**: Census Bureau switched from 8 historical counties to 9 planning regions.

- Affects all Connecticut tract and block group codes
- GEOID changed for every CT tract (new county code embedded)
- Requires crosswalks for any pre-2022 to post-2022 comparison

NHGIS provides crosswalks for this change in the 2022 non-census year crosswalks.

## TIGER/Line Improvements

TIGER/Line files (source for boundary shapefiles) improved substantially:

| Era | Accuracy | Notes |
|-----|----------|-------|
| Pre-2008 | Lower | Based on 1990s digitization |
| 2008-2009 | Major improvement | GPS, local data integration |
| 2010+ | High | Continued refinement |
| 2020+ | Very high | Modern surveying |

**Implication**: Historical shapefiles may not align with recent ones even for unchanged boundaries.

### NHGIS Solutions

NHGIS provides multiple shapefile versions:

| Basis | Best For |
|-------|----------|
| 2000 TIGER/Line+ | Comparing pre-2010 data |
| 2008 TIGER/Line+ | Bridge between eras |
| 2010 TIGER/Line+ | 2010 and later comparisons |
| 2020 TIGER/Line+ | 2020 and later data |

## Impact on Education Research

### Scenario 1: School Neighborhood Change

**Problem**: Track demographics around a school from 1990-2020.

**Challenge**: School is in Tract 1234.00 in 1990; by 2020 that tract is split into 1234.01, 1234.02, 1234.03.

**Solutions**:
1. Use geographically standardized time series (all years to 2010 boundaries)
2. Use crosswalks to allocate all years to 2020 tracts
3. Aggregate to constant geography (e.g., county)

### Scenario 2: School District Demographics Over Time

**Problem**: Compare district demographics 2000 vs 2020.

**Challenge**: School district boundaries may also change; tracts within district change.

**Solutions**:
1. For tracts: Use crosswalks to standardize
2. For district boundaries: Obtain boundaries for each year; note changes
3. Alternative: Use SAIPE district-level data (available 1995+)

### Scenario 3: Historical Segregation Analysis

**Problem**: Measure segregation trends across tracts since 1970.

**Challenge**: Tract coverage incomplete before 1990; boundaries changed significantly.

**Solutions**:
1. Use NHGIS nominally integrated time series (with caveats)
2. Use standardized tables for 1990-2020
3. For pre-1990: Consider county-level analysis or accept metro-only tract coverage

## Detecting Boundary Changes

### Method 1: Compare Tract Counts

```python
import polars as pl

# If tract count in area changed, boundaries changed
tracts_1990 = df_1990.filter(pl.col("county_fips_geo") == 6037).select("tract").n_unique()
tracts_2020 = df_2020.filter(pl.col("county_fips_geo") == 6037).select("tract").n_unique()
# LA County: ~1,600 in 1990 → ~2,300 in 2020
```

### Method 2: Check Crosswalk

```python
import polars as pl

# Crosswalk shows splits/mergers (direct NHGIS download, not Portal data)
crosswalk = pl.read_csv("nhgis_tr1990_tr2010.csv")

# Tracts that split (1990 tract → multiple 2010 tracts)
splits = crosswalk.group_by("GJOIN1990").agg(pl.col("GJOIN2010").n_unique().alias("n_targets"))
split_tracts = splits.filter(pl.col("n_targets") > 1)

# Tracts that merged (multiple 1990 tracts → 1 2010 tract)
merges = crosswalk.group_by("GJOIN2010").agg(pl.col("GJOIN1990").n_unique().alias("n_sources"))
merged_tracts = merges.filter(pl.col("n_sources") > 1)
```

### Method 3: Visual Inspection

Overlay shapefiles from different years in GIS:
- Areas with misalignment = boundary changes
- Useful for specific study areas

## Best Practices

### For Longitudinal Analysis

1. **Default**: Use geographically standardized tables when available
2. **Custom variables**: Use crosswalks to standardize
3. **Always**: Document which boundaries/year you're using
4. **Report**: Uncertainty bounds from standardization

### For Cross-Sectional Analysis

1. **Match vintages**: Use boundaries from same year as data
2. **Document**: Boundary vintage in methods
3. **Be aware**: 2020 data uses 2020 boundaries (not comparable to 2010 without adjustment)

### For Education Data Portal Integration

The Portal's NHGIS endpoints provide:
- School-to-tract links based on decennial census years
- Different years use different boundary vintages

When merging Portal data with direct NHGIS downloads:
- Verify tract IDs match expected format
- Use appropriate crosswalks for different years

## Reference: Major Boundary Events

| Event | Year | Scope | Notes |
|-------|------|-------|-------|
| Full U.S. tract coverage | 1990 | National | First complete tract system |
| TIGER accuracy improvement | 2008 | National | Shapefile alignment changed |
| Connecticut county dissolution | 2022 | Connecticut | Major ID changes |
| Alaska borough changes | Various | Alaska | Ongoing adjustments |
| Virginia independent cities | Various | Virginia | Cities separate from counties |
| Post-Katrina tract changes | 2006 | Louisiana | Special census area changes |

## Resources

| Resource | Content | URL |
|----------|---------|-----|
| NHGIS Crosswalks | Interpolation files | nhgis.org/geographic-crosswalks |
| Census Relationship Files | Official Census crosswalks | census.gov/geographies/reference-files |
| ACS Geography Changes | Annual change documentation | census.gov (by year) |
| NHGIS Revision History | Data update announcements | nhgis.org/revision-history |
