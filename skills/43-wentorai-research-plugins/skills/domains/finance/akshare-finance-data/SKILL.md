---
name: akshare-finance-data
description: "Access Chinese and global financial data using the AkShare Python library"
metadata:
  openclaw:
    emoji: "💹"
    category: "domains"
    subcategory: "finance"
    keywords: ["akshare", "financial data", "chinese stocks", "market data", "economic indicators", "quantitative finance"]
    source: "https://github.com/akfamily/akshare"
---

# AkShare Financial Data Guide

## Overview

AkShare is an open-source Python library providing free access to Chinese and global financial market data. It aggregates data from 50+ sources including Sina Finance, East Money, Tushare, Yahoo Finance, and central bank websites. No API key required for most functions. Essential for financial research, quantitative analysis, and economic studies involving Chinese market data.

## Installation

```bash
pip install akshare --upgrade

# Verify
python -c "import akshare as ak; print(ak.__version__)"
```

## Core Data Categories

### Stock Market Data (A-Shares)

```python
import akshare as ak
import pandas as pd

# Real-time quotes for all A-shares
df = ak.stock_zh_a_spot_em()
print(df.head())
# Columns: 代码, 名称, 最新价, 涨跌幅, 成交量, 成交额, ...

# Historical daily data for a specific stock
df = ak.stock_zh_a_hist(symbol="000001", period="daily",
                         start_date="20200101", end_date="20261231")
print(df.columns)
# 日期, 开盘, 收盘, 最高, 最低, 成交量, 成交额, 振幅, 涨跌幅, 换手率

# Minute-level data
df = ak.stock_zh_a_hist_min_em(symbol="000001", period="5",
                                 start_date="2026-01-01 09:30:00",
                                 end_date="2026-03-10 15:00:00")
```

### Fund Data

```python
# ETF list
df = ak.fund_etf_spot_em()

# Open-end fund NAV history
df = ak.fund_open_fund_info_em(symbol="000001", indicator="单位净值走势")

# Fund manager information
df = ak.fund_manager_em(symbol="000001")
```

### Bond Market

```python
# China government bond yields
df = ak.bond_china_yield(start_date="20200101", end_date="20261231")

# Corporate bond issuance
df = ak.bond_cb_jsl()  # Convertible bonds from jisilu.cn
```

### Macroeconomic Indicators

```python
# GDP quarterly data
df = ak.macro_china_gdp()

# CPI monthly data
df = ak.macro_china_cpi()

# PMI (Purchasing Managers' Index)
df = ak.macro_china_pmi()

# Money supply (M0, M1, M2)
df = ak.macro_china_money_supply()

# US economic data
df = ak.macro_usa_gdp()  # US GDP
df = ak.macro_usa_cpi()  # US CPI
df = ak.macro_usa_unemployment_rate()  # US unemployment
```

### Foreign Exchange

```python
# CNY exchange rates
df = ak.currency_boc_sina(symbol="美元", start_date="20200101", end_date="20261231")

# All major currency pairs
df = ak.fx_spot_quote()
```

### Futures and Commodities

```python
# Chinese commodity futures
df = ak.futures_zh_daily_sina(symbol="RB0")  # Rebar futures

# Gold and silver prices
df = ak.futures_foreign_commodity_realtime(symbol="黄金")
```

## Research Workflow Example

### Financial Panel Data Construction

```python
import akshare as ak
import pandas as pd

def build_stock_panel(symbols: list, start: str, end: str) -> pd.DataFrame:
    """Build a panel dataset of stock returns and fundamentals."""
    panels = []

    for symbol in symbols:
        # Price data
        price = ak.stock_zh_a_hist(symbol=symbol, period="daily",
                                    start_date=start, end_date=end)
        price = price.rename(columns={"日期": "date", "收盘": "close",
                                       "涨跌幅": "return", "成交额": "volume"})
        price["symbol"] = symbol
        price["date"] = pd.to_datetime(price["date"])

        # Financial statements (annual)
        try:
            fin = ak.stock_financial_analysis_indicator(symbol=symbol)
            fin = fin[["日期", "净资产收益率(%)", "资产负债率(%)"]].rename(
                columns={"日期": "report_date", "净资产收益率(%)": "roe",
                         "资产负债率(%)": "leverage"})
        except Exception:
            fin = pd.DataFrame()

        panels.append(price[["date", "symbol", "close", "return", "volume"]])

    panel = pd.concat(panels, ignore_index=True)
    panel = panel.set_index(["symbol", "date"]).sort_index()
    return panel

# Usage
symbols = ["000001", "600519", "000858", "601318", "000333"]
panel = build_stock_panel(symbols, "20200101", "20261231")
print(f"Panel: {panel.shape[0]} observations, {panel.index.get_level_values(0).nunique()} firms")
```

### Event Study

```python
def event_study(symbol: str, event_date: str, window: int = 10):
    """Simple event study around a given date."""
    # Get data with buffer
    start = pd.to_datetime(event_date) - pd.Timedelta(days=window*3)
    end = pd.to_datetime(event_date) + pd.Timedelta(days=window*3)

    df = ak.stock_zh_a_hist(symbol=symbol, period="daily",
                             start_date=start.strftime("%Y%m%d"),
                             end_date=end.strftime("%Y%m%d"))
    df["date"] = pd.to_datetime(df["日期"])
    df["return"] = df["涨跌幅"].astype(float)
    df = df.set_index("date").sort_index()

    # Market return (CSI 300)
    market = ak.stock_zh_index_daily(symbol="sh000300")
    market["date"] = pd.to_datetime(market["date"])
    market = market.set_index("date")
    market["mkt_return"] = market["close"].pct_change() * 100

    # Merge and compute abnormal returns
    merged = df[["return"]].join(market[["mkt_return"]], how="inner")
    merged["abnormal_return"] = merged["return"] - merged["mkt_return"]

    # Event window
    event_idx = merged.index.get_indexer([pd.to_datetime(event_date)], method="nearest")[0]
    event_window = merged.iloc[event_idx-window:event_idx+window+1]
    event_window["CAR"] = event_window["abnormal_return"].cumsum()

    return event_window[["return", "mkt_return", "abnormal_return", "CAR"]]
```

## Common Gotchas

| Issue | Solution |
|-------|---------|
| Data source temporarily unavailable | AkShare aggregates from web sources; retry or use `try/except` |
| Inconsistent column names across functions | Always check `df.columns` before processing |
| Date format varies (string vs datetime) | Standardize: `pd.to_datetime(df["日期"])` |
| Some functions require specific symbol format | A-shares: 6-digit code; indices: `sh000001`; HK: `00700` |
| Rate limiting from upstream sources | Add `time.sleep(1)` between batch requests |

## References

- [AkShare Documentation](https://akshare.akfamily.xyz/)
- [AkShare GitHub](https://github.com/akfamily/akshare)
- [AkShare API Reference](https://akshare.akfamily.xyz/data/stock/stock.html)
