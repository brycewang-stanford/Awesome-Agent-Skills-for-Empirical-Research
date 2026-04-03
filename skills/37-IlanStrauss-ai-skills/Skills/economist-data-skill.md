# Economist Data Skill

## Overview

A Claude skill for economists that ensures rigorous data decisions and directs users only to authoritative sources. Interfaces with Playwright MCP for web data retrieval.

**Tagline:** *Real data, not articles about data.*

---

## Core Principle

**This skill ensures users make conscious, explicit decisions about data specifications before any data is retrieved. It only directs users to authoritative, high-quality sources.**

The skill interfaces with **Playwright MCP** to navigate data portals and extract data. Users do not need to understand Playwright - they simply request data and confirm specifications.

---

## Compatibility

This skill works with any AI agent that has browser automation capabilities:
- **Claude** → Playwright MCP
- **Other agents** → Playwright, Selenium, Puppeteer, or equivalent

The core logic (data decisions, source selection, output format) is agent-agnostic.

---

## Prerequisites Check

Before using this skill, verify browser automation is installed and working.

**First-time users:**
```
⚠️  BROWSER AUTOMATION REQUIRED

This skill uses browser automation to fetch data from authoritative sources.

Do you have browser automation available?
→ [Y] Yes, it's installed and working
→ [N] No, I need to install it

For Claude users (Playwright MCP):
1. npm install -g @anthropic/mcp-playwright
2. Configure in your Claude settings
3. Restart Claude and return to this skill
Documentation: https://github.com/anthropics/mcp-playwright

For other AI agents:
- Ensure Playwright, Selenium, or equivalent is configured
- Agent must be able to navigate URLs and extract page content
```

Only proceed with data requests after confirming browser automation is working.

---

## User Profile Setup

On first use, collect and store preferences. If returning user, confirm: "Welcome back. Using your saved profile. Type 'update profile' to change."

### Required Setup Questions

**1. Software Environment**
"What statistical software are you using?"
- R (tidyverse)
- Python (pandas)
- Stata
- Excel
- Other (specify)

**2. Currency Preference**
"What is your preferred currency for monetary values?"
- USD ($)
- EUR (€)
- GBP (£)
- Local currency (varies by data)
- Other (specify)

**3. Real vs Nominal Default**
"For price-sensitive data, do you typically prefer:"
- Nominal (current prices)
- Real (constant prices) → then ask base year and deflator preference

**4. Seasonal Adjustment Default**
"For time series data, do you typically prefer:"
- Seasonally adjusted (SA)
- Not seasonally adjusted (NSA)
- Ask me each time

**5. Frequency Default**
"What is your typical data frequency?"
- Annual
- Quarterly
- Monthly
- Highest available
- Ask me each time

### Profile Summary Display
```
ECONOMIST DATA PROFILE
━━━━━━━━━━━━━━━━━━━━━━
Software:      R (tidyverse)
Currency:      USD
Price type:    Real (2020 base, GDP deflator)
Seasonal adj:  Seasonally adjusted
Frequency:     Quarterly
━━━━━━━━━━━━━━━━━━━━━━
Say "update profile" to change
```

---

## Mandatory Decision Points (Cannot Be Skipped)

Before ANY data retrieval, the user must explicitly confirm these specifications. The skill will NOT silently default - these decisions must be conscious.

### 1. Price Basis
```
⚠️  PRICE BASIS DECISION REQUIRED

Is this data request for:
→ [N] Nominal (current prices, as recorded)
→ [R] Real (inflation-adjusted, constant prices)

Why it matters: Nominal GDP in 2024 vs 2004 reflects both
real growth AND inflation. Real GDP isolates actual growth.
```

If Real selected:
```
⚠️  BASE YEAR DECISION REQUIRED

Adjust to constant prices of what year?
→ Common options: 2017, 2020, latest available
→ Enter year: ___

Why it matters: "Real 2020 dollars" vs "Real 2010 dollars"
are different values. Ensure consistency across your analysis.
```

```
⚠️  ADJUSTMENT METHOD REQUIRED

Deflate using:
→ [C] CPI (consumer prices)
→ [G] GDP Deflator (broad economy)
→ [P] PPP (cross-country comparison)

Why it matters: CPI reflects consumer purchasing power.
GDP deflator captures full economic output.
PPP enables cross-country comparison.
```

### 2. Seasonal Adjustment
```
⚠️  SEASONAL ADJUSTMENT DECISION REQUIRED

Do you want:
→ [SA] Seasonally Adjusted (removes predictable seasonal patterns)
→ [NSA] Not Seasonally Adjusted (raw data)

Why it matters: Retail sales spike in December.
SA data removes this pattern for trend analysis.
NSA shows actual recorded values.
```

### 3. Frequency
```
⚠️  FREQUENCY DECISION REQUIRED

What time frequency?
→ [A] Annual
→ [Q] Quarterly
→ [M] Monthly

Why it matters: Higher frequency = more observations but
more noise. Annual smooths short-term volatility.
```

### 4. Currency (for monetary values)
```
⚠️  CURRENCY DECISION REQUIRED

Report values in:
→ [USD] US Dollars
→ [EUR] Euros
→ [LCU] Local Currency Units
→ [PPP] PPP-adjusted international dollars

Why it matters: Exchange rates fluctuate.
USD values for Brazil in 2020 vs 2024 reflect
both economic change AND Real/USD exchange rate moves.
```

---

## Decision Summary Confirmation

Before fetching, always display and require confirmation:

```
┌─────────────────────────────────────────────┐
│         DATA REQUEST CONFIRMATION           │
├─────────────────────────────────────────────┤
│ Indicator:    GDP                           │
│ Countries:    USA, DEU, JPN                 │
│ Date range:   2015-2024                     │
├─────────────────────────────────────────────┤
│ Price basis:  REAL                          │
│ Base year:    2020                          │
│ Deflator:     GDP deflator                  │
│ Seasonal:     Seasonally adjusted           │
│ Frequency:    Quarterly                     │
│ Currency:     USD                           │
├─────────────────────────────────────────────┤
│ Source:       OECD                          │
└─────────────────────────────────────────────┘

⚠️  Please confirm these specifications are correct
for your analysis. Type YES to proceed or specify
what to change.
```

---

## Authoritative Sources

### Official Statistics - Macroeconomic

| Source | Coverage | URL |
|--------|----------|-----|
| FRED | US primary | https://fred.stlouisfed.org |
| BEA | US national accounts | https://www.bea.gov/data |
| BLS | US labor & prices | https://www.bls.gov/data/ |
| Census Bureau | US demographics & trade | https://data.census.gov |
| World Bank | International | https://data.worldbank.org |
| OECD | Developed countries | https://data.oecd.org |
| IMF WEO | Global forecasts | https://www.imf.org/en/Publications/WEO |
| IMF IFS | International financial stats | https://data.imf.org |
| Eurostat | EU | https://ec.europa.eu/eurostat |
| ECB | Eurozone monetary | https://data.ecb.europa.eu |
| BIS | International banking | https://www.bis.org/statistics/ |

### Official Statistics - Specialized

| Source | Coverage | URL |
|--------|----------|-----|
| ILO | International labor | https://ilostat.ilo.org |
| UN Comtrade | Detailed trade flows | https://comtradeplus.un.org |
| WTO | Trade statistics | https://stats.wto.org |
| UN Population | Demographics | https://population.un.org/dataportal/ |
| UNDP | Human development | https://hdr.undp.org/data-center |

### PPP & Price Comparisons

| Source | Coverage | URL |
|--------|----------|-----|
| World Bank ICP | Global PPP | https://data.worldbank.org |
| OECD PPP | OECD countries | https://data.oecd.org/conversion/ |
| Penn World Table | Academic standard | https://www.rug.nl/ggdc/productivity/pwt/ |

---

## Academic Data Repositories

### Journal Replication Data

Peer-reviewed, documented, quality-vetted datasets from published research.

| Repository | Journals/Coverage | URL |
|------------|-------------------|-----|
| AEA Data & Code | AER, AEJ journals, JEL, JEP | https://www.openicpsr.org/openicpsr/search/aea/studies |
| Econometrica | Econometrica replications | https://www.econometricsociety.org/publications/econometrica/browse |
| QJE Dataverse | Quarterly Journal of Economics | https://dataverse.harvard.edu/dataverse/qje |
| REStud | Review of Economic Studies | https://restud.github.io/data-editor/ |
| Journal of Finance | Finance research | https://github.com/jofrhwld/jfinance_data |
| Review of Economics & Statistics | REStat | https://dataverse.harvard.edu/dataverse/restat |
| Journal of Political Economy | JPE | https://www.journals.uchicago.edu/journals/jpe/data |

### General Academic Repositories

| Repository | Description | URL |
|------------|-------------|-----|
| Harvard Dataverse | Multi-discipline, many econ journals | https://dataverse.harvard.edu |
| ICPSR | Social science data archive | https://www.icpsr.umich.edu |
| Zenodo | Open research data | https://zenodo.org |
| OpenICPSR | Open access subset | https://www.openicpsr.org |

### Canonical Economic Datasets

Widely-used datasets with established methodology:

| Dataset | Description | URL |
|---------|-------------|-----|
| Penn World Table | Cross-country GDP, productivity | https://www.rug.nl/ggdc/productivity/pwt/ |
| Maddison Project | Historical GDP (back to 1 AD) | https://www.rug.nl/ggdc/historicaldevelopment/maddison/ |
| World Inequality Database | Income & wealth distribution | https://wid.world |
| SWIID | Standardized inequality measures | https://fsolt.org/swiid/ |
| Barro-Lee | Educational attainment | https://barrolee.github.io/BarroLeeDataSet/ |
| Polity | Political regime data | https://www.systemicpeace.org/polityproject.html |
| CEPII | Trade & geography data | http://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele.asp |
| NBER Macrohistory | US historical macro | https://www.nber.org/research/data/nber-macrohistory-database |

### Working Paper Data

| Source | Description | URL |
|--------|-------------|-----|
| NBER | Working paper data appendices | https://www.nber.org/papers |
| CEPR | European policy research | https://cepr.org |
| IZA | Labor economics | https://www.iza.org |

---

## Source Selection Logic

When user requests data, select source by priority:

1. **Official statistics** (BLS, BEA, Eurostat) - for current standard indicators
2. **Canonical datasets** (Penn World Table, WID) - for established cross-country research
3. **Journal replication data** - when replicating or extending published research
4. **Academic repositories** - for specialized research datasets

Always inform user which source and why:

```
SOURCE SELECTED: Penn World Table 10.0

Why: You requested cross-country real GDP comparison
over 50+ years. PWT provides consistent methodology
across countries and time, using PPP adjustments.

Alternative sources:
- World Bank WDI (shorter time series, similar methodology)
- Maddison Project (longer history, less detail)
```

---

## Tidy Data Output Format

All output follows tidy data principles:
- Each variable is a column
- Each observation is a row
- Column names: lowercase, snake_case

### Required Metadata Columns (MANDATORY)

Every dataset MUST include these two columns:
1. **`source`** - The authoritative institution that produced the data (e.g., "BLS via FRED", "World Bank", "Penn World Table")
2. **`accessed_date`** - The date the data was downloaded (ISO 8601 format: YYYY-MM-DD)

These columns enable:
- Reproducibility (others can verify where data came from)
- Data provenance tracking
- Citation generation
- Identifying when data may be stale or revised

### Standard Schema

```csv
date,country,country_code,indicator,value,unit,price_type,base_year,currency,seasonal_adj,frequency,source,source_url,accessed_date
2024-01-01,United States,USA,gdp,22345.6,billions,real,2020,USD,SA,quarterly,BEA,https://...,2025-01-20
```

### Column Definitions

| Column | Description | Example Values |
|--------|-------------|----------------|
| date | ISO 8601 date | 2024-01-01, 2024-Q1 |
| country | Full country name | United States |
| country_code | ISO 3166-1 alpha-3 | USA, GBR, DEU |
| indicator | Variable name | gdp, cpi, unemployment_rate |
| value | Numeric value | 22345.6 |
| unit | Unit of measurement | billions, percent, index |
| price_type | nominal or real | nominal, real |
| base_year | Base year if real | 2020, NA |
| currency | ISO 4217 code | USD, EUR, LCU |
| seasonal_adj | Adjustment status | SA, NSA |
| frequency | Data frequency | annual, quarterly, monthly |
| source | Source institution | BEA, FRED, World Bank |
| source_url | Direct URL to data | https://... |
| accessed_date | Date retrieved | 2025-01-20 |

---

## Software-Specific Output

After retrieving data, provide code snippet for user's software:

### R (tidyverse)
```r
library(tidyverse)
df <- read_csv("economist_data.csv") |>
  mutate(date = as.Date(date))
```

### Python (pandas)
```python
import pandas as pd
df = pd.read_csv("economist_data.csv", parse_dates=["date"])
```

### Stata
```stata
import delimited "economist_data.csv", clear
gen date2 = date(date, "YMD")
format date2 %td
```

### Excel
Note: Open CSV, then format date column as Date. Use Data > Text to Columns if needed.

---

## Educational Prompts

When decisions seem inconsistent or could cause issues, alert the user:

### Consistency Check
```
⚠️  CONSISTENCY CHECK

You requested NOMINAL GDP for USA but your previous
request for Germany was REAL (2020 base).

Comparing nominal USA to real Germany is invalid.

→ [1] Change this request to Real (2020 base) to match
→ [2] Keep as Nominal (I understand the implications)
```

### Methodology Note
```
⚠️  METHODOLOGY NOTE

You selected PPP adjustment. Note that:
- PPP is best for cross-country LEVEL comparisons
- For growth rates, local currency or USD is often preferred
- PPP conversion factors are estimates with uncertainty

→ Continue with PPP? (yes/change)
```

### Source Recommendation
```
⚠️  SOURCE RECOMMENDATION

For cross-country growth regressions, consider using
Penn World Table instead of raw World Bank data.

PWT advantages:
- Consistent PPP methodology across countries
- Capital stock estimates included
- Productivity measures (TFP)
- Widely used in literature (comparable to other papers)

→ [1] Switch to Penn World Table
→ [2] Keep World Bank (I have a specific reason)
```

### Replication Data Available
```
⚠️  REPLICATION DATA AVAILABLE

Your query matches data from a published paper:
Acemoglu, Johnson & Robinson (2001) - "Colonial Origins"
Replication data: https://economics.mit.edu/people/faculty/daron-acemoglu

Using original replication data ensures consistency
with the published methodology.

→ [1] Use replication data
→ [2] Fetch fresh data (I want to extend/update)
```

---

## Playwright Integration

This skill uses **Playwright MCP** for data retrieval. The workflow:

1. User requests data
2. Skill prompts for all mandatory decisions
3. User confirms specifications
4. Skill identifies authoritative source
5. Playwright navigates to source URL
6. Playwright extracts data from page/downloads
7. Skill formats output as tidy data
8. Skill provides software-specific code snippet

Users do not interact with Playwright directly - they simply request data and confirm specifications.

---

## Example Interaction

**User:** Get US GDP for the last 5 years

**Skill:**
```
⚠️  PRICE BASIS DECISION REQUIRED

Is this data request for:
→ [N] Nominal (current prices, as recorded)
→ [R] Real (inflation-adjusted, constant prices)
```

**User:** R

**Skill:**
```
⚠️  BASE YEAR DECISION REQUIRED

Adjust to constant prices of what year?
→ Enter year (common: 2017, 2020):
```

**User:** 2020

**Skill:**
```
⚠️  ADJUSTMENT METHOD REQUIRED

Deflate using:
→ [C] CPI | [G] GDP Deflator | [P] PPP
```

**User:** G

**Skill:**
```
⚠️  SEASONAL ADJUSTMENT DECISION REQUIRED

→ [SA] Seasonally Adjusted | [NSA] Not Seasonally Adjusted
```

**User:** SA

**Skill:**
```
⚠️  FREQUENCY DECISION REQUIRED

→ [A] Annual | [Q] Quarterly | [M] Monthly
```

**User:** Q

**Skill:**
```
┌─────────────────────────────────────────────┐
│         DATA REQUEST CONFIRMATION           │
├─────────────────────────────────────────────┤
│ Indicator:    GDP                           │
│ Countries:    USA                           │
│ Date range:   2020-2025                     │
├─────────────────────────────────────────────┤
│ Price basis:  REAL                          │
│ Base year:    2020                          │
│ Deflator:     GDP deflator                  │
│ Seasonal:     Seasonally adjusted           │
│ Frequency:    Quarterly                     │
│ Currency:     USD                           │
├─────────────────────────────────────────────┤
│ Source:       BEA via FRED                  │
└─────────────────────────────────────────────┘

Type YES to proceed or specify changes:
```

**User:** YES

**Skill:** [Uses Playwright to fetch from FRED, returns tidy CSV + R code snippet]

---

## Why This Matters

This skill exists because:

1. **Data decisions are analytical decisions** - Real vs nominal isn't a technical detail, it changes what you're measuring

2. **Silent defaults cause errors** - "I didn't realize it was seasonally adjusted" has ruined analyses

3. **Comparability requires consistency** - Mixing specifications across series invalidates comparisons

4. **Source quality matters** - BLS data isn't the same as a news article saying "unemployment is 4%"

5. **Replication matters** - Using the same data sources as published research enables valid comparison and extension

**The friction is the feature.** Taking 30 seconds to confirm specifications prevents hours of rework from bad data.

6. **Provenance is non-negotiable** - Every dataset must include `source` and `accessed_date` columns. Data without provenance is unverifiable and unusable for serious research.
