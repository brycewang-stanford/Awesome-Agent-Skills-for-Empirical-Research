# IPEDS Financial Aid Data

Understanding student financial aid data, net price calculations, and their limitations.

## Contents

- [Financial Aid Survey Overview](#financial-aid-survey-overview)
- [Student Populations](#student-populations)
- [Aid Types](#aid-types)
- [Net Price](#net-price)
- [Cost of Attendance](#cost-of-attendance)
- [Military Benefits](#military-benefits)
- [Common Analysis Issues](#common-analysis-issues)
- [Variable Reference](#variable-reference)

## Financial Aid Survey Overview

The Student Financial Aid (SFA) survey collects:
- Counts of students receiving different types of aid
- Total amounts awarded by aid type
- Average amounts calculated from these data

### Collection Period

Winter collection (December-February) for the prior academic year.

### Reporting Requirements

All Title IV institutions must report SFA data.

### Key Data Elements

1. Number of students receiving aid (by type)
2. Total amount of aid awarded (by type)
3. Average award = Total amount / Number receiving

## Student Populations

**Critical**: Different data elements use different student populations.

### Population Definitions

| Population | Definition | Primary Use |
|------------|------------|-------------|
| All undergraduates | All enrolled undergrads | Total aid picture |
| Full-time first-time (FTFT) | First-time, full-time, degree-seeking | Net price calculation |
| Full-time undergraduates | Full-time, degree-seeking | Comparative analysis |
| Part-time undergraduates | Part-time, degree-seeking | Limited reporting |
| Graduate students | Master's and doctoral | Separate from undergrad |

### Why Different Populations Matter

| Population | Pros | Cons |
|------------|------|------|
| All undergrads | Most comprehensive | Heterogeneous mix |
| FTFT only | Comparable across institutions | Small, selective group |
| Full-time only | More comparable | Misses PT students |

### First-Time Full-Time Limitation

Net price and many aid statistics use only FTFT students who:
- Never attended college before
- Started full-time
- Are degree/certificate-seeking

**At community colleges**, this may be <25% of students.

## Aid Types

### Grant Aid (Gift Aid)

Does not need to be repaid.

| Type | Source | Description |
|------|--------|-------------|
| Pell Grant | Federal | Need-based, up to ~$7,400/year |
| FSEOG | Federal | Supplemental grant, need-based |
| Other federal grants | Federal | Various programs |
| State grants | State | Varies by state |
| Local grants | Local | Varies by locality |
| Institutional grants | Institution | School-funded aid |

### Federal Loans

Must be repaid.

| Type | Description | Interest |
|------|-------------|----------|
| Direct Subsidized | Need-based, no interest while enrolled | Government pays |
| Direct Unsubsidized | Not need-based | Student pays |
| Direct PLUS | Parent loans for undergrads | Higher rate |
| Perkins | Campus-based (discontinued) | Low rate |

### Work-Study

Federal Work-Study program:
- Part-time employment
- Usually need-based
- Institution administers

### Aid Award Statistics

```python
# Average award calculation
avg_grant = total_grant_amount / number_receiving_grants

# Percent receiving aid
pct_receiving = students_with_aid / total_students * 100
```

## Net Price

### Definition

**Net Price = Cost of Attendance - Grant Aid Received**

This represents what students actually pay after grants (but before loans).

### Calculation Population

Net price is calculated ONLY for:
- First-time, full-time degree/certificate-seeking undergraduates
- Who were awarded any Title IV aid

**Excludes**:
- Part-time students
- Transfer students
- Students receiving no Title IV aid (full-pay students)
- Non-degree students

### Net Price by Income Level

IPEDS reports net price by family income quintile:

| Income Level | Income Range |
|--------------|--------------|
| $0 - $30,000 | Lowest income |
| $30,001 - $48,000 | Low-middle income |
| $48,001 - $75,000 | Middle income |
| $75,001 - $110,000 | Upper-middle income |
| $110,001 and above | Highest income |

### Why Net Price by Income Matters

```python
# Example showing why average net price is misleading
avg_net_price = 15000  # Overall average

# But by income level:
net_price_low_income = 8000    # After Pell, institutional aid
net_price_high_income = 22000  # Little grant aid

# Average masks important variation
```

### Net Price Limitations

| Limitation | Implication |
|------------|-------------|
| FTFT only | Not representative of all students |
| Title IV recipients only | Excludes full-pay students |
| Published vs actual | Individual packages vary widely |
| Excludes loans | Not total cost |
| Prior year data | May not reflect current prices |

### Interpreting Net Price

```python
# What net price tells you
net_price = sticker_price - grants

# What it doesn't tell you
# - Whether students can afford it
# - Loan amounts needed
# - Out-of-pocket costs
# - Impact of room and board choices
```

## Cost of Attendance

### Components

| Component | Description |
|-----------|-------------|
| Tuition and fees | Published tuition + required fees |
| Room and board | On-campus or estimated off-campus |
| Books and supplies | Estimated annual cost |
| Other expenses | Transportation, personal, etc. |

### Variations

| Student Type | Room/Board |
|--------------|------------|
| On-campus | On-campus rates |
| Off-campus (not with family) | Estimated local costs |
| Off-campus (with family) | Usually lower estimate |

### COA in Net Price Calculation

```python
# Net price components
coa = tuition_fees + room_board + books_supplies + other
net_price = coa - total_grant_aid
```

### Published vs Actual

| Measure | Description | Use |
|---------|-------------|-----|
| Published tuition | Sticker price | Comparison |
| Net tuition | After institutional discounts | Closer to reality |
| Net price | After all grants | What families pay |
| Out-of-pocket | After grants and loans | True cash needed |

## Military Benefits

### Types Tracked

| Benefit | Description |
|---------|-------------|
| Post-9/11 GI Bill | Veterans, service members |
| Yellow Ribbon | Institutional supplements |
| DoD Tuition Assistance | Active duty |
| Other military | Various programs |

### Data Collection

- Count of students receiving benefits
- Separate from other aid categories
- Graduate and undergraduate

### Limitation

Military benefits recipients may also receive other aid; avoid double-counting.

## Common Analysis Issues

### Issue 1: Comparing Net Price Across Institution Types

**Problem**: Different student populations make comparison misleading.

| Institution Type | Net Price Population |
|------------------|---------------------|
| Selective 4-year | FTFT is most students |
| Community college | FTFT is minority |
| For-profit | Variable enrollment patterns |

**Solution**: Note population differences; compare within peer groups.

### Issue 2: Average vs Distribution

**Problem**: Average net price hides important variation.

```python
# Hypothetical examples
# Institution A: Everyone pays $15,000
avg_a = 15000

# Institution B: Half pay $5,000, half pay $25,000
avg_b = 15000  # Same average, very different experience
```

**Solution**: Look at net price by income level.

### Issue 3: Full-Pay Students Not Included

**Problem**: Students not receiving Title IV aid are excluded.

| Group | Excluded Because |
|-------|-----------------|
| Wealthy families | Don't file FAFSA |
| International students | Not Title IV eligible |
| Undocumented students | Not Title IV eligible |

**Impact**: At wealthy institutions, net price may overstate what the full student body pays.

### Issue 4: Institutional Aid Variation

**Problem**: Institutional aid varies widely by student characteristics.

| Factor | Impact on Institutional Aid |
|--------|----------------------------|
| Academic merit | May get more aid |
| Athletic recruitment | May get more aid |
| Income level | Need-based aid varies |
| State residency | May affect aid |

**Solution**: Net price by income shows some of this variation.

### Issue 5: Debt vs Net Price

**Problem**: Low net price doesn't mean no debt.

```python
# Example
net_price = 12000  # After grants
pell_grant = 6000
institutional_grant = 4000
# Student needs $12,000 more
# Options: loans, work, family contribution

loans_taken = 8000  # Typical
out_of_pocket = 4000
```

**Solution**: Consider loan data alongside net price.

### Issue 6: Part-Time Students

**Problem**: Part-time students excluded from net price but:
- Are majority at many schools
- Have different aid patterns
- Face different cost structures

**Solution**: Note this limitation; use total aid data for broader picture.

## Data Interpretation Examples

### Comparing Two Institutions

```python
# Institution A (selective private)
net_price_a = 25000
pct_ftft = 80  # FTFT is 80% of students
interpretation: net_price reflects most students

# Institution B (community college)
net_price_b = 8000
pct_ftft = 20  # FTFT is 20% of students
interpretation: net_price reflects minority of students
```

### Analyzing Aid Effectiveness

```python
# Equity analysis
gap = net_price_high_income - net_price_low_income

# Positive gap = higher income pays more (progressive)
# Negative gap = lower income pays more (regressive)
# Zero = same net price regardless of income
```

### Grant Aid Coverage

```python
# What share of costs are covered by grants?
grant_coverage = total_grants / cost_of_attendance * 100

# High coverage = more affordable
# Low coverage = more loans/family contribution needed
```

## Variable Reference

> **IMPORTANT:** The Portal does NOT use NCES survey variable names (e.g., `scugffn`, `npist1`).
> Instead, the Portal restructures SFA data into **long/tidy format** with dimension columns
> (coded integers) and measure columns (counts, amounts, rates). NCES wide-format variables
> like `npist1`-`npist5` become rows distinguished by `income_level` codes 1-5.
>
> Multiple SFA-related datasets exist in the Portal:
> - `ipeds/colleges_ipeds_sfa_ftft` — FTFT student aid (1999-2017)
> - `ipeds/colleges_ipeds_sfa_grants_and_net_price` — Grants and net price (2008-2021)
> - `ipeds/colleges_ipeds_sfa_all_undergrads` — All undergrad aid (2007-2017)
> - `ipeds/colleges_ipeds_sfa_by_living_arrangement` — Aid by living arrangement (2008-2017)
> - `ipeds/colleges_ipeds_sfa_by_tuition_type` — Aid by tuition type (1999-2017)
>
> Use `get_codebook_url()` from `fetch-patterns.md` to download codebooks:
> ```python
> url = get_codebook_url("ipeds/codebook_colleges_ipeds_sfa_grants_and_net_price")
> ```

### Portal Column Reference by Dataset (Verified)

#### SFA FTFT (`sfa_ftft`) — 12 columns

| Portal Column | Type | Description |
|---------------|------|-------------|
| `unitid` | Int64 | Institution identifier |
| `year` | Int64 | Data year |
| `fips` | Int64 | State FIPS code |
| `type_of_aid` | Int64 | Aid type code (see coded values below) |
| `ftpt` | Int64 | Full-time/part-time status (coded) |
| `level_of_study` | Int64 | Level of study (coded) |
| `class_level` | Int64 | Class level (coded) |
| `degree_seeking` | Int64 | Degree-seeking status (coded) |
| `number_of_students` | Int64 | Count of students receiving this aid type |
| `percent_of_students` | Float64 | Proportion of students receiving aid |
| `average_amount` | Float64 | Average award amount (dollars) |
| `total_amount` | Float64 | Total amount awarded (dollars) |

**`type_of_aid` codes in this dataset:** 1, 2, 3, 4, 5, 7, 8, 10, 11, 12

> **Note on `type_of_aid` codes:** These are integer codes identifying aid categories. Definitions vary by dataset. In `sfa_grants_and_net_price`, code `9` = **all grant and scholarship aid** (Pell + institutional + state/local combined) -- this is NOT Pell-specific. Consult the codebook for the specific dataset you are using: `get_codebook_url("ipeds/codebook_colleges_ipeds_sfa_ftft")`.

#### SFA Grants and Net Price (`sfa_grants_and_net_price`) — 15 columns

| Portal Column | Type | Description |
|---------------|------|-------------|
| `unitid` | Int64 | Institution identifier |
| `year` | Int64 | Data year |
| `fips` | Int64 | State FIPS code |
| `type_of_aid` | Int64 | Aid type code (3 or 9 in this dataset) |
| `income_level` | Int64 | Income bracket code (see below) |
| `ftpt` | Int64 | Full-time/part-time status (coded) |
| `level_of_study` | Int64 | Level of study (coded) |
| `class_level` | Int64 | Class level (coded) |
| `degree_seeking` | Int64 | Degree-seeking status (coded) |
| `tuition_type` | Int64 | Tuition type (coded) |
| `number_of_students` | Int64 | Count of students in group |
| `number_receiving_grants` | Int64 | Count receiving grants |
| `total_grant` | Int64 | Total grant amount (dollars) |
| `average_grant` | Int64 | Average grant amount (dollars) |
| `net_price` | Int64 | Net price (COA minus grants, dollars) |

**`income_level` codes:** 1=$0-$30,000, 2=$30,001-$48,000, 3=$48,001-$75,000, 4=$75,001-$110,000, 5=$110,001+, 99=Total

#### SFA All Undergraduates (`sfa_all_undergrads`) — 10 columns

| Portal Column | Type | Description |
|---------------|------|-------------|
| `unitid` | Int64 | Institution identifier |
| `year` | Int64 | Data year |
| `fips` | Int64 | State FIPS code |
| `type_of_aid` | Int64 | Aid type code (3, 5, or 11 in this dataset) |
| `ftpt` | Int64 | Full-time/part-time status (coded) |
| `level_of_study` | Int64 | Level of study (coded) |
| `number_of_students` | Int64 | Count of students |
| `percent_of_students` | Float64 | Proportion of students |
| `average_amount` | Float64 | Average award amount (dollars) |
| `total_amount` | Float64 | Total amount awarded (dollars) |

#### SFA by Living Arrangement (`sfa_by_living_arrangement`) — 11 columns

| Portal Column | Type | Description |
|---------------|------|-------------|
| `unitid` | Int64 | Institution identifier |
| `year` | Int64 | Data year |
| `fips` | Int64 | State FIPS code |
| `type_of_aid` | Int64 | Aid type code |
| `living_arrangement` | Int64 | Living arrangement code |
| `ftpt` | Int64 | Full-time/part-time status (coded) |
| `level_of_study` | Int64 | Level of study (coded) |
| `class_level` | Int64 | Class level (coded) |
| `degree_seeking` | Int64 | Degree-seeking status (coded) |
| `tuition_type` | Int64 | Tuition type (coded) |
| `number_of_students` | Int64 | Count of students |

#### SFA by Tuition Type (`sfa_by_tuition_type`) — 12 columns

| Portal Column | Type | Description |
|---------------|------|-------------|
| `unitid` | Int64 | Institution identifier |
| `year` | Int64 | Data year |
| `fips` | Int64 | State FIPS code |
| `tuition_type` | Int64 | Tuition type code |
| `type_of_cohort` | Int64 | Cohort type code |
| `ftpt` | Int64 | Full-time/part-time status (coded) |
| `level_of_study` | Int64 | Level of study (coded) |
| `class_level` | Int64 | Class level (coded) |
| `degree_seeking` | Int64 | Degree-seeking status (coded) |
| `number_of_students` | Int64 | Count of students |
| `percent_of_cohort` | Float64 | Proportion of cohort |
| `percent_of_undergrads` | Float64 | Proportion of all undergrads |

### How NCES Variables Map to Portal Structure

The Portal converts NCES wide-format variables into long/tidy rows. For example:

**Student counts** — NCES has separate variables per aid type (`scugpel` for Pell, `scugfsl` for federal loans, etc.). The Portal stores all of these as `number_of_students` rows differentiated by `type_of_aid` code:

| NCES Variable | Portal Equivalent |
|---------------|-------------------|
| `scugffn` | `number_of_students` in `sfa_grants_and_net_price` (filtered by `type_of_aid`) |
| `scugrad` | `number_of_students` in `sfa_ftft` (filtered by `type_of_aid`) |
| `scugpel` | `number_of_students` in `sfa_ftft` where `type_of_aid` = Pell code |
| `scugfsl` | `number_of_students` in `sfa_ftft` where `type_of_aid` = federal loan code |

**Aid amounts** — similarly collapsed:

| NCES Variable | Portal Equivalent |
|---------------|-------------------|
| `upgrnta` | `average_amount` in `sfa_all_undergrads` (filtered by `type_of_aid`) |
| `upgrnt` | `total_amount` in `sfa_all_undergrads` (filtered by `type_of_aid`) |
| `uagrnta` | `average_amount` in `sfa_ftft` (filtered by `type_of_aid`) |
| `uagrntt` | `total_amount` in `sfa_ftft` (filtered by `type_of_aid`) |

**Net price by income** — NCES uses `npist1`-`npist5`; the Portal uses `net_price` column with `income_level` dimension:

| NCES Variable | Portal Equivalent |
|---------------|-------------------|
| `npist1` | `net_price` where `income_level` = 1 ($0-$30K) |
| `npist2` | `net_price` where `income_level` = 2 ($30K-$48K) |
| `npist3` | `net_price` where `income_level` = 3 ($48K-$75K) |
| `npist4` | `net_price` where `income_level` = 4 ($75K-$110K) |
| `npist5` | `net_price` where `income_level` = 5 ($110K+) |
| `npgrn1`-`npgrn5` | `number_of_students` where `income_level` = 1-5 |

### Querying Net Price by Income (Example)

```python
import polars as pl

MIRROR = "https://huggingface.co/datasets/brhkim/education_data_portal_mirror/resolve/main"
url = f"{MIRROR}/ipeds/colleges_ipeds_sfa_grants_and_net_price.parquet"
df = pl.read_parquet(url)

# Net price by income level for a specific institution and year
net_prices = (
    df.filter(
        (pl.col("unitid") == 166027)  # Example: MIT
        & (pl.col("year") == 2020)
        & (pl.col("income_level").is_in([1, 2, 3, 4, 5]))
        & (pl.col("type_of_aid") == 9)
    )
    .select("income_level", "net_price", "number_of_students")
    .sort("income_level")
)
```

### Cost Variables

Cost of attendance components are in the **tuition/fees datasets**, not SFA datasets:
- `ipeds/colleges_ipeds_ay_tuition_fees` — Academic year tuition and fees
- `ipeds/colleges_ipeds_ay_room_board_other` — Room, board, and other expenses

Consult those codebooks for column names:
```python
url = get_codebook_url("ipeds/codebook_colleges_ipeds_ay_tuition_fees")
```

#### NCES Cost Variable Names (for reference only)

These appear in NCES documentation but are NOT used in the Portal:

| NCES Name | Description | Portal Dataset |
|-----------|-------------|----------------|
| `tuition2` | In-state tuition and fees | `ay_tuition_fees` |
| `tuition3` | Out-of-state tuition and fees | `ay_tuition_fees` |
| `roomamt` | Room charges | `ay_room_board_other` |
| `boardamt` | Board charges | `ay_room_board_other` |
| `bksupply` | Books and supplies estimate | `ay_room_board_other` |
| `rmbrdamt` | Room and board combined | `ay_room_board_other` |
