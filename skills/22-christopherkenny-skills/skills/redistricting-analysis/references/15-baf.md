# baf — Census Block Assignment File Downloader

## Overview

`baf` downloads official Block Assignment Files (BAFs) directly from the U.S. Census Bureau. BAFs are the authoritative source for enacted district assignments — they map every Census block to a district for a given geography and year. This is not a general-purpose BAF reader/writer; it is specifically for retrieving Census Bureau-published BAFs.

For converting between BAF formats and redistricting plan objects, see `geomander::baf_to_vtd()` ([10-geomander-spatial.md](10-geomander-spatial.md)) and `alarm_add_plan()` ([12-alarmdata.md](12-alarmdata.md)).

## Downloading BAFs

```r
library(baf)

# Download a block assignment file from the Census Bureau
# Returns a tibble mapping Census block GEOIDs to district identifiers
cd_baf <- baf(
  state = 'MD',
  year = 2024,
  geographies = 'cd'      # see geography codes below
)
# columns: BLOCKID (or GEOID20), district identifier
```

### Geography Codes

| Code | Geography |
|------|-----------|
| `"cd"` | Congressional districts |
| `"sldu"` | State legislative upper chamber |
| `"sldl"` | State legislative lower chamber |
| `"vtd"` | Voting tabulation districts |
| `"county"` | Counties |
| `"cousub"` | County subdivisions |
| `"concity"` | Consolidated cities |
| `"elsd"` | Elementary school districts |
| `"scsd"` | Secondary school districts |
| `"unsd"` | Unified school districts |

```r
# Multiple geographies at once
baf_data <- baf(state = 'MD', year = 2020,
  geographies = c('cd', 'sldu', 'sldl'))
# Returns a list of tibbles, one per geography
```

### Caching

```r
# Cache to a persistent directory (survives sessions)
cd_baf <- baf(state = 'MD', year = 2024, geographies = 'cd',
  cache_to = '~/data/baf_cache')

# Or set globally
options(baf.use_cache = TRUE)
cd_baf <- baf(state = 'MD', year = 2024, geographies = 'cd')
```

## Cleaning BAFs

```r
# Clean raw downloaded BAF data (standardizes column names and formats)
clean_baf <- clean_bafs(cd_baf)
```

## Example Data

```r
# Small example BAF (Adams County, Washington) for testing
data(example_baf)
head(example_baf)
```

## Using Census BAFs in Redistricting Analysis

### Verify an enacted plan

```r
library(baf)
library(redistverse)

# Download enacted congressional districts for Maryland
enacted_baf <- baf('MD', year = 2022, geographies = 'cd')

# Match to your precinct-level map
# Since BAFs are block-level, need to aggregate to precincts
# Use geomander::baf_to_vtd() if your map uses VTDs (see 10-geomander-spatial.md)
# Or manually aggregate:
enacted_plan <- enacted_baf |>
  left_join(block_to_precinct_crosswalk, by = c('BLOCKID' = 'GEOID20')) |>
  group_by(precinct_id) |>
  summarize(district = as.integer(names(which.max(table(cd))))) |>
  pull(district)

# Add to ensemble for comparison
plans <- alarm_add_plan(plans, enacted_plan, map, name = 'Enacted_2022')
```

### Download path utilities

```r
# Find where a BAF would be cached (without downloading)
path <- baf_download_path(state = 'MD', year = 2024, geographies = 'cd')

# Download a file explicitly
baf_download(state = 'MD', year = 2024, geographies = 'cd',
  path = '~/data/md_cd_2024.zip')
```

## See Also

- Convert BAF plans to VTD-level assignments: `geomander::baf_to_vtd()` in [10-geomander-spatial.md](10-geomander-spatial.md)
- Add plans to an ensemble: `alarm_add_plan()` in [12-alarmdata.md](12-alarmdata.md)
- Census block GEOIDs and geography: [13-pl94171.md](13-pl94171.md)
