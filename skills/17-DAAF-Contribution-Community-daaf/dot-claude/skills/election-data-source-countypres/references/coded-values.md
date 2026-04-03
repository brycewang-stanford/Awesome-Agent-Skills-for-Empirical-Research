# Coded Values: County Presidential Returns 2000-2024

## party Column (6 unique values)

| Value | Rows | Pct | Years Present | Description |
|-------|------|-----|---------------|-------------|
| `DEMOCRAT` | 26,092 | 27.71% | All (2000-2024) | Democratic Party |
| `REPUBLICAN` | 26,092 | 27.71% | All (2000-2024) | Republican Party |
| `OTHER` | 25,392 | 26.97% | All (2000-2024) | Minor/third-party candidates aggregated |
| `LIBERTARIAN` | 10,039 | 10.66% | 2020, 2024 | Libertarian Party (named candidates only in 2020+) |
| `GREEN` | 6,035 | 6.41% | 2000, 2020 | Green Party (Ralph Nader 2000, others 2020) |
| `""` (empty) | 501 | 0.53% | 2024 | Undocumented; corresponds to non-candidate entries |

**Note:** The codebook states results are reported for "three parties: Democrat, Republican,
and Libertarian." In practice, LIBERTARIAN appears only in 2020-2024 as a named party.
For 2004-2016, Libertarian candidates are grouped under OTHER. GREEN appears in 2000
(Nader) and 2020 but is not mentioned in the "three parties" statement.

## candidate Column (19 unique values)

### Named Candidates (by party and year)

| Candidate | Party | Year(s) | Rows |
|-----------|-------|---------|------|
| AL GORE | DEMOCRAT | 2000 | 3,157 |
| GEORGE W. BUSH | REPUBLICAN | 2000, 2004 | 6,315 |
| RALPH NADER | GREEN | 2000 | 3,157 |
| JOHN KERRY | DEMOCRAT | 2004 | 3,158 |
| BARACK OBAMA | DEMOCRAT | 2008, 2012 | 6,316 |
| JOHN MCCAIN | REPUBLICAN | 2008 | 3,158 |
| MITT ROMNEY | REPUBLICAN | 2012 | 3,158 |
| HILLARY CLINTON | DEMOCRAT | 2016 | 3,158 |
| DONALD TRUMP | REPUBLICAN | 2016 | 3,158 |
| DONALD J TRUMP | REPUBLICAN | 2020, 2024 | 10,303 |
| JOSEPH R BIDEN JR | DEMOCRAT | 2020 | 5,117 |
| JO JORGENSEN | LIBERTARIAN | 2020 | 4,955 |
| KAMALA D HARRIS | DEMOCRAT | 2024 | 5,186 |
| CHASE OLIVER | LIBERTARIAN | 2024 | 5,084 |

**Name inconsistency:** "DONALD TRUMP" in 2016 vs "DONALD J TRUMP" in 2020/2024.

> **Best Practice:** Always use the `party` column (e.g., `pl.col("party") == "REPUBLICAN"`)
> for party identification, never the `candidate` column. Candidate names change across years
> (as above), but `party` values are stable. This avoids silent data loss from unmatched names.

### Aggregate/Meta Entries

| Candidate | Rows | Meaning | Action |
|-----------|------|---------|--------|
| OTHER | 27,548 | Aggregate of all unlisted candidates | Keep for completeness; filter for named-candidate analysis |
| TOTAL VOTES CAST | 427 | County total votes | Filter out; redundant with `totalvotes` column |
| UNDERVOTES | 402 | No selection made for president | Filter out for candidate analysis |
| OVERVOTES | 380 | Multiple selections (invalidated) | Filter out for candidate analysis |
| SPOILED | 14 | Ballot invalidated | Filter out for candidate analysis |

## mode Column (20 unique values)

### Aggregate Mode

| Value | Rows | Pct | Years |
|-------|------|-----|-------|
| `TOTAL` | 71,912 | 76.38% | All (2000-2024) |

### Voting Method Breakdown Modes (2020)

| Value | Rows | States | Description |
|-------|------|--------|-------------|
| `ELECTION DAY` | 3,737 | 11 | In-person voting on election day |
| `ABSENTEE` | 1,995 | 5 | Absentee ballots |
| `PROVISIONAL` | 1,832 | 6 | Provisional ballots |
| `ABSENTEE BY MAIL` | 1,038 | 3 | Mail-in absentee specifically |
| `ONE STOP` | 500 | 1 (NC) | North Carolina early voting |
| `ADVANCED VOTING` | 477 | 1 (GA) | Georgia early voting term |
| `PROV` | 477 | 1 (GA) | Georgia provisional abbreviation |
| `EARLY` | 453 | 1 | Generic early voting |
| `EARLY VOTE` | 450 | 1 | Early voting variant |
| `FAILSAFE` | 230 | 1 (SC) | SC failsafe ballot type |
| `FAILSAFE PROVISIONAL` | 230 | 1 (SC) | SC failsafe provisional |
| `IN-PERSON ABSENTEE` | 230 | 1 (SC) | SC in-person absentee |
| `MAIL` | 145 | 1 | Mail-in ballot |
| `2ND ABSENTEE` | 120 | 1 | Second absentee ballot |
| `EARLY VOTING` | 120 | 1 | Early voting variant |

**2020 states with mode breakdowns:** AR, AZ, GA, IA, KY, MD, NC, OK, SC, UT, VA

### Voting Method Breakdown Modes (2024)

| Value | Rows | Description |
|-------|------|-------------|
| `""` (empty) | 2,795 | Undocumented; 2024 only |
| `EARLY VOTING` | 2,150 | Early voting |
| `ELECTION DAY` | 1,872 | Election day voting |
| `ABSENTEE` | 1,518 | Absentee ballots |
| `PROVISIONAL` | 1,094 | Provisional ballots |
| `FAILSAFE PROVISIONAL` | 322 | Failsafe provisional |
| `MAIL-IN` | 268 | Mail-in voting |
| `EARLY` | 132 | Early voting variant |
| `VOTE CENTER` | 36 | Vote center voting |
| `LATE EARLY VOTING` | 18 | Late early voting |

## year Column (7 values)

| Year | Rows | Pct | Notes |
|------|------|-----|-------|
| 2000 | 12,628 | 13.41% | Includes GREEN party (Nader) |
| 2004 | 9,474 | 10.06% | Alaska district anomaly |
| 2008 | 9,474 | 10.06% | |
| 2012 | 9,474 | 10.06% | |
| 2016 | 9,474 | 10.06% | Trump listed as "DONALD TRUMP" |
| 2020 | 22,093 | 23.47% | Mode breakdowns (11 states); GREEN + LIBERTARIAN named |
| 2024 | 21,534 | 22.87% | Mode breakdowns; empty party/mode values |

## version Column (1 value)

| Value | Meaning |
|-------|---------|
| `20260211` | Dataset version date: February 11, 2026 (YYYYMMDD format) |
