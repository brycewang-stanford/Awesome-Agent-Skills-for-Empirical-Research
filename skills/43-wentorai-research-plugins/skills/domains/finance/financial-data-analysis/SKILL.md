---
name: financial-data-analysis
description: "Methods for acquiring, cleaning, and analyzing financial datasets for research"
metadata:
  openclaw:
    emoji: "💸"
    category: "domains"
    subcategory: "finance"
    keywords: ["financial data", "stock analysis", "quantitative finance", "data pipeline", "financial API"]
    source: "wentor"
---

# Financial Data Analysis

A practical skill for sourcing, processing, and analyzing financial data in academic research contexts. Covers data acquisition from public APIs, cleaning workflows, and standard analytical techniques used in empirical finance research.

## Data Acquisition

### Public Financial Data Sources

| Source | Data Type | Access | Python Package |
|--------|-----------|--------|---------------|
| Yahoo Finance | Prices, fundamentals | Free | `yfinance` |
| FRED (St. Louis Fed) | Macroeconomic indicators | Free (API key) | `fredapi` |
| SEC EDGAR | Company filings (10-K, 10-Q) | Free | `sec-edgar-downloader` |
| WRDS (Wharton) | CRSP, Compustat, IBES | University subscription | `wrds` |
| Alpha Vantage | Real-time and historical prices | Free tier | `alpha_vantage` |

### Fetching Price Data

```python
import yfinance as yf
import pandas as pd

def fetch_stock_data(tickers: list[str], start: str, end: str) -> pd.DataFrame:
    """
    Fetch adjusted close prices for a list of tickers.

    Args:
        tickers: List of ticker symbols (e.g., ['AAPL', 'MSFT'])
        start: Start date (YYYY-MM-DD)
        end: End date (YYYY-MM-DD)
    Returns:
        DataFrame with adjusted close prices
    """
    data = yf.download(tickers, start=start, end=end, auto_adjust=True)
    prices = data['Close'] if len(tickers) > 1 else data[['Close']]
    prices.columns = tickers if len(tickers) > 1 else tickers
    return prices

# Fetch 5 years of data
prices = fetch_stock_data(['AAPL', 'MSFT', 'GOOGL'], '2020-01-01', '2025-01-01')
print(prices.head())
```

### Macroeconomic Data from FRED

```python
from fredapi import Fred

fred = Fred(api_key=os.environ["FRED_API_KEY"])

# Common series for finance research
series_ids = {
    'GDP': 'GDP',
    'CPI': 'CPIAUCSL',
    'Fed_Funds_Rate': 'FEDFUNDS',
    'Unemployment': 'UNRATE',
    '10Y_Treasury': 'DGS10',
    'VIX': 'VIXCLS'
}

macro_data = pd.DataFrame()
for name, sid in series_ids.items():
    macro_data[name] = fred.get_series(sid, observation_start='2000-01-01')
```

## Data Cleaning Pipeline

Financial data requires careful cleaning before analysis:

```python
def clean_financial_data(df: pd.DataFrame) -> pd.DataFrame:
    """Standard cleaning pipeline for financial time series."""
    cleaned = df.copy()

    # 1. Handle missing values
    missing_pct = cleaned.isnull().sum() / len(cleaned) * 100
    print(f"Missing data:\n{missing_pct}")

    # 2. Forward-fill for market holidays (max 5 days)
    cleaned = cleaned.ffill(limit=5)

    # 3. Remove remaining NaN rows
    cleaned = cleaned.dropna()

    # 4. Detect and flag outliers (>5 sigma daily returns)
    returns = cleaned.pct_change()
    z_scores = (returns - returns.mean()) / returns.std()
    outliers = (z_scores.abs() > 5).any(axis=1)
    print(f"Outlier days flagged: {outliers.sum()}")

    # 5. Verify data integrity
    assert cleaned.index.is_monotonic_increasing, "Index must be sorted"
    assert not cleaned.duplicated().any(), "No duplicate rows allowed"

    return cleaned
```

## Standard Financial Metrics

### Return Calculations

```python
def compute_returns(prices: pd.DataFrame) -> dict:
    """Compute standard return metrics."""
    simple_returns = prices.pct_change().dropna()
    log_returns = np.log(prices / prices.shift(1)).dropna()

    annualized_return = simple_returns.mean() * 252
    annualized_vol = simple_returns.std() * np.sqrt(252)
    sharpe_ratio = annualized_return / annualized_vol

    # Maximum drawdown
    cumulative = (1 + simple_returns).cumprod()
    rolling_max = cumulative.cummax()
    drawdown = (cumulative - rolling_max) / rolling_max
    max_drawdown = drawdown.min()

    return {
        'annualized_return': annualized_return,
        'annualized_volatility': annualized_vol,
        'sharpe_ratio': sharpe_ratio,
        'max_drawdown': max_drawdown
    }
```

## Event Studies

A common methodology in empirical finance research:

1. Define the event window (e.g., [-5, +5] trading days around earnings announcement)
2. Estimate normal returns using the market model over the estimation window (e.g., [-250, -30])
3. Compute abnormal returns: AR = R_actual - R_expected
4. Aggregate cumulative abnormal returns (CAR) across firms
5. Test statistical significance using parametric (Patell test) and non-parametric (sign test) methods

Always report both raw and risk-adjusted results, and perform robustness checks with different estimation windows and benchmark models.

## Reproducibility

Store all data processing steps in version-controlled scripts. Use `pandas.DataFrame.to_parquet()` for efficient storage of intermediate datasets, and document data provenance including download dates, API versions, and any filters applied.
