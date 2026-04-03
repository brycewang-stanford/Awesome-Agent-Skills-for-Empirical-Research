# Census Utilities — censable, easycensus, tinytiger

## censable

`censable` provides Census data retrieval and standardization tools. It wraps `censusapi` for common redistricting-oriented requests, with consistent column naming across years and survey types. Requires a Census API key (set with `add_r_environ()`).

### Building Census Data

```r
library(censable)

# Decennial Census (redistricting data)
dec_data <- build_dec(
  geography = 'block',         # 'block', 'tract', 'county', 'state'
  state = 'MD',
  county = NULL,            # optional FIPS code for a single county
  year = 2020            # 2000, 2010, or 2020
)

# American Community Survey (5-year estimates)
acs_data <- build_acs(
  geography = 'tract',
  state = 'MD',
  year = 2020
)

# Memoized versions (cached in memory — fast for repeated calls in a session)
dec_data <- mem_build_dec(geography = 'tract', state = 'MD', year = 2020)
acs_data <- mem_build_acs(geography = 'tract', state = 'MD', year = 2020)
```

Output columns follow the pattern: `pop` (total), `pop_white`, `pop_black`, `pop_hisp`, `pop_asian`, `pop_aian`, `pop_nhpi`, `pop_other` and equivalent `vap_*` columns for voting-age population.

### Collapsing Race Categories

For analyses that use fewer race categories, collapse the detailed columns:

```r
# Collapse to 4 groups: white, black, hispanic, other
df4 <- collapse4(df)         # adds/replaces standard columns
pop4 <- collapse4_pop(df)    # population columns only
vap4 <- collapse4_vap(df)    # VAP columns only

# Collapse to 5 groups: white, black, hispanic, asian, other
df5 <- collapse5(df)
pop5 <- collapse5_pop(df)
vap5 <- collapse5_vap(df)
```

### State Identifier Conversion

`censable` provides a complete set of functions for converting between state abbreviations, FIPS codes, ANSI codes, and names:

```r
# Convert abbreviation → FIPS
recode_abb_fips('MD')       # '24'
recode_abb_name('MD')       # 'Maryland'
recode_fips_abb('24')       # 'MD'
recode_name_abb('Maryland') # 'MD'

# Add identifier columns to a data frame
df <- join_fips_abb(df, fips_col = 'STATEFP')   # adds 'abb' column
df <- join_abb_name(df, abb_col = 'state')       # adds 'name' column

# Flexible matching (handles abbreviations, FIPS, ANSI, and names as input)
match_abb('Maryland')   # 'MD'
match_fips('MD')        # '24'
```

The 12 `join_*()` functions and 4 `match_*()` functions cover all combinations of {abb, ansi, fips, name}.

### GEOID Tools

```r
# Decompose a Census GEOID into its component parts
breakdown_geoid('240010001001000')
# Returns: state='24', county='001', tract='000100', block_group='1', block='000'

# Build a GEOID from standard columns
construct_geoid(df, level = 'block')   # constructs GEOID from state/county/tract/block cols

# Custom GEOID construction
custom_geoid(df, cols = c('state', 'county', 'tract'))
```

### API Key Management

```r
has_census_key()       # TRUE/FALSE — is a key set?
get_census_key()       # retrieve the key
add_r_environ()        # opens .Renviron for adding CENSUS_API_KEY=your_key
```

---

## easycensus

`easycensus` provides a simpler interface for ACS data with built-in variable search. Useful for finding and downloading specific demographic or socioeconomic tables.

```r
library(easycensus)

# Search for tables by keyword
find_vars('median household income')
find_vars('educational attainment')

# Download a specific ACS variable
income <- get_acs_wide(
  geography = 'tract',
  state = 'MD',
  variables = c(medinc = 'B19013_001'),
  year = 2020
)

# Download a full ACS table
educ <- get_acs_table(
  geography = 'tract',
  state = 'MD',
  table = 'B15003',
  year = 2020
)
```

---

## tinytiger

`tinytiger` downloads TIGER/Line shapefiles from the Census Bureau. Returns `sf` objects in NAD83 (EPSG:4269).

```r
library(tinytiger)

# Geographic boundaries
tt_states(year = 2020)
tt_counties(state = 'MD', year = 2020)
tt_tracts(state = 'MD', county = '003', year = 2020)  # county FIPS
tt_block_groups(state = 'MD', year = 2020)
tt_blocks(state = 'MD', county = '003', year = 2020)  # large files

# Election-related geographies
tt_voting_districts(state = 'MD', year = 2020)        # VTDs / precincts
tt_congressional_districts(state = 'MD', year = 2020)
tt_state_legislative_districts(state = 'MD', year = 2020, chamber = 'upper')
tt_state_legislative_districts(state = 'MD', year = 2020, chamber = 'lower')

# Places (cities, towns)
tt_places(state = 'MD', year = 2020)
```

Caching:
```r
options(tigris_use_cache = TRUE)   # tinytiger follows tigris cache conventions
```

---

## Typical Combined Workflow

```r
library(redistverse)
library(censable)
library(tinytiger)

# 1. Get VTDs as precinct approximations
vtds <- tt_voting_districts('MD', year = 2020)

# 2. Download 2020 Census redistricting data at VTD level
pop <- build_dec(geography = 'voting district', state = 'MD', year = 2020)

# 3. Join
map_sf <- vtds |> left_join(pop, by = 'GEOID')

# 4. Build redist_map
map <- redist_map(map_sf, pop_col = 'pop', ndists = 8, pop_tol = 0.005)
```

## See Also

- Decennial Census P.L. 94-171 data: [13-pl94171.md](13-pl94171.md)
- Pre-built maps (skip manual assembly): [12-alarmdata.md](12-alarmdata.md)
- Spatial aggregation (block→precinct): [10-geomander-spatial.md](10-geomander-spatial.md)
