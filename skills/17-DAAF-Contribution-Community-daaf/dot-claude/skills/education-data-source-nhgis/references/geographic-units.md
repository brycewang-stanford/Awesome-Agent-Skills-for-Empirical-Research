# NHGIS Geographic Units

Census geographic units form a hierarchy. Understanding this hierarchy is essential for education research linking schools to community demographics.

## Geographic Hierarchy

```
Nation
└─ Region (4)
   └─ Division (9)
      └─ State (50 + DC + territories)
         └─ County (~3,200)
            ├─ County Subdivision (towns, townships)
            ├─ Census Tract (~85,000 nationally)
            │  └─ Block Group (~240,000 nationally)
            │     └─ Block (~8 million nationally)
            └─ Place (cities, villages - may cross county lines)

School Districts (overlay - may cross county lines)
├─ Unified School District
├─ Elementary School District
└─ Secondary School District
```

## Census Tracts

**Definition**: Small, relatively stable statistical subdivisions of a county.

| Attribute | Value |
|-----------|-------|
| Target population | ~4,000 (range: 1,200-8,000) |
| First defined | 1910 (8 cities) |
| Full U.S. coverage | 1990 |
| Typical area | Urban: few blocks; Rural: large |
| Stability | Designed to be stable; split when population grows |

**Education use**: Primary unit for school neighborhood demographics. Most schools can be assigned to a tract.

**Identifier format**:
- FIPS GEOID: `{state}{county}{tract}` = 11 characters (e.g., `06037264000`)
- NHGIS GISJOIN: `G{state}0{county}0{tract}0` with "G" prefix

**Tract numbering**:
- Format: 4 digits + 2-digit suffix (e.g., 2640.00)
- Suffix .00 = original tract
- Suffix .01, .02 = splits from original

## Block Groups

**Definition**: Clusters of blocks within a census tract. Smallest unit with sample (ACS) data.

| Attribute | Value |
|-----------|-------|
| Target population | ~1,500 (range: 600-3,000) |
| First defined | 1970 (as "enumeration districts") |
| Current form | 1990 |
| Identifier | Single digit (1-9) appended to tract |

**Education use**: More granular than tracts for dense urban areas. Required for sample variables (income, education) at small-area level.

**Identifier format**:
- GEOID: `{tract}{block_group}` = 12 characters (e.g., `060372640001`)
- The block group digit is the first digit of all blocks in that group

## Census Blocks

**Definition**: Smallest census geography. Bounded by visible features (streets, rivers) or invisible boundaries.

| Attribute | Value |
|-----------|-------|
| Typical population | ~40 people (many are zero) |
| First defined | 1940 (urban only) |
| Full U.S. coverage | 1990 |
| Count | ~8.2 million in 2020 |

**Data availability**: Only 100% count data (age, sex, race, housing tenure). No sample data (income, education).

**Education use**: 
- Precise school location assignment
- Building block for geographic crosswalks
- SABINS uses blocks to define school attendance areas

**Identifier format**:
- GEOID: 15 characters = state(2) + county(3) + tract(6) + block(4)
- Block numbers: First digit = block group; remaining = within-group ID

## School Districts

**Definition**: Administrative units responsible for public education. Three types in Census data.

| Type | Description | Count (2020) |
|------|-------------|--------------|
| Unified | K-12 in single district | ~10,000 |
| Elementary | Elementary only | ~3,500 |
| Secondary | Secondary only | ~500 |

**Geographic characteristics**:
- May cross county boundaries (unlike tracts)
- Boundaries set by states/local authorities
- Often don't align with city/place boundaries
- Change more frequently than census tracts

**NHGIS availability**:
- Boundary files: 2000-2023
- No historical school district boundaries pre-2000
- Cannot directly compare school district boundaries over long periods

**Identifier**:
- NCES LEA ID (7 characters): Used in Education Data Portal
- Census school district ID: State(2) + district(5)

## Places

**Definition**: Incorporated places (cities, towns, villages) and Census Designated Places (CDPs - unincorporated communities).

| Attribute | Value |
|-----------|-------|
| Types | Incorporated, CDP |
| May cross | County boundaries (some states) |
| Coverage | Urban and suburban areas |

**Education use**: City-level demographic context. Note that school district boundaries often differ from city boundaries.

## County Subdivisions

**Definition**: Primary legal or statistical divisions of counties.

| Type | States | Example |
|------|--------|---------|
| Minor Civil Division | 28 states | Townships (OH, PA) |
| Census County Division | 22 states | Statistical areas |

**Education use**: Useful in states with township-based school governance (e.g., Pennsylvania).

## Core Based Statistical Areas (CBSAs)

**Definition**: Metropolitan and micropolitan statistical areas based on commuting patterns.

| Type | Core Population | Count |
|------|-----------------|-------|
| Metropolitan | 50,000+ | ~390 |
| Micropolitan | 10,000-50,000 | ~540 |

**Education use**: Regional labor market context; metro vs. non-metro comparisons.

## Geographic Identifiers

### GISJOIN (NHGIS Standard)

NHGIS uses GISJOIN as the standard identifier across all files:

```
Format: G{state}0{county}0{tract}0{block_group}{block}

Examples:
State:        G060         (California)
County:       G0600370     (Los Angeles County, CA)
Tract:        G06003702640000  (Tract 2640 in LA County)
Block Group:  G060037026400001 (BG 1 in that tract)
```

**Key advantage**: Prefix "G" ensures text storage (no dropped leading zeros).

### GEOID (Census Standard)

Census Bureau's standard identifier:

```
Examples:
State:        06           (California)
County:       06037        (Los Angeles County)
Tract:        06037264000  (Tract 2640.00)
Block Group:  060372640001 (BG 1)
Block:        060372640001001 (Block 1001)
```

**Warning**: Software may interpret as numbers, dropping leading zeros.

### Converting Between Identifiers

```python
# GEOID to GISJOIN (tract example)
geoid = "06037264000"
state = geoid[0:2]
county = geoid[2:5]
tract = geoid[5:11]
gisjoin = f"G{state}0{county}0{tract}0"
# Result: G0600370264000

# GISJOIN to GEOID
gisjoin = "G0600370264000"
state = gisjoin[1:3]
county = gisjoin[4:7]
tract = gisjoin[8:14]
geoid = f"{state}{county}{tract}"
```

## Nesting Relationships

| Unit | Nests Within | Cross-Cuts |
|------|--------------|------------|
| Block | Block Group, Tract, County | Place, County Subdivision |
| Block Group | Tract, County | Place, County Subdivision |
| Tract | County | Place, County Subdivision, School District |
| County | State | CBSA, School District |
| School District | State | County, Place, Tract |

**Implication**: To get tract-level data for a school district, you need to allocate partial tracts or aggregate complete tracts.

## Compound Geographic Levels

When units cross-cut (don't nest), Census provides data for intersections:

**Block Group Parts** = Block Group ∩ Place ∩ County Subdivision ∩ other units

Used in 1990-2000 sample data. Smallest unit for long-form variables.

**Accessing in NHGIS**: Click "Show compound geographic levels" in Data Finder.

## Coverage by Census Year

| Level | 1970 | 1980 | 1990 | 2000 | 2010 | 2020 |
|-------|------|------|------|------|------|------|
| State | Full | Full | Full | Full | Full | Full |
| County | Full | Full | Full | Full | Full | Full |
| Tract | Major metros | Most metros | Full U.S. | Full | Full | Full |
| Block Group | Limited | Limited | Full U.S. | Full | Full | Full |
| Block | Urban only | Urban only | Full U.S. | Full | Full | Full |
| School District | N/A | N/A | N/A | Available | Full | Full |

## Selecting a Geographic Level

| Research Need | Recommended Level | Rationale |
|---------------|-------------------|-----------|
| School immediate context | Block Group or Tract | Balance detail vs. reliability |
| School district profile | School District | Direct match |
| Within-district variation | Tracts in district | Captures neighborhood variation |
| Historical comparison | Standardized tracts | Consistent boundaries |
| ACS sample variables | Block Group+ | Blocks have no sample data |
| Small population groups | Tract or higher | Reduce sampling error |
