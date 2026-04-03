---
name: climate-science-guide
description: "Climate data analysis, modeling workflows, and carbon neutrality research met..."
metadata:
  openclaw:
    emoji: "☁️"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["climate change", "carbon neutrality", "atmospheric science", "climatology", "climate modeling"]
    source: "wentor"
---

# Climate Science Guide

A research skill for analyzing climate data, working with climate model outputs, and conducting carbon-related studies. Covers data sources, standard analytical workflows, and visualization techniques used in climate science publications.

## Climate Data Sources

### Observational Datasets

| Dataset | Variables | Resolution | Period | Source |
|---------|-----------|-----------|--------|--------|
| ERA5 | Temperature, precipitation, wind, etc. | 0.25 deg, hourly | 1940-present | ECMWF/Copernicus |
| GPCP | Precipitation | 2.5 deg, monthly | 1979-present | NASA |
| HadCRUT5 | Surface temperature anomaly | 5 deg, monthly | 1850-present | Met Office |
| NOAA GHCN | Station temperature, precipitation | Point data | 1850-present | NOAA |
| CRU TS | Temperature, precipitation, vapor pressure | 0.5 deg, monthly | 1901-present | UEA CRU |

### CMIP6 Model Outputs

```python
import xarray as xr

def load_cmip6_data(model: str, experiment: str, variable: str,
                     member: str = 'r1i1p1f1') -> xr.Dataset:
    """
    Load CMIP6 model output from a local or cloud archive.

    Args:
        model: Model name (e.g., 'CESM2', 'UKESM1-0-LL')
        experiment: SSP scenario (e.g., 'ssp245', 'ssp585', 'historical')
        variable: Variable name (e.g., 'tas', 'pr', 'tos')
        member: Ensemble member ID
    """
    # Using Pangeo cloud catalog
    import intake
    catalog = intake.open_esm_datastore(
        "https://storage.googleapis.com/cmip6/pangeo-cmip6.json"
    )
    query = catalog.search(
        source_id=model,
        experiment_id=experiment,
        variable_id=variable,
        member_id=member,
        table_id='Amon'  # Monthly atmospheric data
    )
    ds = query.to_dataset_dict(zarr_kwargs={'consolidated': True})
    key = list(ds.keys())[0]
    return ds[key]
```

## Temperature Trend Analysis

### Computing Global Mean Temperature Anomaly

```python
import numpy as np

def compute_global_mean_anomaly(ds: xr.Dataset, var: str = 'tas',
                                 baseline: tuple = (1850, 1900)) -> xr.DataArray:
    """
    Compute area-weighted global mean temperature anomaly
    relative to a baseline period.
    """
    # Area weighting by latitude
    weights = np.cos(np.deg2rad(ds.lat))
    weights = weights / weights.sum()

    # Global mean
    global_mean = ds[var].weighted(weights).mean(dim=['lat', 'lon'])

    # Baseline climatology
    baseline_mean = global_mean.sel(
        time=slice(str(baseline[0]), str(baseline[1]))
    ).mean('time')

    anomaly = global_mean - baseline_mean
    return anomaly

# Usage
# anomaly = compute_global_mean_anomaly(historical_ds)
# anomaly.plot()  # produces a time series of temperature anomaly
```

## Carbon Budget Analysis

### Emissions and Remaining Budget

Track cumulative CO2 emissions against the remaining carbon budget for temperature targets:

```python
def carbon_budget_tracker(cumulative_emissions_gtco2: float,
                           target_warming: float = 1.5) -> dict:
    """
    Estimate remaining carbon budget.
    Based on IPCC AR6 estimates.
    """
    # IPCC AR6 remaining budget from 2020 (GtCO2)
    budgets = {
        1.5: {'50pct': 500, '67pct': 400, '83pct': 300},
        2.0: {'50pct': 1350, '67pct': 1150, '83pct': 900}
    }
    budget = budgets[target_warming]
    remaining = {prob: val - cumulative_emissions_gtco2
                 for prob, val in budget.items()}
    # At ~40 GtCO2/year current rate
    years_left = {prob: max(0, val / 40) for prob, val in remaining.items()}
    return {'remaining_budget_GtCO2': remaining, 'years_at_current_rate': years_left}

result = carbon_budget_tracker(cumulative_emissions_gtco2=200, target_warming=1.5)
print(result)
```

## Climate Visualization

### Spatial Maps with Cartopy

```python
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

def plot_climate_map(data: xr.DataArray, title: str,
                      cmap: str = 'RdBu_r', vmin: float = None,
                      vmax: float = None):
    """Publication-quality climate map."""
    fig = plt.figure(figsize=(12, 6))
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.Robinson())
    ax.coastlines(linewidth=0.5)
    ax.gridlines(draw_labels=True, linewidth=0.3, alpha=0.5)

    im = data.plot(ax=ax, transform=ccrs.PlateCarree(),
                   cmap=cmap, vmin=vmin, vmax=vmax,
                   add_colorbar=False)
    cbar = plt.colorbar(im, ax=ax, orientation='horizontal',
                         pad=0.05, shrink=0.7)
    cbar.set_label(data.attrs.get('units', ''))
    ax.set_title(title, fontsize=14)
    plt.tight_layout()
    return fig
```

## Best Practices

- Always report uncertainties: use multi-model ensembles and provide confidence intervals
- Document data preprocessing steps for reproducibility
- Use standardized calendar handling (`cftime`) for model outputs with non-standard calendars
- Apply bias correction (e.g., quantile mapping) when comparing model outputs to observations
- Follow FAIR data principles and cite datasets using their DOIs
