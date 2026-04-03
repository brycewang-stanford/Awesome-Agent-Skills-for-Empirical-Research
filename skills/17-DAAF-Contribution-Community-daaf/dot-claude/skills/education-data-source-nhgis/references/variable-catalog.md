# NHGIS Variable Catalog for Education Research

Key demographic variables available from NHGIS for education research contexts.

> **IMPORTANT**: This document covers two contexts:
> 1. **Portal NHGIS data** — School/college-to-census links via Education Data Portal mirrors (integer encodings)
> 2. **NHGIS direct access** — Census variables from NHGIS Data Finder (original table codes)
>
> Only Section 1 (Portal Integer Encodings) documents data available through this system. All subsequent sections require direct NHGIS access.
>
> For Portal integer encodings, see the [Portal Encodings](#portal-integer-encodings) section below.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> Codebook paths are listed in `datasets-reference.md`. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs. If this documentation contradicts the codebook, trust the codebook.

---

## Portal Integer Encodings

When accessing NHGIS data through the Education Data Portal mirrors, categorical variables use integer codes. These are the encodings for the NHGIS school/college-geography datasets.

### census_region

| Code | Region |
|------|--------|
| `1` | Northeast |
| `2` | Midwest |
| `3` | South |
| `4` | West |
| `9` | Territories (Puerto Rico, etc.) |

### census_division

| Code | Division |
|------|----------|
| `1` | New England (CT, ME, MA, NH, RI, VT) |
| `2` | Middle Atlantic (NJ, NY, PA) |
| `3` | East North Central (IL, IN, MI, OH, WI) |
| `4` | West North Central (IA, KS, MN, MO, NE, ND, SD) |
| `5` | South Atlantic (DE, DC, FL, GA, MD, NC, SC, VA, WV) |
| `6` | East South Central (AL, KY, MS, TN) |
| `7` | West South Central (AR, LA, OK, TX) |
| `8` | Mountain (AZ, CO, ID, MT, NV, NM, UT, WY) |
| `9` | Pacific (AK, CA, HI, OR, WA) |

### cbsa_type (Core Based Statistical Area)

| Code | Type |
|------|------|
| `1` | Metropolitan Statistical Area (50,000+ core pop) |
| `2` | Micropolitan Statistical Area (10,000-50,000 core pop) |
| `null` | Not in a CBSA (rural) |

### geocode_accuracy

Categorical confidence level for geocode match. **Note:** This column is Float64 in schools data but Int64 in colleges data. Cast to a consistent type before cross-entity comparison.

| Code | Meaning |
|------|---------|
| `1` | High confidence |
| `2` | Medium confidence |
| `3` | Low confidence |
| `4` | Did not geocode |
| `-2` | Not applicable |

> **Codebook correction:** The codebook defines this as a 4-level categorical variable (1-4), not a 0-100 numeric score as previously documented. The prior documentation was inaccurate.

### geocode_accuracy_detailed

| Code | Match Type |
|------|------------|
| `1` | Point address |
| `2` | Street address |
| `3` | Subaddress |
| `4` | Street intersection |
| `5` | Street address extension |
| `6` | Street name |
| `7` | Postal extension |
| `8` | Point of interest |
| `9` | Distance marker |
| `10` | Postal code |
| `11` | Locality |
| `12` | Postal location |
| `-2` | Not applicable |

### cbsa_city (Principal City Indicator)

Indicates whether the school/institution is located in the **principal city** of its Core Based Statistical Area.

| Code | Meaning |
|------|---------|
| `0` | Not in the CBSA's principal city |
| `1` | In the CBSA's principal city |
| `null` | Not in a CBSA or not determined |
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed data |

> **Codebook label discrepancy:** The mirror codebook labels this field as "Metropolitan or micropolitan statistical area (yes/no)", which is misleading since `cbsa` and `cbsa_type` already indicate CBSA membership and type. Empirical verification confirms `cbsa_city` is a principal city indicator: many institutions have a valid `cbsa` code but `cbsa_city=0`, meaning they are in the CBSA but not in its principal city. The variable name `cbsa_city` also supports this interpretation.

**Availability:** Present in census 2000+ files only. Not in census 1990 files.

### lower_chamber_type (State Legislative District Classification)

Legal or statistical area description code for the state legislative district lower chamber. Describes the type of legislative district the school/institution falls within.

| Code | Type |
|------|------|
| `1` | State legislative district |
| `2` | State legislative subdistrict |
| `3` | State house district |
| `4` | Vermont state house district |
| `5` | District |
| `6` | General assembly district |
| `7` | Assembly district |
| `8` | Other geographic entity |

**Availability:** Present in census 2010 files only. Not in census 1990, 2000, or 2020 files. Appears in both schools and colleges NHGIS datasets for the census 2010 vintage.

### class_code (FIPS Place Class)

> **Codebook discrepancy:** The codebook defines different codes than those listed below. The codebook values include: 1=Governmentally active (incorporated), 2=Minor civil division coextensive (incorporated), 3=Consolidated city (incorporated), 4=Minor civil division equivalent (incorporated), 5=Alaska Native village statistical area (incorporated), 6=Independent city, 7=Consolidated city portion, 8=Operationally inactive incorporated place, plus many additional codes (10-86) for American Indian reservations, Alaska Native areas, counties, census-designated places, and minor civil divisions. The simplified mapping below may be inaccurate; consult the codebook for authoritative definitions.

| Code | Type |
|------|------|
| `1` | Governmentally active (incorporated) |
| `2` | Minor civil division coextensive (incorporated) |
| `3` | Consolidated city (incorporated) |
| `4` | Minor civil division equivalent (incorporated) |
| `5` | Alaska Native village statistical area (incorporated) |
| `6` | Independent city |
| `7` | Consolidated city portion |
| `8` | Operationally inactive incorporated place |
| `10`-`16` | American Indian reservations and tribal areas |
| `20`-`23` | Alaska Native statistical areas |
| `30` | Hawaiian home land |
| `40`-`43` | County types |
| `50` | Installation of US Department of Defense |
| `60`-`62` | Minor civil divisions (governmentally active) |
| `70`-`73` | Census-designated places |
| `80`-`86` | Other minor civil divisions and statistical areas |

---

> **STOP — Portal Boundary**
>
> **The variables documented below are NOT available through the Education Data Portal mirrors.** They are available only through direct NHGIS access (free IPUMS registration required at https://www.nhgis.org/). See `data-access.md` for direct access methods.
>
> If your analysis plan relies on census demographic variables (population, poverty, income, race, education attainment, etc.), you **cannot** fetch them through the DAAF mirror system. You must use direct NHGIS access.

---

## Variable Availability by Source

| Source | Geographic Detail | Variables |
|--------|-------------------|-----------|
| Decennial Census (100%) | Block | Age, sex, race, Hispanic origin, household type, housing tenure |
| Decennial Census (Sample) | Block group part (1990-2000) | Income, education, poverty, language, employment |
| ACS 5-Year | Block group | All socioeconomic variables |
| ACS 1-Year | Areas 65K+ | All socioeconomic variables |

## Population Variables

### Total Population

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Total population | P1 (2020), P001 (2010) | Decennial | Denominators, density |
| Population density | Computed | Any | Urban/rural context |

### Age Structure

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Under 5 years | P12 / B01001 | Decennial / ACS | Kindergarten planning |
| 5-17 years | P12 / B01001 | Decennial / ACS | School-age population |
| 18-24 years | P12 / B01001 | Decennial / ACS | College-age, young adults |
| Median age | B01002 | ACS | Community age profile |
| Single year of age | PCT12 | Decennial | Grade-level projections |

**Time series**: Available standardized for basic age groups (1990-2020).

### Sex

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Male / Female | P12 / B01001 | Decennial / ACS | Gender ratios |
| Sex by age | P12 / B01001 | Decennial / ACS | Age-sex pyramids |

## Race and Ethnicity

### Race Categories

| Category | Table | Notes |
|----------|-------|-------|
| White alone | P1, P2 | Not Hispanic |
| Black/African American alone | P1, P2 | |
| American Indian/Alaska Native alone | P1, P2 | |
| Asian alone | P1, P2 | |
| Native Hawaiian/Pacific Islander alone | P1, P2 | |
| Some other race alone | P1, P2 | |
| Two or more races | P1, P2 | Since 2000 only |

### Hispanic/Latino Origin

| Variable | Table | Notes |
|----------|-------|-------|
| Hispanic or Latino (any race) | P2 / B03003 | Ethnicity (not race) |
| Not Hispanic or Latino | P2 / B03003 | |
| Hispanic by race | P2 | Cross-tabulation |

### Race by Hispanic Origin

Common education research categories:

| Category | Derivation |
|----------|------------|
| White, non-Hispanic | White alone AND not Hispanic |
| Black, non-Hispanic | Black alone AND not Hispanic |
| Hispanic (any race) | Hispanic origin |
| Asian, non-Hispanic | Asian alone AND not Hispanic |
| Other/Two or more | Remaining categories |

**Time series notes**:
- Pre-2000: No "two or more races" option
- 1970-1990: Hispanic origin asked separately, race categories differ
- Standardized tables available with adjusted race categories

## Socioeconomic Variables (ACS/Sample)

### Income

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Median household income | B19013 | BG+ | Economic context |
| Per capita income | B19301 | BG+ | Alternative measure |
| Income distribution | B19001 | BG+ | Detailed analysis |
| Family income | B19101 | BG+ | Family economic status |

**Inflation adjustment**: Use Census inflation factors or CPI for real comparisons.

### Poverty

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Persons below poverty | B17001 | BG+ | Poverty rate |
| Children (under 18) in poverty | B17001 | BG+ | Child poverty |
| Poverty ratio categories | C17002 | BG+ | Near-poverty |
| Families below poverty | B17010 | BG+ | Family poverty |

**Universe**: Persons for whom poverty status is determined (excludes GQ).

### Educational Attainment

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Less than HS diploma | B15003 | BG+ | Adult education levels |
| HS diploma (includes equivalency) | B15003 | BG+ | |
| Some college, no degree | B15003 | BG+ | |
| Associate's degree | B15003 | BG+ | |
| Bachelor's degree | B15003 | BG+ | College attainment |
| Graduate/professional degree | B15003 | BG+ | Advanced degrees |
| Educational attainment by sex | B15002 | BG+ | Gender gaps |
| Educational attainment by age | B15001 | Tract+ | Generational differences |

**Population**: Typically 25+ years (completed education).

### Employment

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Unemployment rate | B23025 | BG+ | Economic hardship |
| Labor force participation | B23025 | BG+ | Working-age engagement |
| Employment by industry | B24030 | Tract+ | Local economy |
| Employment by occupation | B24010 | Tract+ | Job types |

**Population**: Usually 16+ years in labor force.

## Language Variables

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Language spoken at home | B16001 | Tract+ | ELL/bilingual context |
| English proficiency | B16004 | Tract+ | LEP population |
| Spanish speakers | B16001 | Tract+ | Hispanic community |
| Asian languages | B16001 | Tract+ | Asian community |
| Linguistic isolation | B16002 | Tract+ | Household-level English |

**Common categories**:
- English only
- Spanish (speaks English "very well" / "well" / "not well" / "not at all")
- Other Indo-European languages
- Asian and Pacific Island languages
- Other languages

## Household and Family Variables

### Household Type

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Family households | P18 / B11001 | Decennial / ACS | Family structure |
| Non-family households | P18 / B11001 | Decennial / ACS | |
| Married-couple families | P18 / B11003 | Decennial / ACS | Two-parent homes |
| Single-parent families | P18 / B11003 | Decennial / ACS | Single-parent households |
| Female householder, no spouse | B11003 | ACS | Female-headed households |

### Household Size

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Average household size | B25010 | ACS | Crowding indicator |
| Persons per room | B25014 | ACS | Housing density |

### Children in Households

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Children under 18 in household | B09002 | BG+ | Child presence |
| Children by family type | B09002 | BG+ | Children in single-parent homes |
| Grandchildren living with grandparent | B10001 | Tract+ | Multigenerational homes |

## Housing Variables

### Tenure

| Variable | Table | Source | Education Use |
|----------|-------|--------|---------------|
| Owner-occupied | H3 / B25003 | Decennial / ACS | Housing stability |
| Renter-occupied | H3 / B25003 | Decennial / ACS | Residential mobility |
| Vacant units | H1 / B25002 | Decennial / ACS | Neighborhood vitality |

### Housing Value and Costs

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Median home value | B25077 | BG+ | Neighborhood wealth |
| Median gross rent | B25064 | BG+ | Rental costs |
| Housing cost burden (>30% income) | B25070 | BG+ | Affordability stress |

### Housing Characteristics

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Year structure built | B25034 | BG+ | Housing age/quality |
| Units in structure | B25024 | BG+ | Multi-family vs. single |
| Rooms per unit | B25017 | BG+ | Housing size |

## Immigration and Nativity

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Native-born | B05002 | BG+ | Immigrant communities |
| Foreign-born | B05002 | BG+ | First-generation |
| Foreign-born, naturalized | B05001 | BG+ | Citizenship status |
| Foreign-born, not citizen | B05001 | BG+ | Non-citizens |
| Year of entry | B05005 | Tract+ | Recent immigrants |
| Place of birth | B05006 | Tract+ | Country of origin |

## Mobility and Migration

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Same residence 1 year ago | B07001 | BG+ | Residential stability |
| Moved within county | B07001 | BG+ | Local mobility |
| Moved from different county | B07001 | BG+ | In-migration |
| Moved from different state | B07001 | BG+ | Interstate migration |
| Moved from abroad | B07001 | BG+ | International migration |

## School Enrollment

| Variable | Table | Level | Education Use |
|----------|-------|-------|---------------|
| Enrolled in school | B14001 | BG+ | School-age enrolled |
| Enrolled in nursery/preschool | B14001 | BG+ | Early childhood |
| Enrolled in kindergarten | B14001 | BG+ | Elementary preparation |
| Enrolled in grades 1-8 | B14001 | BG+ | K-8 enrollment |
| Enrolled in grades 9-12 | B14001 | BG+ | High school enrollment |
| Enrolled in college | B14001 | BG+ | Higher education |
| Private school enrollment | B14002 | Tract+ | Public vs. private |

## Creating Derived Variables

### Common Education Research Indicators

| Indicator | Formula | Variables Needed |
|-----------|---------|------------------|
| Child poverty rate | Children in poverty / Children total | B17001 |
| College attainment rate (25+) | (BA + Grad) / Pop 25+ | B15003 |
| Single-parent household rate | Single-parent families / Families with children | B11003 |
| Linguistic isolation rate | Isolated HH / Total HH | B16002 |
| Foreign-born percentage | Foreign-born / Total pop | B05002 |
| Homeownership rate | Owner-occupied / Occupied units | B25003 |
| Residential stability | Same house / Pop 1+ | B07001 |

### Aggregating to School Districts

When variables not available at school district level:
1. Get tract-level data
2. Identify tracts in district
3. Sum counts; weight averages by population

```python
import polars as pl

# Example: Child poverty rate for school district
result = tracts_in_district.select(
    pl.col("children_in_poverty").sum().alias("poverty_sum"),
    pl.col("children_total").sum().alias("total_sum"),
)
district_child_poverty_rate = result["poverty_sum"][0] / result["total_sum"][0]
```

## Finding Variables in NHGIS

### Data Finder Workflow

1. **Topics filter**: Select subject area (e.g., "Poverty")
2. **Years filter**: Select census year or ACS period
3. **Geographic levels**: Select tract, block group, etc.
4. **Tables**: Browse available tables
5. **View details**: Check universe, variables, notes

### Table Naming Conventions

| Prefix | Source |
|--------|--------|
| P | Decennial - Population |
| H | Decennial - Housing |
| PCT | Decennial - Population (tract+ only) |
| HCT | Decennial - Housing (tract+ only) |
| B | ACS - Detailed tables |
| C | ACS - Collapsed tables |
| S | ACS - Subject tables |

### NHGIS Variable Codes

NHGIS assigns unique codes (e.g., `AJWME001`):
- Check codebook file included in extract
- Codebook maps NHGIS codes to Census table/variable names
