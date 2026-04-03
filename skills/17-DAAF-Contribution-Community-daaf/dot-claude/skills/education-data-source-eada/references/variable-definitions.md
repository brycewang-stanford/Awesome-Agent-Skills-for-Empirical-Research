# EADA Variable Definitions

Detailed definitions for key EADA variables available through the Education Data Portal.

> **CRITICAL: Portal Integer Encoding**
>
> This document describes **Education Data Portal** integer encodings. The Portal converts categorical variables to integers for consistency across sources.
>
> | Variable | Code | Meaning |
> |----------|------|---------|
> | `ath_classification_code` | `1` | NCAA Division I FBS |
> | `ath_classification_code` | `2` | NCAA Division I FCS |
> | `ath_classification_code` | `8` | Other (see `ath_classification_other` for detail) |
> | `fips` | `6` | California |
> | Any variable | `-1` | Missing/not reported |
> | Any variable | `-2` | Not applicable |
> | Any variable | `-3` | Suppressed data |
>
> See the Athletic Classification Codes section below for complete mappings.

## Codebook Authority

> **This document summarizes Portal variable definitions for convenience.** When in doubt,
> consult the authoritative codebook via `get_codebook_url("eada/codebook_colleges_eada_inst-characteristics")`
> from `fetch-patterns.md`. If this document contradicts the codebook or observed data,
> trust the codebook or data (see Truth Hierarchy in `fetch-patterns.md`).

## Institution Identification

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Integer | IPEDS institution identifier (6 digits) |
| `opeid` | String | OPE ID (null for early years, e.g., 2002) |
| `year` | Integer | Reporting year (fiscal year ending) |
| `inst_name` | String | Name of institution |
| `fips` | Integer | State FIPS code (see FIPS codes below) |

> **Note:** There is no `sector` column in EADA Portal data. To filter by institutional
> sector, join with IPEDS directory data on `unitid`.

### State FIPS Codes (Portal Integer Encoding)

| Code | State | Code | State | Code | State |
|------|-------|------|-------|------|-------|
| 1 | Alabama | 18 | Indiana | 35 | New Mexico |
| 2 | Alaska | 19 | Iowa | 36 | New York |
| 4 | Arizona | 20 | Kansas | 37 | North Carolina |
| 5 | Arkansas | 21 | Kentucky | 38 | North Dakota |
| 6 | California | 22 | Louisiana | 39 | Ohio |
| 8 | Colorado | 23 | Maine | 40 | Oklahoma |
| 9 | Connecticut | 24 | Maryland | 41 | Oregon |
| 10 | Delaware | 25 | Massachusetts | 42 | Pennsylvania |
| 11 | District of Columbia | 26 | Michigan | 44 | Rhode Island |
| 12 | Florida | 27 | Minnesota | 45 | South Carolina |
| 13 | Georgia | 28 | Mississippi | 46 | South Dakota |
| 15 | Hawaii | 29 | Missouri | 47 | Tennessee |
| 16 | Idaho | 30 | Montana | 48 | Texas |
| 17 | Illinois | 31 | Nebraska | 49 | Utah |
| | | 32 | Nevada | 50 | Vermont |
| | | 33 | New Hampshire | 51 | Virginia |
| | | 34 | New Jersey | 53 | Washington |
| | | | | 54 | West Virginia |
| | | | | 55 | Wisconsin |
| | | | | 56 | Wyoming |

**Territories and Special Codes:**
| Code | Jurisdiction |
|------|--------------|
| 60 | American Samoa |
| 66 | Guam |
| 69 | Northern Mariana Islands |
| 72 | Puerto Rico |
| 78 | Virgin Islands |

### Athletic Classification Codes (Portal Integer Encoding)

| Code | Athletic Division |
|------|-------------------|
| 1 | NCAA Division I FBS |
| 2 | NCAA Division I FCS |
| 3 | NCAA Division I (without football) |
| 4 | NCAA Division II (with football) |
| 5 | NCAA Division II (without football) |
| 6 | NCAA Division III (with football) |
| 7 | NCAA Division III (without football) |
| 8 | Other (see `ath_classification_other` field) |
| 9 | NAIA Division I |
| 10 | NAIA Division II |
| 11 | NAIA Division III |
| 12 | NJCAA Division I |
| 13 | NJCAA Division II |
| 14 | NJCAA Division III |
| 15 | NCCAA Division I |
| 16 | NCCAA Division II |
| 17 | CCCAA (California Community Colleges) |
| 18 | Independent |
| 19 | NWAC (Northwest Athletic Conference) |
| 20 | USCAA (United States Collegiate Athletic Association) |
| -1 | Missing/not reported |
| -2 | Not applicable |
| -3 | Suppressed |

> **Note:** Code `8` (Other) is used for institutions that don't fit the standard classifications. Check the `ath_classification_other` string field for additional detail.

## Participation Variables

### Institution-Level Participation

| Variable | Type | Description |
|----------|------|-------------|
| `undup_athpartic_men` | Integer | Unduplicated count of male participants across all sports |
| `undup_athpartic_women` | Integer | Unduplicated count of female participants across all sports |
| `undup_athpartic_total` | Integer | Total unduplicated participants (often `-1` coded; may need to sum men + women) |
| `athpartic_men` | Integer | Duplicated (sport-level sum) male participants |
| `athpartic_women` | Integer | Duplicated (sport-level sum) female participants |
| `athpartic_coed_men` | Integer | Male participants on coed teams |
| `athpartic_coed_women` | Integer | Female participants on coed teams |
| `sum_athpartic_men` | Integer | Sum of sport-level male participants |
| `sum_athpartic_women` | Integer | Sum of sport-level female participants |

### Enrollment Context

| Variable | Type | Description |
|----------|------|-------------|
| `enrollment_men` | Integer | Male undergraduate enrollment |
| `enrollment_women` | Integer | Female undergraduate enrollment |
| `enrollment_total` | Integer | Total undergraduate enrollment |

### Definition: "Participant"

A participant is a student who:
- Is listed on the varsity team roster
- As of the first day of the first scheduled contest
- During the reporting year

**Includes**:
- Scholarship athletes
- Walk-ons
- Redshirts (if on roster)

**Excludes**:
- Practice players not on varsity roster
- Club sport participants
- Junior varsity (unless no varsity)

### Unduplicated vs. Duplicated

- **Unduplicated**: Multi-sport athletes counted once for institution total
- **Duplicated**: Summing sport-level data will double-count multi-sport athletes

## Coaching Variables

### Head Coach Counts

The Portal naming convention for coach counts is `{team}_{status}{role}_{gender}`:
- `{team}`: `men_`, `women_`, `coed_`
- `{status}`: `ft` (full-time), `pt` (part-time)
- `{role}`: `hdcoach` (head coach)
- `{gender}`: `_male`, `_fem`

Additional categories exist for university employment status:
- `{team}_hdcoach_ftuniemp_{gender}`: Full-time university employee, head coaching assignment
- `{team}_hdcoach_ptuniemp_{gender}`: Part-time university employee, head coaching assignment

| Variable | Type | Description |
|----------|------|-------------|
| `men_fthdcoach_male` | Integer | Full-time male head coaches of men's teams |
| `men_pthdcoach_male` | Integer | Part-time male head coaches of men's teams |
| `men_fthdcoach_fem` | Integer | Full-time female head coaches of men's teams |
| `men_pthdcoach_fem` | Integer | Part-time female head coaches of men's teams |
| `men_hdcoach_ftuniemp_male` | Integer | FT university employee male head coaches, men's teams |
| `men_hdcoach_ptuniemp_male` | Integer | PT university employee male head coaches, men's teams |
| `men_hdcoach_ftuniemp_fem` | Integer | FT university employee female head coaches, men's teams |
| `men_hdcoach_ptuniemp_fem` | Integer | PT university employee female head coaches, men's teams |
| `men_total_hdcoach` | Integer | Total head coaches of men's teams |
| `women_fthdcoach_male` | Integer | Full-time male head coaches of women's teams |
| `women_pthdcoach_male` | Integer | Part-time male head coaches of women's teams |
| `women_fthdcoach_fem` | Integer | Full-time female head coaches of women's teams |
| `women_pthdcoach_fem` | Integer | Part-time female head coaches of women's teams |
| `women_hdcoach_ftuniemp_male` | Integer | FT university employee male head coaches, women's teams |
| `women_hdcoach_ptuniemp_male` | Integer | PT university employee male head coaches, women's teams |
| `women_hdcoach_ftuniemp_fem` | Integer | FT university employee female head coaches, women's teams |
| `women_hdcoach_ptuniemp_fem` | Integer | PT university employee female head coaches, women's teams |
| `women_total_hdcoach` | Integer | Total head coaches of women's teams |
| `coed_fthdcoach_male` | Integer | Full-time male head coaches of coed teams |
| `coed_pthdcoach_male` | Integer | Part-time male head coaches of coed teams |
| `coed_fthdcoach_fem` | Integer | Full-time female head coaches of coed teams |
| `coed_pthdcoach_fem` | Integer | Part-time female head coaches of coed teams |
| `coed_total_hdcoach` | Integer | Total head coaches of coed teams |
| `num_hdcoach_men` | Integer | Number of head coaches, men's teams |
| `num_hdcoach_women` | Integer | Number of head coaches, women's teams |
| `num_hdcoach_coed` | Integer | Number of head coaches, coed teams |

**Summary (aggregate) variables:**

| Variable | Type | Description |
|----------|------|-------------|
| `sum_fthdcoach_male` | Integer | Sum of full-time male head coaches across all teams |
| `sum_pthdcoach_male` | Integer | Sum of part-time male head coaches across all teams |
| `sum_fthdcoach_fem` | Integer | Sum of full-time female head coaches across all teams |
| `sum_pthdcoach_fem` | Integer | Sum of part-time female head coaches across all teams |
| `sum_total_hdcoach` | Integer | Sum of all head coaches across all teams |

### Assistant Coach Counts

Same structure as head coaches with `ascoach` replacing `hdcoach` in variable names (e.g., `men_ftascoach_male`, `women_ftascoach_fem`, `sum_total_ascoach`).

### Definition: Full-Time vs. Part-Time

| Status | Definition |
|--------|------------|
| **Full-time** | Employed by institution on a full-time basis (regardless of coaching assignment) |
| **Part-time** | Not full-time employees; may include graduate assistants |

**Note**: A full-time employee who coaches part-time is counted as full-time.

## Salary Variables

### Coach Salary Averages

| Variable | Type | Description |
|----------|------|-------------|
| `hdcoach_salary_men` | Integer | Average annual salary of head coaches of men's teams |
| `hdcoach_salary_women` | Integer | Average annual salary of head coaches of women's teams |
| `hdcoach_salary_coed` | Integer | Average annual salary of head coaches of coed teams |
| `hdcoach_sal_fte_men` | Integer | Head coach salary per FTE, men's teams |
| `hdcoach_sal_fte_women` | Integer | Head coach salary per FTE, women's teams |
| `hdcoach_sal_fte_coed` | Integer | Head coach salary per FTE, coed teams |
| `ascoach_salary_men` | Integer | Average annual salary of assistant coaches of men's teams |
| `ascoach_salary_women` | Integer | Average annual salary of assistant coaches of women's teams |
| `ascoach_salary_coed` | Integer | Average annual salary of assistant coaches of coed teams |
| `ascoach_sal_fte_men` | Integer | Assistant coach salary per FTE, men's teams |
| `ascoach_sal_fte_women` | Integer | Assistant coach salary per FTE, women's teams |
| `ascoach_sal_fte_coed` | Integer | Assistant coach salary per FTE, coed teams |

### FTE Coach Counts

| Variable | Type | Description |
|----------|------|-------------|
| `fte_hdcoach_men` | Float | FTE head coaches, men's teams |
| `fte_hdcoach_women` | Float | FTE head coaches, women's teams |
| `fte_hdcoach_coed` | Float | FTE head coaches, coed teams |
| `fte_ascoach_men` | Float | FTE assistant coaches, men's teams |
| `fte_ascoach_women` | Float | FTE assistant coaches, women's teams |
| `fte_ascoach_coed` | Float | FTE assistant coaches, coed teams |

### Definition: Salary

**Includes**:
- Base salary
- Bonuses from the institution
- Any supplemental pay from institutional funds

**Excludes**:
- Income from camps/clinics (unless institutional compensation)
- Media/broadcast contracts
- Apparel/equipment deals
- Outside speaking fees
- Deferred compensation
- Benefits (health insurance, retirement)

### Calculation Method

```
Average Salary = Total Salaries Paid / Number of Paid Coaching Positions
```

**Note**: Volunteer coaches (0 salary) may or may not be excluded from denominator depending on reporting practice.

## Expense Variables

### Total Expenses

| Variable | Type | Description |
|----------|------|-------------|
| `ath_exp_men` | Integer | Total expenses attributable to men's teams |
| `ath_exp_women` | Integer | Total expenses attributable to women's teams |
| `ath_exp_coed_men` | Float | Total expenses for coed teams, men's portion |
| `ath_exp_coed_women` | Float | Total expenses for coed teams, women's portion |
| `ath_exp_menall` | Float | Total expenses for men (including coed portion) |
| `ath_exp_womenall` | Float | Total expenses for women (including coed portion) |
| `ath_total_exp_menwomen` | Integer | Combined total expenses, men's + women's teams |
| `ath_total_exp_coed` | Integer | Total expenses, coed teams |
| `ath_total_exp_all` | Integer | Total expenses, all teams |
| `ath_tot_exp_all_notalloc` | Integer | Total expenses, not allocated by gender |
| `ath_grnd_total_exp` | Integer | Grand total of all athletic expenses |

### Operating Expenses

| Variable | Type | Description |
|----------|------|-------------|
| `ath_opexp_menwomen` | Integer | Operating expenses, men's + women's teams |
| `ath_opexp_coed` | Integer | Operating expenses, coed teams |
| `ath_total_opexp_allteams` | Integer | Total operating expenses, all teams |
| `ath_opexp_perpart_men` | Float | Operating expense per participant, men's teams |
| `ath_opexp_perpart_women` | Float | Operating expense per participant, women's teams |
| `ath_opexp_perpart_menall` | Float | Operating expense per participant, men (incl. coed) |
| `ath_opexp_perpart_womenall` | Float | Operating expense per participant, women (incl. coed) |
| `ath_opexp_perpart_coed_men` | Float | Operating expense per participant, coed teams (men) |
| `ath_opexp_perpart_coed_women` | Float | Operating expense per participant, coed teams (women) |
| `ath_opexp_perteam_men` | Integer | Operating expense per team, men's teams |
| `ath_opexp_perteam_women` | Integer | Operating expense per team, women's teams |
| `ath_opexp_perteam_menall` | Float | Operating expense per team, men (incl. coed) |
| `ath_opexp_perteam_womenall` | Float | Operating expense per team, women (incl. coed) |

### Definition: Operating Expenses

**Includes**:
- Team travel (transportation, lodging, meals)
- Equipment and uniforms
- Game officials
- Game-day support personnel

**Excludes**:
- Coaching salaries (separate)
- Athletic scholarships (separate)
- Facilities (capital)
- Administrative overhead

### Recruiting Expenses

| Variable | Type | Description |
|----------|------|-------------|
| `recruitexp_men` | Integer | Recruiting expenses for men's teams |
| `recruitexp_women` | Integer | Recruiting expenses for women's teams |
| `recruitexp_coed` | Integer | Recruiting expenses for coed teams |
| `recruitexp_total` | Integer | Total recruiting expenses |

### Definition: Recruiting Expenses

**Includes**:
- Travel for coaching staff on recruiting trips
- Lodging and meals during recruiting
- Prospect visit expenses (on-campus)
- Communication costs
- Recruiting services/subscriptions

## Revenue Variables

### Team Revenues

| Variable | Type | Description |
|----------|------|-------------|
| `ath_rev_men` | Integer | Revenues attributable to men's teams |
| `ath_rev_women` | Integer | Revenues attributable to women's teams |
| `ath_rev_coed_men` | Float | Revenues for coed teams, men's portion |
| `ath_rev_coed_women` | Float | Revenues for coed teams, women's portion |
| `ath_rev_menall` | Float | Total revenues for men (including coed portion) |
| `ath_rev_womenall` | Float | Total revenues for women (including coed portion) |
| `ath_total_rev_menwomen` | Integer | Combined total revenues, men's + women's teams |
| `ath_total_rev_coed` | Integer | Total revenues, coed teams |
| `ath_total_rev_all` | Integer | Total revenues, all teams |
| `ath_tot_rev_all_notalloc` | Integer | Total revenues, not allocated by gender |
| `ath_grnd_total_rev` | Integer | Grand total of all athletic revenues |

### Definition: Revenue

**Includes**:
- Ticket sales
- Game guarantees received
- Broadcast rights (attributed portion)
- NCAA/conference distributions (attributed)
- Program sales
- Concessions (if tracked by sport)
- Donations restricted to specific sports

**Excludes**:
- Student fees (typically)
- General institutional support
- Unrestricted donations

### Revenue Attribution Challenges

Many revenue sources are shared (conference distributions, multimedia rights) and attribution varies by institution.

## Athletic Aid Variables

### Financial Assistance

| Variable | Type | Description |
|----------|------|-------------|
| `ath_stuaid_men` | Integer | Total athletic aid to male students |
| `ath_stuaid_women` | Integer | Total athletic aid to female students |
| `ath_stuaid_coed` | Integer | Athletic aid for coed teams |
| `ath_stuaid_total` | Integer | Total athletic aid |
| `ath_stuaid_men_ratio` | Float | Ratio of male aid to total |
| `ath_stuaid_women_ratio` | Float | Ratio of female aid to total |
| `ath_stuaid_coed_ratio` | Float | Ratio of coed aid to total |

### Definition: Athletic Aid

Athletic student aid includes:
- Scholarships specifically for athletics
- Grants-in-aid designated for athletes
- Tuition waivers awarded for athletic participation
- Room, board, and required fees if athletically related

**Excludes**:
- Need-based aid that happens to go to athletes
- Academic merit aid to athletes
- Non-athletic institutional aid

### Equivalency Calculation

For Division I:
```
Full Scholarship Equivalency = Total Aid Dollars / Cost of Full Scholarship
```

**Note**: EADA reports total dollars, not equivalencies.

## Calculated Fields

### Common Calculations

```python
import polars as pl

# Total unduplicated participation
# Note: undup_athpartic_total is often coded -1; calculate manually
total_partic = pl.col("undup_athpartic_men") + pl.col("undup_athpartic_women")

# Female participation share
female_share = pl.col("undup_athpartic_women") / total_partic

# Per-athlete operating expense (pre-calculated in data)
# Use ath_opexp_perpart_men, ath_opexp_perpart_women directly

# Aid proportionality
aid_share_female = pl.col("ath_stuaid_women") / (
    pl.col("ath_stuaid_men") + pl.col("ath_stuaid_women")
)
# Note: ath_stuaid_women_ratio is pre-calculated in the data
```

### Additional Miscellaneous Variables

| Variable | Type | Description |
|----------|------|-------------|
| `num_sports` | Integer | Number of sports offered (null for some years) |

## Missing Value Interpretation (Portal Integer Encoding)

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | State/institution did not report; value unknown |
| `-2` | Not applicable | Item doesn't apply to this institution |
| `-3` | Suppressed | Data suppressed for privacy protection |
| `NULL` | Null value | Genuinely not present in source data |
| `0` | Zero | Reported as zero (institution has no activity) |

### Handling Missing Data

```python
import polars as pl

# Identify coded missing values
missing_codes = [-1, -2, -3]

# Filter to valid data only for a specific column
df_valid = df.filter(~pl.col("undup_athpartic_women").is_in(missing_codes))

# Or convert coded values to null for calculations
df_clean = df.with_columns(
    pl.when(pl.col("ath_stuaid_men").is_in(missing_codes))
    .then(None)
    .otherwise(pl.col("ath_stuaid_men"))
    .alias("ath_stuaid_men_clean")
)
```

## Data Type Notes

- **Integers**: Count variables (participants, coaches)
- **Decimals**: Financial variables (may have cents)
- **Strings**: Names, identifiers
- **Years**: Fiscal year ending (e.g., 2022 = FY2021-22)

## Joining with Other Data

### IPEDS Join Key

Use `unitid` to join with IPEDS data for:
- Enrollment figures
- Institutional characteristics
- Carnegie classification
- Geographic details

```python
import polars as pl

# Example join with IPEDS
eada_df.join(ipeds_df, on=["unitid", "year"], how="left")
```

### Year Alignment

EADA reporting year may not align perfectly with IPEDS year. Check documentation for specific alignment requirements.
