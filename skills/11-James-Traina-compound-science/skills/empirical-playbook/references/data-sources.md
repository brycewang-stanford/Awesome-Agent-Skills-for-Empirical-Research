# Data Sources: FRED and World Bank APIs

Programmatic access to FRED (800k+ economic series, real-time/vintage data via ALFRED) and the World Bank API (240+ cross-national development indicators). Covers series retrieval, built-in transformations, panel assembly, and missing-data auditing.

## FRED API (Federal Reserve Economic Data)

### Setup
```python
from fredapi import Fred
fred = Fred(api_key=os.environ['FRED_API_KEY'])  # Free key at fred.stlouisfed.org/docs/api/api_key.html
```

### Core Series Dictionary
```python
FRED_SERIES = {
    # National Accounts
    'GDP':       'Gross Domestic Product (billions, SAAR)',
    'GDPC1':     'Real GDP (chained 2017 dollars, SAAR)',
    'GDPDEF':    'GDP Deflator (2017=100)',
    'PCEC':      'Personal Consumption Expenditures',
    'GPDI':      'Gross Private Domestic Investment',
    # Labor Market
    'UNRATE':    'Unemployment Rate (SA, %)',
    'PAYEMS':    'Total Nonfarm Payrolls (thousands, SA)',
    'LNS11300060': 'Prime-age (25-54) Labor Force Participation Rate',
    'AWHAETP':   'Average Weekly Hours, Total Private',
    'AHETPI':    'Average Hourly Earnings, Total Private (SA)',
    # Prices
    'CPIAUCSL':  'CPI All Items (SA, 1982-84=100)',
    'CPILFESL':  'Core CPI ex Food & Energy (SA)',
    'PCEPI':     'PCE Price Index (SA, 2017=100)',
    'PCEPILFE':  'Core PCE Price Index (SA)',
    # Interest Rates
    'FEDFUNDS':  'Effective Federal Funds Rate (%)',
    'DGS10':     '10-Year Treasury Constant Maturity Rate (%)',
    'DGS2':      '2-Year Treasury Constant Maturity Rate (%)',
    'T10Y2Y':    '10-Year minus 2-Year Treasury Spread (%, daily)',
    'MORTGAGE30US': '30-Year Fixed Rate Mortgage Average (%)',
    # Financial
    'SP500':     'S&P 500 Index (daily, not seasonally adjusted)',
    'DEXUSEU':   'USD/EUR Exchange Rate (daily)',
    'VIXCLS':    'CBOE Volatility Index (VIX, daily)',
    # Housing
    'HOUST':     'Housing Starts (thousands, SAAR)',
    'CSUSHPISA': 'Case-Shiller US National Home Price Index (SA)',
}
```

### Basic Retrieval
```python
import pandas as pd

# Single series
gdp = fred.get_series('GDPC1', observation_start='1990-01-01')

# Multiple series as DataFrame
series_ids = ['UNRATE', 'PAYEMS', 'GDPC1']
df = pd.DataFrame({s: fred.get_series(s) for s in series_ids})

# With date filtering
df = pd.DataFrame({
    s: fred.get_series(s,
                       observation_start='2000-01-01',
                       observation_end='2023-12-31')
    for s in series_ids
})

# Series metadata
info = fred.get_series_info('GDPC1')
# info['frequency'], info['units'], info['seasonal_adjustment']
```

### Data Transformations (built into FRED API)
```python
# Available: 'lin' (levels), 'chg' (change), 'ch1' (change from year ago),
#            'pch' (pct change), 'pc1' (pct change from year ago),
#            'pca' (compounded annual pct change), 'cch' (continuously compounded rate),
#            'cca' (continuously compounded annual), 'log' (natural log)

gdp_growth = fred.get_series('GDPC1', units='pca')  # Annualized quarterly growth
cpi_yoy = fred.get_series('CPIAUCSL', units='pc1')   # Year-over-year inflation
```

### Vintage / Real-Time Data (ALFRED)
Critical for forecast evaluation and data revision studies:
```python
# Get data AS OF a specific vintage date
gdp_vintage = fred.get_series('GDPC1',
                               realtime_start='2008-01-01',
                               realtime_end='2008-12-31')

# Get all vintages for a series (full revision history)
gdp_all_vintages = fred.get_series_all_releases('GDPC1')
# Returns DataFrame with 'realtime_start', 'realtime_end', 'date', 'value'
# Each row = value of 'date' as measured at vintage 'realtime_start'

# First-release values only (initial estimates, no revisions)
gdp_first_release = fred.get_series_first_release('GDPC1')
```

### GeoFRED (Regional Data)
```python
# State-level unemployment
state_unemployment = fred.search('unemployment rate', filter=('frequency', 'Monthly'))
# Or use state-specific series IDs: e.g., 'CAUR' (California), 'TXUR' (Texas)

# BLS area codes for metropolitan areas: use 'LAUMT' prefix
```

### Release Calendar
```python
# Upcoming releases (for event-study timing)
releases = fred.get_releases()
# Returns release_id, name, link, notes, realtime_start, realtime_end
```

---

## World Bank API

### Setup
```python
import wbdata
import datetime
```

### Core Indicators Dictionary
```python
WB_INDICATORS = {
    # GDP and Growth
    'NY.GDP.MKTP.CD':    'GDP (current US$)',
    'NY.GDP.MKTP.KD.ZG': 'GDP growth (annual %)',
    'NY.GDP.PCAP.CD':    'GDP per capita (current US$)',
    'NY.GDP.PCAP.KD':    'GDP per capita (constant 2015 US$)',
    # Poverty and Inequality
    'SI.POV.DDAY':       'Poverty headcount ratio at $2.15/day (% of population)',
    'SI.POV.GINI':       'Gini index',
    'SI.DST.FRST.20':    'Income share held by lowest 20%',
    # Human Development
    'SE.ADT.LITR.ZS':    'Literacy rate, adult total (% ages 15+)',
    'SP.DYN.IMRT.IN':    'Infant mortality rate (per 1,000 live births)',
    'SH.XPD.CHEX.GD.ZS': 'Current health expenditure (% of GDP)',
    'SE.XPD.TOTL.GD.ZS': 'Government expenditure on education (% of GDP)',
    # Labor
    'SL.UEM.TOTL.ZS':    'Unemployment, total (% of total labor force)',
    'SL.TLF.CACT.ZS':    'Labor force participation rate, total (% ages 15+)',
    # Trade and Finance
    'NE.TRD.GNFS.ZS':    'Trade (% of GDP)',
    'BX.KLT.DINV.WD.GD.ZS': 'Foreign direct investment (% of GDP)',
    'GC.DOD.TOTL.GD.ZS': 'Central government debt, total (% of GDP)',
    # Infrastructure / Development
    'EG.ELC.ACCS.ZS':    'Access to electricity (% of population)',
    'IT.NET.USER.ZS':    'Individuals using the Internet (% of population)',
    'SP.URB.TOTL.IN.ZS': 'Urban population (% of total)',
}
```

### Basic Retrieval
```python
# Single indicator, multiple countries
data = wbdata.get_dataframe(
    {'NY.GDP.PCAP.KD': 'gdp_pc'},
    country=['US', 'GB', 'DE', 'JP', 'CN'],
    date=('2000', '2022')
)

# Multiple indicators
indicators = {
    'NY.GDP.PCAP.KD':    'gdp_pc',
    'SI.POV.GINI':       'gini',
    'SL.UEM.TOTL.ZS':    'unemployment',
}
df = wbdata.get_dataframe(indicators, country='all', date=('1990', '2022'))

# Country metadata (ISO codes, regions, income groups)
countries = wbdata.get_country(incomelevel=['LIC', 'LMC'])  # Low and lower-middle income
```

### Country Code Conventions
```python
# ISO3 codes (WB standard): 'USA', 'GBR', 'DEU', 'JPN', 'CHN', 'IND', 'BRA', 'ZAF'
# Use 'all' for all countries; filter with incomelevel, lendingtype, region after

# Income level groups: 'LIC' (low), 'LMC' (lower-middle), 'UMC' (upper-middle), 'HIC' (high)
# Regions: 'EAS', 'ECS', 'LCN', 'MEA', 'NAC', 'SAS', 'SSF'
```

---

## Panel Data Assembly Best Practices

```python
import pandas as pd

# 1. Align frequencies before merging
# FRED is monthly/quarterly; WB is annual -- downsample FRED to annual
gdp_annual = fred.get_series('GDPC1').resample('Y').last()

# 2. Consistent country codes
# FRED uses FIPS/BLS codes; WB uses ISO3; Penn World Tables use ISO3
# Use pycountry for conversion: pycountry.countries.get(alpha_2='US').alpha_3

# 3. Track vintage when mixing sources
# If using FRED real-time data alongside WB data, document reference dates

# 4. Missing value audit before estimation
print(df.isnull().sum())   # Pattern of missingness
print(df.isnull().mean())  # Fraction missing per variable
# Use assert to catch unexpected missingness:
assert df['gdp'].isnull().sum() < 0.05 * len(df)
```

## Scope

Use this reference when downloading, cleaning, or working with macroeconomic time series or cross-national panel data. The `data-detective` agent handles data quality diagnostics after the data is in hand.
